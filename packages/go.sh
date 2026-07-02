#!/usr/bin/env bash
# DevForge Go Language Installer (idempotent using tarball on Linux / Homebrew on macOS)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

# Script-global temporary directory for exit trap
GO_TEMP_DIR=""
trap '[[ -n "${GO_TEMP_DIR:-}" && -d "${GO_TEMP_DIR:-}" ]] && rm -rf "${GO_TEMP_DIR}"' EXIT

log_info "Processing Go installation..."

TARGET_VER="${GO_VERSION:-"1.22.5"}"

install_linux() {
    log_info "Installing Go $TARGET_VER via official tarball (Linux method)..."
    local current_ver=""
    if command_exists go; then
        current_ver=$(go version | awk '{print $3}' | sed 's/go//')
    fi

    if [[ "$current_ver" == "$TARGET_VER" ]]; then
        log_info "Go $TARGET_VER is already installed. Skipping download."
    else
        local arch
        arch="$(uname -m)"
        local go_arch="amd64"
        if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
            go_arch="arm64"
        fi

        GO_TEMP_DIR=$(mktemp -d)

        local tar_file="go${TARGET_VER}.linux-${go_arch}.tar.gz"
        local download_url="https://go.dev/dl/${tar_file}"

        log_info "Downloading Go from $download_url..."
        curl -LsSf "$download_url" -o "${GO_TEMP_DIR}/${tar_file}"

        log_info "Removing old Go installation and extracting Go $TARGET_VER..."
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "${GO_TEMP_DIR}/${tar_file}"
        log_info "Go $TARGET_VER extracted successfully to /usr/local/go."
    fi

    export PATH="/usr/local/go/bin:$PATH"
    append_to_shell_profile 'export PATH="/usr/local/go/bin:$PATH"'
}

install_macos() {
    log_info "Installing Go via Homebrew (macOS method)..."
    if ! command_exists go; then
        log_info "Installing go via Homebrew..."
        brew install go
    else
        log_info "Go is already installed. Upgrading via Homebrew..."
        brew upgrade go || log_warn "Could not upgrade Go via Homebrew. Continuing..."
    fi
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for Go installation: $OS_TYPE"; exit 1 ;;
esac

# Configure GOPATH
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
append_to_shell_profile 'export GOPATH="$HOME/go"'
append_to_shell_profile 'export PATH="$GOPATH/bin:$PATH"'

# Install default tools
if [[ "${INSTALL_LANG_LIBS:-false}" == "true" ]]; then
    dep_file="${PACKAGES_DIR}/../configs/go_packages.txt"
    log_info "Reading Go dependencies from: ${dep_file}"
    go_packages=$(read_dependency_file "${dep_file}")

    if [[ -n "${go_packages}" ]]; then
        log_info "Installing default Go environment packages..."
        mkdir -p "$GOPATH/bin"
        for pkg in $go_packages; do
            log_info "Running: go install $pkg..."
            go install "$pkg" || log_warn "Go installation failed for: $pkg"
        done
    else
        log_warn "Go dependency file was empty or missing. Skipping package installation."
    fi
fi

log_info "Go installation process completed. Version: $(go version)"
