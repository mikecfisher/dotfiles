if status is-interactive
    zoxide init fish | source

    # Make cd use z instead
    alias cd="z"
    alias y="yazi"
    alias lg="lazygit"
    alias v="nvim"
    alias edit-fish="nvim ~/.config/fish/config.fish"
    alias reload-fish="source ~/.config/fish/config.fish"

    fish_vi_key_bindings
end

# # Basic prompt structure
# set --global tide_left_prompt_items os pwd git node rustc go python
# set --global tide_right_prompt_items time

set -g fish_greeting

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
