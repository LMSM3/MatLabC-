#!/usr/bin/env bash
# test_bundle_system.sh
# Integration test for bundle system
# Intent: Verify bundle generation, extraction, and installation work correctly

set -euo pipefail

# ========== CONFIGURATION ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BOLD=$'\e[1m'
DIM=$'\e[2m'
GREEN=$'\e[32m'
RED=$'\e[31m'
YELLOW=$'\e[33m'
NC=$'\e[0m'

# ========== ERROR HANDLING ==========
cleanup_on_error() {
    local exit_code=$?
    echo ""
    echo "${RED}${BOLD}Test failed with exit code: ${exit_code}${NC}"
    
    # Clean up test directory if it exists
    if [[ -n "${TEST_DIR:-}" ]] && [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
        echo "${DIM}Cleaned up test directory${NC}"
    fi
    
    exit $exit_code
}

trap cleanup_on_error ERR

# ========== RAM MONITORING ==========
get_available_ram_mb() {
    # Real RAM detection across platforms
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux: read from /proc/meminfo
        awk '/MemAvailable/ {printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "0"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: use vm_stat
        local page_size=$(pagesize 2>/dev/null || echo 4096)
        local free_pages=$(vm_stat | awk '/Pages free/ {print $3}' | tr -d '.')
        echo $(( (free_pages * page_size) / 1024 / 1024 ))
    else
        # Windows/WSL: try systeminfo or wmic
        systeminfo 2>/dev/null | awk '/Available Physical Memory/ {print $4}' | tr -d ',' | head -c -3 || echo "0"
    fi
}

get_total_ram_mb() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        awk '/MemTotal/ {printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "0"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo $(($(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1024 / 1024))
    else
        systeminfo 2>/dev/null | awk '/Total Physical Memory/ {print $4}' | tr -d ',' | head -c -3 || echo "0"
    fi
}

show_ram_status() {
    local available=$(get_available_ram_mb)
    local total=$(get_total_ram_mb)
    
    if [[ $total -gt 0 ]]; then
        local used=$((total - available))
        local percent=$((used * 100 / total))
        echo "${DIM}[RAM] ${used}MB/${total}MB used (${percent}%)${NC}"
    fi
}

# Allocate buffer space (just verify we have enough RAM)
allocate_buffer() {
    local required_mb=$1
    local available=$(get_available_ram_mb)
    
    if [[ $available -lt $required_mb ]]; then
        echo "${RED}Insufficient RAM: need ${required_mb}MB, have ${available}MB${NC}"
        return 1
    fi
    
    echo "${GREEN}✓${NC} ${required_mb}MB buffer available"
    return 0
}

# ========== BANNER ==========
show_banner() {
    clear
    echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BOLD}Bundle System Integration Test${NC}"
    echo "${DIM}MatLabC++ v0.3.0${NC}"
    echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    show_ram_status
    echo ""
}

# ========== TEST FUNCTIONS ==========
test_prerequisites() {
    echo "${BOLD}Test 1: Prerequisites${NC}"
    
    # Check matlab_examples directory
    if [[ ! -d "$PROJECT_ROOT/matlab_examples" ]]; then
        echo "  ${RED}✗${NC} matlab_examples/ not found"
        return 1
    fi
    
    # Count .m files
    local m_count=$(find "$PROJECT_ROOT/matlab_examples" -name "*.m" -type f 2>/dev/null | wc -l)
    if [[ $m_count -eq 0 ]]; then
        echo "  ${RED}✗${NC} No .m files found"
        return 1
    fi
    
    echo "  ${GREEN}✓${NC} Found ${m_count} MATLAB files"
    
    # Check generator script
    if [[ ! -f "$SCRIPT_DIR/generate_examples_bundle.sh" ]]; then
        echo "  ${RED}✗${NC} generate_examples_bundle.sh not found"
        return 1
    fi
    echo "  ${GREEN}✓${NC} Generator script present"
    
    # Check template
    if [[ ! -f "$SCRIPT_DIR/mlabpp_examples_bundle.sh" ]]; then
        echo "  ${RED}✗${NC} Template installer not found"
        return 1
    fi
    echo "  ${GREEN}✓${NC} Template installer present"
    
    # Allocate buffer for build
    allocate_buffer 128
    
    echo ""
    return 0
}

test_bundle_generation() {
    echo "${BOLD}Test 2: Bundle Generation${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Generate bundle
    if ! bash "$SCRIPT_DIR/generate_examples_bundle.sh" >/dev/null 2>&1; then
        echo "  ${RED}✗${NC} Generation failed"
        return 1
    fi
    
    # Check output exists
    if [[ ! -f "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" ]]; then
        echo "  ${RED}✗${NC} Bundle not created"
        return 1
    fi
    
    # Get size
    local size_bytes=$(stat -f%z "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" 2>/dev/null || \
                       stat -c%s "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" 2>/dev/null)
    local size_kb=$((size_bytes / 1024))
    
    echo "  ${GREEN}✓${NC} Bundle created (${size_kb} KB)"
    
    # Check executable
    if [[ ! -x "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" ]]; then
        echo "  ${RED}✗${NC} Not executable"
        return 1
    fi
    echo "  ${GREEN}✓${NC} Executable bit set"
    
    # Check payload marker
    if ! grep -q "^__PAYLOAD_BELOW__$" "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh"; then
        echo "  ${RED}✗${NC} Payload marker missing"
        return 1
    fi
    echo "  ${GREEN}✓${NC} Payload marker present"
    
    echo ""
    return 0
}

