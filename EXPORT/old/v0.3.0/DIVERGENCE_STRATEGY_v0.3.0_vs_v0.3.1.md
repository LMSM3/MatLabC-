# MatLabC++ Version Divergence Strategy

**Goal:** Keep v0.3.0 pure (stable, tested) while creating v0.3.1 as installer-ready release

---

## Directory Structure

```
MatLabC++/
├── v0.3.0/                         (STABLE - No changes)
│   ├── src/
│   ├── include/
│   ├── scripts/                    (Command wrappers - shared)
│   ├── powershell/
│   ├── examples/
│   ├── CMakeLists.txt              (Version 0.3.0)
│   ├── README.md                   (References 0.3.0)
│   └── assets/                     (Icon - shared with v0.3.1)
│
├── releases/                       (NEW - Release-specific)
│   └── v0.3.1/                    (Installer Release)
│       ├── README.md              (Explains this version)
│       ├── VERSION.txt            (0.3.1)
│       ├── CMakeLists.txt         (Version 0.3.1)
│       ├── installers/
│       │   ├── MatLabCpp_Setup_v0.3.1.iss
│       │   └── build-installer.ps1
│       ├── scripts/               (Symlink or copy)
│       ├── wrappers/              (v0.3.1-specific)
│       │   ├── mlcpp.cmd
│       │   ├── mlc.cmd
│       │   └── mlcpp.ps1
│       └── docs/
│           ├── INSTALLATION_GUIDE.md
│           └── RELEASE_NOTES.md
```

---

## What Changes in v0.3.1 vs v0.3.0

### ✅ v0.3.0 (UNCHANGED)
- Core engine
- Libraries
- Base functionality
- Original version number

### 🆕 v0.3.1 (NEW)
- Windows installer (Inno Setup)
- Command-line wrappers (mlcpp/mlc)
- Installation documentation
- PATH integration
- Versioned to 0.3.1

---

## Shared vs Unique Files

### Shared (Both versions use)
```
v0.3.0/assets/icon.ico              → Used by v0.3.1 installer
v0.3.0/scripts/mlcpp.cmd            → Included in v0.3.1
v0.3.0/scripts/mlc.cmd              → Included in v0.3.1
v0.3.0/scripts/mlcpp.ps1            → Included in v0.3.1
v0.3.0/scripts/mlcpp                → Included in v0.3.1
v0.3.0/scripts/mlc                  → Included in v0.3.1
```

### v0.3.0 Only
```
v0.3.0/CMakeLists.txt               (Version 0.3.0)
v0.3.0/README.md                    (Refers to 0.3.0)
v0.3.0/src/                         (Core implementation)
v0.3.0/include/                     (Headers)
```

### v0.3.1 Only
```
releases/v0.3.1/CMakeLists.txt       (Version 0.3.1)
releases/v0.3.1/installers/MatLabCpp_Setup_v0.3.1.iss
releases/v0.3.1/Update-Version-To-0.3.1.ps1
releases/v0.3.1/build-installer.ps1
releases/v0.3.1/INSTALLATION_GUIDE.md
releases/v0.3.1/RELEASE_NOTES.md
```

---

## Implementation Steps

### Step 1: Keep v0.3.0 Pure
- ✅ Do NOT run Update-Version-To-0.3.1.ps1 on v0.3.0
- ✅ v0.3.0 stays at version 0.3.0
- ✅ v0.3.0 is the stable baseline

### Step 2: Create releases/v0.3.1/ Directory

```powershell
# Create structure
New-Item -ItemType Directory -Path "releases/v0.3.1/installers" -Force
New-Item -ItemType Directory -Path "releases/v0.3.1/wrappers" -Force
New-Item -ItemType Directory -Path "releases/v0.3.1/docs" -Force
```

### Step 3: Copy v0.3.1-Specific Files

```powershell
# Version-specific files
Copy-Item "v0.3.0/Update-Version-To-0.3.1.ps1" "releases/v0.3.1/"
Copy-Item "v0.3.0/installers/MatLabCpp_Setup_v0.3.1.iss" "releases/v0.3.1/installers/"

# Command wrappers
Copy-Item "v0.3.0/scripts/mlcpp.cmd" "releases/v0.3.1/wrappers/"
Copy-Item "v0.3.0/scripts/mlc.cmd" "releases/v0.3.1/wrappers/"
Copy-Item "v0.3.0/scripts/mlcpp.ps1" "releases/v0.3.1/wrappers/"
Copy-Item "v0.3.0/scripts/mlcpp" "releases/v0.3.1/wrappers/"
Copy-Item "v0.3.0/scripts/mlc" "releases/v0.3.1/wrappers/"

# Documentation
Copy-Item "v0.3.0/ICON_SETUP_COMPLETE.md" "releases/v0.3.1/docs/ICON_SETUP.md"
Copy-Item "v0.3.0/COMMAND_LINE_INTEGRATION_SUMMARY.md" "releases/v0.3.1/docs/"
```

