# Chezmoi Usage

This document provides guidance on using chezmoi with this dotfiles repository.

## Overview

[Chezmoi](https://www.chezmoi.io/) is a dotfile manager that helps you manage configuration files across multiple machines in a secure, adaptable way.

## Repository Structure

```
.
├── .chezmoitemplates/           # Shared templates
│   ├── vscode-cursor-settings.tmpl
│   └── vscode-cursor-keybindings.tmpl
├── private_Library/              # macOS Library folder (private)
│   └── private_Application Support/
│       ├── private_Cursor/User/  # Cursor settings
│       └── private_Code/User/    # VS Code settings
├── dot_config/                  # Configuration files (~/.config)
│   ├── private_fish/            # Fish shell configuration
│   └── brewfile/                # Homebrew Brewfile
├── .chezmoidata/               # Data used in templates
│   └── packages.yaml           # Package definitions
├── .chezmoi.toml.tmpl         # Chezmoi configuration template
└── .chezmoiexternal.toml      # External resource definitions
```

## Common Commands

### Setup and Installation

```bash
# Initialize with repository
chezmoi init https://github.com/mikecfisher/dotfiles.git

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply
```

### Managing Files

```bash
# Add a file to chezmoi
chezmoi add ~/.some_config_file

# Edit a managed file
chezmoi edit ~/.some_config_file

# Apply changes after editing
chezmoi apply

# Update from repository
chezmoi update
```

### Navigation and Inspection

```bash
# Navigate to source directory
chezmoi cd

# Show managed files
chezmoi managed

# Show unmanaged files
chezmoi unmanaged

# Show pending changes
chezmoi diff
```

## File Types

Chezmoi uses special prefixes to determine how files are treated:

| Prefix | Example | Description |
|--------|---------|-------------|
| `dot_` | `dot_gitconfig` | Regular file that will be installed as a dotfile (e.g., `.gitconfig`) |
| `private_` | `private_ssh` | File with permissions 0600 (user read/write only) |
| `executable_` | `executable_script.sh` | File with execute permission |
| `symlink_` | `symlink_dot_zshrc.tmpl` | Symlink to another file |
| `run_` | `run_once_install-packages.sh` | Script run by chezmoi when applying configuration |

## Templates

Chezmoi templates use Go's template syntax:

```
{{- $machineType := promptStringOnce . "machine_type" "Machine type (personal/default)" "default" -}}

[data]
    machine_type = "{{ $machineType }}"
```

### Common Template Functions

- `{{ .chezmoi.os }}` - Operating system (e.g., "darwin", "linux")
- `{{ .chezmoi.hostname }}` - Machine hostname
- `{{ .chezmoi.homeDir }}` - User's home directory
- `{{ onepasswordRead "op://vault/item/field" }}` - Read from 1Password

## Working with Templates

1. Create or edit a template file:
   ```bash
   chezmoi edit --template ~/.zshrc
   ```

2. Test a template:
   ```bash
   chezmoi execute-template < ~/.local/share/chezmoi/.chezmoitemplates/template-name.tmpl
   ```

3. Apply template changes:
   ```bash
   chezmoi apply
   ```

## External Resources

Chezmoi can manage external resources like git repositories:

```toml
# .chezmoiexternal.toml
[".config/tmux/plugins/catppuccin"]
type = "git-repo"
url = "https://github.com/catppuccin/tmux.git"
refreshPeriod = "168h"
[".config/tmux/plugins/catppuccin".clone]
args = ["--branch", "v2.1.2", "--depth", "1"]
```

## Machine-Specific Configuration

This repository uses machine types to customize configuration:

```toml
# .chezmoi.toml.tmpl
{{- $machineType := promptStringOnce . "machine_type" "Machine type (personal/default)" "default" -}}

[data]
    machine_type = "{{ $machineType }}"
```

To change machine type:
```bash
chezmoi init --data=false
```

## Git Integration

Chezmoi automatically commits changes to the source files:

```toml
# .chezmoi.toml.tmpl
[git]
 autoCommit = true
 commitMessageTemplateFile = ".commit_message.tmpl"
```

## Best Practices

1. **Review changes**: Always use `chezmoi diff` before applying changes
2. **Keep secrets secure**: Use 1Password integration for sensitive data
3. **Regularly update**: Run `chezmoi update` to keep dotfiles in sync
4. **Use templates**: Prefer templates over multiple file versions
5. **Test changes**: Before applying widely, test changes on one machine

## Troubleshooting

If you encounter issues:

1. Run with verbose logging:
   ```bash
   chezmoi -v apply
   ```

2. Check for syntax errors in templates:
   ```bash
   chezmoi execute-template < path/to/template
   ```

3. Reset chezmoi state if necessary:
   ```bash
   chezmoi purge
   chezmoi init https://github.com/mikecfisher/dotfiles.git
   ```