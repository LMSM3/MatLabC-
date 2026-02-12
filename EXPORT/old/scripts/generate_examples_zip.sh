#!/usr/bin/env bash
# generate_examples_zip.sh
# Creates universal ZIP bundle for MatLabC++ examples
# Works on Windows, macOS, Linux - no bash/shell required for users!

set -euo pipefail

# ========== CONFIGURATION ==========
VERSION="0.3.0"
PROJECT_NAME="MatLabC++"
EXAMPLES_DIR="matlab_examples"
OUTPUT_DIR="dist"
STAGING_DIR="staging"
ZIP_NAME="matlabcpp_examples_v${VERSION}.zip"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ========== FUNCTIONS ==========

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_banner() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $PROJECT_NAME ZIP Bundle Generator"
    echo "  Version $VERSION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v zip >/dev/null 2>&1; then
        log_error "zip command not found"
        echo ""
        echo "Install with:"
        echo "  Ubuntu/Debian: sudo apt install zip"
        echo "  macOS:         brew install zip"
        echo "  Windows:       Use Git Bash or WSL"
        echo ""
        exit 1
    fi
    
    log_success "All dependencies found"
}

validate_source() {
    log_info "Validating source directory..."
    
    if [ ! -d "$EXAMPLES_DIR" ]; then
        log_error "Source directory not found: $EXAMPLES_DIR"
        exit 1
    fi
    
    # Count .m files
    m_count=$(find "$EXAMPLES_DIR" -name "*.m" -type f | wc -l)
    
    if [ "$m_count" -eq 0 ]; then
        log_error "No .m files found in $EXAMPLES_DIR"
        exit 1
    fi
    
    log_success "Found $m_count MATLAB file(s)"
}

create_staging() {
    log_info "Creating staging directory..."
    
    rm -rf "$STAGING_DIR"
    mkdir -p "$STAGING_DIR/matlabcpp_examples"
    
    log_success "Staging directory created"
}

