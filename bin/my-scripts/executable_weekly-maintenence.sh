#!/bin/bash
#
# weekly-maintenance.sh - System maintenance script for macOS
#
# This script performs weekly maintenance tasks:
# - Updates Homebrew packages and casks
# - Updates Mac App Store applications
# - Cleans up Docker resources
# - Removes old files from Downloads folder
#
# Usage: weekly-maintenance.sh [--quiet]
#   --quiet: Run without interactive prompts

# Create log directory if it doesn't exist
LOG_DIR="$HOME/.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/maintenance-$(date +%Y-%m-%d).log"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1

# Check if running in quiet mode
QUIET=false
if [[ "$1" == "--quiet" ]]; then
  QUIET=true
fi

echo "🧹 Starting weekly maintenance on $(date)..."
echo "📝 Logging to $LOG_FILE"

# Refresh Homebrew metadata; package intent remains managed by chezmoi.
echo "📦 Updating Homebrew metadata..."
if ! brew update; then
  echo "⚠️ Warning: brew file update failed, continuing anyway..."
fi

# Check for additional cask upgrades that might not be in Brewfile
echo "📦 Checking for additional cask upgrades..."
if ! brew upgrade --cask --greedy; then
  echo "⚠️ Warning: Some casks failed to upgrade"
fi

# Update App Store apps
echo "🏪 Updating App Store apps..."
if ! mas upgrade; then
  echo "⚠️ Warning: Some App Store apps failed to upgrade"
fi

# Clean up Docker
if command -v docker &>/dev/null; then
  echo "🐳 Checking Docker status..."
  # Check if Docker is actually running before attempting cleanup
  if docker info &>/dev/null; then
    echo "🐳 Cleaning Docker..."
    docker system prune -f

    # Ask for confirmation before removing volumes
    if [[ "$QUIET" == "false" ]]; then
      read -p "Also remove all unused Docker volumes? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume prune -f
      fi
    else
      echo "🐳 Skipping Docker volume cleanup in quiet mode"
    fi
  else
    echo "🐳 Docker is installed but not running. Skipping cleanup."
  fi
else
  echo "🐳 Docker not installed, skipping cleanup"
fi

# Clean up downloads folder
echo "🗑️ Cleaning Downloads folder (files older than 30 days)..."
find ~/Downloads -mtime +30 -exec mv {} ~/.Trash \; 2>/dev/null || echo "⚠️ No old files found or error moving files"

# Remind about backups
echo "💾 Checking Time Machine backup status..."
LAST_BACKUP=$(tmutil latestbackup 2>/dev/null)
if [[ -n "$LAST_BACKUP" ]]; then
  echo "💾 Last backup: $LAST_BACKUP"
else
  echo "⚠️ No Time Machine backups found. Please ensure backups are configured."
fi

# Check disk space
echo "💽 Checking disk space..."
df -h / | awk 'NR==2 {print "Available: " $4 " of " $2 " (" $5 " used)"}'

# Maintenance complete
echo "✨ Maintenance complete at $(date)!"

# Send notification
osascript -e 'display notification "Weekly system maintenance complete" with title "Maintenance" sound name "Glass"'

exit 0
