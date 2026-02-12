# Shell Build Tools - v0.2.3 Feature

## Overview

Version 0.2.3 introduces **robust, production-grade shell automation** that prevents build failures from being hidden or ignored.

## Key Improvements

### 🛡️ **Prevents Sadness**
- Uses `set -euo pipefail` - fails loudly instead of lying politely
- Never hides build errors behind `|| echo "Failed"` patterns
- Proper exit codes for CI/CD integration

### 🎯 **Cross-Platform & Generator-Agnostic**
- Works with single-config generators (Makefile, Ninja)
- Works with multi-config generators (Visual Studio, Ninja Multi-Config)
- Automatically detects `build/` vs `build/Release/` layouts
- Cross-platform parallelism detection (Linux, macOS, fallback)

### ⚙️ **Environment Variable Overrides**
```bash
BUILD_DIR=out CONFIG=Debug TARGET=mlab++ ./tools/build_and_check.sh
```

## Usage

### Option 1: Shell Script (Recommended for Interactive Use)

```bash
# Make executable (first time only)
chmod +x tools/build_and_check.sh

# Default: Release build in build/ directory
./tools/build_and_check.sh

# Custom configuration
BUILD_DIR=mybuild CONFIG=Debug ./tools/build_and_check.sh
```

**What it does:**
1. ✅ Configures CMake (if needed)
2. ✅ Builds with auto-detected parallelism
3. ✅ Finds executable (single or multi-config layout)
4. ✅ Runs `--version` to verify it actually works
5. ✅ **Fails immediately** if any step breaks

### Option 2: Makefile Targets (Recommended for Development Workflow)

```bash
# Show all available targets
make help

# Build and verify (most common)
make build-version-check

# Just build (no verification)
make build

# Build and run interactive mode
make run

# Run tests
make test

# Clean build directory
make clean

# Custom configuration
BUILD_DIR=out CONFIG=Debug make build-version-check
```

## Why This Exists

### The Problem (v0.2.0 - v0.2.2)
Previous build scripts had patterns like:
```bash
cmake --build . || echo "--- Failed ---"
# Script returns 0 (success) even when build failed! 😱
```

This caused:
- ❌ Developers thinking builds succeeded when they failed
- ❌ CI/CD systems passing broken code
- ❌ Wasted time debugging "successful" failures

### The Solution (v0.2.3)
```bash
set -euo pipefail  # Exit on ANY error
cmake --build .    # If this fails, script exits with error code
```

Now:
- ✅ Build failures immediately stop execution
- ✅ Clear error messages at point of failure
- ✅ Proper exit codes for automation
- ✅ No more lies about success

## Examples

### Basic Build
```bash
$ ./tools/build_and_check.sh
--- Configuring (if needed) ---
  Build directory: build
  Configuration: Release
  Target: mlab++
  Parallel jobs: 16

--- Building target 'mlab++' with -j16 ---
[100%] Built target mlab++

--- Build successful! ---
  Executable: ./build/mlab++

--- Running version check ---
MatLabC++ version 0.3.1
Professional MATLAB-Compatible Numerical Computing

--- Success! Ready to use ---
```

### Debug Build in Custom Directory
```bash
$ BUILD_DIR=debug CONFIG=Debug TARGET=mlab++ ./tools/build_and_check.sh
--- Configuring (if needed) ---
  Build directory: debug
  Configuration: Debug
  Target: mlab++
  Parallel jobs: 16

--- Building target 'mlab++' with -j16 ---
[100%] Built target mlab++

--- Build successful! ---
  Executable: ./debug/mlab++

--- Running version check ---
MatLabC++ version 0.3.1
Professional MATLAB-Compatible Numerical Computing

--- Success! Ready to use ---
```

### Build Failure (Proper Error Handling)
```bash
$ ./tools/build_and_check.sh
--- Configuring (if needed) ---
--- Building target 'mlab++' with -j16 ---
src/main.cpp:10:1: error: expected ';' after class definition
ERROR: Built executable not found or not executable: ./build/mlab++
$ echo $?
1   # Proper non-zero exit code!
```

## Integration with Existing Scripts

### For CI/CD
```bash
#!/bin/bash
# .github/workflows/build.sh
set -e

# Use robust build script
./tools/build_and_check.sh

# If we get here, build actually succeeded!
echo "Build verified - deploying..."
```

### For Development
```bash
# Add to your .bashrc or .zshrc
alias mlab-build='./tools/build_and_check.sh'
alias mlab-run='make run'
alias mlab-clean='make clean && ./tools/build_and_check.sh'
```

## Technical Details

### Error Handling Flags
- `set -e` - Exit immediately if any command fails
- `set -u` - Exit if undefined variable is used
- `set -o pipefail` - Pipeline fails if any command in pipe fails

### Generator Detection Logic
```bash
# Try default path first
EXE_PATH="./build/mlab++"

# If not found, check multi-config layout
if [[ ! -x "${EXE_PATH}" && -x "./build/Release/mlab++" ]]; then
    EXE_PATH="./build/Release/mlab++"
fi

# Verify it's actually executable
[[ -x "${EXE_PATH}" ]] || die "Executable not found!"
```

### Parallelism Detection
```bash
if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)"                    # Linux
elif command -v sysctl >/dev/null 2>&1; then
    JOBS="$(sysctl -n hw.ncpu)"        # macOS
else
    JOBS=4                              # Safe fallback
fi
```

## Comparison: Old vs New

| Feature | v0.2.0-0.2.2 (build_and_setup.sh) | v0.2.3 (tools/build_and_check.sh) |
|---------|-----------------------------------|-----------------------------------|
| Error handling | `|| echo "Failed"` (lies) | `set -euo pipefail` (truth) |
| Multi-config generators | Assumes `build/` only | Auto-detects layout |
| Exit codes | Always 0 (even on failure) | Proper non-zero on failure |
| Parallelism | Linux-only (`nproc`) | Cross-platform detection |
| Environment overrides | None | Full support via env vars |
| CI/CD safe | ❌ No | ✅ Yes |
| Makefile integration | ❌ No | ✅ Yes (`make` targets) |

## What Changed from build_and_setup.sh?

The original `build_and_setup.sh` is **still available** for its full-featured interactive experience with:
- ANSI colors and progress bars
- Dependency checking
- Build artifact verification
- Environment setup with symlinks

The new `tools/build_and_check.sh` is focused on **robustness for automation**:
- Simpler, more focused
- Better error handling
- CI/CD friendly
- Makefile integration

**Use both!**
- `build_and_setup.sh` - First-time setup, interactive use
- `tools/build_and_check.sh` - Daily development, CI/CD, Makefile

## See Also

- `CHANGELOG.md` - Full version history including v0.2.3 rationale
- `build_and_setup.sh` - Original full-featured build script
- `Makefile` - Build targets using the robust script
- `QUICK_START_CLI.md` - Getting started guide
