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

## Machine Types

When initializing chezmoi, you'll be prompted to choose between two machine types:

- **Default**: Includes common development tools and applications
- **Personal**: Includes everything in the default configuration plus additional tools for music production and personal use

The prompt will look like this:
```
? Machine type (personal/default) default
```

Select the appropriate type for your machine.

## Post-Installation

After installation, you may want to:

1. Check that all dependencies were installed correctly
2. Set up the fish shell as your default shell:
   ```bash
   echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
   chsh -s /opt/homebrew/bin/fish
   ```

3. Set up 1Password CLI integration (required for credential management)