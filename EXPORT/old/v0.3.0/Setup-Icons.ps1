<#
.SYNOPSIS
    Prepares icon assets for MatLabC++ installer.

.DESCRIPTION
    Copies icon file from source to project assets directory, validates integrity,
    and generates configuration hints for Inno Setup installer script.
    Supports WhatIf preview mode and automatic overwrite with -Force.

.PARAMETER SourceIconPath
    Path to source icon file (.ico). Accepts absolute or relative paths.
    Default: Auto-detects from parent directory structure.

.PARAMETER ProjectRoot
    Project root directory. If not specified, derives from script location.
    Expected: Directory containing 'assets/', 'scripts/', 'installers/' folders.

.PARAMETER Force
    Overwrite existing icon without prompting for confirmation.

.PARAMETER WhatIf
    Preview actions without executing them.

.PARAMETER Confirm
    Prompt for confirmation before each operation.

.EXAMPLE
    # Use default auto-detection
    .\Setup-Icons.ps1

.EXAMPLE
    # Specify custom source icon
    .\Setup-Icons.ps1 -SourceIconPath "C:\path\to\custom.ico"

.EXAMPLE
    # Preview without executing
    .\Setup-Icons.ps1 -WhatIf

.EXAMPLE
    # Force overwrite without prompting
    .\Setup-Icons.ps1 -Force

.NOTES
    Author: MatLabC++ Build System
    Version: 0.3.1
    Requires: PowerShell 5.0+
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(ValueFromPipeline)]
    [string]$SourceIconPath,
    
    [Parameter()]
    [string]$ProjectRoot,
    
    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# ============================================================================
# Configuration & Initialization
# ============================================================================

$script:Result = @{
    Success = $false
    SourceIcon = $null
    DestinationIcon = $null
    AssetsDir = $null
    InstallersDir = $null
    InnoSetupPath = $null
    Errors = @()
}

function Write-Header {
    Write-Host "`n" + ("=" * 68) -ForegroundColor Cyan
    Write-Host "  MatLabC++ v0.3.1 - Icon Setup" -ForegroundColor Cyan
    Write-Host ("=" * 68) -ForegroundColor Cyan
    Write-Host ""
}

function Write-StepHeader {
    param([string]$Message)
    Write-Host "STEP: $Message" -ForegroundColor Yellow
}

