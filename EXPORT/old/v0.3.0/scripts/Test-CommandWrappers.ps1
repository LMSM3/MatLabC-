# Test-CommandWrappers.ps1
# Comprehensive test suite for MatLabC++ command-line wrappers
# Tests all wrappers across different scenarios and platforms

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SkipExecutableTest  # Skip tests that require actual executable
)

$ErrorActionPreference = "Stop"

# Color output functions
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Failure { param($Message) Write-Host "[FAIL] $Message" -ForegroundColor Red }
function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-TestHeader { param($Message) Write-Host "`n=== $Message ===" -ForegroundColor Yellow }

# Test counters
$script:PassCount = 0
$script:FailCount = 0
$script:SkipCount = 0

function Test-WrapperExists {
    param($Path, $Description)
    
    Write-TestHeader "Testing: $Description"
    
    if (Test-Path $Path) {
        Write-Success "$Description exists at: $Path"
        $script:PassCount++
        return $true
    } else {
        Write-Failure "$Description not found at: $Path"
        $script:FailCount++
        return $false
    }
}

function Test-WrapperContent {
    param($Path, $ExpectedExecutable, $Description)
    
    Write-TestHeader "Testing Content: $Description"
    
    if (-not (Test-Path $Path)) {
        Write-Failure "File not found: $Path"
        $script:FailCount++
        return $false
    }
    
    $content = Get-Content $Path -Raw
    
    # Check if executable name is referenced
    if ($content -match [regex]::Escape($ExpectedExecutable)) {
        Write-Success "$Description references '$ExpectedExecutable'"
        $script:PassCount++
        return $true
    } else {
        Write-Failure "$Description does NOT reference '$ExpectedExecutable'"
        Write-Info "Expected: $ExpectedExecutable"
        Write-Info "Content preview: $($content.Substring(0, [Math]::Min(200, $content.Length)))"
        $script:FailCount++
        return $false
    }
}

function Test-WrapperExecutable {
    param($WrapperPath, $Description)
    
    Write-TestHeader "Testing Executability: $Description"
    
    if ($SkipExecutableTest) {
        Write-Info "Skipping executable test (--SkipExecutableTest specified)"
        $script:SkipCount++
        return $null
    }
    
    if (-not (Test-Path $WrapperPath)) {
        Write-Failure "Wrapper not found: $WrapperPath"
        $script:FailCount++
        return $false
    }
    
    try {
        # Try to execute with --version flag (most programs support this)
        $output = & $WrapperPath --version 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$Description executed successfully"
            Write-Info "Output: $output"
            $script:PassCount++
            return $true
        } else {
            Write-Failure "$Description exit code: $LASTEXITCODE"
            $script:FailCount++
            return $false
        }
    } catch {
        Write-Failure "$Description threw exception: $_"
        $script:FailCount++
        return $false
    }
}

function Test-BashScriptExecutable {
    param($ScriptPath, $Description)
    
    Write-TestHeader "Testing Bash Script: $Description"
    
    if (-not (Test-Path $ScriptPath)) {
        Write-Failure "Script not found: $ScriptPath"
        $script:FailCount++
        return $false
    }
    
    # Check shebang
    $firstLine = Get-Content $ScriptPath -First 1
    if ($firstLine -match '^#!/') {
        Write-Success "$Description has valid shebang: $firstLine"
        $script:PassCount++
    } else {
        Write-Failure "$Description missing shebang line"
        $script:FailCount++
        return $false
    }
    
    # Check if script uses 'exec' (best practice for wrappers)
    $content = Get-Content $ScriptPath -Raw
    if ($content -match '\bexec\b') {
        Write-Success "$Description uses 'exec' (preserves exit code)"
        $script:PassCount++
    } else {
        Write-Info "$Description doesn't use 'exec' (may still work, but not ideal)"
        $script:SkipCount++
    }
    
    return $true
}

# ==============================================================================
# Main Test Execution
# ==============================================================================

