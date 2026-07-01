#!/usr/bin/env bash
# DevForge Python Installer (idempotent using Astral uv)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing Python installation..."

install_linux() {
    log_info "Installing uv on Linux/WSL..."
    export PATH="$HOME/.local/bin:$PATH"
    append_to_shell_profile 'export PATH="$HOME/.local/bin:$PATH"'

    if ! command_exists uv; then
        log_info "Astral uv is not found. Installing..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        log_info "Astral uv already installed. Updating..."
        uv self update || log_warn "Could not update uv. Continuing..."
    fi
}

install_macos() {
    log_info "Installing uv on macOS via Homebrew..."
    if ! brew list uv &>/dev/null; then
        log_info "Installing uv via Homebrew..."
        brew install uv
    else
        log_info "Astral uv already installed via Homebrew. Upgrading..."
        brew upgrade uv || log_warn "Could not upgrade uv via Homebrew. Continuing..."
    fi
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for Python installation: $OS_TYPE"; exit 1 ;;
esac

# Target Python version
TARGET_VER="${PYTHON_VERSION:-"3.13"}"

if uv python list | grep -q "cpython-${TARGET_VER}-" &>/dev/null; then
    log_info "Python ${TARGET_VER} is already installed via uv. Skipping."
else
    log_info "Installing Python ${TARGET_VER} via uv..."
    uv python install "${TARGET_VER}"
fi

# Install default packages
if [[ "${INSTALL_LANG_LIBS:-false}" == "true" ]]; then
    dep_file="${PACKAGES_DIR}/../configs/python_requirements.txt"
    log_info "Reading Python dependencies from: ${dep_file}"
    py_packages=$(read_dependency_file "${dep_file}")

    if [[ -n "${py_packages}" ]]; then
        log_info "Installing default Python libraries..."
        
        # Try installing on system Python using pip/pip3 if present
        if command_exists pip3 || command_exists pip; then
            log_info "Installing libraries on system Python via pip..."
            local PIP_CMD="pip3"
            if ! command_exists pip3; then PIP_CMD="pip"; fi
            # shellcheck disable=SC2086
            $PIP_CMD install --user --break-system-packages $py_packages &>/dev/null || log_warn "System-level pip package install failed or was partially skipped."
        fi

        # Install in uv-managed environment
        log_info "Installing libraries in uv-managed Python environment..."
        # shellcheck disable=SC2086
        uv pip install --python "${TARGET_VER}" --system --break-system-packages $py_packages || log_warn "uv pip install completed with warnings/errors."
    else
        log_warn "Python dependency file was empty or missing. Skipping library installation."
    fi
fi

log_info "Python installation completed. Version: $(uv run python --version 2>&1)"
