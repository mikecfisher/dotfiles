# Vim Keybindings Reference

This document provides a comprehensive reference for all Vim keybindings configured in my editor setup. These mappings are designed to create a powerful, LazyVim-inspired editing experience within VS Code and Cursor.

## Core Vim Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `vim.leader` | `<Space>` | Sets Space as the leader key |
| `vim.easymotion` | `true` | Enables EasyMotion plugin for quick cursor movement |
| `vim.camelCaseMotion.enable` | `true` | Enables navigation within camelCase words |
| `vim.useSystemClipboard` | `true` | Uses system clipboard for yank/paste operations |
| `vim.incsearch` | `true` | Shows search matches as you type |
| `vim.hlsearch` | `true` | Highlights all matches when searching |
| `vim.ignorecase` | `true` | Makes searches case-insensitive |
| `vim.smartcase` | `true` | Makes searches case-sensitive when using uppercase letters |
| `vim.highlightedyank.enable` | `true` | Briefly highlights yanked (copied) text |
| `vim.autoindent` | `true` | Automatically indents new lines to match previous indentation |

## Normal Mode Keybindings

### Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `H` | `:bprevious` | Go to previous buffer |
| `L` | `:bnext` | Go to next buffer |
| `<C-h>` | `workbench.action.navigateLeft` | Navigate to left editor group |
| `<C-j>` | `workbench.action.navigateDown` | Navigate to editor group below |
| `<C-k>` | `workbench.action.navigateUp` | Navigate to editor group above |
| `<C-l>` | `workbench.action.navigateRight` | Navigate to right editor group |

### Window Management

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<C-Up>` | `workbench.action.increaseViewHeight` | Increase editor height |
| `<C-Down>` | `workbench.action.decreaseViewHeight` | Decrease editor height |
| `<C-Left>` | `workbench.action.decreaseViewWidth` | Decrease editor width |
| `<C-Right>` | `workbench.action.increaseViewWidth` | Increase editor width |

### Split Management

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ws` | `workbench.action.splitEditorDown` | Split editor down |
| `<leader>wv` | `workbench.action.splitEditorRight` | Split editor right |
| `<leader>wl` | `workbench.action.splitEditorRight` | Split editor right (alternative) |
| `<leader>wh` | `workbench.action.splitEditorLeft` | Split editor left |
| `<leader>wj` | `workbench.action.splitEditorDown` | Split editor down (alternative) |
| `<leader>wk` | `workbench.action.splitEditorUp` | Split editor up |
| `<leader>v` | `:vsplit` | Create vertical split |
| `<leader>s` | `:split` | Create horizontal split |

### Debugging

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>db` | `editor.debug.action.toggleBreakpoint` | Toggle breakpoint |
| `<leader>dc` | `workbench.action.debug.continue` | Continue debugging |
| `<leader>dC` | `workbench.action.debug.run` | Run without debugging |
| `<leader>do` | `workbench.action.debug.stepOver` | Step over |
| `<leader>di` | `workbench.action.debug.stepInto` | Step into |
| `<leader>dO` | `workbench.action.debug.stepOut` | Step out |
| `<leader>dx` | `workbench.action.debug.stop` | Stop debugging |

### Buffer Management

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>bd` | `workbench.action.closeActiveEditor` | Close current editor (buffer) |

### Diagnostics Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `]d` | `editor.action.marker.next` | Go to next diagnostic |
| `[d` | `editor.action.marker.prev` | Go to previous diagnostic |
| `<leader>cd` | `editor.action.showHover` | Show hover information |
| `<leader>xd` | `workbench.actions.view.problems` | Show problems panel |
| `<leader>xw` | `workbench.actions.view.problems` | Show problems panel (alternative) |