test_bundle_contents() {
    echo "${BOLD}Test 3: Bundle Contents${NC}"
    
    # Extract payload to verify
    local temp_list=$(mktemp)
    
    if ! awk '/^__PAYLOAD_BELOW__$/{p=1;next}p' "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" \
        | base64 -d 2>/dev/null | tar -tzv > "$temp_list" 2>&1; then
        echo "  ${RED}✗${NC} Failed to extract payload"
        rm "$temp_list"
        return 1
    fi
    
    # Count archived files
    local archived_count=$(grep -c "\.m$" "$temp_list" || echo "0")
    local expected_count=$(find "$PROJECT_ROOT/matlab_examples" -name "*.m" -type f | wc -l)
    
    if [[ $archived_count -ne $expected_count ]]; then
        echo "  ${RED}✗${NC} File count mismatch: expected ${expected_count}, got ${archived_count}"
        rm "$temp_list"
        return 1
    fi
    
    echo "  ${GREEN}✓${NC} All ${archived_count} files archived"
    
    # Verify key files
    for file in basic_demo.m materials_lookup.m; do
        if ! grep -q "$file" "$temp_list"; then
            echo "  ${RED}✗${NC} Missing: ${file}"
            rm "$temp_list"
            return 1
        fi
    done
    
    echo "  ${GREEN}✓${NC} Key files verified"
    rm "$temp_list"
    
    echo ""
    return 0
}

test_installation() {
    echo "${BOLD}Test 4: Installation${NC}"
    
    # Create test directory
    TEST_DIR=$(mktemp -d)
    echo "  ${DIM}Test dir: ${TEST_DIR}${NC}"
    
    # Allocate buffer for extraction
    allocate_buffer 64
    
    cd "$TEST_DIR"
    
    # Run installer
    if ! bash "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" "$TEST_DIR" >/dev/null 2>&1; then
        echo "  ${RED}✗${NC} Installation failed"
        return 1
    fi
    
    # Verify examples directory
    if [[ ! -d "$TEST_DIR/examples" ]]; then
        echo "  ${RED}✗${NC} examples/ not created"
        return 1
    fi
    echo "  ${GREEN}✓${NC} examples/ directory created"
    
    # Count installed files
    local installed_count=$(find "$TEST_DIR/examples" -name "*.m" -type f | wc -l)
    local expected_count=$(find "$PROJECT_ROOT/matlab_examples" -name "*.m" -type f | wc -l)
    
    if [[ $installed_count -ne $expected_count ]]; then
        echo "  ${RED}✗${NC} File count mismatch: expected ${expected_count}, got ${installed_count}"
        return 1
    fi
    
    echo "  ${GREEN}✓${NC} All ${installed_count} files extracted"
    
    echo ""
    return 0
}

test_file_annotations() {
    echo "${BOLD}Test 5: File Annotations${NC}"
    
    # Find first .m file
    local first_file=$(find "$TEST_DIR/examples" -name "*.m" -type f | head -n 1)
    
    if [[ -z "$first_file" ]]; then
        echo "  ${RED}✗${NC} No .m files found"
        return 1
    fi
    
    # Check for installation annotation
    if ! head -n 5 "$first_file" | grep -q "Installed by mlabpp_examples_bundle.sh"; then
        echo "  ${RED}✗${NC} Files not annotated"
        return 1
    fi
    echo "  ${GREEN}✓${NC} Installation annotation present"
    
    # Check location recorded
    if ! head -n 5 "$first_file" | grep -q "Location: $TEST_DIR/examples"; then
        echo "  ${RED}✗${NC} Location not recorded"
        return 1
    fi
    echo "  ${GREEN}✓${NC} Location recorded correctly"
    
    echo ""
    return 0
}

test_idempotency() {
    echo "${BOLD}Test 6: Idempotency${NC}"
    
    # Run installer again
    if ! bash "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" "$TEST_DIR" >/dev/null 2>&1; then
        echo "  ${RED}✗${NC} Re-installation failed"
        return 1
    fi
    
    # Check file hasn't grown excessively
    local first_file=$(find "$TEST_DIR/examples" -name "*.m" -type f | head -n 1)
    local line_count=$(wc -l < "$first_file")
    
    if [[ $line_count -gt 500 ]]; then
        echo "  ${RED}✗${NC} File appears duplicated (${line_count} lines)"
        return 1
    fi
    
    echo "  ${GREEN}✓${NC} Re-installation is idempotent"
    
    echo ""
    return 0
}

# ========== MAIN ==========
main() {
    show_banner
    
    # Run all tests
    test_prerequisites
    test_bundle_generation
    test_bundle_contents
    test_installation
    test_file_annotations
    test_idempotency
    
    # Cleanup
    if [[ -n "${TEST_DIR:-}" ]] && [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
    
    # Success message
    echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${GREEN}${BOLD}All tests passed${NC}"
    echo "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Show bundle info
    if [[ -f "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" ]]; then
        local size_bytes=$(stat -f%z "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" 2>/dev/null || \
                           stat -c%s "$PROJECT_ROOT/dist/mlabpp_examples_bundle.sh" 2>/dev/null)
        local size_kb=$((size_bytes / 1024))
        local file_count=$(find "$PROJECT_ROOT/matlab_examples" -name "*.m" -type f | wc -l)
        
        echo "${BOLD}Bundle ready:${NC}"
        echo "  Location: ${YELLOW}dist/mlabpp_examples_bundle.sh${NC}"
        echo "  Size:     ${size_kb} KB"
        echo "  Files:    ${file_count} examples"
        echo ""
        echo "${BOLD}Distribute:${NC}"
        echo "  ${DIM}scp dist/mlabpp_examples_bundle.sh user@server:/path/${NC}"
        echo "  ${DIM}curl -O https://site.com/mlabpp_examples_bundle.sh${NC}"
        echo ""
    fi
}

main "$@"
