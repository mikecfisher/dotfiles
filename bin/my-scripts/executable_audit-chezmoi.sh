#!/bin/bash
set -euo pipefail

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "error: chezmoi is required" >&2
  exit 1
fi

CHEZMOI_BIN="$(command -v chezmoi)"
SOURCE_DIR="${1:-$(pwd)}"

if [ ! -f "${SOURCE_DIR}/.chezmoi.toml.tmpl" ]; then
  echo "error: ${SOURCE_DIR} does not look like this chezmoi source directory" >&2
  exit 1
fi

TMPDIR="$(mktemp -d)"
if [ "${KEEP_AUDIT_LOGS:-0}" = "1" ]; then
  echo "Keeping audit logs in ${TMPDIR}"
else
  trap 'rm -rf "${TMPDIR}"' EXIT
fi
DEST_DIR="${TMPDIR}/home"
CONFIG_FILE="${TMPDIR}/chezmoi.toml"
mkdir -p "${DEST_DIR}"

cat >"${CONFIG_FILE}" <<EOF
[data.vscode]
app = "vscode"

[data.cursor]
app = "cursor"

[data]
machine_type = "default"
is_work_machine = false
use_1password = false
git_name = "Audit User"
git_email = "audit@example.invalid"

[git]
autoCommit = false
commitMessageTemplateFile = ".commit_message.tmpl"
EOF

echo "==> chezmoi doctor"
"${CHEZMOI_BIN}" doctor --source "${SOURCE_DIR}"

echo "==> dry-run apply into temp home"
"${CHEZMOI_BIN}" apply \
  --source "${SOURCE_DIR}" \
  --destination "${DEST_DIR}" \
  --config "${CONFIG_FILE}" \
  --dry-run \
  --no-tty \
  --no-pager \
  --keep-going \
  --refresh-externals=never \
  >/"${TMPDIR}/dry-run.log"

echo "    dry-run completed"

echo "==> dry-run apply with clean PATH (catches unguarded op/brew lookups)"
env PATH="/usr/bin:/bin:/usr/sbin:/sbin" "${CHEZMOI_BIN}" apply \
  --source "${SOURCE_DIR}" \
  --destination "${DEST_DIR}" \
  --config "${CONFIG_FILE}" \
  --dry-run \
  --no-tty \
  --no-pager \
  --keep-going \
  --refresh-externals=never \
  >/"${TMPDIR}/clean-path-dry-run.log"

echo "    clean PATH dry-run completed"

if command -v rg >/dev/null 2>&1; then
  echo "==> scan for hardcoded local home paths"
  local_home_pattern="$(printf '/Users/%s' mike)"
  if rg --hidden -n "${local_home_pattern}" "${SOURCE_DIR}" --glob '!docs/**' --glob '!.git/**'; then
    echo "warning: hardcoded ${local_home_pattern} paths remain" >&2
    exit 1
  fi
fi

echo "chezmoi audit passed"
