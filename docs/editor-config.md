# Editor Configuration

This document details the shared configuration system for VS Code and Cursor editors.

## Overview

This dotfiles repository includes a sophisticated templating system that detects which editor is being configured and applies the appropriate settings while sharing common configurations between editors.

## How It Works

The magic happens through Chezmoi templates that detect the target editor and adjust settings accordingly:

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

## Directory Structure

```
.chezmoitemplates/
├── vscode-cursor-settings.tmpl     # Shared settings template
└── vscode-cursor-keybindings.tmpl  # Shared keybindings template

private_Library/
└── private_Application Support/
    ├── private_Cursor/User/      # Cursor specific settings
    └── private_Code/User/        # VS Code specific settings
```

## Key Feature Sets

### Shared Settings

Settings that are shared between both editors:

- Extension recommendations
- Font settings (JetBrains Mono Nerd Font)
- Terminal configuration
- Git integration settings
- Language-specific formatters
- Zen mode configuration
- Vim keybindings

### Editor-Specific Settings

Settings that are customized per editor:

- Color themes:
  - VS Code: GitHub Dark
  - Cursor: Palenight
- Terminal executable:
  - VS Code: System default
  - Cursor: Custom startup flags
- UI density and layout
- Editor-specific extensions

## Custom Extensions

Both editors automatically install recommended extensions, including:

- Vim emulation
- GitHub Copilot
- Better syntax highlighting
- Git integration
- Formatter configurations

## Terminal Integration

The terminal is configured with consistent settings across both editors:

- Shell integration enabled
- Custom font and sizes
- Integrated shell selection

## LazyVim Integration

The configuration includes a script to set up LazyVim for Neovim:

```bash
# Check if LazyVim is already installed
if [ ! -d "$HOME/.config/nvim/.nvim" ]; then
  echo "Setting up LazyVim..."

  # Clone lazy.nvim
  mkdir -p ~/.config/nvim/lazy
  git clone https://github.com/LazyVim/starter ~/.config/nvim

  # Initial Neovim run to install plugins
  nvim --headless "+Lazy! sync" +qa
fi
```

## Customization

To customize editor settings:

1. Edit the template file:
   ```bash
   chezmoi edit ~/.local/share/chezmoi/.chezmoitemplates/vscode-cursor-settings.tmpl
   ```

2. Apply changes:
   ```bash
   chezmoi apply
   ```

This will update settings for both VS Code and Cursor based on the template.

## Vim Mode Integration

Both editors are configured with Vim keybindings that follow LazyVim conventions for consistency. See [vim-mappings.md](../vim-mappings.md) for detailed key bindings.