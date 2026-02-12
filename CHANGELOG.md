# Changelog

All notable changes to MatLabC++ will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2025-01-XX

### Added
- **Complete Function System**: Implemented MATLAB-compatible function calling with 15+ built-in functions
  - **Display**: `disp(x)` - Display values without showing 'ans'
  - **Statistics**: `sum(x)`, `mean(x)`, `min(x)`, `max(x)` - Array statistics
  - **Array Info**: `size(x)`, `length(x)` - Retrieve dimensions and length
  - **Math**: `sqrt(x)`, `abs(x)` - Square root and absolute value
  - **Trigonometry**: `sin(x)`, `cos(x)`, `tan(x)` - Trigonometric functions
  - **Exponential/Log**: `exp(x)`, `log(x)`, `log10(x)` - Exponential and logarithm functions
- Function argument parsing supporting scalar, vector, and matrix types
- Enhanced `help` command now lists all available functions
- Better error messages for function calls (missing arguments, unknown functions)

### Changed
- Expression evaluator now detects and routes function calls to dedicated handler
- Statement-style functions (like `disp`) no longer show redundant "ans = " output
- Improved error handling with clear messages for invalid function usage

### Technical
- Added `evaluate_function_call()` method to ActiveWindow class
- Function parser handles nested expressions and multiple argument types
- Code now includes `<limits>` for numeric_limits support
- All mathematical functions properly handle scalar, vector, and matrix inputs

## [0.3.0] - 2025-01-XX

### Added
- **Interactive REPL (Active Window)**: Full-featured command-line interface
  - Professional banner with color-coded system information
  - Real-time prompt with ">>>" indicator
  - Graceful exit with Ctrl+C or "quit"/"exit" commands
- **Workspace Management**: Complete variable storage and retrieval system
  - `workspace` - List all variables
  - `clear [var]` - Delete specific variable
  - `clear` - Clear entire workspace
  - `who` - List variable names
- **Variable System**: Support for scalars, vectors, and matrices
  - Variable assignment: `x = 10`, `y = 5`
  - Automatic type detection (Scalar/Vector/Matrix)
- **Expression Evaluation**: Basic mathematical operations
  - Arithmetic: `+`, `-`, `*`, `/`
  - Operator precedence
  - Variable references in expressions
- **Commands**:
  - `help` - Show available commands
  - `version` - Display version information
  - `quit`/`exit` - Exit the program

### Technical
- CMake build system with modular architecture
- Optional dependencies: Cairo (2D plotting), OpenGL (3D), CUDA (GPU)
- Cross-platform compatibility (Linux, WSL, macOS)
- Release configuration with optimizations

## [0.2.3] - 2025-01-XX

### Added - Shell Usability
- **Robust Build Script**: `tools/build_and_check.sh` with enterprise-grade error handling
  - `set -euo pipefail` - Fails loudly instead of silently succeeding
  - Multi-config generator support (handles `build/` and `build/Release/` layouts)
  - Cross-platform parallelism detection (nproc, sysctl, fallback to 4 cores)
  - Environment variable overrides (`BUILD_DIR`, `CONFIG`, `TARGET`)
  - Automatic executable path resolution
  - Built-in version verification after successful build
- **Makefile Targets**: Professional build automation
  - `make build-version-check` - Build and verify (prevents false success)
  - `make configure` - Configure CMake only
  - `make build` - Build project with parallelism
  - `make test` - Run test suite
  - `make run` - Build and launch interactive mode
  - `make clean` - Remove build directory
  - All targets support environment overrides

### Changed
- Build process no longer hides failures behind `|| echo` patterns
- Executable detection works correctly with Visual Studio and Ninja Multi-Config generators
- Parallel build jobs auto-detected based on CPU cores

### Technical
- Shell script uses POSIX-compliant parameter expansion
- Makefile targets use `set -eu` for reliability
- Build verification ensures executable exists and is actually executable (`-x` check)

### Why This Matters
Previous build scripts could report success even when builds failed. This version uses proper error handling (`set -euo pipefail`) and never lies about build status. Critical for CI/CD integration and developer sanity.

## [0.2.0] - Earlier Release

### Initial Features
This version likely included the foundational architecture:
- Basic project structure with CMake
- Core libraries: `matlabcpp_core`, `matlabcpp_materials`, `matlabcpp_plotting`
- Initial Variable and Workspace classes
- Basic expression parser foundation
- Command-line executable entry point
- Basic build script with ANSI colors and progress bars

---

## Version Naming Convention

MatLabC++ follows **Semantic Versioning** (MAJOR.MINOR.PATCH):
- **MAJOR**: Incompatible API changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

Example:
- `0.3.0` → `0.3.1`: Added functions (new feature, patch increment)
- `0.3.1` → `0.4.0`: Would add new major feature like plotting
- `0.4.0` → `1.0.0`: First stable release with complete MATLAB compatibility

---

## Links
- [0.3.1]: Current release
- [0.3.0]: First documented release with interactive REPL
- [0.2.0]: Inferred baseline features
