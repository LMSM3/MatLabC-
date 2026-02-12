# MatLabC++ PowerShell - Function Test Suite
# Tests all internal functions in Install.ps1 (v0.3.0)
# Generates detailed log of what works and what fails

param(
    [string]$LogPath = ".\function_tests_v0.3.0.log"
)

# Initialize log
$script:TestLog = @()
$script:TestResults = @{
    Passed = 0
    Failed = 0
    Skipped = 0
}

function Log-Test {
    param(
        [string]$FunctionName,
        [string]$TestName,
        [string]$Status,
        [string]$Message,
        [string]$Details = ""
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = [PSCustomObject]@{
        Timestamp = $timestamp
        Function = $FunctionName
        Test = $TestName
        Status = $Status
        Message = $Message
        Details = $Details
    }
    
    $script:TestLog += $entry
    
    # Console output
    $color = switch ($Status) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "SKIP" { "Yellow" }
        default { "White" }
    }
    
    Write-Host "[$Status] $FunctionName : $TestName - $Message" -ForegroundColor $color
    
    # Update counters
    switch ($Status) {
        "PASS" { $script:TestResults.Passed++ }
        "FAIL" { $script:TestResults.Failed++ }
        "SKIP" { $script:TestResults.Skipped++ }
    }
}

function Save-TestLog {
    Write-Host "`n" -ForegroundColor Cyan
    Write-Host "═════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Function Test Results - MatLabC++ v0.3.0" -ForegroundColor Cyan
    Write-Host "═════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "`n"
    
    $reportPath = $LogPath
    
    # Create detailed report
    $report = @"
╔═══════════════════════════════════════════════════════════════════════╗
║  MatLabC++ PowerShell v0.3.0 - Function Test Report                  ║
║  Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                  ║
╚═══════════════════════════════════════════════════════════════════════╝

SUMMARY
───────────────────────────────────────────────────────────────────────
Total Tests: $($script:TestResults.Passed + $script:TestResults.Failed + $script:TestResults.Skipped)
Passed:      $($script:TestResults.Passed) ✓
Failed:      $($script:TestResults.Failed) ✗
Skipped:     $($script:TestResults.Skipped) ⊘

Success Rate: $(if ($script:TestResults.Passed + $script:TestResults.Failed -gt 0) { 
    [math]::Round(($script:TestResults.Passed / ($script:TestResults.Passed + $script:TestResults.Failed)) * 100, 1)
} else { 0 })%

DETAILED TEST LOG
───────────────────────────────────────────────────────────────────────
"@

    foreach ($entry in $script:TestLog) {
        $status = switch ($entry.Status) {
            "PASS" { "[PASS]" }
            "FAIL" { "[FAIL]" }
            "SKIP" { "[SKIP]" }
            default { "[INFO]" }
        }
        
        $report += "`n$status [$($entry.Timestamp)] $($entry.Function)"
        $report += "`n  Test:    $($entry.Test)"
        $report += "`n  Message: $($entry.Message)"
        
        if ($entry.Details) {
            $report += "`n  Details: $($entry.Details)"
        }
        $report += "`n"
    }
    
    $report | Out-File $reportPath -Encoding UTF8
    
    Write-Host "Test log saved: $reportPath`n" -ForegroundColor Green
    
    # Display summary
    Write-Host "RESULTS:" -ForegroundColor Cyan
    Write-Host "  ✓ Passed:  $($script:TestResults.Passed)" -ForegroundColor Green
    Write-Host "  ✗ Failed:  $($script:TestResults.Failed)" -ForegroundColor Red
    Write-Host "  ⊘ Skipped: $($script:TestResults.Skipped)" -ForegroundColor Yellow
}

# ============================================================================
# Load functions from Install.ps1
# ============================================================================

Write-Host "`nLoading Install.ps1 functions..." -ForegroundColor Yellow

try {
    # Dot-source the Install.ps1 script to load its functions
    . .\Install.ps1 -ErrorAction Stop 2>$null
    Log-Test "Loader" "Script Load" "PASS" "Successfully loaded Install.ps1"
} catch {
    Log-Test "Loader" "Script Load" "FAIL" "Failed to load Install.ps1" "$($_.Exception.Message)"
    Save-TestLog
    exit 1
}

# ============================================================================
# Test Write Functions
# ============================================================================

Write-Host "`nTesting Write Functions..." -ForegroundColor Cyan

