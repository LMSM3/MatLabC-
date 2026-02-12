# Setup-Icons Automation System - Complete Guide

## Overview

Three-tier automation system for v0.3.1 installer icon setup:

1. **Setup-Icons.ps1** (Core) - Direct icon setup with validation
2. **Setup-Icons-Auto.ps1** (Smart) - First-run/location-change detection  
3. **Setup-Icons-Orchestrator.ps1** (Master) - Coordinated automation with guidance

---

## Quick Start

### Recommended: Use the Orchestrator (Master Control)

```powershell
# Auto-detect and execute if needed (first-time or location change)
.\Setup-Icons-Orchestrator.ps1

# Force re-run regardless of cache
.\Setup-Icons-Orchestrator.ps1 -Profile force

# Preview what would happen (no changes)
.\Setup-Icons-Orchestrator.ps1 -Profile preview

# Check status only
.\Setup-Icons-Orchestrator.ps1 -Profile verify
```

---

## Architecture

```
Setup-Icons-Orchestrator.ps1  ← START HERE
    │
    ├─ Pre-flight Checks
    │   ├─ Verify dependencies
    │   ├─ Check project structure
    │   └─ Report current status
    │
    ├─ Execute Profile
    │   └─ Setup-Icons-Auto.ps1
    │       │
    │       ├─ Get-CacheState (read .setup-icons-cache.json)
    │       ├─ Get-ProjectEnvironment (capture current state)
    │       ├─ Test-FirstRun (no cache = first time)
    │       ├─ Test-LocationChange (hostname/user/path changed)
    │       ├─ Decide: Execute or Skip
    │       │
    │       └─ Execute: Setup-Icons.ps1
    │           ├─ Resolve & validate paths
    │           ├─ Locate source icon
    │           ├─ Create asset directories
    │           ├─ Copy icon
    │           ├─ Verify integrity (SHA256)
    │           └─ Return result object
    │
    ├─ Post-execution Validation
    ├─ Display Status Report
    └─ Show Next Steps Guide
```

---

## File Descriptions

### 1. Setup-Icons.ps1 (Core Script)

**Purpose:** Direct icon setup with full validation

**Features:**
- Parameterized paths (no hard-coded values)
- Auto-detection of icon sources (4 search locations)
- SHA256 hash-based integrity verification
- Case-insensitive user input
- WhatIf/ShouldProcess support
- Returns hashtable result object

**Parameters:**
```powershell
-SourceIconPath <string>    # Explicit icon path (optional)
-ProjectRoot <string>       # Project root (auto-detected if omitted)
-Force                      # Skip confirmation prompts
-WhatIf                     # Preview mode
-Confirm                    # Prompt for each operation
```

**Usage:**
```powershell
# Auto-detect everything
.\Setup-Icons.ps1

# Explicit source path
.\Setup-Icons.ps1 -SourceIconPath "C:\path\to\icon.ico" -Force

# Preview mode
.\Setup-Icons.ps1 -WhatIf

# From script to capture result
$result = & .\Setup-Icons.ps1 -Force
if ($result.Success) {
    Write-Host "Icon: $($result.DestinationIcon)"
}
```

---

### 2. Setup-Icons-Auto.ps1 (Smart Automation)

**Purpose:** First-run and location-change detection

**Features:**
- Detects first execution (no cache)
- Detects location/environment changes:
  - ProjectRoot path changed
  - Hostname changed
  - Username changed
  - OS version changed
- Caches state in JSON format
- Auto-enables -Force for first-run/location-change
- Skips execution if conditions not met
- Idempotent (safe to run repeatedly)

**State Cache:** `.setup-icons-cache.json`
```json
{
  "Environment": {
    "ProjectRoot": "C:\\...",
    "ScriptPath": "C:\\...\\scripts",
    "Hostname": "LAPTOP-USER",
    "Username": "User",
    "OSVersion": "...",
    "PowerShellVersion": "7.4.1",
    "Timestamp": "2025-01-24T..."
  },
  "LastExecution": {
    "Success": true,
    "DestinationIcon": "C:\\...\\assets\\icon.ico",
    "Timestamp": "2025-01-24T..."
  }
}
```

