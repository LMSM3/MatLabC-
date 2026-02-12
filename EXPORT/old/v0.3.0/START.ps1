<#
.SYNOPSIS
    Quick-start helper - Validates setup and shows next steps

.DESCRIPTION
    Runs basic validation and launches the icon setup orchestrator.
    Safe to run - non-destructive, mainly informational.

.NOTES
    Run this in Admin PowerShell to get started with v0.3.1 setup
#>

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MatLabC++ v0.3.1 Setup - Quick Start Helper                  ║" -ForegroundColor Cyan
Write-Host "║  Generated: 2025-01-24                                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "Step 1: Environment Validation" -ForegroundColor Yellow
Write-Host ""

# Check if admin
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "  ✓ Admin rights: YES" -ForegroundColor Green
} else {
    Write-Host "  ✗ Admin rights: NO (required for setup)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  ⚠ Please run this in an ADMIN PowerShell window:" -ForegroundColor Yellow
    Write-Host "    1. Press Windows key" -ForegroundColor Gray
    Write-Host "    2. Type 'powershell'" -ForegroundColor Gray
    Write-Host "    3. Right-click 'Windows PowerShell'" -ForegroundColor Gray
    Write-Host "    4. Click 'Run as Administrator'" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion.Major
Write-Host "  ✓ PowerShell version: $($PSVersionTable.PSVersion)" -ForegroundColor Green

# Check location
$scriptLocation = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$projectRoot = Split-Path -Parent $scriptLocation
Write-Host "  ✓ Script location: $scriptLocation" -ForegroundColor Green

# Check key files
Write-Host ""
Write-Host "Step 2: Checking Required Files" -ForegroundColor Yellow
Write-Host ""

$requiredFiles = @(
    "Setup-Icons-Orchestrator.ps1",
    "Setup-Icons-Auto.ps1",
    "Setup-Icons.ps1",
    "Verify-SetupScripts.ps1"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    $path = Join-Path $scriptLocation $file
    if (Test-Path $path) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file (MISSING)" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host ""
    Write-Host "  ⚠ Some required files are missing!" -ForegroundColor Red
    exit 1
}

# Check directories
Write-Host ""
Write-Host "Step 3: Checking Project Structure" -ForegroundColor Yellow
Write-Host ""

$directories = @(
    "assets",
    "scripts",
    "installers"
)

foreach ($dir in $directories) {
    $path = Join-Path $projectRoot $dir
    if (Test-Path $path -PathType Container) {
        $itemCount = @(Get-ChildItem $path -ErrorAction SilentlyContinue).Count
        Write-Host "  ✓ $dir\ ($itemCount items)" -ForegroundColor Green
    } else {
        Write-Host "  ℹ $dir\ (will be created if needed)" -ForegroundColor Cyan
    }
}

# Check cache
Write-Host ""
Write-Host "Step 4: Checking Execution State" -ForegroundColor Yellow
Write-Host ""

$cachePath = Join-Path $scriptLocation ".setup-icons-cache.json"
if (Test-Path $cachePath) {
    Write-Host "  ℹ Cache file found (previous execution)" -ForegroundColor Cyan
    $cache = Get-Content $cachePath | ConvertFrom-Json
    Write-Host "    Last run: $($cache.LastExecution.Timestamp)" -ForegroundColor Gray
    Write-Host "    Machine: $($cache.Environment.Hostname)" -ForegroundColor Gray
} else {
    Write-Host "  ℹ Cache file not found (first-time execution)" -ForegroundColor Cyan
}

# Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Status: READY TO RUN ✓                                       ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host ""
Write-Host "Next Step: Execute Icon Setup" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Run this command:" -ForegroundColor Cyan
Write-Host ""
Write-Host "    .\Setup-Icons-Orchestrator.ps1" -ForegroundColor White
Write-Host ""
Write-Host "  This will:" -ForegroundColor Gray
Write-Host "    • Detect if first-run or location changed" -ForegroundColor Gray
Write-Host "    • Auto-execute setup if needed" -ForegroundColor Gray
Write-Host "    • Copy and verify icon" -ForegroundColor Gray
Write-Host "    • Cache state for future runs" -ForegroundColor Gray
Write-Host "    • Show next steps for v0.3.1 build" -ForegroundColor Gray
Write-Host ""

Write-Host "Options:" -ForegroundColor Yellow
Write-Host "  Standard (recommended):" -ForegroundColor White
Write-Host "    .\Setup-Icons-Orchestrator.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  Check status only (no changes):" -ForegroundColor White
Write-Host "    .\Setup-Icons-Orchestrator.ps1 -Profile verify" -ForegroundColor Gray
Write-Host ""
Write-Host "  Preview (what would happen):" -ForegroundColor White
Write-Host "    .\Setup-Icons-Orchestrator.ps1 -Profile preview" -ForegroundColor Gray
Write-Host ""
Write-Host "  Force re-run:" -ForegroundColor White
Write-Host "    .\Setup-Icons-Orchestrator.ps1 -Profile force" -ForegroundColor Gray
Write-Host ""

Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  Quick Start:    .\RUNME_START_HERE.txt" -ForegroundColor Gray
Write-Host "  Full Guide:     .\RUNME_20250124.md" -ForegroundColor Gray
Write-Host "  Setup Info:     .\README_SETUP_ICONS.txt" -ForegroundColor Gray
Write-Host "  Complete Docs:  .\SETUP_ICONS_AUTOMATION_GUIDE.md" -ForegroundColor Gray
Write-Host ""

Write-Host "Ready? Press Enter to continue..." -ForegroundColor Cyan
Read-Host

Write-Host ""
Write-Host "Executing: Setup-Icons-Orchestrator.ps1" -ForegroundColor Yellow
Write-Host ""

# Run the orchestrator
& ".\Setup-Icons-Orchestrator.ps1"
