#!/usr/bin/env bash
set -euo pipefail

VERSION=$(git describe --tags --abbrev=0 | sed 's/^v//')
if [[ -z "$VERSION" ]]; then
  echo "Error: No git tag found." >&2
  exit 1
fi

BUILD_DIR=$(mktemp -d)
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/local/bin"
mkdir -p "$BUILD_DIR/usr/local/share/dev-forge"

cat > "$BUILD_DIR/DEBIAN/control" <<EOF
Package: devforge
Version: $VERSION
Architecture: all
Maintainer: Harish Narasimhan <harish@example.com>
Depends: curl, git, unzip, bash (>=4.4)
Description: Developer‑environment automation bootstrapper
 This package provides the dforge CLI and the full bootstrap script.
EOF

install -m 0755 dforge "$BUILD_DIR/usr/local/bin/"
cp -r * "$BUILD_DIR/usr/local/share/dev-forge/"

# Inject version dynamically
sed -i "s/VERSION=\"0.1.0\"/VERSION=\"$VERSION\"/g" "$BUILD_DIR/usr/local/bin/dforge"
sed -i "s/VERSION=\"0.1.0\"/VERSION=\"$VERSION\"/g" "$BUILD_DIR/usr/local/share/dev-forge/dforge"

# Clean up unwanted files
rm -f "$BUILD_DIR/usr/local/share/dev-forge/devforge_"*.deb
rm -rf "$BUILD_DIR/usr/local/share/dev-forge/repo"
rm -rf "$BUILD_DIR/usr/local/share/dev-forge/repo-ghpages"

cat > "$BUILD_DIR/DEBIAN/postinst" <<'EOS'
#!/bin/sh
set -e
echo "DevForge installed. Run 'dforge init' to bootstrap your workstation."
EOS
chmod 0755 "$BUILD_DIR/DEBIAN/postinst"

DEB_NAME="devforge_${VERSION}_all.deb"
dpkg-deb --build "$BUILD_DIR" "$DEB_NAME"

rm -rf "$BUILD_DIR"
echo "✅ Package built: $DEB_NAME"
