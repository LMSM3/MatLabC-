# MatLabC++ Quick Reference

## Installation

```bash
# One-command setup
./scripts/setup_all.sh

# Or step-by-step
./scripts/setup_env.sh      # Python environment
./scripts/build_cpp.sh       # C++ compilation
./scripts/test_all.sh        # Verification
```

## Usage

### Interactive CLI

```bash
cd build
./matlabcpp

# Commands:
constant g              # Show gravity constant
material peek           # Show PEEK properties
materials               # List all materials
help                    # Show all commands
```

### Jupyter Notebooks

```bash
conda activate matlabcpp_journal
jupyter notebook notebooks/
```

### Running Benchmarks

```bash
cd build
./benchmark_inference
```

## Project Structure

```
MatLabCPP/
??? include/matlabcpp/     # C++ headers
?   ??? core.hpp           # RK45 solver
?   ??? constants.hpp      # Physical constants
?   ??? materials.hpp      # Material database
?   ??? materials_inference.hpp  # Inference engine
?   ??? system.hpp         # System utilities
?   ??? integration.hpp    # High-level API
??? src/
?   ??? main.cpp           # Interactive CLI
?   ??? benchmark_inference.cpp  # Benchmarks
??? notebooks/             # Jupyter documentation
??? scripts/               # Automation scripts
??? CMakeLists.txt         # Build configuration
```

## Key Features

- **Zero dependencies** - Pure C++ standard library
- **127+ constants** - Physical, engineering, material
- **7 materials** - Engineering plastics with full properties
- **Inference engine** - Material identification from partial data
- **RK45 solver** - Adaptive 5th-order ODE integration
- **Production-ready** - Optimized with -O3, AVX2, LTO

## Build Options

```bash
# Debug build
cmake .. -DCMAKE_BUILD_TYPE=Debug

# Release without native arch (portable)
cmake .. -DCMAKE_BUILD_TYPE=Release -DMATLABCPP_NATIVE_ARCH=OFF

# Skip notebook data generation
cmake .. -DMATLABCPP_BUILD_NOTEBOOKS=OFF
```

## Troubleshooting

### Conda not found
```bash
# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

### CMake version too old
```bash
# Ubuntu/Debian
sudo snap install cmake --classic

# macOS
brew install cmake
```

### Build fails
```bash
# Check compiler
g++ --version    # Should be GCC 10+ or Clang 12+

# Clean rebuild
rm -rf build
./scripts/build_cpp.sh
```

## Performance

Typical benchmark results:

- **Material queries:** 100,000+ per second
- **Inference latency:** <10 microseconds
- **Memory usage:** O(1) - no trajectory storage
- **RK45 step:** ~200 microseconds per integration step

## Citation

```bibtex
@software{matlabcpp2026,
  title={MatLabC++: High-Performance Numerical Computing},
  year={2026}
}
```
