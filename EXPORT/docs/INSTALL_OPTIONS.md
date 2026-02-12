# MatLabC++ Installation Options

Choose your installation based on needs and disk space.

---

## Option 1: Minimal Core (50 MB)

**What you get:**
- ODE solvers (RK45, RK4)
- Basic materials (7 plastics)
- Physical constants
- CLI interface

**Perfect for:**
- Homework problems
- Quick ODE solving
- Laptops with limited space
- Just trying it out

```bash
./scripts/build_cpp.sh --minimal
# or
cmake .. -DMATLABCPP_MODULES="core"
```

---

## Option 2: Standard Install (150 MB)

**What you get:**
- ODE/PDE solvers
- Control systems (PID, state-space)
- Materials database (20 entries)
- Signal processing (FFT, filters)
- Python wrapper

**Perfect for:**
- Typical engineering work
- Balanced features/size
- Most users

```bash
./scripts/build_cpp.sh
# or
cmake .. -DMATLABCPP_MODULES="core,control,signal"
```

---

## Option 3: Full Install (300 MB)

**What you get:**
- Everything in Standard +
- FEM solvers
- 50+ materials database
- Optimization toolkit
- Advanced PDEs
- All examples
- Full documentation

**Perfect for:**
- Power users
- Multiple projects
- Replacing MATLAB completely
- You have disk space

```bash
./scripts/setup_all.sh
# or
cmake .. -DMATLABCPP_MODULES="all"
```

---

## Option 4: Custom Install

Pick exactly what you need:

```bash
cmake .. -DMATLABCPP_MODULES="core,control,fem,materials_extended"
```

**Available modules:**
- `core` - ODE solvers, constants (30 MB)
- `pde` - PDE solvers (25 MB)
- `control` - Control systems, state-space (20 MB)
- `signal` - Signal processing, FFT (40 MB)
- `fem` - Finite element analysis (80 MB)
- `optimization` - Optimizers (15 MB)
- `materials_basic` - 7 plastics (1 MB)
- `materials_extended` - 50+ materials (10 MB)
- `python` - Python wrapper (5 MB)
- `examples` - Worked examples (30 MB)
- `docs` - PDF documentation (20 MB)

**Example custom builds:**

```bash
# Student (homework only)
cmake .. -DMATLABCPP_MODULES="core,materials_basic"
# Size: ~50 MB

# Mechanical engineer
cmake .. -DMATLABCPP_MODULES="core,fem,materials_extended"
# Size: ~120 MB

# Controls engineer
cmake .. -DMATLABCPP_MODULES="core,control,signal"
# Size: ~90 MB

# Everything except FEM
cmake .. -DMATLABCPP_MODULES="core,pde,control,signal,optimization,materials_extended"
# Size: ~150 MB
```

---

## Jupyter Notebook Support

Add Python wrapper to any install:

```bash
cmake .. -DMATLABCPP_MODULES="<your_modules>,python"
pip install -e .
```

Then in notebooks:
```python
import matlabcpp as ml
```

---

## GPU Acceleration (Optional)

Add GPU support for large problems:

```bash
# With CUDA (NVIDIA)
cmake .. -DMATLABCPP_MODULES="all" -DENABLE_CUDA=ON
# Adds: ~200 MB

# With OpenCL (AMD/Intel/NVIDIA)
cmake .. -DMATLABCPP_MODULES="all" -DENABLE_OPENCL=ON
# Adds: ~150 MB
```

---

## Disk Space Summary

| Install Type | Size | Features |
|--------------|------|----------|
| Minimal | 50 MB | ODEs, basic materials |
| Standard | 150 MB | ODEs, PDEs, control, signal |
| Full | 300 MB | Everything |
| Full + GPU | 500 MB | Everything + GPU acceleration |

**vs MATLAB:** 18,000 MB (18 GB)

**Even full install is 36x smaller than MATLAB**

---

## Uninstall

Remove entire installation:
```bash
rm -rf build/
rm -rf ~/.matlabcpp/  # Config files
```

No registry entries, no system files, no residue.

---

## Upgrade

To upgrade to newer version:
```bash
git pull
./scripts/build_cpp.sh
```

Keeps your data and settings.

---

## Option 5: Self-Extracting Examples Bundle (Single-File Install)

**What is it?**
A single executable bash script containing all MATLAB examples. No git, no build system, just download and run.

