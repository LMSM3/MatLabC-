# GLOBAL INTEGRATION: Step-by-Step Guide

**Date:** 2025-01-24  
**Goal:** Make MatLabC++ accessible from anywhere on your system

---

## Quick Start (5 minutes)

### Windows PowerShell

```powershell
# 1. Build Release executable (if not already built)
cd C:\Users\Liam\Desktop\MatLabC++
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release

# 2. Add to global PATH
.\Setup-Global-Integration.ps1

# 3. Close and reopen PowerShell, then test:
mlcpp --version
```

### WSL/Bash

```bash
# 1. Run setup script
bash Setup-Bash-Integration.sh

# 2. Reload bash
source ~/.bashrc

# 3. Test
mlcpp --version
```

---

## Detailed Setup

### Step 1: Build Release Executable

**Location:** `C:\Users\Liam\Desktop\MatLabC++`

```powershell
# In Admin PowerShell:
cd C:\Users\Liam\Desktop\MatLabC++

# Create build directory
mkdir build
cd build

# Configure for Release
cmake -DCMAKE_BUILD_TYPE=Release ..

# Build
cmake --build . --config Release

# Verify executable exists
ls .\Release\matlabcpp.exe

# Expected output shows file size and timestamp
```

**Output Location:** `build\Release\matlabcpp.exe`

---

### Step 2: Windows PATH Integration

**What This Does:**
- Adds MatLabC++ to system PATH
- Makes `mlcpp` accessible from any directory
- Works in PowerShell, CMD, VS Code terminals, etc.

**Option A: Automated (Recommended)**

```powershell
# Navigate to project
cd C:\Users\Liam\Desktop\MatLabC++\v0.3.0

# Run integration script
.\Setup-Global-Integration.ps1
```

The script will:
- Validate build path
- Add to PATH
- Verify success

**Option B: Manual**

```powershell
# In Admin PowerShell
$buildPath = "C:\Users\Liam\Desktop\MatLabC++\build\Release"

# Add to PATH permanently
[Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path + ";$buildPath",
    [EnvironmentVariableTarget]::User
)

# Verify
Write-Host $env:Path | Select-String "build"
```

**Step 3: Close and Reopen PowerShell**

You MUST close and reopen PowerShell for PATH changes to take effect.

```
❌ Don't: Continue in same window
✅ Do: Close → Open new PowerShell window
```

**Step 4: Test Windows Integration**

```powershell
# Test from any directory
PS C:\> mlcpp --version

# Test from different paths
PS C:\Users\> mlcpp --help
PS D:\> mlcpp compile program.mlc

# Should all work!
```

---

### Step 3: WSL/Bash Integration

**What This Does:**
- Creates bash aliases for MatLabC++
- Makes `mlcpp` work in WSL/bash
- Bridges Windows executable to Linux environment

**Option A: Automated (Recommended)**

```bash
# In WSL/bash terminal
cd /mnt/c/Users/Liam/Desktop/MatLabC++/v0.3.0

# Run integration script
bash Setup-Bash-Integration.sh
```

The script will:
- Find your bashrc
- Add aliases and functions
- Reload configuration
- Test integration

**Option B: Manual**

```bash
# Edit bashrc
nano ~/.bashrc

# Add at the end:
# MatLabC++ CLI Integration
alias mlcpp='/mnt/c/Users/Liam/Desktop/MatLabC++/build/Release/matlabcpp.exe'
alias mlc='/mnt/c/Users/Liam/Desktop/MatLabC++/build/Release/matlabcpp.exe'

# Save: Ctrl+X, Y, Enter

# Reload
source ~/.bashrc
```

**Step 5: Test Bash Integration**

```bash
# Test from WSL bash
$ mlcpp --version

# Test from different directories
$ cd /tmp
$ mlcpp --help

# Should work!
```

---

## Verification Checklist

### Windows Command Line ✓

```powershell
# From any directory
PS C:\Users\> mlcpp --version
PS C:\> mlcpp --help
PS D:\Projects\> mlcpp compile test.mlc
```

### PowerShell ✓

```powershell
# Test autocomplete
PS> mlcpp [TAB]  # Should show suggestions

# Test with arguments
PS> mlcpp --version
PS> mlcpp compile program.mlc
```

### CMD (Windows Command Prompt) ✓

```cmd
C:\> mlcpp --version
C:\> mlcpp --help
```

### WSL/Bash ✓

```bash
$ mlcpp --version
$ mlcpp --help
$ mlcpp compile program.mlc
```

### VS Code Terminal ✓

```bash
# In VS Code integrated terminal
> mlcpp --version
> mlcpp compile program.mlc
```

---

## Troubleshooting

### "mlcpp command not found" (Windows)

**Problem:** Freshly added to PATH but not recognized

**Solution:**
1. Close current PowerShell window
2. Open NEW PowerShell window
3. Test again

**Why:** PATH changes require shell restart

---

### "The term 'mlcpp' is not recognized" (CMD)

**Problem:** Using old Command Prompt

**Solution:** Use PowerShell instead (or restart CMD)

---

### Path file not found (WSL)

**Problem:** `/mnt/c/Users/Liam/...` doesn't exist

**Solution:** Adjust path in `.bashrc` to match your actual username/path

```bash
# Check actual path:
ls /mnt/c/Users/

# Update .bashrc with correct path
nano ~/.bashrc
# Change path to match your username
```

---

### "Permission denied" (WSL)

**Problem:** Script doesn't have execute permission

**Solution:**
```bash
chmod +x Setup-Bash-Integration.sh
bash Setup-Bash-Integration.sh
```

---

## What Gets Set Up

### Windows PATH Entry
```
C:\Users\Liam\Desktop\MatLabC++\build\Release
```

Added to:
- User environment variables
- Available to all shells
- Persists across restarts

### Bash Aliases
```bash
alias mlcpp='/mnt/c/Users/Liam/Desktop/MatLabC++/build/Release/matlabcpp.exe'
alias mlc='/mnt/c/Users/Liam/Desktop/MatLabC++/build/Release/matlabcpp.exe'
```

Added to:
- `~/.bashrc`
- Loaded on bash startup
- Works in all bash terminals

---

## Testing Your Setup

### Create Test Program

```matlab
% test.mlc
function result = test_add(a, b)
    result = a + b;
end

fprintf('Result: %d\n', test_add(5, 3));
```

### Compile and Run

```powershell
# Windows
PS> mlcpp compile test.mlc
PS> mlcpp run test.mlc

# WSL/Bash
$ mlcpp compile test.mlc
$ mlcpp run test.mlc
```

---

## Next Steps After Integration

1. **Create Quick Start Guide** (for users)
2. **Build Installer Package** (for distribution)
3. **Set Up Package Manager** (apt/chocolatey)
4. **Create IDE Plugins** (VSCode/VisualStudio)

---

## Files Used in This Process

- `Setup-Global-Integration.ps1` - Windows PATH setup
- `Setup-Bash-Integration.sh` - WSL/bash setup
- Build executable: `build\Release\matlabcpp.exe`
- Command wrappers: `scripts\mlcpp.ps1`, `scripts\mlc.cmd`, etc.

---

## Status

- ✅ Icon setup complete
- ⏳ **← You are here: Global integration**
- ⏳ Professional installer
- ⏳ End-user documentation
- ⏳ Package distribution

---

**Once complete, MatLabC++ will be a real, globally-accessible language on your system!**
