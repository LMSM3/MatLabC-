# MatLabC++ v0.3.0 PowerShell Bridge - Documentation Index

## 🎯 Start Here

**New to PowerShell bridge?**
→ Start with [README.md](README.md) - 5 minute quick start

**Need comprehensive guide?**
→ Read [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) - Complete reference (800 lines)

**Want PDF documentation?**
→ Run `.\Generate-PDF.ps1` or see [PDF_GENERATION.md](PDF_GENERATION.md)

**Looking for examples?**
→ See [examples/BeamAnalysis.ps1](examples/BeamAnalysis.ps1) - 3D beam stress calculation

---

## 📚 Documentation Structure

### 1. Quick Reference (READ FIRST)

| Document | Lines | Purpose | Audience |
|----------|-------|---------|----------|
| **[README.md](README.md)** | 300 | Quick start, basic usage | Everyone |
| **[POWERSHELL_SUMMARY.md](POWERSHELL_SUMMARY.md)** | 150 | High-level overview | Managers, reviewers |
| **[PACKAGE_COMPLETE.md](PACKAGE_COMPLETE.md)** | 600 | Complete package description | Developers |

**Estimated reading time:** 10-15 minutes

### 2. Comprehensive Guides (DEEP DIVE)

| Document | Lines | Purpose | Audience |
|----------|-------|---------|----------|
| **[POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md)** ⭐ | 800 | Complete technical reference | Developers, users |
| **[PDF_GENERATION.md](PDF_GENERATION.md)** | 300 | How to create PDF docs | Documentation writers |
| **[INDEX.md](INDEX.md)** | This file | Navigation hub | Everyone |

**Estimated reading time:** 1-2 hours

### 3. Code Examples (HANDS-ON)

| File | Lines | Purpose | Difficulty |
|------|-------|---------|------------|
| **[examples/BeamAnalysis.ps1](examples/BeamAnalysis.ps1)** | 300 | 3D beam stress analysis | Intermediate |
| **[Generate-PDF.ps1](Generate-PDF.ps1)** | 400 | Automated PDF generation | Beginner |

**Estimated time:** 30 minutes to run and understand

### 4. Source Code (DEVELOPERS)

| File | Lines | Language | Purpose |
|------|-------|----------|---------|
| **[matlabcpp_c_bridge.c](matlabcpp_c_bridge.c)** | 400 | C99 | Native bridge library |
| **[MatLabCppPowerShell.cs](MatLabCppPowerShell.cs)** | 500 | C# 10 | PowerShell cmdlets |
| **[MatLabCppPowerShell.csproj](MatLabCppPowerShell.csproj)** | 25 | XML | .NET project file |
| **[build_native.ps1](build_native.ps1)** | 60 | PowerShell | Windows build script |
| **[build_native.sh](build_native.sh)** | 40 | Bash | Linux/macOS build |

**Total code:** ~1,025 lines

---

## 🗺️ Usage Flowchart

```
START
  │
  ├─ Need to install? ──→ README.md (Quick Start section)
  │
  ├─ Want to understand architecture? ──→ POWERSHELL_SUMMARY.md
  │
  ├─ Need complete reference? ──→ POWERSHELL_GUIDE.md
  │
  ├─ Want PDF version? ──→ Generate-PDF.ps1 → PDF_GENERATION.md
  │
  ├─ Looking for examples? ──→ examples/BeamAnalysis.ps1
  │
  ├─ Need troubleshooting? ──→ POWERSHELL_GUIDE.md (Section 7)
  │
  ├─ Want to extend/modify? ──→ matlabcpp_c_bridge.c + MatLabCppPowerShell.cs
  │
  └─ Need package overview? ──→ PACKAGE_COMPLETE.md
```

---

## 📖 Reading Paths

### Path 1: Quick Start (10 minutes)
For users who just want to get started:

1. **[README.md](README.md)** - Installation and basic usage
2. Run build scripts (`build_native.ps1` or `build_native.sh`)
3. Import module: `Import-Module .\bin\Debug\net6.0\MatLabCppPowerShell.dll`
4. Test: `Get-Material aluminum_6061`

**Outcome:** Working PowerShell module with 5 cmdlets

### Path 2: Example-Driven (30 minutes)
For developers who learn by doing:

1. **[README.md](README.md)** - Build and install
2. **[examples/BeamAnalysis.ps1](examples/BeamAnalysis.ps1)** - Study complete example
3. Run example: `.\examples\BeamAnalysis.ps1`
4. Modify example for your use case
5. Refer to **[POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md)** as needed

