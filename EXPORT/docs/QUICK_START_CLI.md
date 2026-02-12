# MatLabC++ CLI Quick Start Guide

**Get up and running with MatLabC++ for MATLAB-style computing in 3 steps.**

---

## 🛠️ Step 1: Build MatLabC++

### Platform Support

**Build Environment Compatibility:**

- **✅ Fully Tested:** WSL (Windows Subsystem for Linux), Native Linux (Debian/Ubuntu, RHEL/Fedora/CentOS)
- **✅ Supported:** Native Windows with MSVC (Microsoft Visual C++)
- **⚠️ Experimental:** macOS (should work with minor adjustments)
- **🔥 GPU Mode:** NVIDIA GPU + CUDA Toolkit 12.0+ (v0.8.0.1 beta)

### Prerequisites

**Linux/WSL:**
```bash
# Ubuntu/Debian
sudo apt-get install build-essential cmake g++ libcairo2-dev

# RHEL/Fedora/CentOS
sudo yum install gcc-c++ cmake cairo-devel
```

**Windows (MSVC):**
- Visual Studio 2019+ with C++ Desktop Development workload
- CMake 3.15+ (bundled with VS or standalone)

**macOS (Untested):**
```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install build tools
brew install cmake
xcode-select --install  # For C++ compiler
```

**GPU Mode (Optional - v0.8.0.1):**
```bash
# NVIDIA CUDA Toolkit
wget https://developer.download.nvidia.com/compute/cuda/12.3.0/local_installers/cuda_12.3.0_545.23.06_linux.run
sudo sh cuda_12.3.0_545.23.06_linux.run

# Or via package manager
sudo apt-get install nvidia-cuda-toolkit

# Verify
nvidia-smi  # Check GPU
nvcc --version  # Check CUDA compiler
```

---

### Build Methods

Choose one based on your workflow:

#### **Option A: Automated Build Script** ⭐ *Recommended for First-Time Setup*

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
chmod +x tools/build_and_check.sh
./tools/build_and_check.sh
```

**Features:**
- ✅ Automatic version checking
- ✅ Comprehensive error reporting
- ✅ Build verification
- ✅ Parallel compilation
- ⏱️ Time: ~30-60 seconds (clean build)

**Best for:** First builds, CI/CD, post-update verification

---

#### **Option B: Makefile Targets** ⭐ *Recommended for Development*

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
make build-version-check
```

**Other useful targets:**
```bash
make clean           # Clean build artifacts
make rebuild         # Clean + build
make test           # Run tests
make install        # Install to system
```

**Features:**
- ✅ Fast incremental builds
- ✅ Parallel compilation (auto-detected cores)
- ✅ Version verification built-in
- ⏱️ Time: ~10-20 seconds (incremental)

**Best for:** Active development, quick iterations

---

#### **Option C: Legacy Setup Script** *For Backward Compatibility*

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
./build_and_setup.sh --quick
```

**Features:**
- ✅ Quick mode (skips some checks)
- ✅ Compatible with older setups
- ⏱️ Time: ~20-40 seconds

**Best for:** Reproducing old builds, specific configurations

---

#### **Option D: Manual CMake** *For Advanced Users*

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
rm -rf build
mkdir build && cd build

# Standard build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)

# GPU-enabled build (v0.8.0.1)
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_GPU=ON
cmake --build . -j$(nproc)

# Verify
./mlab++ --version
```

**Features:**
- ✅ Full control over build parameters
- ✅ Custom configurations
- ✅ Direct CMake access
- ⏱️ Time: Variable (depends on options)

**Best for:** Custom builds, debugging build issues, GPU setup

---

### Platform-Specific Notes

#### **Windows (MSVC)**

Use **Developer Command Prompt** or **Developer PowerShell**:

```powershell
cd C:\Users\Liam\Desktop\MatLabC++
mkdir build
cd build

# Configure
cmake .. -G "Visual Studio 17 2022" -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build . --config Release -j %NUMBER_OF_PROCESSORS%

# Run
.\Release\mlab++.exe --version
```

**Key differences:**
- Use `.\mlab++.exe` instead of `./mlab++`
- Use `%NUMBER_OF_PROCESSORS%` instead of `$(nproc)`
- Executables in `build/Release/` not `build/`

#### **macOS (Experimental)**

