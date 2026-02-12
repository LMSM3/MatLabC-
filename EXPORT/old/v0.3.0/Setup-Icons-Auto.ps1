<#
.SYNOPSIS
    Auto-detects first-run or location change and automates icon setup.

.DESCRIPTION
    Smart wrapper around Setup-Icons.ps1 that:
    - Detects if running for first time (no state cache)
    - Detects if project location has changed (cached path differs from current)
    - Auto-executes setup with appropriate flags (-Force, -WhatIf, etc.)
    - Caches state for future runs
    - Supports manual override flags

.PARAMETER Force
    Force execution even if not first-run or location change.

.PARAMETER WhatIf
    Preview mode without executing.

.PARAMETER NoCache
    Do not write state cache file after execution.

.PARAMETER ResetCache
    Delete existing cache and treat as fresh start.

.EXAMPLE
    # Auto-detect and execute if needed
    .\Setup-Icons-Auto.ps1

.EXAMPLE
    # Force execution regardless of cache
    .\Setup-Icons-Auto.ps1 -Force

.EXAMPLE
    # Preview what would happen
    .\Setup-Icons-Auto.ps1 -WhatIf

.EXAMPLE
    # Reset cache and start fresh
    .\Setup-Icons-Auto.ps1 -ResetCache

.NOTES
    Author: MatLabC++ Build System
    Version: 0.3.1
    Cache Location: v0.3.0\.setup-icons-cache.json
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$WhatIf,
    
    [Parameter()]
    [switch]$NoCache,
    
    [Parameter()]
    [switch]$ResetCache,
    
    [Parameter()]
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# ============================================================================
# Configuration
# ============================================================================

$script:ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$script:CacheFile = Join-Path $script:ScriptDir ".setup-icons-cache.json"
$script:SetupIconsScript = Join-Path $script:ScriptDir "Setup-Icons.ps1"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $colors = @{
        "INFO"    = "Cyan"
        "SUCCESS" = "Green"
        "WARN"    = "Yellow"
        "ERROR"   = "Red"
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colors[$Level]
}

function Get-CacheState {
    if (-not (Test-Path $script:CacheFile)) {
        return $null
    }
    
    try {
        $content = Get-Content $script:CacheFile -Raw | ConvertFrom-Json
        return $content
    } catch {
        Write-Log "Cache file corrupted, ignoring: $_" "WARN"
        return $null
    }
}

function Save-CacheState {
    param([hashtable]$State)
    
    if ($NoCache) {
        Write-Log "Skipping cache (NoCache flag set)" "INFO"
        return
    }
    
    try {
        $json = $State | ConvertTo-Json
        $json | Set-Content $script:CacheFile -Encoding UTF8
        Write-Log "Cached state: $script:CacheFile" "SUCCESS"
    } catch {
        Write-Log "Failed to save cache: $_" "ERROR"
    }
}

function Get-ProjectEnvironment {
    $projectRoot = Split-Path -Parent $script:ScriptDir
    $hostname = [System.Net.Dns]::GetHostName()
    $username = $env:USERNAME
    $computerInfo = Get-ComputerInfo -ErrorAction SilentlyContinue
    $osVersion = if ($computerInfo) { $computerInfo.OsVersion } else { $PSVersionTable.OS }
    
    return @{
        ProjectRoot    = $projectRoot
        ScriptPath     = $script:ScriptDir
        Hostname       = $hostname
        Username       = $username
        OSVersion      = $osVersion
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        Timestamp      = Get-Date -Format "o"
    }
}

function Test-FirstRun {
    $cache = Get-CacheState
    return $cache -eq $null
}

