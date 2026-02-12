#!/usr/bin/env bash
# Build all automation tools
# Run this after extracting from package

set -euo pipefail

echo "╔═══════════════════════════════════════════════════╗"
echo "║  Building Production Testing Tools                ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_LOG="build.log"

build_tool() {
    local source=$1
    local output=$2
    local compiler=$3
    local flags=$4
    
    echo -n "Building $(basename "$output")... "
    
    if $compiler $flags -o "$output" "$source" >> "$BUILD_LOG" 2>&1; then
        echo "✓"
        return 0
    else
        echo "✗ (see $BUILD_LOG)"
        return 1
    fi
}

main() {
    cd "$TOOLS_DIR"
    
    echo "" > "$BUILD_LOG"
    
    # C tools
    if command -v gcc &> /dev/null; then
        build_tool "memory_leak_detector.c" "memleak" "gcc" "-O2 -Wall"
        build_tool "perf_profiler.c" "perfprof" "gcc" "-O2 -Wall -lpthread"
    else
        echo "Warning: gcc not found, skipping C tools"
    fi
    
    # C++ tools
    if command -v g++ &> /dev/null; then
        build_tool "write_speed_benchmark.cpp" "writebench" "g++" "-O2 -std=c++17 -Wall"
        build_tool "code_reader.cpp" "codereader" "g++" "-O2 -std=c++17 -Wall"
    else
        echo "Warning: g++ not found, skipping C++ tools"
    fi
    
    # Make shell scripts executable
    chmod +x gpu_monitor.sh 2>/dev/null || true
    chmod +x code_deployer.sh 2>/dev/null || true
    chmod +x test_runner.sh 2>/dev/null || true
    
    echo ""
    echo "✓ Build complete!"
    echo ""
    echo "Available tools:"
    echo "  ./memleak <pid> [interval]       - Monitor process memory"
    echo "  ./writebench [size_mb] [block]   - Disk I/O benchmark"
    echo "  ./perfprof --test                - CPU/memory profiler"
    echo "  ./codereader <file>              - Source code analyzer"
    echo "  ./gpu_monitor.sh [interval]      - GPU usage monitor"
    echo "  ./code_deployer.sh <cmd>         - Package deployment"
    echo "  ./test_runner.sh [-d dir]        - Automated testing"
    echo ""
}

main
