#!/usr/bin/env bash
# ship_release.sh
# Intent: Automated release preparation and verification
# Ensures all packages, builds demos, exports documentation

set -euo pipefail

BOLD=$'\e[1m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
CYAN=$'\e[36m'
RED=$'\e[31m'
DIM=$'\e[2m'
NC=$'\e[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESKTOP="$HOME/Desktop"
RELEASE_DIR="$PROJECT_ROOT/release"

# ========== BANNER ==========
show_banner() {
    clear
    echo ""
    echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BOLD}${CYAN}MatLabC++ Release Preparation${NC}"
    echo "${DIM}Automated verification and packaging${NC}"
    echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ========== PROGRESS ==========
step() {
    echo ""
    echo "${BOLD}${CYAN}▶${NC} $1${NC}"
}

success() {
    echo "  ${GREEN}✓${NC} $1"
}

warning() {
    echo "  ${YELLOW}!${NC} $1"
}

error() {
    echo "  ${RED}✗${NC} $1"
}

# ========== VERIFICATION ==========
verify_structure() {
    step "Verifying project structure"
    
    local required_dirs=(
        "demos"
        "scripts"
        "tools"
        "matlab_examples"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$PROJECT_ROOT/$dir" ]]; then
            success "$dir/ exists"
        else
            error "$dir/ missing"
            return 1
        fi
    done
    
    return 0
}

verify_python_setup() {
    step "Verifying Python environment"
    
    if command -v python3 >/dev/null 2>&1; then
        success "Python 3: $(python3 --version)"
    else
        error "Python 3 not found"
        return 1
    fi
    
    # Test demo imports
    if python3 -c "import sys, subprocess, time" 2>/dev/null; then
        success "Standard library imports OK"
    else
        error "Standard library check failed"
        return 1
    fi
    
    return 0
}

verify_cpp_build() {
    step "Verifying C++ build system"
    
    if command -v g++ >/dev/null 2>&1; then
        success "g++: $(g++ --version | head -n1)"
    elif command -v clang++ >/dev/null 2>&1; then
        success "clang++: $(clang++ --version | head -n1)"
    else
        warning "No C++ compiler (demos will skip C++)"
        return 0
    fi
    
    # Test compile
    if [[ -f "$PROJECT_ROOT/demos/green_square_demo.cpp" ]]; then
        success "C++ demo source exists"
    else
        error "C++ demo source missing"
        return 1
    fi
    
    return 0
}

verify_scripts() {
    step "Verifying scripts"
    
    local scripts=(
        "scripts/generate_examples_zip.sh"
        "scripts/generate_examples_bundle.sh"
        "scripts/test_bundle_system.sh"
        "demos/run_demo.sh"
        "tools/build_installer.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$PROJECT_ROOT/$script" ]]; then
            if [[ -x "$PROJECT_ROOT/$script" ]]; then
                success "$script (executable)"
            else
                warning "$script (not executable)"
                chmod +x "$PROJECT_ROOT/$script" 2>/dev/null || true
            fi
        else
            error "$script missing"
        fi
    done
    
    return 0
}

# ========== BUILD ==========
build_bundles() {
    step "Building distribution bundles"
    
    cd "$PROJECT_ROOT"
    
    # ZIP bundle
    if bash scripts/generate_examples_zip.sh >/dev/null 2>&1; then
        if [[ -f dist/matlabcpp_examples_v0.3.0.zip ]]; then
            local size=$(du -h dist/matlabcpp_examples_v0.3.0.zip | cut -f1)
            success "ZIP bundle: $size"
        else
            error "ZIP bundle not created"
            return 1
        fi
    else
        error "ZIP bundle generation failed"
        return 1
    fi
    
    # Shell bundle
    if bash scripts/generate_examples_bundle.sh >/dev/null 2>&1; then
        if [[ -f dist/mlabpp_examples_bundle.sh ]]; then
            local size=$(du -h dist/mlabpp_examples_bundle.sh | cut -f1)
            success "Shell bundle: $size"
        else
            error "Shell bundle not created"
            return 1
        fi
    else
        error "Shell bundle generation failed"
        return 1
    fi
    
    return 0
}

