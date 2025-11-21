# WezTerm Configuration

> **Lovecraft / Mike Fisher**  
> Complete tmux + sesh replacement with native WezTerm workspaces

---

## 📖 Table of Contents

- [Philosophy](#philosophy)
- [Keyboard Shortcuts](#keyboard-shortcuts)
  - [Workspaces (Sessions)](#workspaces-sessions)
  - [Tabs (Windows)](#tabs-windows)
  - [Panes (Splits)](#panes-splits)
  - [Copy Mode & Selection](#copy-mode--selection)
  - [Utility](#utility)
- [Pre-Configured Workspaces](#pre-configured-workspaces)
- [Adding New Workspaces](#adding-new-workspaces)
- [Why WezTerm > Tmux](#why-wezterm--tmux)
- [Troubleshooting](#troubleshooting)

---

## Philosophy

This config **completely replaces tmux + sesh** with native WezTerm features:

- ✅ **No prefix key** - Use native CMD shortcuts (like every other Mac app)
- ✅ **Seamless Neovim integration** - `CTRL+H/J/K/L` navigates both WezTerm panes AND Neovim splits
- ✅ **GPU accelerated** - Smoother than tmux, better fonts, ligatures, emojis
- ✅ **One config language** - Just Lua (no tmux.conf, no bash scripts)
- ✅ **Workspaces with multiple tabs** - Like sesh sessions with pre-configured windows
- ✅ **Native clipboard** - No tmux/macOS clipboard weirdness
- ✅ **Better defaults** - Most things just work out of the box

---

## Keyboard Shortcuts

### Workspaces (Sessions)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `CMD+F` | **Launch workspace** | Fuzzy find & launch pre-configured workspaces (like `sesh connect`) |
| `CMD+S` | Create/switch workspace | Prompt for workspace name, creates if doesn't exist |
| `CMD+N` | Workspace from directory | Creates workspace named after current directory |
| `CMD+O` | Next workspace | Switch to next workspace (like alt-tab for workspaces) |
| `CMD+Shift+O` | Previous workspace | Switch to previous workspace |
| `CMD+Shift+W` | List workspaces | Show all workspaces with fuzzy search |

**Most used:** `CMD+F` - This is your main workspace launcher!

---

### Tabs (Windows)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `CMD+T` | New tab | Creates new tab in current directory |
| `CMD+W` | Close tab/pane | Closes current pane (or tab if only one pane) |
| `CMD+Shift+[` | Previous tab | Navigate to previous tab |
| `CMD+Shift+]` | Next tab | Navigate to next tab |
| `CMD+1-9` | Jump to tab | Jump directly to tab 1-9 |
| `CMD+Shift+{` | Move tab left | Reorder tab to the left |
| `CMD+Shift+}` | Move tab right | Reorder tab to the right |

---

### Panes (Splits)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `CMD+D` | Split vertically | Split pane top/bottom (inherits directory) |
| `CMD+Shift+D` | Split horizontally | Split pane left/right (inherits directory) |
| `CTRL+H/J/K/L` | **Navigate panes** | Navigate between panes (works in Neovim too!) |
| `CMD+Shift+←/→/↑/↓` | Resize pane | Resize pane by 5 units in direction |
| `CMD+Z` | Zoom/unzoom pane | Toggle pane fullscreen |
| `CMD+W` | Close pane | Close current pane without confirmation |

**🎯 Pro tip:** `CTRL+H/J/K/L` seamlessly navigates between WezTerm panes AND Neovim splits - no prefix key needed!

---

### Copy Mode & Selection

| Keybinding | Action | Description |
|------------|--------|-------------|
| `CMD+Shift+C` | Enter copy mode | Vim-style navigation mode |
| `CMD+;` | Quick select | Select URLs, paths, hashes with hints |
| `CMD+Shift+F` | Search scrollback | Search through terminal history |
| Mouse selection | Auto-copy | Selected text automatically copies to clipboard |
| `CMD+C` | Copy (trimmed) | Copy selection with trailing spaces removed |

**In Copy Mode:**
- Navigate: `h/j/k/l`, `w/b/e` (vim motions)
- Search: `/` (forward), `?` (backward)
- Select: `v` (visual), `V` (line), `Ctrl+V` (block)
- Copy: `y` (yank)
- Exit: `q` or `Escape`

---

### Utility

| Keybinding | Action | Description |
|------------|--------|-------------|
| `CMD+Shift+R` | Reload config | Reload wezterm.lua without restarting |
| `CMD+Shift+P` | Command palette | Access all WezTerm commands |
| `CMD+Shift+N` | New window | New window inheriting current directory |

---

## Pre-Configured Workspaces

Press `CMD+F` to launch these workspaces with multiple tabs:

### ⚡ listium
**Path:** `~/dev/personal/listium`  
**Tabs:**
- `dev` - Opens Neovim in project root
- `claude` - Launches claude CLI
- `codex` - Launches codex CLI
- `git` - Opens gt log
- `tasks` - Empty shell
- `scripts` - Empty shell

### ⚙️ tmux config
**Path:** `~/.config/tmux`  
**Tabs:**
- `sesh-settings` - Opens sesh.toml in lv
- `tmux-settings` - Opens tmux.conf in lv
- `tmux-reset` - Opens tmux.reset.conf in lv
- `git` - Opens gt log

### 📝 scratch
**Path:** `~/dev/scratch`  
**Tabs:**
- `notes` - Opens notes.md in Neovim
- `experiments` - Opens Neovim
- `shell` - Empty shell

### ⚡ wezterm config
**Path:** `~/.config/wezterm`  
**Tabs:**
- `config` - Opens wezterm.lua in Neovim
- `git` - Opens gt log

---

## Adding New Workspaces

Edit `~/.config/wezterm/wezterm.lua` and add to the `project_workspaces` table:

```lua
{
    id = "my-project",
    label = "🚀 my project",
    path = wezterm.home_dir .. "/dev/my-project",
    tabs = {
        { name = "editor", command = "nvim ." },
        { name = "server", command = "npm run dev" },
        { name = "git", command = "gt log" },
        { name = "shell" }, -- no command = just opens shell
    },
},
```

Then reload with `CMD+Shift+R` and press `CMD+F` to launch it!

---

## Why WezTerm > Tmux

### 1. No Prefix Key Madness
```
❌ Tmux: Ctrl+A, then D to split
✅ WezTerm: Just CMD+D
```

### 2. Seamless Neovim Integration
```
❌ Tmux: Separate keybindings, conflicts, send-keys hacks
✅ WezTerm: CTRL+H/J/K/L works everywhere automatically
```

### 3. Native GUI Experience
- Better font rendering (ligatures, emojis)
- Smooth GPU-accelerated scrolling
- Native macOS clipboard integration
- Proper color support (no double-rendering)

### 4. Single Configuration Language
```
❌ Tmux: tmux.conf + shell scripts + sesh.toml + Lua
✅ WezTerm: Just wezterm.lua
```

### 5. Better Defaults
- Focus follows mouse (works out of the box)
- Copy on select (no special config)
- Window titles (just work)
- Tab bar styling (beautiful by default)

### 6. Workspaces > Sessions
```
❌ Tmux: tmux attach -t session (nested terminals)
✅ WezTerm: CMD+F → fuzzy find → instant switch (native GUI)
```

---

## Troubleshooting

### Neovim navigation not working?

Make sure you **don't** have `smart-splits.nvim` or similar plugins that might conflict. The config detects vim/nvim processes automatically.

If you want the advanced integration, you can add `smart-splits.nvim` with this config:

```lua
-- In your Neovim config
require('smart-splits').setup({
  at_edge = 'stop'
})
```

### Workspace not spawning tabs correctly?

1. Check your shell is fish (config uses `fish -c`)
2. Make sure commands like `claude`, `codex`, `gt`, `lv` are in your PATH
3. Reload config with `CMD+Shift+R`

### Tab bar not showing?

The tab bar auto-hides when you have only one tab. Open multiple tabs (`CMD+T`) and it will appear.

### Want to see the tab bar always?

Edit `wezterm.lua` and change:
```lua
config.hide_tab_bar_if_only_one_tab = false
```

### Commands not auto-running in tabs?

The `send_text()` function sends commands as if you typed them. If a command isn't working:
1. Test it manually in a terminal first
2. Check if it needs to be in your PATH
3. Make sure you're using fish shell syntax

---

## Configuration Files

```
~/.config/wezterm/
├── wezterm.lua           # Main configuration
├── README.md            # This file
└── KEYBINDINGS.md       # Detailed keybinding reference
```

---

## Quick Start Guide

1. **Open WezTerm**
2. Press `CMD+F` to launch a workspace
3. Select "listium" or any other project
4. Watch as multiple tabs spawn automatically with commands running
5. Navigate between panes with `CTRL+H/J/K/L`
6. Open Neovim and notice the same keys work for vim splits!
7. Press `CMD+W` to close panes
8. Press `CMD+O` to switch between workspaces

**You're now living the tmux-free life!** 🎉

---

## Additional Resources

- [WezTerm Official Docs](https://wezfurlong.org/wezterm/)
- [WezTerm Config Reference](https://wezfurlong.org/wezterm/config/lua/general.html)
- [Catppuccin Theme](https://github.com/catppuccin/wezterm)

---

## Theme & Appearance

**Color Scheme:** Catppuccin Macchiato  
**Font:** JetBrainsMono Nerd Font (18pt)  
**Window Opacity:** 98% with 10pt blur  
**Split Indicator:** Purple (`#33008a`)  
**Unfocused Pane:** 50% brightness

**Status Line Shows:**
- Current workspace name (⚡)
- Current working directory

---

## Tips & Tricks

### Use CMD+F for Everything
This is your main entry point. Just like you used `sesh connect` in tmux, use `CMD+F` to fuzzy find workspaces.

### Create Ad-Hoc Workspaces
Press `CMD+N` in any directory to create a workspace named after that directory. Great for quick experiments!

### Zoom Panes During Presentations
Press `CMD+Z` to zoom a pane fullscreen. Perfect for demos or pair programming.

### Search Your Scrollback
Press `CMD+Shift+F` and type to search through your terminal history. Way better than tmux's copy mode search!

### Quick URL Selection
See a URL? Press `CMD+;` and it will highlight all URLs/paths with hints. Type the hint letters to copy it.

### Seamless Neovim Workflow
Open Neovim, split some windows with `:split` and `:vsplit`, then use `CTRL+H/J/K/L` to navigate between vim splits and WezTerm panes without thinking about it!

---

**Last Updated:** 2025-01-21  
**Config Version:** 1.0.0  
**WezTerm Version:** Latest stable
