# Package Management

`.chezmoidata/packages.yaml` is the source of truth for package intent. The
repository does not maintain or ingest a generated Brewfile: temporary
Brewfiles are rendered only while `setup-mac` runs.

## Manifest Structure

Packages are grouped by behavior rather than by whatever happened to be
installed on one machine:

- `bootstrap.brews` — minimal tools needed during the first apply;
- `common.brews` and `personal.brews` — explicitly desired formulae;
- `standard_casks` — ordinary drag-to-Applications packages;
- `heavy_casks` — large downloads installed independently with retries;
- `privileged_casks` — packages that invoke `sudo` or a macOS installer;
- `mas` — App Store applications identified by numeric ID;
- `vendor.automated` — apps handled by pinned, verified Installomator labels;
- `vendor.manual` — documented intent that cannot be safely automated.

Bootstrap/common formula overlap is intentional. Transitive dependencies should
not be added merely because `brew list` reports them; Homebrew resolves those.

## Adding or Removing Packages

Edit `.chezmoidata/packages.yaml` directly and place the item in the phase that
matches its behavior. Then validate and provision:

```bash
~/bin/my-scripts/validate-dotfiles.sh
chezmoi apply
setup-mac
```

For a faster targeted run:

```bash
setup-mac --phase core
setup-mac --phase gui
setup-mac --phase heavy
```

Do not regenerate the manifest from `brew bundle dump`. That captures
transitive dependencies and recreates a large, machine-specific snapshot.

## Updating Existing Packages

Provisioning deliberately uses `--no-upgrade`; desired presence and routine
upgrades are separate concerns. Upgrade installed packages explicitly:

```bash
brew update
brew upgrade
mas upgrade
```

Use `setup-mac --update` when provisioning should refresh Homebrew metadata
first.

The bootstrap toolchain versions live in `.chezmoidata/toolchains.yaml`. Node,
pnpm, Yarn, global npm packages, uv, Bun, `agent-browser`, and Pi are pinned so
a fresh machine does not silently receive a different toolchain from the one
validated in this repository. The uv and Bun bootstrap scripts replace an
existing mismatched version and verify the exact result. Update pins
deliberately and run the validator before applying.

## Cleanup

`setup-mac` does not uninstall packages absent from the manifest. Review cleanup
before making destructive changes:

```bash
brew bundle cleanup --file=/path/to/reviewed/Brewfile
```

The manifest validation command checks YAML, duplicate package intent, both
profiles' rendered shell syntax, removed legacy behavior, and whitespace. The
state-machine tests cover profile rejection, full-run deferral, post-install
postconditions, marker drift, tap convergence, `--update`, and password-free
converged phases. Toolchain tests exercise exact uv and Bun convergence. Set
`VALIDATE_PACKAGES=1` to install the configured taps and resolve every Homebrew
formula and cask on macOS; CI enables this fresh-runner package check.
