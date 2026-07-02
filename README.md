# DevForge

> **Automated, friction-free developer environment provisioning.**

Target-optimized for **Windows WSL2 (Ubuntu)** and **macOS (Homebrew)**.

---

## 💡 The Problem & First Principles

Setting up a local development environment is a recurring friction point for developers. Whether you are configuring a newly bought laptop, spinning up a fresh EC2 instance, or initializing a new WSL environment:
* **Time-consuming:** Installing compiler runtimes, cloud utilities, shell prompts, and editor configs manually takes hours of copy-pasting commands.
* **Configuration Drift:** Subtle differences in command-line arguments, packages, or versions cause unexpected bugs and "works on my machine" issues across developers.
* **Fragile Scripts:** Generic setup scripts are rarely idempotent, failing when run multiple times or conflicting with existing files.

### The DevForge Solution
DevForge automates this entire workspace setup into a single command. 

To make it as frictionless as possible, we don't just supply raw scripts. We package and distribute DevForge natively through **APT** and **Homebrew**, making installation, globally available execution, and version upgrades as simple as managing system packages.

*Note: This is the `v1` release of DevForge. We plan to expand support to other Linux distributions and automate custom dotfile profiles in future versions.*

---

## High-Level Design (HLD)

### Workstation Bootstrap Lifecycle

![DevForge Bootstrap Flow](assets/devforge_hld_arch.png)

### Software Architecture Diagram

![DevForge Software Architecture](assets/devforge_hld.png)

---

## 🚀 Installation & Setup

### Method 1: APT Installation (Ubuntu / WSL - Recommended)

```bash
# Add the repository and GPG signing key
curl -fsSL https://harishnarasimhank.github.io/dev-forge/install-devforge.sh | sudo bash

# Install devforge
sudo apt install -y devforge

# Bootstrap your workstation
dforge init
```

### Method 2: Homebrew Installation (macOS & Linux)

```bash
# Tap your custom repository
brew tap harishnarasimhank/devforge

# Install devforge
brew install devforge

# Bootstrap your workstation
dforge init
```

### Method 3: Manual Clone (Development / Source Run)

```bash
git clone https://github.com/HarishNarasimhanK/dev-forge.git
cd dev-forge
./dforge init
```

---

## 🖥️ Command Line Interface

Once installed, the `dforge` command is globally available.

```bash
dforge init       # Run the full workstation bootstrap
dforge install    # Run installer scripts only
dforge doctor     # Run environment diagnostics and health checks
dforge test       # Run ShellCheck syntax linter and bats unit tests
dforge update     # Pull updates from git and sync packages
dforge version    # Print the current CLI release version
```

---

## 🧪 Running Tests

We run tests using **ShellCheck** for static analysis and **bats-core** for unit testing:

```bash
# Execute local linter and unit tests
dforge test
```

Test scripts are hosted in the `tests/` directory.

---

## 📚 Documentation

Detailed documents are available in the `docs/` folder:

* **Command Line Interface Reference:** [docs/cli.md](docs/cli.md)
* **APT Package Management:** [docs/apt.md](docs/apt.md)
* **Homebrew Formula Tap Guide:** [docs/homebrew.md](docs/homebrew.md)
* **CI/CD Release Automation:** [docs/cicd.md](docs/cicd.md)
* **WSL2 Windows Environment Setup:** [docs/wsl-setup.md](docs/wsl-setup.md)
* **VS Code Integration:** [docs/vscode-setup.md](docs/vscode-setup.md)

For contributors and developers, please refer to the [Developer and Contribution Guide](DEVELOPER-GUIDE.md).
