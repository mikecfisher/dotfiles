#!/bin/bash
set -euo pipefail

if [ -n "${DOTFILES_SOURCE_DIR:-}" ]; then
  ROOT="${DOTFILES_SOURCE_DIR}"
elif source_path="$(chezmoi source-path 2>/dev/null)" && [ -d "${source_path}/.git" ]; then
  ROOT="${source_path}"
else
  ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
fi
PACKAGES="${ROOT}/.chezmoidata/packages.yaml"
TOOLCHAINS="${ROOT}/.chezmoidata/toolchains.yaml"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

for command_name in chezmoi yq; do
  command -v "${command_name}" >/dev/null 2>&1 || {
    echo "error: ${command_name} is required" >&2
    exit 1
  }
done

echo "Validating YAML..."
yq eval '.' "${PACKAGES}" >/dev/null
yq eval '.' "${TOOLCHAINS}" >/dev/null

assert_unique() {
  local label="$1"
  local expression="$2"
  local duplicates
  duplicates="$(yq -r "${expression}" "${PACKAGES}" | sort | uniq -d)"
  if [ -n "${duplicates}" ]; then
    echo "error: duplicate ${label}:" >&2
    printf '%s\n' "${duplicates}" >&2
    return 1
  fi
}

assert_unique "formula entries" \
  '.packages.common.brews[], .packages.personal.brews[]'
assert_unique "Homebrew taps" '.packages.taps[]'
assert_unique "cask entries" \
  '.packages.common.standard_casks[], .packages.common.heavy_casks[], .packages.common.privileged_casks[], .packages.personal.standard_casks[], .packages.personal.heavy_casks[], .packages.personal.privileged_casks[]'
assert_unique "Mac App Store IDs" \
  '.packages.common.mas[].id, .packages.personal.mas[].id'
assert_unique "automated vendor IDs" \
  '.packages.personal.vendor.automated[].id'

echo "Rendering shell templates for default and personal profiles..."
for profile in default personal; do
  config="${WORK_DIR}/${profile}.toml"
  printf '[data]\nmachine_type = "%s"\nis_work_machine = false\nuse_1password = false\ngit_name = "Validation"\ngit_email = "validation@example.com"\n' \
    "${profile}" >"${config}"

  while IFS= read -r template; do
    relative="${template#${ROOT}/}"
    rendered="${WORK_DIR}/${profile}-$(printf '%s' "${relative}" | tr '/' '-')"
    chezmoi execute-template --source "${ROOT}" --config "${config}" <"${template}" >"${rendered}"
    bash -n "${rendered}"
    if command -v shellcheck >/dev/null 2>&1; then
      shellcheck --severity=error --external-sources "${rendered}"
    fi
  done < <(find "${ROOT}/run_scripts" -type f -name '*.sh.tmpl' -print | sort)

  rendered="${WORK_DIR}/${profile}-setup-mac"
  chezmoi execute-template --source "${ROOT}" --config "${config}" \
    <"${ROOT}/dot_local/bin/executable_setup-mac.tmpl" >"${rendered}"
  bash -n "${rendered}"
  if command -v shellcheck >/dev/null 2>&1; then
    shellcheck --severity=error --external-sources "${rendered}"
  fi
done

if rg -n 'mas account|brew-wrap|\.config/brewfile/Brewfile' "${ROOT}/docs" >/dev/null; then
  echo "error: documentation still references removed package-management behavior" >&2
  rg -n 'mas account|brew-wrap|\.config/brewfile/Brewfile' "${ROOT}/docs" >&2
  exit 1
fi

if [ "${VALIDATE_PACKAGES:-0}" = "1" ]; then
  [ "$(uname -s)" = "Darwin" ] || {
    echo "error: package resolution validation requires macOS" >&2
    exit 1
  }
  echo "Converging configured Homebrew taps for package resolution..."
  taps=()
  while IFS= read -r item; do taps+=("${item}"); done \
    < <(yq -r '.packages.taps[]' "${PACKAGES}")
  for item in "${taps[@]}"; do brew tap "${item}" >/dev/null; done

  echo "Resolving configured Homebrew packages..."
  formulae=()
  while IFS= read -r item; do formulae+=("${item}"); done \
    < <(yq -r '.packages.common.brews[], .packages.personal.brews[]' "${PACKAGES}")
  casks=()
  while IFS= read -r item; do casks+=("${item}"); done \
    < <(yq -r '.packages.common.standard_casks[], .packages.common.heavy_casks[], .packages.common.privileged_casks[], .packages.personal.standard_casks[], .packages.personal.heavy_casks[], .packages.personal.privileged_casks[]' "${PACKAGES}")
  brew info --formula "${formulae[@]}" >/dev/null
  brew info --cask "${casks[@]}" >/dev/null
fi

git -C "${ROOT}" diff --check
echo "Dotfiles validation passed."
