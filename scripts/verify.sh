#!/usr/bin/env bash
# DevForge Diagnostic Verification Doctor
set -euo pipefail

# Script paths
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPTS_DIR}/.." && pwd)"

# Source helpers
source "${SCRIPTS_DIR}/logger.sh"
source "${SCRIPTS_DIR}/utils.sh"

# Default config path
CONFIG_PATH="${REPO_ROOT}/configs/default.env"
load_config "${CONFIG_PATH}"

# Ensure runtime-specific paths are visible to the verifier
# (shell profile may not be sourced when verify runs as a subprocess)
export PATH="/usr/local/go/bin:${HOME}/go/bin:${HOME}/.cargo/bin:${HOME}/.local/bin:${PATH}"

# Output color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info "=========================================================="
log_info "              DEVFORGE DIAGNOSTIC REPORT                  "
log_info "=========================================================="

check_item() {
    local name="$1"
    local cmd="$2"
    local ver_cmd="$3"
    local install_flag="$4"
    
    if command_exists "$cmd"; then
        local version=""
        if [[ -n "$ver_cmd" ]]; then
            version=$(eval "$ver_cmd" 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || echo "")
            if [[ -z "$version" ]]; then
                version=$(eval "$ver_cmd" 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1 || echo "")
            fi
        fi
        
        if [[ -n "$version" ]]; then
            printf "  %-18s : [${GREEN}✔${NC}] Deployed (v%s)\n" "$name" "$version"
        else
            printf "  %-18s : [${GREEN}✔${NC}] Deployed\n" "$name"
        fi
    else
        if [[ "${install_flag:-false}" == "true" ]]; then
            printf "  %-18s : [${RED}✘${NC}] Failed\n" "$name"
        else
            printf "  %-18s : [${YELLOW}-${NC}] Disabled\n" "$name"
        fi
    fi
}

check_dotfile() {
    local name="$1"
    local file_path="$2"
    
    if [[ -f "$file_path" ]]; then
        printf "  %-18s : [${GREEN}✔${NC}] Deployed (~/%s)\n" "$name" "$(basename "$file_path")"
    else
        printf "  %-18s : [${RED}✘${NC}] Missing\n" "$name"
    fi
}

echo ""
echo "--- 1. Programming Runtimes ---"
check_item "Node.js" "node" "node -v" "${INSTALL_NODE:-false}"
check_item "Python" "uv" "uv run python --version" "${INSTALL_PYTHON:-false}"
check_item "Java" "java" "java -version" "${INSTALL_JAVA:-false}"
check_item "Rust" "rustc" "rustc --version" "${INSTALL_RUST:-false}"
check_item "Go" "go" "go version" "${INSTALL_GO:-false}"
check_item "C/C++ (GCC)" "gcc" "gcc --version" "${INSTALL_CPP:-false}"

echo ""
echo "--- 2. Command Line Utilities ---"
check_item "Git" "git" "git --version" "true"
check_item "GitHub CLI" "gh" "gh --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "AWS CLI" "aws" "aws --version" "${INSTALL_AWS:-false}"
check_item "Azure CLI" "az" "az --version" "${INSTALL_AZURE_CLI:-false}"
check_item "GCloud CLI" "gcloud" "gcloud --version" "${INSTALL_GCLOUD_CLI:-false}"
check_item "Lazygit" "lazygit" "lazygit --version" "${INSTALL_LAZYGIT:-false}"
check_item "Git Delta" "delta" "delta --version" "${INSTALL_LAZYGIT:-false}"
check_item "Tmux" "tmux" "tmux -V" "${INSTALL_DEV_TOOLS:-false}"
check_item "Zoxide" "zoxide" "zoxide --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Starship" "starship" "starship --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Fzf" "fzf" "fzf --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Ripgrep (rg)" "rg" "rg --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Fd" "fd" "fd --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Bat" "bat" "bat --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Eza" "eza" "eza --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Jq" "jq" "jq --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Tree" "tree" "tree --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Htop" "htop" "htop --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Btop" "btop" "btop --version" "${INSTALL_DEV_TOOLS:-false}"
check_item "Fastfetch" "fastfetch" "fastfetch --version" "${INSTALL_DEV_TOOLS:-false}"

echo ""
echo "--- 3. Configuration Dotfiles ---"
check_dotfile "Zsh profile" "$HOME/.zshrc"
check_dotfile "Tmux config" "$HOME/.tmux.conf"
check_dotfile "Starship layout" "$HOME/.config/starship.toml"
check_dotfile "Output credentials" "${REPO_ROOT}/devforge-output.json"

echo ""
log_info "=========================================================="
log_info "             DIAGNOSTICS CHECKS COMPLETED                 "
log_info "=========================================================="
echo ""
