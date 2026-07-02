#!/usr/bin/env bash
# DevForge AWS CLI v2 Installer (idempotent using zip on Linux / Homebrew on macOS)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

# Script-global temporary directory tracking for exit traps
AWS_TEMP_DIR=""
trap '[[ -n "${AWS_TEMP_DIR:-}" && -d "${AWS_TEMP_DIR:-}" ]] && rm -rf "${AWS_TEMP_DIR}"' EXIT

log_info "Processing AWS CLI v2 installation..."

install_linux() {
    log_info "Installing AWS CLI via official zip download (Linux method)..."
    if command_exists aws; then
        log_info "AWS CLI is already installed. Version: $(aws --version). Skipping installation."
        return 0
    fi

    # Architecture check
    local arch
    arch="$(uname -m)"
    local zip_file="awscliv2.zip"
    local download_url=""

    if [[ "$arch" == "x86_64" ]]; then
        download_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    elif [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
        download_url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
    else
        log_error "Unsupported architecture for AWS CLI: $arch"
        exit 1
    fi

    AWS_TEMP_DIR=$(mktemp -d)

    log_info "Downloading AWS CLI from $download_url..."
    curl -LsSf "$download_url" -o "${AWS_TEMP_DIR}/${zip_file}"

    log_info "Unzipping AWS CLI installer..."
    unzip -q "${AWS_TEMP_DIR}/${zip_file}" -d "${AWS_TEMP_DIR}"

    log_info "Running AWS CLI installer..."
    sudo "${AWS_TEMP_DIR}/aws/install"
}

install_macos() {
    log_info "Installing AWS CLI via Homebrew (macOS method)..."
    if ! command_exists aws; then
        log_info "Installing awscli via Homebrew..."
        brew install awscli
    else
        log_info "AWS CLI is already installed. Upgrading via Homebrew..."
        brew upgrade awscli || log_warn "Could not upgrade AWS CLI via Homebrew. Continuing..."
    fi
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for AWS CLI installation: $OS_TYPE"; exit 1 ;;
esac

log_info "AWS CLI installation completed. Version: $(aws --version)"
