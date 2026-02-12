# MatLabC++ PowerShell Bridge v0.3.0

**Native PowerShell Cmdlets for High-Performance Numerical Computing**

Seamless integration with PowerShell via C# cmdlets and P/Invoke to native C functions.

---

## 📚 Documentation

- **[POWERSHELL_GUIDE.md](POWERSHELL_GUIDE.md)** - Comprehensive guide (800+ lines, PDF-ready)
- **[PDF_GENERATION.md](PDF_GENERATION.md)** - How to generate PDF documentation
- **[POWERSHELL_SUMMARY.md](POWERSHELL_SUMMARY.md)** - Quick reference summary
- **[examples/BeamAnalysis.ps1](examples/BeamAnalysis.ps1)** - 3D beam stress example

### Generate PDF Documentation

```powershell
.\Generate-PDF.ps1
```

Auto-detects available tools (pandoc/wkhtmltopdf/browser) and generates **MatLabCpp_PowerShell_Guide.pdf**.

---

## Quick Start

### Build

#### Windows
```powershell
cd v0.3.0/powershell

# Build native bridge
.\build_native.ps1

# Build C# module
dotnet build

# Import module
Import-Module .\bin\Debug\net6.0\MatLabCppPowerShell.dll
```

#### Linux/macOS
```bash
cd v0.3.0/powershell

# Build native bridge
chmod +x build_native.sh
./build_native.sh

# Build C# module
dotnet build

# Import module
pwsh -Command "Import-Module ./bin/Debug/net6.0/MatLabCppPowerShell.dll"
```

---

## Cmdlets

### Get-Material

Retrieve material properties by name.

```powershell
# Get aluminum properties
Get-Material aluminum_6061

# Output:
# Material: Aluminum 6061-T6
#   Density:              2700 kg/m³
#   Young's Modulus:      69.0 GPa
#   Yield Strength:       276.0 MPa
#   Thermal Conductivity: 167.0 W/(m·K)
#   Specific Heat:        896 J/(kg·K)
#   Melting Point:        582°C
```

**Parameters:**
- `Name` (string, required) - Material name (aluminum_6061, steel, peek, pla)

**Examples:**
```powershell
# Get multiple materials
'aluminum_6061', 'steel', 'peek' | Get-Material

# Format as table
Get-Material steel | Format-Table

# Select specific properties
Get-Material peek | Select-Object Name, Density, YoungsModulus

# Export to CSV
Get-Material aluminum_6061 | Export-Csv materials.csv
```

---

### Find-Material

Identify material by density with tolerance.

```powershell
# Find material with density ~2700 kg/m³
Find-Material 2700

# With custom tolerance
Find-Material 2700 -Tolerance 50

# Output: Aluminum 6061-T6 (density 2700 kg/m³)
```

**Parameters:**
- `Density` (double, required) - Density in kg/m³
- `Tolerance` (double, optional) - Tolerance ± kg/m³ (default 100)

**Examples:**
```powershell
# Find by exact density
Find-Material 1240  # PLA

# Tight tolerance
Find-Material 7850 -Tolerance 10  # Steel

# Wide search
Find-Material 1300 -Tolerance 200  # May match PEEK or PLA
```

---

### Get-Constant

Retrieve physical constants.

```powershell
# Standard gravity
Get-Constant g
# Output: 9.80665

# Speed of light
Get-Constant c
# Output: 299792458

# Pi
Get-Constant pi
# Output: 3.14159265358979
```

**Parameters:**
- `Name` (string, required) - Constant name

**Available Constants:**
- `g` - Standard gravity (9.80665 m/s²)
- `G` - Gravitational constant (6.67430e-11 m³/(kg·s²))
- `c` - Speed of light (299792458 m/s)
- `h` - Planck constant (6.62607015e-34 J·s)
- `k_B` - Boltzmann constant (1.380649e-23 J/K)
- `N_A` - Avogadro constant (6.02214076e23 mol⁻¹)
- `R` - Gas constant (8.314462618 J/(mol·K))
- `pi` - Pi (3.14159...)
- `e` - Euler's number (2.71828...)

**Examples:**
```powershell
# Calculate with constants
$radius = 0.5
$circumference = 2 * (Get-Constant pi) * $radius

# Multiple constants
'g', 'c', 'h' | Get-Constant

# Use in expressions
$weight = 70 * (Get-Constant g)  # kg * m/s² = N
```

