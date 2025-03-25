# Dotfiles

A portable, templated dotfiles management system using [chezmoi](https://www.chezmoi.io/).

## Overview

This repository contains my dotfiles and configurations managed with chezmoi. It handles configuration for:

- VS Code and Cursor editor settings (shared configuration with editor-specific customizations)
- Terminal settings and Fish shell configuration
- Various development tools and preferences
- Git integrations and workflow enhancements
- Vim-style navigation and productivity

## Documentation

📚 **Complete documentation is available in the [docs/](./docs) directory**

- [Installation Guide](./docs/installation.md)
- [Shell Configuration](./docs/shell-config.md)
- [Editor Configuration](./docs/editor-config.md)
- [Vim Keybindings](./vim-mappings.md)
- [Keyboard Shortcuts](./keyboard-shortcuts.md)
- [Package Management](./docs/package-management.md)
- [Chezmoi Usage](./docs/chezmoi-usage.md)
- [Security & Credentials](./docs/security.md)

## Quick Start

### One-Line Setup

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/mikecfisher/dotfiles.git
```

### Update Existing Installation

```bash
chezmoi update
```

## Key Features

- Fish shell configuration with intelligent plugins
- Shared settings between VS Code and Cursor editors
- Templated configuration files with conditional logic
- Secure credential management via 1Password integration
- Machine-specific customizations based on needs
- Comprehensive Vim keybindings for editors
- Automatic Homebrew package management

## Directory Structure

```
.
├── .chezmoitemplates/           # Shared templates
├── dot_config/                  # Configuration files (~/.config)
│   ├── private_fish/            # Fish shell configuration
│   └── brewfile/                # Homebrew Brewfile
├── .chezmoidata/               # Data used in templates
├── docs/                       # Documentation
└── run_scripts/                # Scripts run on apply
```

## License

MIT