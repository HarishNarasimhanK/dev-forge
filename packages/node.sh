#!/usr/bin/env bash
# DevForge Node.js Installer (idempotent)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing Node.js installation..."

install_linux() {
    log_info "Installing Node.js via NVM (Linux method)..."
    export NVM_DIR="$HOME/.nvm"
    set +u
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        log_info "nvm is already installed. Sourcing..."
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    else
        log_info "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    set -u

    append_to_shell_profile 'export NVM_DIR="$HOME/.nvm"'
    append_to_shell_profile '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    append_to_shell_profile '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
}

install_macos() {
    log_info "Installing Node.js via NVM (Homebrew macOS method)..."
    export NVM_DIR="$HOME/.nvm"
    mkdir -p "$NVM_DIR"

    if ! brew list nvm &>/dev/null; then
        log_info "Installing nvm via Homebrew..."
        brew install nvm
    fi

    local brew_prefix
    brew_prefix=$(brew --prefix)
    
    # Load nvm
    set +u
    # shellcheck source=/dev/null
    [ -s "${brew_prefix}/opt/nvm/nvm.sh" ] && \. "${brew_prefix}/opt/nvm/nvm.sh"
    set -u

    append_to_shell_profile 'export NVM_DIR="$HOME/.nvm"'
    append_to_shell_profile "[ -s \"${brew_prefix}/opt/nvm/nvm.sh\" ] && \\. \"${brew_prefix}/opt/nvm/nvm.sh\""
    append_to_shell_profile "[ -s \"${brew_prefix}/opt/nvm/etc/bash_completion.d/nvm\" ] && \\. \"${brew_prefix}/opt/nvm/etc/bash_completion.d/nvm\""
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for Node installation: $OS_TYPE"; exit 1 ;;
esac

# Install Node version
TARGET_VER="${NODE_VERSION:-"--lts"}"

set +u
# Normalize version for NVM checks
check_ver="$TARGET_VER"
if [[ "$check_ver" == "--lts" ]]; then
    check_ver="lts/*"
fi

if [[ "$(nvm version "$check_ver" 2>/dev/null || echo "N/A")" != "N/A" ]]; then
    log_info "Node.js $TARGET_VER is already installed. Skipping install."
    nvm use "$check_ver"
else
    log_info "Installing Node.js $TARGET_VER..."
    nvm install "$TARGET_VER"
    nvm alias default "$TARGET_VER"
    nvm use default
fi

# Upgrade npm
log_info "Upgrading global npm..."
nvm install-latest-npm || log_warn "Could not upgrade global npm, skipping."
set -u

# Install default packages
if [[ "${INSTALL_LANG_LIBS:-false}" == "true" ]]; then
    dep_file="${PACKAGES_DIR}/../configs/npm_packages.txt"
    log_info "Reading NPM dependencies from: ${dep_file}"
    npm_packages=$(read_dependency_file "${dep_file}")

    if [[ -n "${npm_packages}" ]]; then
        log_info "Installing default global Node packages..."
        # shellcheck disable=SC2086
        npm install -g $npm_packages || log_warn "Global npm package installation completed with warnings/errors."
    else
        log_warn "NPM dependency file was empty or missing. Skipping package installation."
    fi
fi

log_info "Node.js installation completed. Version: $(node -v)"
