#!/bin/bash
set -e

echo "=========================================="
echo "Building MatLabC++ System"
echo "=========================================="

rm -rf build
mkdir -p build
cd build

echo "Configuring CMake..."
cmake .. -DCMAKE_BUILD_TYPE=Release -DMATLABCPP_NATIVE_ARCH=ON

echo "Building..."
cmake --build . -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo ""
echo "=========================================="
echo "Build complete!"
echo "=========================================="
echo "Executables in build/ directory"

cd ..
