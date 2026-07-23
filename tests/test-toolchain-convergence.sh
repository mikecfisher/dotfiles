#!/bin/bash
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

MOCK_BIN="${WORK_DIR}/bin"
CALLS="${WORK_DIR}/calls"
CONFIG="${WORK_DIR}/default.toml"
UV_SCRIPT="${WORK_DIR}/setup-uv.sh"
BUN_SCRIPT="${WORK_DIR}/setup-bun.sh"
EXPECTED_UV="$(yq -r '.toolchains.uv.version' "${ROOT}/.chezmoidata/toolchains.yaml")"
EXPECTED_BUN="$(yq -r '.toolchains.bun.version' "${ROOT}/.chezmoidata/toolchains.yaml")"

mkdir -p "${MOCK_BIN}" "${WORK_DIR}/home/.local/bin" "${WORK_DIR}/home/.bun/bin"
: >"${CALLS}"

printf '[data]\nmachine_type = "default"\nis_work_machine = false\nuse_1password = false\ngit_name = "Test"\ngit_email = "test@example.com"\n' >"${CONFIG}"
chezmoi execute-template --source "${ROOT}" --config "${CONFIG}" \
  <"${ROOT}/run_scripts/run_onchange_after_25_setup-uv.sh.tmpl" >"${UV_SCRIPT}"
chezmoi execute-template --source "${ROOT}" --config "${CONFIG}" \
  <"${ROOT}/run_scripts/run_onchange_after_26_setup-bun.sh.tmpl" >"${BUN_SCRIPT}"
chmod +x "${UV_SCRIPT}" "${BUN_SCRIPT}"

cat >"${MOCK_BIN}/curl" <<'EOF'
#!/bin/bash
set -eu
printf 'curl %s\n' "$*" >>"${CALLS}"
case "$*" in
  *astral.sh/uv/*)
    cat <<'INSTALL'
#!/bin/sh
set -eu
mkdir -p "${UV_INSTALL_DIR}"
printf '#!/bin/sh\necho "uv %s"\n' "${EXPECTED_UV}" >"${UV_INSTALL_DIR}/uv"
printf '#!/bin/sh\necho "uvx %s"\n' "${EXPECTED_UV}" >"${UV_INSTALL_DIR}/uvx"
chmod +x "${UV_INSTALL_DIR}/uv" "${UV_INSTALL_DIR}/uvx"
INSTALL
    ;;
  *bun.sh/install*)
    cat <<'INSTALL'
#!/bin/bash
set -eu
version="${1#bun-v}"
mkdir -p "${BUN_INSTALL}/bin"
printf '#!/bin/sh\necho "%s"\n' "${version}" >"${BUN_INSTALL}/bin/bun"
chmod +x "${BUN_INSTALL}/bin/bun"
INSTALL
    ;;
  *) exit 1 ;;
esac
EOF
chmod +x "${MOCK_BIN}/curl"

cat >"${WORK_DIR}/home/.local/bin/uv" <<'EOF'
#!/bin/sh
echo 'uv 0.0.1'
EOF
cat >"${WORK_DIR}/home/.local/bin/uvx" <<'EOF'
#!/bin/sh
echo 'uvx 0.0.1'
EOF
cat >"${WORK_DIR}/home/.bun/bin/bun" <<'EOF'
#!/bin/sh
echo '0.0.1'
EOF
chmod +x "${WORK_DIR}/home/.local/bin/uv" "${WORK_DIR}/home/.local/bin/uvx" \
  "${WORK_DIR}/home/.bun/bin/bun"

export CALLS EXPECTED_UV EXPECTED_BUN
export HOME="${WORK_DIR}/home"
export XDG_BIN_HOME="${HOME}/.local/bin"
export BUN_INSTALL="${HOME}/.bun"
export PATH="${MOCK_BIN}:${XDG_BIN_HOME}:${BUN_INSTALL}/bin:/usr/bin:/bin:/usr/sbin:/sbin"

echo "Testing mismatched uv and Bun versions are replaced..."
"${UV_SCRIPT}" >/dev/null
"${BUN_SCRIPT}" >/dev/null
[ "$(uv --version | awk '{print $2}')" = "${EXPECTED_UV}" ]
[ "$(bun --version)" = "${EXPECTED_BUN}" ]
grep -qF 'astral.sh/uv/' "${CALLS}"
grep -qF 'bun.sh/install' "${CALLS}"

echo "Testing matching uv and Bun versions avoid downloads..."
: >"${CALLS}"
"${UV_SCRIPT}" >/dev/null
"${BUN_SCRIPT}" >/dev/null
[ ! -s "${CALLS}" ]

echo "Toolchain convergence tests passed."
