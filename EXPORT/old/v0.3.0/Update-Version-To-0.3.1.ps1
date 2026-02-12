# Update-Version-To-0.3.1.ps1
# Bumps all version references from v0.3.0 to v0.3.1
# Run this before building the installer

[CmdletBinding()]
param(
    [switch]$DryRun  # Show what would change without making changes
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  MatLabC++ Version Update: v0.3.0 → v0.3.1                   " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN MODE] - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

$files = @(
    @{
        Path = "v0.3.0\CMakeLists.txt"
        Find = "project(MatLabCPP VERSION 0.3.0 LANGUAGES CXX)"
        Replace = "project(MatLabCPP VERSION 0.3.1 LANGUAGES CXX)"
        Description = "CMake version"
    },
    @{
        Path = "v0.3.0\README.md"
        Find = "MatLabC++ v0.3.0"
        Replace = "MatLabC++ v0.3.1"
        Description = "Main README"
    },
    @{
        Path = "v0.3.0\powershell\README.md"
        Find = "**MatLabC++ PowerShell Bridge v0.3.0**"
        Replace = "**MatLabC++ PowerShell Bridge v0.3.1**"
        Description = "PowerShell README"
    },
    @{
        Path = "v0.3.0\COMMAND_LINE_INTEGRATION_SUMMARY.md"
        Find = "**Version:** MatLabC++ v0.3.0"
        Replace = "**Version:** MatLabC++ v0.3.1"
        Description = "CLI integration summary"
    },
    @{
        Path = "v0.3.0\scripts\Test-CommandWrappers.ps1"
        Find = "MatLabC++ Command Wrapper Test Suite v0.3.0"
        Replace = "MatLabC++ Command Wrapper Test Suite v0.3.1"
        Description = "Test suite version"
    }
)

$updateCount = 0
$failCount = 0

foreach ($file in $files) {
    Write-Host "[$($updateCount + $failCount + 1)/$($files.Count)] Checking: $($file.Description)" -ForegroundColor Yellow
    Write-Host "  File: $($file.Path)" -ForegroundColor Gray
    
    if (-not (Test-Path $file.Path)) {
        Write-Host "  ❌ NOT FOUND" -ForegroundColor Red
        $failCount++
        continue
    }
    
    $content = Get-Content $file.Path -Raw
    
    if ($content -match [regex]::Escape($file.Find)) {
        if ($DryRun) {
            Write-Host "  ✓ Would update (DRY RUN)" -ForegroundColor Cyan
        } else {
            $newContent = $content -replace [regex]::Escape($file.Find), $file.Replace
            Set-Content -Path $file.Path -Value $newContent -NoNewline
            Write-Host "  ✅ Updated" -ForegroundColor Green
        }
        $updateCount++
    } else {
        Write-Host "  ℹ️  Already at v0.3.1 or different format" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor $(if ($DryRun) { "Cyan" } else { "Green" })
if ($DryRun) {
    Write-Host "  [DRY RUN] Would update: $updateCount file(s)" -ForegroundColor Cyan
    Write-Host "  Run without -DryRun to apply changes" -ForegroundColor Cyan
} else {
    Write-Host "  Version update complete! Updated: $updateCount file(s)" -ForegroundColor Green
}
Write-Host "================================================================" -ForegroundColor $(if ($DryRun) { "Cyan" } else { "Green" })
Write-Host ""

if (-not $DryRun) {
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Build Release executable:" -ForegroundColor White
    Write-Host "     cd v0.3.0" -ForegroundColor Gray
    Write-Host "     cmake -B build -G 'Visual Studio 17 2022' -A x64" -ForegroundColor Gray
    Write-Host "     cmake --build build --config Release" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Compile installer:" -ForegroundColor White
    Write-Host "     C:\Program Files (x86)\Inno Setup 6\ISCC.exe v0.3.0\installers\MatLabCpp_Setup_v0.3.1.iss" -ForegroundColor Gray
    Write-Host ""
}
