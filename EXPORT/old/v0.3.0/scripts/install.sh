#!/bin/bash
# MatLabC++ v0.3.0 - Install Script (stage to dist/)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="${ROOT}/build"
DIST="${ROOT}/dist"

NCORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo "╔════════════════════════════════════════╗"
echo "║  MatLabC++ v0.3.0 - Installing         ║"
echo "╚════════════════════════════════════════╝"

# Create dist structure
mkdir -p "${DIST}"/{bin,include,examples}

# Build if needed
if [ ! -f "${BUILD}/matlabcpp" ]; then
    echo ""
    echo "[1/4] Build not found, building first..."
    ./scripts/build.sh
fi

# Install binaries
echo ""
echo "[2/4] Installing binaries..."
cp -v "${BUILD}/matlabcpp" "${DIST}/bin/"
cp -v "${BUILD}/benchmark_inference" "${DIST}/bin/"

# Install headers
echo ""
echo "[3/4] Installing headers..."
rsync -a --delete "${ROOT}/include/" "${DIST}/include/"

# Install examples
echo ""
echo "[4/4] Installing examples..."
rsync -a --exclude="*.md" "${ROOT}/examples/" "${DIST}/examples/"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║  Installation Complete!                ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Install prefix: ${DIST}"
echo "Binaries:       ${DIST}/bin/"
echo "Headers:        ${DIST}/include/"
echo "Examples:       ${DIST}/examples/"
echo ""
echo "Add to PATH:    export PATH=\"${DIST}/bin:\$PATH\""
echo "Run:            ${DIST}/bin/matlabcpp"
echo ""
