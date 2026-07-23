#!/bin/bash

# Shared non-interactive environment setup for chezmoi provisioning scripts.
# Callers retain control of strict-mode settings and error handling.

dotfiles_load_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  elif [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

dotfiles_add_fnm_to_path() {
  local candidate
  for candidate in "${HOME}/.local/share/fnm" "${HOME}/.fnm"; do
    if [ -x "${candidate}/fnm" ]; then
      export PATH="${candidate}:${PATH}"
    fi
  done
}

dotfiles_load_node() {
  local version="${1:-22}"
  dotfiles_load_homebrew
  dotfiles_add_fnm_to_path

  if ! command -v fnm >/dev/null 2>&1; then
    echo "error: fnm is required to load Node.js ${version}" >&2
    return 1
  fi

  fnm install "${version}" --corepack-enabled
  eval "$(fnm env --shell bash)"
  fnm use "${version}"
  hash -r

  command -v node >/dev/null 2>&1 || {
    echo "error: Node.js ${version} is unavailable after fnm setup" >&2
    return 1
  }
}
