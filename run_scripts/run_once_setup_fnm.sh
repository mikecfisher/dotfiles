#!/bin/bash

# Install fnm using the official installation script
if ! command -v fnm &> /dev/null; then
  echo "Installing fnm..."
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

# Enable Corepack for Node.js package manager version management
if command -v node &> /dev/null; then
  echo "Enabling Corepack for package manager version management..."
  corepack enable
else
  echo "Node.js not found. Will be installed via fnm"
fi

# Install default Node.js version with Corepack enabled
echo "Installing default Node.js version..."
fnm install 22 --corepack-enabled

# Uninstall Homebrew pnpm to avoid conflicts with Corepack
if command -v brew &>/dev/null && brew list pnpm &>/dev/null; then
  echo "Uninstalling Homebrew pnpm to avoid conflicts with Corepack..."
  brew uninstall pnpm
fi

# Set up global packages with pnpm
echo "Installing global packages with pnpm..."
pnpm add -g \
  @anthropic-ai/claude-code \
  cursor-tools \
  playwright \
  turbo \
  typescript-language-server \
  typescript \
  yarn

# Prepare pnpm with Corepack
echo "Setting up pnpm with Corepack..."
corepack prepare pnpm@ --activate