**Parameters:**
```powershell
-Force              # Force execution despite cache
-WhatIf             # Preview mode
-NoCache            # Don't write cache file
-ResetCache         # Delete existing cache
-Verbose            # Verbose output
```

**Usage:**
```powershell
# Smart auto-execution (only runs if needed)
.\Setup-Icons-Auto.ps1

# Force re-run
.\Setup-Icons-Auto.ps1 -Force

# Reset and start fresh
.\Setup-Icons-Auto.ps1 -ResetCache -Force

# Preview
.\Setup-Icons-Auto.ps1 -WhatIf
```

**Detection Logic:**
```
Execute if:
  • -Force flag specified, OR
  • No cache file exists (first run), OR
  • ProjectRoot changed, OR
  • Hostname changed, OR
  • Username changed, OR
  • Icon asset missing

Skip if:
  • Cache valid AND environment matches AND asset exists
```

---

### 3. Setup-Icons-Orchestrator.ps1 (Master Control)

**Purpose:** Coordinated automation with guidance

**Features:**
- 4 execution profiles
- Pre-flight validation checks
- Status reporting
- Post-execution validation
- Actionable next-steps guide
- Execution logging
- Error handling and reporting

**Profiles:**
```
auto      → Smart execution (detect need and run)
force     → Force re-run despite state
preview   → WhatIf mode (show what would happen)
verify    → Status check only (no changes)
```

**Parameters:**
```powershell
-Profile <string>          # auto|force|preview|verify (default: auto)
-SkipValidation            # Skip post-exec validation
```

**Usage:**
```powershell
# Standard operation (recommended)
.\Setup-Icons-Orchestrator.ps1

# Force re-run
.\Setup-Icons-Orchestrator.ps1 -Profile force

# Check status
.\Setup-Icons-Orchestrator.ps1 -Profile verify

# Preview changes
.\Setup-Icons-Orchestrator.ps1 -Profile preview
```

**Output:**
```
Pre-flight Checks:
  ✓ Setup-Icons-Auto.ps1 found
  ✓ Project root validated

Current Status:
  ℹ First execution cached
  ✓ Icon asset found (10.2 KB)

Execution (auto mode):
  ✓ Setup-Icons-Auto.ps1 completed

Post-execution Validation:
  ✓ Icon asset verified

Next Steps for v0.3.1 Installer:
  1. Update Project Version (CMakeLists.txt)
  2. Build Release Executable
  3. Review Installer Configuration
  4. Compile Installer (Inno Setup)
  5. Test Installer (clean Windows VM)
```

---

## Decision Tree: Which Script to Use?

```
┌─ Do you want simple, one-command automation?
│  └─ YES → Use Setup-Icons-Orchestrator.ps1
│
├─ Do you need to manually control settings?
│  └─ YES → Use Setup-Icons.ps1 directly
│
├─ Do you need smart first-run detection?
│  └─ YES → Use Setup-Icons-Auto.ps1
│
└─ Do you want to integrate into CI/CD?
   └─ YES → Use Setup-Icons-Orchestrator.ps1 -Profile auto
```

---

## Automation Scenarios

### Scenario 1: First Developer Setup
```powershell
# On first clone/new machine
.\Setup-Icons-Orchestrator.ps1

# → Detects first-run, auto-enables -Force, copies icon
# → Caches environment state
# → Shows next steps
```

### Scenario 2: Location/Machine Change
```powershell
# After moving project to new path or new machine
.\Setup-Icons-Orchestrator.ps1

# → Detects hostname/path/user changed
# → Auto-enables -Force, re-runs setup
# → Updates cache
```

### Scenario 3: Developer Moved to Different Computer
```powershell
# Just run normally
.\Setup-Icons-Orchestrator.ps1

# → Detects hostname change (LAPTOP-A → LAPTOP-B)
# → Detects user change if applicable
# → Auto-re-runs with fresh settings
# → Updates cache with new environment
```

### Scenario 4: Manual Re-run (Debugging)
```powershell
# Force re-run despite cache
.\Setup-Icons-Orchestrator.ps1 -Profile force

# → Ignores cache state
# → Re-executes everything
# → Updates cache
```

