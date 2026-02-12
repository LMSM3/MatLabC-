# MatLabC++ PowerShell - Self-Packaging Script
# Creates distributable packages with self-extraction capability

param(
    [ValidateSet('Portable', 'Installer', 'SelfExtract', 'All')]
    [string]$PackageType = 'All',
    
    [string]$OutputDir = ".\packages",
    
    [switch]$IncludeSource,
    
    [string]$Version = "1.0.0"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param($Message)
    Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Write-Success {
    param($Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Ensure-BuildExists {
    Write-Step "Verifying Build"
    
    if (-not (Test-Path "bin\Release\net6.0\MatLabCppPowerShell.dll")) {
        Write-Host "Build not found. Building now..."
        & .\build_native.ps1
        dotnet build -c Release
    }
    
    if (-not (Test-Path "matlabcpp_c_bridge.dll")) {
        throw "Native library not found. Run build_native.ps1 first."
    }
    
    Write-Success "Build verified"
}

function Create-PortablePackage {
    Write-Step "Creating Portable Package"
    
    $portableDir = "$OutputDir\MatLabCppPowerShell-Portable-$Version"
    
    if (Test-Path $portableDir) {
        Remove-Item $portableDir -Recurse -Force
    }
    
    New-Item -ItemType Directory -Path $portableDir -Force | Out-Null
    
    # Copy binaries
    Copy-Item "bin\Release\net6.0\*" "$portableDir\" -Recurse
    Copy-Item "matlabcpp_c_bridge.dll" "$portableDir\"
    
    # Copy documentation
    Copy-Item "POWERSHELL_GUIDE.md" "$portableDir\"
    Copy-Item "README.md" "$portableDir\"
    Copy-Item "CROSS_PLATFORM_GUIDE.md" "$portableDir\"
    
    # Copy examples
    if (Test-Path "examples") {
        Copy-Item "examples" "$portableDir\examples" -Recurse
    }
    
    # Create usage instructions
    $readme = @"
# MatLabC++ PowerShell - Portable Edition

## Quick Start

### Windows
``````powershell
Import-Module .\MatLabCppPowerShell.dll
Get-Material aluminum_6061
``````

### Linux/macOS (with PowerShell Core)
``````bash
pwsh -Command "Import-Module ./MatLabCppPowerShell.dll"
``````

## Available Cmdlets

- Get-Material - Retrieve material properties
- Find-Material - Search materials by density
- Get-Constant - Get physical constants
- Invoke-ODEIntegration - Physics simulations
- Invoke-MatrixMultiply - Matrix operations

## Documentation

See POWERSHELL_GUIDE.md for complete documentation.

## System Requirements

- .NET 6.0 Runtime
- PowerShell 5.1+ or PowerShell Core 6+
- Windows, Linux, or macOS

## Installation

No installation needed! Just import the module:

``````powershell
Import-Module .\MatLabCppPowerShell.dll
``````

To auto-load on startup, add to your PowerShell profile:

``````powershell
# Find your profile location
`$PROFILE

# Add this line
Import-Module "C:\path\to\MatLabCppPowerShell.dll"
``````

Version: $Version
"@
    
    $readme | Out-File "$portableDir\README.txt" -Encoding UTF8
    
    # Create ZIP
    $zipPath = "$OutputDir\MatLabCppPowerShell-Portable-$Version.zip"
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    Compress-Archive -Path "$portableDir\*" -DestinationPath $zipPath -CompressionLevel Optimal
    
    Write-Success "Portable package created: $zipPath"
    return $zipPath
}

function Create-SelfExtractingPackage {
    Write-Step "Creating Self-Extracting Package"
    
    $sfxDir = "$OutputDir\SelfExtract"
    New-Item -ItemType Directory -Path $sfxDir -Force | Out-Null
    
    # Create the self-extracting installer script
    $installerScript = @'
# MatLabC++ PowerShell - Self-Extracting Installer
# This script will automatically extract and install the module

param([switch]$Unattended)

$ErrorActionPreference = "Stop"

Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MatLabC++ PowerShell - Self-Extracting Installer ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Embedded ZIP data starts after __DATA__ marker

# Find the data marker
$scriptContent = Get-Content $PSCommandPath -Raw
$dataMarker = "__DATA__"
$markerPos = $scriptContent.IndexOf($dataMarker)

if ($markerPos -lt 0) {
    Write-Error "Invalid installer: data marker not found"
    exit 1
}

# Extract base64 data
$base64Data = $scriptContent.Substring($markerPos + $dataMarker.Length).Trim()

# Decode and extract
Write-Host "Extracting files..." -ForegroundColor Yellow

$tempZip = [System.IO.Path]::GetTempFileName() + ".zip"
try {
    [System.IO.File]::WriteAllBytes($tempZip, [System.Convert]::FromBase64String($base64Data))
    
    $extractPath = "$env:TEMP\MatLabCppPowerShell_Install"
    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force
    }
    
    Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force
    
    Write-Host "✓ Files extracted" -ForegroundColor Green
    
    # Run installation
    Push-Location $extractPath
    
    if (Test-Path "Install.ps1") {
        Write-Host "Running installer..." -ForegroundColor Yellow
        & .\Install.ps1 -Unattended:$Unattended
    } else {
        # Manual install
        $modulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\MatLabCppPowerShell"
        New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
        Copy-Item * $modulePath -Recurse -Force
        Write-Host "✓ Module installed to: $modulePath" -ForegroundColor Green
    }
    
    Pop-Location
    
    Write-Host ""
    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Host "Try: Get-Material aluminum_6061" -ForegroundColor Cyan
    
} finally {
    if (Test-Path $tempZip) {
        Remove-Item $tempZip -Force
    }
}

exit 0

__DATA__
'@
    
    # Create temp package with installer
    $tempPackageDir = "$env:TEMP\MatLabCppPowerShell_Package"
    if (Test-Path $tempPackageDir) {
        Remove-Item $tempPackageDir -Recurse -Force
    }
    
    New-Item -ItemType Directory -Path $tempPackageDir -Force | Out-Null
    
    # Copy all files
    Copy-Item "bin\Release\net6.0\*" "$tempPackageDir\" -Recurse
    Copy-Item "matlabcpp_c_bridge.dll" "$tempPackageDir\"
    Copy-Item "Install.ps1" "$tempPackageDir\" -ErrorAction SilentlyContinue
    Copy-Item "*.md" "$tempPackageDir\" -ErrorAction SilentlyContinue
    
    # Create ZIP
    $tempZipPath = "$env:TEMP\MatLabCppPowerShell_Data.zip"
    Compress-Archive -Path "$tempPackageDir\*" -DestinationPath $tempZipPath -Force
    
    # Convert to Base64
    Write-Host "Encoding package..."
    $bytes = [System.IO.File]::ReadAllBytes($tempZipPath)
    $base64 = [System.Convert]::ToBase64String($bytes)
    
    # Create final self-extracting script
    $finalScript = $installerScript + "`n" + $base64
    $sfxPath = "$OutputDir\MatLabCppPowerShell-Installer-$Version.ps1"
    
    $finalScript | Out-File $sfxPath -Encoding UTF8
    
    # Cleanup
    Remove-Item $tempZipPath -Force
    Remove-Item $tempPackageDir -Recurse -Force
    
    Write-Success "Self-extracting package created: $sfxPath"
    Write-Host "  Usage: .\$(Split-Path $sfxPath -Leaf)" -ForegroundColor Gray
    
    return $sfxPath
}

function Create-ChocoPackage {
    Write-Step "Creating Chocolatey Package"
    
    $chocoDir = "$OutputDir\choco"
    New-Item -ItemType Directory -Path $chocoDir -Force | Out-Null
    
    # Create nuspec
    $nuspec = @"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>matlabcpp-powershell</id>
    <version>$Version</version>
    <title>MatLabC++ PowerShell Module</title>
    <authors>MatLabC++ Team</authors>
    <projectUrl>https://github.com/your-repo/matlabcpp</projectUrl>
    <description>High-performance numerical computing cmdlets for PowerShell</description>
    <tags>powershell matlab numerical computing engineering</tags>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <dependencies>
      <dependency id="dotnet-6.0-runtime" />
    </dependencies>
  </metadata>
  <files>
    <file src="tools\**" target="tools" />
  </files>
</package>
"@
    
    $nuspec | Out-File "$chocoDir\matlabcpp-powershell.nuspec" -Encoding UTF8
    
    # Create install script
    $toolsDir = "$chocoDir\tools"
    New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
    
    $installScript = @"
`$ErrorActionPreference = 'Stop'

`$modulePath = "`$env:ProgramData\PowerShell\Modules\MatLabCppPowerShell"

Write-Host "Installing MatLabC++ PowerShell Module..."

New-Item -ItemType Directory -Path `$modulePath -Force | Out-Null

Copy-Item "`$PSScriptRoot\*" `$modulePath -Recurse -Force -Exclude @('*.nuspec', 'chocolateyInstall.ps1', 'chocolateyUninstall.ps1')

Write-Host "Module installed to: `$modulePath" -ForegroundColor Green
Write-Host "Import with: Import-Module MatLabCppPowerShell" -ForegroundColor Cyan
"@
    
    $installScript | Out-File "$toolsDir\chocolateyInstall.ps1" -Encoding UTF8
    
    # Copy binaries to tools
    Copy-Item "bin\Release\net6.0\*" "$toolsDir\" -Recurse
    Copy-Item "matlabcpp_c_bridge.dll" "$toolsDir\"
    
    Write-Success "Chocolatey package prepared: $chocoDir"
    Write-Host "  To publish: choco pack $chocoDir\matlabcpp-powershell.nuspec" -ForegroundColor Gray
}

function Create-NuGetPackage {
    Write-Step "Creating NuGet Package"
    
    # For PowerShell Gallery
    $nugetDir = "$OutputDir\nuget"
    New-Item -ItemType Directory -Path $nugetDir -Force | Out-Null
    
    # Create module manifest
    $manifest = @"
@{
    RootModule = 'MatLabCppPowerShell.dll'
    ModuleVersion = '$Version'
    GUID = 'a1b2c3d4-e5f6-4a5b-9c8d-1a2b3c4d5e6f'
    Author = 'MatLabC++ Team'
    CompanyName = 'MatLabC++'
    Copyright = '(c) 2024 MatLabC++. All rights reserved.'
    Description = 'High-performance numerical computing cmdlets for PowerShell. Provides material properties, physics simulations, and matrix operations.'
    PowerShellVersion = '5.1'
    DotNetFrameworkVersion = '6.0'
    CmdletsToExport = @('Get-Material', 'Find-Material', 'Get-Constant', 'Invoke-ODEIntegration', 'Invoke-MatrixMultiply')
    AliasesToExport = @('matmul')
    PrivateData = @{
        PSData = @{
            Tags = @('Numerical', 'Computing', 'Engineering', 'Materials', 'Physics', 'Mathematics')
            LicenseUri = 'https://github.com/your-repo/matlabcpp/blob/main/LICENSE'
            ProjectUri = 'https://github.com/your-repo/matlabcpp'
            ReleaseNotes = 'Initial release of MatLabC++ PowerShell module'
        }
    }
}
"@
    
    $manifest | Out-File "$nugetDir\MatLabCppPowerShell.psd1" -Encoding UTF8
    
    # Copy module files
    Copy-Item "bin\Release\net6.0\*" "$nugetDir\" -Recurse
    Copy-Item "matlabcpp_c_bridge.dll" "$nugetDir\"
    
    Write-Success "NuGet package prepared: $nugetDir"
    Write-Host "  To publish: Publish-Module -Path $nugetDir -NuGetApiKey <key>" -ForegroundColor Gray
}

function Create-AllPackages {
    Create-PortablePackage
    Create-SelfExtractingPackage
    Create-ChocoPackage
    Create-NuGetPackage
}

# ============================================================================
# MAIN PACKAGING SCRIPT
# ============================================================================

Write-Host "`n"
Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MatLabC++ PowerShell - Package Builder          ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "`n"

try {
    # Create output directory
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    # Verify build exists
    Ensure-BuildExists
    
    # Create packages based on type
    switch ($PackageType) {
        'Portable' { Create-PortablePackage }
        'Installer' { Create-SelfExtractingPackage }
        'SelfExtract' { Create-SelfExtractingPackage }
        'All' { Create-AllPackages }
    }
    
    Write-Host "`n"
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  Packaging Complete!                              ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host "`n"
    
    Write-Host "Packages created in: $OutputDir" -ForegroundColor Cyan
    Get-ChildItem $OutputDir -Recurse -File | Select-Object Name, Length, LastWriteTime | Format-Table
    
} catch {
    Write-Host "`n"
    Write-Host "✗ Packaging failed: $_" -ForegroundColor Red
    exit 1
}
