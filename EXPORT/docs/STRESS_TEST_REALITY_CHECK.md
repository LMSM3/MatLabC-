# RUNNING MATRIX STRESS TESTS - PRACTICAL GUIDE

## Current Situation

**Your build (v0.4.0)** doesn't support:
- ❌ MATLAB script files (.m)
- ❌ GPU operations
- ❌ Complex numbers
- ❌ Advanced decompositions

**What WORKS now:**
- ✅ Basic math operations
- ✅ Matrix creation (randn, zeros, ones)
- ✅ Matrix operations (+, -, *, .*)
- ✅ Interactive REPL

---

## Option 1: Quick Manual Test (Works NOW)

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
./build/mlab++
```

Then copy-paste from `tests/cpu_matrix_manual.txt`:

```matlab
>>> N = 1000
>>> A = randn(N, N)
>>> B = randn(N, N)
>>> tic
>>> C = A * B
>>> toc
```

**Expected:** ~0.5-2 seconds for 1000x1000

---

## Option 2: Build v0.8.0.1 for Full GPU Testing

### Prerequisites
```bash
# Check GPU
nvidia-smi

# Check CUDA
nvcc --version
# Need: CUDA 12.0+
```

### Build GPU Version
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++

# Create GPU build
rm -rf build_gpu
mkdir build_gpu && cd build_gpu

# Configure with CUDA
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DWITH_GPU=ON \
         -DCMAKE_CUDA_ARCHITECTURES=70

# Build
cmake --build . -j$(nproc)

# Verify
./mlab++ --version
```

**Time:** ~60-120 seconds (if CUDA installed)

### Then Run Full GPU Tests
```bash
./build_gpu/mlab++ < tests/stress_matrix_parallel.m
```

---

## Option 3: What You Can Do Right Now

### Test Current Capabilities

**Test 1: Matrix Creation**
```bash
./build/mlab++
>>> A = randn(100, 100)
>>> size(A)
>>> who
>>> quit
```

**Test 2: Matrix Math**
```bash
./build/mlab++
>>> A = [1 2; 3 4]
>>> B = [5 6; 7 8]
>>> C = A + B
>>> D = A * B
>>> E = A'
>>> quit
```

**Test 3: Basic Functions**
```bash
./build/mlab++
>>> A = randn(10, 10)
>>> sum(A(:))
>>> mean(A(:))
>>> max(A(:))
>>> min(A(:))
>>> quit
```

---

## Comparison Table

| Feature | v0.4.0 (NOW) | v0.8.0.1 (NEED BUILD) |
|---------|--------------|----------------------|
| Matrix ops | ✅ Basic | ✅ Full |
| GPU support | ❌ | ✅ |
| Complex numbers | ❌ | ✅ |
| Script files | ❌ | ✅ |
| QR/LU/SVD | ❌ | ✅ |
| cuBLAS | ❌ | ✅ |
| FFT | ❌ | ✅ |
| Stress tests | ⚠️ Manual only | ✅ Automated |

---

## Decision Tree

```
Do you have NVIDIA GPU + CUDA?
│
├── YES → Build v0.8.0.1 (1 hour setup)
│         → Run full GPU stress tests
│         → Get 50-150x speedup
│
└── NO  → Use v0.4.0 (current)
          → Manual testing only
          → CPU baseline performance
```

---

## Quick Commands Summary

### Right Now (No Build)
```bash
# Launch REPL
./build/mlab++

# Test from file
cat tests/cpu_matrix_manual.txt
# Copy-paste commands
```

### After GPU Build
```bash
# Full stress test
./build_gpu/mlab++ < tests/stress_matrix_parallel.m

# CPU vs GPU comparison
./tests/run_matrix_stress_both_modes.sh

# Individual tests
./build_gpu/mlab++ < tests/stress_tensor.m
./build_gpu/mlab++ < tests/stress_vector_parallel.m
./build_gpu/mlab++ < tests/stress_linear_accuracy.m
```

---

## Next Steps

1. **Test current v0.4.0 capabilities:**
   ```bash
   ./build/mlab++
   # Try matrix operations manually
   ```

2. **If you have GPU:**
   - Install CUDA Toolkit 12.0+
   - Build v0.8.0.1 (see `V0.8.0.1_BETA_GPU_BUILD.md`)
   - Run full stress tests

3. **If no GPU:**
   - Continue with v0.4.0
   - Use manual testing
   - Plan CPU-only improvements

---

**Bottom Line:**
- ✅ Can test basic matrices RIGHT NOW (manual)
- ⏳ Need v0.8.0.1 build for automated GPU tests
- 🎯 GPU testing requires: CUDA + 1 hour setup