copy_examples() {
    log_info "Copying example files..."
    
    # Copy all .m files
    cp "$EXAMPLES_DIR"/*.m "$STAGING_DIR/matlabcpp_examples/" 2>/dev/null || true
    
    # Count copied files
    copied=$(find "$STAGING_DIR/matlabcpp_examples" -name "*.m" | wc -l)
    
    log_success "Copied $copied file(s)"
}

create_readme() {
    log_info "Creating README.txt..."
    
    cat > "$STAGING_DIR/matlabcpp_examples/README.txt" <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║  MatLabC++ Examples v0.3.0                                   ║
║                                                              ║
║  Professional MATLAB-Compatible Numerical Computing          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

QUICK START
═══════════

1. Ensure MatLabC++ is installed:
   
   Windows:   mlab++.exe --version
   Mac/Linux: mlab++ --version

2. Run an example:

   mlab++ basic_demo.m
   mlab++ materials_lookup.m
   mlab++ test_math_accuracy.m

3. Or use Active Window:

   mlab++
   >> basic_demo


EXAMPLES INCLUDED
═════════════════

basic_demo.m
  Simple introduction to MatLabC++ features

materials_lookup.m
  Materials database lookup and properties

materials_optimization.m
  Material selection optimization

gpu_benchmark.m
  GPU performance testing

signal_processing.m
  Signal processing pipeline

linear_algebra.m
  Matrix operations and linear algebra

engineering_report_demo.m
  Engineering-quality plotting

business_dashboard_demo.m
  Business dashboard visualization

test_math_accuracy.m
  Mathematical accuracy verification


PLATFORM-SPECIFIC INSTRUCTIONS
═══════════════════════════════

Windows
───────
1. Open Command Prompt or PowerShell
2. Navigate to this directory:
   cd C:\path\to\matlabcpp_examples
3. Run: mlab++ basic_demo.m

Or double-click install.bat

macOS
─────
1. Open Terminal
2. Navigate to this directory:
   cd ~/Downloads/matlabcpp_examples
3. Run: mlab++ basic_demo.m

Or double-click install.sh

Linux
─────
1. Open terminal
2. Navigate to this directory:
   cd ~/Downloads/matlabcpp_examples
3. Run: mlab++ basic_demo.m

Or: bash install.sh


TROUBLESHOOTING
═══════════════

Problem: "mlab++ not found"
Solution: Ensure MatLabC++ is installed and in PATH
  Windows: set PATH=%USERPROFILE%\.local\bin;%PATH%
  Unix:    export PATH=$HOME/.local/bin:$PATH

Problem: "Permission denied"
Solution: On Unix, make files executable:
  chmod +x *.sh

Problem: Files won't run
Solution: Check MatLabC++ is installed:
  mlab++ --version


DOCUMENTATION
═════════════

Full documentation available at:
  https://github.com/yourproject/matlabcpp

README.md          - Project overview
FOR_NORMAL_PEOPLE.md - User-friendly guide
ACTIVE_WINDOW_DEMO.md - Interactive environment guide
MATH_ACCURACY_TESTS.md - Mathematical accuracy info


SUPPORT
═══════

Questions? Issues?
- GitHub: https://github.com/yourproject/matlabcpp/issues
- Email: support@yourproject.com


LICENSE
═══════

MatLabC++ is free and open-source software.
See LICENSE file for details.


VERSION INFORMATION
═══════════════════

MatLabC++: v0.3.0
Examples:  v0.3.0
Date:      2024

Enjoy numerical computing without the license fees! 🚀
EOF
    
    log_success "README.txt created"
}

create_installers() {
    log_info "Creating platform-specific installers..."
    
    # Windows batch file
    cat > "$STAGING_DIR/matlabcpp_examples/install.bat" <<'EOF'
@echo off
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║  MatLabC++ Examples Installer (Windows)                 ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

REM Check if mlab++ is installed
where mlab++ >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] mlab++ not found in PATH
    echo.
    echo Please install MatLabC++ first:
    echo   1. Download from: https://github.com/yourproject/matlabcpp
    echo   2. Run: build.bat install
    echo   3. Add to PATH: set PATH=%%USERPROFILE%%\.local\bin;%%PATH%%
    echo.
    pause
    exit /b 1
)

echo [OK] MatLabC++ found
mlab++ --version
echo.

echo Examples installed in: %CD%
echo.
echo To run an example:
echo   mlab++ basic_demo.m
echo.
echo Or start Active Window:
echo   mlab++
echo.

pause
EOF
    
    # Unix shell script
    cat > "$STAGING_DIR/matlabcpp_examples/install.sh" <<'EOF'
#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  MatLabC++ Examples Installer (Unix)                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check if mlab++ is installed
if ! command -v mlab++ >/dev/null 2>&1; then
    echo "[ERROR] mlab++ not found in PATH"
    echo ""
    echo "Please install MatLabC++ first:"
    echo "  1. Download from: https://github.com/yourproject/matlabcpp"
    echo "  2. Run: ./build.sh install"
    echo "  3. Add to PATH: export PATH=\$HOME/.local/bin:\$PATH"
    echo ""
    exit 1
fi

echo "[OK] MatLabC++ found"
mlab++ --version
echo ""

echo "Examples installed in: $(pwd)"
echo ""
echo "To run an example:"
echo "  mlab++ basic_demo.m"
echo ""
echo "Or start Active Window:"
echo "  mlab++"
echo ""
EOF
    
    chmod +x "$STAGING_DIR/matlabcpp_examples/install.sh"
    
    log_success "Platform installers created"
}

create_examples_doc() {
    log_info "Creating EXAMPLES.md..."
    
    cat > "$STAGING_DIR/matlabcpp_examples/EXAMPLES.md" <<'EOF'
# MatLabC++ Examples v0.3.0

**Complete example suite for MatLabC++ numerical computing**

---

## 📚 Examples Included

### 1. basic_demo.m
**Introduction to MatLabC++ features**

```matlab
% Basic variable operations
x = [1 2 3 4 5];
mean(x)
std(x)

% Matrix operations
A = [1 2; 3 4];
inv(A)
```

**Run:** `mlab++ basic_demo.m`

---

### 2. materials_lookup.m
**Materials database and property lookup**

```matlab
% Look up material properties
pla = material_get('pla');
fprintf('PLA density: %.0f kg/m³\n', pla.density);

% Compare materials
petg = material_get('petg');
abs_plastic = material_get('abs');
```

**Run:** `mlab++ materials_lookup.m --visual`

---

### 3. test_math_accuracy.m
**Comprehensive mathematical accuracy tests**

Verifies:
- Machine epsilon (IEEE 754 compliance)
- Matrix operations
- Special values (NaN, Inf)
- Trigonometric identities
- Complex numbers
- Statistical functions

**Run:** `mlab++ test_math_accuracy.m`

---

### 4. engineering_report_demo.m
**Engineering-quality plotting**

Features:
- Stress-strain curves
- 3D temperature distributions
- Multi-panel layouts
- 300 DPI publication quality

**Run:** `mlab++ engineering_report_demo.m`

---

### 5. business_dashboard_demo.m
**Business dashboard visualization**

Features:
- Revenue forecasts
- Market share charts
- Customer analysis
- 150 DPI presentation quality

**Run:** `mlab++ business_dashboard_demo.m`

---

## 🚀 Quick Start

### Option 1: Run Example Directly
```bash
mlab++ basic_demo.m
```

### Option 2: Use Active Window
```bash
mlab++
>> basic_demo
```

### Option 3: Interactive Testing
```bash
mlab++
>> waterData = [0 0 1 1 2 3 5 8]
>> sum(waterData)
>> test_math_accuracy
```

---

## 📖 Documentation

**Active Window Guide:**
- Interactive MATLAB-like environment
- Semicolon suppression
- Variable workspace (who, whos, clear)
- Fancy colored output

**Mathematical Accuracy:**
- 10 comprehensive tests
- IEEE 754 compliance
- MATLAB compatibility

**See:**
- README.txt (this directory)
- Full docs: https://github.com/yourproject/matlabcpp

---

**Enjoy numerical computing!** 🧮✨
EOF
    
    log_success "EXAMPLES.md created"
}

create_zip() {
    log_info "Creating ZIP archive..."
    
    mkdir -p "$OUTPUT_DIR"
    
    cd "$STAGING_DIR"
    zip -r "../$OUTPUT_DIR/$ZIP_NAME" matlabcpp_examples/ >/dev/null 2>&1
    cd ..
    
    log_success "ZIP archive created"
}

cleanup() {
    log_info "Cleaning up staging directory..."
    
    rm -rf "$STAGING_DIR"
    
    log_success "Cleanup complete"
}

show_summary() {
    local zip_path="$OUTPUT_DIR/$ZIP_NAME"
    local zip_size=$(du -h "$zip_path" | cut -f1)
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ZIP Bundle Created Successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Output: $zip_path"
    echo "  Size:   $zip_size"
    echo ""
    echo "  Distribution:"
    echo "    - Universal format (Windows, macOS, Linux)"
    echo "    - Double-click to extract (GUI)"
    echo "    - Or: unzip $ZIP_NAME"
    echo ""
    echo "  Test installation:"
    echo "    cd /tmp"
    echo "    unzip $(pwd)/$zip_path"
    echo "    cd matlabcpp_examples"
    echo "    mlab++ basic_demo.m"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# ========== MAIN ==========

main() {
    print_banner
    check_dependencies
    validate_source
    create_staging
    copy_examples
    create_readme
    create_installers
    create_examples_doc
    create_zip
    cleanup
    show_summary
}

main "$@"
