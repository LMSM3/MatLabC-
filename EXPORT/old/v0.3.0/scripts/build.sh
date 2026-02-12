#!/bin/bash
# MatLabC++ v0.3.0 - Build Script
set -euo pipefail

NCORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo "╔════════════════════════════════════════╗"
echo "║  MatLabC++ v0.3.0 - Building System    ║"
echo "╚════════════════════════════════════════╝"

# Clean and create build directory
rm -rf build
mkdir -p build
cd build

# Configure
echo ""
echo "[1/3] Configuring CMake..."
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DMATLABCPP_NATIVE_ARCH=ON \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Build
echo ""
echo "[2/3] Compiling (using ${NCORES} cores)..."
cmake --build . --config Release -j${NCORES}

# Verify
echo ""
echo "[3/3] Verifying..."
if [ -f "matlabcpp" ]; then
    echo "✓ matlabcpp executable built"
    ls -lh matlabcpp
fi
if [ -f "benchmark_inference" ]; then
    echo "✓ benchmark_inference built"
    ls -lh benchmark_inference
fi

cd ..

echo ""
echo "╔════════════════════════════════════════╗"
echo "║  Build Complete!                       ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Run: ./build/matlabcpp"
echo "Or:  cd build && ./matlabcpp"
echo ""
