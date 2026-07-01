# Standard Operating Procedure (SOP): Windows WSL2 Setup Guide

This guide details how to install and configure Windows Subsystem for Linux (WSL2) to prepare your environment for provisioning via the DevForge toolkit.

---

## Prerequisites
- **Windows OS**: Windows 10 (Version 2004 or higher, Build 19041 or higher) or Windows 11.
- **Hardware Virtualization**: Enabled in your computer's BIOS/UEFI settings.
  - To check: Open **Task Manager** (`Ctrl+Shift+Esc`), go to the **Performance** tab, select **CPU**, and verify that **Virtualization: Enabled** is displayed.

---

## Step 1: Install WSL and Linux Distro
1. Right-click the Windows Start menu and select **Terminal (Admin)** or **PowerShell (Admin)**.
2. Execute the following command to automatically install WSL2 and the default Ubuntu Linux distribution:
   ```powershell
   wsl --install
   ```
   *Note: If you want to use a specific distribution, you can view options via `wsl --list --online` and install with `wsl --install -d <DistroName>`.*
3. Once the installation process finishes, **restart your Windows computer** when prompted.

---

## Step 2: Initialize Your Linux Environment
1. After rebooting, a new terminal window will open automatically to complete the Linux setup. (If it doesn't, search for **Ubuntu** or your chosen distribution in the Windows Start menu and open it).
2. The terminal will ask you to enter a **username** and **password** for your new Linux distribution.
   - *This username and password are separate from your Windows credentials. Remember the password, as it will be used for `sudo` commands.*
3. Ensure WSL is running version 2. You can verify this in PowerShell on Windows by running:
   ```powershell
   wsl --list --verbose
   ```
   If it displays version `1`, convert it by running:
   ```powershell
   wsl --set-version <DistroName> 2
   ```

---

## Step 3: Run DevForge inside WSL
1. Within your running WSL Linux terminal, run package updates:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
2. Ensure Git is installed:
   ```bash
   sudo apt install -y git
   ```
3. Clone this repository to a directory inside WSL:
   ```bash
   git clone https://github.com/HarishNarasimhanK/dev-forge.git
   cd dev-forge
   ```
4. Run the DevForge bootstrap script:
   ```bash
   ./bootstrap.sh
   ```

---

## Troubleshooting WSL Connection Issues
If you encounter network resolution issues inside WSL, run the following commands to recreate the DNS configuration:
```bash
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "[network]" > /etc/wsl.conf && echo "generateResolvConf = false" >> /etc/wsl.conf'
```
Restart WSL via PowerShell on Windows with `wsl --shutdown` and boot it again.
