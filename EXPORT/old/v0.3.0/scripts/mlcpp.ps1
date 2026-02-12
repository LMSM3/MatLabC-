#!/usr/bin/env pwsh
# mlcpp.ps1 - MatLabC++ PowerShell Wrapper
# Forwards all arguments to the main matlabcpp executable
# Part of MatLabC++ v0.3.0 command-line integration
# Usage: mlcpp [options] file1.c file2.m ...

$ErrorActionPreference = "Stop"

# Get the directory where this script lives
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Determine executable name based on platform
if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
    $ExeName = "matlabcpp.exe"
} else {
    $ExeName = "matlabcpp"
}

$ExePath = Join-Path $ScriptDir $ExeName

# Check if executable exists
if (-not (Test-Path $ExePath)) {
    Write-Error "MatLabC++ executable not found at: $ExePath"
    exit 1
}

# Forward all arguments and preserve exit code
& $ExePath @args
exit $LASTEXITCODE
