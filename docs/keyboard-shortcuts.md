# Keyboard Shortcuts

This document outlines the custom keyboard shortcuts configured in my development environment. These shortcuts are designed to create a Vim-like experience with additional IDE features.

## Navigation Shortcuts

### Window/Editor Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `Ctrl+h` | All | Navigate to the left editor group |
| `Ctrl+j` | All | Navigate to the editor group below |
| `Ctrl+k` | All | Navigate to the editor group above |
| `Ctrl+l` | All | Navigate to the right editor group |
| `leader e` | Normal | Toggle sidebar visibility |

### Split Management

| Shortcut | Mode | Description |
|----------|------|-------------|
| `; w l` | Normal | Split editor right |
| `; w h` | Normal | Split editor left |
| `; w j` | Normal | Split editor down |
| `; w k` | Normal | Split editor up |
| `<Leader> v` | Normal | Create vertical split (`:vsplit`) |
| `<Leader> s` | Normal | Create horizontal split (`:split`) |

### Tab/Buffer Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `leader b l` | Normal | Open next recently used editor |
| `leader b d` | Normal | Close current editor (buffer delete) |
| `Shift+h` | Normal | Go to previous buffer (`:bprevious`) |
| `Shift+l` | Normal | Go to next buffer (`:bnext`) |
| `<Leader> t t` | Normal | Create new tab |
| `<Leader> t o` | Normal | Close all other tabs |

### List/Menu Navigation

Press Tab then:
| Shortcut | Mode | Description |
|----------|------|-------------|
| `j` | List | Move down in lists, suggestions, and quick open |
| `k` | List | Move up in lists, suggestions, and quick open |

## Code Editing

| Shortcut | Mode | Description |
|----------|------|-------------|
| `Shift+j` | Normal/Visual | Move current line(s) down |
| `Shift+k` | Normal/Visual | Move current line(s) up |
| `leader c a` | Normal | Show code actions menu |
| `leader c r` | Normal | Rename symbol (refactoring) |
| `Ctrl+n` | Normal/Visual | Add selection to next find match (multiple cursors) |
| `<Leader> j` | Normal | Join lines (equivalent to J in Vim) |
| `>` | Visual | Indent selected lines |
| `<` | Visual | Outdent selected lines |
| `jj` | Insert | Escape to normal mode |

## Code Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `leader c s` / `<Leader> c s` | Normal | Go to symbol in current file |
| `leader g d` / `<Leader> g d` | Normal | Go to definition |
| `leader g r` / `<Leader> g r` | Normal | Find all references |

## UI Toggling & Workspace Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<Leader> <Leader>` | Normal | Quick open file picker |
| `<Leader> g s` | Normal | Search across all files |
| `leader g g` / `<Leader> g g` | Normal | Quick access to source control view |
| `leader g e` / `<Leader> g e` | Normal | Quick access to file explorer |
| `:` | Normal | Open command palette |

## File Explorer Actions

| Shortcut | Mode | Description |
|----------|------|-------------|
| `r` | Explorer | Rename selected file/folder |
| `c` | Explorer | Copy selected file/folder |
| `p` | Explorer | Paste previously copied file/folder |
| `x` | Explorer | Cut selected file/folder |
| `d` | Explorer | Delete selected file/folder |
| `a` | Explorer | Create new file at current location |
| `Shift+a` | Explorer | Create new folder at current location |
| `s` | Explorer | Open file in split to the side |
| `Shift+s` | Explorer | Open file in split below and focus on it |
| `Enter` | Explorer | Open file and focus on it |

## Vim Extensions

| Feature | Description |
|---------|-------------|
| `<Space>` | Leader key |
| EasyMotion | Enabled for quick navigation |
| CamelCaseMotion | Enabled for navigation within camelCase words |
| Hlsearch | Enabled for highlighting search results |

## Disabled Shortcuts

The following shortcuts are disabled to avoid conflicts:
- `Ctrl+o` in normal mode
- `Ctrl+t` in normal mode
- `Ctrl+b` in normal mode