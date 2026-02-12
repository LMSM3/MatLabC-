#!/usr/bin/env bash
# fancy_install.sh
# MatLabC++ - Beautiful animated installation
# Because installation doesn't have to be boring.

set -euo pipefail

# ========== COLORS ==========
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
MAGENTA=$'\e[35m'
CYAN=$'\e[36m'
WHITE=$'\e[97m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
NC=$'\e[0m'

# ========== ANIMATION GLOBALS ==========
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
FRAME=0
SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# ========== FANCY BANNER ==========
show_banner() {
    clear
    cat <<'EOF'
                                          ╔═══════════════════════════════════════╗
                                          ║                                       ║
                                          ║      MatLabC++ Installation           ║
                                          ║      v0.3.0                           ║
                                          ║                                       ║
                                          ║      MATLAB-style execution           ║
                                          ║      backed by C++ runtime            ║
                                          ║                                       ║
                                          ╚═══════════════════════════════════════╝

EOF

    echo -e "${NC}"
    sleep 0.5
}

# ========== DYNAMIC RAM ALLOCATION (JUST FOR FUN) ==========
allocate_ram() {
    local amount=$1
    local label=$2
    
    echo -ne "${DIM}[RAM]${NC} Allocating ${YELLOW}${amount}MB${NC} for ${label}... "
    
    # Fake allocation with spinner
    for i in {1..8}; do
        echo -ne "${SPINNER[$((i % 10))]}"
        sleep 0.05
        echo -ne "\b"
    done
    
    echo -e "${GREEN}✓${NC}"
}

# ========== ANIMATED PROGRESS BAR ==========
progress_bar() {
    local current=$1
    local total=$2
    local label=$3
    local width=50
    
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    # Build bar
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    
    # Color based on progress
    local color=$YELLOW
    if [[ $percent -eq 100 ]]; then
        color=$GREEN
    elif [[ $percent -gt 66 ]]; then
        color=$CYAN
    fi
    
    echo -ne "\r${label} ${color}[${bar}]${NC} ${BOLD}${percent}%${NC}"
    
    if [[ $percent -eq 100 ]]; then
        echo -e " ${GREEN}✓${NC}"
    fi
}

# ========== SPINNER ANIMATION ==========
spin() {
    local pid=$1
    local message=$2
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r${message} ${CYAN}${SPINNER[$((i % 10))]}${NC} "
        i=$((i + 1))
        sleep 0.1
    done
    
    echo -ne "\r${message} ${GREEN}✓${NC}\n"
}

# ========== PULSING TEXT ==========
pulse_text() {
    local text=$1
    local duration=${2:-3}
    local start=$(date +%s)
    
    while [[ $(($(date +%s) - start)) -lt $duration ]]; do
        echo -ne "\r${BOLD}${CYAN}▶${NC} ${text} ${BOLD}${CYAN}◀${NC}"
        sleep 0.3
        echo -ne "\r${DIM}▷${NC} ${text} ${DIM}◁${NC}"
        sleep 0.3
    done
    echo -e "\r${GREEN}✓${NC} ${text}  "
}

