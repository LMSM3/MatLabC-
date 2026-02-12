# Fix line endings in build_native.sh
$content = Get-Content "build_native.sh" -Raw
$content = $content -replace "`r`n", "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD/build_native.sh", $content, $utf8NoBom)
Write-Host "✓ Fixed line endings in build_native.sh"
