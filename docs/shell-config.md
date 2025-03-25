# Shell Configuration

This document details the shell configuration used in this dotfiles setup, focusing primarily on the Fish shell with notes about the ZSH configuration for reference.

## Fish Shell Configuration

Fish is the primary shell used in this setup. The configuration provides a fast, modern shell experience with powerful features.

### Key Features

- Intelligent path management
- Integration with development tools
- Credential handling via macOS keychain
- Performance optimizations

### Directory Structure

```
~/.config/fish/
├── config.fish         # Main configuration file
└── fish_plugins        # Plugins managed by Fisher
```

### Core Plugins

The following plugins are used to enhance the Fish shell experience:

```
jorgebucaran/fisher            # Package manager for Fish
patrickf1/fzf.fish             # Fuzzy finder integration
jethrokuan/z                   # Directory jumping (like zoxide)
ilancosman/tide@v6             # Modern prompt
franciscolourenco/done         # Notification when commands complete
jorgebucaran/autopair.fish     # Auto-pair brackets and quotes
nickeb96/puffer-fish           # Additional abbreviations
lewisacidic/fish-git-abbr      # Git abbreviations
halostatue/fish-chezmoi@v1     # Chezmoi integration
gazorby/fish-abbreviation-tips # Abbreviation usage tips
plttn/fish-eza                 # Eza (ls replacement) integration
```

### Environment Variables

Key environment variables set in the Fish configuration:

```fish
# XDG Base Directories
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache

# Node.js
set -gx NODE_EXTRA_CA_CERTS "$HOME/Library/Application Support/mkcert/rootCA.pem"
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -gx NODE_OPTIONS --no-deprecation

# Android SDK
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"
```

### Shell Aliases

Useful aliases configured in Fish:

```fish
alias y="yazi"                    # File manager
alias lg="lazygit"                # Git TUI
alias cat="bat"                   # Enhanced cat
alias edit-fish="nvim ~/.config/fish/config.fish"
alias reload-fish="source ~/.config/fish/config.fish"
alias cd="z"                      # Use zoxide for smart directory jumping
```

### Node.js with FNM

Fast Node Manager (FNM) is integrated to manage Node.js versions:

```fish
# FNM Environment for Node Version Management
if status --is-interactive
    # Ensure fnm sets up its Node environment on every new session.
    fnm env --use-on-cd --shell fish | source
end
```

### Vi Keybindings

Fish is configured with Vi key bindings for navigation:

```fish
fish_vi_key_bindings
```

## ZSH Configuration (Legacy/Reference)

While Fish is the primary shell, ZSH configuration is maintained for compatibility and reference.

### Directory Structure

```
~/.config/zsh/
├── .zshrc             # Main configuration
└── completions/       # Custom completions
```

### Zinit Plugin Management

ZSH uses Zinit for plugin management with lazy-loading for performance:

```zsh
# Load essential Zinit annexes
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust
```

### Key ZSH Plugins

```zsh
# Core utilities
zinit light zsh-users/zsh-autosuggestions       # Intelligent suggestions
zinit light zsh-users/zsh-history-substring-search  # History search
zinit light wfxr/forgit                         # Git workflow improvements
zinit light ael-code/zsh-colored-man-pages      # Colored manual pages
zinit light hcgraf/zsh-sudo                     # Easy sudo prefixing
```

### ZSH Performance Characteristics

- Optimized through lazy-loading
- Deferred loading of heavy components (fnm, 1Password)
- Compiled completion cache
- Typical startup time: 150-200ms (vs 800ms+ with Oh-My-Zsh)

### Migrating Between Shells

To switch between Fish and ZSH:

1. Fish to ZSH: Run `zsh` in your terminal
2. ZSH to Fish: Run `fish` in your terminal
3. Make Fish your default:
   ```bash
   echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
   chsh -s /opt/homebrew/bin/fish
   ```
4. Make ZSH your default:
   ```bash
   chsh -s /bin/zsh
   ```

## Common Shell Functions

Both shells include common functionality for:
- FZF integration for fuzzy finding
- Zoxide for smart directory jumping
- Lazy-loading of API keys from the macOS keychain
- Homebrew package management