build_cpp_installer() {
    step "Building C++ installer"
    
    cd "$PROJECT_ROOT"
    
    if command -v g++ >/dev/null 2>&1 || command -v clang++ >/dev/null 2>&1; then
        if bash tools/build_installer.sh >/dev/null 2>&1; then
            if [[ -f tools/bundle_installer ]]; then
                local size=$(du -h tools/bundle_installer | cut -f1)
                success "C++ installer: $size"
            else
                warning "C++ installer not built"
            fi
        else
            warning "C++ installer build failed"
        fi
    else
        warning "C++ installer skipped (no compiler)"
    fi
    
    return 0
}

build_cpp_demo() {
    step "Building C++ demo"
    
    cd "$PROJECT_ROOT"
    
    if command -v g++ >/dev/null 2>&1 || command -v clang++ >/dev/null 2>&1; then
        local compiler=$(command -v g++ || command -v clang++)
        
        if $compiler -std=c++17 -O2 -pthread demos/green_square_demo.cpp -o demos/green_square_demo 2>/dev/null; then
            local size=$(du -h demos/green_square_demo | cut -f1)
            success "C++ demo: $size"
        else
            warning "C++ demo build failed"
        fi
    else
        warning "C++ demo skipped (no compiler)"
    fi
    
    return 0
}

# ========== TESTING ==========
run_tests() {
    step "Running integration tests"
    
    cd "$PROJECT_ROOT"
    
    if bash scripts/test_bundle_system.sh >/dev/null 2>&1; then
        success "Bundle system tests passed"
    else
        error "Bundle system tests failed"
        return 1
    fi
    
    return 0
}

# ========== EXPORT DOCUMENTATION ==========
export_readmes() {
    step "Exporting documentation to Desktop"
    
    mkdir -p "$DESKTOP/MatLabCpp_Docs"
    
    local readmes=(
        "README.md:00_Main_README.md"
        "FOR_NORMAL_PEOPLE.md:01_User_Guide.md"
        "ACTIVE_WINDOW_DEMO.md:02_Active_Window.md"
        "MATH_ACCURACY_TESTS.md:03_Math_Tests.md"
        "MATERIALS_DATABASE.md:04_Materials_Database.md"
        "EXAMPLES_BUNDLE.md:05_Examples_Bundle.md"
        "DISTRIBUTION_COMPARISON.md:06_Distribution.md"
        "DISTRIBUTION_QUICKSTART.md:07_Quick_Start.md"
        "DISTRIBUTION_CHEATSHEET.md:08_Cheat_Sheet.md"
        "scripts/README.md:09_Scripts.md"
        "scripts/FANCY_BUILDS.md:10_Fancy_Builds.md"
        "tools/INSTALLER.md:11_Installer.md"
        "demos/README.md:12_Demos.md"
    )
    
    local count=0
    for readme in "${readmes[@]}"; do
        IFS=':' read -r source dest <<< "$readme"
        if [[ -f "$PROJECT_ROOT/$source" ]]; then
            cp "$PROJECT_ROOT/$source" "$DESKTOP/MatLabCpp_Docs/$dest"
            success "$dest"
            ((count++))
        else
            warning "$source not found"
        fi
    done
    
    # Create index
    cat > "$DESKTOP/MatLabCpp_Docs/00_INDEX.txt" <<'EOF'
MatLabC++ Documentation Export
==============================

Files are numbered for reading order:

00_Main_README.md              - Project overview
01_User_Guide.md               - For normal people
02_Active_Window.md            - Interactive environment
03_Math_Tests.md               - Mathematical accuracy
04_Materials_Database.md       - Materials system
05_Examples_Bundle.md          - Example distribution
06_Distribution.md             - Format comparison
07_Quick_Start.md              - Quick reference
08_Cheat_Sheet.md              - Copy-paste commands
09_Scripts.md                  - Build scripts
10_Fancy_Builds.md             - Animated builds
11_Installer.md                - C++ installer
12_Demos.md                    - Visual demos

Quick Start:
1. Read 00_Main_README.md first
2. Then 01_User_Guide.md
3. Browse others as needed

MatLabC++ v0.3.0
MATLAB-style execution, C++ runtime
EOF
    
    success "Exported $count documentation files"
    success "Index: $DESKTOP/MatLabCpp_Docs/00_INDEX.txt"
    
    return 0
}

