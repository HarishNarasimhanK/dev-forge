#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-repo}"
mkdir -p "$REPO_DIR"

if ls devforge_*.deb 1> /dev/null 2>&1; then
  cp devforge_*.deb "$REPO_DIR/"
else
  echo "No devforge_*.deb files found. Scanning existing files in '$REPO_DIR'."
fi

if ! command -v dpkg-scanpackages &> /dev/null; then
  echo "Error: dpkg-scanpackages not found." >&2
  exit 1
fi

echo "Scanning packages..."
dpkg-scanpackages "$REPO_DIR" /dev/null > "$REPO_DIR/Packages"
gzip -9c "$REPO_DIR/Packages" > "$REPO_DIR/Packages.gz"

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

echo "MD5Sum:" >> "$REPO_DIR/Release"
md5_pkg=$(md5sum "$REPO_DIR/Packages" | awk '{print $1}')
size_pkg=$(wc -c < "$REPO_DIR/Packages" | tr -d ' ')
echo " $md5_pkg $size_pkg Packages" >> "$REPO_DIR/Release"
md5_pkg_gz=$(md5sum "$REPO_DIR/Packages.gz" | awk '{print $1}')
size_pkg_gz=$(wc -c < "$REPO_DIR/Packages.gz" | tr -d ' ')
echo " $md5_pkg_gz $size_pkg_gz Packages.gz" >> "$REPO_DIR/Release"

echo "SHA256:" >> "$REPO_DIR/Release"
sha_pkg=$(sha256sum "$REPO_DIR/Packages" | awk '{print $1}')
size_pkg=$(wc -c < "$REPO_DIR/Packages" | tr -d ' ')
echo " $sha_pkg $size_pkg Packages" >> "$REPO_DIR/Release"
sha_pkg_gz=$(sha256sum "$REPO_DIR/Packages.gz" | awk '{print $1}')
size_pkg_gz=$(wc -c < "$REPO_DIR/Packages.gz" | tr -d ' ')
echo " $sha_pkg_gz $size_pkg_gz Packages.gz" >> "$REPO_DIR/Release"

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
    echo "Warning: GPG Key ID '$GPG_KEYID' not found. Skipping signing."
  fi
else
  echo "GPG_KEYID not set – skipping signing."
fi

echo "✅ Repository update completed in '$REPO_DIR/'"
