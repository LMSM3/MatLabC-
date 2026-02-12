# MatLabC++ v0.3.0 Build Instructions

**Complete build system for Linux, macOS, and Windows**

---

## Quick Start

### Linux / macOS

```bash
# Make build script executable
chmod +x build.sh

# Build everything
./build.sh install

# Or step by step
./build.sh clean       # Clean build directory
./build.sh configure   # Configure CMake
./build.sh build       # Build project
./build.sh install     # Install to ~/.local
```

### Windows

```cmd
REM Build everything
build.bat install

REM Or step by step
build.bat clean        # Clean build directory
build.bat configure    # Configure CMake
build.bat build        # Build project
build.bat install      # Install to %USERPROFILE%\.local
```

---

## Prerequisites

### Linux (Ubuntu/Debian)

```bash
# Required
sudo apt install cmake g++ make

# Optional (for full features)
sudo apt install libcairo2-dev      # Plotting backend
sudo apt install libgl1-mesa-dev    # 3D plotting
sudo apt install nvidia-cuda-toolkit # GPU support
```

### Linux (Fedora/RHEL)

```bash
# Required
sudo dnf install cmake gcc-c++ make

# Optional
sudo dnf install cairo-devel        # Plotting backend
sudo dnf install mesa-libGL-devel   # 3D plotting
sudo dnf install cuda               # GPU support
```

### macOS

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Required
brew install cmake

# Optional
brew install cairo          # Plotting backend
brew install glfw3          # 3D plotting
```

### Windows

**Option 1: Visual Studio (Recommended)**

1. Install Visual Studio 2019 or later
2. Select "Desktop development with C++"
3. Install CMake from https://cmake.org/download/

**Option 2: MinGW-w64**

1. Install MinGW-w64 from https://www.mingw-w64.org/
2. Install CMake from https://cmake.org/download/
3. Add both to PATH

**Optional:**
- CUDA Toolkit from NVIDIA (for GPU support)

---

## Build Commands

### Full Build (Recommended)

```bash
# Linux/macOS
./build.sh install

# Windows
build.bat install
```

**This will:**
1. Check dependencies
2. Detect optional features (Cairo, OpenGL, CUDA)
3. Configure CMake
4. Build all components
5. Install to ~/.local (or %USERPROFILE%\.local on Windows)
6. Generate example bundles

### Custom Build Options

#### Clean Build

```bash
# Remove build directory and start fresh
./build.sh clean
./build.sh build
```

#### Configuration Only

```bash
# Just configure CMake (no build)
./build.sh configure
```

#### Build Only

```bash
# Build without installing
./build.sh build
```

#### Run Tests

```bash
# Build and run tests
./build.sh test
```

#### Create Distribution Package

```bash
# Create .tar.gz package
./build.sh package
```

#### Do Everything

```bash
# Clean, build, test, install, package
./build.sh all
```

---

## CMake Options

### Custom Install Location

```bash
# Install to custom directory
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/matlabcpp
make -j$(nproc)
sudo make install
```

### Disable Optional Features

```bash
cmake .. \
    -DBUILD_PLOTTING=OFF      # Disable plotting module
    -DBUILD_EXAMPLES=OFF      # Don't build examples
    -DWITH_CAIRO=OFF          # Force disable Cairo
    -DWITH_OPENGL=OFF         # Force disable OpenGL
    -DWITH_GPU=OFF            # Force disable CUDA
```

### Static Libraries

```bash
cmake .. -DBUILD_SHARED_LIBS=OFF
```

### Debug Build

```bash
cmake .. -DCMAKE_BUILD_TYPE=Debug
```

---

## Build Output

### Executables

- **`mlab++`** - Main MATLAB interpreter
- **`mlab_pkg`** - Package manager CLI

### Libraries

- **`libmatlabcpp_core.so`** - Core functionality
- **`libmatlabcpp_materials.so`** - Materials database
- **`libmatlabcpp_plotting.so`** - Plotting system
- **`libmatlabcpp_pkg.so`** - Package manager

### Installation Structure

```
~/.local/                           (or %USERPROFILE%\.local on Windows)
├── bin/
│   ├── mlab++                      Main executable
│   └── mlab_pkg                    Package manager
├── lib/
│   ├── libmatlabcpp_core.so
│   ├── libmatlabcpp_materials.so
│   ├── libmatlabcpp_plotting.so
│   └── libmatlabcpp_pkg.so
├── include/
│   └── matlabcpp/                  C++ headers
└── share/
    ├── doc/matlabcpp/              Documentation
    ├── matlabcpp/packages/         Module packages
    └── matlabcpp/examples/         MATLAB examples
```

---

## Post-Build Setup

### Add to PATH

**Linux/macOS (bash):**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Linux/macOS (zsh):**
```zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Windows:**
```cmd
setx PATH "%USERPROFILE%\.local\bin;%PATH%"
```

### Verify Installation