```bash
# Install prerequisites
brew install cmake

# Use Option A or D
cd /path/to/MatLabC++
rm -rf build
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(sysctl -n hw.ncpu)

# Note: Use sysctl instead of nproc
```

**Known adjustments needed:**
- Replace `nproc` with `sysctl -n hw.ncpu` in scripts
- May need to adjust shell script shebangs for bash/zsh
- Cairo/OpenGL support may require additional Homebrew packages

**⚠️ If you encounter issues on macOS, please report them!**

---

### Build Verification

After building, verify installation:

```bash
# Check version (should show v0.4.0 or v0.8.0.1)
./build/mlab++ --version

# Expected output:
# MatLabC++ version 0.4.0
# Professional MATLAB-Compatible Numerical Computing

# Check files exist
ls -lh build/
```

**Expected artifacts:**

```
build/
├── mlab++                        # Main executable (Linux/macOS)
├── mlab++.exe                    # Main executable (Windows)
├── libmatlabcpp_core.so/.dll     # Core library
├── libmatlabcpp_materials.so/.dll # Materials module
├── libmatlabcpp_plotting.so/.dll  # Plotting module
├── libmatlabcpp_pkg.so/.dll      # Package manager
└── libmatlabcpp_gpu.so/.dll      # GPU module (if CUDA enabled)
```

**Quick sanity check:**

```bash
# Test basic operation
echo "2 + 2" | ./build/mlab++

# Should see:
# ans = 4
```

---

### GPU Build Verification (v0.8.0.1 Beta)

If you built with CUDA support:

```bash
# Check CUDA detected
./build/mlab++ --version
# Should mention "GPU: CUDA 12.x"

# Quick GPU test
echo "A = gpu(rand(100, 100)); B = A * A'; cpu(B);" | ./build/mlab++

# Or use stress tests
./build/mlab++ < tests/run_gpu_stress_tests.m
```

---

### Troubleshooting Build Issues

#### "CMake not found"
```bash
# Ubuntu/Debian
sudo apt-get install cmake

# macOS
brew install cmake

# Windows: Download from cmake.org
```

#### "Compiler not found"
```bash
# Ubuntu/Debian
sudo apt-get install build-essential g++

# macOS
xcode-select --install

# Windows: Install Visual Studio with C++ tools
```

#### "CUDA not found" (GPU mode)
```bash
# Check CUDA installation
which nvcc
nvidia-smi

# Set paths if needed
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
```

#### "Library not found at runtime"
```bash
# Linux: Set library path
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/build

# macOS: Set library path  
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$(pwd)/build

# Or install system-wide
sudo make install
```

#### Build takes too long
```bash
# Use more CPU cores
cmake --build . -j8  # Use 8 cores

# Or reduce parallelism if system struggles
cmake --build . -j2
```

---

### Version Matrix

| Version | Features | Build Time | Status |
|---------|----------|------------|--------|
| v0.3.1 | 15+ functions, REPL | ~20s | ✅ Stable |
| v0.4.0 | Matrices, parser, debug | ~30s | ✅ **Current** |
| v0.8.0.1 | GPU, complex, tensors | ~60s | 🔥 **Beta** |

**Current recommended version:** v0.4.0 (stable)  
**Experimental:** v0.8.0.1 (GPU acceleration, requires CUDA)

---

## 🎯 Step 2: Run MatLabC++

### Interactive Mode (REPL):

```bash
cd build
./mlab++
```

**You'll see:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MatLabC++ v0.3.0 - Professional MATLAB-Compatible Environment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Type 'help' for available commands
Type 'quit' or 'exit' to exit

>>> 
```

### Run a Script:

```bash
./mlab++ script.m
```

### Show Help:

```bash
./mlab++ --help
```

---

## Example Active Window Usage ! :flower:

### Basic Calculations

```matlab
>>> 2 + 2
ans = 4

>>> 5 * 6
ans = 30

>>> sqrt(16)
ans = 4

>>> pi
ans = 3.14159

>>> exp(1)
ans = 2.71828
```

### Variables

```matlab
>>> x = 10
x = 10

>>> y = 20
y = 20

>>> z = x + y
z = 30

>>> x = 5;        % Semicolon suppresses output
>>> x
x = 5
```

### Workspace Management

```matlab
>>> who              % List variables
Variables in workspace:
  x  y  z

