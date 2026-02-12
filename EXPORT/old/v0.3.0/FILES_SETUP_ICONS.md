# Setup-Icons System Files

## Core Scripts (Required)

### Setup-Icons.ps1
- **Purpose:** Direct icon setup and validation
- **Status:** ✅ Production Ready (fixed critical bug)
- **Size:** ~4 KB
- **Dependencies:** None (native PowerShell 5.0+)

### Setup-Icons-Auto.ps1
- **Purpose:** Smart automation with first-run/location detection
- **Status:** ✅ Production Ready
- **Size:** ~5 KB
- **Dependencies:** Setup-Icons.ps1
- **Creates:** .setup-icons-cache.json

### Setup-Icons-Orchestrator.ps1
- **Purpose:** Master control with profiles and guidance
- **Status:** ✅ Production Ready
- **Size:** ~6 KB
- **Dependencies:** Setup-Icons-Auto.ps1, Setup-Icons.ps1

## Documentation (Reference)

### SETUP_ICONS_AUTOMATION_GUIDE.md
- Complete architecture documentation
- All features explained
- Integration examples
- Troubleshooting guide
- Decision tree for script selection

### SETUP_ICONS_REFACTORING.md
- Details of improvements made
- Comparison of before/after
- Quality metrics
- Testing recommendations

### SETUP_ICONS_FIX_SUMMARY.md
- Summary of bug fix
- Quick reference
- Integration checklist
- Cache file format

### README_SETUP_ICONS.txt
- ASCII-formatted quick reference
- Visual summary
- Quick start section
- Next steps for v0.3.1

## Validation

### Verify-SetupScripts.ps1
- Syntax validation for all three scripts
- Use: `.\Verify-SetupScripts.ps1`
- Result: All scripts valid ✅

## State Cache (Auto-Created)

### .setup-icons-cache.json
- Created on first successful run
- Contains environment and execution metadata
- Location: v0.3.0/.setup-icons-cache.json
- Format: JSON (portable, human-readable)
- Reset: `.\Setup-Icons-Auto.ps1 -ResetCache`

## File Organization

```
v0.3.0/
├─ Setup-Icons.ps1              (Core - Direct setup)
├─ Setup-Icons-Auto.ps1         (Automation - Smart detection)
├─ Setup-Icons-Orchestrator.ps1 (Master - Orchestration)
├─ Verify-SetupScripts.ps1      (Validation)
├─ .setup-icons-cache.json      (State cache - auto-created)
│
├─ SETUP_ICONS_AUTOMATION_GUIDE.md  (Full guide)
├─ SETUP_ICONS_REFACTORING.md       (Improvements detail)
├─ SETUP_ICONS_FIX_SUMMARY.md       (Summary)
├─ README_SETUP_ICONS.txt           (Quick reference)
└─ FILES_SETUP_ICONS.md             (This file)
```

## Usage Priority

### Start Here (Recommended for Most Users)
```powershell
.\Setup-Icons-Orchestrator.ps1
```

### If You Need Direct Control
```powershell
.\Setup-Icons.ps1 -SourceIconPath "path" -Force
```

### For CI/CD Integration
```powershell
.\Setup-Icons-Orchestrator.ps1 -Profile auto -SkipValidation
```

## Feature Matrix

| Feature | Setup-Icons | Setup-Icons-Auto | Setup-Icons-Orchestrator |
|---------|------------|------------------|--------------------------|
| Direct icon setup | ✅ | ✅ (calls Setup-Icons) | ✅ (calls Auto) |
| Parameter support | ✅ | ✅ | ✅ |
| First-run detection | - | ✅ | ✅ (via Auto) |
| Location change detection | - | ✅ | ✅ (via Auto) |
| State caching | - | ✅ | ✅ (via Auto) |
| Multiple profiles | - | ✅ | ✅ |
| Pre-flight checks | - | - | ✅ |
| Status reporting | - | ✅ | ✅ |
| Next steps guide | - | - | ✅ |
| Execution logging | - | ✅ | ✅ |

## Dependency Tree

```
Setup-Icons-Orchestrator.ps1
    │
    └─→ Setup-Icons-Auto.ps1
            │
            └─→ Setup-Icons.ps1
```

## Quick Command Reference

```powershell
# Standard automation (recommended)
.\Setup-Icons-Orchestrator.ps1

# Force re-run
.\Setup-Icons-Orchestrator.ps1 -Profile force

# Preview
.\Setup-Icons-Orchestrator.ps1 -Profile preview

# Status only
.\Setup-Icons-Orchestrator.ps1 -Profile verify

# Direct setup
.\Setup-Icons.ps1

# Direct setup with explicit path
.\Setup-Icons.ps1 -SourceIconPath "path"

# Smart automation with cache reset
.\Setup-Icons-Auto.ps1 -ResetCache -Force

# Validate all scripts
.\Verify-SetupScripts.ps1

# Check cache state
Get-Content .setup-icons-cache.json | ConvertFrom-Json | Format-List

# Reset cache
.\Setup-Icons-Auto.ps1 -ResetCache
```

## Help & Documentation

Get detailed help:
```powershell
Get-Help .\Setup-Icons-Orchestrator.ps1 -Full
Get-Help .\Setup-Icons-Auto.ps1 -Full
Get-Help .\Setup-Icons.ps1 -Full
```

Read guides:
- Full guide: `cat .\SETUP_ICONS_AUTOMATION_GUIDE.md`
- Summary: `cat .\SETUP_ICONS_FIX_SUMMARY.md`
- Refactoring: `cat .\SETUP_ICONS_REFACTORING.md`

## Version Information

- **System Version:** 0.3.1
- **PowerShell Required:** 5.0+
- **Platform:** Windows
- **Status:** Production Ready ✅
- **Last Updated:** 2025-01-24

## Support & Troubleshooting

For detailed troubleshooting, see:
- SETUP_ICONS_AUTOMATION_GUIDE.md → Troubleshooting section
- SETUP_ICONS_FIX_SUMMARY.md → Integration Checklist

For issues:
1. Check cache state: `Get-Content .setup-icons-cache.json`
2. Reset cache: `.\Setup-Icons-Auto.ps1 -ResetCache`
3. Run with -Force: `.\Setup-Icons-Orchestrator.ps1 -Profile force`
4. Review help: `Get-Help .\Setup-Icons-Orchestrator.ps1 -Full`

---

**Total Files:** 10 files  
**Total Size:** ~30 KB (scripts + docs)  
**Status:** ✅ Production Ready
