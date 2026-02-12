# MATRIX STRESS TEST - DUAL MODE GUIDE

Run matrix stress tests in both CPU and GPU modes for comparison.

---

## Quick Start

### Current State (v0.4.0 - CPU Only)

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++

# Run CPU baseline
./build/mlab++ < tests/stress_matrix_parallel_cpu_only.m
```

**Expected:** CPU baseline performance (~20-50 GFLOPS for 1000x1000)

---

## Run Both Modes (Requires GPU Build)

### Step 1: Build GPU Version (v0.8.0.1)

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++

# Create separate GPU build directory
rm -rf build_gpu
mkdir build_gpu && cd build_gpu

# Configure with CUDA
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_GPU=ON

# Build
cmake --build . -j$(nproc)

# Verify
./mlab++ --version
# Should show: "MatLabC++ version 0.8.0.1 beta"
# Should mention: "GPU: CUDA 12.x"
```

**Time:** ~60 seconds  
**Requires:** NVIDIA GPU, CUDA Toolkit 12.0+

---

### Step 2: Run Automated Comparison

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++

# Make script executable
chmod +x tests/run_matrix_stress_both_modes.sh

# Run both tests
./tests/run_matrix_stress_both_modes.sh
```

**Output:** 
- `cpu_results.txt` - CPU baseline
- `gpu_results.txt` - GPU performance
- Console comparison summary

---

## Manual Testing

### Test 1: CPU Baseline Only

```bash
./build/mlab++ < tests/stress_matrix_parallel_cpu_only.m
```

**Tests:**
- Matrix multiply (500, 1000, 2000)
- Operations (add, multiply, transpose)
- Decompositions (QR, LU, SVD)
- Linear solve
- Batch operations

**Time:** 2-5 minutes

---

### Test 2: GPU Full Test

```bash
./build_gpu/mlab++ < tests/stress_matrix_parallel.m
```

**Tests:**
- Everything from CPU test PLUS
- CPU vs GPU comparison
- GPU speedup measurements
- Accuracy verification

**Time:** 5-10 minutes  
**Expected Speedup:** 50-150x

---

## Expected Results

### CPU Baseline (v0.4.0)

```
Matrix Multiply Performance:
  500x500: 15-25 GFLOPS
  1000x1000: 20-40 GFLOPS
  2000x2000: 25-50 GFLOPS

Operation Times (1000x1000):
  Addition:       0.020 s
  Element-wise:   0.015 s
  Transpose:      0.010 s
  Multiply:       0.450 s

Decompositions:
  QR:  0.800 s
  LU:  0.600 s
  SVD: 5.000 s
```

### GPU Full Test (v0.8.0.1)

```
Matrix Multiply Speedup:
  500x500:   50x (0.450s → 0.009s)
  1000x1000: 100x (0.450s → 0.005s)
  2000x2000: 150x (3.500s → 0.023s)

Average GPU Speedup:
  Element-wise: 50x
  Matrix ops:   100x
  QR:           80x
  LU:           80x
  SVD:          100x
  
Overall: 75-100x faster on GPU
```

---

## File Comparison

### CPU-Only Test vs Full GPU Test

| Feature | CPU-Only | GPU Full |
|---------|----------|----------|
| File | `stress_matrix_parallel_cpu_only.m` | `stress_matrix_parallel.m` |
| Sizes | [500, 1000, 2000] | [500, 1000, 2000, 4000] |
| GPU calls | None | `gpu()`, `cpu()` |
| Comparison | Absolute timing | CPU vs GPU |
| Output | Baseline metrics | Speedup factors |

---

## Troubleshooting

### "GPU version not found"

```bash
# Build GPU version first
cd /mnt/c/Users/Liam/Desktop/MatLabC++
mkdir build_gpu && cd build_gpu
cmake .. -DWITH_GPU=ON
cmake --build . -j$(nproc)
```

### "CUDA not found"

```bash
# Check CUDA installation
which nvcc
nvidia-smi

# Install CUDA
# See V0.8.0.1_BETA_GPU_BUILD.md
```

### "Out of GPU memory"

Edit `stress_matrix_parallel.m`, reduce sizes:
```matlab
sizes = [500, 1000];  % Instead of [500, 1000, 2000, 4000]
```

---

## What to Compare

### Key Metrics:

1. **Matrix Multiply Time**
   - CPU: Should be ~0.5s for 1000x1000
   - GPU: Should be ~0.005s
   - Speedup: ~100x

2. **QR Decomposition**
   - CPU: ~0.8s
   - GPU: ~0.01s
   - Speedup: ~80x

3. **Accuracy**
   - Both should have errors < 1e-10
   - Verify with "Reconstruction error" outputs

4. **Memory Usage**
   - CPU: ~16 MB per 1000x1000 matrix
   - GPU: Similar + transfer overhead

---

## Quick Commands

```bash
# CPU baseline (always works)
./build/mlab++ < tests/stress_matrix_parallel_cpu_only.m | tee cpu_baseline.txt

# GPU full test (needs GPU build)
./build_gpu/mlab++ < tests/stress_matrix_parallel.m | tee gpu_full.txt

# Compare results
diff cpu_baseline.txt gpu_full.txt | grep speedup

# Or use automated runner
./tests/run_matrix_stress_both_modes.sh
```

---

## Next Steps After Testing

1. **If CPU baseline works:**
   - ✅ Core functionality verified
   - ✅ Ready to build GPU version

2. **If GPU test shows 50-150x speedup:**
   - ✅ GPU system fully operational
   - ✅ Ready for production use
   - ✅ Run full test suite: `./tests/run_gpu_stress_tests.m`

3. **If GPU slower than expected:**
   - Check GPU utilization: `nvidia-smi`
   - Verify CUDA version matches
   - Check for CPU bottlenecks

---

**Status:**  
✅ CPU test ready to run NOW  
⏳ GPU test requires build  
🎯 Expected: 50-150x speedup on GPU
