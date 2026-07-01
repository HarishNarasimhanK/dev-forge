#!/usr/bin/env bash
# DevForge AI CLIs Installer (idempotent)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing AI Coding CLIs installation..."

# Source nvm
export NVM_DIR="$HOME/.nvm"
set +u
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"
elif command_exists brew; then
    brew_prefix=$(brew --prefix)
    if [[ -s "${brew_prefix}/opt/nvm/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        source "${brew_prefix}/opt/nvm/nvm.sh"
    fi
fi
set -u

if ! command_exists npm; then
    log_error "npm command not found! Please ensure Node.js is installed before running this script."
    exit 1
fi

# 1. Claude Code
if command_exists claude; then
    log_info "Claude Code is already installed. Upgrading..."
    npm install -g @anthropic-ai/claude-code || log_warn "Claude Code upgrade failed."
else
    log_info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code || log_warn "Claude Code installation failed."
fi

# 2. Gemini CLI
if command_exists gemini; then
    log_info "Gemini CLI is already installed. Upgrading..."
    npm install -g @google/gemini-cli || log_warn "Gemini CLI upgrade failed."
else
    log_info "Installing Gemini CLI..."
    npm install -g @google/gemini-cli || log_warn "Gemini CLI installation failed."
fi

# 3. OpenAI Codex CLI
if command_exists codex; then
    log_info "Codex CLI is already installed. Upgrading..."
    npm install -g @openai/codex || log_warn "Codex CLI upgrade failed."
else
    log_info "Installing Codex CLI..."
    npm install -g @openai/codex || log_warn "Codex CLI installation failed."
fi

log_info "AI Coding CLIs installation completed."
