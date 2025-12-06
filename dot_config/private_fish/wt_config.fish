# ============================================================================
# Git Worktree (wt) Configuration
# ============================================================================
# Customize the behavior of the wt command for managing git worktrees

# Editor command to use when opening worktrees
# Options: "cursor", "code", or any custom command
set -g WT_EDITOR_CMD "cursor"

# Automatically open editor after creating worktree
# Set to "false" to just create the worktree without opening
set -g WT_AUTO_OPEN true

# Source branch to use when creating new worktrees
# Options: "auto" (detect main/master), "main", "master", "develop", etc.
# "auto" will try to detect your default branch (main or master)
set -g WT_SOURCE_BRANCH "auto"

# Files and directories to copy from main repo to worktree
# These are typically gitignored files needed for development
set -g WT_COPY_PATTERNS \
    .env \
    .env.local \
    .env.development \
    .env.production \
    .env.test \
    .claude \
    .cursor \
    .agentos \
    .vscode \
    .idea

# Advanced: Custom editor open command
# Uncomment and modify if you need special behavior
# function __wt.open_editor_custom
#     set -l worktree_path $argv[1]
#     # Your custom logic here
#     # Example: open -na "YourEditor.app" --args "$worktree_path"
# end
