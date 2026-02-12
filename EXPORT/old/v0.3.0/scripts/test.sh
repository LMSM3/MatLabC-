#!/bin/bash
# MatLabC++ v0.3.0 - Test Script
set -euo pipefail

echo "╔════════════════════════════════════════╗"
echo "║  MatLabC++ v0.3.0 - System Test        ║"
echo "╚════════════════════════════════════════╝"
echo ""

PASS=0
FAIL=0

# Check function
check() {
    local name="$1"
    local cmd="$2"
    
    if eval "$cmd" &>/dev/null; then
        echo "✓ ${name}"
        ((PASS++))
    else
        echo "✗ ${name}"
        ((FAIL++))
    fi
}

# System checks
echo "[System Dependencies]"
check "CMake"        "command -v cmake"
check "C++ Compiler" "command -v g++ || command -v clang++"
check "GCC (for .c scripts)" "command -v gcc"
check "Octave (for .m scripts)" "command -v octave"

echo ""
echo "[Build Artifacts]"
check "matlabcpp executable" "[ -f build/matlabcpp ]"
check "benchmark_inference" "[ -f build/benchmark_inference ]"

echo ""
echo "[Headers]"
check "Main header" "[ -f include/matlabcpp.hpp ]"
check "Core module" "[ -f include/matlabcpp/core.hpp ]"
check "Materials module" "[ -f include/matlabcpp/materials.hpp ]"
check "Script module" "[ -f include/matlabcpp/script.hpp ]"

echo ""
echo "[Examples]"
check "C++ examples" "[ -d examples/cpp ]"
check "Script examples" "[ -d examples/scripts ]"
check "3D beam demo" "[ -f examples/cpp/beam_stress_3d.cpp ]"

# Run quick tests if built
if [ -f "build/matlabcpp" ]; then
    echo ""
    echo "[Runtime Tests]"
    
    if ./build/matlabcpp --help &>/dev/null; then
        echo "✓ matlabcpp runs"
        ((PASS++))
    else
        echo "✗ matlabcpp fails"
        ((FAIL++))
    fi
fi

# Summary
echo ""
echo "╔════════════════════════════════════════╗"
echo "║  Test Summary                          ║"
echo "╚════════════════════════════════════════╝"
echo "  Passed: ${PASS}"
echo "  Failed: ${FAIL}"

if [ ${FAIL} -eq 0 ]; then
    echo ""
    echo "✓ All tests passed!"
    exit 0
else
    echo ""
    echo "⚠ ${FAIL} test(s) failed"
    echo ""
    echo "Missing dependencies? Install:"
    echo "  sudo apt install cmake g++ gcc octave  # Ubuntu/Debian"
    echo "  brew install cmake gcc octave           # macOS"
    exit 1
fi