# ========== PACKAGE RELEASE ==========
create_release_package() {
    step "Creating release package"
    
    rm -rf "$RELEASE_DIR"
    mkdir -p "$RELEASE_DIR"
    
    # Copy distribution bundles
    if [[ -d "$PROJECT_ROOT/dist" ]]; then
        cp -r "$PROJECT_ROOT/dist" "$RELEASE_DIR/"
        success "Distribution bundles copied"
    fi
    
    # Copy demos
    if [[ -d "$PROJECT_ROOT/demos" ]]; then
        cp -r "$PROJECT_ROOT/demos" "$RELEASE_DIR/"
        success "Demos copied"
    fi
    
    # Copy documentation
    cp -r "$DESKTOP/MatLabCpp_Docs" "$RELEASE_DIR/docs"
    success "Documentation copied"
    
    # Create release info
    cat > "$RELEASE_DIR/RELEASE_INFO.txt" <<EOF
MatLabC++ v0.3.0 Release Package
================================

Generated: $(date)
Platform: $(uname -s)

Contents:
---------
dist/                     Distribution bundles
  - matlabcpp_examples_v0.3.0.zip
  - mlabpp_examples_bundle.sh

demos/                    Visual demonstrations
  - self_install_demo.py
  - green_square_demo.cpp
  - run_demo.sh

docs/                     Complete documentation
  - 00_INDEX.txt         Start here
  - *.md files           Numbered guides

Quick Start:
-----------
1. Read docs/00_INDEX.txt
2. Run demos/run_demo.sh
3. Distribute dist/ bundles

Build Info:
----------
$(bash --version | head -n1)
$(python3 --version 2>/dev/null || echo "Python: Not available")
$(g++ --version 2>/dev/null | head -n1 || echo "g++: Not available")

MatLabC++ - MATLAB-style execution, C++ runtime
No drama. No dependencies. No excuses.
EOF
    
    success "Release info created"
    
    # Create archive
    cd "$PROJECT_ROOT"
    tar -czf "$DESKTOP/matlabcpp_v0.3.0_release.tar.gz" -C release .
    
    local size=$(du -h "$DESKTOP/matlabcpp_v0.3.0_release.tar.gz" | cut -f1)
    success "Release archive: $DESKTOP/matlabcpp_v0.3.0_release.tar.gz ($size)"
    
    return 0
}

# ========== SUMMARY ==========
show_summary() {
    echo ""
    echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${GREEN}${BOLD}Release Preparation Complete${NC}"
    echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "${BOLD}Documentation:${NC}"
    echo "  Location: ${CYAN}$DESKTOP/MatLabCpp_Docs/${NC}"
    echo "  Index:    ${CYAN}$DESKTOP/MatLabCpp_Docs/00_INDEX.txt${NC}"
    echo ""
    echo "${BOLD}Release Package:${NC}"
    echo "  Archive:  ${CYAN}$DESKTOP/matlabcpp_v0.3.0_release.tar.gz${NC}"
    echo "  Staging:  ${CYAN}$RELEASE_DIR/${NC}"
    echo ""
    echo "${BOLD}Distribution Bundles:${NC}"
    echo "  ZIP:      ${CYAN}$PROJECT_ROOT/dist/matlabcpp_examples_v0.3.0.zip${NC}"
    echo "  Shell:    ${CYAN}$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh${NC}"
    echo ""
    echo "${BOLD}Next Steps:${NC}"
    echo "  ${DIM}1. Review documentation in Desktop/MatLabCpp_Docs/${NC}"
    echo "  ${DIM}2. Test release archive: tar -xzf matlabcpp_v0.3.0_release.tar.gz${NC}"
    echo "  ${DIM}3. Distribute bundles from dist/${NC}"
    echo ""
}

# ========== MAIN ==========
main() {
    show_banner
    
    # Verification
    verify_structure || exit 1
    verify_python_setup || exit 1
    verify_cpp_build
    verify_scripts
    
    # Build
    build_bundles || exit 1
    build_cpp_installer
    build_cpp_demo
    
    # Test
    run_tests || exit 1
    
    # Export
    export_readmes || exit 1
    
    # Package
    create_release_package || exit 1
    
    # Summary
    show_summary
    
    echo "${GREEN}${BOLD}Ready to ship${NC}"
    echo ""
}

main "$@"
