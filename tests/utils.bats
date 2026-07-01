#!/usr/bin/env bats
# DevForge Utilities BATS Unit Tests

setup() {
    # Stub logger functions
    log_info() { :; }
    log_warn() { :; }
    log_error() { :; }
    log_debug() { :; }
    export -f log_info log_warn log_error log_debug

    # Source script under test
    source ./scripts/utils.sh

    # Create temporary dependency file in workspace
    mkdir -p ./tests/tmp
    cat << 'EOF' > ./tests/tmp/mock_packages.txt
# Core dependency
package-alpha
  
# Tool modules
package-beta
package-gamma # inline comments
EOF
}

teardown() {
    # Cleanup temporary test files
    rm -rf ./tests/tmp
}

@test "command_exists returns success for existing standard commands" {
    run command_exists ls
    [ "$status" -eq 0 ]
    
    run command_exists grep
    [ "$status" -eq 0 ]
}

@test "command_exists returns failure for nonexistent commands" {
    run command_exists nonexistent-cli-tool-xyz-123
    [ "$status" -ne 0 ]
}

@test "read_dependency_file filters out comments and empty lines" {
    run read_dependency_file "./tests/tmp/mock_packages.txt"
    [ "$status" -eq 0 ]
    [ "$output" = "package-alpha package-beta package-gamma" ]
}

@test "is_wsl returns standard exit code status" {
    run is_wsl
    # Exit code should be either 0 (is WSL) or 1 (is not WSL)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}
