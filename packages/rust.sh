#!/usr/bin/env bash
# DevForge Rust Installer (idempotent using rustup)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing Rust installation..."

install_linux() {
    log_info "Installing rustup via official curl script (Linux method)..."
    if ! command_exists rustup; then
        log_info "Rustup is not found. Installing..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    fi
}

install_macos() {
    log_info "Installing rustup via Homebrew (macOS method)..."
    if ! command_exists rustup; then
        if ! brew list rustup-init &>/dev/null; then
            log_info "Installing rustup-init via Homebrew..."
            brew install rustup-init
        fi
        log_info "Initializing rustup..."
        rustup-init -y --no-modify-path
    fi
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for Rust installation: $OS_TYPE"; exit 1 ;;
esac

# Configure paths
export PATH="$HOME/.cargo/bin:$PATH"
append_to_shell_profile 'export PATH="$HOME/.cargo/bin:$PATH"'
append_to_shell_profile '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'

# Install Rust toolchain
TARGET_CHANNEL="${RUST_CHANNEL:-"stable"}"
log_info "Ensuring Rust channel '$TARGET_CHANNEL' is installed..."
rustup toolchain install "$TARGET_CHANNEL"
rustup default "$TARGET_CHANNEL"

if [[ "$TARGET_CHANNEL" == "nightly" ]]; then
    log_info "Ensuring Rust stable toolchain is also installed..."
    rustup toolchain install stable
fi

# Install default packages
if [[ "${INSTALL_LANG_LIBS:-false}" == "true" ]]; then
    dep_file="${PACKAGES_DIR}/../configs/cargo_packages.txt"
    log_info "Reading Cargo dependencies from: ${dep_file}"
    cargo_packages=$(read_dependency_file "${dep_file}")

    if [[ -n "${cargo_packages}" ]]; then
        log_info "Installing default Cargo package utilities..."
        for pkg in $cargo_packages; do
            log_info "Running: cargo install $pkg..."
            cargo install "$pkg" || log_warn "Cargo installation failed for: $pkg"
        done
    else
        log_warn "Cargo dependency file was empty or missing. Skipping package installation."
    fi
fi

log_info "Rust installation completed. rustc version: $(rustc --version)"
