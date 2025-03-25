# Security & Credentials

This document explains how sensitive information is handled in this dotfiles repository.

## Overview

This repository uses a security-first approach to credential management, integrating with macOS Keychain and 1Password to avoid storing sensitive information directly in configuration files.

## 1Password Integration

Secrets are accessed through 1Password CLI integration using the Chezmoi template function `onepasswordRead`.

### Setup

1. Install 1Password CLI:
   ```bash
   brew install --cask 1password/tap/1password-cli
   ```

2. Sign in to 1Password:
   ```bash
   op signin
   ```

3. Configure Chezmoi to use 1Password:
   ```toml
   [onepassword]
     command = "op"
   ```

### Usage in Templates

Secrets can be accessed in template files:

```
# Example template with 1Password integration
GITHUB_TOKEN={{ onepasswordRead "op://Private/github_token/credential" }}
```

## macOS Keychain Integration

For even faster access to frequently used API keys, the dotfiles use macOS Keychain integration.

### Shell Integration

In the fish shell configuration:

```fish
# API Keys (loaded at login; be cautious with sensitive info)
set -gx ANTHROPIC_API_KEY (timeout 2 security find-generic-password -a $USER -s "anthropic_api_key" -w 2>/dev/null)
```

In ZSH profile:

```zsh
# API Keys (loaded at login)
export ANTHROPIC_API_KEY=$(timeout 2 security find-generic-password -a ${USER} -s "anthropic_api_key" -w 2>/dev/null)
export OPENAI_API_KEY=$(timeout 2 security find-generic-password -a ${USER} -s "openai_api_key" -w 2>/dev/null)
```

### Lazy Loading

For improved performance, some credentials are lazy-loaded only when needed:

```zsh
function openai() {
  # Loads API key only when first used
  [[ "$OPENAI_API_KEY" == "needs_loading" ]] && \
    export OPENAI_API_KEY=$(get_openai_api_key)
  command openai "$@"
}
```

## Secure File Permissions

Chezmoi manages sensitive file permissions using the `private_` prefix:

- `private_dot_ssh/` - SSH configuration with proper permissions
- `private_etc/` - System configuration files with proper permissions

## Git Security

The Git configuration ensures secure credentials handling:

```
[credential]
helper = osxkeychain
```

## Adding New Credentials

### 1Password Method

1. Store the credential in 1Password
2. Use the credential in a template:
   ```
   {{ onepasswordRead "op://vault/item/field" }}
   ```

### Keychain Method

1. Add a credential to macOS Keychain:
   ```bash
   security add-generic-password -a "$USER" -s "credential_name" -w "secret_value"
   ```

2. Access the credential in a shell script:
   ```bash
   CREDENTIAL=$(security find-generic-password -a "$USER" -s "credential_name" -w)
   ```

## Best Practices

1. **Never hardcode credentials** in dotfiles
2. **Use timeout** with security commands (prevents hanging)
3. **Lazy load** credentials when possible
4. **Use short-lived tokens** where possible
5. **Verify permissions** of sensitive files (chmod 600)

## Security Checks

Before committing changes, ensure:

1. No credentials are directly embedded in files
2. Sensitive files use the `private_` prefix
3. SSH keys have proper permissions
4. API keys are accessed via Keychain or 1Password

## Common Issues

### Missing Credentials

If a credential is missing from Keychain/1Password, the system will handle it gracefully by:

1. Setting the variable to `null` or an empty string
2. Using a timeout to prevent hanging
3. Including error handling in credential-accessing functions

### 1Password Not Available

If 1Password CLI is not available, templates will fail gracefully during the `chezmoi apply` process, and you'll be prompted to install 1Password CLI.