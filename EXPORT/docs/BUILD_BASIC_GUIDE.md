# BUILD BASIC - Quick Reference

**Simple, reliable build for MatLabC++ v0.4.0**

---

## One Command Build

```bash
chmod +x build_basic.sh
./build_basic.sh
```

**Time:** ~30 seconds  
**Result:** Clean v0.4.0 build, no GPU, no optional features

---

## What It Does

1. **Clean:** Removes old build directory
2. **Configure:** CMake with basic options only
3. **Build:** Parallel compilation (all cores)
4. **Verify:** Checks executable exists
5. **Test:** Quick 2+2 test

---

## Features Included

✅ Core REPL  
✅ Basic matrix operations (+, -, *, .*)  
✅ 15+ math functions  
✅ Material database  
✅ Workspace management  

❌ GPU support  
❌ Cairo graphics  
❌ OpenGL  
❌ Complex numbers (v0.8.0.1 feature)  

---

## After Build

### Test it
```bash
./build/mlab++
>>> 2 + 2
>>> A = [1 2; 3 4]
>>> B = [5 6; 7 8]
>>> C = A + B
>>> quit
```

### Check version
```bash
./build/mlab++ --version
```

### Run manual tests
```bash
# Copy from tests/cpu_matrix_manual.txt
./build/mlab++
>>> N = 100
>>> A = randn(N, N)
>>> B = randn(N, N)
>>> C = A * B
>>> quit
```

---

## Troubleshooting

### "CMake not found"
```bash
# Ubuntu/Debian
sudo apt-get install cmake

# RHEL/AlmaLinux
sudo dnf install cmake
```

### "g++ not found"
```bash
# Ubuntu/Debian
sudo apt-get install build-essential

# RHEL/AlmaLinux
sudo dnf groupinstall "Development Tools"
```

### Build fails
```bash
# Check requirements
cmake --version  # Need 3.15+
g++ --version    # Need 7.0+

# Try manual build
rm -rf build
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

---

## Clean Build Options

### Minimal (fastest)
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DBUILD_EXAMPLES=OFF \
         -DBUILD_TESTS=OFF
```

### Debug (for development)
```bash
cmake .. -DCMAKE_BUILD_TYPE=Debug \
         -DBUILD_EXAMPLES=ON \
         -DBUILD_TESTS=ON
```

### With optional features
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DWITH_CAIRO=ON \
         -DWITH_OPENGL=ON
```

---

## Next Steps

After successful basic build:

1. **Test:** Run manual commands in REPL
2. **Experiment:** Try v0.4.X experiments
3. **GPU:** Build v0.8.0.1 if you have CUDA

---

**Status:** ✅ Ready to build  
**Command:** `./build_basic.sh`  
**Time:** ~30 seconds