**Outcome:** Understanding through practical application

### Path 3: Comprehensive Study (2 hours)
For developers who need deep understanding:

1. **[POWERSHELL_SUMMARY.md](POWERSHELL_SUMMARY.md)** - Architecture overview
2. **[POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md)** - Complete reference
   - Section 1: Executive Summary
   - Section 2: Installation
   - Section 3: Cmdlet Reference
   - Section 4: Usage Examples
   - Section 5: Architecture
   - Section 6: Performance
   - Section 7: Troubleshooting
   - Section 8: API Documentation
3. **[matlabcpp_c_bridge.c](matlabcpp_c_bridge.c)** - Study C implementation
4. **[MatLabCppPowerShell.cs](MatLabCppPowerShell.cs)** - Study C# cmdlets
5. **[examples/BeamAnalysis.ps1](examples/BeamAnalysis.ps1)** - Apply knowledge

**Outcome:** Expert-level understanding, ready to extend

### Path 4: Documentation Creation (1 hour)
For technical writers or project leads:

1. **[POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md)** - Review content
2. **[PDF_GENERATION.md](PDF_GENERATION.md)** - Learn PDF creation methods
3. **[Generate-PDF.ps1](Generate-PDF.ps1)** - Generate PDF
4. Review generated PDF: `MatLabCpp_PowerShell_Guide.pdf`
5. Customize/brand if needed

**Outcome:** Professional PDF documentation

---

## 🎓 Skill Levels

### Beginner
**Prerequisites:** Basic PowerShell knowledge

**Start here:**
- [README.md](README.md) - Installation and basic usage
- [POWERSHELL_SUMMARY.md](POWERSHELL_SUMMARY.md) - What it does

**Cmdlets to try:**
```powershell
Get-Material aluminum_6061
Get-Constant pi
```

**Example:**
```powershell
# Simple material lookup
$mat = Get-Material steel
Write-Host "Density: $($mat.Density) kg/m³"
```

### Intermediate
**Prerequisites:** PowerShell scripting, basic numerical computing

**Start here:**
- [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) Sections 1-4
- [examples/BeamAnalysis.ps1](examples/BeamAnalysis.ps1)

**Cmdlets to master:**
```powershell
Find-Material 2700 -Tolerance 50
Invoke-ODEIntegration -Height 100
Invoke-MatrixMultiply $A $B
```

**Example:**
```powershell
# Drop simulation pipeline
Invoke-ODEIntegration -Height 50 |
  Where-Object { $_.PositionZ -le 0 } |
  Select-Object -First 1 |
  Format-Table Time, VelocityZ
```

### Advanced
**Prerequisites:** C#, P/Invoke, numerical methods

**Start here:**
- [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) Sections 5-8
- [matlabcpp_c_bridge.c](matlabcpp_c_bridge.c) source code
- [MatLabCppPowerShell.cs](MatLabCppPowerShell.cs) source code

**Tasks:**
- Understand 3-layer architecture
- Study P/Invoke marshalling
- Profile performance
- Extend with new cmdlets

**Example:**
```csharp
// Add new cmdlet
[Cmdlet(VerbsCommon.Get, "Stress")]
public class GetStressCmdlet : PSCmdlet {
    [Parameter] public double Moment { get; set; }
    [Parameter] public double Distance { get; set; }
    [Parameter] public double Inertia { get; set; }
    
    protected override void ProcessRecord() {
        double stress = (Moment * Distance) / Inertia;
        WriteObject(stress);
    }
}
```

---

## 🔍 Document Deep Dive

### README.md
**Purpose:** Get users running in 5 minutes  
**Sections:**
- Documentation links
- Quick start (build, import, test)
- All 5 cmdlets with examples
- Performance notes
- Troubleshooting basics

**When to read:** First document, always

### POWERSHELL_GUIDE.md ⭐
**Purpose:** Complete technical reference  
**Sections:**
1. Executive Summary - Why use this
2. Installation - Prerequisites, build steps (Windows/Linux/macOS)
3. Cmdlet Reference - All 5 cmdlets, parameters, examples
4. Usage Examples - Material selection, drop simulation, stress pipeline, Python export
5. Architecture - 3-layer design, memory marshalling, P/Invoke
6. Performance - Benchmarks, comparisons, optimization tips
7. Troubleshooting - DLL loading, build issues, common errors
8. API Documentation - MaterialInfo, IntegrationSample classes
9. Appendices - Build scripts, report generation

