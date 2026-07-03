# DevForge Features

DevForge is a cross-platform, idempotent workstation bootstrapper that provisions a fully configured developer environment in a single command. Below is a complete catalog of all capabilities included in the current release.

---

## Core Architecture

| Feature | Detail |
|---|---|
| **Single-command bootstrap** | Run `./dforge init` or `./bootstrap.sh` to provision the full workstation |
| **Idempotent execution** | Safely re-run at any time — already-installed tools and configurations are detected and skipped |
| **OS-dispatch architecture** | Separate `install_linux()` and `install_macos()` functions per package script, routed via `uname` case blocks |
| **Config-driven toggles** | All features can be enabled or disabled via [`configs/default.env`](../configs/default.env) without touching script logic |
| **Sudo caching** | Prompts once for password at startup; background loop keeps credentials active throughout installation |
| **WSL detection** | Automatically detects Windows Subsystem for Linux and adjusts behavior accordingly |

---

## Programming Runtimes

| Runtime | Manager | Toggle |
|---|---|---|
| **Node.js** | NVM (nvm-sh) | `INSTALL_NODE` |
| **Python** | Astral uv | `INSTALL_PYTHON` |
| **Java** | SDKMAN! | `INSTALL_JAVA` |
| **Rust** | Rustup | `INSTALL_RUST` |
| **Go** | Official tar.gz / Homebrew | `INSTALL_GO` |
| **C/C++** | GCC + build-essential | `INSTALL_CPP` |

Version of each runtime is configurable via `configs/default.env` (e.g. `JAVA_VERSION`, `GO_VERSION`).

---

## Cloud & DevOps Tooling

| Tool | Toggle |
|---|---|
| **AWS CLI v2** | `INSTALL_AWS` |
| **Azure CLI** | `INSTALL_AZURE_CLI` |
| **Google Cloud CLI** | `INSTALL_GCLOUD_CLI` |
| **Lazygit** | `INSTALL_LAZYGIT` |
| **Git Delta** | `INSTALL_LAZYGIT` |
| **GitHub CLI** | `INSTALL_DEV_TOOLS` |

---

## AI Developer CLIs

| Tool | Description |
|---|---|
| **Claude Code** | Anthropic AI coding assistant CLI |
| **Gemini CLI** | Google Gemini coding assistant CLI |
| **Codex CLI** | OpenAI Codex coding assistant CLI |

Toggle: `INSTALL_AI_CLIS`

---

## Shell Environment

| Feature | Detail |
|---|---|
| **Zsh as default shell** | Detected, installed, and set via `chsh` non-interactively |
| **Starship prompt** | Deployed with curated [`configs/dotfiles/starship.toml`](../configs/dotfiles/starship.toml) |
| **Zoxide** | Smart `cd` replacement with history-based frecency |
| **Fzf** | Fuzzy finder with shell integrations |
| **Dotfile safety** | Existing `~/.zshrc`, `~/.tmux.conf`, and `~/.config/starship.toml` are **never overwritten** |
| **Shell profile appending** | Zoxide and Starship hooks are appended to `~/.zshrc` and `~/.bashrc` only if not already present |
| **Alias toolkit** | `cat` → `bat`, `ls` → `eza`, git shorthand macros (`gc`, `gp`, `gst`) |
| **History configuration** | 100,000 command history with deduplication, timestamps, and session sharing |

Toggle: `INSTALL_DEV_TOOLS`

---

## Developer Utilities

| Tool | Description |
|---|---|
| **Tmux** | Terminal multiplexer with custom key bindings and status bar |
| **Ripgrep** (`rg`) | Ultra-fast recursive code search |
| **Fd** | `find` replacement with smart defaults |
| **Bat** | `cat` replacement with syntax highlighting |
| **Eza** | `ls` replacement with icons and Git integration |
| **Jq** | JSON command-line processor |
| **Tree** | Directory structure viewer |
| **Htop / Btop** | Interactive system process monitors |
| **Fastfetch** | System information display |
| **Make / CMake** | Build system tooling |
| **Wl-clipboard / Xclip** | System clipboard integration utilities (Linux/WSL) |

Toggle: `INSTALL_DEV_TOOLS`

---

## Git & SSH Configuration

| Feature | Detail |
|---|---|
| **Global Git credentials** | Configures `user.name` and `user.email` interactively on first run |
| **Credentials caching** | Reads from `devforge-output.json` on re-runs to skip prompts |
| **SSH key generation** | Generates Ed25519 key pair at `~/.ssh/id_ed25519` (skipped if already exists) |
| **SSH config auto-setup** | Configures `~/.ssh/config` with `AddKeysToAgent` and `IdentityFile` |
| **Output credentials file** | Saves git username, email, and public SSH key to local `devforge-output.json` |

Toggle: `INSTALL_GIT_SSH`

---

## Diagnostics & Verification

| Feature | Detail |
|---|---|
| **`dforge doctor`** | Runs [`scripts/verify.sh`](../scripts/verify.sh) — colored console status report for all runtimes, CLIs, and dotfiles |
| **Automatic post-install check** | `verify.sh` is automatically triggered at the end of every `dforge init` run |
| **Version reporting** | Exact installed versions are queried and displayed for each tool |
| **Disabled flag awareness** | Tools toggled off in `default.env` are shown as `[-] Disabled` rather than `[✘] Failed` |

---

## Testing & Code Quality

| Feature | Detail |
|---|---|
| **`dforge test`** | Runs [`scripts/test.sh`](../scripts/test.sh) — executes ShellCheck and BATS in a single command |
| **ShellCheck** | Static linter for all `.sh` files in the repository |
| **BATS unit tests** | Automated unit tests for core utility functions in [`tests/utils.bats`](../tests/utils.bats) |
| **Auto-installed** | `shellcheck` and `bats` are included in the `INSTALL_DEV_TOOLS` apt package list |

---

## `dforge` Command-Line Interface

| Command | Description |
|---|---|
| `dforge init` | Runs full workstation bootstrap |
| `dforge install` | Runs package installer dispatcher only |
| `dforge doctor` | Prints environment diagnostics report |
| `dforge test` | Executes ShellCheck linter + BATS unit tests |
| `dforge update` | Pulls latest changes from the repository and re-runs installer |
| `dforge version` | Prints CLI version info |
| `dforge help` | Displays all available commands |

The `dforge` binary is automatically symlinked to `~/.local/bin/dforge` during dev-tools installation, enabling global execution from any directory.

---

## Workspace Structure

| Feature | Detail |
|---|---|
| **Workspace initialization** | Creates `~/workspace/{personal,work,sandbox}` if `~/workspace` does not already exist |
| **Workspace idempotency** | If `~/workspace` exists, directory creation is skipped to protect your existing structure |
