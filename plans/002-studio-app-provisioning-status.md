# Studio app provisioning status

Source: the edited `studio-app-inventory.md`.

## Added to Homebrew

The following inventory apps now have personal Homebrew casks in
`.chezmoidata/packages.yaml`: Anki, Bambu Studio, Backblaze, Bitwig Studio,
BlueBubbles, Brave Browser, Dropbox, ForkLift, Geekbench, IINA, iZotope Product Portal,
Mixed In Key, Native Access, PaulXStretch, Reflect, RipX, Softube Central,
Splice, Synology Assistant, Synology Drive Client, Telegram, Topaz Photo AI,
UA Connect, WhatsApp, Wispr Flow, Youlean Loudness Meter, and Zoom. Tailscale
was removed from the MAS list in favor of its Homebrew cask.

Existing manifest casks cover the other requested Homebrew apps such as
Ableton, BetterDisplay, ChatGPT, Claude, Conductor, DJ.Studio, Ghostty,
Granola, Hermes, Legcord, Lexicon, Notion, Obsidian, OrbStack, Raycast,
Spotify, Superhuman, and Zed.

## Installomator/private-label status

The current Installomator release was checked against the remaining names.
Every remaining app with a confirmed Homebrew cask was routed to Homebrew
first; no duplicate Installomator recipe is needed for those apps.
There are no reliable built-in labels for the remaining vendor-specific audio
apps below, so no guessed labels were added:

- AmpliTube 5, BA-1, BA-1 FX Strip, Harmony Bloom, Keyscape, Loopcloud,
  Model D, OXI App/OXI-Desktop, Oszillos Mega Scope, Output Hub,
  PA-InstallationManager, Roland Cloud Manager, SEM, SSL 360/SSL Download
  Manager, Sample Scout, Serato DJ Lite/Serato Studio, Slate Digital Connect,
  Sononym, Steven Slate Audio Center, T-1 Config, WiFiman Desktop, XLN Online
  Installer, and other plugin/hardware managers.

These are vendor-manager or hardware-driver workflows. They should be
installed from their official managers after Homebrew provisioning unless a
stable public download URL and signed app identity are established for a
private label.

Private labels already implemented and tested:

- `groof` — official Sparkle feed, signed Team ID verified.
- `willowvoice` — official Sparkle feed, signed Team ID verified.

Installomator's maintained `ikproductmanager` label was also verified in
DEBUG=2 mode and is now included in the personal vendor-app setup. The
`outputhub` label was intentionally not used: its current recipe requires a
runtime download URL and the vendor exposes only an account/landing-page flow,
not a stable direct installer URL.

Raycast Beta remains manual because it exposes no stable public beta feed;
Installomator's `raycast` label targets stable Raycast.

## Manual/Apple or special cases

Keep 1Password for Safari, Logic Pro, djay Pro, Samplism Lite, Tonebridge,
forScore, and other Apple App Store software in the MAS section. Hardware
drivers and utilities such as Insta360 Link Controller, Fireface USB Settings,
T-1 Config, OXI tools, and controller configurators require interactive system
permissions and should not be silently installed by the base bootstrap.

## Verification

```bash
ruby -ryaml -e 'YAML.load_file(".chezmoidata/packages.yaml")'
brew info --cask <each-added-cask>
chezmoi diff
```
