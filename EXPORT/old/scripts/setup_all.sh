#!/bin/bash
set -e

echo "=========================================="
echo "MatLabC++ Complete Setup"
echo "=========================================="

# Make scripts executable
chmod +x scripts/*.sh

echo "Step 1/3: Environment setup..."
./scripts/setup_env.sh

echo ""
echo "Step 2/3: Building C++ system..."
./scripts/build_cpp.sh

echo ""
echo "Step 3/3: Testing installation..."
./scripts/test_all.sh

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Activate: conda activate matlabcpp_journal"
echo "  2. Launch:   jupyter notebook notebooks/"
echo "  3. Or run:   cd build && ./matlabcpp"
echo ""
