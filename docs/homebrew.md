# Homebrew Installation Guide

For macOS or systems using Homebrew, you can install and update DevForge using a custom Formula Tap.

---

### How it Works

Homebrew uses Ruby-based recipes called **Formulas** to download and install packages from source code archives.

1. **Tap Integration:** By tapping the repository, you tell Homebrew where to look for the formula files.
2. **On-the-Fly Assembly:** Homebrew downloads the stable release archive directly from GitHub, updates the internal version configuration, and symlinks the executable and assets into your standard execution path.

---

### Installation

Run these commands to add the tap and install the CLI:

```bash
# Add the tap repository
brew tap harishnarasimhank/devforge

# Install the package
brew install devforge
```

---

### Upgrading

To pull the latest updates, run:

```bash
brew update
brew upgrade devforge
```