**When to read:** For complete understanding or reference

### POWERSHELL_SUMMARY.md
**Purpose:** High-level overview for stakeholders  
**Sections:**
- What is it (2 paragraphs)
- Key features (bullet list)
- Quick start (3 commands)
- Example usage (4 scenarios)
- Architecture diagram
- Benefits (PowerShell integration advantages)
- Next steps

**When to read:** For presentations, reviews, or quick understanding

### PDF_GENERATION.md
**Purpose:** How to create professional PDF docs  
**Sections:**
- 5 methods (pandoc, wkhtmltopdf, VS Code, online, browser)
- Installation instructions for each
- Comparison table
- Customization (cover page, styling)
- Troubleshooting
- Automation examples

**When to read:** When you need PDF for distribution or review

### PACKAGE_COMPLETE.md
**Purpose:** Complete package description  
**Sections:**
- What's included (all files listed)
- Quick start (60 seconds)
- Architecture diagram
- Usage examples (4 scenarios)
- Performance table
- Documentation formats
- Troubleshooting
- File structure
- Comparison with MATLAB
- Learning path
- Next steps

**When to read:** For comprehensive overview of entire package

---

## 🛠️ Common Tasks

### Task: Install and Test (5 min)
```powershell
# 1. Build
cd v0.3.0/powershell
.\build_native.ps1
dotnet build

# 2. Import
Import-Module .\bin\Debug\net6.0\MatLabCppPowerShell.dll

# 3. Test
Get-Material aluminum_6061
```

**Documentation:** [README.md](README.md) Quick Start

### Task: Run Beam Example (10 min)
```powershell
# Run analysis
.\examples\BeamAnalysis.ps1

# View output
Import-Csv beam_3d_powershell.csv | Format-Table
```

**Documentation:** [examples/BeamAnalysis.ps1](examples/BeamAnalysis.ps1)

### Task: Generate PDF (15 min)
```powershell
# Auto-detect method
.\Generate-PDF.ps1

# Or force specific method
.\Generate-PDF.ps1 -Method pandoc
```

**Documentation:** [PDF_GENERATION.md](PDF_GENERATION.md)

### Task: Create Custom Script (30 min)
```powershell
# 1. Study examples
Get-Help Get-Material -Examples
notepad examples\BeamAnalysis.ps1

# 2. Reference guide
notepad POWERSHELL_GUIDE.md  # Section 3: Cmdlet Reference

# 3. Create your script
# ... use cmdlets for your specific problem
```

**Documentation:** [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) Sections 3-4

### Task: Extend with New Cmdlet (2 hours)
```powershell
# 1. Study architecture
notepad POWERSHELL_GUIDE.md  # Section 5: Architecture

# 2. Study existing code
notepad matlabcpp_c_bridge.c
notepad MatLabCppPowerShell.cs

# 3. Add to C bridge (e.g., new material)
# Edit matlabcpp_c_bridge.c

# 4. Add C# cmdlet (if needed)
# Edit MatLabCppPowerShell.cs

# 5. Rebuild
.\build_native.ps1
dotnet build

# 6. Test
Import-Module .\bin\Debug\net6.0\MatLabCppPowerShell.dll -Force
```

**Documentation:** 
- [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) Section 5
- [matlabcpp_c_bridge.c](matlabcpp_c_bridge.c)
- [MatLabCppPowerShell.cs](MatLabCppPowerShell.cs)

---

## 📊 Documentation Statistics

### Total Documentation
- **Files:** 6 markdown + 1 index
- **Lines:** ~3,100 total
- **Size:** ~180 KB

### Breakdown
| Document | Lines | Words | Read Time |
|----------|-------|-------|-----------|
| README.md | 300 | 2,400 | 10 min |
| POWERSHELL_GUIDE.md | 800 | 6,500 | 45 min |
| POWERSHELL_SUMMARY.md | 150 | 1,200 | 5 min |
| PDF_GENERATION.md | 300 | 2,500 | 15 min |
| PACKAGE_COMPLETE.md | 600 | 4,800 | 30 min |
| INDEX.md | 400 | 3,000 | 15 min |
| **Total** | **2,550** | **20,400** | **2 hours** |