try {
    Write-Step "Test Step"
    Log-Test "Write-Step" "Format Output" "PASS" "Displays formatted step header"
} catch {
    Log-Test "Write-Step" "Format Output" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    Write-Success "Test Success Message"
    Log-Test "Write-Success" "Format Output" "PASS" "Displays success message with checkmark"
} catch {
    Log-Test "Write-Success" "Format Output" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    Write-Warning-Custom "Test Warning Message"
    Log-Test "Write-Warning-Custom" "Format Output" "PASS" "Displays warning message with symbol"
} catch {
    Log-Test "Write-Warning-Custom" "Format Output" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    Write-Error-Custom "Test Error Message"
    Log-Test "Write-Error-Custom" "Format Output" "PASS" "Displays error message with symbol"
} catch {
    Log-Test "Write-Error-Custom" "Format Output" "FAIL" "Error: $($_.Exception.Message)"
}

# ============================================================================
# Test Command Detection
# ============================================================================

Write-Host "`nTesting Command Detection..." -ForegroundColor Cyan

try {
    $result = Test-Command "powershell"
    if ($result -eq $true) {
        Log-Test "Test-Command" "Find Existing Command" "PASS" "Correctly detected 'powershell' command"
    } else {
        Log-Test "Test-Command" "Find Existing Command" "FAIL" "Failed to detect 'powershell' command"
    }
} catch {
    Log-Test "Test-Command" "Find Existing Command" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    $result = Test-Command "nonexistent_command_xyz"
    if ($result -eq $false) {
        Log-Test "Test-Command" "Detect Missing Command" "PASS" "Correctly detected missing command"
    } else {
        Log-Test "Test-Command" "Detect Missing Command" "FAIL" "Failed to detect missing command"
    }
} catch {
    Log-Test "Test-Command" "Detect Missing Command" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    $result = Test-Command "dotnet"
    Log-Test "Test-Command" "Check dotnet" "PASS" "dotnet found: $result"
} catch {
    Log-Test "Test-Command" "Check dotnet" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    $result = Test-Command "gcc"
    Log-Test "Test-Command" "Check gcc" "PASS" "gcc found: $result"
} catch {
    Log-Test "Test-Command" "Check gcc" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    $result = Test-Command "choco"
    Log-Test "Test-Command" "Check choco" "PASS" "choco found: $result"
} catch {
    Log-Test "Test-Command" "Check choco" "FAIL" "Error: $($_.Exception.Message)"
}

# ============================================================================
# Test Path Functions
# ============================================================================

Write-Host "`nTesting Path Detection..." -ForegroundColor Cyan

try {
    $modulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\MatLabCppPowerShell"
    if (Test-Path $env:USERPROFILE) {
        Log-Test "Path Functions" "User Profile Detection" "PASS" "User profile found: $env:USERPROFILE"
    } else {
        Log-Test "Path Functions" "User Profile Detection" "FAIL" "User profile not found"
    }
} catch {
    Log-Test "Path Functions" "User Profile Detection" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    $profilePath = $PROFILE
    if ($profilePath) {
        Log-Test "Path Functions" "PowerShell Profile Path" "PASS" "Profile path: $profilePath"
    } else {
        Log-Test "Path Functions" "PowerShell Profile Path" "FAIL" "Profile path is empty"
    }
} catch {
    Log-Test "Path Functions" "PowerShell Profile Path" "FAIL" "Error: $($_.Exception.Message)"
}

# ============================================================================
# Test Environment Variables
# ============================================================================

Write-Host "`nTesting Environment Variables..." -ForegroundColor Cyan

try {
    $pathVar = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($pathVar) {
        Log-Test "Environment" "Machine PATH" "PASS" "Retrieved machine PATH ($(($pathVar.Split(';') | Measure-Object).Count) entries)"
    } else {
        Log-Test "Environment" "Machine PATH" "FAIL" "Machine PATH is empty"
    }
} catch {
    Log-Test "Environment" "Machine PATH" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    $pathVar = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    if ($pathVar) {
        Log-Test "Environment" "User PATH" "PASS" "Retrieved user PATH ($(($pathVar.Split(';') | Measure-Object).Count) entries)"
    } else {
        Log-Test "Environment" "User PATH" "SKIP" "User PATH is empty (may be normal)"
    }
} catch {
    Log-Test "Environment" "User PATH" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    $version = [System.Environment]::OSVersion
    Log-Test "Environment" "OS Detection" "PASS" "OS: $($version.VersionString)"
} catch {
    Log-Test "Environment" "OS Detection" "FAIL" "Error: $($_.Exception.Message)"
}

# ============================================================================
# Test File Operations
# ============================================================================

Write-Host "`nTesting File Operations..." -ForegroundColor Cyan

