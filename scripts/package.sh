#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# Build a signed Debian package for DevForge.
# ---------------------------------------------------------------
# 1️⃣ Determine the version from the most recent git tag (e.g. v1.2.4)
VERSION=$(git describe --tags --abbrev=0 | sed 's/^v//')
if [[ -z "$VERSION" ]]; then
  echo "No git tag found – cannot determine version"
  exit 1
fi

# 2️⃣ Prepare a temporary build directory with the Debian layout
BUILD_DIR=$(mktemp -d)
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/local/bin"
mkdir -p "$BUILD_DIR/usr/local/share/dev-forge"

# 3️⃣ Create the control file (mandatory metadata for APT)
cat > "$BUILD_DIR/DEBIAN/control" <<EOF
Package: devforge
Version: $VERSION
Architecture: all
Maintainer: Harish Narasimhan <harish@example.com>
Depends: curl, git, unzip, bash (>=4.4)
Description: Developer‑environment automation bootstrapper
 This package provides the `dforge` CLI and the full bootstrap script.
EOF

# 4️⃣ Copy the main executable and the rest of the repository into the package
install -m 0755 dforge "$BUILD_DIR/usr/local/bin/"
# Copy everything (scripts, docs, assets) – adjust if you want a slimmer package
cp -r * "$BUILD_DIR/usr/local/share/dev-forge/"

# Dynamically set the correct version inside the packaged dforge wrapper script
sed -i "s/VERSION=\"0.1.0\"/VERSION=\"$VERSION\"/g" "$BUILD_DIR/usr/local/bin/dforge"
sed -i "s/VERSION=\"0.1.0\"/VERSION=\"$VERSION\"/g" "$BUILD_DIR/usr/local/share/dev-forge/dforge"

# Remove self-built packages/repositories and temporary directories if they were copied in
rm -f "$BUILD_DIR/usr/local/share/dev-forge/devforge_"*.deb
rm -rf "$BUILD_DIR/usr/local/share/dev-forge/repo"
rm -rf "$BUILD_DIR/usr/local/share/dev-forge/repo-ghpages"

# 5️⃣ Optional post‑install script – just a friendly reminder
cat > "$BUILD_DIR/DEBIAN/postinst" <<'EOS'
#!/bin/sh
set -e
echo "DevForge installed. Run 'dforge init' to bootstrap your workstation."
EOS
chmod 0755 "$BUILD_DIR/DEBIAN/postinst"

# 6️⃣ Build the .deb file
DEB_NAME="devforge_${VERSION}_all.deb"

dpkg-deb --build "$BUILD_DIR" "$DEB_NAME"

# 7️⃣ APT repository security relies on signing the Release index file,
# not individual .deb packages. We do not need to sign the .deb itself.

# 8️⃣ Clean up temporary build directory
rm -rf "$BUILD_DIR"

echo "✅ Package built: $DEB_NAME"
