#!/usr/bin/env bash
# Automated Test Runner
# Executes test suites and generates reports

set -euo pipefail

TEST_DIR="${TEST_DIR:-.}"
REPORT_FILE="test_report.txt"
VERBOSE=0

print_header() {
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║  Automated Test Runner - Production Testing      ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
}

discover_tests() {
    echo "Discovering tests in: $TEST_DIR"
    
    # Find test files
    local test_files=()
    
    # C/C++ test executables
    while IFS= read -r -d '' file; do
        if [[ -x "$file" ]] && [[ "$(basename "$file")" == test_* ]]; then
            test_files+=("$file")
        fi
    done < <(find "$TEST_DIR" -type f -print0)
    
    # Python test files
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find "$TEST_DIR" -name "test_*.py" -print0)
    
    # Shell test scripts
    while IFS= read -r -d '' file; do
        if [[ -x "$file" ]]; then
            test_files+=("$file")
        fi
    done < <(find "$TEST_DIR" -name "test_*.sh" -print0)
    
    echo "Found ${#test_files[@]} test files"
    printf '%s\n' "${test_files[@]}"
}

run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file")
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local start_time=$(date +%s)
    local exit_code=0
    
    # Capture output
    local output
    if output=$("$test_file" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Print results
    echo "$output"
    echo ""
    
    if [[ $exit_code -eq 0 ]]; then
        echo "✓ PASS: $test_name (${duration}s)"
        return 0
    else
        echo "✗ FAIL: $test_name (${duration}s) - Exit code: $exit_code"
        return 1
    fi
}

run_all_tests() {
    local tests=("$@")
    local total=${#tests[@]}
    local passed=0
    local failed=0
    local failed_tests=()
    
    echo "" > "$REPORT_FILE"
    echo "Test Report - $(date)" >> "$REPORT_FILE"
    echo "═══════════════════════════════════════════" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    for test in "${tests[@]}"; do
        local test_name=$(basename "$test")
        
        if run_test "$test" | tee -a "$REPORT_FILE"; then
            ((passed++))
        else
            ((failed++))
            failed_tests+=("$test_name")
        fi
    done
    
    # Summary
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║  Test Summary                                     ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    echo "Total:  $total tests"
    echo "Passed: $passed tests ($(( total > 0 ? passed * 100 / total : 0 ))%)"
    echo "Failed: $failed tests ($(( total > 0 ? failed * 100 / total : 0 ))%)"
    
    if [[ $failed -gt 0 ]]; then
        echo ""
        echo "Failed tests:"
        for test in "${failed_tests[@]}"; do
            echo "  ✗ $test"
        done
    fi
    
    echo ""
    echo "Report saved to: $REPORT_FILE"
    
    # Summary to report
    {
        echo ""
        echo "═══════════════════════════════════════════"
        echo "SUMMARY"
        echo "═══════════════════════════════════════════"
        echo "Total:  $total"
        echo "Passed: $passed ($((total > 0 ? passed * 100 / total : 0))%)"
        echo "Failed: $failed ($((total > 0 ? failed * 100 / total : 0))%)"
    } >> "$REPORT_FILE"
    
    return $failed
}

build_cpp_tests() {
    echo "Building C++ tests..."
    
    for src in "$TEST_DIR"/*.cpp; do
        if [[ -f "$src" ]]; then
            local exe="${src%.cpp}"
            echo "  Compiling $(basename "$src")..."
            g++ -std=c++17 -O2 -o "$exe" "$src" || echo "    Warning: Compilation failed"
        fi
    done
    
    echo "✓ Build complete"
}

main() {
    print_header
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                TEST_DIR="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -b|--build)
                build_cpp_tests
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Discover and run tests
    mapfile -t test_files < <(discover_tests)
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo "No tests found in $TEST_DIR"
        exit 0
    fi
    
    echo ""
    run_all_tests "${test_files[@]}"
}

main "$@"
