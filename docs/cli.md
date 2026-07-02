# DevForge CLI Guide

`dforge` is the command-line companion for managing your developer environment. This guide explains how to use its core commands.

---

### Core Commands

#### 1. `dforge init`
Bootstraps your development environment from scratch.
* **What it does:** Installs the standard configurations, language runtimes (Node.js, Python, Go, Java, Rust), cloud command-line interfaces, and terminal tools.
* **When to use it:** On a fresh machine install, a new WSL workspace, or when you want to reset your local tooling to a standard state.
* **How to run:**
  ```bash
  dforge init
  ```

#### 2. `dforge doctor`
Runs health checks and diagnostics on your runtimes and tools.
* **What it does:** Scans your path, checks installed versions, and verifies shell configuration files. Prints a clean, color-coded status report.
* **When to use it:** When checking if a runtime installed successfully, or troubleshooting environment configurations.
* **How to run:**
  ```bash
  dforge doctor
  ```

#### 3. `dforge install`
Orchestrates package and language runtime installation.
* **What it does:** Re-evaluates configurations and ensures all runtimes toggled in your config profile are installed.
* **How to run:**
  ```bash
  dforge install
  ```

#### 4. `dforge update`
Pulls updates from the remote repository and syncs packages.
* **What it does:** Performs a `git pull` on your environment configuration repository and executes installation tasks to sync any new packages or updates.
* **How to run:**
  ```bash
  dforge update
  ```

#### 5. `dforge test`
Runs environment static analysis tests.
* **What it does:** Runs shellcheck syntax checks and local unit tests to verify script integrity.
* **How to run:**
  ```bash
  dforge test
  ```

#### 6. `dforge version`
Prints the current CLI release version.
* **How to run:**
  ```bash
  dforge version
  ```