>>> whos             % Detailed variable info
Name    Size    Type      Memory
x       1x1     double    8 bytes
y       1x1     double    8 bytes
z       1x1     double    8 bytes

>>> clear x          % Clear single variable
>>> clear            % Clear all variables
>>> clc              % Clear screen
```

---

## 📊 Common MATLAB Operations

### Vectors and Matrices

```matlab
>>> v = [1, 2, 3, 4, 5]
v = [1.0  2.0  3.0  4.0  5.0]

>>> A = [1, 2; 3, 4]
A = 
  1.0  2.0
  3.0  4.0

>>> B = [5, 6; 7, 8]
B = 
  5.0  6.0
  7.0  8.0

>>> C = A + B
C = 
  6.0   8.0
  10.0  12.0

>>> D = A * B        % Matrix multiplication
D = 
  19.0  22.0
  43.0  50.0
```

### Mathematical Functions

```matlab
>>> sin(pi/2)
ans = 1.0

>>> cos(0)
ans = 1.0

>>> log(exp(1))
ans = 1.0

>>> abs(-5)
ans = 5.0

>>> floor(3.7)
ans = 3.0

>>> ceil(3.2)
ans = 4.0

>>> round(3.5)
ans = 4.0
```

### Ranges and Sequences

```matlab
>>> 1:5
ans = [1.0  2.0  3.0  4.0  5.0]

>>> 0:0.5:2
ans = [0.0  0.5  1.0  1.5  2.0]

>>> linspace(0, 10, 5)
ans = [0.0  2.5  5.0  7.5  10.0]
```

---

## 🔬 Material Database

### Material Lookup

```matlab
>>> material pla
Material: PLA (Polylactic Acid)
  Category: Polymer (3D Printing)
  Density: 1240 kg/m³
  Thermal Conductivity: 0.13 W/(m·K)
  Melting Point: 180°C
  Tensile Strength: 50 MPa
  Young's Modulus: 3.5 GPa

>>> material aluminum
Material: Aluminum 6061-T6
  Category: Metal (Structural)
  Density: 2700 kg/m³
  Thermal Conductivity: 167 W/(m·K)
  Melting Point: 660°C
  Tensile Strength: 310 MPa
  Young's Modulus: 69 GPa
```

### Available Materials

- **3D Printing Plastics:** PLA, PETG, ABS, Nylon
- **Engineering Plastics:** PEEK, Polycarbonate
- **Metals:** Aluminum, Steel, Stainless Steel, Titanium, Copper
- **Composites:** Carbon Fiber

---

## 🧮 Engineering Calculations

### Physics Calculations

```matlab
>>> drop 100         % Drop from 100 meters
Dropping object from 100 m...
  Time to ground: 4.52 s
  Final velocity: 44.3 m/s

>>> terminal 70      % Terminal velocity for 70 kg
Terminal velocity for 70 kg mass: 54.2 m/s

>>> g                % Gravitational constant
g = 9.81 m/s²
```

### Physical Constants

```matlab
>>> constant pi
pi = 3.141593

>>> constant e
e = 2.718282

>>> constant c       % Speed of light
c = 299792458 m/s

>>> constant g       % Gravitational acceleration
g = 9.81 m/s²

>>> constant R       % Universal gas constant
R = 8.314 J/(mol·K)
```

---

## 📈 Plotting (if plotting module is built)

### 2D Plots

```matlab
>>> x = linspace(0, 2*pi, 100);
>>> y = sin(x);
>>> plot(x, y)

>>> title('Sine Wave')
>>> xlabel('x')
>>> ylabel('sin(x)')
>>> grid on
```

### Multiple Plots

```matlab
>>> x = 0:0.1:10;
>>> y1 = sin(x);
>>> y2 = cos(x);
>>> plot(x, y1, 'r-', x, y2, 'b--')
>>> legend('sin(x)', 'cos(x)')
```

### 3D Plots

```matlab
>>> [X, Y] = meshgrid(-2:0.1:2, -2:0.1:2);
>>> Z = X.^2 + Y.^2;
>>> surf(X, Y, Z)
>>> title('Paraboloid')
```

---

## 🛠️ Advanced Features

### Script Files

Create `my_script.m`:
```matlab
% My calculation script
x = 10;
y = 20;
z = x + y;
disp(['Result: ', num2str(z)]);

