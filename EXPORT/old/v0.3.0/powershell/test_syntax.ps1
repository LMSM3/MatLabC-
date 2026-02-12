# Test Install.ps1 syntax
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    (Resolve-Path ".\Install.ps1"),
    [ref]$null,
    [ref]$errors
)

if ($errors) {
    Write-Host "Syntax Errors Found:" -ForegroundColor Red
    $errors | ForEach-Object {
        Write-Host "Line $($_.Extent.StartLineNumber): $($_.Message)" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "✓ No syntax errors found in Install.ps1" -ForegroundColor Green
    exit 0
}
