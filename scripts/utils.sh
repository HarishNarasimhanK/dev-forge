#!/usr/bin/env bash
# DevForge Utilities Library
set -euo pipefail

# Check if running in WSL
is_wsl() {
    if grep -qE "(Microsoft|microsoft-standard-WSL2)" /proc/version &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if CLI command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Prompt user for yes/no confirmation (respects default and AUTO_YES)
prompt_yes_no() {
    local question="$1"
    local default_val="${2:-true}"
    local auto_yes="${AUTO_YES:-false}"

    if [[ "${auto_yes}" == "true" ]]; then
        return 0
    fi

    local prompt_suffix="[Y/n]"
    if [[ "${default_val}" == "false" ]]; then
        prompt_suffix="[y/N]"
    fi

    while true; do
        read -rp "$question $prompt_suffix " yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            "")
                if [[ "${default_val}" == "true" ]]; then
                    return 0
                else
                    return 1
                fi
                ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# Append line to profile if not exists
append_to_shell_profile() {
    local line_to_add="$1"
    local profiles=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")

    for profile in "${profiles[@]}"; do
        if [[ -f "$profile" ]]; then
            if ! grep -Fxq "$line_to_add" "$profile"; then
                echo "$line_to_add" >> "$profile"
                log_debug "Appended to $profile: $line_to_add"
            fi
        fi
    done
}

# Load configuration file
load_config() {
    local config_path="$1"
    if [[ -f "$config_path" ]]; then
        log_info "Loading configuration from: ${config_path}"
        # Read and export environment assignments
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Strip comments and whitespace
            line=$(echo "$line" | sed 's/#.*//' | xargs)
            if [[ -n "$line" && "$line" == *"="* ]]; then
                local var_name="${line%%=*}"
                if [[ -z "${!var_name:-}" ]]; then
                    export "$line"
                fi
            fi
        done < "$config_path"
    else
        log_warn "Configuration file not found: ${config_path}. Using default environment variables."
    fi
}

# Read dependencies (ignoring empty lines and comments)
read_dependency_file() {
    local file_path="$1"
    local packages=()
    if [[ -f "$file_path" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Strip comments and whitespace
            line=$(echo "$line" | sed 's/#.*//' | xargs)
            if [[ -n "$line" ]]; then
                packages+=("$line")
            fi
        done < "$file_path"
    fi
    echo "${packages[@]:-}"
}

export -f is_wsl command_exists prompt_yes_no append_to_shell_profile load_config read_dependency_file
