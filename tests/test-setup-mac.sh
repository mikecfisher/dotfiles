#!/bin/bash
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
REAL_CHEZMOI="$(command -v chezmoi)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

MOCK_BIN="${WORK_DIR}/bin"
MOCK_STATE="${WORK_DIR}/state"
MOCK_CALLS="${WORK_DIR}/calls"
MOCK_INVENTORY="${WORK_DIR}/inventory.json"
MOCK_BUNDLE_INVENTORY="${WORK_DIR}/bundle-inventory.json"
MOCK_MAS_LIST="${WORK_DIR}/mas-list"
MOCK_TAPS="${WORK_DIR}/taps"
mkdir -p "${MOCK_BIN}" "${MOCK_STATE}"
: >"${MOCK_CALLS}"
printf '%s\n' '{"formulae":[],"casks":[]}' >"${MOCK_INVENTORY}"
: >"${MOCK_BUNDLE_INVENTORY}"
: >"${MOCK_TAPS}"

cat >"${MOCK_BIN}/brew" <<'EOF'
#!/bin/bash
set -eu
case "${1:-}" in
  shellenv) exit 0 ;;
  info) cat "${MOCK_INVENTORY}" ;;
  bundle)
    printf 'brew bundle %s\n' "$*" >>"${MOCK_CALLS}"
    if [ -s "${MOCK_BUNDLE_INVENTORY}" ]; then
      cp "${MOCK_BUNDLE_INVENTORY}" "${MOCK_INVENTORY}"
    fi
    exit 0
    ;;
  install|reinstall)
    printf 'brew %s\n' "$*" >>"${MOCK_CALLS}"
    exit 0
    ;;
  tap)
    if [ "$#" -eq 1 ]; then
      cat "${MOCK_TAPS}"
    elif ! grep -qxF "${2}" "${MOCK_TAPS}"; then
      printf '%s\n' "${2}" >>"${MOCK_TAPS}"
      printf 'brew tap %s\n' "${2}" >>"${MOCK_CALLS}"
    fi
    ;;
  trust) exit 0 ;;
  update)
    printf 'brew update\n' >>"${MOCK_CALLS}"
    exit 0
    ;;
  --version) echo 'Homebrew 99.0.0-test' ;;
  *) printf 'unexpected brew call: %s\n' "$*" >&2; exit 1 ;;
esac
EOF

cat >"${MOCK_BIN}/chezmoi" <<'EOF'
#!/bin/bash
if [ "${1:-}" = "verify" ]; then
  exit "${MOCK_CHEZMOI_VERIFY_STATUS:-0}"
fi
exec "${REAL_CHEZMOI}" "$@"
EOF

cat >"${MOCK_BIN}/mas" <<'EOF'
#!/bin/bash
set -eu
case "${1:-}" in
  list) cat "${MOCK_MAS_LIST}" ;;
  install)
    printf 'mas install %s\n' "${2:-}" >>"${MOCK_CALLS}"
    exit 0
    ;;
  *) exit 1 ;;
esac
EOF

cat >"${MOCK_BIN}/sudo" <<'EOF'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"${MOCK_CALLS}"
exit 0
EOF

