# QuickStart — MatLabC++ v0.4.0

Copy-paste the commands for your platform and you will have a running shell
in under a minute.

---

## Linux / macOS

```bash
# 1. Clone
git clone https://github.com/your-org/matlabcpp.git
cd matlabcpp

# 2. Build
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)

# 3. Run
./build/mlab++
```

## Windows (Visual Studio / MSVC)

```powershell
# 1. Clone
git clone https://github.com/your-org/matlabcpp.git
cd matlabcpp

# 2. Build
cmake -B build
cmake --build build --config Release

# 3. Run
.\build\Release\mlab++.exe
```

## Windows (MinGW / MSYS2)

```bash
cmake -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
./build/mlab++.exe
```

---

## Verify It Works

Once the interactive shell starts you should see the `>>>` prompt.
Try these commands:

```
>>> constant pi
pi = 3.141593e+00

>>> material pla
PLA
  Density: 1240 kg/m³ ...

>>> help
```

## Optional Dependencies

| Dependency | CMake flag    | Enables              |
|------------|---------------|----------------------|
| Cairo      | `-DWITH_CAIRO=ON`  | 2-D plot rendering  |
| OpenGL     | `-DWITH_OPENGL=ON` | 3-D plot rendering  |
| CUDA       | `-DWITH_GPU=ON`    | GPU acceleration    |

All are auto-detected; the core REPL builds with **zero** external
dependencies.

## Run Tests

```bash
cmake --build build --target test
# or
cd build && ctest --output-on-failure
```

## Next Steps

- **README.md** — project overview and status table
- **ROADMAP.md** — upcoming milestones
- **examples/**  — sample programs (C++, CLI, Python)
