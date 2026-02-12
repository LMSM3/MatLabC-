#!/bin/bash
# RUN_MATRIX_STRESS_BOTH_MODES.SH
# Run matrix stress tests in CPU-only and GPU modes for comparison
#
# Usage: ./tests/run_matrix_stress_both_modes.sh

MLAB_CPU="./build/mlab++"
MLAB_GPU="./build_gpu/mlab++"

echo "================================================"
echo "MatLabC++ Matrix Stress Test - Dual Mode Runner"
echo "================================================"
echo ""

# Check if CPU version exists
if [ ! -f "$MLAB_CPU" ]; then
    echo "ERROR: CPU version not found at $MLAB_CPU"
    echo "Build with: ./build_and_setup.sh"
    exit 1
fi

echo "Found CPU version: $MLAB_CPU"
$MLAB_CPU --version
echo ""

# Run CPU baseline test
echo "================================================"
echo "STEP 1: CPU BASELINE TEST"
echo "================================================"
echo ""
echo "Running CPU-only stress test..."
echo ""

$MLAB_CPU < tests/stress_matrix_parallel_cpu_only.m > cpu_results.txt 2>&1

if [ $? -eq 0 ]; then
    echo "✓ CPU test completed"
    echo ""
    cat cpu_results.txt
else
    echo "✗ CPU test failed"
    cat cpu_results.txt
    exit 1
fi

echo ""
echo "================================================"
echo "STEP 2: GPU VERSION CHECK"
echo "================================================"
echo ""

# Check if GPU version exists
if [ ! -f "$MLAB_GPU" ]; then
    echo "⚠ GPU version not found at $MLAB_GPU"
    echo ""
    echo "To build GPU version:"
    echo "  1. Install CUDA Toolkit"
    echo "  2. Run: rm -rf build_gpu && mkdir build_gpu && cd build_gpu"
    echo "  3. Run: cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_GPU=ON"
    echo "  4. Run: cmake --build . -j\$(nproc)"
    echo ""
    echo "Skipping GPU comparison test."
    echo ""
    echo "================================================"
    echo "RESULTS: CPU BASELINE ONLY"
    echo "================================================"
    tail -20 cpu_results.txt
    exit 0
fi

echo "Found GPU version: $MLAB_GPU"
$MLAB_GPU --version
echo ""

# Check GPU availability
echo "Checking GPU..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
    echo ""
else
    echo "⚠ nvidia-smi not found - GPU may not be available"
    echo ""
fi

# Run GPU stress test
echo "================================================"
echo "STEP 3: GPU FULL STRESS TEST"
echo "================================================"
echo ""
echo "Running GPU stress test..."
echo ""

$MLAB_GPU < tests/stress_matrix_parallel.m > gpu_results.txt 2>&1

if [ $? -eq 0 ]; then
    echo "✓ GPU test completed"
    echo ""
    cat gpu_results.txt
else
    echo "✗ GPU test failed"
    cat gpu_results.txt
    exit 1
fi

echo ""
echo "================================================"
echo "STEP 4: COMPARISON REPORT"
echo "================================================"
echo ""

# Extract key metrics (simplified - would need actual parsing)
echo "CPU Baseline Results:"
echo "---------------------"
grep "Matrix multiply:" cpu_results.txt || echo "See cpu_results.txt"
grep "QR decomposition:" cpu_results.txt || echo "See cpu_results.txt"
echo ""

echo "GPU Full Results:"
echo "----------------"
grep "Average speedup:" gpu_results.txt || echo "See gpu_results.txt"
grep "Overall average:" gpu_results.txt || echo "See gpu_results.txt"
echo ""

echo "================================================"
echo "COMPLETE TEST RESULTS"
echo "================================================"
echo ""
echo "Detailed results saved to:"
echo "  CPU: cpu_results.txt"
echo "  GPU: gpu_results.txt"
echo ""
echo "Performance comparison:"
echo "  1. Open both files and compare timing sections"
echo "  2. GPU version should show 50-150x speedup"
echo "  3. Accuracy should match (errors < 1e-10)"
echo ""
echo "Test completed ✓"
