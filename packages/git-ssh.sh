#!/usr/bin/env bash
# DevForge Git & SSH Installer/Orchestrator (idempotent)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing Git and SSH configuration..."

# Configure global Git settings
log_info "Configuring global Git user..."
git config --global user.name "${GIT_USER_NAME:-"Developer"}"
git config --global user.email "${GIT_USER_EMAIL:-"developer@example.com"}"

# Generate SSH keys
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    log_info "Generating new SSH key pairing (Ed25519)..."
    ssh-keygen -t ed25519 -C "${GIT_USER_EMAIL:-"developer@example.com"}" -N "" -f "$HOME/.ssh/id_ed25519"
    chmod 600 "$HOME/.ssh/id_ed25519"
    chmod 644 "$HOME/.ssh/id_ed25519.pub"
else
    log_info "Ed25519 SSH key already exists."
fi

# Configure SSH config
SSH_CONFIG="$HOME/.ssh/config"
if [[ ! -f "$SSH_CONFIG" ]]; then
    touch "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
fi

if ! grep -q "AddKeysToAgent" "$SSH_CONFIG" 2>/dev/null; then
    log_info "Configuring SSH settings to auto-load keys..."
    cat << 'EOF' >> "$SSH_CONFIG"

Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOF
fi

# Write details to local output JSON (ignored by git)
out_json="${PACKAGES_DIR}/../devforge-output.json"
public_key=""
if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    public_key=$(cat "$HOME/.ssh/id_ed25519.pub")
fi

log_info "Writing credentials summary to devforge-output.json..."
if command_exists jq; then
    jq -n \
      --arg name "${GIT_USER_NAME:-"Developer"}" \
      --arg email "${GIT_USER_EMAIL:-"developer@example.com"}" \
      --arg key "$public_key" \
      --arg note_name "The global user.name value configured for git commits on this machine." \
      --arg note_email "The global user.email value configured for git commits and used as comment metadata for SSH key generation." \
      --arg note_key "Your generated Ed25519 public SSH key. Copy and add this key to your GitHub account settings at https://github.com/settings/keys to authenticate safely." \
      '{
        git_user_name: $name,
        git_user_email: $email,
        ssh_public_key: $key,
        notes: {
          git_user_name: $note_name,
          git_user_email: $note_email,
          ssh_public_key: $note_key
        }
      }' > "$out_json"
else
    cat << EOF > "$out_json"
{
  "git_user_name": "${GIT_USER_NAME:-"Developer"}",
  "git_user_email": "${GIT_USER_EMAIL:-"developer@example.com"}",
  "ssh_public_key": "$public_key",
  "notes": {
    "git_user_name": "The global user.name value configured for git commits on this machine.",
    "git_user_email": "The global user.email value configured for git commits and used as comment metadata for SSH key generation.",
    "ssh_public_key": "Your generated Ed25519 public SSH key. Copy and add this key to your GitHub account settings at https://github.com/settings/keys to authenticate safely."
  }
}
EOF
fi

echo "=========================================================="
echo "                   YOUR PUBLIC SSH KEY                    "
echo "=========================================================="
echo "${public_key}"
echo "=========================================================="
echo "Saved locally in: devforge-output.json"
echo "Copy the key above and add it to your GitHub profile settings:"
echo "https://github.com/settings/keys"
echo "=========================================================="

log_info "Git and SSH configuration completed."