---

### Invoke-ODEIntegration

Simulate dropping object with drag.

```powershell
# Drop from 100 meters
$samples = Invoke-ODEIntegration -Height 100 -Mass 1.0

# View results
$samples | Select-Object -First 5

# Output:
# Time  PositionZ  VelocityZ
# 0.00  100.0      0.0
# 0.01  99.999     -0.098
# 0.02  99.996     -0.196
# ...
```

**Parameters:**
- `Height` (double, required) - Drop height in meters
- `Mass` (double, optional) - Mass in kg (default 1.0)
- `DragCoefficient` (double, optional) - Cd (default 0.47 for sphere)

**Examples:**
```powershell
# Simple drop
$drop = Invoke-ODEIntegration -Height 50

# Heavy object with less drag
$drop = Invoke-ODEIntegration -Height 100 -Mass 10 -DragCoefficient 0.2

# Find time to impact
$drop | Where-Object { $_.PositionZ -le 0 } | Select-Object -First 1

# Plot results
$drop | Select-Object Time, PositionZ | Export-Csv drop_data.csv
```

---

### Invoke-MatrixMultiply

Multiply two matrices.

```powershell
# Create matrices
$A = @(@(1,2), @(3,4))
$B = @(@(5,6), @(7,8))

# Multiply
$C = Invoke-MatrixMultiply $A $B

# Output:
# [[19, 22],
#  [43, 50]]
```

**Alias:** `matmul`

**Parameters:**
- `A` (double[][], required) - First matrix
- `B` (double[][], required) - Second matrix

**Examples:**
```powershell
# Identity matrix
$I = @(@(1,0), @(0,1))
$A = @(@(3,4), @(5,6))
Invoke-MatrixMultiply $I $A  # Returns A

# Using alias
$result = matmul $A $B

# Chain operations
$temp = matmul $A $B
$final = matmul $temp $C
```

---

## Integration Examples

### Material Selection Pipeline

```powershell
# Load materials from CSV
$requirements = Import-Csv requirements.csv

foreach ($req in $requirements) {
    $material = Get-Material $req.Name
    
    if ($material.Density -lt $req.MaxDensity -and 
        $material.YieldStrength -gt $req.MinStrength) {
        Write-Host "✓ $($material.Name) meets requirements" -ForegroundColor Green
        $material | Export-Csv -Append selected_materials.csv
    }
}
```

### Stress Analysis Automation

```powershell
# Analyze multiple materials
$materials = 'aluminum_6061', 'steel', 'peek'
$load = 1000  # N

foreach ($name in $materials) {
    $mat = Get-Material $name
    $stress = $load / 0.001  # 1 mm² area
    $safety_factor = $mat.YieldStrength / $stress
    
    [PSCustomObject]@{
        Material = $mat.Name
        SafetyFactor = [math]::Round($safety_factor, 2)
        Status = if ($safety_factor -gt 2) { "SAFE" } else { "UNSAFE" }
    }
}
```

### Drop Test Simulation

```powershell
# Test multiple heights
$heights = 10, 20, 50, 100, 200

$results = foreach ($h in $heights) {
    $drop = Invoke-ODEIntegration -Height $h
    $impact = $drop | Where-Object { $_.PositionZ -le 0 } | Select-Object -First 1
    
    [PSCustomObject]@{
        Height_m = $h
        Time_s = [math]::Round($impact.Time, 3)
        Velocity_ms = [math]::Round([math]::Abs($impact.VelocityZ), 2)
    }
}

$results | Format-Table
```

### Data Export for Visualization

```powershell
# Generate data for Python/Excel
$drop = Invoke-ODEIntegration -Height 100

# Export to CSV
$drop | Export-Csv drop_simulation.csv -NoTypeInformation

# Or JSON
$drop | ConvertTo-Json | Out-File drop_simulation.json

# Generate Python plot script
@"
import pandas as pd
import matplotlib.pyplot as plt

data = pd.read_csv('drop_simulation.csv')
plt.plot(data['Time'], data['PositionZ'])
plt.xlabel('Time (s)')
plt.ylabel('Height (m)')
plt.title('Drop Simulation')
plt.savefig('drop.png')
"@ | Out-File plot.py

python plot.py
```

---

## Architecture

