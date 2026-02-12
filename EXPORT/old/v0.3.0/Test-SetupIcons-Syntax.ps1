# Quick syntax test for Setup-Icons.ps1
$scriptPath = "C:\Users\Liam\Desktop\MatLabC++\v0.3.0\Setup-Icons.ps1"
try {
    $content = Get-Content $scriptPath -Raw
    [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null) | Out-Null
    Write-Host "Setup-Icons.ps1 Syntax: [OK]" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "Setup-Icons.ps1 Syntax Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
