#!/usr/bin/env bash
# DevForge Root Bootstrap Script
set -euo pipefail

# Repo root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helpers
source "${REPO_ROOT}/scripts/logger.sh"
source "${REPO_ROOT}/scripts/utils.sh"

SUDO_PID=""

# Cleanup background sudo session
cleanup() {
    if [[ -n "${SUDO_PID:-}" ]]; then
        kill "$SUDO_PID" &>/dev/null || true
    fi
}
trap cleanup EXIT

# Error trap
error_handler() {
    local exit_code=$?
    local line_number=$1
    log_error "----------------------------------------------------------"
    log_error "FATAL: Installation failed on line ${line_number} of bootstrap.sh"
    log_error "Exit Code: ${exit_code}"
    log_error "Detailed log file is available at: ${REPO_ROOT}/install.log"
    log_error "Please review the errors above or in the log file to troubleshoot."
    log_error "----------------------------------------------------------"
    cleanup
    exit "${exit_code}"
}
trap 'error_handler $LINENO' ERR

log_info "=========================================================="
log_info "              DEVFORGE BOOTSTRAP WORKSPACE                "
log_info "=========================================================="

# OS checks
OS_TYPE="$(uname -s)"

if [[ "$OS_TYPE" == *"MINGW"* || "$OS_TYPE" == *"MSYS"* || "$OS_TYPE" == *"CYGWIN"* ]]; then
    log_error "Native Windows (Git Bash/MSYS/Cygwin) detected."
    log_error "DevForge Version 1 is target-optimized for Windows WSL (Windows Subsystem for Linux)."
    log_error "Please follow the WSL setup guide in: docs/wsl-setup.md"
    log_error "Quick Steps:"
    log_error "  1. Enable WSL in PowerShell Admin: 'wsl --install'"
    log_error "  2. Restart Windows, set up your Linux username/password."
    log_error "  3. Open WSL, clone this repository inside it, and run ./bootstrap.sh again."
    exit 1
fi

if [[ "$OS_TYPE" != "Linux" && "$OS_TYPE" != "Darwin" ]]; then
    log_error "Unsupported OS type: ${OS_TYPE}."
    log_error "DevForge bash scripts support Linux (including WSL) and macOS."
    exit 1
fi

if is_wsl; then
    log_info "Running inside Windows Subsystem for Linux (WSL)."
else
    log_warn "You are running on a non-WSL environment (${OS_TYPE})."
fi

# macOS Homebrew setup
if [[ "$OS_TYPE" == "Darwin" ]]; then
    log_info "macOS detected. Verifying Homebrew installation..."
    if ! command_exists brew; then
        log_info "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            append_to_shell_profile 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
            append_to_shell_profile 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        fi
    else
        log_info "Homebrew is already installed."
    fi

    # Ensure brew is loaded
    if ! command_exists brew; then
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
fi

# Cache sudo password
log_info "Requesting sudo permissions upfront to avoid repeated password prompts..."
if sudo -v; then
    # Refresh sudo credentials loop
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
    SUDO_PID=$!
    log_info "Sudo session credential caching initialized successfully."
else
    log_warn "Sudo authorization failed. The installation will continue, but individual steps may ask for password."
fi

# Check installer prerequisites
log_info "Checking installer pre-requisites..."
missing_deps=()
for cmd in curl git unzip; do
    if ! command_exists "$cmd"; then
        missing_deps+=("$cmd")
    fi
done

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_warn "Missing required base dependencies: ${missing_deps[*]}"
    if command_exists apt-get; then
        log_info "Attempting to install missing dependencies via apt-get..."
        sudo apt-get update -qq && sudo apt-get install -y -qq "${missing_deps[@]}" || {
            log_error "Failed to install dependencies automatically. Please run: sudo apt install ${missing_deps[*]}"
            exit 1
        }
    elif command_exists brew; then
        log_info "Attempting to install missing dependencies via Homebrew..."
        brew install "${missing_deps[@]}" || {
            log_error "Failed to install dependencies automatically. Please run: brew install ${missing_deps[*]}"
            exit 1
        }
    else
        log_error "No supported package manager (apt-get or brew) found. Please install: ${missing_deps[*]}"
        exit 1
    fi
