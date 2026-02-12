# Verify syntax of all setup scripts
$scripts = @(
    "Setup-Icons.ps1",
    "Setup-Icons-Auto.ps1", 
    "Setup-Icons-Orchestrator.ps1"
)

Write-Host "`nValidating PowerShell scripts..." -ForegroundColor Cyan
Write-Host ""

$allValid = $true
foreach ($scriptName in $scripts) {
    $path = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) $scriptName
    
    if (-not (Test-Path $path)) {
        Write-Host "  [FAIL] $scriptName - NOT FOUND" -ForegroundColor Red
        $allValid = $false
        continue
    }
    
    try {
        $content = Get-Content $path -Raw
        [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null) | Out-Null
        Write-Host "  [OK] $scriptName - Syntax OK" -ForegroundColor Green
    }
    catch {
        Write-Host "  [FAIL] $scriptName - Syntax Error: $_" -ForegroundColor Red
        $allValid = $false
    }
}

Write-Host ""
if ($allValid) {
    Write-Host "All scripts valid!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "Some scripts have errors!" -ForegroundColor Red
    exit 1
}
