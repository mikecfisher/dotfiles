function cproj
    # Pick a directory interactively
    set dir (fd . ~/code -t d -d 4 | fzf)

    # If user cancelled fzf
    if test -z "$dir"
        return
    end

    # Derive a session name
    set name (basename "$dir")

    # Create or attach tmux session with that name, rooted at that dir
    tmux new-session -A -s "$name" -c "$dir"
end