### Scenario 5: Preview Before Committing to CI/CD
```powershell
# See what would happen without executing
.\Setup-Icons-Orchestrator.ps1 -Profile preview

# → Shows [SKIP] for operations (WhatIf mode)
# → No actual changes made
# → Good for CI/CD validation
```

### Scenario 6: CI/CD Pipeline Integration
```powershell
# In build script - idempotent, auto-skips if not needed
.\Setup-Icons-Orchestrator.ps1 -Profile auto -SkipValidation

# → Runs only once per unique build environment
# → Subsequent builds on same machine skip
# → No artifacts left behind (clean build)
```

---

## Cache Management

### View Cache State
```powershell
$cache = Get-Content .\v0.3.0\.setup-icons-cache.json | ConvertFrom-Json
$cache | Format-List

# Output example:
# Environment         : @{ProjectRoot=C:\...; Hostname=LAPTOP-USER; ...}
# LastExecution       : @{Success=True; DestinationIcon=C:\...\icon.ico; ...}
```

### Reset Cache (Start Fresh)
```powershell
# Method 1: Script flag
.\Setup-Icons-Auto.ps1 -ResetCache

# Method 2: Manual deletion
Remove-Item .\v0.3.0\.setup-icons-cache.json -Force
```

### Cache Location
```
v0.3.0\.setup-icons-cache.json
```

---

## Integration Examples

### PowerShell Profile Auto-Setup
```powershell
# Add to your $PROFILE (PowerShell profile)
function Setup-MatLabCppIcons {
    $setupPath = "C:\path\to\MatLabC++\v0.3.0\Setup-Icons-Orchestrator.ps1"
    & $setupPath -Profile auto -SkipValidation
}

# Then use:
# Setup-MatLabCppIcons
```

### CI/CD Pipeline (GitHub Actions)
```yaml
- name: Setup Icons
  shell: pwsh
  run: |
    cd v0.3.0
    .\Setup-Icons-Orchestrator.ps1 -Profile auto -SkipValidation
```

### Build Script (CMake)
```cmake
# In CMakeLists.txt or build.bat
execute_process(
    COMMAND powershell -NoProfile -ExecutionPolicy Bypass 
            -File "${CMAKE_SOURCE_DIR}/v0.3.0/Setup-Icons-Orchestrator.ps1" 
            -Profile auto
)
```

---

## Troubleshooting

### Issue: "Setup-Icons-Auto.ps1 not found"
**Solution:** Ensure both scripts are in the same directory
```powershell
ls .\Setup-Icons*.ps1  # Should see all three scripts
```

### Issue: "Icon asset missing"
**Solution:** Check source icon location
```powershell
# Find icon
Get-ChildItem -Recurse -Filter "*.ico"

# Then specify explicitly
.\Setup-Icons.ps1 -SourceIconPath "C:\path\to\found\icon.ico" -Force
```

### Issue: "Cache says 'already executed' but I need to re-run"
**Solution:** Use -Force or -ResetCache
```powershell
# Option 1: Force this time
.\Setup-Icons-Orchestrator.ps1 -Profile force

# Option 2: Reset and re-run
.\Setup-Icons-Auto.ps1 -ResetCache -Force
```

### Issue: "WhatIf shows no [SKIP] operations"
**Expected behavior:** In WhatIf mode, actual operations are skipped
```powershell
.\Setup-Icons-Orchestrator.ps1 -Profile preview

# You should see:
# [SKIP] Would create directory...
# [SKIP] Would copy icon...
```

---

## Status: Production Ready ✅

- ✅ All scripts syntax verified
- ✅ Error handling implemented
- ✅ State caching functional
- ✅ Auto-detection logic tested
- ✅ WhatIf/ShouldProcess support
- ✅ Comprehensive documentation

---

## Next Steps for v0.3.1

1. Run orchestrator to setup icons:
   ```powershell
   .\Setup-Icons-Orchestrator.ps1
   ```

2. Follow the printed "Next Steps" guide

3. Update CMakeLists.txt version → 0.3.1

4. Build Release executable

5. Test installer on clean Windows VM

---

**Last Updated:** 2025-01-24  
**Version:** 0.3.1  
**Status:** Production Ready ✅
