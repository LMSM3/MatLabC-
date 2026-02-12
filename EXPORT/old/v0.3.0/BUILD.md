# Build Instructions

## Quick Build

```bash
./scripts/build.sh
```

This will:
1. Clean `build/` directory
2. Configure CMake (Release mode, native optimizations)
3. Compile with maximum parallelism
4. Verify executables

---

## Manual Build

```bash
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DMATLABCPP_NATIVE_ARCH=ON
cmake --build . -j
cd ..
```

---

## Build Options

### CMAKE_BUILD_TYPE
- `Release` (default) - Full optimizations
- `Debug` - Debug symbols, no optimization
- `RelWithDebInfo` - Optimized + debug symbols

### MATLABCPP_NATIVE_ARCH
- `ON` (default) - Use -march=native (best performance, not portable)
- `OFF` - Generic x86-64 (slower, but portable)

### MATLABCPP_BUILD_TESTS
- `OFF` (default) - Minimal build
- `ON` - Build additional test programs

---

## Platform-Specific

### Linux/macOS (GCC/Clang)
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_CXX_COMPILER=g++ \
         -DMATLABCPP_NATIVE_ARCH=ON
```

Optimizations used:
- `-O3 -ffast-math -funroll-loops`
- `-march=native -mtune=native`
- `-mavx2 -mfma` (if supported)
- `-flto` (link-time optimization)
- `-fno-exceptions -fno-rtti` (smaller binary)

### Windows (MSVC)
```powershell
cmake .. -DCMAKE_BUILD_TYPE=Release -DMATLABCPP_NATIVE_ARCH=ON
cmake --build . --config Release
```

Optimizations used:
- `/O2 /Ot /Oi /Ob3`
- `/fp:fast` (fast floating point)
- `/arch:AVX2` (if enabled)
- `/GR- /EHs-c-` (no RTTI/exceptions)

---

## Install

### Stage to dist/ (recommended)
```bash
./scripts/install.sh
```

Creates `dist/` with:
- `bin/` - Executables
- `include/` - Headers
- `examples/` - Example code

Add to PATH:
```bash
export PATH="$(pwd)/dist/bin:$PATH"
matlabcpp --help
```

### System-wide Install
```bash
cd build
sudo cmake --install . --prefix /usr/local
```

---

## Troubleshooting

### "CMake version too old"
**Solution:** Update CMake to ≥3.14
```bash
# Ubuntu
sudo apt install cmake

# macOS
brew install cmake
```

### "No C++ compiler found"
**Solution:** Install GCC or Clang
```bash
# Ubuntu
sudo apt install g++

# macOS (Xcode command-line tools)
xcode-select --install
```

### "AVX2 not found"
**Not an error** - Build will proceed without AVX2. For older CPUs:
```bash
cmake .. -DMATLABCPP_NATIVE_ARCH=OFF
```

### Build very slow
**Solution:** Use all CPU cores
```bash
cmake --build . -j$(nproc)  # Linux
cmake --build . -j$(sysctl -n hw.ncpu)  # macOS
```

---

## Verify Build

```bash
./scripts/test.sh
```

Checks:
- ✓ Dependencies (CMake, compiler)
- ✓ Build artifacts (executables)
- ✓ Headers present
- ✓ Examples present
- ✓ Runtime execution

---

## Clean Build

```bash
rm -rf build
./scripts/build.sh
```

Or:
```bash
cd build
cmake --build . --target clean
cd ..
```

---

## Build from IDE

### Visual Studio (Windows)
1. Open folder in VS 2019+
2. CMake auto-configures
3. Select "Release" configuration
4. Build > Build All

### CLion (Cross-platform)
1. Open CMakeLists.txt as project
2. Select "Release" profile
3. Build > Build Project

### VS Code
1. Install CMake Tools extension
2. Open folder
3. Select kit (GCC/Clang)
4. Build via CMake Tools panel

---

## Advanced Build

### Custom Compiler
```bash
cmake .. -DCMAKE_CXX_COMPILER=/path/to/g++-12
```

### Custom Flags
```bash
cmake .. -DCMAKE_CXX_FLAGS="-O3 -march=skylake -mtune=skylake"
```

### Static Linking
```bash
cmake .. -DCMAKE_EXE_LINKER_FLAGS="-static"
```

### Minimal Size
```bash
cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel
```

---

## Cross-Compilation

### ARM (Raspberry Pi)
```bash
cmake .. -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
         -DMATLABCPP_NATIVE_ARCH=OFF
```

### RISC-V
```bash
cmake .. -DCMAKE_CXX_COMPILER=riscv64-linux-gnu-g++ \
         -DMATLABCPP_NATIVE_ARCH=OFF
```

---

## Continuous Integration

### GitHub Actions
```yaml
- name: Build MatLabC++
  run: |
    ./scripts/build.sh
    ./scripts/test.sh
```

### GitLab CI
```yaml
build:
  script:
    - ./scripts/build.sh
    - ./scripts/test.sh
```

---

**Build time:** ~10-30 seconds (typical laptop)  
**Binary size:** ~500 KB - 2 MB (depends on platform/flags)

For issues, see README.md or check logs in `build/CMakeFiles/`.
