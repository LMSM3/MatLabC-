<#
.SYNOPSIS
    Master orchestrator for v0.3.1 installer icon setup automation.

.DESCRIPTION
    Coordinates all icon setup operations with intelligent automation.
    Runs Setup-Icons-Auto.ps1 for smart first-run/location detection.
    Validates results and provides actionable feedback.
    Safe to run repeatedly (idempotent).

.PARAMETER Profile
    Execution profile: 'auto' (default), 'force', 'preview', 'verify'

.EXAMPLE
    # Standard auto-detection and execution
    .\Setup-Icons-Orchestrator.ps1

.EXAMPLE
    # Force re-run despite cache
    .\Setup-Icons-Orchestrator.ps1 -Profile force

.EXAMPLE
    # Preview mode (no changes)
    .\Setup-Icons-Orchestrator.ps1 -Profile preview

.EXAMPLE
    # Check current status only
    .\Setup-Icons-Orchestrator.ps1 -Profile verify

.NOTES
    Author: MatLabC++ Build System
    Version: 0.3.1
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("auto", "force", "preview", "verify")]
    [string]$Profile = "auto",
    
    [Parameter()]
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"

# Setup paths
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$AutoScript = Join-Path $ScriptDir "Setup-Icons-Auto.ps1"
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host ""
Write-Host ("=" * 75) -ForegroundColor Cyan
Write-Host "  v0.3.1 Icon Setup Orchestrator - Profile: $Profile" -ForegroundColor Cyan
Write-Host ("=" * 75) -ForegroundColor Cyan
Write-Host ""

# Pre-flight checks
Write-Host "Pre-flight Checks:" -ForegroundColor Yellow
Write-Host ""

if (Test-Path $AutoScript -PathType Leaf) {
    Write-Host "  [OK] Setup-Icons-Auto.ps1 found" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Setup-Icons-Auto.ps1 not found" -ForegroundColor Red
    exit 1
}

if (Test-Path $ProjectRoot -PathType Container) {
    Write-Host "  [OK] Project root validated: $ProjectRoot" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Project root not found" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Current status
Write-Host "Current Status:" -ForegroundColor Yellow
Write-Host ""

$CacheFile = Join-Path $ScriptDir ".setup-icons-cache.json"
if (Test-Path $CacheFile) {
    Write-Host "  [INFO] Previous execution cached" -ForegroundColor Cyan
    try {
        $cache = Get-Content $CacheFile | ConvertFrom-Json
        Write-Host "    Last run: $($cache.LastExecution.Timestamp)" -ForegroundColor Gray
    } catch {
        Write-Host "    (cache corrupted)" -ForegroundColor Gray
    }
} else {
    Write-Host "  [INFO] No cache (first execution)" -ForegroundColor Cyan
}

$IconPath = Join-Path $ProjectRoot "assets" "icon.ico"
if (Test-Path $IconPath -PathType Leaf) {
    $item = Get-Item $IconPath
    Write-Host "  [OK] Icon asset found: $([Math]::Round($item.Length/1024, 2)) KB" -ForegroundColor Green
} else {
    Write-Host "  [INFO] Icon asset will be created" -ForegroundColor Cyan
}

Write-Host ""

# Execute based on profile
Write-Host "Execution ($Profile mode):" -ForegroundColor Yellow
Write-Host ""

$params = @{}
switch ($Profile) {
    "force"   { $params['Force'] = $true }
    "preview" { $params['WhatIf'] = $true }
    "verify"  { $params['NoCache'] = $true }
}

try {
    $result = & $AutoScript @params
    Write-Host ""
    Write-Host "  [OK] Icon setup completed" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "  [FAIL] Icon setup failed: $_" -ForegroundColor Red
    exit 1
}

# Summary
Write-Host ""
Write-Host ("=" * 75) -ForegroundColor Green
Write-Host "  Complete" -ForegroundColor Green
Write-Host ("=" * 75) -ForegroundColor Green
Write-Host ""

if (-not $SkipValidation) {
    if (Test-Path $IconPath) {
        Write-Host "  [OK] Icon asset verified" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Next Steps for v0.3.1:" -ForegroundColor Cyan
Write-Host "  1. Update CMakeLists.txt version to 0.3.1" -ForegroundColor White
Write-Host "  2. Build Release executable" -ForegroundColor White
Write-Host "  3. Review: installers/MatLabCpp_Setup_v0.3.1.iss" -ForegroundColor White
Write-Host "  4. Compile installer with Inno Setup" -ForegroundColor White
Write-Host "  5. Test on clean Windows VM" -ForegroundColor White
Write-Host ""