else
    log_info "All core installer dependencies (curl, git, unzip) are present."
fi

# Create dev directories if workspace is missing
if [[ ! -d "$HOME/workspace" ]]; then
    log_info "Initializing developer directory structure under ~/workspace..."
    mkdir -p "$HOME/workspace/personal"
    mkdir -p "$HOME/workspace/work"
    mkdir -p "$HOME/workspace/sandbox"
    log_info "Workspace folders initialized: ~/workspace/{personal, work, sandbox}."
else
    log_info "Workspace folder already exists at ~/workspace. Skipping folder structure creation."
fi

# Configure Git credentials
default_name="Developer"
default_email="developer@example.com"

# Check if already present in devforge-output.json first
existing_name=""
existing_email=""
OUT_JSON="${REPO_ROOT}/devforge-output.json"

if [[ -f "$OUT_JSON" ]]; then
    existing_name=$(grep '"git_user_name":' "$OUT_JSON" | head -n 1 | sed -E 's/.*"git_user_name":\s*"([^"]*)".*/\1/' || echo "")
    existing_email=$(grep '"git_user_email":' "$OUT_JSON" | head -n 1 | sed -E 's/.*"git_user_email":\s*"([^"]*)".*/\1/' || echo "")
fi

# Fallback to global git config if still empty
if [[ -z "$existing_name" ]]; then
    existing_name=$(git config --global user.name || echo "")
fi
if [[ -z "$existing_email" ]]; then
    existing_email=$(git config --global user.email || echo "")
fi

if [[ -n "$existing_name" && -n "$existing_email" ]]; then
    log_info "Git credentials are already configured. Skipping configuration prompts."
    export GIT_USER_NAME="$existing_name"
    export GIT_USER_EMAIL="$existing_email"
else
    if [[ "${AUTO_YES:-false}" != "true" ]]; then
        echo "=========================================================="
        echo "            GIT CREDENTIALS CONFIGURATION"
        echo "=========================================================="
        read -rp "Enter global Git user name [$default_name]: " input_name
        read -rp "Enter global Git user email [$default_email]: " input_email
        echo "=========================================================="
        
        # Resolve custom inputs or fall back to system configs silently
        if [[ -n "$input_name" ]]; then
            export GIT_USER_NAME="$input_name"
        else
            export GIT_USER_NAME="${existing_name:-$default_name}"
        fi

        if [[ -n "$input_email" ]]; then
            export GIT_USER_EMAIL="$input_email"
        else
            export GIT_USER_EMAIL="${existing_email:-$default_email}"
        fi
    else
        export GIT_USER_NAME="${existing_name:-$default_name}"
        export GIT_USER_EMAIL="${existing_email:-$default_email}"
    fi
fi

# Run dispatcher
log_info "Invoking installer dispatcher..."
bash "${REPO_ROOT}/scripts/install.sh"

# Set Zsh as default shell
if command_exists zsh; then
    current_shell=$(basename "$SHELL")
    if [[ "$current_shell" != "zsh" ]]; then
        log_info "Configuring Zsh as the default shell..."
        zsh_path=$(which zsh)
        sudo chsh -s "$zsh_path" "$USER" || log_warn "Failed to change shell to Zsh automatically."
    else
        log_info "Zsh is already the default shell."
    fi
fi

# Run diagnostics verification
bash "${REPO_ROOT}/scripts/verify.sh"

log_info "=========================================================="
log_info "       DEVFORGE BOOTSTRAP WORKSPACE SETUP COMPLETED       "
log_info "=========================================================="
log_info "Installation details logged to: ${REPO_ROOT}/install.log"
log_info "Please restart your terminal session or reload your shell profile to apply changes."
