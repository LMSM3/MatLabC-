# Build native C bridge library for PowerShell (Windows)

Write-Host "Building MatLabC++ C Bridge for PowerShell (Windows)..." -ForegroundColor Cyan
Write-Host ""

$DllName = "matlabcpp_c_bridge.dll"
$BuildSuccess = $false

# Check for MSVC
$VsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (Test-Path $VsWhere) {
    Write-Host "Checking for Visual Studio..." -ForegroundColor Yellow
    $VsPath = & $VsWhere -latest -property installationPath
    
    if ($VsPath) {
        $VcVarsPath = Join-Path $VsPath "VC\Auxiliary\Build\vcvars64.bat"
        
        if (Test-Path $VcVarsPath) {
            Write-Host "✓ Found Visual Studio at: $VsPath" -ForegroundColor Green
            Write-Host "Building with MSVC..." -ForegroundColor Yellow
            
            # Create a temporary batch file to set up environment and build
            $TempBat = [System.IO.Path]::GetTempFileName() + ".bat"
            
            # Write batch file content
            $batContent = "@echo off`r`n"
            $batContent += "call `"$VcVarsPath`" > nul`r`n"
            $batContent += "cl /LD /O2 /Fe:$DllName matlabcpp_c_bridge.c /I..\include`r`n"
            $batContent += "exit /b %ERRORLEVEL%`r`n"
            [System.IO.File]::WriteAllText($TempBat, $batContent)
            
            # Execute the batch file
            $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c","`"$TempBat`"" -Wait -NoNewWindow -PassThru -WorkingDirectory $PSScriptRoot
            Remove-Item $TempBat -ErrorAction SilentlyContinue
            
            if ($process.ExitCode -eq 0 -and (Test-Path $DllName)) {
                Write-Host "✓ Built: $DllName" -ForegroundColor Green
                $BuildSuccess = $true
            } else {
                Write-Warning "MSVC build failed, trying GCC..."
            }
        } else {
            Write-Warning "MSVC vcvars not found, trying GCC..."
        }
    } else {
        Write-Warning "Visual Studio not found, trying GCC..."
    }
} else {
    Write-Warning "vswhere.exe not found, trying GCC..."
}

# Try MinGW/GCC if MSVC failed
if (-not $BuildSuccess) {
    Write-Host ""
    Write-Host "Attempting build with GCC/MinGW..." -ForegroundColor Yellow
    
    # Check if gcc is available
    $gccVersion = $null
    try {
        $gccVersion = & gcc --version 2>&1 | Select-Object -First 1
        Write-Host "Found: $gccVersion" -ForegroundColor Green
    } catch {
        Write-Error "GCC not found! Please install one of:"
        Write-Host "  1. Visual Studio 2019+ (with C++ workload)" -ForegroundColor Cyan
        Write-Host "  2. MinGW-w64: https://www.mingw-w64.org/" -ForegroundColor Cyan
        Write-Host "  3. Chocolatey: choco install mingw" -ForegroundColor Cyan
        exit 1
    }
    
    # Build with GCC
    $output = & gcc -shared -O2 -o $DllName matlabcpp_c_bridge.c -I..\include -lm 2>&1
    
    if (Test-Path $DllName) {
        Write-Host "✓ Built with GCC: $DllName" -ForegroundColor Green
        $BuildSuccess = $true
    } else {
        Write-Error "Build failed!"
        Write-Host "Output: $output" -ForegroundColor Red
        exit 1
    }
}

# Show result
if ($BuildSuccess) {
    Write-Host ""
    $fileInfo = Get-Item $DllName
    Write-Host "✓ Native library built successfully!" -ForegroundColor Green
    Write-Host "  File: $($fileInfo.Name)" -ForegroundColor White
    Write-Host "  Size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor White
    
    # Copy to bin directories if they exist
    $copied = $false
    
    if (Test-Path "bin\Debug\net6.0") {
        Copy-Item $DllName "bin\Debug\net6.0\" -Force
        Write-Host "  ✓ Copied to bin\Debug\net6.0\" -ForegroundColor Green
        $copied = $true
    }
    
    if (Test-Path "bin\Release\net6.0") {
        Copy-Item $DllName "bin\Release\net6.0\" -Force
        Write-Host "  ✓ Copied to bin\Release\net6.0\" -ForegroundColor Green
        $copied = $true
    }
    
    if (-not $copied) {
        Write-Host "  Note: Run 'dotnet build' first to create bin directories" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Native bridge ready!" -ForegroundColor Green
} else {
    Write-Error "Build failed!"
    exit 1
}