### Layer 1: C Bridge (matlabcpp_c_bridge.c)
- Pure C99 library
- Exposes C-compatible API
- No C++ exceptions/RTTI
- Builds to shared library (.so/.dylib/.dll)

**Functions:**
```c
MaterialResult* get_material_by_name(const char* name);
double get_constant_by_name(const char* name);
IntegrationSample* integrate_simple_drop(...);
double* matrix_multiply(...);
```

### Layer 2: C# Wrapper (MatLabCppPowerShell.cs)
- P/Invoke declarations with [DllImport]
- Memory marshalling (IntPtr ↔ managed types)
- PowerShell Cmdlet attributes
- Parameter validation

**Classes:**
- `NativeBridge` - P/Invoke declarations
- `MaterialInfo` - Managed data structure
- `GetMaterialCmdlet` - PowerShell cmdlet
- `InvokeODEIntegrationCmdlet` - ODE solver cmdlet

### Layer 3: PowerShell
- Native cmdlet experience
- Pipeline integration
- Help system
- Tab completion

---

## Building

### Prerequisites

**All Platforms:**
- .NET 6 SDK or later
- C compiler (GCC, Clang, or MSVC)

**Windows:**
- Visual Studio 2019+ (recommended)
- Or MinGW-w64

**Linux:**
- GCC 9+ or Clang 10+
- `sudo apt install gcc`

**macOS:**
- Xcode Command Line Tools
- `xcode-select --install`

### Build Steps

```bash
# 1. Navigate to directory
cd v0.3.0/powershell

# 2. Build native bridge
./build_native.sh           # Linux/macOS
.\build_native.ps1          # Windows

# 3. Build C# module
dotnet build

# 4. (Optional) Build release
dotnet build -c Release
```

### Output Files

```
bin/Debug/net6.0/
├── MatLabCppPowerShell.dll         # C# assembly
├── MatLabCppPowerShell.pdb         # Debug symbols
├── MatLabCppPowerShell.xml         # XML documentation
├── libmatlabcpp_c_bridge.so        # Native library (Linux)
├── libmatlabcpp_c_bridge.dylib     # Native library (macOS)
└── matlabcpp_c_bridge.dll          # Native library (Windows)
```

---

## Usage

### Load Module

```powershell
# Import module
Import-Module .\bin\Debug\net6.0\MatLabCppPowerShell.dll

# Verify loaded
Get-Command -Module MatLabCppPowerShell

# Get help
Get-Help Get-Material -Full
```

### Persistent Load (Optional)

Add to PowerShell profile:

```powershell
# Find profile path
$PROFILE

# Edit profile
notepad $PROFILE

# Add line:
Import-Module "C:\path\to\MatLabCppPowerShell.dll"
```

---

## Troubleshooting

### "Unable to load DLL 'matlabcpp_c_bridge'"

**Cause:** Native library not found

**Solution:**
```powershell
# Ensure native library is in same directory as DLL
Copy-Item libmatlabcpp_c_bridge.so bin/Debug/net6.0/  # Linux
Copy-Item libmatlabcpp_c_bridge.dylib bin/Debug/net6.0/  # macOS
Copy-Item matlabcpp_c_bridge.dll bin/Debug/net6.0/  # Windows

# Or add to LD_LIBRARY_PATH (Linux) / DYLD_LIBRARY_PATH (macOS)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/bin/Debug/net6.0
```

### "DllNotFoundException" on Windows

**Cause:** MSVC runtime not installed

**Solution:**
1. Install [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)
2. Or build with static runtime: `cl /LD /MT ...`

### Build Errors

```powershell
# Clean and rebuild
dotnet clean
Remove-Item -Recurse bin, obj
./build_native.ps1
dotnet build
```

---

## Performance

### Benchmarks (Typical Laptop)

| Operation | Time | Throughput |
|-----------|------|------------|
| Get-Material | ~5 µs | 200k/s |
| Get-Constant | ~1 µs | 1M/s |
| Matrix Multiply (10x10) | ~50 µs | 20k/s |
| ODE Integration (100m drop) | ~500 µs | 2k/s |

**Notes:**
- P/Invoke overhead: ~10-50 ns per call
- Memory marshalling: ~100 ns per allocation
- Native computation: Same as C (µs-ms depending on problem)

### Optimization Tips

1. **Batch Operations** - Use pipeline for multiple items
2. **Minimize Marshalling** - Keep data in native format when possible
3. **Reuse Results** - Cache material lookups
4. **Parallel Processing** - Use `ForEach-Object -Parallel` for independent tasks

