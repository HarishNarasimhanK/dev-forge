# VS Code & WSL Workstation Integration Guide

This guide details setting up Visual Studio Code on your Windows 11 host and linking it to your WSL2 Ubuntu environment.

---

## 1. Prerequisites

### Install VS Code on Windows Host
1. Download the installer from the [Official VS Code Website](https://code.visualstudio.com/).
2. Run the installer. Ensure that the option **"Add to PATH (requires shell restart)"** is checked during installation.

### Configure Nerd Fonts
We recommend using **JetBrains Mono Nerd Font** to render dev symbols and icons correctly:
1. Download it from the [Nerd Fonts Website](https://www.nerdfonts.com/).
2. Extract the archive and install the font files on your Windows host.
3. Open Windows Terminal settings, navigate to your WSL Ubuntu profile, select **Appearance**, and set the font to `JetBrains Mono Nerd Font`.

---

## 2. Remote Development Configuration

### Install the WSL Extension
To write code inside your WSL Linux container from your Windows desktop:
1. Launch VS Code on Windows.
2. Open the extensions panel (`Ctrl + Shift + X`).
3. Search for and install the **WSL** extension (ID: `ms-vscode-remote.remote-wsl` by Microsoft).

### Launching Your Workspace
Always host your projects inside the native Linux directory structure (e.g. `~/workspace/`), **never** inside the mounted Windows drive (`/mnt/c/`), to prevent disk performance issues and file permission conflicts.

To start coding:
1. Open Windows Terminal and boot into WSL.
2. Navigate to your project:
   ```bash
   cd ~/workspace/personal/dev-forge
   ```
3. Launch VS Code:
   ```bash
   code .
   ```
VS Code will automatically spin up its WSL backend helper and load your workspace inside Linux.

---

## 3. Recommended Extensions

Once connected to WSL, install these extensions to align with your workstation configuration. When prompted, select **"Install in WSL: Ubuntu"**:

* **Python** (`ms-python.python`): Full Python debugging and linting integration.
* **Java Extension Pack** (`vscjava.vscode-java-pack`): Compiler support, debugger, and Maven integration.
* **rust-analyzer** (`rust-lang.rust-analyzer`): High-speed code completions, type hints, and compile diagnostics for Rust.
* **GitLens** (`eamodio.gitlens`): Comprehensive git visualization and file history tracking.
* **Error Lens** (`usernamehw.errorlens`): Renders code compiler warnings and errors inline.
* **Even Better TOML** (`tamasfe.even-better-toml`): Syntax highlighting and linting for TOML configuration files.
* **YAML** (`redhat.vscode-yaml`): Complete schema validation and checks for YAML.
* **Markdown All in One** (`yzhang.markdown-all-in-one`): Markdown preview, shortcuts, and auto-formatting.