function Write-StepSuccess {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-StepFailure {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Write-StepInfo {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor Cyan
}

function Write-StepWarn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-DetailLine {
    param([string]$Label, [string]$Value)
    Write-Host "         $Label $Value" -ForegroundColor Gray
}

# ============================================================================
# Phase 1: Resolve and Validate Paths
# ============================================================================

Write-Header

Write-StepHeader "Resolving paths"

# Determine project root
if (-not $ProjectRoot) {
    if ($PSScriptRoot) {
        $ProjectRoot = Split-Path -Parent $PSScriptRoot
    } else {
        Write-StepFailure "Cannot determine project root (PSScriptRoot is empty)"
        $script:Result.Errors += "Failed to resolve ProjectRoot"
        exit 1
    }
}

# Validate project root exists
if (-not (Test-Path $ProjectRoot -PathType Container)) {
    Write-StepFailure "Project root not found: $ProjectRoot"
    $script:Result.Errors += "ProjectRoot does not exist: $ProjectRoot"
    exit 1
}

Write-StepSuccess "Project root: $ProjectRoot"
$script:Result.ProjectRoot = $ProjectRoot

# Construct asset paths
$assetsDir = Join-Path $ProjectRoot "assets"
$destIcon = Join-Path $assetsDir "icon.ico"
$installersDir = Join-Path $ProjectRoot "installers"

Write-StepInfo "Assets directory: $assetsDir"
Write-StepInfo "Destination icon: $destIcon"

# ============================================================================
# Phase 2: Determine Source Icon
# ============================================================================

Write-Host ""
Write-StepHeader "Locating source icon"

if (-not $SourceIconPath) {
    # Auto-detect: look for icon in common locations
    $searchPaths = @(
        (Join-Path $ProjectRoot "v0.3.0" "icon.ico"),
        (Join-Path $ProjectRoot "assets" "icon.ico"),
        (Join-Path $ProjectRoot "icon.ico"),
        (Join-Path $ProjectRoot ".." "icon.ico")
    )
    
    $SourceIconPath = $null
    foreach ($path in $searchPaths) {
        if (Test-Path $path -PathType Leaf) {
            $SourceIconPath = $path
            Write-StepSuccess "Auto-detected source: $SourceIconPath"
            break
        }
    }
    
    if (-not $SourceIconPath) {
        Write-StepWarn "Could not auto-detect source icon"
        Write-StepInfo "Searched: $($searchPaths -join ', ')"
        Write-Host ""
        Write-Host "Provide explicit path with: .\Setup-Icons.ps1 -SourceIconPath <path>" -ForegroundColor Cyan
        exit 1
    }
} else {
    # Resolve user-provided path (relative or absolute)
    $SourceIconPath = (Resolve-Path $SourceIconPath -ErrorAction SilentlyContinue).Path
    if (-not $SourceIconPath) {
        Write-StepFailure "Source icon path could not be resolved"
        exit 1
    }
}

# Validate source exists and is .ico
if (-not (Test-Path $SourceIconPath -PathType Leaf)) {
    Write-StepFailure "Source icon not found: $SourceIconPath"
    exit 1
}

if ($SourceIconPath -notmatch '\.ico$') {
    Write-StepWarn "File does not have .ico extension: $SourceIconPath"
}

$sourceFile = Get-Item $SourceIconPath
Write-StepSuccess "Source icon verified"
Write-DetailLine "Size:" "$($sourceFile.Length) bytes (~$([Math]::Round($sourceFile.Length/1024, 2)) KB)"
Write-DetailLine "Modified:" $sourceFile.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
$script:Result.SourceIcon = $SourceIconPath

# ============================================================================
# Phase 3: Create Asset Directories
# ============================================================================

Write-Host ""
Write-StepHeader "Creating asset directories"

foreach ($dir in @($assetsDir, $installersDir)) {
    if (Test-Path $dir -PathType Container) {
        Write-StepSuccess "Already exists: $dir"
    } else {
        if ($PSCmdlet.ShouldProcess($dir, "Create directory")) {
            $null = New-Item -ItemType Directory -Path $dir -Force -ErrorAction Stop
            Write-StepSuccess "Created: $dir"
        } else {
            Write-Host "  [SKIP] Would create: $dir" -ForegroundColor Cyan
        }
    }
}

$script:Result.AssetsDir = $assetsDir
$script:Result.InstallersDir = $installersDir

# ============================================================================
# Phase 4: Copy and Verify Icon
# ============================================================================

Write-Host ""
Write-StepHeader "Copying icon to assets"

$shouldCopy = $true
if ((Test-Path $destIcon) -and -not $Force) {
    Write-StepWarn "Destination already exists: $destIcon"
    $response = Read-Host "Overwrite? (y/n)"
    $shouldCopy = $response -match '^y$' -or $response -match '^yes$'
}

if ($shouldCopy) {
    if ($PSCmdlet.ShouldProcess($destIcon, "Copy icon file")) {
        Copy-Item $SourceIconPath $destIcon -Force -ErrorAction Stop
        Write-StepSuccess "Icon copied successfully"
        
        $destFile = Get-Item $destIcon
        Write-DetailLine "Size:" "$($destFile.Length) bytes"
        
        # Hash-based integrity verification
        Write-Host ""
        Write-StepHeader "Verifying integrity (SHA256)"
        
        $srcHash = (Get-FileHash $SourceIconPath -Algorithm SHA256).Hash
        $dstHash = (Get-FileHash $destIcon -Algorithm SHA256).Hash
        
        Write-DetailLine "Source hash:" $srcHash.Substring(0, 16) + "..."
        Write-DetailLine "Dest hash:  " $dstHash.Substring(0, 16) + "..."
        
        if ($srcHash -eq $dstHash) {
            Write-StepSuccess "Integrity check: PASS (hashes match)"
            $script:Result.DestinationIcon = $destIcon
            $script:Result.Success = $true
        } else {
            Write-StepFailure "Integrity check: FAIL (hash mismatch)"
            $script:Result.Errors += "Hash verification failed after copy"
            exit 1
        }
    } else {
        Write-Host "  [SKIP] Would copy icon to: $destIcon" -ForegroundColor Cyan
    }
} else {
    Write-Host "  [SKIP] Skipped (user cancelled)" -ForegroundColor Cyan
}

# ============================================================================
# Phase 5: Generate Configuration
# ============================================================================

Write-Host ""
Write-StepHeader "Generating Inno Setup configuration"

$relativeIconPath = "..\assets\icon.ico"
Write-StepSuccess "Relative path for Inno Setup: $relativeIconPath"
$script:Result.InnoSetupPath = $relativeIconPath

# ============================================================================
# Summary & Next Steps
# ============================================================================

Write-Host ""
Write-Host ("=" * 68) -ForegroundColor Green
Write-Host "  Icon Setup Complete" -ForegroundColor Green
Write-Host ("=" * 68) -ForegroundColor Green
Write-Host ""

if ($script:Result.Success) {
    Write-Host "FILES CREATED:" -ForegroundColor Cyan
    if ($script:Result.DestinationIcon) {
        Write-Host "  - $($script:Result.DestinationIcon)" -ForegroundColor White
    }
    Write-Host ""
    
    Write-Host "INNO SETUP CONFIGURATION:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [Setup]" -ForegroundColor Yellow
    Write-Host "    SetupIconFile=$relativeIconPath" -ForegroundColor Gray
    Write-Host "    UninstallDisplayIcon={app}\matlabcpp.exe" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [Files]" -ForegroundColor Yellow
    Write-Host "    Source: ""$relativeIconPath""; DestDir: ""{app}""; Flags: ignoreversion" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [Icons]" -ForegroundColor Yellow
    Write-Host "    Name: ""{group}\MatLabC++""; Filename: ""{app}\matlabcpp.exe""; IconFilename: ""{app}\icon.ico""" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "  1. Update CMakeLists.txt version to 0.3.1" -ForegroundColor White
    Write-Host "  2. Review: installers/MatLabCpp_Setup_v0.3.1.iss" -ForegroundColor White
    Write-Host "  3. Build Release executable" -ForegroundColor White
    Write-Host "  4. Compile installer with Inno Setup" -ForegroundColor White
    Write-Host "  5. Test on clean Windows VM" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "ERRORS ENCOUNTERED:" -ForegroundColor Red
    foreach ($error in $script:Result.Errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    exit 1
}

# Return result object for pipeline consumers
$script:Result
