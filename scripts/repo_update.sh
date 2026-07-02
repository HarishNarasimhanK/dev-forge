#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# Update APT Repository indexes and metadata.
# ---------------------------------------------------------------
# This script copies the generated debian packages into the repository
# directory, runs dpkg-scanpackages to create/update Packages.gz,
# generates the Release file, and signs it.

REPO_DIR="repo"
mkdir -p "$REPO_DIR"

# Copy newly built .deb file into repo directory
if ls devforge_*.deb 1> /dev/null 2>&1; then
  cp devforge_*.deb "$REPO_DIR/"
else
  echo "No devforge_*.deb files found in the current directory. Only scanning existing files in '$REPO_DIR'."
fi

# Regenerate Packages index using dpkg-scanpackages
# dpkg-scanpackages requires dpkg-dev to be installed
if ! command -v dpkg-scanpackages &> /dev/null; then
  echo "Error: dpkg-scanpackages is not installed. Please run: sudo apt-get install dpkg-dev"
  exit 1
fi

echo "Scanning packages..."
dpkg-scanpackages "$REPO_DIR" /dev/null | gzip -9c > "$REPO_DIR/Packages.gz"

# Create Release file
echo "Generating Release metadata..."
cat > "$REPO_DIR/Release" <<EOF
Archive: stable
Component: main
Origin: devforge
Label: devforge
Version: $(date +%Y%m%d%H%M)
Codename: stable
Architectures: all
Date: $(date -R)
Description: DevForge Debian/Ubuntu APT repository
EOF

# Append MD5Sum and SHA256 sum of Packages.gz to Release file
echo "MD5Sum:" >> "$REPO_DIR/Release"
md5_pkg=$(md5sum "$REPO_DIR/Packages.gz" | awk '{print $1}')
size_pkg=$(wc -c < "$REPO_DIR/Packages.gz" | tr -d ' ')
echo " $md5_pkg $size_pkg Packages.gz" >> "$REPO_DIR/Release"

echo "SHA256:" >> "$REPO_DIR/Release"
sha_pkg=$(sha256sum "$REPO_DIR/Packages.gz" | awk '{print $1}')
echo " $sha_pkg $size_pkg Packages.gz" >> "$REPO_DIR/Release"

# Sign the Release file if GPG_KEYID is set
if [[ -n "${GPG_KEYID-}" ]]; then
  if gpg --list-keys "$GPG_KEYID" &> /dev/null; then
    echo "Signing Release with GPG Key ID: $GPG_KEYID"
    gpg_opts="--batch --pinentry-mode loopback"
    if [[ -n "${GPG_PASSPHRASE-}" ]]; then
      echo "$GPG_PASSPHRASE" | gpg $gpg_opts --passphrase-fd 0 --default-key "$GPG_KEYID" --digest-algo SHA256 -abs -o "$REPO_DIR/Release.gpg" "$REPO_DIR/Release"
      echo "$GPG_PASSPHRASE" | gpg $gpg_opts --passphrase-fd 0 --default-key "$GPG_KEYID" --digest-algo SHA256 --clearsign -o "$REPO_DIR/InRelease" "$REPO_DIR/Release"
    else
      gpg --default-key "$GPG_KEYID" --digest-algo SHA256 -abs -o "$REPO_DIR/Release.gpg" "$REPO_DIR/Release"
      gpg --default-key "$GPG_KEYID" --digest-algo SHA256 --clearsign -o "$REPO_DIR/InRelease" "$REPO_DIR/Release"
    fi
    echo "✅ Signed successfully."
  else
    echo "Warning: GPG Key ID '$GPG_KEYID' not found in local keyring. Skipping Release signing."
  fi
else
  echo "GPG_KEYID is not set – skipping signing of Release metadata."
fi

echo "✅ Repository update completed in '$REPO_DIR/'"
