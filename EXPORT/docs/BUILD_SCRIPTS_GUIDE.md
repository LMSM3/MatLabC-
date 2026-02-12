# Build Automation Scripts - Quick Reference

## 🚀 Complete Build & Setup (NEW!)

**The all-in-one build script** - does everything automatically:

```bash
./build_and_setup.sh
```

### What It Does:
1. ✅ Checks system dependencies (CMake, g++, make)
2. 🧹 Cleans old build directory
3. ⚙️ Configures CMake with optimal settings
4. 🔨 Builds the project with parallel jobs
5. ✓ Verifies all build artifacts
6. 🎯 Sets up environment and symlinks

### Options:

```bash
./build_and_setup.sh          # Full build (recommended)
./build_and_setup.sh --help   # Show help
./build_and_setup.sh --clean  # Only clean build directory
./build_and_setup.sh --quick  # Skip dependency checks
```

---

## 📋 Other Build Scripts

### Standard C++ Build
```bash
./scripts/build_cpp.sh        # Simple build
```

### Fancy Animated Builds
```bash
./scripts/fancy_install.sh            # Animated build with progress
./scripts/ultra_fancy_build.sh        # Maximum visual effects
```

### Full Automation (Release Prep)
```bash
./scripts/automate_all.sh     # Complete release automation
```

---

## 🎯 Typical Workflow

### First Time Setup:
```bash
# 1. Clone repository
git clone <repo-url>
cd MatLabC++

# 2. Run complete build
./build_and_setup.sh

# 3. Run MatLabC++
cd build
./mlab++
```

### After Code Changes:
```bash
# Quick rebuild (keeps CMake configuration)
cd build
cmake --build . -j$(nproc)
./mlab++

# OR full rebuild
./build_and_setup.sh
```

### Clean Start:
```bash
# Remove everything and rebuild
./build_and_setup.sh --clean
./build_and_setup.sh
```

---

## 🔧 Manual Build (Advanced)

If you need more control:

```bash
# 1. Create build directory
mkdir -p build
cd build

# 2. Configure CMake
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DBUILD_SHARED_LIBS=ON \
         -DBUILD_EXAMPLES=ON \
         -DBUILD_TESTS=ON \
         -DBUILD_PLOTTING=ON \
         -DWITH_CAIRO=ON \
         -DWITH_OPENGL=ON

# 3. Build
cmake --build . -j$(nproc)

# 4. Run
./mlab++
```

---

## 🐛 Troubleshooting

### Build fails with "CMake not found"
```bash
# Ubuntu/Debian
sudo apt install cmake

# macOS
brew install cmake
```

### Build fails with "No C++ compiler"
```bash
# Ubuntu/Debian
sudo apt install build-essential g++

# macOS
xcode-select --install
```

### Build fails with linking errors
```bash
# Clean and rebuild
./build_and_setup.sh --clean
./build_and_setup.sh
```

### Permission denied on scripts
```bash
chmod +x build_and_setup.sh
chmod +x scripts/*.sh
```

---

## 📊 Build Output

### Successful Build Output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MatLabC++ Complete Build & Setup Automation
Clean → Configure → Build → Verify → Ready
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/6] Checking system dependencies...
  ✓ CMake found (version 3.22.1)
  ✓ g++ found (version 11.4.0)
  ✓ All dependencies found

[2/6] Cleaning build directory...
  ✓ Old build cleaned
  ✓ Build directory ready

[3/6] Configuring CMake...
  ✓ CMake configuration complete

[4/6] Building project...
  ✓ Build complete

[5/6] Verifying build artifacts...
  ✓ mlab++
  ✓ All critical artifacts verified

[6/6] Setting up environment...
  ✓ Executable runs successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Build & Setup Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready to run MatLabC++:
  cd build && ./mlab++
```

---

## ⚡ Performance Tips

### Faster Builds:
```bash
# Use more CPU cores (if you have them)
cd build
cmake --build . -j16    # 16 cores

# Use Ninja (faster than Make)
cmake .. -GNinja
ninja
```

### Minimal Build (faster):
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DBUILD_EXAMPLES=OFF \
         -DBUILD_TESTS=OFF \
         -DBUILD_PLOTTING=OFF
cmake --build . -j$(nproc)
```

---

## 📁 Build Artifacts

After successful build:

```
build/
├── mlab++                      # Main executable
├── libmatlabcpp_core.so        # Core library
├── libmatlabcpp_materials.so   # Materials library
├── libmatlabcpp_plotting.so    # Plotting library
├── libmatlabcpp_pkg.so         # Package manager
└── CMakeFiles/                 # Build metadata
```

---

## 🎯 Quick Commands

```bash
# Full automated build
./build_and_setup.sh

# Run MatLabC++
cd build && ./mlab++

# Rebuild after changes
cd build && cmake --build .

# Clean build
rm -rf build && ./build_and_setup.sh

# Check what was built
ls -lh build/
```

---

## 📚 Related Documentation

- **QUICK_START_CLI.md** - Complete CLI usage guide
- **CODEBASE_REVIEW.md** - Project overview
- **README.md** - Project introduction
- **CMakeLists.txt** - Build configuration

---

**Recommended:** Use `./build_and_setup.sh` for the best automated experience! 🎉
