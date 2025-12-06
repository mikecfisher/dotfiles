function wtmux
    # Require git
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Not inside a git repo."
        return 1
    end

    # Repo root name, for example "listium"
    set root (basename (git rev-parse --show-toplevel))

    # Branch or worktree identifier
    set branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if test -z "$branch"
        set branch detached
    end

    # Session name: listium-feature-x
    set session "$root-$branch"

    # Start or attach to tmux session rooted at current directory
    tmux new-session -A -s $session -c $PWD
end
