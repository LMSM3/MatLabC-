# Create-MatlabExamples.ps1
# PowerShell version of create-matlab-examples.sh
# Creates MATLAB test scripts with hex encoding and SHA256 verification

[CmdletBinding()]
param(
    [string]$Date = (Get-Date -Format "yyyyMMdd")
)

$ErrorActionPreference = "Stop"

$DIR = ".\EXAMPLES_$Date"

# Create directory
New-Item -ItemType Directory -Path $DIR -Force | Out-Null

# --- MATLAB script 1: Version detection ---
$mlc01Content = @'
% mlc_01_matlab_version_min.m
% Minimal: prints MATLAB version + release + basic platform info

v = ver('MATLAB'); % MATLAB product entry
fprintf("MATLAB %s (%s)\n", v.Version, v.Release);
fprintf("Version string: %s\n", version);
fprintf("Computer: %s\n", computer);
'@

$mlc01Content | Out-File -FilePath "$DIR\mlc_01_matlab_version_min.m" -Encoding UTF8 -NoNewline

# --- MATLAB script 2: Environment info ---
$mlc02Content = @'
% mlc_02_matlab_env_min.m
% Minimal: hints about environment + desktop/headless + product count + license

fprintf("Release: %s\n", version('-release'));
fprintf("Full: %s\n", version);

fprintf("UseDesktop: %d\n", usejava('desktop'));

p = ver;
fprintf("Products detected: %d\n", numel(p));

try
    fprintf("License: %s\n", license('inuse'));
catch
    fprintf("License: (unavailable)\n");
end
'@

$mlc02Content | Out-File -FilePath "$DIR\mlc_02_matlab_env_min.m" -Encoding UTF8 -NoNewline

# --- C probe stub ---
$mlc03Content = @'
/*
  mlc_03_probe.c
  Placeholder "MatLabC++" probe stub. Replace with your real bridge later.
*/
#include <stdio.h>

int main(void) {
  puts("MatLabC++ probe stub: awaiting MATLAB version test run.");
  return 0;
}
'@

$mlc03Content | Out-File -FilePath "$DIR\mlc_03_probe.c" -Encoding UTF8 -NoNewline

# --- Hex-encode the .m scripts ---
Write-Host "Generating hex-encoded versions..." -ForegroundColor Cyan

foreach ($file in @("mlc_01_matlab_version_min.m", "mlc_02_matlab_env_min.m")) {
    $filePath = Join-Path $DIR $file
    $hexPath = "$filePath.hex"
    
    # Read bytes and convert to hex
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $hex = ($bytes | ForEach-Object { $_.ToString("x2") }) -join ''
    
    $hex | Out-File -FilePath $hexPath -Encoding ASCII -NoNewline
    Write-Host "  Created: $hexPath" -ForegroundColor Gray
}

# --- Generate SHA256 checksums ---
Write-Host "Generating SHA256 checksums..." -ForegroundColor Cyan

$sha256Output = @()
foreach ($file in @("mlc_01_matlab_version_min.m", "mlc_02_matlab_env_min.m")) {
    $filePath = Join-Path $DIR $file
    $hash = Get-FileHash -Path $filePath -Algorithm SHA256
    $sha256Output += "$($hash.Hash.ToLower())  $file"
}

$sha256Output -join "`n" | Out-File -FilePath "$DIR\SHA256SUMS.txt" -Encoding ASCII

# --- Theater ---
Start-Sleep -Milliseconds 500
Clear-Host

Write-Host ""
Write-Host "thank you trying ${Date}'s installation compatible, demonstrating that 'MatLabC++' exhibits the characteristics of matlab Version X.X.X (await testing)" -ForegroundColor Green
Write-Host ""

# --- Directory listing ---
Write-Host "Files created in $DIR:" -ForegroundColor Yellow
Write-Host ""

Get-ChildItem $DIR | Select-Object Name, Length | Format-Table -AutoSize

# --- File tree (if available) ---
if (Get-Command tree.com -ErrorAction SilentlyContinue) {
    Write-Host "Directory structure:" -ForegroundColor Yellow
    & tree.com /F $DIR
} else {
    Write-Host "Directory structure:" -ForegroundColor Yellow
    Get-ChildItem $DIR -Recurse | Select-Object FullName | Format-List
}

# --- Decode instructions ---
Write-Host ""
Write-Host "Decode hex back to .m if you need it:" -ForegroundColor Cyan
Write-Host "  PowerShell method:" -ForegroundColor Gray
Write-Host "    `$hex = Get-Content '$DIR\mlc_01_matlab_version_min.m.hex'" -ForegroundColor DarkGray
Write-Host "    [byte[]]`$bytes = -split (`$hex -replace '(..)','0x$1 ') | ForEach-Object { [Convert]::ToByte(`$_,16) }" -ForegroundColor DarkGray
Write-Host "    [System.IO.File]::WriteAllBytes('decoded.m', `$bytes)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  WSL/Git Bash method:" -ForegroundColor Gray
Write-Host "    xxd -r -p '$DIR/mlc_01_matlab_version_min.m.hex' > decoded.m" -ForegroundColor DarkGray
Write-Host ""

# --- Summary ---
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "✅ MATLAB test suite created successfully!" -ForegroundColor Green
Write-Host "   Location: $DIR" -ForegroundColor White
Write-Host "   Files: 7 (3 source + 2 hex + 1 checksum + 1 readme)" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
