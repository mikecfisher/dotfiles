# Kanata Configuration for macOS

Keyboard remapping configuration using [Kanata](https://github.com/jtroo/kanata) with Hammerspoon visual overlays.

## Features

- **Caps Lock**: Tap for Escape, hold for Control
- **Leader Key**: Press `.` + `/` together to activate layer-based shortcuts
- **Visual Overlays**: Hammerspoon displays available keys for each layer
- **App Launching**: Quick access to apps via `Leader → a → key`
- **Window Management**: Raycast window commands via `Leader → w → key`
- **System Controls**: Lock screen, notifications, etc.

## Prerequisites

- **macOS** (tested on Ventura+)
- **Homebrew**: [Install Homebrew](https://brew.sh)
- **Karabiner VirtualHIDDevice Driver**: Install [Karabiner-Elements](https://karabiner-elements.pqrs.org/) (you can quit the app after installation - only the driver is needed)

## Quick Start

```bash
./setup.sh
```

The setup script is **idempotent** - safe to run multiple times. It will skip steps that are already configured.

### What the Script Does

1. **Checks prerequisites** - macOS, Xcode CLI tools, Homebrew, Karabiner driver
2. **Installs dependencies** - Hammerspoon, terminal-notifier (via Homebrew)
3. **Installs kanata binary** - Copies to `/usr/local/bin/kanata`
4. **Installs LaunchDaemon** - Creates `/Library/LaunchDaemons/com.kanata.plist`
5. **Configures Hammerspoon** - Symlinks `~/.hammerspoon` to the repo's config
6. **Starts the service** - Bootstraps the LaunchDaemon
7. **Verifies setup** - Checks daemon is running and TCP server responds

### Script Options

```bash
./setup.sh              # Install/verify setup
./setup.sh --uninstall  # Remove service and configuration
./setup.sh --help       # Show help
```

## Manual Permissions Required

After running the setup script, you must grant these permissions manually:

### 1. Input Monitoring (Required)

Kanata needs permission to capture keyboard input.

1. Open **System Settings → Privacy & Security → Input Monitoring**
2. Click `+`
3. Press `Cmd+Shift+G` and enter the path to `kanata_cmd` in this repo
4. Enable the checkbox

> **Note**: After adding, restart the service: `sudo launchctl kickstart -k system/com.kanata`

### 2. Accessibility (Required for Overlays)

Hammerspoon needs permission to display overlays.

1. Open **System Settings → Privacy & Security → Accessibility**
2. Click `+`
3. Add **Hammerspoon.app** from `/Applications`
4. Enable the checkbox

### 3. Start Hammerspoon

1. Open Hammerspoon from Applications
2. Grant any permission prompts
3. Hammerspoon will auto-connect to Kanata's TCP server

## Architecture

```
Leader Key (./)
├── apps (a)      → App launchers
├── windows (w)   → Window management
├── browser (b)   → Browser bookmarks
├── raycast (r)   → Raycast commands
├── system (s)    → System controls
├── kanata (k)    → Kanata controls (reload, etc.)
└── n             → Clear notifications
```

Each layer change emits a TCP event on port 5829. Hammerspoon listens and displays an overlay showing available keys.

## Key Bindings

### Leader Key Activation

Press `.` and `/` together (chord) to enter leader mode.

### Apps Layer (`Leader → a`)

| Key | App |
|-----|-----|
| `1` | 1Password |
| `b` | ChatGPT Atlas |
| `c` | Zed |
| `d` | Discord |
| `e` | Superhuman |
| `f` | Finder |
| `g` | Chrome |
| `i` | ChatGPT |
| `n` | Notion |
| `p` | Perplexity |
| `r` | Reflect |
| `s` | Slack |
| `t` | Ghostty |
| `v` | VS Code |
| `z` | Cursor |

### Windows Layer (`Leader → w`)

| Key | Action |
|-----|--------|
| `h` | Left half |
| `j` | Bottom half |
| `k` | Top half |
| `l` | Right half |
| `f` | Maximize |

### Other Layers

See the `.kbd` files for complete mappings:
- `apps.kbd` - App launchers
- `windows.kbd` - Window management
- `browser.kbd` - Browser bookmarks
- `raycast.kbd` - Raycast commands
- `system.kbd` - System controls
- `kanata-commands.kbd` - Kanata controls

## Files

```
kanata/
├── setup.sh             # Idempotent setup script
├── kanata.kbd           # Main config (includes other files)
├── kanata_cmd           # Binary with cmd feature
├── com.kanata.plist     # LaunchDaemon template
├── hammerspoon/         # Hammerspoon config
│   ├── init.lua         # Entry point
│   └── kanata.lua       # TCP client + overlay
├── apps.kbd             # App launcher layer
├── windows.kbd          # Window management layer
├── browser.kbd          # Browser shortcuts
├── raycast.kbd          # Raycast commands
├── system.kbd           # System controls
└── kanata-commands.kbd  # Kanata controls
```

## Service Management

```bash
# Check status
sudo launchctl print system/com.kanata

# Restart service
sudo launchctl kickstart -k system/com.kanata

# Stop service
sudo launchctl bootout system/com.kanata

# Start service
sudo launchctl bootstrap system /Library/LaunchDaemons/com.kanata.plist

# View logs
tail -f /var/log/kanata.error.log

# Test TCP connection
nc -z localhost 5829 && echo "OK" || echo "Not responding"
```

## Troubleshooting

### `IOHIDDeviceOpen: not permitted` or `privilege violation`

The binary isn't in Input Monitoring, or the permission was revoked.

1. Remove the binary from Input Monitoring
2. Re-add it
3. Restart the service: `sudo launchctl kickstart -k system/com.kanata`

### Kanata won't start / crashes immediately

Check the error log:
```bash
tail -50 /var/log/kanata.error.log
```

Common causes:
- Karabiner-Elements is running (they can't run simultaneously)
- Karabiner driver isn't active
- Config syntax error

### "cmd not allowed" error

You're using the Homebrew version of kanata, which doesn't include the `cmd` feature. Use the included `kanata_cmd` binary or download from [GitHub releases](https://github.com/jtroo/kanata/releases) (look for `*_cmd` variants).

### Hammerspoon overlay doesn't appear

1. Verify kanata is running with TCP enabled (port 5829)
2. Test connection: `nc localhost 5829`
3. Check Hammerspoon console (`Cmd+Option+C`) for errors
4. Reload Hammerspoon config

### Keys don't work / can't type

1. Ensure Karabiner-Elements is **not** running
2. Activate the Karabiner driver:
   ```bash
   sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate
   ```

## Customization

### Adding a New App Shortcut

1. Edit `apps.kbd`
2. Add an alias:
   ```lisp
   (defalias
     open-myapp (cmd open -b com.example.myapp)
   )
   ```
3. Add to the layer:
   ```lisp
   (deflayermap (apps)
     x (multi @open-myapp (layer-switch base))
   )
   ```
4. Update `hammerspoon/kanata.lua` with the new mapping for the overlay
5. Reload: `Leader → k → r`

### Finding Bundle IDs

```bash
osascript -e 'id of app "App Name"'
# or
mdls -name kMDItemCFBundleIdentifier /Applications/AppName.app
```

## Resources

- [Kanata Documentation](https://github.com/jtroo/kanata/blob/main/docs/config.adoc)
- [Kanata Sample Configs](https://github.com/jtroo/kanata/tree/main/cfg_samples)
- [Kanata Online Simulator](https://jtroo.github.io/kanata-simulator/)
- [Hammerspoon Documentation](https://www.hammerspoon.org/docs/)

## Uninstalling

```bash
./setup.sh --uninstall
```

This removes:
- LaunchDaemon service and plist
- Binary from `/usr/local/bin`
- Optionally, the Hammerspoon symlink

Homebrew packages (Hammerspoon, terminal-notifier) are preserved.
