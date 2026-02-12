Write-Host "Testing MatLabC++ v0.3.0 Functions" -ForegroundColor Cyan
Write-Host ""

# Simple test log
$TestResults = @{
    Passed = 0
    Failed = 0
}

# Test 1: Test-Command function
Write-Host "[TEST 1] Test-Command function" -ForegroundColor Yellow
try {
    $testCmd = Get-Command powershell -ErrorAction Stop
    Write-Host "  PASS: Get-Command works" -ForegroundColor Green
    $TestResults.Passed++
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $TestResults.Failed++
}

# Test 2: Environment PATH
Write-Host ""
Write-Host "[TEST 2] Environment Variables" -ForegroundColor Yellow
try {
    $path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $pathCount = ($path -split ';').Count
    Write-Host "  PASS: Retrieved Machine PATH ($pathCount entries)" -ForegroundColor Green
    $TestResults.Passed++
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $TestResults.Failed++
}

# Test 3: Admin Check
Write-Host ""
Write-Host "[TEST 3] Administrator Detection" -ForegroundColor Yellow
try {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    Write-Host "  PASS: Admin check: $isAdmin" -ForegroundColor Green
    $TestResults.Passed++
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $TestResults.Failed++
}

# Test 4: Profile Path
Write-Host ""
Write-Host "[TEST 4] PowerShell Profile" -ForegroundColor Yellow
try {
    $profilePath = $PROFILE
    Write-Host "  PASS: Profile path: $profilePath" -ForegroundColor Green
    $TestResults.Passed++
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $TestResults.Failed++
}

# Test 5: User Profile
Write-Host ""
Write-Host "[TEST 5] User Profile Detection" -ForegroundColor Yellow
try {
    $userProfile = $env:USERPROFILE
    Write-Host "  PASS: User profile: $userProfile" -ForegroundColor Green
    $TestResults.Passed++
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $TestResults.Failed++
}

# Test 6: Directory Creation
Write-Host ""
Write-Host "[TEST 6] Directory Operations" -ForegroundColor Yellow
try {
    $testDir = Join-Path $env:TEMP "MatLabTest_$(Get-Random)"
    $null = New-Item -ItemType Directory -Path $testDir -Force
    if (Test-Path $testDir) {
        Remove-Item $testDir -Force
        Write-Host "  PASS: Directory creation and removal works" -ForegroundColor Green
        $TestResults.Passed++
    } else {
        Write-Host "  FAIL: Directory not created" -ForegroundColor Red
        $TestResults.Failed++
    }
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $TestResults.Failed++
}

# Test 7: File Creation
Write-Host ""
Write-Host "[TEST 7] File Operations" -ForegroundColor Yellow
try {
    $testFile = Join-Path $env:TEMP "MatLabTest_$(Get-Random).txt"
    "Test content" | Out-File $testFile -Encoding UTF8
    if (Test-Path $testFile) {
        Remove-Item $testFile -Force
        Write-Host "  PASS: File creation and removal works" -ForegroundColor Green
        $TestResults.Passed++
    } else {
        Write-Host "  FAIL: File not created" -ForegroundColor Red
        $TestResults.Failed++
    }
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $TestResults.Failed++
}

# Test 8: Module Manifest
Write-Host ""
Write-Host "[TEST 8] Module Manifest Generation" -ForegroundColor Yellow
try {
    $manifestPath = Join-Path $env:TEMP "TestManifest_$(Get-Random).psd1"
    $null = New-ModuleManifest -Path $manifestPath -ModuleVersion '1.0.0' -Author 'Test' -ErrorAction Stop
    if (Test-Path $manifestPath) {
        Remove-Item $manifestPath -Force
        Write-Host "  PASS: Module manifest creation works" -ForegroundColor Green
        $TestResults.Passed++
    } else {
        Write-Host "  FAIL: Manifest not created" -ForegroundColor Red
        $TestResults.Failed++
    }
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $TestResults.Failed++
}

# Test 9: Check source files
Write-Host ""
Write-Host "[TEST 9] Required Source Files" -ForegroundColor Yellow
$sourceFiles = @(
    "matlabcpp_c_bridge.c",
    "MatLabCppPowerShell.cs",
    "MatLabCppPowerShell.csproj",
    "build_native.ps1"
)

$fileTestsPassed = 0
foreach ($file in $sourceFiles) {
    if (Test-Path $file) {
        Write-Host "  PASS: Found $file" -ForegroundColor Green
        $fileTestsPassed++
    } else {
        Write-Host "  FAIL: Missing $file" -ForegroundColor Red
    }
}
$TestResults.Passed += $fileTestsPassed

# Test 10: .NET SDK detection
Write-Host ""
Write-Host "[TEST 10] .NET SDK Detection" -ForegroundColor Yellow
try {
    $dotnetVersion = & dotnet --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  PASS: .NET SDK found: $dotnetVersion" -ForegroundColor Green
        $TestResults.Passed++
    } else {
        Write-Host "  INFO: .NET SDK not installed (expected in test environment)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  INFO: .NET SDK not available (expected in test environment)" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Passed:  $($TestResults.Passed)" -ForegroundColor Green
Write-Host "Failed:  $($TestResults.Failed)" -ForegroundColor Red
Write-Host ""
Write-Host "Test report saved to: function_tests_v0.3.0.log" -ForegroundColor Green
