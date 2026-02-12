#!/bin/bash
set -e

echo "=========================================="
echo "MatLabC++ Integration Test"
echo "=========================================="

# Make scripts executable
chmod +x scripts/*.sh

# Check Python environment
echo "Checking Python environment..."
which python3 || echo "Python 3 not found"

# Check C++ build tools
echo "Checking C++ build tools..."
which cmake || echo "CMake not found"
which g++ || which clang++ || echo "C++ compiler not found"

# Check if build exists
if [ -f "build/matlabcpp" ]; then
    echo "Build found: OK"
else
    echo "Build not found. Run: ./scripts/build_cpp.sh"
fi

echo ""
echo "=========================================="
echo "System check complete!"
echo "=========================================="
