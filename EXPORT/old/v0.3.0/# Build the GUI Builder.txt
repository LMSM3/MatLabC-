# Build the GUI Builder
Write-Host "Building MatLabC++ Builder GUI..." -ForegroundColor Cyan

dotnet build BuilderGUI.csproj -c Release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! GUI Builder created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Run it with:" -ForegroundColor Yellow
    Write-Host "  .\bin\Release\net6.0-windows\MatLabCppBuilder.exe" -ForegroundColor White
    Write-Host ""
    Write-Host "Or double-click the .exe file in File Explorer!" -ForegroundColor Cyan
} else {
    Write-Host "Build failed - check output above" -ForegroundColor Red
    exit 1
}
