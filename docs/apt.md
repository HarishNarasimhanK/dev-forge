# APT Package Manager Guide

For Debian, Ubuntu, and WSL2 environments, you can install and update DevForge using your system's native package manager (`apt`).

---

### How it Works

Instead of running a manual download or cloning the code yourself, we package the entire project into a standard Debian installer file (`.deb`). 

1. **Static Hosting:** The package files and repository indexes are hosted statically on GitHub Pages.
2. **Cryptographic Trust:** The repository metadata index is signed with a private GPG key. Your system uses the matching public GPG key to verify the integrity of the downloaded package.

---

### Quick Installation

Run this single command to fetch the signing key, add the repository source, and install the CLI:

```bash
# Add the DevForge repository and GPG key
curl -fsSL https://harishnarasimhank.github.io/dev-forge/install-devforge.sh | sudo bash

# Install the CLI package
sudo apt install devforge
```

---

### Upgrading DevForge

Since it is managed by the system, upgrading is as simple as upgrading any other software:

```bash
sudo apt update
sudo apt install --only-upgrade devforge
```