cat >"${MOCK_BIN}/sw_vers" <<'EOF'
#!/bin/bash
echo '99.0-test'
EOF
chmod +x "${MOCK_BIN}"/*

render_profile() {
  local profile="$1"
  local config="${WORK_DIR}/${profile}.toml"
  local output="${WORK_DIR}/setup-mac-${profile}"
  printf '[data]\nmachine_type = "%s"\nis_work_machine = false\nuse_1password = false\ngit_name = "Test"\ngit_email = "test@example.com"\n' \
    "${profile}" >"${config}"
  chezmoi execute-template --source "${ROOT}" --config "${config}" \
    <"${ROOT}/dot_local/bin/executable_setup-mac.tmpl" >"${output}"
  chmod +x "${output}"
  printf '%s\n' "${output}"
}

make_inventory() {
  local profile="$1"
  local output="$2"
  local formula_expression cask_expression formulae casks

  formula_expression='[.packages.common.brews[]]'
  cask_expression='[.packages.common.standard_casks[], .packages.common.heavy_casks[], .packages.common.privileged_casks[]]'
  if [ "${profile}" = "personal" ]; then
    formula_expression='[.packages.common.brews[], .packages.personal.brews[]]'
    cask_expression='[.packages.common.standard_casks[], .packages.common.heavy_casks[], .packages.common.privileged_casks[], .packages.personal.standard_casks[], .packages.personal.heavy_casks[], .packages.personal.privileged_casks[]]'
  fi

  formulae="$(yq -o=json -I=0 "${formula_expression}" "${ROOT}/.chezmoidata/packages.yaml")"
  casks="$(yq -o=json -I=0 "${cask_expression}" "${ROOT}/.chezmoidata/packages.yaml")"
  jq -n --argjson formulae "${formulae}" --argjson casks "${casks}" \
    '{formulae: ($formulae | map({name: ., aliases: []})), casks: ($casks | map({token: ., artifacts: []}))}' \
    >"${output}"
}

assert_contains() {
  local file="$1"
  local expected="$2"
  grep -qF "${expected}" "${file}" || {
    echo "error: expected '${expected}' in ${file}" >&2
    return 1
  }
}

assert_not_contains() {
  local file="$1"
  local unexpected="$2"
  if grep -qF "${unexpected}" "${file}"; then
    echo "error: did not expect '${unexpected}' in ${file}" >&2
    return 1
  fi
}

export REAL_CHEZMOI MOCK_CALLS MOCK_INVENTORY MOCK_BUNDLE_INVENTORY MOCK_MAS_LIST MOCK_TAPS
export MOCK_CHEZMOI_VERIFY_STATUS=0
export PATH="${MOCK_BIN}:${PATH}"
export HOME="${WORK_DIR}/home"
export XDG_STATE_HOME="${MOCK_STATE}"
mkdir -p "${HOME}"
yq -r '.packages.taps[]' "${ROOT}/.chezmoidata/packages.yaml" >"${MOCK_TAPS}"

setup_mac="$(render_profile personal)"
default_setup_mac="$(render_profile default)"

echo "Testing invalid profile rejection..."
invalid_setup="$(render_profile personl)"
set +e
"${invalid_setup}" --help >"${WORK_DIR}/invalid.out" 2>&1
status=$?
set -e
[ "${status}" -eq 2 ]
assert_contains "${WORK_DIR}/invalid.out" "invalid profile 'personl'"

echo "Testing honest non-interactive deferral..."
set +e
"${setup_mac}" --phase privileged --non-interactive >"${WORK_DIR}/deferred.out" 2>&1
status=$?
set -e
[ "${status}" -eq 20 ]
assert_contains "${WORK_DIR}/deferred.out" "deferred: privileged"
assert_contains "${WORK_DIR}/deferred.out" "setup-mac partial"
assert_not_contains "${WORK_DIR}/deferred.out" "setup-mac complete"

echo "Testing targeted verification has no empty-array crash..."
set +e
"${default_setup_mac}" --phase verify --non-interactive >"${WORK_DIR}/targeted-verify.out" 2>&1
status=$?
set -e
[ "${status}" -eq 1 ]
assert_contains "${WORK_DIR}/targeted-verify.out" "Verification failures:"
assert_not_contains "${WORK_DIR}/targeted-verify.out" "unbound variable"

echo "Testing post-install state is required before completion..."
: >"${MOCK_CALLS}"
marker_dir="${MOCK_STATE}/dotfiles/setup-mac/personal"
mkdir -p "${marker_dir}"
shasum -a 256 "${setup_mac}" | awk '{print $1}' >"${marker_dir}/core.done"
set +e
"${setup_mac}" --phase core --non-interactive >"${WORK_DIR}/postcondition.out" 2>&1
status=$?
set -e
[ "${status}" -eq 1 ]
assert_contains "${WORK_DIR}/postcondition.out" "saved state drifted; scheduling repair"
assert_contains "${WORK_DIR}/postcondition.out" "post-install state verification failed"
assert_not_contains "${WORK_DIR}/postcondition.out" "setup-mac complete"
[ ! -f "${marker_dir}/core.done" ]

echo "Testing marker drift repair..."
printf '%s\n' '{"formulae":[],"casks":[]}' >"${MOCK_INVENTORY}"
make_inventory personal "${MOCK_BUNDLE_INVENTORY}"
"${setup_mac}" --phase core --non-interactive >"${WORK_DIR}/drift.out" 2>&1
assert_contains "${MOCK_CALLS}" "brew bundle"
assert_contains "${WORK_DIR}/drift.out" "setup-mac complete"
[ -f "${marker_dir}/core.done" ]

echo "Testing --update on a repeated preflight..."
: >"${MOCK_CALLS}"
: >"${MOCK_TAPS}"
"${setup_mac}" --phase preflight --update --non-interactive >"${WORK_DIR}/update.out" 2>&1
assert_contains "${MOCK_CALLS}" "brew update"
assert_contains "${MOCK_CALLS}" "brew tap getsentry/tools"

echo "Testing converged App Store phase avoids sudo..."
: >"${MOCK_CALLS}"
yq -r '.packages.common.mas[].id, .packages.personal.mas[].id' \
  "${ROOT}/.chezmoidata/packages.yaml" | awk '{print $1 " Installed"}' >"${MOCK_MAS_LIST}"
"${setup_mac}" --phase mas --force --non-interactive >"${WORK_DIR}/mas.out" 2>&1
assert_contains "${WORK_DIR}/mas.out" "administrator access is not needed"
assert_not_contains "${MOCK_CALLS}" "sudo"

echo "Testing full non-interactive run preserves deferred exit status..."
make_inventory default "${MOCK_INVENTORY}"
: >"${MOCK_BUNDLE_INVENTORY}"
yq -r '.packages.common.mas[].id' "${ROOT}/.chezmoidata/packages.yaml" \
  | awk '{print $1 " Installed"}' >"${MOCK_MAS_LIST}"
rm -rf "${MOCK_STATE}/dotfiles/setup-mac/default"
set +e
"${default_setup_mac}" --force --non-interactive >"${WORK_DIR}/full-deferred.out" 2>&1
status=$?
set -e
if [ "${status}" -ne 20 ]; then
  cat "${WORK_DIR}/full-deferred.out" >&2
  echo "error: expected full deferred run to exit 20, got ${status}" >&2
  exit 1
fi
assert_contains "${WORK_DIR}/full-deferred.out" "Verification pending deferred items"
assert_contains "${WORK_DIR}/full-deferred.out" "setup-mac partial"
assert_not_contains "${WORK_DIR}/full-deferred.out" "setup-mac incomplete"
assert_not_contains "${WORK_DIR}/full-deferred.out" "failed:"

echo "setup-mac state-machine tests passed."
