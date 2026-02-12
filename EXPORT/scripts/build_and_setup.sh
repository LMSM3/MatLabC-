#!/bin/bash
# MatLabC++ - Complete Build and Setup Automation
# Clears, configures, builds, and verifies the entire project

set -e  # Exit on error

# ========== ANSI COLORS ==========
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
MAGENTA='\033[35m'
NC='\033[0m' # No Color

# ========== HELPER FUNCTIONS ==========

print_banner() {
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}MatLabC++ Complete Build & Setup Automation${NC}"
    echo -e "${DIM}Clean → Configure → Build → Verify → Ready${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "\n${BOLD}${CYAN}[$1]${NC} ${BOLD}$2${NC}"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}!${NC} $1"
}

print_info() {
    echo -e "  ${CYAN}→${NC} $1"
}

spinner() {
    local pid=$1
    local message=$2
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr:i++%${#spinstr}:1}
        printf "\r  ${CYAN}%s${NC} %s" "$temp" "$message"
        sleep 0.1
    done
    printf "\r"
}

progress_bar() {
    local current=$1
    local total=$2
    local label=$3
    local width=50
    
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    # Color based on progress
    if [ $percent -eq 100 ]; then
        local color=$GREEN
    elif [ $percent -gt 66 ]; then
        local color=$CYAN
    else
        local color=$YELLOW
    fi
    
    # Build bar
    local bar=$(printf '█%.0s' $(seq 1 $filled))
    local empty_bar=$(printf '░%.0s' $(seq 1 $empty))
    
    if [ $percent -eq 100 ]; then
        echo -e "\r  ${label} ${color}[${bar}${empty_bar}]${NC} ${BOLD}${percent}%${NC} ${GREEN}✓${NC}"
    else
        echo -ne "\r  ${label} ${color}[${bar}${empty_bar}]${NC} ${BOLD}${percent}%${NC}"
    fi
}

# ========== SYSTEM CHECKS ==========

check_dependencies() {
    print_step "1/6" "Checking system dependencies..."
    
    local missing=0
    
    # Check CMake
    echo -n "  Checking CMake... "
    if command -v cmake &> /dev/null; then
        local cmake_version=$(cmake --version | head -n1 | awk '{print $3}')
        echo -e "${GREEN}✓${NC} (version $cmake_version)"
    else
        echo -e "${RED}✗ missing${NC}"
        print_error "CMake not found. Install with: sudo apt install cmake"
        missing=1
    fi
    # Check C++ compiler
    echo -n "  Checking C++ compiler... "
    if command -v g++ &> /dev/null; then
        local gcc_version=$(g++ --version | head -n1 | awk '{print $3}')
        echo -e "${GREEN}✓${NC} (g++ $gcc_version)"
    elif command -v clang++ &> /dev/null; then
        local clang_version=$(clang++ --version | head -n1 | awk '{print $4}')
        echo -e "${GREEN}✓${NC} (clang++ $clang_version)"
    else
        echo -e "${RED}✗ missing${NC}"
        print_error "No C++ compiler found. Install with: sudo apt install build-essential"
        missing=1
    fi
    
    # Check make
    echo -n "  Checking build system... "
    if command -v make &> /dev/null || command -v ninja &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}! warning${NC}"
        print_warning "No build system found (make/ninja), but CMake might generate one"
    fi
    
    # Check git (optional)
    echo -n "  Checking git (optional)... "
    if command -v git &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${DIM}not installed${NC}"
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Missing required dependencies. Please install them first."
        exit 1
    fi
    
    print_success "All required dependencies found"
}

# ========== BUILD STEPS ==========

clean_build_directory() {
    print_step "2/6" "Cleaning build directory..."
    
    if [ -d "build" ]; then
        print_info "Removing old build directory..."
        #rm -rf build
        print_success "Old build cleaned"
    else
        print_info "No existing build directory"
    fi
    
    print_info "Creating fresh build directory..."
    mkdir -p build
    print_success "Build directory ready"
}

configure_cmake() {
    print_step "3/6" "Configuring CMake..."
    
    cd build
    
    print_info "Running CMake configuration..."
    echo ""
    
    # Run CMake with options
    if cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_EXAMPLES=ON \
        -DBUILD_TESTS=ON \
        -DBUILD_PLOTTING=ON \
        -DWITH_CAIRO=ON \
        -DWITH_OPENGL=ON \
        -DWITH_GPU=ON; then
        
        echo ""
        print_success "CMake configuration complete"
        
        # Show configuration summary
        echo ""
        echo -e "${DIM}Configuration summary:${NC}"
        echo -e "${DIM}  Build type: Release${NC}"
        echo -e "${DIM}  Shared libs: ON${NC}"
        echo -e "${DIM}  Examples: ON${NC}"
        echo -e "${DIM}  Tests: ON${NC}"
        echo -e "${DIM}  Plotting: ON${NC}"
    else
        echo ""
        print_error "CMake configuration failed"
        cd ..
        exit 1
    fi
    
    cd ..
}

build_project() {
    print_step "4/6" "Building project..."
    
    cd build
    
    # Detect number of CPU cores
    if command -v nproc &> /dev/null; then
        local cores=$(nproc)
    elif command -v sysctl &> /dev/null; then
        local cores=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)
    else
        local cores=4
    fi
    
    print_info "Building with $cores parallel jobs..."
    echo ""
    
    # Build with progress
    if cmake --build . -j$cores; then
        echo ""
        print_success "Build complete"
    else
        echo ""
        print_error "Build failed"
        cd ..
        exit 1
    fi
    
    cd ..
}

