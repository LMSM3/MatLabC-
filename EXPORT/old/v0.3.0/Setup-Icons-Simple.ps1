# Setup-Icons-Simple.ps1
# Prepares icon assets for MatLabC++ v0.3.1 installer

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  MatLabC++ v0.3.1 - Icon Setup                                " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Paths
$sourceIcon = "C:\Users\Liam\Desktop\MatLabC++\v0.3.0\v0.3.0\icon.ico"
$assetsDir = "C:\Users\Liam\Desktop\MatLabC++\v0.3.0\assets"
$destIcon = Join-Path $assetsDir "icon.ico"

# Step 1: Verify source icon
Write-Host "[1/4] Verifying source icon..." -ForegroundColor Yellow
if (Test-Path $sourceIcon) {
    $sourceFile = Get-Item $sourceIcon
    Write-Host "  ✅ Found: $($sourceFile.Length) bytes" -ForegroundColor Green
} else {
    Write-Host "  ❌ NOT FOUND!" -ForegroundColor Red
    exit 1
}

# Step 2: Create assets directory
Write-Host "[2/4] Creating assets directory..." -ForegroundColor Yellow
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
    Write-Host "  ✅ Created" -ForegroundColor Green
} else {
    Write-Host "  ✅ Already exists" -ForegroundColor Green
}

# Step 3: Copy icon
Write-Host "[3/4] Copying icon..." -ForegroundColor Yellow
Copy-Item $sourceIcon $destIcon -Force
if (Test-Path $destIcon) {
    Write-Host "  ✅ Copied successfully" -ForegroundColor Green
} else {
    Write-Host "  ❌ Copy failed" -ForegroundColor Red
    exit 1
}

# Step 4: Summary
Write-Host "[4/4] Complete!" -ForegroundColor Yellow
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  ✅ Icon setup complete for v0.3.1!                            " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Icon location: $destIcon" -ForegroundColor Cyan
Write-Host "Use in Inno Setup: ..\assets\icon.ico" -ForegroundColor Cyan
Write-Host ""
