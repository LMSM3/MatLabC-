# C++ Bundle Installer

Native C++ installer for MatLabC++ examples.

Intent: Replace bash dependency with compiled binary. Faster, more portable, better error handling.

---

## Quick Start

### Build

```bash
# Using build script (recommended)
./tools/build_installer.sh

# Or with CMake
cmake -B build tools/
cmake --build build
cp build/bundle_installer tools/

# Or direct compilation
g++ -std=c++17 -O2 -Wall tools/bundle_installer.cpp -o tools/bundle_installer
```

### Use

```bash
# Install to current directory
./tools/bundle_installer mlabpp_examples_bundle.sh

# Install to specific location
./tools/bundle_installer mlabpp_examples_bundle.sh /opt/matlabcpp

# Install with sudo
sudo ./tools/bundle_installer mlabpp_examples_bundle.sh /usr/local
```

---

## Features

**Real RAM Monitoring:**
- Linux: `/proc/meminfo`
- macOS: `vm_stat` + `sysctl`
- Windows: `GlobalMemoryStatusEx()`

**Error Handling:**
- Exception-safe
- Clear error messages
- Automatic cleanup on failure
- Exit codes for scripting

**Cross-Platform:**
- Linux (any distro)
- macOS (10.13+)
- Windows (with MinGW/MSVC)
- WSL

**Performance:**
- Compiled binary (no interpreter)
- Direct system calls
- Minimal dependencies
- Fast execution

---

## Why C++ Instead of Bash

| Feature | Bash Script | C++ Binary |
|---------|-------------|------------|
| **Speed** | Slow (interpreted) | Fast (compiled) |
| **Dependencies** | bash, tar, base64 | None (static link) |
| **RAM Monitoring** | Fake/estimates | Real system calls |
| **Error Handling** | Basic | Exception-safe |
| **Portability** | Unix only | Cross-platform |
| **Size** | ~10 KB | ~150 KB |

**Use C++ installer when:**
- Need true cross-platform support
- Want real RAM monitoring
- Distributing to non-Unix systems
- Performance matters
- Need better error handling

**Use bash script when:**
- Unix-only distribution
- Want minimal file size
- Debugging/customization needed
- Users expect shell scripts

---

## Build Options

### Option 1: CMake (Recommended)

```bash
cmake -B build tools/
cmake --build build
cmake --install build  # Installs to /usr/local/bin
```

**Advantages:**
- Professional build system
- Automatic dependency detection
- Platform-specific optimizations
- Testing framework

### Option 2: Direct Compilation

```bash
# Linux/macOS
g++ -std=c++17 -O2 -Wall tools/bundle_installer.cpp -o tools/bundle_installer

# Windows (MinGW)
g++ -std=c++17 -O2 -Wall tools/bundle_installer.cpp -o tools/bundle_installer.exe -lkernel32

# Windows (MSVC)
cl /std:c++17 /O2 /EHsc tools/bundle_installer.cpp
```

**Advantages:**
- No CMake dependency
- Quick one-liner
- Easy to customize

### Option 3: Build Script

```bash
./tools/build_installer.sh
```

**Advantages:**
- Auto-detects compiler
- Falls back to direct compile if no CMake
- Verifies output
- Shows helpful summary


```cpp
RAMMonitor::show_status();
// Output: [RAM] 4096MB/16384MB used (25%)

RAMMonitor::check_available(128);
// Verifies 128MB is available before proceeding
```

### Implementation

**Linux:**
```cpp
struct sysinfo si;
sysinfo(&si);
size_t free_mb = (si.freeram * si.mem_unit) / (1024 * 1024);
```

**macOS:**
```cpp
// Use vm_stat for free pages
FILE* fp = popen("vm_stat | awk '/Pages free/ {print $3}'", "r");
// Convert pages to MB (4KB pages)
```

**Windows:**
```cpp
MEMORYSTATUSEX mem_info;
mem_info.dwLength = sizeof(MEMORYSTATUSEX);
GlobalMemoryStatusEx(&mem_info);
size_t free_mb = mem_info.ullAvailPhys / (1024 * 1024);
```

---

## Error Handling

**Exception-Safe Design:**

