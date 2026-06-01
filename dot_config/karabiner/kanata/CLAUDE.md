# Kanata Configuration Guide

## Repository Structure

```
kanata/
├── kanata.kbd           # Main config - base layer, leader layer, includes
├── apps.kbd             # App launching layer (Leader → a → key)
├── windows.kbd          # Window management layer (Leader → w → key)
├── browser.kbd          # Browser URL shortcuts (Leader → b → key)
├── raycast.kbd          # Raycast commands (Leader → r → key)
├── system.kbd           # System controls (Leader → s → key)
├── kanata-commands.kbd  # Kanata control layer (Leader → k → key)
├── hammerspoon/         # Hammerspoon layer overlay (symlink to ~/.hammerspoon)
│   ├── init.lua         # Hammerspoon entry point
│   └── kanata.lua       # TCP client + overlay logic
├── com.kanata.plist     # launchd service definition
└── setup.sh             # Installation script
```

## Architecture

The configuration uses a **layer-based** architecture:

```
base
└── leader (chord ./)
    ├── apps (a)
    │   └── messaging (m) → hold for WhatsApp/Beeper
    ├── windows (w)
    ├── browser (b)
    ├── raycast (r)
    ├── system (s)
    ├── kanata-cmds (k)
    └── n → clear notifications (direct action)
```

Each layer change emits a `LayerChange` event via TCP (port 5829). Hammerspoon connects to this port and displays a visual overlay showing available key mappings for the current layer.

---

## Running Kanata

### Test Changes Manually
```bash
sudo ~/.config/karabiner/kanata/kanata_cmd --cfg ~/.config/karabiner/kanata/kanata.kbd -p 5829
```

### Reload Config (While Running)
Press: Leader → k → r (`. + /` together, then `k`, then `r`)

### Service Management
```bash
# Start
sudo launchctl bootstrap system /Library/LaunchDaemons/com.kanata.plist

# Stop
sudo launchctl bootout system /Library/LaunchDaemons/com.kanata.plist

# View logs
tail -f /var/log/kanata.error.log

# Check TCP connection
nc localhost 5829
```

---

## Kanata Syntax Guide

### Layers (Category Organization)

Layers are defined using `deflayermap` with actions that return to base:

```lisp
;; Define aliases for actions
(defalias
  open-finder (cmd open -b com.apple.finder)
)

;; Define the layer
(deflayermap (apps)
  f (multi @open-finder (layer-switch base))
  esc (layer-switch base)
  _ (layer-switch base)  ;; fallback - any unbound key returns to base
)
```

### Layer Navigation

```lisp
;; From leader layer - enter a category layer (tap, don't hold)
a (layer-switch apps)

;; From category layer - perform action and return to base
f (multi @open-finder (layer-switch base))
```

### Running Shell Commands

```lisp
;; Basic command
(cmd open -b com.apple.finder)

;; Command with URL scheme - use -g to prevent focus stealing
(cmd open -g "raycast://extensions/raycast/window-management/left-half")

;; Multiple actions
(multi lrld (cmd terminal-notifier -title "Kanata" -message "Done"))
```

### Opening Apps

Prefer bundle IDs over paths:
```lisp
;; Good - bundle ID
(cmd open -b com.apple.finder)

;; Okay - path (use for apps without standard bundle IDs)
(cmd open "/Applications/Some App.app")
```

To find a bundle ID:
```bash
osascript -e 'id of app "AppName"'
# or
mdls -name kMDItemCFBundleIdentifier /Applications/AppName.app
```

### Key Aliases

```lisp
(defalias
  cap (tap-hold 200 200 esc lctl)  ;; tap=esc, hold=ctrl
)
```

### Chords (Simultaneous Keys)

```lisp
(defchordsv2
  (. /) (layer-switch leader) 200 first-release ()
)
```

### Sub-layers (Sequential Pattern)

For categories within categories (e.g., messaging apps):
```lisp
;; 'm' enters messaging sub-layer, then press m/w/b
m (layer-switch messaging)
```

---

## Quirks and Gotchas

### 1. Binary Must Have `cmd` Feature
The Homebrew kanata does NOT include the `cmd` feature. You must use `kanata_cmd` from GitHub releases or build with `--features cmd`.

### 2. URL Schemes Need `-g` Flag
Without `-g`, opening URL schemes steals focus from the current window:
```lisp
;; Bad - steals focus
(cmd open "raycast://...")

;; Good - opens in background
(cmd open -g "raycast://...")
```

### 3. Karabiner Driver Required
Kanata uses Karabiner's VirtualHIDDevice driver. Karabiner-Elements app must be installed (but not running) for the driver to be available.

### 4. Cannot Run With Karabiner-Elements
Kanata and Karabiner-Elements cannot run simultaneously - they share the same driver.

### 5. Layer-Based vs Sequence-Based
This config uses **layers** (not sequences) so each category emits layer change events for Hammerspoon to display overlays.

### 6. Leader Key is a Chord
The leader key is `.` + `/` pressed together (not sequentially), which activates the `leader` layer.

