# Installation Guide

This guide walks you through installing and setting up the dotfiles using chezmoi.

## Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) (dotfile manager)
- [1Password CLI](https://1password.com/downloads/command-line/) (optional, for secrets)
- macOS (primary target platform)
- Git

## One-Line Setup (Recommended)

This will install everything you need in one command:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/mikecfisher/dotfiles.git
```

## Manual Setup

If you prefer a step-by-step approach:

1. Install chezmoi:
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
   ```

2. Initialize with this repo:
   ```bash
   chezmoi init https://github.com/mikecfisher/dotfiles.git
   ```

3. Preview changes:
   ```bash
   chezmoi diff
   ```

4. Apply the dotfiles:
   ```bash
   chezmoi apply
   ```

## Updating Existing Installation

To update your dotfiles after changes have been made to the repository:

```bash
chezmoi update
```

## Init Prompts

When initializing chezmoi, you'll be prompted for machine-specific data:

- **Machine type**: `default` or `personal`
  - `default`: common development tools and applications
  - `personal`: default plus music/personal packages
- **Work machine**: enables work-specific editor/MCP configuration
- **Use 1Password secrets**: only say yes after `op` is installed/signed in, or expect blank secret values until you re-apply
- **Git name/email**: rendered into `~/.gitconfig`

## Fresh Mac Notes

The first apply bootstraps Homebrew before package installation and supports both Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`) prefixes.

Mac App Store apps are skipped unless you're signed in. After signing in, re-run:

```bash
chezmoi apply
```

If 1Password secrets were skipped on first apply, install/sign in to 1Password CLI and re-run:

```bash
op signin
chezmoi apply --init
```

## Post-Installation

After installation, you may want to:

1. Check that all dependencies were installed correctly:
   ```bash
   ~/bin/my-scripts/audit-chezmoi.sh ~/.local/share/chezmoi
   ```
2. Set up the fish shell as your default shell:
   ```bash
   BREW_PREFIX="$(brew --prefix)"
   echo "$BREW_PREFIX/bin/fish" | sudo tee -a /etc/shells
   chsh -s "$BREW_PREFIX/bin/fish"
   ```

3. Set up/sign in to 1Password CLI integration if you use secret-backed templates