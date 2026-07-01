#!/usr/bin/env bash
# DevForge Azure CLI & Google Cloud CLI Installer (idempotent)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing Cloud CLI installations (Azure CLI, Google Cloud SDK)..."

install_linux() {
    # Azure CLI
    if command_exists az; then
        log_info "Azure CLI is already installed. Version: $(az --version 2>/dev/null | head -n 1). Skipping."
    else
        # Clean up any stale apt source files from previous failed installs
        # that would poison subsequent apt-get update calls in other scripts
        sudo rm -f /etc/apt/sources.list.d/azure-cli.list \
                   /etc/apt/trusted.gpg.d/microsoft.gpg 2>/dev/null || true

        log_info "Installing Azure CLI via Microsoft install script (Linux method)..."
        if curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash; then
            log_info "Azure CLI installed successfully."
        else
            log_warn "Azure CLI installation failed. Skipping."
        fi
    fi

    # Google Cloud CLI
    if command_exists gcloud; then
        log_info "Google Cloud CLI is already installed. Version: $(gcloud version 2>/dev/null | head -n 1). Skipping."
    else
        log_info "Installing Google Cloud CLI (Linux method)..."
        if command_exists apt-get; then
            curl -sLS https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/google-cloud.gpg > /dev/null
            echo "deb [signed-by=/etc/apt/trusted.gpg.d/google-cloud.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
            sudo apt-get update -qq && sudo apt-get install -y -qq google-cloud-cli || log_warn "Google Cloud CLI installation failed. Skipping."
        else
            log_warn "apt-get not found. Skipping Google Cloud CLI installation."
        fi
    fi
}

install_macos() {
    # Azure CLI
    if command_exists az; then
        log_info "Azure CLI is already installed. Skipping."
    else
        log_info "Installing Azure CLI via Homebrew (macOS method)..."
        brew install azure-cli || log_warn "Azure CLI installation failed. Skipping."
    fi

    # Google Cloud CLI
    if command_exists gcloud; then
        log_info "Google Cloud CLI is already installed. Skipping."
    else
        log_info "Installing Google Cloud CLI via Homebrew (macOS method)..."
        brew install google-cloud-sdk || log_warn "Google Cloud CLI installation failed. Skipping."
    fi
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for Cloud CLI installation: $OS_TYPE"; exit 1 ;;
esac

log_info "Cloud CLI installation process completed."
