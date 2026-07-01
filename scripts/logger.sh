#!/usr/bin/env bash
# DevForge Logging Library
set -euo pipefail

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Setup log path
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE_PATH="${REPO_ROOT}/${LOG_FILE:-install.log}"

# Ensure directory exists
mkdir -p "$(dirname "${LOG_FILE_PATH}")"

# Format time
log_time() {
    date "+%Y-%m-%d %H:%M:%S"
}

log_info() {
    local msg="$1"
    echo -e "${GREEN}[INFO] $(log_time) - ${msg}${NC}"
    echo "[INFO] $(log_time) - ${msg}" >> "${LOG_FILE_PATH}"
}

log_warn() {
    local msg="$1"
    echo -e "${YELLOW}[WARN] $(log_time) - ${msg}${NC}"
    echo "[WARN] $(log_time) - ${msg}" >> "${LOG_FILE_PATH}"
}

log_error() {
    local msg="$1"
    echo -e "${RED}[ERROR] $(log_time) - ${msg}${NC}" >&2
    echo "[ERROR] $(log_time) - ${msg}" >> "${LOG_FILE_PATH}"
}

log_debug() {
    local msg="$1"
    # Log debug if enabled
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG] $(log_time) - ${msg}${NC}"
    fi
    echo "[DEBUG] $(log_time) - ${msg}" >> "${LOG_FILE_PATH}"
}
export -f log_info log_warn log_error log_debug log_time
