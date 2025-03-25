# ============================================================================
# Homebrew & XDG Directories
# ============================================================================
if test -d /opt/homebrew
    # Homebrew environment (sets PATH, MANPATH, etc.)
    eval (/opt/homebrew/bin/brew shellenv)
    set -gx PATH /opt/homebrew/bin $PATH
    set -gx MANPATH /opt/homebrew/share/man $MANPATH
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end
# <D-s>
# XDG Base Directories
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
#
# XDG Base Directories
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache

# ============================================================================
# DEVELOPMENT ENVIRONMENT VARIABLES
# ============================================================================
# Node.js SSL certificates
set -gx NODE_EXTRA_CA_CERTS "$HOME/Library/Application Support/mkcert/rootCA.pem"

# Node.js package managers & options
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -gx NODE_OPTIONS --no-deprecation

# Android SDK
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"

# Ruby compilation flags
set -gx LDFLAGS -L/opt/homebrew/opt/ruby/lib
set -gx CPPFLAGS -I/opt/homebrew/opt/ruby/include

# API Keys (loaded at login; be cautious with sensitive info)
set -gx ANTHROPIC_API_KEY (timeout 2 security find-generic-password -a $USER -s "anthropic_api_key" -w 2>/dev/null)
#set -gx HASS_TOKEN (timeout 2 security find-generic-password -a $USER -s "homeassistant_token_api_key" -w 2>/dev/null)
#set -gx OPENAI_API_KEY (timeout 2 security find-generic-password -a $USER -s "openai_api_key" -w 2>/dev/null)
#set -gx HASS_SERVER "http://homeassistant.local:8123"

# ============================================================================
# FNM Environment for Node Version Management
# ============================================================================
if status --is-interactive
    # Ensure fnm sets up its Node environment on every new session.
    fnm env --use-on-cd --shell fish | source
end

#============================================================================
# Interactive Shell Settings
# ============================================================================
if status is-interactive
    # Initialize zoxide
    zoxide init fish | source

    # Aliases
    alias cd="z" # use zoxide for directory switching
    alias y="yazi"
    alias lg="lazygit"
    alias cat="bat"
    alias edit-fish="nvim ~/.config/fish/config.fish"
    alias reload-fish="source ~/.config/fish/config.fish"

    alias lvim='env NVIM_APPNAME=nvim-lazy nvim'
    alias kvim='env NVIM_APPNAME=nvim-kickstart nvim'
    alias lv='env NVIM_APPNAME=nvim-lazy nvim'
    alias kv='env NVIM_APPNAME=nvim-kickstart nvim'
    fish_vi_key_bindings
end

# Brew Wrapper
if test -f (brew --prefix)/etc/brew-wrap.fish
    source (brew --prefix)/etc/brew-wrap.fish

    function _post_brewfile_update
        echo "Brewfile was updated!"
        ~/.local/bin/my-scripts/update-packages-yaml.ts
    end
end

# # Basic prompt structure
# set --global tide_left_prompt_items os pwd git node rustc go python
# set --global tide_right_prompt_items time

set -g fish_greeting

function cursor
    command /usr/local/bin/cursor $argv
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
starship init fish | source