---

## Extending

### Add New Cmdlet

1. **Add C function** to `matlabcpp_c_bridge.c`:
```c
EXPORT double calculate_stress(double force, double area) {
    return force / area;
}
```

2. **Add P/Invoke declaration**:
```csharp
[DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
public static extern double calculate_stress(double force, double area);
```

3. **Create cmdlet**:
```csharp
[Cmdlet(VerbsLifecycle.Invoke, "StressCalculation")]
public class InvokeStressCalculationCmdlet : PSCmdlet {
    [Parameter(Mandatory = true)]
    public double Force { get; set; }
    
    [Parameter(Mandatory = true)]
    public double Area { get; set; }
    
    protected override void ProcessRecord() {
        double stress = NativeBridge.calculate_stress(Force, Area);
        WriteObject(stress);
    }
}
```

4. **Rebuild**:
```powershell
./build_native.ps1
dotnet build
```

---

## Command-Line Integration

### Quick Commands (Windows Installer)

The Windows installer provides **clean command-line integration** without environment variable complexity:

```cmd
# Primary command (always available after install)
mlcpp file.c file2.m

# Optional short alias (if you checked the box during install)
mlc file.c file2.m
```

### How It Works

**1. During Installation:**
- Installer adds `{app}` directory to PATH (System or User)
- Creates wrapper scripts: `mlcpp.cmd` (always) and `mlc.cmd` (optional)
- No environment variable teaching required—it just works

**2. After Installation:**
- Open a **new terminal** (cmd/PowerShell)
- Run `mlcpp` from anywhere
- If you enabled the short alias, `mlc` also works

### Command Naming

| Command | Status | Purpose | Collision Risk |
|---------|--------|---------|----------------|
| `mlcpp` | **Default** | Primary command, well-documented | Low (recommended) |
| `mlc` | **Optional** | Short alias, user opts in during install | Low-Medium |
| ~~`mc`~~ | Avoided | Too short, conflicts with Midnight Commander | High (WSL/Linux) |

**Why `mlcpp`?**
- Clear, unique, low collision risk
- Works in Windows, WSL, and Linux
- Matches project name naturally

**Why optional `mlc`?**
- Shorter for power users
- User explicitly enables it (checkbox in installer)
- Slightly higher collision risk, but acceptable

### Installer Implementation

**Checkbox Options:**
```
[✓] Add MatLabForC++ to PATH (recommended)
[ ] Install short command alias: mlc
```

**Files Installed:**
```
C:\Program Files\MatLabCpp\
├── matlabcpp.exe             # Main executable
├── mlcpp.cmd                 # Primary wrapper (always installed)
├── mlc.cmd                   # Short alias (optional)
└── mlcpp.ps1                 # PowerShell wrapper (optional)
```

**Wrapper Scripts:**

`mlcpp.cmd` (Primary):
```batch
@echo off
setlocal
"%~dp0matlabcpp.exe" %*
```

`mlc.cmd` (Alias - identical, just shorter name):
```batch
@echo off
setlocal
"%~dp0matlabcpp.exe" %*
```

### PATH Integration (Inno Setup)

The installer uses **safe, duplicate-checking PATH addition**:

```iss
[Tasks]
Name: "addtopath"; Description: "Add MatLabForC++ to PATH (recommended)"; GroupDescription: "Command line integration:"
Name: "alias_mlc"; Description: "Install short command alias: mlc"; GroupDescription: "Command line integration:"

[Files]
Source: "scripts\mlcpp.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "scripts\mlcpp.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "scripts\mlc.cmd";   DestDir: "{app}"; Flags: ignoreversion; Tasks: alias_mlc

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

**What This Does:**
1. Checks if `{app}` is already in PATH (prevents duplicates)
2. Only modifies PATH if user checked "Add to PATH"
3. Creates System PATH entry (accessible to all users)
4. Installs `mlc.cmd` only if user checked the alias option

### Usage Examples

**After Installation:**

```cmd
# Open NEW terminal (to pick up PATH changes)
cmd

# Run from anywhere
mlcpp --version
mlcpp --help
mlcpp analyze beam.c
mlcpp compile project.m