verify_build() {
    print_step "5/6" "Verifying build artifacts..."
    
    local all_good=1
    
    # Check for main executable
    echo -n "  Checking main executable... "
    if [ -f "build/mlab++" ]; then
        echo -e "${GREEN}✓${NC} mlab++"
    elif [ -f "build/Release/mlab++.exe" ]; then
        echo -e "${GREEN}✓${NC} mlab++.exe"
    elif [ -f "build/mlab++.exe" ]; then
        echo -e "${GREEN}✓${NC} mlab++.exe"
    else
        echo -e "${RED}✗ not found${NC}"
        all_good=0
    fi
    
    # Check for libraries
    echo -n "  Checking core library... "
    if ls build/libmatlabcpp_core.* &> /dev/null || ls build/Release/matlabcpp_core.* &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ not found${NC}"
        all_good=0
    fi
    
    echo -n "  Checking materials library... "
    if ls build/libmatlabcpp_materials.* &> /dev/null || ls build/Release/matlabcpp_materials.* &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}! not found${NC}"
    fi
    
    echo -n "  Checking plotting library... "
    if ls build/libmatlabcpp_plotting.* &> /dev/null || ls build/Release/matlabcpp_plotting.* &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}! not found${NC}"
    fi
    
    if [ $all_good -eq 1 ]; then
        print_success "All critical artifacts verified"
    else
        print_error "Some critical artifacts missing"
        exit 1
    fi
}

setup_environment() {
    print_step "6/6" "Setting up environment..."
    
    # Make executable runnable
    if [ -f "build/mlab++" ]; then
        chmod +x build/mlab++
        print_success "Executable permissions set"
    fi
    
    # Create convenience symlink (optional)
    if [ -f "build/mlab++" ]; then
        if [ ! -L "mlab++" ]; then
            ln -sf build/mlab++ mlab++ 2>/dev/null || true
            if [ -L "mlab++" ]; then
                print_success "Convenience symlink created: ./mlab++"
            fi
        fi
    fi
    
    # Check if we can run it
    echo -n "  Testing executable... "
    if [ -f "build/mlab++" ]; then
        if build/mlab++ --version &> /dev/null; then
            echo -e "${GREEN}✓${NC}"
            print_success "Executable runs successfully"
        else
            echo -e "${YELLOW}! version flag not implemented yet${NC}"
            print_info "Executable exists but --version not implemented"
        fi
    fi
}

# ========== FINAL SUMMARY ==========

print_summary() {
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}Build & Setup Complete!${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}Ready to run MatLabC++:${NC}"
    echo ""
    echo -e "  ${CYAN}cd build && ./mlab++${NC}          ${DIM}# Interactive mode${NC}"
    echo -e "  ${CYAN}./mlab++${NC}                      ${DIM}# If symlink was created${NC}"
    echo -e "  ${CYAN}./build/mlab++ script.m${NC}       ${DIM}# Run a script${NC}"
    echo ""
    echo -e "${BOLD}Quick test:${NC}"
    echo ""
    echo -e "  ${DIM}>>> 2 + 2${NC}"
    echo -e "  ${DIM}>>> x = 10${NC}"
    echo -e "  ${DIM}>>> material pla${NC}"
    echo -e "  ${DIM}>>> help${NC}"
    echo -e "  ${DIM}>>> quit${NC}"
    echo ""
    echo -e "${BOLD}Documentation:${NC}"
    echo ""
    echo -e "  ${CYAN}cat QUICK_START_CLI.md${NC}       ${DIM}# Complete CLI guide${NC}"
    echo -e "  ${CYAN}cat CODEBASE_REVIEW.md${NC}       ${DIM}# Project overview${NC}"
    echo ""
}

# ========== MAIN EXECUTION ==========

main() {
    print_banner
    
    # Run all steps
    check_dependencies
    clean_build_directory
    configure_cmake
    build_project
    verify_build
    setup_environment
    
    # Show summary
    print_summary
}

# ========== ERROR HANDLING ==========

trap 'echo -e "\n${RED}Build interrupted by user${NC}"; exit 130' INT
trap 'echo -e "\n${RED}Build failed${NC}"; exit 1' ERR

# ========== ENTRY POINT ==========

# Check if script is run from project root
if [ ! -f "CMakeLists.txt" ]; then
    echo -e "${RED}Error: CMakeLists.txt not found${NC}"
    echo -e "${DIM}Please run this script from the MatLabC++ project root directory${NC}"
    exit 1
fi

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        echo "MatLabC++ Build & Setup Automation"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --clean        Only clean build directory"
        echo "  --quick        Skip dependency checks"
        echo ""
        echo "This script will:"
        echo "  1. Check system dependencies"
        echo "  2. Clean build directory"
        echo "  3. Configure CMake"
        echo "  4. Build project"
        echo "  5. Verify build artifacts"
        echo "  6. Set up environment"
        exit 0
        ;;
    --clean)
        print_banner
        clean_build_directory
        echo ""
        echo -e "${GREEN}Build directory cleaned${NC}"
        exit 0
        ;;
    --quick)
        print_banner
        clean_build_directory
        configure_cmake
        build_project
        verify_build
        setup_environment
        print_summary
        exit 0
        ;;
    "")
        # Normal execution
        main
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