% Material analysis
material pla
```

Run it:
```bash
./mlab++ my_script.m
```

### Loops and Conditionals

```matlab
>>> for i = 1:5
      disp(i)
    end
1
2
3
4
5

>>> x = 10;
>>> if x > 5
      disp('x is greater than 5')
    else
      disp('x is less than or equal to 5')
    end
x is greater than 5
```

### Functions

```matlab
>>> function y = square(x)
      y = x * x;
    end

>>> square(5)
ans = 25
```

---

## 📝 Available Commands

### Workspace Management
- `who` - List variables
- `whos` - Detailed variable information
- `clear` - Clear all variables
- `clear <var>` - Clear specific variable
- `clc` - Clear screen

### System
- `help` - Show help
- `version` - Show version
- `quit` or `exit` - Exit MatLabC++
- `pwd` - Print working directory
- `ls` or `dir` - List files

### Special Operators
- `;` - Suppress output
- `%` - Comment
- `...` - Line continuation

---

## 💡 Tips and Tricks

### 1. Suppress Output
```matlab
>>> x = 100;         % No output
>>> x
x = 100
```

### 2. Multiple Statements
```matlab
>>> x = 5; y = 10; z = x + y
z = 15
```

### 3. Clear Output
```matlab
>>> clc              % Clear screen
>>> clear            % Clear variables
```

### 4. Quick Calculations
```matlab
>>> ans              % Last result
>>> ans * 2          % Use last result
```

### 5. Help System
```matlab
>>> help             % General help
>>> help plot        % Help for specific function
>>> doc matrix       % Documentation
```

---

## 🔧 Troubleshooting

### Build Issues

**Problem:** CMake not found
```bash
# Ubuntu/Debian
sudo apt install cmake

# macOS
brew install cmake

# Windows
# Download from cmake.org
```

**Problem:** Compiler not found
```bash
# Ubuntu/Debian
sudo apt install build-essential g++

# macOS
xcode-select --install

# Windows
# Install Visual Studio with C++ tools
```

**Problem:** Missing dependencies
```bash
# Install optional dependencies for full features
sudo apt install libcairo2-dev libgl1-mesa-dev  # Linux
brew install cairo                               # macOS
```

### Runtime Issues

**Problem:** `mlab++` not found
```bash
# Make sure you're in the build directory
cd build
./mlab++

# OR add to PATH
export PATH=$PATH:$(pwd)/build
```

**Problem:** Library not found
```bash
# Linux: Set LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/build

# macOS: Set DYLD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$(pwd)/build
```

---

## 🎓 Learning Resources

### Built-in Examples

```bash
# Check examples directory
ls examples/

# Run C++ examples
cd examples/cpp
g++ -std=c++17 basic_ode.cpp -o basic_ode
./basic_ode

# Check MATLAB examples
cd matlab_examples
../build/mlab++ basic_demo.m
```

### Documentation

```bash
# Read documentation
less docs/QUICK_START_V0.2.0.md
less README.md

# Check example files
ls examples/cli/*.txt         # CLI examples
ls examples/python/*.py       # Python examples
ls matlab_examples/*.m        # MATLAB scripts
```

---

## 🚀 Next Steps

1. **Explore Examples:**
   ```bash
   cd examples/cli
   cat basic_usage.txt
   ```

2. **Try Material Database:**
   ```matlab
   >>> material list
   >>> material pla
   >>> material steel
   ```

3. **Write Your First Script:**
   ```matlab
   % my_first_script.m
   disp('Hello from MatLabC++!')
   x = 1:10
   y = x.^2
   plot(x, y)
   ```

4. **Check Out Advanced Features:**
   - 3D visualization (examples/cpp/beam_stress_3d.cpp)
   - Material optimization (matlab_examples/materials_optimization.m)
   - GPU benchmarking (matlab_examples/gpu_benchmark.m)

---

## 📞 Getting Help

- **Command help:** Type `help` in the CLI
- **Documentation:** Check `docs/` directory
- **Examples:** Browse `examples/` directory
- **Issues:** Check project README.md

---

**You're ready to use MatLabC++! 🎉**

Open a terminal, run `./build/mlab++`, and start computing!
