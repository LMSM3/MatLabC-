#!/usr/bin/env bash
# build.sh - Complete build script for MatLabC++ v0.3.0
#
# Usage:
#   ./build.sh              # Full build
#   ./build.sh clean        # Clean build
#   ./build.sh install      # Build and install
#   ./build.sh package      # Create distribution package

set -euo pipefail

# ========== CONFIGURATION ==========
PROJECT_NAME="MatLabC++"
VERSION="0.3.0"
BUILD_DIR="build"
INSTALL_PREFIX="${HOME}/.local"
NUM_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $PROJECT_NAME v$VERSION Build System"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing=()
    
    # Required
    command -v cmake >/dev/null 2>&1 || missing+=("cmake")
    command -v g++ >/dev/null 2>&1 || missing+=("g++")
    command -v make >/dev/null 2>&1 || missing+=("make")
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        echo "  Ubuntu/Debian: sudo apt install cmake g++ make"
        echo "  Fedora/RHEL:   sudo dnf install cmake gcc-c++ make"
        echo "  macOS:         brew install cmake"
        echo ""
        exit 1
    fi
    
    # Optional
    local optional=()
    command -v pkg-config >/dev/null 2>&1 || optional+=("pkg-config")
    
    if [ ${#optional[@]} -ne 0 ]; then
        log_warn "Optional dependencies missing: ${optional[*]}"
        log_warn "Some features may be disabled"
    fi
    
    log_success "All required dependencies found"
}

detect_features() {
    log_info "Detecting optional features..."
    
    # Cairo
    if pkg-config --exists cairo 2>/dev/null; then
        log_success "Cairo found (plotting backend available)"
        HAVE_CAIRO=ON
    else
        log_warn "Cairo not found (plotting will use fallback)"
        HAVE_CAIRO=OFF
    fi
    
    # OpenGL
    if pkg-config --exists gl 2>/dev/null; then
        log_success "OpenGL found (3D plotting available)"
        HAVE_OPENGL=ON
    else
        log_warn "OpenGL not found (3D plotting disabled)"
        HAVE_OPENGL=OFF
    fi
    
    # CUDA
    if command -v nvcc >/dev/null 2>&1; then
        log_success "CUDA found (GPU acceleration available)"
        HAVE_CUDA=ON
    else
        log_warn "CUDA not found (GPU features disabled)"
        HAVE_CUDA=OFF
    fi
}

clean_build() {
    log_info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    log_success "Build directory cleaned"
}

configure_cmake() {
    log_info "Configuring CMake..."
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_EXAMPLES=ON \
        -DBUILD_PLOTTING=ON \
        -DWITH_CAIRO="$HAVE_CAIRO" \
        -DWITH_OPENGL="$HAVE_OPENGL" \
        -DWITH_GPU="$HAVE_CUDA"
    
    cd ..
    log_success "CMake configuration complete"
}

build_project() {
    log_info "Building project with $NUM_JOBS parallel jobs..."
    
    cd "$BUILD_DIR"
    make -j"$NUM_JOBS"
    cd ..
    
    log_success "Build complete"
}

run_tests() {
    log_info "Running tests..."
    
    cd "$BUILD_DIR"
    ctest --output-on-failure
    cd ..
    
    log_success "All tests passed"
}

install_project() {
    log_info "Installing to $INSTALL_PREFIX..."
    
    cd "$BUILD_DIR"
    make install
    cd ..
    
    log_success "Installation complete"
}

create_package() {
    log_info "Creating distribution package..."
    
    cd "$BUILD_DIR"
    cpack
    cd ..
    
    log_success "Package created: $BUILD_DIR/MatLabCPlusPlus-$VERSION-*.tar.gz"
}

build_bundles() {
    log_info "Building example bundles..."
    
    if [ -f "scripts/generate_examples_bundle.sh" ]; then
        bash scripts/generate_examples_bundle.sh
        log_success "Example bundles created"
    else
        log_warn "Bundle script not found, skipping"
    fi
}

show_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Build Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Project:          $PROJECT_NAME v$VERSION"
    echo "Build directory:  $BUILD_DIR"
    echo "Install prefix:   $INSTALL_PREFIX"
    echo ""
    echo "Features:"
    echo "  Cairo:          $HAVE_CAIRO"
    echo "  OpenGL:         $HAVE_OPENGL"
    echo "  CUDA:           $HAVE_CUDA"
    echo ""
    echo "Executables:"
    echo "  mlab++          Main interpreter"
    echo "  mlab_pkg        Package manager"
    echo ""
    echo "Libraries:"
    echo "  libmatlabcpp_core.so         Core functionality"
    echo "  libmatlabcpp_materials.so    Materials database"
    echo "  libmatlabcpp_plotting.so     Plotting system"
    echo "  libmatlabcpp_pkg.so          Package manager"
    echo ""
    echo "Next steps:"
    echo "  1. Add to PATH:  export PATH=\"$INSTALL_PREFIX/bin:\$PATH\""
    echo "  2. Run demo:     mlab++ matlab_examples/basic_demo.m"
    echo "  3. Install pkg:  mlab++ pkg install materials_smart"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# ========== MAIN ==========
main() {
    print_banner
    
    # Parse command
    COMMAND="${1:-build}"
    
    case "$COMMAND" in
        clean)
            clean_build
            ;;
            
        configure)
            check_dependencies
            detect_features
            clean_build
            configure_cmake
            ;;
            
        build)
            check_dependencies
            detect_features
            configure_cmake
            build_project
            show_summary
            ;;
            
        test)
            build_project
            run_tests
            ;;
            
        install)
            check_dependencies
            detect_features
            configure_cmake
            build_project
            install_project
            build_bundles
            show_summary
            ;;
            
        package)
            check_dependencies
            detect_features
            configure_cmake
            build_project
            create_package
            build_bundles
            log_success "Package ready for distribution"
            ;;
            
        all)
            check_dependencies
            detect_features
            clean_build
            configure_cmake
            build_project
            run_tests
            install_project
            create_package
            build_bundles
            show_summary
            ;;
            
        help|--help|-h)
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  clean       Clean build directory"
            echo "  configure   Configure CMake"
            echo "  build       Build project (default)"
            echo "  test        Run tests"
            echo "  install     Build and install"
            echo "  package     Create distribution package"
            echo "  all         Clean, build, test, install, package"
            echo "  help        Show this help"
            echo ""
            echo "Examples:"
            echo "  $0              # Quick build"
            echo "  $0 install      # Build and install to ~/.local"
            echo "  $0 package      # Create release package"
            echo ""
            ;;
            
        *)
            log_error "Unknown command: $COMMAND"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
}

# Run main
main "$@"
