#!/bin/sh
set -eu

# Best-effort bootstrap for templates that use chezmoi's onepasswordRead.
# If Homebrew is not available yet, the guarded templates will render empty
# secrets and the normal package install will install 1Password CLI later.
command -v op >/dev/null 2>&1 && exit 0

if [ "$(uname -s)" != "Darwin" ]; then
  echo "1Password CLI bootstrap skipped: unsupported OS $(uname -s)." >&2
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  :
elif [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "1Password CLI bootstrap skipped: Homebrew is not installed yet." >&2
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  echo "Installing 1Password CLI for chezmoi secret templates..."
  brew install --cask 1password-cli || true
fi
