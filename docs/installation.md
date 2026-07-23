# Installation Guide

This repository separates dotfile convergence from full workstation
provisioning. `chezmoi apply` is safe to run frequently; `setup-mac` is the
explicit, resumable installer for applications and machine-level packages.

## Fresh Mac

Install the dotfiles and bootstrap tools:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/mikecfisher/dotfiles.git
```

Initialization prompts for:

- machine type: `default` or `personal`;
- whether the Mac is a work machine;
- whether 1Password-backed templates are enabled;
- Git name and email.

The first apply installs Homebrew when necessary, installs and trusts the configured taps,
and installs only the small bootstrap formula set required by shell/editor
setup. It also provisions the pinned Node, pnpm, Yarn, uv, and Bun toolchains;
global development CLIs; Chrome for Testing for `agent-browser`; Pi; and the
LazyVim starter. Homebrew metadata is refreshed at most once every 24 hours.
This makes the first apply intentionally more substantial than routine applies.

## Provision the Workstation

Run the complete installer from an interactive terminal:

```bash
setup-mac
```

Phases run in this order:

1. `preflight` — verify macOS, Command Line Tools, Homebrew, disk space, and taps;
2. `core` — install common and profile-specific formulae;
3. `gui` — install standard nonprivileged casks;
4. `heavy` — install large applications independently with retries;
5. `privileged` — install casks that invoke administrator installers;
6. `mas` — install only missing Mac App Store IDs;
7. `vendor` — install verified vendor apps through pinned Installomator labels;
8. `verify` — report any missing automated item and run `chezmoi verify`.

Successful phase hints are stored under
`~/.local/state/dotfiles/setup-mac/<profile>/`. They automatically invalidate
when the rendered setup command or package manifest changes. A hint is never
trusted on its own: each rerun checks the current Homebrew receipt, application
bundle, App Store ID, or vendor application before skipping a phase. Verification
removes the relevant hint when it finds drift so the next run repairs it.
Mutating phases refresh their inventory after the installer exits and write a
completion hint only when the resulting machine state satisfies the manifest.

Useful commands:

```bash
setup-mac                         # Resume incomplete work
setup-mac --phase heavy           # Run one phase
setup-mac --phase verify          # Audit without installing
setup-mac --force                 # Re-evaluate completed phases
setup-mac --reset                 # Clear phase state
setup-mac --update                # Refresh Homebrew before provisioning
setup-mac --non-interactive       # Defer admin/App Store/vendor phases
```

Logs are appended to `~/.local/state/dotfiles/setup-mac/setup-mac.log`.
The final summary separates completed, verified/skipped, deferred, pending, and
failed work. Verification reports items belonging to a phase deferred in the
same run as pending rather than reclassifying them as failures. A fully
converged run exits `0`, deferred interactive work exits `20`, and an actual
independent failure exits `1`.

## Administrator and App Store Behavior

Normal `chezmoi apply` never attempts privileged casks or App Store installs.
The explicit installer inventories each phase before requesting administrator
access, so a converged rerun does not prompt for a password. Homebrew casks are
checked for both their receipt and their application bundle where applicable.
App Store apps are checked by numeric ID and only missing apps are attempted.

The TestFlight ID has a targeted repair for the partial-copy/no-receipt state
observed with `mas` 7. The installer does not install Rosetta. Intel-only apps
must be explicitly approved and added to the manifest.

## Vendor and Manual Applications

Groof, Willow Voice, and IK Product Manager are automated using a pinned
Installomator commit, a checked archive checksum, and verified labels in this
repository.

Output Hub and Raycast Beta remain manual because they do not expose stable,
public installer feeds suitable for unattended provisioning. Music and backup
applications still require their own account sign-ins, license activation, or
macOS privacy permissions after installation.

## Routine Updates

Apply repository changes without reprovisioning the workstation:

```bash
chezmoi update
```

When package intent changes, run:

```bash
setup-mac
```

If 1Password was disabled during first initialization, sign in and reinitialize
template data before applying secret-backed templates.