### Step 4: Create v0.3.1 Build Script

```powershell
# releases/v0.3.1/BUILD_v0.3.1.ps1
# Builds v0.3.1 installer from v0.3.0 source

$SourceDir = "../../v0.3.0"
$ReleaseDir = $PSScriptRoot

# 1. Copy v0.3.0 to build directory
Copy-Item $SourceDir "v0.3.1_build" -Recurse

# 2. Update version to 0.3.1
cd v0.3.1_build
& PowerShell -File "..\Update-Version-To-0.3.1.ps1"

# 3. Build Release executable
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release

# 4. Run installer compiler
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" `
    "..\installers\MatLabCpp_Setup_v0.3.1.iss"

# Output: releases/v0.3.1/installers/output/MatLabCpp_Setup_v0.3.1.exe
```

---

## File Structure After Divergence

```
MatLabC++/
├── v0.3.0/                              ← STABLE (unchanged)
│   ├── CMakeLists.txt                  (version 0.3.0)
│   ├── README.md                       (v0.3.0)
│   ├── src/                            (core)
│   ├── include/                        (headers)
│   ├── scripts/                        (shared wrappers)
│   ├── powershell/                     (cmdlets)
│   ├── assets/icon.ico                 (shared)
│   └── examples/
│
└── releases/                            ← NEW
    └── v0.3.1/                         (Installer Release)
        ├── README.md                   (How to build v0.3.1)
        ├── VERSION.txt                 (0.3.1)
        ├── BUILD_v0.3.1.ps1            (Build script)
        ├── Update-Version-To-0.3.1.ps1 (Version update)
        ├── installers/
        │   ├── MatLabCpp_Setup_v0.3.1.iss
        │   └── output/                 (generated installer)
        │       └── MatLabCpp_Setup_v0.3.1.exe
        ├── wrappers/                   (copies for reference)
        │   ├── mlcpp.cmd
        │   ├── mlc.cmd
        │   ├── mlcpp.ps1
        │   ├── mlcpp
        │   └── mlc
        ├── docs/
        │   ├── INSTALLATION_GUIDE.md
        │   ├── RELEASE_NOTES.md
        │   └── ICON_SETUP.md
        └── build/                      (temporary, git-ignored)
            └── v0.3.1_build/           (working copy)
```

---

## Build Workflow

### To build v0.3.0 (stable):
```powershell
cd v0.3.0
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
# Output: v0.3.0/build/Release/matlabcpp.exe (v0.3.0)
```

### To build v0.3.1 (with installer):
```powershell
cd releases/v0.3.1
.\BUILD_v0.3.1.ps1
# Output: releases/v0.3.1/installers/output/MatLabCpp_Setup_v0.3.1.exe
```

---

## Benefits of This Structure

✅ **v0.3.0 remains untouched** - No version pollution  
✅ **v0.3.1 is isolated** - Clean, independent build  
✅ **Easy to maintain** - Both versions coexist  
✅ **Clear separation** - No confusion about which version is which  
✅ **Easy to diverge further** - v0.3.2, v0.3.3 can follow same pattern  
✅ **Git-friendly** - Each version is in its own branch/folder  

---

## Git Strategy (Optional)

```bash
# v0.3.0 branch (main, stable)
git checkout -b v0.3.0
git commit -am "v0.3.0 - Stable release"
git tag v0.3.0

# v0.3.1 branch (installer release, based on v0.3.0)
git checkout -b v0.3.1
git commit -am "v0.3.1 - Installer and CLI integration"
git tag v0.3.1
```

---

## Summary

| Aspect | v0.3.0 | v0.3.1 |
|--------|--------|--------|
| **Location** | `v0.3.0/` | `releases/v0.3.1/` |
| **Status** | Stable base | Installer release |
| **Version** | 0.3.0 | 0.3.1 |
| **Installer** | ❌ None | ✅ Inno Setup |
| **Wrappers** | ✅ In scripts/ | ✅ In wrappers/ |
| **Icon** | ✅ assets/ | ✅ assets/ (shared) |
| **Purpose** | Core library | Windows installer |

---

**Status:** ✅ Ready to diverge  
**Next Step:** Create releases/v0.3.1/ directory structure
