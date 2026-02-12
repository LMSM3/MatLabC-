#!/bin/bash
# cleanup_project.sh - Organize MatLabC++ directory structure
# Run this from project root

set -e

# Colors
GREEN='\033[32m'
CYAN='\033[36m'
YELLOW='\033[33m'
NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  MatLabC++ Directory Cleanup & Organization Tool          ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify we're in project root
if [ ! -f "CMakeLists.txt" ]; then
    echo -e "${YELLOW}Error: CMakeLists.txt not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo -e "${GREEN}✓${NC} Project root verified"
echo ""

# Create documentation structure
echo "Creating documentation structure..."
mkdir -p docs/{guides,architecture,tutorials,reference,development,archive}
echo -e "${GREEN}✓${NC} Documentation directories created"

# Move guide documents
echo ""
echo "Organizing guide documents..."
[ -f "QUICK_START_CLI.md" ] && mv QUICK_START_CLI.md docs/guides/ && echo "  → QUICK_START_CLI.md"
[ -f "BUILD_SCRIPTS_GUIDE.md" ] && mv BUILD_SCRIPTS_GUIDE.md docs/guides/ && echo "  → BUILD_SCRIPTS_GUIDE.md"
[ -f "FOR_NORMAL_PEOPLE.md" ] && mv FOR_NORMAL_PEOPLE.md docs/guides/ && echo "  → FOR_NORMAL_PEOPLE.md"
[ -f "INSTALL_OPTIONS.md" ] && mv INSTALL_OPTIONS.md docs/guides/ && echo "  → INSTALL_OPTIONS.md"
[ -f "GETTING_STARTED.md" ] && mv GETTING_STARTED.md docs/guides/ && echo "  → GETTING_STARTED.md"

# Move architecture documents
echo ""
echo "Organizing architecture documents..."
[ -f "CODEBASE_REVIEW.md" ] && mv CODEBASE_REVIEW.md docs/architecture/ && echo "  → CODEBASE_REVIEW.md"
[ -f "BUNDLE_ARCHITECTURE.md" ] && mv BUNDLE_ARCHITECTURE.md docs/architecture/ && echo "  → BUNDLE_ARCHITECTURE.md"
[ -f "PACKAGE_MANAGEMENT_COMPLETE.md" ] && mv PACKAGE_MANAGEMENT_COMPLETE.md docs/architecture/ && echo "  → PACKAGE_MANAGEMENT_COMPLETE.md"
[ -f "PLOTTING_SYSTEM.md" ] && mv PLOTTING_SYSTEM.md docs/architecture/ && echo "  → PLOTTING_SYSTEM.md"
[ -f "FEATURES.md" ] && mv FEATURES.md docs/architecture/ && echo "  → FEATURES.md"

# Move tutorial documents
echo ""
echo "Organizing tutorial documents..."
[ -f "ACTIVE_WINDOW_QUICKSTART.md" ] && mv ACTIVE_WINDOW_QUICKSTART.md docs/tutorials/ && echo "  → ACTIVE_WINDOW_QUICKSTART.md"
[ -f "ACTIVE_WINDOW_DEMO.md" ] && mv ACTIVE_WINDOW_DEMO.md docs/tutorials/ && echo "  → ACTIVE_WINDOW_DEMO.md"
[ -f "MATH_ACCURACY_QUICKREF.md" ] && mv MATH_ACCURACY_QUICKREF.md docs/tutorials/ && echo "  → MATH_ACCURACY_QUICKREF.md"
[ -f "DISTRIBUTION_QUICKSTART.md" ] && mv DISTRIBUTION_QUICKSTART.md docs/tutorials/ && echo "  → DISTRIBUTION_QUICKSTART.md"

# Move reference documents
echo ""
echo "Organizing reference documents..."
[ -f "MATERIALS_DATABASE.md" ] && mv MATERIALS_DATABASE.md docs/reference/ && echo "  → MATERIALS_DATABASE.md"
[ -f "QUICKREF.md" ] && mv QUICKREF.md docs/reference/ && echo "  → QUICKREF.md"
[ -f "BUNDLE_QUICKREF.md" ] && mv BUNDLE_QUICKREF.md docs/reference/ && echo "  → BUNDLE_QUICKREF.md"
[ -f "MATH_ACCURACY_TESTS.md" ] && mv MATH_ACCURACY_TESTS.md docs/reference/ && echo "  → MATH_ACCURACY_TESTS.md"

# Move development documents
echo ""
echo "Organizing development documents..."
[ -f "BUILD_AUTOMATION_READY.md" ] && mv BUILD_AUTOMATION_READY.md docs/development/ && echo "  → BUILD_AUTOMATION_READY.md"
[ -f "SYSTEM_STATUS.md" ] && mv SYSTEM_STATUS.md docs/development/ && echo "  → SYSTEM_STATUS.md"
[ -f "PRE_FLIGHT_CHECKLIST.md" ] && mv PRE_FLIGHT_CHECKLIST.md docs/development/ && echo "  → PRE_FLIGHT_CHECKLIST.md"
[ -f "AUTOMATION_SUMMARY.md" ] && mv AUTOMATION_SUMMARY.md docs/development/ && echo "  → AUTOMATION_SUMMARY.md"
[ -f "BUNDLE_CHECKLIST.md" ] && mv BUNDLE_CHECKLIST.md docs/development/ && echo "  → BUNDLE_CHECKLIST.md"
[ -f "BUNDLE_INTEGRATION.md" ] && mv BUNDLE_INTEGRATION.md docs/development/ && echo "  → BUNDLE_INTEGRATION.md"

