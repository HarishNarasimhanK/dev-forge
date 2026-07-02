#!/usr/bin/env bash
# DevForge Test Runner & Static Linter orchestrator
set -euo pipefail

# Script paths
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPTS_DIR}/.." && pwd)"

# Source logger
source "${SCRIPTS_DIR}/logger.sh"
source "${SCRIPTS_DIR}/utils.sh"

log_info "=========================================================="
log_info "              STARTING DEVFORGE TEST RUNNER               "
log_info "=========================================================="

cd "${REPO_ROOT}"

# 1. Static Linting Checks (ShellCheck)
if command_exists shellcheck; then
    log_info "Running ShellCheck static linter..."
    # shellcheck disable=SC2046
    if shellcheck --exclude=SC1091,SC2016,SC2015,SC2035,SC2086 bootstrap.sh scripts/*.sh packages/*.sh; then
        log_info "✔ ShellCheck completed: No lint warnings found."
    else
        log_error "✘ ShellCheck failed. Please correct lint errors above."
        exit 1
    fi
else
    log_warn "ShellCheck is not installed. Skipping static linting."
    log_warn "Install it via: sudo apt install shellcheck (Linux) or brew install shellcheck (macOS)"
fi

# 2. Automated Unit Tests (BATS)
if command_exists bats; then
    log_info "Running BATS unit tests..."
    if bats tests/; then
        log_info "✔ BATS tests completed: All tests passed."
    else
        log_error "✘ BATS tests failed. Please inspect test errors above."
        exit 1
    fi
else
    log_warn "BATS is not installed. Skipping unit tests."
    log_warn "Install it via: sudo apt install bats (Linux) or brew install bats-core (macOS)"
fi

log_info "=========================================================="
log_info "              DEVFORGE TEST RUN COMPLETED                 "
log_info "=========================================================="
