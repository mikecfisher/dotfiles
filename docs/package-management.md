# Package Management

This document explains how Homebrew packages and applications are managed in this dotfiles setup.

## Overview

This dotfiles repository uses a simplified package management approach based on Homebrew, with automatic Brewfile updates. `uv` is the exception: it is installed with Astral's standalone installer so `uv self update` works and Python/tool shims live in `~/.local/bin`. The system supports two machine types:

- **Default**: Common development tools and applications suitable for any machine
- **Personal**: Includes everything in the default configuration plus additional tools for personal use

## Directory Structure

```
dot_config/
└── brewfile/
    └── Brewfile         # Managed Homebrew packages

.chezmoidata/
└── packages.yaml        # Package definitions
```

## Homebrew manifest management

The setup uses `.chezmoidata/packages.yaml` as the source of truth. Chezmoi generates temporary Brewfiles during apply; there is no checked-in Brewfile.

### How It Works

1. **Location**: Package intent is stored in `.chezmoidata/packages.yaml`.

2. **Installation Script**: `run_onchange_before_10_install-packages-homebrew.sh.tmpl` bootstraps Homebrew and the bootstrap set. `run_onchange_after_90_install-packages-homebrew.sh.tmpl` installs the common and machine-specific sets from generated temporary Brewfiles.

   ```bash
   chezmoi apply
   ```

3. **Automatic Updates**: With `brew-wrap` enabled, package changes can be synchronized back into `.chezmoidata/packages.yaml` whenever you:
   - Install packages with `brew install`
   - Uninstall packages with `brew uninstall`
   - Install apps with `brew install --cask`
   - Install Mac App Store apps with `mas install`

The bootstrap/common overlap is intentional: bootstrap packages are needed early so the shell and editor can start, while the common list is the complete desired set. Homebrew deduplicates them.

### Package Definitions

Packages are defined in `.chezmoidata/packages.yaml`:

```yaml
packages:
  taps:
    - "homebrew/bundle"
    - "homebrew/cask"
    # ... other taps
  common:
    brews:
      # Development tools
      - "chezmoi"
      - "fish"
      - "fnm"
      - "git"
      - "gh"
      # ... more packages
    casks:
      # Applications
      - "visual-studio-code"
      - "cursor"
      # ... more applications
```

## Machine-Specific Packages

When initializing the repository, you're prompted to choose a machine type:

```toml
# .chezmoi.toml.tmpl
{{- $machineType := promptStringOnce . "machine_type" "Machine type (personal/default)" "default" -}}

[data]
    machine_type = "{{ $machineType }}"
```

The package installation script uses this information to install the appropriate set of packages.

## Adding New Packages

To add new packages:

1. **Automatic Method**:
   - Simply use `brew install <package>` and the Brewfile will be updated automatically via brew-wrap.

2. **Manual Method**:
   - Edit `.chezmoidata/packages.yaml` to add the package
   - Run `chezmoi apply` to apply the changes

## Updating Packages

To update all installed packages:

```bash
brew update && brew upgrade
```

The Brewfile will be automatically updated with any changes.

## Cleaning Up

To remove packages that are no longer in your Brewfile:

```bash
brew bundle cleanup --force
```

## Integration with Shell

Both fish and zsh configurations include a brew-wrap integration that automatically updates the Brewfile when packages are installed or removed. In fish:

```fish
# Brew Wrapper
if test -f (brew --prefix)/etc/brew-wrap.fish
    source (brew --prefix)/etc/brew-wrap.fish

    function _post_brewfile_update
        echo "Brewfile was updated!"
        ~/.local/bin/my-scripts/update-packages-yaml.ts
    end
end
```

And in zsh:

```zsh
# Brew Wrapper for auto-updating Brewfile
if [ -f "$(brew --prefix)/etc/brew-wrap.sh" ]; then
  source "$(brew --prefix)/etc/brew-wrap.sh"

  # Call update script after Brewfile changes
  _post_brewfile_update() {
    echo "Updating packages.yaml..."
    ~/.local/bin/my-scripts/update-packages-yaml.ts
  }
fi
```
