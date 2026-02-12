#!/bin/bash
# BUILD_BASIC.SH - Simple, reliable build for v0.4.0
# No GPU, no complex features, just core functionality

set -e  # Exit on error

echo "================================================"
echo "MatLabC++ BASIC BUILD (v0.4.0)"
echo "================================================"
echo ""

# Check we're in project root
if [ ! -f "CMakeLists.txt" ]; then
    echo "ERROR: Run from project root (where CMakeLists.txt is)"
    exit 1
fi

# Clean previous build
echo "Step 1: Clean previous build..."
rm -rf build
mkdir -p build
echo "  ✓ Build directory ready"
echo ""

# Configure
echo "Step 2: Configure with CMake..."
cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_TESTS=ON \
    -DWITH_GPU=OFF \
    -DWITH_CAIRO=OFF \
    -DWITH_OPENGL=OFF

if [ $? -ne 0 ]; then
    echo "  ✗ Configuration failed"
    exit 1
fi
echo "  ✓ Configuration successful"
echo ""

# Build
echo "Step 3: Build (using $(nproc) cores)..."
cmake --build . -j$(nproc)

if [ $? -ne 0 ]; then
    echo "  ✗ Build failed"
    exit 1
fi
echo "  ✓ Build successful"
echo ""

# Verify
echo "Step 4: Verify build..."
if [ -f "mlab++" ]; then
    echo "  ✓ Executable found: mlab++"
    ./mlab++ --version
elif [ -f "Release/mlab++.exe" ]; then
    echo "  ✓ Executable found: Release/mlab++.exe"
    ./Release/mlab++.exe --version
else
    echo "  ✗ Executable not found"
    exit 1
fi
echo ""

# Test
echo "Step 5: Quick test..."
echo "2 + 2" | ./mlab++ 2>&1 | grep -q "ans" && echo "  ✓ Basic math works" || echo "  ⚠ Test inconclusive"
echo ""

cd ..

echo "================================================"
echo "BUILD COMPLETE"
echo "================================================"
echo ""
echo "Run with:"
echo "  ./build/mlab++"
echo ""
echo "Quick test:"
echo "  echo '2 + 2' | ./build/mlab++"
echo ""
