#!/usr/bin/env bash
# build_installer.sh
# Intent: Build C++ installer binary
# Creates standalone installer that replaces bash dependency

set -euo pipefail

BOLD=$'\e[1m'
GREEN=$'\e[32m'
RED=$'\e[31m'
YELLOW=$'\e[33m'
NC=$'\e[0m'

echo "${BOLD}Building C++ Bundle Installer${NC}"
echo ""

# ========== CHECK COMPILER ==========
echo "Checking compiler..."

if command -v g++ >/dev/null 2>&1; then
    COMPILER="g++"
    echo "  ${GREEN}✓${NC} Found: g++ $(g++ --version | head -n1)"
elif command -v clang++ >/dev/null 2>&1; then
    COMPILER="clang++"
    echo "  ${GREEN}✓${NC} Found: clang++ $(clang++ --version | head -n1)"
else
    echo "  ${RED}✗${NC} No C++ compiler found"
    echo ""
    echo "Install:"
    echo "  Ubuntu/Debian: sudo apt install g++"
    echo "  macOS:         xcode-select --install"
    echo "  Windows:       Install MinGW or MSVC"
    exit 1
fi

echo ""

# ========== CHECK CMAKE (OPTIONAL) ==========
USE_CMAKE=false
if command -v cmake >/dev/null 2>&1; then
    USE_CMAKE=true
    echo "${YELLOW}CMake detected - using CMake build${NC}"
else
    echo "${YELLOW}CMake not found - using direct compilation${NC}"
fi

echo ""

# ========== BUILD ==========
echo "Compiling..."

if $USE_CMAKE; then
    # CMake build
    mkdir -p build
    cd build
    cmake ../tools >/dev/null 2>&1
    cmake --build . >/dev/null 2>&1
    cd ..
    
    if [[ -f build/bundle_installer ]]; then
        cp build/bundle_installer tools/
        echo "  ${GREEN}✓${NC} Built: tools/bundle_installer"
    else
        echo "  ${RED}✗${NC} Build failed"
        exit 1
    fi
else
    # Direct compilation
    $COMPILER -std=c++17 -O2 -Wall -Wextra \
        tools/bundle_installer.cpp \
        -o tools/bundle_installer
    
    if [[ $? -eq 0 ]]; then
        echo "  ${GREEN}✓${NC} Built: tools/bundle_installer"
    else
        echo "  ${RED}✗${NC} Compilation failed"
        exit 1
    fi
fi

# Make executable
chmod +x tools/bundle_installer

echo ""

# ========== VERIFY ==========
echo "Verifying..."

INSTALLER_SIZE=$(stat -f%z tools/bundle_installer 2>/dev/null || \
                 stat -c%s tools/bundle_installer 2>/dev/null)
INSTALLER_SIZE_KB=$((INSTALLER_SIZE / 1024))

echo "  ${GREEN}✓${NC} Size: ${INSTALLER_SIZE_KB} KB"

if file tools/bundle_installer | grep -q "executable"; then
    echo "  ${GREEN}✓${NC} Format: Valid executable"
else
    echo "  ${YELLOW}!${NC} Warning: May not be executable"
fi

echo ""

# ========== SUMMARY ==========
echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${GREEN}${BOLD}Build complete${NC}"
echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "${BOLD}Usage:${NC}"
echo "  ${YELLOW}./tools/bundle_installer mlabpp_examples_bundle.sh${NC}"
echo "  ${YELLOW}./tools/bundle_installer bundle.sh /opt/matlabcpp${NC}"
echo ""
echo "${BOLD}Advantages:${NC}"
echo "  - No bash dependency"
echo "  - Faster execution"
echo "  - Cross-platform binary"
echo "  - Real RAM monitoring"
echo "  - Better error handling"
echo ""
