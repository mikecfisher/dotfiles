A portable, templated dotfiles management system using [chezmoi](https://www.chezmoi.io/).

## Overview

This repository contains my dotfiles and configurations managed with chezmoi. It handles configuration for:

- VS Code and Cursor editor settings (shared configuration with editor-specific customizations)
- Terminal settings and shell configurations (ZSH with high-performance Zinit setup)
- Various development tools and preferences

## Features

- Shared settings between VS Code and Cursor with editor-specific customizations
- Templated configuration files with conditional logic
- Secure credential management via 1Password integration
- Machine-specific customizations
- Vim keybindings for editors
- Development environment configurations for multiple languages
- Optimized ZSH configuration with Zinit (faster than Oh-My-Zsh)

## Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) (dotfile manager)
- [1Password CLI](https://1password.com/downloads/command-line/) (optional, for secrets)
- macOS (primary target platform)
- [Ghostty](https://github.com/mitchellh/ghostty) terminal (optional)
- Git
- Zsh with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager

## Quick Start

### First-time Setup

1. Install chezmoi:
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
   ```

2. Initialize with this repo:
   ```bash
   chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git
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

- **Performance-focused**: Loads plugins in parallel and on-demand
- **No SVN dependencies**: Uses standalone plugins with direct installation
- **Proper completion management**: Correctly configured completions for each tool
- **Modular organization**: Organized by categories (core, git, developer tools, etc.)

### Completions Management

Zinit offers several ways to handle completions:

1. **Automatic management**: The `completions` ice modifier
2. **Manual installation**: Via `zinit ice as"completion"` for specific completion files
3. **Direct installation**: Through custom completion directories in `fpath`

Example:
```zsh
# Using raw GitHub URLs for completions
zinit ice as"completion"
zinit snippet https://raw.githubusercontent.com/Homebrew/brew/master/completions/zsh/_brew

# 1Password completion with direct evaluation
eval "$(op completion zsh)"
```

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
│       ├── private_Cursor/User/  # Cursor settings
│       └── private_Code/User/    # VS Code settings
├── .zshrc                        # ZSH configuration with Zinit
└── .chezmoi.toml.tmpl           # chezmoi configuration
```

## Common Tasks

### Adding a New Dotfile

```bash
chezmoi add ~/.some_config_file
```

### Making a File a Template

```bash
chezmoi add --template ~/.some_config_file
```

### Editing a Managed File

```bash
chezmoi edit ~/.some_config_file
```

### Updating After Changes

```bash
chezmoi apply
```

### Adding a New ZSH Completion

```bash
# Generate completion file
your_command completion zsh > ~/.zsh/completions/_your_command

# Or add via Zinit
zinit ice as"completion"
zinit snippet https://raw.githubusercontent.com/author/repo/master/completions/_your_command
```

## Troubleshooting

If editor settings aren't applying correctly:
1. Check the target paths with `chezmoi managed`
2. Verify template syntax with `chezmoi execute-template`
3. Force application with `chezmoi apply --verbose`

For ZSH completion issues:
1. Run `compinit -d` to regenerate the completion dump file
2. Check completion paths with `echo $fpath`
3. Verify URL paths for snippet-based completions

## Security

- Sensitive information is handled through 1Password integration
- Use `onepasswordRead` template function to access secrets

## License

MIT (or specify your preferred license)

---

## About This Setup

This dotfiles repository is designed to maintain consistent settings across multiple machines, with special attention to sharing configurations between VS Code and Cursor editors. The power of chezmoi's templating allows for both shared and editor-specific settings while keeping everything in sync.

The ZSH configuration prioritizes performance and maintainability, using Zinit's advanced features to load plugins efficiently and manage completions properly.

For questions or issues, please open an issue on the repository.