### File Explorer

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>e` | `workbench.view.explorer` | Open file explorer |
| `<leader>E` | Multiple commands | Open and focus file explorer |
| `<leader>fe` | `workbench.action.toggleSidebarVisibility` | Toggle sidebar visibility |

### Comments

| Keybinding | Action | Description |
|------------|--------|-------------|
| `gcc` | `editor.action.commentLine` | Comment/uncomment current line |
| `gc` | `editor.action.commentLine` | Comment/uncomment selection |

### Search Commands

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>/` | `actions.find` | Find in current file |
| `<leader>sg` | `workbench.action.findInFiles` | Find in files |
| `<leader>sG` | `workbench.action.findInFiles` | Find in files (alternative) |
| `<leader>ss` | `workbench.action.gotoSymbol` | Go to symbol in file |
| `<leader>sw` | `editor.action.addSelectionToNextFindMatch` | Add selection to next match |

### File Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ff` | `workbench.action.quickOpen` | Quick open file |
| `<leader>fF` | `workbench.action.quickOpen` | Quick open file (alternative) |
| `<leader>fr` | `workbench.action.openRecent` | Open recent files |
| `<leader>fb` | `workbench.action.showAllEditorsByMostRecentlyUsed` | Show all editors |
| `<leader>leader` | `workbench.action.quickOpen` | Quick open file (alternative) |

### Terminal

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ft` | `workbench.action.terminal.toggleTerminal` | Toggle terminal |
| `<leader>fT` | `workbench.action.terminal.new` | New terminal |

### Git Commands

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>gg` | `workbench.view.scm` | Open source control view |
| `<leader>gs` | `workbench.action.findInFiles` | Search in files |

### Tab Management

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Leader>tt` | `:tabnew` | Create new tab |
| `<Leader>tn` | `:tabnext` | Go to next tab |
| `<Leader>tp` | `:tabprev` | Go to previous tab |
| `<Leader>to` | `:tabo` | Close all other tabs |

### Code Actions

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ca` | `editor.action.codeAction` | Show code actions |
| `<leader>cs` | `workbench.action.gotoSymbol` | Go to symbol in file |
| `<leader>ch` | `composer.showComposerChatHistory` | Show composer chat history |

### Code Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>gd` | `editor.action.revealDefinition` | Go to definition |
| `<leader>gr` | `editor.action.goToReferences` | Go to references |

### Text Manipulation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>j` | `J` | Join lines |

## Insert Mode Keybindings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `jj` | `<Esc>` | Escape to normal mode |

## Visual Mode Keybindings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `>` | `editor.action.indentLines` | Indent selected lines |
| `<` | `editor.action.outdentLines` | Outdent selected lines |
| `J` | `editor.action.moveLinesDownAction` | Move selected lines down |
| `K` | `editor.action.moveLinesUpAction` | Move selected lines up |
| `<leader>sg` | Multiple commands | Add selection to next match and find in files |

## Disabled Key Handlers

The following keys are disabled or modified in their handling:

| Key | Handling | Description |
|-----|----------|-------------|
| `<C-o>` | Disabled | Disabled in normal mode (conflicts with Karabiner) |
| `<C-t>` | Disabled | Disabled in normal mode |
| `<C-b>` | Disabled | Disabled in normal mode |
| `<C-d>` | Vim handles | Vim handles this key |
| `<C-u>` | Vim handles | Vim handles this key |
| `<C-f>` | VS Code handles | VS Code handles find |
| `<C-h>` | Vim handles | Vim handles this key |
| `<C-j>` | Vim handles | Vim handles this key |
| `<C-k>` | Vim handles | Vim handles this key |
| `<C-l>` | Vim handles | Vim handles this key |

## File Explorer Keybindings

These keybindings are active when the file explorer has focus:

| Keybinding | Action | Description |
|------------|--------|-------------|
| `r` | `renameFile` | Rename selected file/folder |
| `c` | `filesExplorer.copy` | Copy selected file/folder |
| `p` | `filesExplorer.paste` | Paste previously copied file/folder |
| `x` | `filesExplorer.cut` | Cut selected file/folder |
| `d` | `deleteFile` | Delete selected file/folder |
| `a` | `explorer.newFile` | Create new file |
| `shift+a` | `explorer.newFolder` | Create new folder |
| `s` | `explorer.openToSide` | Open file in split to the side |
| `shift+s` | Multiple commands | Open file in split below and focus on it |
| `enter` | `explorer.openAndPassFocus` | Open file and focus on it |