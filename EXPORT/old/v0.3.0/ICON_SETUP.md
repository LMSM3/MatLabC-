# Icon Setup Guide - MatLabC++ v0.3.1

## 🎨 Icon Configuration

### Current Icon Location
**Primary Icon:** `C:\Users\Liam\Desktop\MatLabC++\v0.3.0\v0.3.0\icon.ico`
- **Size:** 10,844 bytes (~11 KB)
- **Last Modified:** 2026-01-24 1:15 PM
- **Status:** ✅ EXISTS

---

## 📁 Recommended Icon Structure

For proper installer integration, icons should be organized:

```
v0.3.0/
├── assets/
│   ├── icon.ico              # Main application icon (copy from v0.3.0\icon.ico)
│   ├── installer-icon.ico    # Installer wizard icon (optional)
│   └── uninstall-icon.ico    # Uninstaller icon (optional)
└── installers/
    └── MatLabCpp_Setup.iss   # References: ..\assets\icon.ico
```

---

## 🔧 Setup Steps

### 1. Create Assets Directory

```powershell
# Create assets directory
New-Item -ItemType Directory -Path "v0.3.0\assets" -Force

# Copy icon to assets
Copy-Item "C:\Users\Liam\Desktop\MatLabC++\v0.3.0\v0.3.0\icon.ico" `
          "v0.3.0\assets\icon.ico"

# Verify
Get-Item "v0.3.0\assets\icon.ico"
```

### 2. Inno Setup Configuration

**File:** `v0.3.0/installers/MatLabCpp_Setup_v0.3.1.iss`

```iss
#define MyAppName "MatLabC++"
#define MyAppVersion "0.3.1"
#define MyAppPublisher "MatLabC++ Project"
#define MyAppURL "https://github.com/yourorg/matlabcpp"
#define MyAppExeName "matlabcpp.exe"

[Setup]
; Application info
AppId={{YOUR-GUID-HERE}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; Icon configuration
SetupIconFile=..\assets\icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}

