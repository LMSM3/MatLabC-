# MatLabC++ PowerShell - Self-Installer
# Automatically installs dependencies, builds, and configures the module

param(
    [switch]$SkipDependencies,
    [switch]$Unattended,
    [string]$InstallPath = "$env:ProgramFiles\MatLabCppPowerShell"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param($Message)
    Write-Host "`n═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Write-Success {
    param($Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param($Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param($Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Test-Command {
    param($CommandName)
    try {
        Get-Command $CommandName -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Install-Chocolatey {
    Write-Step "Installing Chocolatey Package Manager"
    
    if (Test-Command choco) {
        Write-Success "Chocolatey already installed"
        return
    }
    
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh environment
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = $machinePath + ';' + $userPath
    
    Write-Success "Chocolatey installed"
}

function Install-DotNetSDK {
    Write-Step "Checking .NET SDK"
    
    if (Test-Command dotnet) {
        $version = (dotnet --version)
        Write-Success ".NET SDK $version installed"
        return
    }
    
    Write-Host "Installing .NET SDK 6.0..."
    
    if ($Unattended) {
        choco install dotnet-sdk -y
    } else {
        $response = Read-Host "Install .NET SDK 6.0? (Y/n)"
        if ($response -ne 'n') {
            choco install dotnet-sdk -y
        }
    }
    
    Write-Success ".NET SDK installed"
}

function Install-GCC {
    Write-Step "Checking C Compiler (GCC)"
    
    if (Test-Command gcc) {
        $version = (gcc --version | Select-Object -First 1)
        Write-Success "GCC installed: $version"
        return
    }
    
    Write-Host "GCC not found. Installing MinGW..."
    
    if ($Unattended) {
        choco install mingw -y
    } else {
        $response = Read-Host "Install MinGW-w64 GCC? (Y/n)"
        if ($response -ne 'n') {
            choco install mingw -y
        } else {
            Write-Warning-Custom "Skipping GCC installation. Build will fail without a C compiler!"
            return
        }
    }
    
    # Refresh PATH
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = $machinePath + ';' + $userPath
    
    Write-Success "MinGW GCC installed"
}

function Build-NativeLibrary {
    Write-Step "Building Native C Library"
    
    if (-not (Test-Path "matlabcpp_c_bridge.c")) {
        Write-Error-Custom "Source file not found: matlabcpp_c_bridge.c"
        throw "Build failed: source file missing"
    }
    
    # Try to build
    Write-Host "Compiling C bridge..."
    $output = & gcc -shared -O2 -o matlabcpp_c_bridge.dll matlabcpp_c_bridge.c -I..\include -lm 2>&1
    
    if (-not (Test-Path "matlabcpp_c_bridge.dll")) {
        Write-Error-Custom "Native compilation failed"
        Write-Host $output
        throw "Build failed"
    }
    
    Write-Success "Native library built: matlabcpp_c_bridge.dll"
}

function Build-CSharpModule {
    Write-Step "Building C# PowerShell Module"
    
    if (-not (Test-Path "MatLabCppPowerShell.csproj")) {
        Write-Error-Custom "Project file not found: MatLabCppPowerShell.csproj"
        throw "Build failed: project file missing"
    }
    
    Write-Host "Compiling C# module..."
    dotnet build -c Release --nologo
    
    if ($LASTEXITCODE -ne 0) {
        throw "C# build failed"
    }
    
    Write-Success "C# module built successfully"
}

function Install-Module {
    Write-Step "Installing Module"
    
    $modulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\MatLabCppPowerShell"
    
    if (-not (Test-Path $modulePath)) {
        New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
    }
    
    # Copy binaries
    Copy-Item "bin\Release\net6.0\*" $modulePath -Recurse -Force
    Copy-Item "matlabcpp_c_bridge.dll" $modulePath -Force
    
    # Create module manifest using New-ModuleManifest
    $manifestPath = Join-Path $modulePath 'MatLabCppPowerShell.psd1'
    $manifestParams = @{
        Path = $manifestPath
        ModuleVersion = '1.0.0'
        GUID = 'a1b2c3d4-e5f6-4a5b-9c8d-1a2b3c4d5e6f'
        Author = 'MatLabC++ Team'
        Description = 'High-performance numerical computing for PowerShell'
        PowerShellVersion = '5.1'
        RootModule = 'MatLabCppPowerShell.dll'
        FunctionsToExport = @()
        CmdletsToExport = @('Get-Material', 'Find-Material', 'Get-Constant', 'Invoke-ODEIntegration', 'Invoke-MatrixMultiply')
        AliasesToExport = @('matmul')
    }
    New-ModuleManifest @manifestParams
    
    Write-Success "Module installed to: $modulePath"
}

function Test-Installation {
    Write-Step "Testing Installation"
    
    Import-Module MatLabCppPowerShell -Force
    
    # Test basic functionality
    try {
        $mat = Get-Material aluminum_6061
        if ($mat) {
            Write-Success "Module test passed: Get-Material works"
        } else {
            Write-Warning-Custom "Module loaded but test returned null"
        }
    } catch {
        Write-Error-Custom "Module test failed: $_"
        throw
    }
}

function Create-ProfileEntry {
    Write-Step "Adding to PowerShell Profile"
    
    $profileDir = Split-Path $PROFILE
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    $importLine = "Import-Module MatLabCppPowerShell"
    
    if (Test-Path $PROFILE) {
        $content = Get-Content $PROFILE -Raw
        if ($content -notmatch "MatLabCppPowerShell") {
            Add-Content $PROFILE "`n# MatLabC++ PowerShell Module"
            Add-Content $PROFILE $importLine
            Write-Success "Added to PowerShell profile"
        } else {
            Write-Success "Already in PowerShell profile"
        }
    } else {
        "# MatLabC++ PowerShell Module" | Out-File $PROFILE
        $importLine | Add-Content $PROFILE
        Write-Success "Created PowerShell profile with module import"
    }
}

function Show-Summary {
    Write-Host "`n"
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  MatLabC++ PowerShell - Installation Complete!   ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host "`n"
    
    Write-Host "Available Cmdlets:" -ForegroundColor Cyan
    Write-Host "  Get-Material          - Get material properties"
    Write-Host "  Find-Material         - Find material by density"
    Write-Host "  Get-Constant          - Get physical constants"
    Write-Host "  Invoke-ODEIntegration - Run physics simulations"
    Write-Host "  Invoke-MatrixMultiply - Matrix operations (alias: matmul)"
    Write-Host "`n"
    
    Write-Host "Try it now:" -ForegroundColor Yellow
    Write-Host "  Get-Material aluminum_6061" -ForegroundColor White
    Write-Host "  Get-Constant pi" -ForegroundColor White
    Write-Host "`n"
    
    Write-Host "Documentation: v0.3.0\powershell\POWERSHELL_GUIDE.md" -ForegroundColor Gray
}

# ============================================================================
# MAIN INSTALLATION SCRIPT
# ============================================================================

try {
    Write-Host "`n"
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  MatLabC++ PowerShell - Automated Installer      ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`n"
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Warning-Custom "Not running as Administrator. Some operations may require elevation."
        if (-not $Unattended) {
            $response = Read-Host "Continue anyway? (Y/n)"
            if ($response -eq 'n') {
                Write-Host "Installation cancelled. Run as Administrator for best results."
                exit 0
            }
        }
    }
    
    # Step 1: Install dependencies
    if (-not $SkipDependencies) {
        Install-Chocolatey
        Install-DotNetSDK
        Install-GCC
    } else {
        Write-Warning-Custom "Skipping dependency installation (-SkipDependencies)"
    }
    
    # Step 2: Build native library
    Build-NativeLibrary
    
    # Step 3: Build C# module
    Build-CSharpModule
    
    # Step 4: Install module
    Install-Module
    
    # Step 5: Test installation
    Test-Installation
    
    # Step 6: Add to profile
    if (-not $Unattended) {
        $response = Read-Host "Add module to PowerShell profile (auto-load on startup)? (Y/n)"
        if ($response -ne 'n') {
            Create-ProfileEntry
        }
    }
    
    # Show summary
    Show-Summary
    
    Write-Host "✓ Installation successful!" -ForegroundColor Green
    
} catch {
    Write-Host "`n"
    Write-Error-Custom "Installation failed: $_"
    Write-Host "`n"
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Run as Administrator"
    Write-Host "2. Check internet connection"
    Write-Host "3. Manually install dependencies:"
    Write-Host "   - .NET SDK 6.0: https://dot.net/download"
    Write-Host "   - MinGW GCC: https://github.com/niXman/mingw-builds-binaries/releases"
    Write-Host "`n"
    exit 1
}