```bash
# Check version
mlab++ --version
# MatLabC++ v0.3.0

# Check package manager
mlab++ pkg list
# No packages installed

# Run demo
mlab++ ~/.local/share/matlabcpp/examples/basic_demo.m
```

---

## Building Individual Components

### Core Library Only

```bash
cd build
make matlabcpp_core -j$(nproc)
```

### Materials Module Only

```bash
make matlabcpp_materials -j$(nproc)
```

### Plotting Module Only

```bash
make matlabcpp_plotting -j$(nproc)
```

### Package Manager Only

```bash
make matlabcpp_pkg mlab_pkg -j$(nproc)
```

---

## Troubleshooting

### CMake Cannot Find Compiler

**Linux/macOS:**
```bash
# Install GCC
sudo apt install g++      # Ubuntu/Debian
sudo dnf install gcc-c++  # Fedora/RHEL
brew install gcc          # macOS
```

**Windows:**
- Ensure Visual Studio or MinGW is installed
- Run from "Developer Command Prompt for VS"

### Missing Cairo

**If plotting backend is disabled:**
```bash
# Linux
sudo apt install libcairo2-dev    # Ubuntu/Debian
sudo dnf install cairo-devel      # Fedora/RHEL

# macOS
brew install cairo

# Then rebuild
./build.sh clean
./build.sh build
```

### Missing OpenGL

**If 3D plotting is disabled:**
```bash
# Linux
sudo apt install libgl1-mesa-dev  # Ubuntu/Debian
sudo dnf install mesa-libGL-devel # Fedora/RHEL

# macOS (usually pre-installed)
brew install glfw3                # For window management
```

### CUDA Not Found

**If GPU support is missing:**

1. Install CUDA Toolkit from https://developer.nvidia.com/cuda-downloads
2. Add to PATH:
   ```bash
   export PATH=/usr/local/cuda/bin:$PATH
   export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
   ```
3. Rebuild:
   ```bash
   ./build.sh clean
   ./build.sh build
   ```

### Build Fails with "undefined reference"

**Usually a linking issue:**
```bash
# Clean and rebuild
rm -rf build
./build.sh build
```

### Permission Denied

**If install fails:**
```bash
# Change install prefix to writable location
mkdir ~/matlabcpp
cmake .. -DCMAKE_INSTALL_PREFIX=~/matlabcpp
make install
```

---

## Advanced Build Options

### Cross-Compilation

```bash
# For ARM64 from x86_64
cmake .. \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
    -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
```

### Optimized Build

```bash
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native"
```

### Verbose Build

```bash
make VERBOSE=1
```

### Parallel Build

```bash
# Use all CPU cores
make -j$(nproc)

# Use specific number of cores
make -j8
```

---

## Development Build

### For Active Development

```bash
mkdir build-dev && cd build-dev

cmake .. \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \  # For IDE integration
    -DBUILD_TESTS=ON \                     # Enable tests
    -DCMAKE_CXX_FLAGS="-Wall -Wextra"      # Warnings

make -j$(nproc)
ctest --output-on-failure                  # Run tests
```

### IDE Integration

**CLion / Qt Creator:**
- Open `CMakeLists.txt` as project
- IDE will handle configuration

**VS Code:**
```bash
# Generate compile_commands.json
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

# Link in project root
ln -s build/compile_commands.json .
```

**Visual Studio:**
- File → Open → CMake
- Select `CMakeLists.txt`

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Install dependencies (Linux)
        if: runner.os == 'Linux'
        run: sudo apt install cmake g++ libcairo2-dev
      
      - name: Install dependencies (macOS)
        if: runner.os == 'macOS'
        run: brew install cmake cairo
      
      - name: Build
        run: |
          chmod +x build.sh
          ./build.sh build
      
      - name: Test
        run: ./build.sh test
```

---

## Creating Release Package

### Full Distribution

```bash
# Build everything and create tarball
./build.sh package

# Output: build/MatLabCPlusPlus-0.3.0-Linux.tar.gz
```

### Manual Packaging

```bash
# Install to staging directory
mkdir -p release/matlabcpp
cmake .. -DCMAKE_INSTALL_PREFIX=release/matlabcpp
make -j$(nproc)
make install

# Create tarball
cd release
tar czf MatLabCPlusPlus-0.3.0.tar.gz matlabcpp/

# Test extraction
mkdir test && cd test
tar xzf ../MatLabCPlusPlus-0.3.0.tar.gz
./matlabcpp/bin/mlab++ --version
```

---

## Summary

**Quick build:**
```bash
./build.sh install
```

**Custom build:**
```bash
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=~/mypath
make -j$(nproc)
make install
```

**Verify:**
```bash
mlab++ --version
mlab++ pkg list
```

**Done!** ✅

---

**For more help, see:**
- [README.md](README.md) - Project overview
- [FOR_NORMAL_PEOPLE.md](FOR_NORMAL_PEOPLE.md) - User guide
- [INSTALL_OPTIONS.md](INSTALL_OPTIONS.md) - Installation methods