### 7. Include Order Matters
Files are included at the end of `kanata.kbd`. All `defalias` and `deflayermap` are collected across files.

### 8. Testing Syntax
Use the online simulator to test syntax before applying:
https://jtroo.github.io/kanata-simulator/

### 9. Notification Dependency
The reload notification uses `terminal-notifier`. Install with:
```bash
brew install terminal-notifier
```

### 10. Config Path is Hardcoded
The launchd plist has an absolute path to the config. If you move the repo, update `com.kanata.plist`.

### 11. TCP Port for Layer Events (Critical!)
The `-p 5829` flag is **required** to enable the TCP server. Without it, kanata won't emit layer events and Hammerspoon overlay won't work. The JSON format is:
```json
{"LayerChange":{"new":"apps"}}
```

---

## Adding New Shortcuts

### New App Launcher
In `apps.kbd`:
```lisp
;; Add to defalias section
(defalias
  ;; ... existing entries ...
  open-myapp (cmd open -b com.example.myapp)
)

;; Add to deflayermap
(deflayermap (apps)
  ;; ... existing entries ...
  x (multi @open-myapp (layer-switch base))
)
```

### New Window Command
In `windows.kbd`:
```lisp
(defalias
  win-new-action (cmd open -g "raycast://extensions/raycast/window-management/action-name")
)

(deflayermap (windows)
  x (multi @win-new-action (layer-switch base))
)
```

### New Category
1. Create a new `.kbd` file with `defalias` and `deflayermap`
2. Include it in `kanata.kbd`: `(include mynewfile.kbd)`
3. Add entry point in leader layer: `x (layer-while-held newlayer)`

---

## Hammerspoon Layer Overlay

Hammerspoon displays a visual overlay showing available key mappings when kanata switches layers.

### Installation
1. Install Hammerspoon: `brew install --cask hammerspoon`
2. Symlink the config:
   ```bash
   rm -rf ~/.hammerspoon
   ln -s ~/.config/karabiner/kanata/hammerspoon ~/.hammerspoon
   ```
3. Grant Hammerspoon Accessibility permissions in System Settings
4. Start/reload Hammerspoon

### How It Works
```
Kanata (TCP:5829) --JSON--> Hammerspoon ---> Visual Overlay
                           {"LayerChange":{"new":"apps"}}
```

When you press `.+/` to enter leader mode, Hammerspoon shows an overlay with available category keys. When you press `a` for apps, it shows all app shortcuts.

### Features
- Auto-connects to kanata on startup
- Auto-reconnects if kanata restarts
- Centered overlay with dark semi-transparent background
- Shows layer name and all key→action mappings
- Auto-hides when returning to base layer

### Updating Mappings
When adding new shortcuts to kanata, also update the `layerMappings` table in `hammerspoon/kanata.lua` to keep the overlay in sync.

### Testing
```lua
-- In Hammerspoon console (Cmd+Option+C):
require("kanata").toggleOverlay("apps")  -- Show apps overlay
require("kanata").hideOverlay()           -- Hide overlay
hs.alert.show("test")                     -- Test if alerts work
```

### Troubleshooting

**No overlay appears:**
1. Verify kanata is running WITH the `-p 5829` flag (required for TCP):
   ```bash
   # This WON'T work - no TCP server:
   sudo ./kanata_cmd --cfg ./kanata.kbd

   # This WILL work - TCP enabled:
   sudo ./kanata_cmd --cfg ./kanata.kbd -p 5829
   ```

2. Test TCP connection manually:
   ```bash
   nc localhost 5829
   # Should output JSON like: {"LayerChange":{"new":"base"}}
   # If "Connection refused", kanata isn't listening on TCP
   ```

3. Reload Hammerspoon after starting kanata with TCP:
   - Click menu bar icon → "Reload Config"
   - Or run `hs.reload()` in console

**Start order matters:**
1. Start kanata with `-p 5829` first
2. Then start/reload Hammerspoon
3. You should see "Connected to Kanata" alert

**Hammerspoon not loading config:**
- Check console (Cmd+Option+C) for errors
- Verify symlink: `ls -la ~/.hammerspoon` should point to repo

---

## Key Bindings Reference

| Chord | Then | Then | Action |
|-------|------|------|--------|
| ./ | a | 1 | 1Password |
| ./ | a | f | Finder |
| ./ | a | g | Chrome |
| ./ | a | m → m | Messages |
| ./ | a | m → w | WhatsApp |
| ./ | a | m → b | Beeper |
| ./ | w | h/j/k/l | Window left/down/up/right |
| ./ | w | f | Maximize |
| ./ | b | g | github.com |
| ./ | r | h | Clipboard history |
| ./ | s | l | Lock screen |
| ./ | k | r | Reload config |
| ./ | n | - | Clear notifications |

---

## Reference

- [Kanata docs](https://github.com/jtroo/kanata/blob/main/docs/config.adoc)
- [Sample configs](https://github.com/jtroo/kanata/tree/main/cfg_samples)
- [Online simulator](https://jtroo.github.io/kanata-simulator/)
- [Hammerspoon docs](https://www.hammerspoon.org/docs/)
