# MatLabC++

A free, lightweight MATLAB alternative written in C++17.  
< 1 MB binary · starts in < 0.1 s · runs on 8 GB RAM laptops.

## What It Is

MatLabC++ is an open-source numerical computing environment that provides a
MATLAB-compatible interactive shell (REPL), a built-in material-property
database, vector/matrix math, and 2-D/3-D plotting—all compiled from C++ so
it runs anywhere without a licence.

## Current Status (v0.4.0)

| Module              | Status | Notes                                     |
|---------------------|--------|-------------------------------------------|
| Interactive REPL    | ✅     | Active-window with variable workspace     |
| Scalar math         | ✅     | Arithmetic, trig, exp, log, constants     |
| Vector/matrix ops   | ✅     | Core linear-algebra routines              |
| Material database   | ✅     | Smart lookup for engineering materials    |
| Package manager     | ⚠️     | Installs packages; resolver is WIP        |
| 2-D plotting        | ⚠️     | Cairo backend builds; interactive WIP     |
| 3-D plotting        | ⚠️     | OpenGL backend scaffolded                 |
| `.m` script runner  | ❌     | Parsing not yet implemented               |
| `publish()` reports | ❌     | Planned (see ROADMAP.md)                  |
| GPU / CUDA          | ❌     | Kernel stubs only                         |

## Build & Run

```bash
# Configure + build (requires CMake ≥ 3.15 and a C++17 compiler)
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build

# Launch interactive shell
./build/mlab++
```

> See **QUICKSTART.md** for full copy-paste steps on Linux, macOS, and Windows.

## Demo

```
>>> constant pi
pi = 3.141593e+00

>>> material peek
PEEK
  Density:     1320 kg/m³
  Conductivity: 0.25 W/(m·K)
  Melts at:    343°C

>>> drop 100
Dropping object from 100 m...
  Time to ground: 4.52 s
  Final velocity: 44.3 m/s
```

## Repository Layout

```
src/            C++ source (core, cli, plotting, gpu, packages)
include/        Public headers
tests/          Unit & stress tests
examples/       Example programs (C++, CLI, Python, MATLAB reference)
packages/       Package-manager manifests
EXPORT/         Archived old docs, scripts, and .m demo files
```

## Licence

MIT — see [LICENSE](LICENSE)
