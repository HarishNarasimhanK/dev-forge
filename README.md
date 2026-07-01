# DevForge

> A cross-platform, idempotent workstation bootstrapper that provisions a complete developer environment in a single command.

Target-optimized for **Windows WSL2 (Ubuntu)** · Extensible to **macOS (Homebrew)**

---

## Architecture

![DevForge HLD Architecture](assets/devforge_hld.png)

---

## 🚀 Quick Start

> [!IMPORTANT]
> **Windows Users**: DevForge runs inside WSL2 (Windows Subsystem for Linux). If you do not have WSL2 set up yet, please follow the step-by-step [WSL Setup Guide](docs/wsl-setup.md) first.

### Step 1: Ensure Git is Installed

**Ubuntu / WSL**:
```bash
sudo apt update && sudo apt install -y git
```
**macOS**:
```bash
xcode-select --install
```

### Step 2: Clone and Bootstrap

```bash
git clone https://github.com/your-username/dev-forge.git
cd dev-forge
./dforge init
```

That's it. DevForge will provision your full workstation and print a diagnostic summary when done.

---

## 🖥️ `dforge` CLI

After bootstrapping, the `dforge` command is globally available from any directory.

| Command | Description |
|---|---|
| `dforge init` | Run the full workstation bootstrap |
| `dforge install` | Run the package installer dispatcher only |
| `dforge doctor` | Print a live environment diagnostics report |
| `dforge test` | Run ShellCheck linter + BATS unit tests |
| `dforge update` | Pull the latest repository changes and re-sync packages |
| `dforge version` | Display the DevForge CLI version |
| `dforge help` | Display all available commands |

**Examples**:
```bash
# Verify what's installed on your machine
dforge doctor

# Check for DevForge version
dforge version

# Re-run installer after editing configs/default.env
dforge install

# Run code quality checks
dforge test
```

---

## 🛠️ What Gets Installed

| Category | Tools |
|---|---|
| **Runtimes** | Node.js (NVM), Python (uv), Java (SDKMAN!), Rust (Rustup), Go, C/C++ (GCC) |
| **Cloud CLIs** | AWS CLI v2, Azure CLI, Google Cloud CLI |
| **Developer Utilities** | Git, GitHub CLI, Lazygit, Git Delta, Tmux, Zoxide, Starship, Fzf, Ripgrep, Fd, Bat, Eza, Jq, Btop, Fastfetch |
| **AI Coding CLIs** | Claude Code, Gemini CLI, OpenAI Codex |
| **Shell Environment** | Zsh (default), Starship prompt, custom aliases, Fzf integrations, 100k history |

> See [docs/features.md](docs/features.md) for the complete feature catalog.

---

## ⚙️ Customization

Edit configuration files in the `configs/` directory before running the installer:

| File | Purpose |
|---|---|
| [`configs/default.env`](configs/default.env) | Feature toggles and version pinning |
| [`configs/python_requirements.txt`](configs/python_requirements.txt) | Python libraries to install globally |
| [`configs/npm_packages.txt`](configs/npm_packages.txt) | Global NPM packages |
| [`configs/go_packages.txt`](configs/go_packages.txt) | Go binaries to install |
| [`configs/cargo_packages.txt`](configs/cargo_packages.txt) | Rust crates to install |
| [`configs/dotfiles/`](configs/dotfiles/) | Zshrc, Tmux config, and Starship theme |

To disable a feature, open `configs/default.env` and set the toggle to `false`:
```bash
INSTALL_JAVA=false
INSTALL_GCLOUD_CLI=false
```

---

## 📚 Documentation

| Guide | Description |
|---|---|
| [WSL Setup](docs/wsl-setup.md) | How to install and configure WSL2 on Windows |
| [VS Code Setup](docs/vscode-setup.md) | VS Code + WSL integration and recommended extensions |
| [Features](docs/features.md) | Complete catalog of all DevForge capabilities |

