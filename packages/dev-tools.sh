#!/usr/bin/env bash
# DevForge Developer Utilities Installer (idempotent)
set -euo pipefail

# Script paths
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${PACKAGES_DIR}/../scripts/logger.sh"
source "${PACKAGES_DIR}/../scripts/utils.sh"

log_info "Processing developer tools and configurations..."

install_linux() {
    log_info "Installing developer tools (Linux/WSL method)..."
    if command_exists apt-get; then
        sudo apt-get update -qq
        
        # All required utilities
        sudo apt-get install -y -qq \
            zsh tmux zoxide fzf ripgrep fd-find jq tree wl-clipboard xclip \
            htop btop unzip zip curl wget make cmake build-essential gh bat shellcheck bats || log_warn "Some package installs failed. Continuing..."
    else
        log_warn "apt-get package manager not found. Skipping apt package installation."
    fi

    # Install starship
    if ! command_exists starship; then
        log_info "Installing Starship shell prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y || log_warn "Starship prompt installation failed."
    fi

    # Create symlinks for Ubuntu naming differences
    mkdir -p "$HOME/.local/bin"
    
    if command_exists fdfind && ! command_exists fd; then
        log_info "Creating local symlink for fd -> fdfind..."
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    fi

    if command_exists batcat && ! command_exists bat; then
        log_info "Creating local symlink for bat -> batcat..."
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    fi

    log_info "Creating global user symlink for dforge..."
    ln -sf "${PACKAGES_DIR}/../dforge" "$HOME/.local/bin/dforge"
}

install_macos() {
    log_info "Installing developer tools via Homebrew (macOS method)..."
    local brew_packages=(zsh tmux zoxide starship fzf ripgrep fd jq tree htop btop unzip zip curl wget make cmake gh bat shellcheck bats-core)
    for pkg in "${brew_packages[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            log_info "Installing $pkg via Homebrew..."
            brew install "$pkg"
        else
            log_info "$pkg is already installed."
        fi
    done

    mkdir -p "$HOME/.local/bin"
    log_info "Creating global user symlink for dforge..."
    ln -sf "${PACKAGES_DIR}/../dforge" "$HOME/.local/bin/dforge"
}

# OS-dispatch
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS_TYPE" in
    linux*) install_linux ;;
    darwin*) install_macos ;;
    *) log_error "Unsupported OS for dev-tools: $OS_TYPE"; exit 1 ;;
esac

# Deploy dotfiles
log_info "Deploying custom user configuration dotfiles..."

# Deploy zshrc configuration
if [[ -f "$HOME/.zshrc" ]]; then
    log_info "Configuration ~/.zshrc already exists. Skipping template deployment to protect your settings."
else
    if [[ -f "${PACKAGES_DIR}/../configs/dotfiles/zshrc" ]]; then
        log_info "Deploying custom starting zsh config to ~/.zshrc"
        cp "${PACKAGES_DIR}/../configs/dotfiles/zshrc" "$HOME/.zshrc"
    else
        log_error "Source zshrc config template not found!"
    fi
fi

# Deploy tmux configuration
if [[ -f "$HOME/.tmux.conf" ]]; then
    log_info "Configuration ~/.tmux.conf already exists. Skipping template deployment to protect your settings."
else
    if [[ -f "${PACKAGES_DIR}/../configs/dotfiles/tmux.conf" ]]; then
        log_info "Shipping tmux config to ~/.tmux.conf"
        cp "${PACKAGES_DIR}/../configs/dotfiles/tmux.conf" "$HOME/.tmux.conf"
    else
        log_error "Source tmux.conf not found!"
    fi
fi

# Deploy starship configuration
if [[ -f "$HOME/.config/starship.toml" ]]; then
    log_info "Configuration ~/.config/starship.toml already exists. Skipping template deployment to protect your settings."
else
    if [[ -f "${PACKAGES_DIR}/../configs/dotfiles/starship.toml" ]]; then
        mkdir -p "$HOME/.config"
        log_info "Shipping starship config to ~/.config/starship.toml"
        cp "${PACKAGES_DIR}/../configs/dotfiles/starship.toml" "$HOME/.config/starship.toml"
    else
        log_error "Source starship.toml not found!"
    fi
fi

# Bash/Zsh fallback integration
append_shell_specific_configs() {
    local profile="$1"
    if [[ -f "$profile" ]]; then
        local shell_name="bash"
        if [[ "$profile" == *".zshrc" ]]; then
            shell_name="zsh"
        fi
        
        # Append Zoxide integration line
        local zoxide_line="eval \"\$(zoxide init ${shell_name})\""
        if ! grep -Fxq "$zoxide_line" "$profile"; then
            echo -e "\n# DevForge Zoxide Jumper\n$zoxide_line" >> "$profile"
            log_info "Integrated Zoxide into $profile"
        fi

        # Append Starship integration line
        local starship_line="eval \"\$(starship init ${shell_name})\""
        if ! grep -Fxq "$starship_line" "$profile"; then
            echo -e "\n# DevForge Starship Prompt\n$starship_line" >> "$profile"
            log_info "Integrated Starship Prompt into $profile"
        fi
    fi
}

append_shell_specific_configs "$HOME/.bashrc"
append_shell_specific_configs "$HOME/.zshrc"

# Reload active tmux settings
if pgrep tmux &>/dev/null || [[ -n "${TMUX:-}" ]]; then
    log_info "Tmux is active. Reloading configuration settings..."
    tmux source-file "$HOME/.tmux.conf" || log_warn "Could not reload active tmux configuration."
fi

log_info "Developer tools and configurations installation completed."