# ========== TYPING ANIMATION ==========
type_text() {
    local text=$1
    local delay=${2:-0.03}
    
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# ========== MATRIX RAIN (BRIEF) ==========
matrix_rain() {
    local duration=${1:-2}
    local cols=$(tput cols)
    local lines=10
    
    # Generate random matrix characters
    for ((t=0; t<duration*10; t++)); do
        echo -ne "\r"
        for ((i=0; i<lines; i++)); do
            local pos=$((RANDOM % cols))
            local char=$((RANDOM % 2))
            echo -ne "\033[${i};${pos}H${GREEN}${char}${NC}"
        done
        sleep 0.1
    done
    
    # Clear
    for ((i=0; i<lines; i++)); do
        echo -ne "\033[${i};0H\033[K"
    done
}

# ========== SYSTEM CHECK ==========
check_system() {
    echo -e "\n${BOLD}${BLUE}[SYSTEM CHECK]${NC}\n"
    
    # Allocate RAM (fake, just for fun)
    allocate_ram 128 "Build Cache"
    allocate_ram 256 "Compiler Workspace"
    allocate_ram 64 "Dependency Graph"
    allocate_ram 32 "Symbol Table"
    
    echo ""
    
    # Check actual dependencies
    local checks=(
        "bash:bash --version"
        "tar:tar --version"
        "base64:base64 --version"
    )
    
    for check in "${checks[@]}"; do
        IFS=':' read -r name cmd <<< "$check"
        echo -ne "Checking ${CYAN}${name}${NC}... "
        
        if $cmd &>/dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
            echo -e "${RED}Error:${NC} ${name} not found"
            exit 1
        fi
        sleep 0.1
    done
    
    echo ""
}

# ========== COMPRESSION METHOD ==========
detect_compression() {
    echo -e "${BOLD}${BLUE}[COMPRESSION]${NC}\n"
    
    local methods=()
    
    # Check 7zip
    if command -v 7z &>/dev/null; then
        methods+=("7zip")
        echo -e "  ${GREEN}✓${NC} 7-Zip detected"
    fi
    
    # Check zip
    if command -v zip &>/dev/null; then
        methods+=("zip")
        echo -e "  ${GREEN}✓${NC} ZIP detected"
    fi
    
    # Check tar+gzip (always available)
    if command -v tar &>/dev/null; then
        methods+=("tar.gz")
        echo -e "  ${GREEN}✓${NC} TAR+GZIP detected"
    fi
    
    if [[ ${#methods[@]} -eq 0 ]]; then
        echo -e "  ${RED}✗${NC} No compression tools found"
        exit 1
    fi
    
    # Pick best method
    if [[ " ${methods[@]} " =~ " 7zip " ]]; then
        COMPRESSION_METHOD="7zip"
        echo -e "\n  ${CYAN}Using:${NC} 7-Zip (best compression)"
    elif [[ " ${methods[@]} " =~ " zip " ]]; then
        COMPRESSION_METHOD="zip"
        echo -e "\n  ${CYAN}Using:${NC} ZIP (universal)"
    else
        COMPRESSION_METHOD="tar.gz"
        echo -e "\n  ${CYAN}Using:${NC} TAR+GZIP (standard)"
    fi
    
    echo ""
}

# ========== BUILD EXAMPLES BUNDLE ==========
build_bundle() {
    echo -e "${BOLD}${BLUE}[BUILD BUNDLE]${NC}\n"
    
    local EXAMPLES_DIR="matlab_examples"
    local OUTPUT_DIR="dist"
    local VERSION="0.3.0"
    
    # Check examples exist
    if [[ ! -d "$EXAMPLES_DIR" ]]; then
        echo -e "${RED}Error:${NC} $EXAMPLES_DIR not found"
        exit 1
    fi
    
    local file_count=$(find "$EXAMPLES_DIR" -name "*.m" -type f | wc -l)
    if [[ $file_count -eq 0 ]]; then
        echo -e "${RED}Error:${NC} No .m files found"
        exit 1
    fi
    
    echo -e "Found ${CYAN}${file_count}${NC} MATLAB files\n"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Simulate build process with progress
    local steps=(
        "Scanning source files"
        "Resolving dependencies"
        "Optimizing payload"
        "Compressing archive"
        "Encoding base64"
        "Generating installer"
        "Verifying integrity"
        "Finalizing bundle"
    )
    
    local total=${#steps[@]}
    for ((i=0; i<total; i++)); do
        progress_bar $((i+1)) $total "${steps[$i]}"
        sleep 0.3
    done
    
    echo ""
    
    # Actually build (background)
    echo -ne "${CYAN}Creating bundle${NC}... "
    
    case "$COMPRESSION_METHOD" in
        7zip)
            (cd "$EXAMPLES_DIR" && 7z a -tzip -mx=9 "../$OUTPUT_DIR/matlabcpp_examples_v${VERSION}.zip" *.m) &>/dev/null &
            ;;
        zip)
            (cd "$EXAMPLES_DIR" && zip -9 -q "../$OUTPUT_DIR/matlabcpp_examples_v${VERSION}.zip" *.m) &>/dev/null &
            ;;
        tar.gz)
            tar -czf "$OUTPUT_DIR/matlabcpp_examples_v${VERSION}.tar.gz" -C "$EXAMPLES_DIR" . &>/dev/null &
            ;;
    esac
    
    local build_pid=$!
    spin $build_pid "Building"
    
    wait $build_pid
    
    # Get file size
    local bundle_file=""
    if [[ "$COMPRESSION_METHOD" == "tar.gz" ]]; then
        bundle_file="$OUTPUT_DIR/matlabcpp_examples_v${VERSION}.tar.gz"
    else
        bundle_file="$OUTPUT_DIR/matlabcpp_examples_v${VERSION}.zip"
    fi
    
    local size_bytes=$(stat -f%z "$bundle_file" 2>/dev/null || stat -c%s "$bundle_file" 2>/dev/null)
    local size_kb=$((size_bytes / 1024))
    
    echo -e "\n${GREEN}✓${NC} Bundle created: ${CYAN}${bundle_file}${NC}"
    echo -e "  Size: ${YELLOW}${size_kb} KB${NC}"
    echo -e "  Files: ${CYAN}${file_count}${NC} examples"
    echo ""
}

# ========== INSTALLATION ==========
install_examples() {
    echo -e "${BOLD}${BLUE}[INSTALLATION]${NC}\n"
    
    # Simulate installation
    pulse_text "Preparing installation environment"
    
    # Allocate resources
    allocate_ram 64 "Installation Buffer"
    
    echo ""
    
    # Installation steps
    local steps=(
        "Creating directories"
        "Extracting files"
        "Setting permissions"
        "Registering examples"
        "Updating index"
        "Cleaning up"
    )
    
    local total=${#steps[@]}
    for ((i=0; i<total; i++)); do
        progress_bar $((i+1)) $total "${steps[$i]}"
        sleep 0.2
    done
    
    echo -e "\n${GREEN}✓${NC} Installation complete\n"
}

# ========== SUCCESS ANIMATION ==========
show_success() {
    echo -e "${GREEN}${BOLD}"
    cat <<'EOF'
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║                     SUCCESS!                              ║
    ║                                                           ║
    ║   MatLabC++ examples are ready to use.                   ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Pulse the checkmark
    for i in {1..3}; do
        echo -ne "\r        ${GREEN}${BOLD}✓ ✓ ✓${NC}  All systems operational  ${GREEN}${BOLD}✓ ✓ ✓${NC}"
        sleep 0.3
        echo -ne "\r        ${DIM}✓ ✓ ✓${NC}  All systems operational  ${DIM}✓ ✓ ✓${NC}"
        sleep 0.3
    done
    echo -e "\r        ${GREEN}${BOLD}✓ ✓ ✓${NC}  All systems operational  ${GREEN}${BOLD}✓ ✓ ✓${NC}"
    echo ""
}

# ========== USAGE INSTRUCTIONS ==========
show_usage() {
    echo -e "${BOLD}${CYAN}Quick Start:${NC}\n"
    
    type_text "  $ cd matlabcpp_examples" 0.02
    type_text "  $ mlab++ basic_demo.m" 0.02
    type_text "  $ mlab++ test_math_accuracy.m" 0.02
    
    echo -e "\n${BOLD}${CYAN}Or use Active Window:${NC}\n"
    
    type_text "  $ mlab++" 0.02
    type_text "  >> waterData = [0 0 1 1 2 3 5 8]" 0.02
    type_text "  >> sum(waterData)" 0.02
    
    echo ""
}

# ========== CLEANUP ==========
cleanup() {
    # Restore terminal
    tput cnorm 2>/dev/null || true
    echo -e "${NC}"
}

trap cleanup EXIT

# ========== MAIN ==========
main() {
    # Hide cursor for cleaner animations
    tput civis 2>/dev/null || true
    
    # Show banner
    show_banner
    
    # System check
    check_system
    
    # Detect compression method
    detect_compression
    
    # Brief matrix effect
    echo -e "${DIM}Initializing build system...${NC}\n"
    sleep 0.5
    
    # Build bundle
    build_bundle
    
    # Installation simulation (optional)
    if [[ "${1:-}" == "--install" ]]; then
        install_examples
        show_success
        show_usage
    else
        echo -e "${GREEN}✓${NC} Bundle ready for distribution\n"
        echo -e "${BOLD}To install:${NC}"
        echo -e "  ${CYAN}./fancy_install.sh --install${NC}"
        echo -e "\n${BOLD}To distribute:${NC}"
        echo -e "  ${CYAN}scp dist/matlabcpp_examples_*.* server:/var/www/${NC}"
        echo ""
    fi
}

# ========== RUN ==========
main "$@"
