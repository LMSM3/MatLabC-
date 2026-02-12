<#
.SYNOPSIS
    Automatically sets up MatLabC++ for global access (Windows PATH integration)

.DESCRIPTION
    Adds MatLabC++ executable to system PATH so it's accessible from any directory

.EXAMPLE
    .\Setup-Global-Integration.ps1
#>

param()

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  MatLabC++ Global Integration Setup" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Determine build path
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildPath = Join-Path (Split-Path -Parent $scriptDir) "build" "Release"

Write-Host "Build Path: $buildPath" -ForegroundColor Yellow
Write-Host ""

# Validate build exists
if (-not (Test-Path $buildPath -PathType Container)) {
    Write-Host "ERROR: Build path not found: $buildPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Did you build the Release executable?" -ForegroundColor Yellow
    Write-Host "Run these commands:" -ForegroundColor Gray
    Write-Host "  cd C:\Users\Liam\Desktop\MatLabC++" -ForegroundColor Gray
    Write-Host "  mkdir build" -ForegroundColor Gray
    Write-Host "  cd build" -ForegroundColor Gray
    Write-Host "  cmake -DCMAKE_BUILD_TYPE=Release .." -ForegroundColor Gray
    Write-Host "  cmake --build . --config Release" -ForegroundColor Gray
    exit 1
}

# Check for executable
$exe = Get-ChildItem $buildPath -Filter "matlabcpp.exe" -ErrorAction SilentlyContinue
if (-not $exe) {
    Write-Host "ERROR: matlabcpp.exe not found in: $buildPath" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Build directory validated" -ForegroundColor Green
Write-Host "[OK] matlabcpp.exe found ($([math]::Round($exe.Length / 1MB, 2)) MB)" -ForegroundColor Green
Write-Host ""

# Get current PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if already in PATH
if ($currentPath -like "*$buildPath*") {
    Write-Host "INFO: Build path already in PATH" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[OK] PATH already configured" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Adding to PATH..." -ForegroundColor Yellow
    
    # Add to PATH
    $newPath = if ($currentPath.EndsWith(";")) {
        "$currentPath$buildPath"
    } else {
        "$currentPath;$buildPath"
    }
    
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    
    Write-Host "[OK] PATH updated" -ForegroundColor Green
    Write-Host ""
}

# Verify
$verifyPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($verifyPath -like "*$buildPath*") {
    Write-Host "[OK] PATH verification: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "[FAIL] PATH verification failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Integration Complete" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Close this PowerShell window" -ForegroundColor White
Write-Host "  2. Open a NEW Admin PowerShell window" -ForegroundColor White
Write-Host "  3. Test: mlcpp --version" -ForegroundColor White
Write-Host ""