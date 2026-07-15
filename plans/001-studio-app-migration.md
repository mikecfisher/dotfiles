# Studio Mac application migration plan

Source inventory: `studio-app-inventory.md`, captured from `mikes-macbook.local` over SSH on 2026-07-09 (macOS 26.2).

## Goal

Turn the Studio Mac's intentional application baseline into reproducible Chez Moi provisioning without copying trials, helpers, duplicate versions, or one-off installers.

## Phase 1: Homebrew-first reconciliation

Check each candidate with `brew info --cask <name>` and add only confirmed casks to `.chezmoidata/packages.yaml`, preferably under `personal.casks` for Studio-only software.

High-confidence candidates from the inventory include:

- `android-studio`, `docker` (only if Docker Desktop is preferred over OrbStack), `forklift`, `iina`, `gitkraken`, `postgres-unofficial`, `screen-studio`, `transmission`, `utm`, `virtualbox`, `vlc`, `downie`, `daisydisk`, `shapr3d`, `fantastical`, `tailscale`, `transmit`, `istat-menus`, `betterdisplay`, `blackhole-2ch`, `loopback`, `audio-hijack`, `waves-central`, `arturia-software-center`, `steinberg-activation-manager`, `steinberg-library-manager`, and `reaper`.

Do not add an app merely because a cask exists. Confirm it is part of the intended new-Mac baseline and resolve conflicts first (OrbStack vs Docker, Warp vs iTerm/Ghostty, Rectangle vs Magnet/Moom, duplicate audio managers).

## Phase 2: Existing manifest corrections

Compare the final intentional list against `.chezmoidata/packages.yaml` and remove duplicate installation paths. In particular, choose Homebrew or App Store for Tailscale, and keep Apple apps in `mas`.

## Phase 3: Installomator coverage

Use Installomator only for apps with no Homebrew cask and a stable public installer. Candidate built-in labels from this inventory include `betterdisplay`, `blackhole2ch`, `loopback`, `rogueamoebaaudiohijack4`, `nativeaccess`, `wavescentral`, `arturiasoftwarecenter`, `steinbergactivationmanager`, `steinberglibrarymanager`, `reaper`, and `raycast`.

Do not duplicate labels already covered by Homebrew. Keep Groof and Willow Voice as private labels in `installomator/labels/`; keep Raycast Beta manual until its beta feed is stable.

## Phase 4: Vendor-managed audio software

Keep these as explicit manual/vendor-manager checklist items unless a stable cask or Installomator label is verified:

- Devious Machines, Output Hub, UAD Connect, SSL Download Manager/360, Steven Slate Audio Center, Softube Central, Slate Digital Connect, IK Product Manager, PA Installation Manager, iZotope Product Portal, XLN Online Installer, Spitfire Audio, Roland Cloud Manager, iLok License Manager, and KVR Studio Manager.
- RME Fireface/TotalMix, CH34xVCPDriver, Insta360, Elgato Stream Deck, MIDI Fighter, OXI, QMK/Vial/Bazecor, and other hardware drivers/configurators.

These installers commonly require account login, hardware activation, or privileged system extensions.

## Phase 5: Cleanup review

Before adding anything, decide whether these are intentional baseline apps or historical residue:

- Ableton beta/update bundles, Playbeat trial, duplicate Mixed In Key 10/11, duplicate RX 10/11, duplicate Lexicon/Lexicon-Beta, duplicate DJ.Studio/DJ.Studio Next, duplicate Raycast stable/beta, and duplicate apps such as Arc/ARC X or Proton Mail/uninstaller.
- Temporary helpers and installers such as `.Ableton*`, `Sparkle`, `Authorization Manager`, `License Control Center`, and updater-only bundles.

## Verification gates

1. `ruby -ryaml -e 'YAML.load_file(".chezmoidata/packages.yaml")'`
2. `brew info --cask <each-selected-cask>` succeeds for every added cask.
3. `chezmoi diff` on a clean machine shows only intentional additions.
4. Installomator custom labels run with `DEBUG=2` before any real install.
5. A fresh personal-machine `chezmoi apply` completes with vendor-managed apps reported as explicit follow-up items.

## Out of scope

Do not automate license activation, vendor account sign-in, private download portals, or hardware-driver approval. Do not add every application found on the Studio Mac to the personal baseline without an explicit keep/delete decision.
