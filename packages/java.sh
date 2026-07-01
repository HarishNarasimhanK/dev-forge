#!/usr/bin/env bash
# DevForge Java Installer (idempotent using SDKMAN! on Linux / Homebrew on macOS)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing Java installation..."

install_linux() {
    log_info "Installing Java via SDKMAN! (Linux method)..."
    if command_exists apt-get; then
        log_info "Installing zip/unzip dependencies for SDKMAN!..."
        sudo apt-get update -qq && sudo apt-get install -y -qq zip unzip curl || log_warn "Apt install zip/unzip failed. Continuing..."
    fi

    # Load SDKMAN
    export SDKMAN_DIR="$HOME/.sdkman"
    
    # Configure SDKMAN into non-interactive auto-answer mode
    mkdir -p "$SDKMAN_DIR/etc"
    if [[ ! -f "$SDKMAN_DIR/etc/config" ]]; then
        echo "sdkman_auto_answer=true" > "$SDKMAN_DIR/etc/config"
        echo "sdkman_selfupdate_feature=false" >> "$SDKMAN_DIR/etc/config"
    else
        if ! grep -q "sdkman_auto_answer=true" "$SDKMAN_DIR/etc/config" 2>/dev/null; then
            echo "sdkman_auto_answer=true" >> "$SDKMAN_DIR/etc/config"
        fi
    fi

    set +u
    if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
        log_info "SDKMAN! already installed. Sourcing..."
        # shellcheck source=/dev/null
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
    else
        log_info "Installing SDKMAN!..."
        curl -s "https://get.sdkman.io?rcupdate=false" | bash
        # shellcheck source=/dev/null
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
    fi
    set -u

    # Configure profiles
    append_to_shell_profile 'export SDKMAN_DIR="$HOME/.sdkman"'
    append_to_shell_profile '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"'

    local target_ver="${JAVA_VERSION:-"21.0.4-tem"}"

    # Install Java version
    set +u
    # shellcheck source=/dev/null
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    if [[ -d "$SDKMAN_DIR/candidates/java/$target_ver" ]]; then
        log_info "Java version $target_ver is already installed. Skipping install."
    else
        log_info "Installing Java $target_ver via SDKMAN!..."
        sdk install java "$target_ver"
        sdk default java "$target_ver"
    fi
    set -u
}

install_macos() {
    log_info "Installing OpenJDK via Homebrew (macOS method)..."
    
    if ! brew list openjdk@21 &>/dev/null; then
        log_info "Installing openjdk@21 via Homebrew..."
        brew install openjdk@21
    else
        log_info "OpenJDK 21 is already installed."
    fi

    # Configure OpenJDK path
    local brew_prefix
    brew_prefix=$(brew --prefix)
    
    export PATH="${brew_prefix}/opt/openjdk@21/bin:$PATH"
    append_to_shell_profile "export PATH=\"${brew_prefix}/opt/openjdk@21/bin:\$PATH\""
    
    log_info "Creating Java symlink for macOS system recognition..."
    sudo ln -sfn "${brew_prefix}/opt/openjdk@21/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk-21.jdk || log_warn "Could not create java symlink in system directory. Sudo privileges might have been denied."
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for Java installation: $OS_TYPE"; exit 1 ;;
esac

log_info "Java installation completed."