# With short alias (if enabled)
mlc --version
mlc analyze beam.c
```

**From WSL/Linux (if using WSL):**

```bash
# Commands work in WSL too (Windows PATH is inherited)
mlcpp.exe --version
mlc.exe analyze beam.c  # (if alias enabled)
```

**From PowerShell:**

```powershell
# Native PowerShell cmdlets (preferred)
Import-Module MatLabCppPowerShell
Get-Material aluminum_6061

# Or use command-line wrapper
mlcpp analyze beam.c
mlc --version  # (if alias enabled)
```

### Troubleshooting

#### "mlcpp is not recognized"

**Cause:** Terminal opened before PATH was updated

**Solution:**
```cmd
# Close and reopen terminal
# Or refresh environment in current session:
refreshenv  # (if using Chocolatey)

# Or manually:
set PATH=%PATH%;C:\Program Files\MatLabForC++
```

#### "mlc conflicts with Midnight Commander"

**Cause:** You installed the short alias, and Midnight Commander (`mc`) is also installed

**Solution:**
1. Use `mlcpp` instead (always available)
2. Or uninstall and reinstall without checking "short alias"
3. Or create your own custom alias:
   ```cmd
   doskey mlfc=mlcpp $*
   ```

#### "Commands work in cmd but not PowerShell"

**Cause:** PowerShell sometimes caches command paths

**Solution:**
```powershell
# Refresh PowerShell environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Or just restart PowerShell
```

#### "I want to use a different command name"

**Solution - Create your own alias:**

**cmd/batch:**
```cmd
# Add to a batch file in PATH or your profile
@echo off
doskey mlfc=mlcpp $*
doskey matlab=mlcpp $*
```

**PowerShell:**
```powershell
# Add to $PROFILE
Set-Alias mlfc mlcpp
Set-Alias matlab mlcpp
```

**Linux/macOS:**
```bash
# Add to ~/.bashrc or ~/.zshrc
alias mlfc='mlcpp'
alias matlab='mlcpp'
```

### Uninstallation

**What Gets Removed:**
- `{app}` directory and all files
- PATH entry (automatically cleaned)
- Registry entries

**What Stays:**
- User data and configurations (in `%APPDATA%`)
- Cached materials database

**Manual PATH Cleanup (if needed):**
```powershell
# Check current PATH
$env:Path -split ';'

# Remove specific entry
$path = [Environment]::GetEnvironmentVariable("Path", "Machine")
$path = ($path.Split(';') | Where-Object { $_ -ne "C:\Program Files\MatLabCpp" }) -join ';'
[Environment]::SetEnvironmentVariable("Path", $path, "Machine")
```

### Advanced: Custom Wrapper Scripts

**Create your own wrapper** with additional functionality:

`my_mlcpp.cmd`:
```batch
@echo off
setlocal

REM Set custom environment
set MLCPP_CONFIG=%USERPROFILE%\.mlcpp\config.json

REM Add timestamp to logs
echo [%date% %time%] Running mlcpp %* >> %TEMP%\mlcpp.log

REM Run actual command
"%~dp0matlabcpp.exe" %*

REM Check exit code
if errorlevel 1 (
    echo Error occurred! Check %TEMP%\mlcpp.log
    exit /b 1
)
```

**PowerShell wrapper** with progress indication:

`my_mlcpp.ps1`:
```powershell
param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Args
)

Write-Host "[OK] Running MatLabC++..." -ForegroundColor Green

$app = Join-Path $PSScriptRoot "matlabcpp.exe"
& $app @Args

if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Command failed with code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[OK] Complete" -ForegroundColor Green
```

---

## Contributing

Contributions welcome! Please ensure:
1. C code is C99-compatible
2. P/Invoke signatures match exactly
3. Memory is properly freed (no leaks)
4. Cmdlets follow PowerShell naming conventions
5. Documentation updated

---

## License

Same as MatLabC++ - open source.

---

## Support

- **Issues:** GitHub Issues
- **Documentation:** This file + XML help
- **Examples:** See Integration Examples section
- **Command-Line Help:** `mlcpp --help` or `mlcpp /?`

---

**MatLabC++ PowerShell Bridge v0.3.0**  
Making high-performance numerical computing feel native in PowerShell.

**Status:** Production Ready  
**Platforms:** Windows, Linux, macOS  
**PowerShell:** 5.1+, PowerShell Core 6+  
**Command-Line:** `mlcpp` (always), `mlc` (optional)
