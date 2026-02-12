#!/usr/bin/env bash
# run_demo.sh
# Intent: One-command demo execution with self-installation
# Automatically handles all dependencies

set -euo pipefail

BOLD=$'\e[1m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
CYAN=$'\e[36m'
RED=$'\e[31m'
DIM=$'\e[2m'
NC=$'\e[0m'

echo ""
echo "${BOLD}${CYAN}MatLabC++ Visual Demo Launcher${NC}"
echo "${DIM}Automatic dependency installation${NC}"
echo ""

# ========== DETECT PYTHON ==========
check_python() {
    if command -v python3 >/dev/null 2>&1; then
        PYTHON="python3"
        return 0
    elif command -v python >/dev/null 2>&1; then
        PYTHON="python"
        return 0
    else
        return 1
    fi
}

# ========== DETECT C++ COMPILER ==========
check_compiler() {
    if command -v g++ >/dev/null 2>&1; then
        COMPILER="g++"
        return 0
    elif command -v clang++ >/dev/null 2>&1; then
        COMPILER="clang++"
        return 0
    else
        return 1
    fi
}

# ========== MAIN MENU ==========
show_menu() {
    echo "${BOLD}Choose demo version:${NC}"
    echo ""
    echo "  ${CYAN}1.${NC} Python (matplotlib) - Auto-installs packages"
    echo "  ${CYAN}2.${NC} C++ (ASCII) - No dependencies"
    echo "  ${CYAN}3.${NC} C++ (ASCII) - Animated"
    echo ""
}

# ========== RUN PYTHON DEMO ==========
run_python_demo() {
    echo "${BOLD}Launching Python demo...${NC}"
    echo ""
    
    if ! check_python; then
        echo "${RED}Python not found${NC}"
        echo ""
        echo "Install Python:"
        echo "  Ubuntu/Debian: sudo apt install python3"
        echo "  macOS:         brew install python3"
        echo "  Windows:       Download from python.org"
        return 1
    fi
    
    echo "${GREEN}✓${NC} Found: $($PYTHON --version)"
    echo ""
    
    # Make executable
    chmod +x demos/self_install_demo.py 2>/dev/null || true
    
    # Run demo (it will self-install packages)
    $PYTHON demos/self_install_demo.py
}

# ========== RUN C++ DEMO ==========
run_cpp_demo() {
    local animate=$1
    
    echo "${BOLD}Launching C++ demo...${NC}"
    echo ""
    
    # Check if compiled
    if [[ ! -f demos/green_square_demo ]]; then
        echo "${YELLOW}Compiling C++ demo...${NC}"
        echo ""
        
        if ! check_compiler; then
            echo "${RED}C++ compiler not found${NC}"
            echo ""
            echo "Install compiler:"
            echo "  Ubuntu/Debian: sudo apt install g++"
            echo "  macOS:         xcode-select --install"
            return 1
        fi
        
        echo "${GREEN}✓${NC} Found: $COMPILER"
        echo ""
        
        # Compile
        echo "Compiling..."
        $COMPILER -std=c++17 -O2 -pthread demos/green_square_demo.cpp -o demos/green_square_demo
        
        if [[ $? -eq 0 ]]; then
            echo "${GREEN}✓${NC} Compilation successful"
            echo ""
        else
            echo "${RED}✗${NC} Compilation failed"
            return 1
        fi
    fi
    
    # Run demo
    if [[ $animate == "true" ]]; then
        ./demos/green_square_demo --animate
    else
        ./demos/green_square_demo
    fi
}

# ========== INTERACTIVE MODE ==========
interactive() {
    show_menu
    
    read -p "${BOLD}Enter choice [1-3, default=1]:${NC} " choice
    echo ""
    
    case "$choice" in
        2)
            run_cpp_demo false
            ;;
        3)
            run_cpp_demo true
            ;;
        1|"")
            run_python_demo
            ;;
        *)
            echo "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
}

# ========== NON-INTERACTIVE MODE ==========
if [[ $# -gt 0 ]]; then
    case "$1" in
        --python)
            run_python_demo
            ;;
        --cpp)
            run_cpp_demo false
            ;;
        --cpp-animate)
            run_cpp_demo true
            ;;
        *)
            echo "Usage: $0 [--python|--cpp|--cpp-animate]"
            exit 1
            ;;
    esac
else
    interactive
fi

echo ""
echo "${GREEN}${BOLD}Demo complete${NC}"
echo ""
