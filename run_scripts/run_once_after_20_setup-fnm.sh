#!/bin/bash
set -euo pipefail

load_homebrew_shellenv() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  elif [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

add_fnm_to_path() {
  local candidate
  for candidate in \
    "${HOME}/.local/share/fnm" \
    "${HOME}/.fnm"; do
    if [ -x "${candidate}/fnm" ]; then
      export PATH="${candidate}:${PATH}"
    fi
  done
}

load_homebrew_shellenv
add_fnm_to_path

if ! command -v fnm >/dev/null 2>&1; then
  echo "Installing fnm..."
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
  add_fnm_to_path
fi

if ! command -v fnm >/dev/null 2>&1; then
  echo "error: fnm is still not available after installation" >&2
  exit 1
fi

echo "Installing Node.js 22 with fnm..."
fnm install 22 --corepack-enabled

# Make the newly-installed Node available in this non-interactive script.
eval "$(fnm env --shell bash)"
fnm use 22
hash -r

if ! command -v node >/dev/null 2>&1; then
  echo "error: node is not available after fnm setup" >&2
  exit 1
fi

echo "Enabling Corepack and activating pnpm..."
corepack enable
corepack prepare pnpm@latest --activate
hash -r

if ! command -v pnpm >/dev/null 2>&1; then
  echo "error: pnpm is not available after Corepack setup" >&2
  exit 1
fi

# Uninstall Homebrew pnpm to avoid conflicts with Corepack-managed pnpm.
if command -v brew >/dev/null 2>&1 && brew list --formula pnpm >/dev/null 2>&1; then
  echo "Uninstalling Homebrew pnpm to avoid Corepack conflicts..."
  brew uninstall pnpm
fi

echo "Installing global Node packages with pnpm..."
pnpm add -g \
  @anthropic-ai/claude-code \
  cursor-tools \
  playwright \
  turbo \
  typescript-language-server \
  typescript \
  yarn
