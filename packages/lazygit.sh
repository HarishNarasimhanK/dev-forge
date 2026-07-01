#!/usr/bin/env bash
# DevForge Lazygit & Git-Delta Installer (idempotent using GitHub/apt/cargo on Linux / Homebrew on macOS)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

# Script-global temporary directory for exit trap
LAZYGIT_TEMP_DIR=""
trap '[[ -n "${LAZYGIT_TEMP_DIR:-}" && -d "${LAZYGIT_TEMP_DIR:-}" ]] && rm -rf "${LAZYGIT_TEMP_DIR}"' EXIT

log_info "Processing Lazygit and Git-Delta installation..."

install_linux() {
    log_info "Installing Lazygit and Git-Delta (Linux method)..."
    
    # 1. Install Lazygit
    if command_exists lazygit; then
        log_info "Lazygit is already installed. Version: $(lazygit --version)"
    else
        log_info "Downloading latest Lazygit release..."
        local lazygit_version
        lazygit_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        local lazygit_arch
        lazygit_arch=$(uname -m | sed -e 's/aarch64/arm64/' -e 's/x86_64/x86_64/')
        
        LAZYGIT_TEMP_DIR=$(mktemp -d)

        local tar_url="https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_Linux_${lazygit_arch}.tar.gz"
        log_info "Downloading Lazygit from $tar_url..."
        curl -LsSf "$tar_url" -o "${LAZYGIT_TEMP_DIR}/lazygit.tar.gz"
        
        log_info "Extracting and installing Lazygit..."
        tar -xf "${LAZYGIT_TEMP_DIR}/lazygit.tar.gz" -C "${LAZYGIT_TEMP_DIR}" lazygit
        sudo install "${LAZYGIT_TEMP_DIR}/lazygit" -D -t /usr/local/bin/
        log_info "Lazygit installed successfully."
    fi

    # 2. Install Git-Delta
    if command_exists delta; then
        log_info "Git-Delta is already installed. Version: $(delta --version)"
    else
        log_info "Installing Git-Delta..."
        if command_exists apt-get && sudo apt-get update -qq && sudo apt-get install -y -qq git-delta &>/dev/null; then
            log_info "Git-Delta installed via apt."
        elif command_exists cargo; then
            log_info "Apt install failed. Installing Git-Delta via Cargo..."
            cargo install git-delta
        else
            log_warn "Could not install Git-Delta (no apt package or cargo found)."
        fi
    fi
}

install_macos() {
    log_info "Installing Lazygit and Git-Delta via Homebrew (macOS method)..."
    if ! command_exists lazygit; then
        log_info "Installing lazygit via Homebrew..."
        brew install lazygit
    else
        log_info "Lazygit is already installed."
    fi

    if ! command_exists delta; then
        log_info "Installing git-delta via Homebrew..."
        brew install git-delta
    else
        log_info "Git-Delta (delta) is already installed."
    fi
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for Lazygit/Delta installation: $OS_TYPE"; exit 1 ;;
esac

# 3. Configure Git to use Delta
if command_exists delta; then
    log_info "Configuring Git to use Delta pager..."
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate "true"
    git config --global delta.light "false"
    git config --global merge.conflictstyle "zdiff3"
fi

log_info "Lazygit and Git-Delta installation/configuration completed."
