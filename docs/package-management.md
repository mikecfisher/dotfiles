# Package Management

This document explains how Homebrew packages and applications are managed in this dotfiles setup.

## Overview

This dotfiles repository uses a simplified package management approach based on Homebrew, with automatic Brewfile updates. The system supports two machine types:

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

## Brewfile Management

The setup uses a Brewfile to manage Homebrew packages, ensuring consistency across installations.

### How It Works

1. **Location**: The Brewfile is stored in `dot_config/brewfile/Brewfile` in the Chezmoi source directory.

2. **Installation Script**: When you apply the dotfiles, the `run_onchange_install-packages-homebrew.sh.tmpl` script installs packages from the Brewfile:

   ```bash
   # Only run on macOS
   {{ if eq .chezmoi.os "darwin" -}}

   # Install Homebrew if not installed
   if ! command -v brew &> /dev/null; then
     echo "Installing Homebrew..."
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   fi

   # Update Homebrew
   echo "Updating Homebrew..."
   brew update

   # Install from Brewfile in Chezmoi config
   echo "Installing packages from Brewfile..."
   brew bundle --no-lock --file="{{ .chezmoi.sourceDir }}/dot_config/brewfile/Brewfile"

   {{ end -}}
   ```

3. **Automatic Updates**: With `brew-wrap` enabled, the Brewfile is automatically updated whenever you:
   - Install packages with `brew install`
   - Uninstall packages with `brew uninstall`
   - Install apps with `brew install --cask`
   - Install Mac App Store apps with `mas install`

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