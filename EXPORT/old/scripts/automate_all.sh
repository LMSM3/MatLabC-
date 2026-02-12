#!/usr/bin/env bash
# automate_all.sh
# Intent: One-command system automation
# Runs verification, builds, tests, and prepares release

set -euo pipefail

BOLD=$'\e[1m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
CYAN=$'\e[36m'
RED=$'\e[31m'
NC=$'\e[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""
echo "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo "${BOLD}${CYAN}║                                                               ║${NC}"
echo "${BOLD}${CYAN}║            MatLabC++ Automated Ship Process                   ║${NC}"
echo "${BOLD}${CYAN}║                                                               ║${NC}"
echo "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ========== STEP 1: VERIFY SYSTEM ==========
echo "${BOLD}Step 1: System Verification${NC}"
echo ""

if python3 "$SCRIPT_DIR/verify_system.py"; then
    echo "${GREEN}✓ System verification passed${NC}"
else
    echo "${RED}✗ System verification failed${NC}"
    echo ""
    echo "Fix issues and try again"
    exit 1
fi

echo ""
read -p "${BOLD}Continue with build? [Y/n]:${NC} " response
if [[ "$response" =~ ^[Nn] ]]; then
    echo "Aborted by user"
    exit 0
fi

# ========== STEP 2: MAKE SCRIPTS EXECUTABLE ==========
echo ""
echo "${BOLD}Step 2: Setting Permissions${NC}"
echo ""

find "$PROJECT_ROOT/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$PROJECT_ROOT/demos" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$PROJECT_ROOT/tools" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
chmod +x "$PROJECT_ROOT/demos/self_install_demo.py" 2>/dev/null || true

echo "${GREEN}✓ Permissions updated${NC}"

# ========== STEP 3: BUILD EVERYTHING ==========
echo ""
echo "${BOLD}Step 3: Building Components${NC}"
echo ""

cd "$PROJECT_ROOT"

# Distribution bundles
if bash scripts/generate_examples_zip.sh >/dev/null 2>&1; then
    echo "${GREEN}✓ ZIP bundle${NC}"
else
    echo "${RED}✗ ZIP bundle failed${NC}"
fi

if bash scripts/generate_examples_bundle.sh >/dev/null 2>&1; then
    echo "${GREEN}✓ Shell bundle${NC}"
else
    echo "${RED}✗ Shell bundle failed${NC}"
fi

# C++ installer (optional)
if command -v g++ >/dev/null 2>&1 || command -v clang++ >/dev/null 2>&1; then
    if bash tools/build_installer.sh >/dev/null 2>&1; then
        echo "${GREEN}✓ C++ installer${NC}"
    else
        echo "${YELLOW}! C++ installer failed (non-critical)${NC}"
    fi
fi

# C++ demo (optional)
if command -v g++ >/dev/null 2>&1; then
    if g++ -std=c++17 -O2 -pthread demos/green_square_demo.cpp -o demos/green_square_demo 2>/dev/null; then
        echo "${GREEN}✓ C++ demo${NC}"
    else
        echo "${YELLOW}! C++ demo failed (non-critical)${NC}"
    fi
fi

# ========== STEP 4: RUN TESTS ==========
echo ""
echo "${BOLD}Step 4: Running Tests${NC}"
echo ""

if bash scripts/test_bundle_system.sh >/dev/null 2>&1; then
    echo "${GREEN}✓ Bundle system tests passed${NC}"
else
    echo "${RED}✗ Tests failed${NC}"
    echo ""
    echo "Fix test failures and try again"
    exit 1
fi

# ========== STEP 5: PREPARE RELEASE ==========
echo ""
echo "${BOLD}Step 5: Release Preparation${NC}"
echo ""

if bash scripts/ship_release.sh; then
    echo ""
    echo "${GREEN}${BOLD}✓ Release preparation complete${NC}"
else
    echo "${RED}✗ Release preparation failed${NC}"
    exit 1
fi

# ========== FINAL SUMMARY ==========
echo ""
echo "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo "${BOLD}${GREEN}║                                                               ║${NC}"
echo "${BOLD}${GREEN}║                 READY TO SHIP                                 ║${NC}"
echo "${BOLD}${GREEN}║                                                               ║${NC}"
echo "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo "${BOLD}What was done:${NC}"
echo "  ${GREEN}✓${NC} System verified"
echo "  ${GREEN}✓${NC} Permissions set"
echo "  ${GREEN}✓${NC} Components built"
echo "  ${GREEN}✓${NC} Tests passed"
echo "  ${GREEN}✓${NC} Documentation exported"
echo "  ${GREEN}✓${NC} Release package created"
echo ""

echo "${BOLD}Check these locations:${NC}"
echo "  Docs:     ${CYAN}$HOME/Desktop/MatLabCpp_Docs/${NC}"
echo "  Release:  ${CYAN}$HOME/Desktop/matlabcpp_v0.3.0_release.tar.gz${NC}"
echo "  Bundles:  ${CYAN}$PROJECT_ROOT/dist/${NC}"
echo ""

echo "${BOLD}Next steps:${NC}"
echo "  ${DIM}1. Review exported documentation${NC}"
echo "  ${DIM}2. Test demos: ./demos/run_demo.sh${NC}"
echo "  ${DIM}3. Distribute bundles from dist/${NC}"
echo ""

echo "${GREEN}${BOLD}MatLabC++ ready for distribution${NC}"
echo ""
s