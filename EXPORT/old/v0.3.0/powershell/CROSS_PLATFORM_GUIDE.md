# Cross-Platform Building Explained

## Why Different Platforms Need Different Tools

### The Core Problem

Your **source code** (`.c`, `.cpp` files) is **100% portable** across platforms. The **compilation process** is NOT!

```
┌─────────────────────────────────────────────────────┐
│  Your C Source Code (portable)                      │
│  matlabcpp_c_bridge.c                               │
└──────────────┬──────────────────────────────────────┘
               │
               │ COMPILATION (platform-specific!)
               │
       ┌───────┴───────┬──────────────┬────────────┐
       ▼               ▼              ▼            ▼
   Windows          Linux          macOS       WebAssembly
   (.dll)           (.so)        (.dylib)       (.wasm)
```

### Platform Differences

#### 🐧 Linux
- **Compiler:** GCC (pre-installed)
- **Output:** `libmatlabcpp_c_bridge.so`
- **Command:** `gcc -shared -fPIC -o lib.so source.c`
- **✓ Just works!**

#### 🍎 macOS
- **Compiler:** Clang (via Xcode Command Line Tools)
- **Output:** `libmatlabcpp_c_bridge.dylib`
- **Command:** `clang -dynamiclib -o lib.dylib source.c`
- **✓ One command install:** `xcode-select --install`

#### 🪟 Windows
- **Compiler:** **NONE BY DEFAULT!**
- **Output:** `matlabcpp_c_bridge.dll`
- **Command:** `gcc -shared -o lib.dll source.c` (if GCC installed)
- **✗ Must install separately:**
  - Option 1: Visual Studio (4 GB+)
  - Option 2: MinGW-GCC (200 MB)
  - Option 3: Clang/LLVM (500 MB)

---

## Why Windows is Different

### Philosophy

| Aspect | Linux/macOS | Windows |
|--------|-------------|---------|
| **Design** | Developer-first | User-first |
| **Default tools** | Compiler, make, git | Office, Edge, Paint |
| **Package manager** | apt, brew (built-in) | winget (recent), Chocolatey (3rd party) |
| **Binary distribution** | Source code common | Pre-compiled `.exe` expected |

### Historical Reasons

1. **1990s:** Windows was designed for **business users** who run programs, not compile them
2. **Linux:** Designed by developers, for developers (kernel development requires compiler)
3. **macOS:** Unix-based, inherited developer tools culture

### Technical Reasons

**Binary Compatibility:**
- Linux: `glibc` (standard C library) + ELF format
- macOS: `libSystem` + Mach-O format  
- Windows: `msvcrt.dll` (or UCRT) + PE/COFF format

Each has different:
- Calling conventions (how functions pass arguments)
- Name mangling (C++ symbol names)
- Exception handling (SEH vs DWARF)
- Thread-local storage
- DLL/SO loading mechanisms

---

## Solution: GUI Builder

Instead of fighting Windows quirks, use the **GUI Builder** I just created!

### Build the GUI

```powershell
cd v0.3.0\powershell
.\build_gui.ps1
```

### Run the GUI

```powershell
.\bin\Release\net6.0-windows\MatLabCppBuilder.exe
```

Or **double-click** `MatLabCppBuilder.exe` in File Explorer!

### What It Does

1. **Environment Check** - Detects missing tools
2. **One-Click Build** - Handles native + C# compilation
3. **Auto-Install Helper** - Opens MinGW download page
4. **Progress Tracking** - Shows what's happening
5. **Error Messages** - Clear, actionable feedback

---

## Install Compiler (One-Time Setup)

### Option 1: MinGW-GCC (Recommended - 200 MB)

**Easy Way (via GUI):**
1. Run `MatLabCppBuilder.exe`
2. Click "⚙️ Install MinGW-GCC"
3. Download installer
4. Install to `C:\mingw64`
5. Add `C:\mingw64\bin` to PATH

**Manual Way:**
```powershell
# Download from
# https://github.com/niXman/mingw-builds-binaries/releases
# Get: x86_64-*-win32-seh-ucrt-*.7z

# Extract to C:\mingw64
# Add to PATH:
[System.Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path + ";C:\mingw64\bin",
    [System.EnvironmentVariableTarget]::User
)

# Verify
gcc --version
```

### Option 2: Chocolatey Package Manager

```powershell
# Install Chocolatey first (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install MinGW
choco install mingw

# Verify
gcc --version
```

### Option 3: Visual Studio (Large - 4+ GB)

```powershell
# Install Visual Studio 2022 Community (free)
winget install Microsoft.VisualStudio.2022.Community

# Or just Build Tools (smaller)
winget install Microsoft.VisualStudio.2022.BuildTools

# During install, select "Desktop development with C++"
```

---

## After Compiler Install

### Using GUI (Easy)

1. Double-click `MatLabCppBuilder.exe`
2. Click "🚀 BUILD EVERYTHING"
3. Done!

### Using PowerShell (Manual)

```powershell
cd v0.3.0\powershell

# Build native library
.\build_native.ps1

# Build C# module
dotnet build -c Release

# Test
Import-Module .\bin\Release\net6.0\MatLabCppPowerShell.dll
Get-Material aluminum_6061
```

---

## Why This Matters

### What You Built

You created a **polyglot numerical computing system**:

```
C/C++ (performance)
  ↓
C Bridge (FFI compatibility)
  ↓
C# Wrapper (managed code)
  ↓
PowerShell Cmdlets (automation)
```

This is the **same architecture** used by:
- Python's NumPy (C → Python)
- Node.js native modules (C++ → JavaScript)
- Ruby gems with C extensions (C → Ruby)

### Why Cross-Platform is Hard

**Write once, run anywhere** is a **myth** for native code!

Reality:
- **Write once** (source code)
- **Compile everywhere** (different tools/flags per platform)
- **Test everywhere** (different bugs per platform)

Your code is doing it **right** by:
1. Pure C implementation (most portable)
2. Platform-specific build scripts
3. Testing on multiple platforms

---

## Quick Reference

### Command Cheat Sheet

| Task | Linux | macOS | Windows |
|------|-------|-------|---------|
| Install compiler | `sudo apt install gcc` | `xcode-select --install` | `choco install mingw` |
| Build native | `./build_native.sh` | `./build_native.sh` | `.\build_native.ps1` |
| Output file | `lib*.so` | `lib*.dylib` | `*.dll` |
| Check compiler | `gcc --version` | `clang --version` | `gcc --version` |

### Build Commands

```bash
# Linux/macOS
chmod +x build_native.sh
./build_native.sh
dotnet build -c Release

# Windows
.\build_native.ps1
dotnet build -c Release

# Or use GUI
.\MatLabCppBuilder.exe
```

---

## Conclusion

**Is it "just a Linux program"?**  
- The **code**: Yes, portable C
- The **build process**: No, needs platform-specific tools
- The **solution**: Use the GUI builder! 🎨

Windows doesn't include a compiler because it's designed for **running programs**, not **building them**. Linux includes compilers because the **kernel itself** is compiled from source on every system.

You're not doing anything wrong - this is just how cross-platform development works! The GUI tool makes it painless. 🚀
