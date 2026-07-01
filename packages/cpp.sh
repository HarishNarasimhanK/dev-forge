#!/usr/bin/env bash
# DevForge C/C++ Compiler Toolchain Installer (idempotent)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing C/C++ compiler toolchain installation..."

install_linux() {
    log_info "Installing C/C++ toolchain (Linux/WSL method)..."
    if command_exists gcc && command_exists g++ && command_exists make && command_exists cmake; then
        log_info "C/C++ compilers (gcc, g++, make, cmake) are already installed. Version: $(gcc --version | head -n 1)"
    else
        log_info "Installing C/C++ compilers and build tools..."
        if command_exists apt-get; then
            sudo apt-get update -qq
            sudo apt-get install -y -qq build-essential cmake g++ gcc make gdb || log_warn "apt-get install for C/C++ toolchain returned errors. Trying to continue..."
        else
            log_warn "apt-get not found. Unsupported Linux distribution for automated C/C++ installation."
        fi
    fi
}

install_macos() {
    log_info "Installing C/C++ toolchain via Homebrew (macOS method)..."
    if ! xcode-select -p &>/dev/null; then
        log_info "Command Line Tools not found. Installing..."
        xcode-select --install || log_warn "xcode-select --install failed or was already queued. Please complete manually."
    fi

    if ! brew list cmake &>/dev/null; then
        log_info "Installing cmake via Homebrew..."
        brew install cmake
    else
        log_info "CMake is already installed."
    fi

    if ! brew list gcc &>/dev/null; then
        log_info "Installing gcc via Homebrew..."
        brew install gcc
    else
        log_info "GCC compiler is already installed."
    fi
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for C/C++ installation: $OS_TYPE"; exit 1 ;;
esac

log_info "C/C++ compiler toolchain installation completed."
