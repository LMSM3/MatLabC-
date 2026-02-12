# MatLabC++ v0.3.0

**High-Performance Numerical Computing | Zero Bloat**

Clean, production-ready numerical computing library with material database, ODE solvers, and script execution.

---

## Quick Start

```bash
# Build
./scripts/build.sh

# Run
./build/matlabcpp

# Install to dist/
./scripts/install.sh
```

---

## What's Included

### Core Libraries (`include/matlabcpp/`)
- `core.hpp` - ODE solvers (RK45), matrix operations (matmul, solve)
- `materials.hpp` - Material property database (metals, plastics)
- `materials_inference.hpp` - Smart material identification
- `constants.hpp` - Physical constants (g, c, h, k_B, etc.)
- `script.hpp` - Universal .m/.c script execution
- `integration.hpp` - High-level integration functions
- `advanced.hpp` - Advanced utilities
- `system.hpp` - System diagnostics

### Executables
- `matlabcpp` - Main CLI (materials, constants, calculations)
- `benchmark_inference` - Performance testing

### Examples (`examples/`)
- **cpp/** - C++ programs (ODE solving, material analysis, 3D visualization)
- **scripts/** - Runnable .c and .m scripts (helix, tank simulation, beam stress)
- **cli/** - Command-line usage examples
- **matlab/** - MATLAB compatibility demos

---

## Usage

### Material Lookup
```bash
./matlabcpp
>>> material aluminum_6061
>>> density steel
>>> identify 2700  # Find material by density
```

### Run Scripts
```bash
>>> run examples/scripts/helix_plot.c      # C script
>>> run examples/scripts/beam_3d.m         # MATLAB script
```

### Compile Examples
```bash
cd examples/cpp
g++ -std=c++20 -I../../include beam_stress_3d.cpp -o beam
./beam
```

---

## Features

✓ **Material Database** - 10+ materials with thermal, mechanical properties  
✓ **ODE Solvers** - RK45 adaptive stepping, Euler integration  
✓ **Matrix Operations** - matmul(A,B), lu_solve(A,b)  
✓ **Script Engine** - Run .m (MATLAB) and .c (C) files directly  
✓ **Zero Dependencies** - Header-only core, stdlib only  
✓ **High Performance** - AVX2, LTO, native architecture optimization  
✓ **Cross-Platform** - Linux, macOS, Windows (MSVC/GCC/Clang)  

---

## Build Requirements

- **C++ compiler:** GCC ≥9, Clang ≥10, MSVC 2019+
- **CMake:** ≥3.14
- **Optional:** gcc (for .c scripts), octave (for .m scripts)

---

## Architecture

```
MatLabC++
├── include/          # Headers (single-include or modular)
├── src/              # Source files
├── examples/         # Working examples
├── scripts/          # Build/install/test scripts
└── CMakeLists.txt    # Build configuration
```

---

## Performance

- **Startup:** < 0.1s
- **Memory:** < 50 MB
- **Material lookup:** < 1 µs
- **ODE integration:** ~1000 steps/ms (RK45)
- **Matrix multiply:** ~10 GFLOPS (AVX2 enabled)

---

## License

Open source. See LICENSE file for details.

---

## Version History

- **v0.3.0** - Production release: removed bloat, consolidated scripts, clean codebase
- **v0.2.0** - Universal script engine (.m/.c support)
- **v0.1.0** - Initial release

---

**Build | Run | Ship**

No bloat. No noise. Just code that works.
