#!/usr/bin/env bash
# Package Manager Demo Script
# Shows the full workflow of package installation

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "MatLabC++ Package Manager Demo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# ========== SEARCH FOR PACKAGES ==========
echo "1. Searching for packages..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "$ mlab++ pkg search materials"
echo

cat <<'EOF'
Found 1 package(s):

Name              Version  Size     Description                              Status
────────────────────────────────────────────────────────────────────────────────
materials_smart   1.0.0    156 KB   Smart materials database with inference
EOF

echo
read -p "Press Enter to continue..."
echo

# ========== SHOW PACKAGE INFO ==========
echo "2. Getting package information..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "$ mlab++ pkg info materials_smart"
echo

cat <<'EOF'
Package: materials_smart
Version: 1.0.0
Description: Smart materials database with inference, selection, and optimization
Category: data
License: MIT
Size: 156 KB
Status: Not installed

Requires:
  - core >= 0.3.0

Provides:
  - material
  - material_get
  - material_infer_density
  - material_select
  - material_compare
  - material_recommend

Backends: cpu
EOF

echo
read -p "Press Enter to continue..."
echo

# ========== INSTALL PACKAGE ==========
echo "3. Installing package..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "$ mlab++ pkg install materials_smart"
echo

cat <<'EOF'
Resolving dependencies...
  materials_smart 1.0.0
    requires: core >= 0.3.0 ✓

Installing:
  materials_smart  1.0.0

Downloading [####################] 156 KB

Verifying checksum... ✓
Extracting... ✓
Installing... ✓

Installed: materials_smart 1.0.0
  Provides: material, material_get, material_infer_density, ...
  Location: ~/.matlabcpp/modules/materials_smart/1.0.0/

Run demos:
  cd ~/.matlabcpp/modules/materials_smart/1.0.0/demos/
  mlab++ materials_lookup.m --visual

✓ Complete!
EOF

echo
read -p "Press Enter to continue..."
echo

# ========== LIST INSTALLED ==========
echo "4. Listing installed packages..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "$ mlab++ pkg list"
echo

cat <<'EOF'
Installed packages:

Name              Version  Size     Provides
────────────────────────────────────────────────────────────
materials_smart   1.0.0    156 KB   9 capabilities
EOF

echo
read -p "Press Enter to continue..."
echo

# ========== USE THE PACKAGE ==========
echo "5. Using installed package..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "$ mlab++"
echo ">> material_get('aluminum_6061')"
echo

cat <<'EOF'
Material: Aluminum 6061-T6
  Density: 2700 kg/m³
  Young's Modulus: 68.9 GPa
  Yield Strength: 276 MPa
  Source: NIST (confidence: 5/5)

>> material_infer_density(2710, 100)

Inferred material: aluminum_6061
Confidence: 0.95
Reasoning: Density match within tolerance

>> quit
EOF

echo
read -p "Press Enter to continue..."
echo

# ========== INSTALL MORE PACKAGES ==========
echo "6. Installing GPU benchmarking..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "$ mlab++ pkg install gpu_bench"
echo

cat <<'EOF'
Resolving dependencies...
  gpu_bench 1.0.0
    requires: core >= 0.3.0 ✓

Detecting GPU capabilities...
  NVIDIA GeForce RTX 3080 detected ✓
  CUDA 11.6 found ✓

Installing:
  gpu_bench  1.0.0

Downloading [####################] 48 KB

✓ Complete!

GPU benchmarking tools installed
Test with: mlab++ gpu_benchmark.m --enableGPU
EOF

echo
read -p "Press Enter to continue..."
echo

# ========== CAPABILITY RESOLUTION ==========
echo "7. Capability-based resolution (the pro part)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Application doesn't call libraries directly."
echo "It requests capabilities, system provides best backend."
echo
echo "Example code:"
echo

cat <<'EOF'
// Application doesn't hardcode dependencies
auto fn = matlabcpp::resolve("material_get");
auto mat = fn("aluminum_6061");

// System chooses backend at runtime:
// 1. Check if materials_smart is installed
// 2. Check which backend is available (cpu/gpu)
// 3. Load appropriate .so
// 4. Return function pointer

// This is why it scales.
EOF

echo
read -p "Press Enter to continue..."
echo

# ========== REMOVE PACKAGE ==========
echo "8. Removing package..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "$ mlab++ pkg remove materials_smart"
echo

cat <<'EOF'
Removing: materials_smart

✓ Package removed: materials_smart
EOF

echo
echo

# ========== SUMMARY ==========
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Package Manager Features:"
echo "  ✓ Search and discovery"
echo "  ✓ Dependency resolution"
echo "  ✓ Automated download and install"
echo "  ✓ Checksum verification"
echo "  ✓ Backend selection"
echo "  ✓ Capability-based resolution"
echo "  ✓ Clean uninstall"
echo
echo "Just like dnf, but for numerical computing."
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
