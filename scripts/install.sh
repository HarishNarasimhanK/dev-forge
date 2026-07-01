#!/usr/bin/env bash
# DevForge Package Dispatcher/Orchestrator
set -euo pipefail

# Script paths
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPTS_DIR}/.." && pwd)"

# Source helpers
source "${SCRIPTS_DIR}/logger.sh"
source "${SCRIPTS_DIR}/utils.sh"

# Default config path
CONFIG_PATH="${REPO_ROOT}/configs/default.env"

# Load config
load_config "${CONFIG_PATH}"

log_info "Starting DevForge package installation orchestration..."

# Go to repo root
cd "${REPO_ROOT}"

# --- Runtimes ---

# 1. Node.js
if [[ "${INSTALL_NODE:-false}" == "true" ]]; then
    if [[ -f "./packages/node.sh" ]]; then
        bash "./packages/node.sh"
    else
        log_error "Node installer packages/node.sh not found!"
    fi
else
    log_debug "Node.js installation is disabled."
fi

# 2. Python
if [[ "${INSTALL_PYTHON:-false}" == "true" ]]; then
    if [[ -f "./packages/python.sh" ]]; then
        bash "./packages/python.sh"
    else
        log_error "Python installer packages/python.sh not found!"
    fi
else
    log_debug "Python installation is disabled."
fi

# 3. Java
if [[ "${INSTALL_JAVA:-false}" == "true" ]]; then
    if [[ -f "./packages/java.sh" ]]; then
        bash "./packages/java.sh"
    else
        log_error "Java installer packages/java.sh not found!"
    fi
else
    log_debug "Java installation is disabled."
fi

# 4. Go
if [[ "${INSTALL_GO:-false}" == "true" ]]; then
    if [[ -f "./packages/go.sh" ]]; then
        bash "./packages/go.sh"
    else
        log_error "Go installer packages/go.sh not found!"
    fi
else
    log_debug "Go installation is disabled."
fi

# 5. Rust
if [[ "${INSTALL_RUST:-false}" == "true" ]]; then
    if [[ -f "./packages/rust.sh" ]]; then
        bash "./packages/rust.sh"
    else
        log_error "Rust installer packages/rust.sh not found!"
    fi
else
    log_debug "Rust installation is disabled."
fi

# 6. C/C++
if [[ "${INSTALL_CPP:-false}" == "true" ]]; then
    if [[ -f "./packages/cpp.sh" ]]; then
        bash "./packages/cpp.sh"
    else
        log_error "C/C++ installer packages/cpp.sh not found!"
    fi
else
    log_debug "C/C++ installation is disabled."
fi

# --- Cloud CLIs ---

# 7. AWS CLI
if [[ "${INSTALL_AWS:-false}" == "true" ]]; then
    if [[ -f "./packages/aws.sh" ]]; then
        bash "./packages/aws.sh"
    else
        log_error "AWS installer packages/aws.sh not found!"
    fi
else
    log_debug "AWS CLI installation is disabled."
fi

# 8. Azure CLI & Google Cloud CLI
if [[ "${INSTALL_AZURE_CLI:-false}" == "true" || "${INSTALL_GCLOUD_CLI:-false}" == "true" ]]; then
    if [[ -f "./packages/cloud-clis.sh" ]]; then
        bash "./packages/cloud-clis.sh"
    else
        log_error "Cloud CLIs installer packages/cloud-clis.sh not found!"
    fi
else
    log_debug "Cloud CLI installations are disabled."
fi

# --- Developer Tooling ---

# 9. Lazygit & Delta
if [[ "${INSTALL_LAZYGIT:-false}" == "true" ]]; then
    if [[ -f "./packages/lazygit.sh" ]]; then
        bash "./packages/lazygit.sh"
    else
        log_error "Lazygit installer packages/lazygit.sh not found!"
    fi
else
    log_debug "Lazygit installation is disabled."
fi

# 10. AI Coding CLIs (requires Node/npm)
if [[ "${INSTALL_AI_CLIS:-false}" == "true" ]]; then
    if [[ -f "./packages/ai-clis.sh" ]]; then
        bash "./packages/ai-clis.sh"
    else
        log_error "AI CLIs installer packages/ai-clis.sh not found!"
    fi
else
    log_debug "AI CLIs installation is disabled."
fi

# 11. Dev Tools, Utilities & Dotfiles
if [[ "${INSTALL_DEV_TOOLS:-false}" == "true" ]]; then
    if [[ -f "./packages/dev-tools.sh" ]]; then
        bash "./packages/dev-tools.sh"
    else
        log_error "Dev tools installer packages/dev-tools.sh not found!"
    fi
else
    log_debug "Dev tools installation is disabled."
fi

# 12. Git Credentials & SSH Keys
if [[ "${INSTALL_GIT_SSH:-false}" == "true" ]]; then
    if [[ -f "./packages/git-ssh.sh" ]]; then
        bash "./packages/git-ssh.sh"
    else
        log_error "Git-SSH installer packages/git-ssh.sh not found!"
    fi
else
    log_debug "Git-SSH configuration is disabled."
fi

log_info "DevForge package orchestration completed successfully."