# Archive old/completed documents
echo ""
echo "Archiving old documents..."
mv *COMPLETE*.md docs/archive/ 2>/dev/null && echo "  → *COMPLETE*.md files" || true
mv *READY*.md docs/archive/ 2>/dev/null && echo "  → *READY*.md files" || true
mv README_NEW.md docs/archive/ 2>/dev/null && echo "  → README_NEW.md" || true
mv DEMO_SIMULATION.md docs/archive/ 2>/dev/null && echo "  → DEMO_SIMULATION.md" || true
mv BUILD_NOW.md docs/archive/ 2>/dev/null && echo "  → BUILD_NOW.md" || true
mv BUILD_QUICKSTART.md docs/archive/ 2>/dev/null && echo "  → BUILD_QUICKSTART.md" || true
mv BUILD.md docs/archive/ 2>/dev/null && echo "  → BUILD.md" || true
mv DISTRIBUTION_COMPARISON.md docs/archive/ 2>/dev/null && echo "  → DISTRIBUTION_COMPARISON.md" || true
mv DISTRIBUTION_CHEATSHEET.md docs/archive/ 2>/dev/null && echo "  → DISTRIBUTION_CHEATSHEET.md" || true
mv EXAMPLES_BUNDLE.md docs/archive/ 2>/dev/null && echo "  → EXAMPLES_BUNDLE.md" || true
mv 918749016749174.md docs/archive/ 2>/dev/null && echo "  → 918749016749174.md" || true

# Create index in docs
echo ""
echo "Creating documentation index..."
cat > docs/INDEX.md << 'EOF'
# MatLabC++ Documentation Index

## 📘 Guides (Start Here!)
- [Quick Start CLI](guides/QUICK_START_CLI.md) - Complete CLI usage guide
- [Build Scripts Guide](guides/BUILD_SCRIPTS_GUIDE.md) - Build system reference
- [For Normal People](guides/FOR_NORMAL_PEOPLE.md) - User-friendly introduction
- [Install Options](guides/INSTALL_OPTIONS.md) - Installation methods
- [Getting Started](guides/GETTING_STARTED.md) - Quick start tutorial

## 🏗️ Architecture
- [Codebase Review](architecture/CODEBASE_REVIEW.md) - Complete project overview
- [Bundle Architecture](architecture/BUNDLE_ARCHITECTURE.md) - Distribution system design
- [Package Management](architecture/PACKAGE_MANAGEMENT_COMPLETE.md) - Package system
- [Plotting System](architecture/PLOTTING_SYSTEM.md) - Visualization architecture
- [Features](architecture/FEATURES.md) - Feature overview

## 📖 Tutorials
- [Active Window Quickstart](tutorials/ACTIVE_WINDOW_QUICKSTART.md) - Interactive demo
- [Active Window Demo](tutorials/ACTIVE_WINDOW_DEMO.md) - Step-by-step demo
- [Math Accuracy](tutorials/MATH_ACCURACY_QUICKREF.md) - Numerical accuracy guide
- [Distribution Quickstart](tutorials/DISTRIBUTION_QUICKSTART.md) - Creating distributions

## 📚 Reference
- [Materials Database](reference/MATERIALS_DATABASE.md) - Material properties
- [Quick Reference](reference/QUICKREF.md) - Command reference
- [Bundle Quick Reference](reference/BUNDLE_QUICKREF.md) - Bundle commands
- [Math Accuracy Tests](reference/MATH_ACCURACY_TESTS.md) - Test results

## 🛠️ Development
- [Build Automation](development/BUILD_AUTOMATION_READY.md) - Build system status
- [System Status](development/SYSTEM_STATUS.md) - Current system state
- [Pre-Flight Checklist](development/PRE_FLIGHT_CHECKLIST.md) - Release checklist
- [Automation Summary](development/AUTOMATION_SUMMARY.md) - Automation overview
- [Bundle Checklist](development/BUNDLE_CHECKLIST.md) - Bundle verification
- [Bundle Integration](development/BUNDLE_INTEGRATION.md) - Integration guide

## 🗄️ Archive
Historical and superseded documents

---

**Quick Links:**
- Back to [Main README](../README.md)
- [Build & Setup Script](../build_and_setup.sh)
- [Cleanup Guide](../CLEANUP_AND_ORGANIZE.md)
EOF

echo -e "${GREEN}✓${NC} Documentation index created"

# Summary
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Cleanup Complete!                                        ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Documentation organized in docs/ with subdirectories:"
echo "  • docs/guides/        - User guides and tutorials"
echo "  • docs/architecture/  - System architecture docs"
echo "  • docs/tutorials/     - Step-by-step tutorials"
echo "  • docs/reference/     - Quick reference guides"
echo "  • docs/development/   - Development documentation"
echo "  • docs/archive/       - Old/superseded documents"
echo ""
echo "Root directory now contains only essential files."
echo ""
echo "Next steps:"
echo "  1. Review docs/INDEX.md for documentation"
echo "  2. Run ./build_and_setup.sh to build"
echo "  3. Run cd build && ./mlab++ to use"
echo ""