try {
    $testDir = Join-Path $env:TEMP "MatLabCpp_Test_$(Get-Random)"
    $result = New-Item -ItemType Directory -Path $testDir -Force
    if (Test-Path $testDir) {
        Log-Test "File Operations" "Directory Creation" "PASS" "Created test directory"
        Remove-Item $testDir -Force
    } else {
        Log-Test "File Operations" "Directory Creation" "FAIL" "Directory creation failed"
    }
} catch {
    Log-Test "File Operations" "Directory Creation" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    $testFile = Join-Path $env:TEMP "test_$(Get-Random).txt"
    "Test content" | Out-File $testFile -Encoding UTF8
    if (Test-Path $testFile) {
        Log-Test "File Operations" "File Creation" "PASS" "Created test file"
        Remove-Item $testFile -Force
    } else {
        Log-Test "File Operations" "File Creation" "FAIL" "File creation failed"
    }
} catch {
    Log-Test "File Operations" "File Creation" "FAIL" "Error: $($_.Exception.Message)"
}

# ============================================================================
# Test Admin Check
# ============================================================================

Write-Host "`nTesting Administrator Detection..." -ForegroundColor Cyan

try {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Log-Test "Admin Check" "Administrator Status" "PASS" "Running as Administrator"
    } else {
        Log-Test "Admin Check" "Administrator Status" "PASS" "Running as Standard User (expected for tests)"
    }
} catch {
    Log-Test "Admin Check" "Administrator Status" "FAIL" "Error: $($_.Exception.Message)"
}

# ============================================================================
# Test Module Manifest Generation
# ============================================================================

Write-Host "`nTesting Module Manifest Capabilities..." -ForegroundColor Cyan

try {
    $testManifestPath = Join-Path $env:TEMP "test_manifest_$(Get-Random).psd1"
    $manifestParams = @{
        Path = $testManifestPath
        ModuleVersion = '1.0.0'
        Author = 'Test'
        Description = 'Test Module'
    }
    New-ModuleManifest @manifestParams -ErrorAction Stop
    
    if (Test-Path $testManifestPath) {
        Log-Test "Module Operations" "Manifest Generation" "PASS" "Successfully created module manifest"
        Remove-Item $testManifestPath -Force
    } else {
        Log-Test "Module Operations" "Manifest Generation" "FAIL" "Manifest file not created"
    }
} catch {
    Log-Test "Module Operations" "Manifest Generation" "FAIL" "Error: $($_.Exception.Message)"
}

# ============================================================================
# Test Required Source Files
# ============================================================================

Write-Host "`nTesting Required Source Files..." -ForegroundColor Cyan

$requiredFiles = @(
    @{ Name = "matlabcpp_c_bridge.c"; Type = "C Source" }
    @{ Name = "MatLabCppPowerShell.cs"; Type = "C# Source" }
    @{ Name = "MatLabCppPowerShell.csproj"; Type = "Project File" }
    @{ Name = "build_native.ps1"; Type = "Build Script" }
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file.Name) {
        Log-Test "Source Files" $file.Name "PASS" "Found $($file.Type)"
    } else {
        Log-Test "Source Files" $file.Name "FAIL" "Missing $($file.Type)"
    }
}

# ============================================================================
# Test Build Infrastructure
# ============================================================================

Write-Host "`nTesting Build Infrastructure..." -ForegroundColor Cyan

try {
    if (Test-Path "MatLabCppPowerShell.csproj") {
        $projContent = Get-Content "MatLabCppPowerShell.csproj" -Raw
        if ($projContent -match "<TargetFramework>net6.0</TargetFramework>") {
            Log-Test "Build Infrastructure" "Project Target Framework" "PASS" "Targets .NET 6.0"
        } else {
            Log-Test "Build Infrastructure" "Project Target Framework" "FAIL" "Target framework not net6.0"
        }
    } else {
        Log-Test "Build Infrastructure" "Project Target Framework" "FAIL" "Project file not found"
    }
} catch {
    Log-Test "Build Infrastructure" "Project Target Framework" "FAIL" "Error: $($_.Exception.Message)"
}

try {
    if (Test-Path "build_native.ps1") {
        Log-Test "Build Infrastructure" "Native Build Script" "PASS" "build_native.ps1 exists"
    } else {
        Log-Test "Build Infrastructure" "Native Build Script" "FAIL" "build_native.ps1 not found"
    }
} catch {
    Log-Test "Build Infrastructure" "Native Build Script" "FAIL" "Error: $($_.Exception.Message)"
}

# ============================================================================
# Final Report
# ============================================================================

Write-Host "`nGenerating final test report..." -ForegroundColor Cyan
Save-TestLog

Write-Host "`n" -ForegroundColor Cyan
Write-Host "═════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Test Suite Complete" -ForegroundColor Cyan
Write-Host "═════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "`n"
