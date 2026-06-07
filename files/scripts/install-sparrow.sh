#!/usr/bin/env bash
set -euo pipefail

VERSION=$(curl -fsSL https://api.github.com/repos/sparrowwallet/sparrow/releases/latest | jq -r '.tag_name')
TARBALL="sparrowwallet-${VERSION}-x86_64.tar.gz"
MANIFEST="sparrow-${VERSION}-manifest.txt"
MANIFEST_SIG="sparrow-${VERSION}-manifest.txt.asc"
BASE_URL="https://github.com/sparrowwallet/sparrow/releases/download/${VERSION}"

echo "Installing Sparrow ${VERSION}..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "${BASE_URL}/${TARBALL}"      -o "${TMP}/${TARBALL}"
curl -fsSL "${BASE_URL}/${MANIFEST}"     -o "${TMP}/${MANIFEST}"
curl -fsSL "${BASE_URL}/${MANIFEST_SIG}" -o "${TMP}/${MANIFEST_SIG}"

curl -fsSL "https://keybase.io/craigraw/pgp_keys.asc" | gpg --import

echo "Verifying GPG signature..."
gpg --verify "${TMP}/${MANIFEST_SIG}" "${TMP}/${MANIFEST}"

echo "Verifying SHA256..."
pushd "$TMP" > /dev/null
grep "${TARBALL}" "${MANIFEST}" | sha256sum --check
popd > /dev/null

tar -xzf "${TMP}/${TARBALL}" -C /opt
ln -sf /opt/Sparrow/bin/Sparrow /usr/local/bin/sparrow

# Desktop entry
cat > /usr/share/applications/sparrow.desktop <<EOF
[Desktop Entry]
Name=Sparrow Wallet
Comment=Bitcoin hardware and software wallet
Exec=/opt/Sparrow/bin/Sparrow
Icon=/opt/Sparrow/lib/Sparrow.png
Terminal=false
Type=Application
Categories=Network;Finance;
Keywords=bitcoin;wallet;hardware;
EOF

echo "Sparrow ${VERSION} installed."