function Test-LocationChange {
    $cache = Get-CacheState
    if ($cache -eq $null) {
        return $false
    }
    
    $current = Get-ProjectEnvironment
    $cached = $cache.Environment
    
    # Check if any critical paths have changed
    if ($cached.ProjectRoot -ne $current.ProjectRoot) {
        Write-Log "ProjectRoot changed: '$($cached.ProjectRoot)' → '$($current.ProjectRoot)'" "WARN"
        return $true
    }
    
    if ($cached.Hostname -ne $current.Hostname) {
        Write-Log "Hostname changed: '$($cached.Hostname)' → '$($current.Hostname)'" "WARN"
        return $true
    }
    
    if ($cached.Username -ne $current.Username) {
        Write-Log "Username changed: '$($cached.Username)' → '$($current.Username)'" "WARN"
        return $true
    }
    
    return $false
}

function Test-AssetExists {
    $projectRoot = Split-Path -Parent $script:ScriptDir
    $assetIcon = Join-Path $projectRoot "assets" "icon.ico"
    return Test-Path $assetIcon -PathType Leaf
}

# ============================================================================
# Main Logic
# ============================================================================

Write-Host ""
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "  Setup-Icons Auto-Detection & Automation" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host ""

# Reset cache if requested
if ($ResetCache) {
    if (Test-Path $script:CacheFile) {
        Remove-Item $script:CacheFile -Force
        Write-Log "Cache reset" "SUCCESS"
    }
}

# Detect conditions
$isFirstRun = Test-FirstRun
$hasLocationChange = Test-LocationChange
$assetExists = Test-AssetExists

Write-Log "First Run: $isFirstRun" "INFO"
Write-Log "Location Changed: $hasLocationChange" "INFO"
Write-Log "Asset Exists: $assetExists" "INFO"
Write-Log "Force Flag: $Force" "INFO"
Write-Host ""

# Determine if we should execute
$shouldExecute = $Force -or $isFirstRun -or $hasLocationChange -or -not $assetExists

if ($shouldExecute) {
    Write-Log "Conditions met for execution - proceeding with Setup-Icons.ps1" "SUCCESS"
    Write-Host ""
    
    # Build parameters for Setup-Icons.ps1
    $setupParams = @{}
    if ($WhatIf) { $setupParams['WhatIf'] = $true }
    
    # Auto-force if location changed or first run
    if ($isFirstRun -or $hasLocationChange) {
        $setupParams['Force'] = $true
        Write-Log "Auto-enabling Force (first-run or location change)" "WARN"
    }
    
    Write-Host ""
    
    # Execute Setup-Icons.ps1
    try {
        if (Test-Path $script:SetupIconsScript -PathType Leaf) {
            $result = & $script:SetupIconsScript @setupParams
            
            # Cache the execution state
            if ($result -and $result.Success) {
                $cacheState = @{
                    Environment = Get-ProjectEnvironment
                    LastExecution = @{
                        Success = $result.Success
                        DestinationIcon = $result.DestinationIcon
                        Timestamp = Get-Date -Format "o"
                    }
                    Result = $result
                }
                
                Save-CacheState $cacheState
                Write-Log "Setup completed successfully and cached" "SUCCESS"
            }
        } else {
            Write-Log "Setup-Icons.ps1 not found: $script:SetupIconsScript" "ERROR"
            exit 1
        }
    } catch {
        Write-Log "Setup-Icons.ps1 execution failed: $_" "ERROR"
        exit 1
    }
} else {
    Write-Log "No action needed - all conditions satisfied" "SUCCESS"
    Write-Log "Use -Force to re-run, or -ResetCache to start fresh" "INFO"
    
    $cache = Get-CacheState
    if ($cache -and $cache.LastExecution) {
        Write-Host ""
        Write-Host "Last Successful Execution:" -ForegroundColor Cyan
        Write-Host "  Timestamp: $($cache.LastExecution.Timestamp)" -ForegroundColor Gray
        Write-Host "  Icon: $($cache.LastExecution.DestinationIcon)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host ("=" * 70) -ForegroundColor Green
Write-Host "  Automation Complete" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Green
Write-Host ""
