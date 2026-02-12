# 🔨 Build MatLabC++ v0.3.0

**Quick build instructions for getting started**

---

## 🚀 Quick Start (30 seconds)

### Linux / macOS

```bash
# 1. Setup project structure
chmod +x setup_project.sh build.sh
./setup_project.sh

# 2. Build and install
./build.sh install

# 3. Test it
mlab++ --version
```

### Windows

```cmd
REM 1. Open "Developer Command Prompt for VS" or MinGW terminal

REM 2. Setup and build
setup_project.bat
build.bat install

REM 3. Test it
mlab++ --version
```

---

## 📋 What You Need

### Linux
- `cmake` `g++` `make` (required)
- `libcairo2-dev` (optional, for plotting)
- `libgl1-mesa-dev` (optional, for 3D)
- CUDA Toolkit (optional, for GPU)

### macOS
- Xcode Command Line Tools
- CMake (`brew install cmake`)
- Cairo (optional): `brew install cairo`

### Windows
- Visual Studio 2019+ OR MinGW-w64
- CMake from https://cmake.org/download/
- CUDA Toolkit (optional)

---

## 🔧 Build Commands

```bash
./build.sh                  # Build only
./build.sh clean            # Clean build directory
./build.sh install          # Build and install
./build.sh package          # Create release tarball
./build.sh help             # Show all commands
```

---

## 📂 What Gets Built

### Executables
- `mlab++` - Main MATLAB interpreter
- `mlab_pkg` - Package manager CLI

### Libraries
- `libmatlabcpp_core.so` - Core functionality
- `libmatlabcpp_materials.so` - Materials database
- `libmatlabcpp_plotting.so` - Plotting system
- `libmatlabcpp_pkg.so` - Package manager

### Installed To
- Linux/macOS: `~/.local/`
- Windows: `%USERPROFILE%\.local\`

---

## ✅ Verify Installation

```bash
# Add to PATH (if needed)
export PATH="$HOME/.local/bin:$PATH"

# Check version
mlab++ --version
# MatLabC++ v0.3.0

# Check package manager
mlab++ pkg list
# No packages installed

# Run demo
mlab++ matlab_examples/basic_demo.m
```

---

## 🐛 Troubleshooting

### "cmake not found"
```bash
# Linux
sudo apt install cmake         # Ubuntu/Debian
sudo dnf install cmake         # Fedora/RHEL

# macOS
brew install cmake
```

### "No C++ compiler found"
```bash
# Linux
sudo apt install g++           # Ubuntu/Debian
sudo dnf install gcc-c++       # Fedora/RHEL

# macOS
xcode-select --install

# Windows
# Install Visual Studio or MinGW-w64
```

### Build fails
```bash
# Clean and rebuild
./build.sh clean
./build.sh build
```

---

## 📖 Detailed Instructions

See [BUILD.md](BUILD.md) for:
- Advanced build options
- Custom CMake configuration
- Cross-compilation
- IDE integration
- CI/CD setup

---

## 🎯 Next Steps

After successful build:

1. **Install packages:**
   ```bash
   mlab++ pkg install materials_smart plotting
   ```

2. **Run examples:**
   ```bash
   cd matlab_examples
   mlab++ materials_lookup.m --visual
   ```

3. **Build your own:**
   ```matlab
   % my_script.m
   disp('Hello from MatLabC++!');
   ```
   ```bash
   mlab++ my_script.m
   ```

---

## 💻 Development Build

For active development:

```bash
mkdir build-dev && cd build-dev
cmake .. \
    -DCMAKE_BUILD_TYPE=Debug \
    -DBUILD_TESTS=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
make -j$(nproc)
ctest --output-on-failure
```

---

**Questions? See [BUILD.md](BUILD.md) for complete documentation.**