### Code Statistics
| File | Lines | Language | Complexity |
|------|-------|----------|------------|
| matlabcpp_c_bridge.c | 400 | C99 | Medium |
| MatLabCppPowerShell.cs | 500 | C# | Medium |
| BeamAnalysis.ps1 | 300 | PowerShell | Low |
| Generate-PDF.ps1 | 400 | PowerShell | Medium |
| build_native.ps1 | 60 | PowerShell | Low |
| build_native.sh | 40 | Bash | Low |
| **Total** | **1,700** | Mixed | - |

---

## 🎯 Quick Reference Card

### 5 Core Cmdlets
```powershell
Get-Material <name>                    # Material properties
Find-Material <density> [-Tolerance]   # Search by density
Get-Constant <name>                    # Physical constants
Invoke-ODEIntegration -Height <h>      # Drop simulation
Invoke-MatrixMultiply $A $B            # Matrix math (alias: matmul)
```

### Common Parameters
```powershell
-Name           # Material/constant name (string)
-Density        # Material density kg/m³ (double)
-Tolerance      # Search tolerance (double)
-Height         # Drop height in meters (double)
-Mass           # Object mass in kg (double, default: 1.0)
-TimeStep       # Integration step in s (double, default: 0.01)
-Duration       # Max simulation time in s (double, default: 10.0)
-MatrixA        # First matrix (double[][])
-MatrixB        # Second matrix (double[][])
```

### Build Commands
```powershell
# Windows
.\build_native.ps1 && dotnet build

# Linux/macOS
./build_native.sh && dotnet build

# Import
Import-Module .\bin\Debug\net6.0\MatLabCppPowerShell.dll
```

### Help Commands
```powershell
Get-Command -Module MatLabCppPowerShell
Get-Help Get-Material
Get-Help Get-Material -Examples
Get-Help Get-Material -Full
```

---

## 📞 Need Help?

### Documentation Issues
- **Can't find information?** → Check this INDEX.md for navigation
- **Need quick reference?** → See [POWERSHELL_SUMMARY.md](POWERSHELL_SUMMARY.md)
- **Want details?** → See [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md)

### Build Issues
- **Build fails?** → See [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) Section 7 (Troubleshooting)
- **DLL not found?** → Rebuild native: `.\build_native.ps1`
- **.NET errors?** → Check: `dotnet --version` (need 6.0+)

### Usage Questions
- **How do I...?** → See [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) Section 4 (Examples)
- **What parameters?** → See [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) Section 3 (Cmdlet Reference)
- **Performance?** → See [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md) Section 6

### PDF Generation
- **Can't generate PDF?** → See [PDF_GENERATION.md](PDF_GENERATION.md)
- **Multiple methods fail?** → Try browser method (no install needed)

---

## 🚀 Next Steps

### For Users
1. ✅ Read [README.md](README.md)
2. ✅ Build and import module
3. ✅ Run example: `.\examples\BeamAnalysis.ps1`
4. ✅ Generate PDF: `.\Generate-PDF.ps1`
5. → Create your own automation scripts

### For Developers
1. ✅ Read [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md)
2. ✅ Study source: [matlabcpp_c_bridge.c](matlabcpp_c_bridge.c) + [MatLabCppPowerShell.cs](MatLabCppPowerShell.cs)
3. ✅ Understand architecture (Section 5 of guide)
4. → Add new cmdlets or extend bridge
5. → Contribute improvements

### For Documentation Writers
1. ✅ Review [POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md)
2. ✅ Generate PDF: `.\Generate-PDF.ps1`
3. ✅ Read [PDF_GENERATION.md](PDF_GENERATION.md) for methods
4. → Customize branding/styling
5. → Distribute to stakeholders

---

## 📅 Document Versions

| Document | Version | Last Updated | Status |
|----------|---------|--------------|--------|
| INDEX.md | 1.0 | Jan 2026 | ✅ Current |
| README.md | 1.0 | Jan 2026 | ✅ Current |
| POWERSHELL_GUIDE.md | 1.0 | Jan 2026 | ✅ Current |
| POWERSHELL_SUMMARY.md | 1.0 | Jan 2026 | ✅ Current |
| PDF_GENERATION.md | 1.0 | Jan 2026 | ✅ Current |
| PACKAGE_COMPLETE.md | 1.0 | Jan 2026 | ✅ Current |

---

**Navigation Hub Version:** 1.0  
**MatLabC++ PowerShell Bridge:** v0.3.0  
**Last Updated:** January 2026  
**Maintainer:** MatLabC++ Documentation Team

---

**End of Index**

For questions or suggestions, please refer to the appropriate document above or consult [PACKAGE_COMPLETE.md](PACKAGE_COMPLETE.md) for comprehensive package information.
