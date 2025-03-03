A portable, templated dotfiles management system using [chezmoi](https://www.chezmoi.io/).

## Overview

This repository contains my dotfiles and configurations managed with chezmoi. It handles configuration for:

- VS Code and Cursor editor settings (shared configuration with editor-specific customizations)
- Terminal settings and shell configurations (ZSH with high-performance Zinit setup)
- Various development tools and preferences
- Git abbreviations using zsh-abbr for faster git workflows
- [Custom keyboard shortcuts](keyboard-shortcuts.md) for Vim-style navigation and productivity

## Features

- Shared settings between VS Code and Cursor with editor-specific customizations
- Templated configuration files with conditional logic
- Secure credential management via 1Password integration
- Machine-specific customizations
- Vim keybindings for editors
- Development environment configurations for multiple languages
- Optimized ZSH configuration with Zinit (faster than Oh-My-Zsh)
- Git abbreviations for common commands using zsh-abbr

## Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) (dotfile manager)
- [1Password CLI](https://1password.com/downloads/command-line/) (optional, for secrets)
- macOS (primary target platform)
- [Ghostty](https://github.com/mitchellh/ghostty) terminal (optional)
- Git
- Zsh with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager
- [zsh-abbr](https://github.com/olets/zsh-abbr) for command abbreviations

## Quick Start

### First-time Setup

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

### Updating Existing Installation

```bash
chezmoi update
```

## Editor Configuration

This repo includes a shared configuration system for VS Code and Cursor. The magic happens through:

- A shared template in `.chezmoitemplates/vscode-cursor-settings.tmpl`
- Target detection that identifies which editor is being configured
- Conditional settings based on the target editor

### How It Works

The template detects which editor it's configuring by checking the target path:

```go
{{- $app := "cursor" -}}
{{- if eq .chezmoi.targetFile (joinPath .chezmoi.homeDir "Library/Application Support/Code/User/settings.json") -}}
{{-   $app = "vscode" -}}
{{- end -}}
```

Settings are then customized based on the `$app` variable:

```json
"workbench.colorTheme": {{ if eq $app "vscode" }}"GitHub Dark"{{ else }}"Palenight (Mild Contrast)"{{ end }},
```

## ZSH Configuration

The shell configuration uses Zinit for fast, efficient plugin management:

### Key Features

- **Performance Optimization**:
  - Lazy-loading for slow-starting components (NVM, 1Password credentials)
  - Parallel plugin loading with Zinit
  - Standalone plugin installations without SVN dependencies

- **Advanced Plugin Setup**:
  ```zsh
  # Core utilities
  zinit light zsh-users/zsh-autosuggestions       # Intelligent suggestions
  zinit light zdharma-continuum/fast-syntax-highlighting  # Syntax highlighting
  zinit light wfxr/forgit                         # Git workflow improvements
  zinit light ael-code/zsh-colored-man-pages      # Colored manual pages
  zinit light hcgraf/zsh-sudo                     # Easy sudo prefixing
  ```

- **Custom Functions & Aliases**:
  ```zsh
  # Python/Node.js utilities
  alias venv="uv venv"                            # Fast virtual environments
  alias pipx="uv tool run"                        # Isolated tool execution

  # System utilities
  alias pwdc='pwd | pbcopy && echo "📋 Path copied"'  # Directory path copying
  function copyfile() { cat $1 | pbcopy }         # File content to clipboard
  ```

- **Intelligent Path Management**:
  ```zsh
  # Structured PATH configuration with deduplication
  path=(
    $HOME/.local/bin               # User scripts
    $PNPM_HOME                     # PNPM packages
    $BUN_INSTALL/bin               # Bun runtime
    /opt/homebrew/opt/ruby/bin     # Homebrew Ruby
    $ANDROID_HOME/platform-tools  # Android tools
    $path                          # Existing paths
  )
  typeset -U path  # Ensure unique entries
  ```

- **1Password Integration**:
  ```zsh
  # Lazy-loaded credential system
  function openai() {
    # Loads API key only when first used
    [[ "$OPENAI_API_KEY" == "needs_loading" ]] && \
      export OPENAI_API_KEY=$(get_openai_api_key)
    command openai "$@"
  }
  ```

- **Node.js Management**:
  ```zsh
  # Lazy-loaded NVM with automatic .nvmrc detection
  function nvm() {
    unfunction nvm                # Remove placeholder
    source "$NVM_DIR/nvm.sh"      # Load actual nvm
    nvm "$@"                      # Execute command
  }
  ```

- **Tool Integrations**:
  ```zsh
  # Zoxide - smarter directory navigation
  eval "$(zoxide init --cmd cd zsh)"

  # FZF fuzzy finder
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # Starship prompt
  eval "$(starship init zsh)"
  ```

### Performance Characteristics
- Startup time optimized through:
  - Deferred loading of heavy components (NVM, 1Password)
  - Standalone plugin installations
  - Compiled completion cache
- Typical startup time: 150-200ms (vs 800ms+ with OMZ)

### Unique Features
- Automatic Brewfile updates via `brew-wrap`
- Hybrid completion system (Zinit + traditional fpath)
- Security-focused credential handling
- Cross-platform Android development setup
- Python/Node.js version management coexistence

## Customization

### Personal Information

Edit `.chezmoi.toml.tmpl` to configure your personal information:

```toml
[data]
    email = "your.email@example.com"
    name = "Your Name"
```

### Machine-Specific Settings

chezmoi automatically detects the current machine and OS, allowing for conditional configuration.

## Directory Structure

```
.
├── .chezmoitemplates/           # Shared templates
│   └── vscode-cursor-settings.tmpl
├── private_Library/              # macOS Library folder (private)
│   └── private_Application Support/
│       ├── private_Curso#!/bin/bash

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

{{ end -}}r/User/  # Cursor settings
│       └── private_Code/User/    # VS Code settings
├── .zshrc                        # ZSH configuration with Zinit
└── .chezmoi.toml.tmpl           # chezmoi configuration
```

## Common Tasks

### Adding a New Dotfile

```bash
chezmoi add ~/.some_config_file
```

### Editing a Managed File

```bash
chezmoi edit ~/.some_config_file
```

### Updating After Changes

```bash
chezmoi apply
```

## Security

- Sensitive information is handled through 1Password integration
- Use `onepasswordRead` template function to access secrets


## Brewfile Management

This setup uses a Brewfile to manage Homebrew packages, ensuring consistency across installations. The Brewfile is located in the Chezmoi source directory at `dot_config/brewfile/Brewfile`.

### How It Works

- **Location**: The Brewfile is stored in `dot_config/brewfile/Brewfile` within the Chezmoi source directory.
- **Installation Script**: The `run_onchange_install-packages-homebrew.sh.tmpl` script installs packages from the Brewfile. It checks if Homebrew is installed, updates it, and then installs packages using the Brewfile.
- **Automatic Updates**: With `brew-wrap` enabled, the Brewfile is automatically updated when packages are installed or removed.

### Updating the Brewfile



With `brew-wrap` enabled, the Brewfile is automatically updated whenever you install or uninstall packages using `brew`, `mas`, `whalebrew`, or `code`. This means you don't need to manually run `brew bundle dump` to update the Brewfile.