```cpp
try {
    if (!installer.install(bundle_path)) {
        // Installation failed
        return 1;
    }
} catch (const std::exception& e) {
    std::cerr << "Exception: " << e.what() << std::endl;
    return 1;
}
```

**Clear Error Messages:**

```
✗ Insufficient RAM: need 128MB, have 64MB
✗ tar not found
✗ Bundle not found: mlabpp_examples_bundle.sh
✗ Payload marker not found
✗ Extraction failed
```

**Automatic Cleanup:**

All temporary files removed on error or completion.

---

## Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MatLabC++ Examples Installer
C++ Native Installer v0.3.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[RAM] 4096MB/16384MB used (25%)

Step 1: Prerequisites
✓ 64MB buffer available
✓ tar available
✓ base64 available

Step 2: Create Directories
✓ Install dir: /opt/matlabcpp
✓ Examples dir: /opt/matlabcpp/examples

Step 3: Extract Payload
✓ Payload marker found
✓ Payload decoded
✓ Files extracted

Step 4: Verify Installation
✓ 10 example files installed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Installation complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Installed:
  Location: /opt/matlabcpp/examples
  Files:    10 examples

Quick Start:
  cd /opt/matlabcpp/examples
  mlab++ basic_demo.m
  mlab++ test_math_accuracy.m
```

---

## Testing

```bash
# Build tests
cmake -B build tools/
ctest --test-dir build

# Manual test
./tools/bundle_installer mlabpp_examples_bundle.sh /tmp/test
ls /tmp/test/examples/
```

---

## Distribution

**Include installer with bundle:**

```bash
# Build installer
./tools/build_installer.sh

# Create distribution
mkdir -p dist
cp tools/bundle_installer dist/
cp dist/mlabpp_examples_bundle.sh dist/

# Archive
tar -czf matlabcpp_installer.tar.gz dist/

# Users extract and run
tar -xzf matlabcpp_installer.tar.gz
./dist/bundle_installer dist/mlabpp_examples_bundle.sh
```

**Or distribute separately:**

```bash
# Download installer binary
curl -O https://site.com/bundle_installer

# Download bundle
curl -O https://site.com/mlabpp_examples_bundle.sh

# Install
./bundle_installer mlabpp_examples_bundle.sh
```

---

## Troubleshooting

**Compilation fails:**

```bash
# Check compiler version
g++ --version  # Need GCC 7+ or Clang 5+

# Install compiler
sudo apt install g++         # Ubuntu/Debian
brew install gcc             # macOS
# Windows: Install MinGW or Visual Studio
```

**Runtime error "tar not found":**

```bash
# Install tar
sudo apt install tar         # Ubuntu/Debian
brew install gnu-tar         # macOS
# Windows: Use WSL or install tar.exe
```

**Permission denied:**

```bash
# Make executable
chmod +x tools/bundle_installer

# Or install with sudo
sudo ./tools/bundle_installer bundle.sh /usr/local
```

---

## Comparison: Test Scripts

### Bash Test (test_bundle_system.sh)

**Features:**
- Real RAM monitoring (via /proc/meminfo, vm_stat, systeminfo)
- Bold text formatting
- Error handling with trap
- 6 integration tests
- ~300 lines

**Usage:**
```bash
./scripts/test_bundle_system.sh
```

### C++ Installer (bundle_installer.cpp)

**Features:**
- Real RAM monitoring (native system calls)
- Cross-platform support
- Exception-safe error handling
- Compiled binary (no bash)
- ~400 lines

**Usage:**
```bash
./tools/bundle_installer mlabpp_examples_bundle.sh
```

---

## Files

| File | Purpose | Size |
|------|---------|------|
| `tools/bundle_installer.cpp` | C++ source | ~15 KB |
| `tools/CMakeLists.txt` | CMake build | ~2 KB |
| `tools/build_installer.sh` | Build script | ~3 KB |
| `tools/bundle_installer` | Compiled binary | ~150 KB |

---

## See Also

- **scripts/test_bundle_system.sh** - Bash test suite
- **tools/build_installer.sh** - Build script
- **tools/CMakeLists.txt** - CMake configuration

---

**C++ installer: Same workflow. Native code. Zero excuses.**