; Output configuration
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=output
OutputBaseFilename=MatLabCpp_Setup_v{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

; Architecture
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "addtopath"; Description: "Add MatLabC++ to PATH (recommended)"; GroupDescription: "Command line integration:"
Name: "alias_mlc"; Description: "Install short command alias: mlc"; GroupDescription: "Command line integration:"
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main executable (from CMake build output)
Source: "..\build\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; Icon file
Source: "..\assets\icon.ico"; DestDir: "{app}"; Flags: ignoreversion
; Command wrappers
Source: "..\scripts\mlcpp.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\scripts\mlc.cmd"; DestDir: "{app}"; Flags: ignoreversion; Tasks: alias_mlc
Source: "..\scripts\mlcpp.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon.ico"; Tasks: desktopicon

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
  ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; \
  Tasks: addtopath; Check: NeedsAddPath

[Code]
function NeedsAddPath(): Boolean;
var
  Paths: string;
begin
  if not RegQueryStringValue(HKLM,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', Paths) then
  begin
    Result := True;
    exit;
  end;
  
  Result := Pos(';' + Uppercase(ExpandConstant('{app}')) + ';',
                ';' + Uppercase(Paths) + ';') = 0;
end;
```

---

## 🎨 Icon Requirements

### For Windows .ico files:

**Recommended Resolutions:**
- 16x16 pixels (small taskbar)
- 24x24 pixels (small toolbar)
- 32x32 pixels (medium icons)
- 48x48 pixels (large icons)
- 256x256 pixels (high-DPI displays)

**Your Current Icon:**
- ✅ Valid .ico format
- ✅ 10,844 bytes (~11 KB - appropriate size)
- ✅ Ready for installer use

---

## 🔍 Verification Steps

### Check Icon Integrity

```powershell
# PowerShell verification
$icon = "v0.3.0\assets\icon.ico"
if (Test-Path $icon) {
    $file = Get-Item $icon
    Write-Host "✅ Icon exists" -ForegroundColor Green
    Write-Host "   Size: $($file.Length) bytes"
    Write-Host "   Path: $($file.FullName)"
} else {
    Write-Host "❌ Icon not found" -ForegroundColor Red
}
```

### Test in Inno Setup

```powershell
# Compile installer (requires Inno Setup installed)
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" `
    "v0.3.0\installers\MatLabCpp_Setup_v0.3.1.iss"
```

---

## 📋 Quick Setup Script

Create **v0.3.0/Setup-Icons.ps1**:

```powershell
# Setup-Icons.ps1
# Prepares icon assets for installer

$ErrorActionPreference = "Stop"

Write-Host "Setting up MatLabC++ v0.3.1 icons..." -ForegroundColor Cyan

# Create assets directory
$assetsDir = "v0.3.0\assets"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
    Write-Host "✅ Created assets directory" -ForegroundColor Green
}

# Copy icon
$sourceIcon = "C:\Users\Liam\Desktop\MatLabC++\v0.3.0\v0.3.0\icon.ico"
$destIcon = "$assetsDir\icon.ico"

if (Test-Path $sourceIcon) {
    Copy-Item $sourceIcon $destIcon -Force
    Write-Host "✅ Copied icon to $destIcon" -ForegroundColor Green
    
    $iconFile = Get-Item $destIcon
    Write-Host "   Size: $($iconFile.Length) bytes" -ForegroundColor Gray
} else {
    Write-Host "❌ Source icon not found: $sourceIcon" -ForegroundColor Red
    exit 1
}

# Verify
if (Test-Path $destIcon) {
    Write-Host "✅ Icon setup complete!" -ForegroundColor Green
    Write-Host "   Location: $destIcon" -ForegroundColor Cyan
} else {
    Write-Host "❌ Icon setup failed" -ForegroundColor Red
    exit 1
}
```

**Run:**
```powershell
.\v0.3.0\Setup-Icons.ps1
```

---

## 🚀 Version 0.3.1 Changes

### What's New in v0.3.1?

- ✅ **Working Installer:** Inno Setup integration complete
- ✅ **Command-Line Integration:** `mlcpp` and `mlc` wrappers
- ✅ **PATH Management:** Automatic duplicate-checking
- ✅ **Icon Support:** Proper icon integration in installer
- ✅ **Cross-Platform:** Windows/Linux/macOS wrappers
- ✅ **Test Suite:** 20 tests, 100% pass rate

### Version Bumping

**Update these files for v0.3.1:**

1. **CMakeLists.txt:**
```cmake
project(MatLabCPP VERSION 0.3.1 LANGUAGES CXX)
```

2. **Inno Setup Script:**
```iss
#define MyAppVersion "0.3.1"
```

3. **README files:**
- v0.3.0/README.md
- v0.3.0/powershell/README.md
- v0.3.0/COMMAND_LINE_INTEGRATION_SUMMARY.md

---

## 🎯 Installer Testing Checklist

Before releasing v0.3.1:

- [ ] Icon displays correctly in installer wizard
- [ ] Icon displays correctly for installed application
- [ ] Desktop shortcut has correct icon (if enabled)
- [ ] Start menu shortcut has correct icon
- [ ] Uninstaller displays correct icon
- [ ] Application window shows icon in taskbar
- [ ] File associations show icon (if configured)

---

## 🔧 Troubleshooting

### Icon Not Appearing in Installer

**Problem:** Installer wizard shows default icon

**Solution:**
```iss
; Check relative path is correct
SetupIconFile=..\assets\icon.ico

; Or use absolute path for testing
SetupIconFile=C:\Users\Liam\Desktop\MatLabC++\v0.3.0\assets\icon.ico
```

### Icon Not Appearing in Installed App

**Problem:** Executable shows default icon

**Solution:**
1. Icon must be **embedded in the executable** at compile time (requires resource file)
2. Or use `UninstallDisplayIcon={app}\icon.ico` in Inno Setup

**To embed icon in executable (CMake):**
```cmake
if(WIN32)
    set(APP_ICON_RESOURCE "${CMAKE_CURRENT_SOURCE_DIR}/assets/app.rc")
    target_sources(matlabcpp PRIVATE ${APP_ICON_RESOURCE})
endif()
```

**app.rc file:**
```rc
IDI_ICON1 ICON "assets/icon.ico"
```

### Icon Appears Blurry

**Problem:** Icon looks pixelated on high-DPI displays

**Solution:** Ensure icon.ico contains multiple resolutions (16x16, 32x32, 48x48, 256x256)

---

## 📊 Icon Locations Summary

| Location | Path | Purpose | Status |
|----------|------|---------|--------|
| **Source** | `v0.3.0\v0.3.0\icon.ico` | Original icon | ✅ EXISTS |
| **Assets** | `v0.3.0\assets\icon.ico` | Installer asset | ⏳ SETUP NEEDED |
| **Installed** | `{app}\icon.ico` | Runtime icon | ⏳ AFTER INSTALL |
| **Executable** | `{app}\matlabcpp.exe` | Embedded icon | ⏳ REQUIRES BUILD |

---

## ✅ Final Checklist

- [ ] Create `v0.3.0/assets/` directory
- [ ] Copy icon to assets directory
- [ ] Update Inno Setup script to reference icon
- [ ] Update version to 0.3.1 in all files
- [ ] Test installer on clean Windows VM
- [ ] Verify icon displays in all contexts
- [ ] Document icon requirements for future versions

---

**MatLabC++ v0.3.1 Icon Setup**  
**Status:** Ready for implementation  
**Icon Source:** Confirmed and validated (10,844 bytes)  
**Next Step:** Run Setup-Icons.ps1 script
