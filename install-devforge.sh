#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# DevForge APT Repository Setup Script
# ---------------------------------------------------------------
# This script registers the DevForge static APT repository and adds
# its signing GPG key so users can securely install devforge.

REPO_URL="https://harishnarasimhank.github.io/dev-forge"
KEY_URL="${REPO_URL}/keys/devforge-archive-keyring.gpg"

echo "Setting up DevForge APT repository..."

# 1. Download and install GPG keyring
echo "Importing repository signing key..."
sudo mkdir -p /usr/share/keyrings
curl -fsSL "$KEY_URL" | sudo gpg --dearmor -o /usr/share/keyrings/devforge-archive-keyring.gpg

# 2. Add repository source entry
echo "Adding repository entry to /etc/apt/sources.list.d/devforge.list..."
sudo tee /etc/apt/sources.list.d/devforge.list > /dev/null <<EOF
deb [signed-by=/usr/share/keyrings/devforge-archive-keyring.gpg] $REPO_URL ./
EOF

# 3. Update APT cache
echo "Updating package lists..."
sudo apt-get update -y

echo ""
echo "=========================================================="
echo "✅ DevForge repository configured successfully!"
echo "Run the following command to install the CLI:"
echo "  sudo apt install devforge"
echo "=========================================================="
