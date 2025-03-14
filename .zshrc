# Check if brew-wrap is installed
if [[ -f $(brew --prefix)/etc/brew-wrap ]]; then
  source $(brew --prefix)/etc/brew-wrap

  # Call update script after Brewfile changes
  _post_brewfile_update() {
    echo "Updating packages.yaml..."
    ~/.local/bin/my-scripts/update-packages-yaml.ts
  }
fi

# Set placeholder environment variables
export HASS_SERVER=http://homeassistant.local:8123