**What you get:**
- 5 comprehensive MATLAB demo files (~50 KB total)
- Automatic installation to `examples/` directory
- Pre-annotated with run instructions
- Works on any Unix-like system (Linux, macOS, WSL)

**Perfect for:**
- Quick demo/evaluation without full installation
- Distributing examples to students
- Remote systems without git
- Air-gapped environments
- "Just show me what it does"

### Download and Run

```bash
# Download the bundle
wget https://example.com/mlabpp_examples_bundle.sh
# or
curl -O https://example.com/mlabpp_examples_bundle.sh

# Run installer (extracts to ./examples/)
bash mlabpp_examples_bundle.sh

# Or install to specific location
bash mlabpp_examples_bundle.sh /opt/matlabcpp
```

### Generate Your Own Bundle

If you've added custom examples:

```bash
# 1. Put your .m files in matlab_examples/
mkdir matlab_examples
cp your_demo.m matlab_examples/

# 2. Generate bundle
./scripts/generate_examples_bundle.sh

# 3. Distribute single file
# dist/mlabpp_examples_bundle.sh is now portable!
scp dist/mlabpp_examples_bundle.sh user@remote:~/
ssh user@remote './mlabpp_examples_bundle.sh'
```

### What's Included in the Bundle

| File | Description | Size |
|------|-------------|------|
| `basic_demo.m` | Matrix operations, eigenvalues, norms | 2 KB |
| `materials_lookup.m` | Smart materials database queries | 5 KB |
| `gpu_benchmark.m` | GPU acceleration benchmarking | 3 KB |
| `signal_processing.m` | FFT, filtering, spectrograms | 4 KB |
| `linear_algebra.m` | Decompositions, solvers, least squares | 4 KB |

### Running the Examples

After installation:

```bash
cd examples

# Basic demo
mlab++ basic_demo.m --visual

# Materials database (requires materials_smart module)
mlab++ materials_lookup.m --visual --noerrorlogs

# GPU benchmark (requires CUDA/OpenCL)
mlab++ gpu_benchmark.m --enableGPU --visual

# Signal processing
mlab++ signal_processing.m --visual --silentcli

# Linear algebra
mlab++ linear_algebra.m --visual
```

### Bundle Features

✓ **Single-file distribution** - No dependencies, just bash  
✓ **Self-extracting** - Unpacks on execution  
✓ **Auto-annotating** - Adds run instructions to each file  
✓ **Safe self-delete** - Removes itself after installation (from temp locations)  
✓ **Idempotent** - Can run multiple times safely  
✓ **Portable** - Works on Linux, macOS, WSL  
✓ **Size-efficient** - base64 + tar.gz compression  

### Technical Details

The bundle is a bash script with embedded base64-encoded tar.gz payload:
- Header: Bash script with extraction logic (~100 lines)
- Payload: base64(tar.gz(examples/)) (~40 KB for 5 demos)
- Total size: ~50 KB

No external dependencies except standard Unix tools (awk, base64, tar).

---

## Platform-Specific Notes

### Windows
```bash
# Use Visual Studio
cmake .. -G "Visual Studio 17 2022"
cmake --build . --config Release

# Examples bundle works in WSL
wsl bash mlabpp_examples_bundle.sh
```

### macOS
```bash
# May need Xcode command line tools
xcode-select --install
cmake ..
make -j$(sysctl -n hw.ncpu)
```

### Linux
```bash
# Works out of the box
cmake ..
make -j$(nproc)
```

---

## Requirements

**Minimal:**
- C++20 compiler (GCC 10+, Clang 12+, MSVC 2019+)
- CMake 3.14+
- 100 MB free disk space
- 2 GB RAM

**Recommended:**
- Modern compiler (GCC 13+, Clang 16+)
- CMake 3.20+
- 500 MB free disk space
- 8 GB RAM
- SSD (for faster startup)

**Optional:**
- Python 3.8+ (for Jupyter)
- CUDA 11+ (for GPU)
- LaTeX (for PDF docs generation)

---

## Quick Install Comparison

**Just want to try it?**
```bash
./scripts/build_cpp.sh --minimal
cd build && ./matlabcpp
```
(Takes 1 minute, 50 MB)

**Daily engineering work?**
```bash
./scripts/build_cpp.sh
```
(Takes 2 minutes, 150 MB)

**Replace MATLAB completely?**
```bash
./scripts/setup_all.sh
```
(Takes 5 minutes, 300 MB)

---

**No matter which option, it's still 36-360x smaller than MATLAB.**

**Choose based on your needs, not your disk space.**