Write-Host "`n" -NoNewline
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  MatLabC++ Command Wrapper Test Suite v0.3.0                  " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptsDir = $PSScriptRoot
if (-not $ScriptsDir) {
    $ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

Write-Info "Scripts directory: $ScriptsDir"
Write-Info "Platform: $($PSVersionTable.Platform)"
Write-Info "OS: $($PSVersionTable.OS)"
Write-Host ""

# ==============================================================================
# Phase 1: File Existence Tests
# ==============================================================================

Write-Host "================================================================" -ForegroundColor Yellow
Write-Host "  Phase 1: File Existence Tests                                " -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow

Test-WrapperExists (Join-Path $ScriptsDir "mlcpp.cmd") "Windows Primary Wrapper (mlcpp.cmd)"
Test-WrapperExists (Join-Path $ScriptsDir "mlc.cmd") "Windows Alias Wrapper (mlc.cmd)"
Test-WrapperExists (Join-Path $ScriptsDir "mlcpp.ps1") "PowerShell Wrapper (mlcpp.ps1)"
Test-WrapperExists (Join-Path $ScriptsDir "mlcpp") "Linux/macOS Primary Wrapper (mlcpp)"
Test-WrapperExists (Join-Path $ScriptsDir "mlc") "Linux/macOS Alias Wrapper (mlc)"
Test-WrapperExists (Join-Path $ScriptsDir "COMMAND_WRAPPERS.md") "Documentation (COMMAND_WRAPPERS.md)"

# ==============================================================================
# Phase 2: Content Validation Tests
# ==============================================================================

Write-Host "`n================================================================" -ForegroundColor Yellow
Write-Host "  Phase 2: Content Validation Tests                            " -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow

Test-WrapperContent (Join-Path $ScriptsDir "mlcpp.cmd") "matlabcpp.exe" "mlcpp.cmd"
Test-WrapperContent (Join-Path $ScriptsDir "mlc.cmd") "matlabcpp.exe" "mlc.cmd"
Test-WrapperContent (Join-Path $ScriptsDir "mlcpp.ps1") "matlabcpp" "mlcpp.ps1"
Test-WrapperContent (Join-Path $ScriptsDir "mlcpp") "matlabcpp" "mlcpp (bash)"
Test-WrapperContent (Join-Path $ScriptsDir "mlc") "matlabcpp" "mlc (bash)"

# ==============================================================================
# Phase 3: Bash Script Validation (Linux/macOS)
# ==============================================================================

Write-Host "`n================================================================" -ForegroundColor Yellow
Write-Host "  Phase 3: Bash Script Validation                              " -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow

Test-BashScriptExecutable (Join-Path $ScriptsDir "mlcpp") "mlcpp (bash)"
Test-BashScriptExecutable (Join-Path $ScriptsDir "mlc") "mlc (bash)"

# ==============================================================================
# Phase 4: PowerShell Script Validation
# ==============================================================================

Write-Host "`n================================================================" -ForegroundColor Yellow
Write-Host "  Phase 4: PowerShell Script Validation                        " -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow

Write-TestHeader "Testing PowerShell Script Syntax"

$ps1Path = Join-Path $ScriptsDir "mlcpp.ps1"
if (Test-Path $ps1Path) {
    try {
        # Test syntax by tokenizing (doesn't execute)
        $null = [System.Management.Automation.PSParser]::Tokenize(
            (Get-Content $ps1Path -Raw), 
            [ref]$null
        )
        Write-Success "mlcpp.ps1 has valid PowerShell syntax"
        $script:PassCount++
    } catch {
        Write-Failure "mlcpp.ps1 syntax error: $_"
        $script:FailCount++
    }
} else {
    Write-Failure "mlcpp.ps1 not found"
    $script:FailCount++
}

# ==============================================================================
# Phase 5: Cross-Platform Compatibility Checks
# ==============================================================================

Write-Host "`n================================================================" -ForegroundColor Yellow
Write-Host "  Phase 5: Cross-Platform Compatibility                        " -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow

Write-TestHeader "Checking Line Endings"

foreach ($file in @("mlcpp.cmd", "mlc.cmd")) {
    $filePath = Join-Path $ScriptsDir $file
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        if ($content -match "`r`n") {
            Write-Success "$file uses CRLF (correct for Windows batch files)"
            $script:PassCount++
        } else {
            Write-Info "$file uses LF (may work, but CRLF is standard for .cmd)"
            $script:SkipCount++
        }
    }
}

foreach ($file in @("mlcpp", "mlc")) {
    $filePath = Join-Path $ScriptsDir $file
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        if ($content -notmatch "`r`n") {
            Write-Success "$file uses LF (correct for bash scripts)"
            $script:PassCount++
        } else {
            Write-Failure "$file uses CRLF (should use LF for bash)"
            $script:FailCount++
        }
    }
}

# ==============================================================================
# Final Summary
# ==============================================================================

Write-Host "`n`n"
Write-Host "================================================================" -ForegroundColor Magenta
Write-Host "  Test Summary                                                  " -ForegroundColor Magenta
Write-Host "================================================================" -ForegroundColor Magenta

$TotalTests = $script:PassCount + $script:FailCount + $script:SkipCount

Write-Host ""
Write-Host "  Total Tests:  $TotalTests" -ForegroundColor White
Write-Host "  Passed:       $($script:PassCount)" -ForegroundColor Green
Write-Host "  Failed:       $($script:FailCount)" -ForegroundColor Red
Write-Host "  Skipped:      $($script:SkipCount)" -ForegroundColor Yellow
Write-Host ""

if ($script:FailCount -eq 0) {
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "  ALL TESTS PASSED!                                            " -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    exit 0
} else {
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "  SOME TESTS FAILED - Review output above                     " -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    exit 1
}
