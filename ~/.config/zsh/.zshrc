# ===== HISTORY SETTINGS =====
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"  # XDG-compliant
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Change from:
fpath=(~/.zsh/completions $fpath)
# To:
fpath=("${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions" $fpath)

# Add this right after Zinit initialization (~line 20)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Change line 14 (Zinit check):
if [[ ! -f "$XDG_DATA_HOME/zinit/zinit.git/zinit.zsh" ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$XDG_DATA_HOME/zinit" && command chmod g-rwX "$XDG_DATA_HOME/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$XDG_DATA_HOME/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

# Change line 25 (Zinit source):
source "$XDG_DATA_HOME/zinit/zinit.git/zinit.zsh"

# Keep only core settings and source others
typeset -U path  # Keep this in main file
setopt SHARE_HISTORY

# Source split configs in order
for file in ~/.config/zsh/rc.d/*.zsh(N); do
    source "$file"
done

# Keep these in main file if they need to be last
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"