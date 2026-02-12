#!/usr/bin/env bash
# MatLabC++ PowerShell - Linux/macOS Self-Installer

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/share/powershell/Modules/MatLabCppPowerShell}"
SKIP_DEPS=false
UNATTENDED=false

# Functions
print_step() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

command_exists() {
    command -v "$1" &> /dev/null
}

check_os() {
    print_step "Detecting Operating System"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_success "Detected: Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_success "Detected: macOS"
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

install_dotnet() {
    print_step "Checking .NET SDK"
    
    if command_exists dotnet; then
        version=$(dotnet --version)
        print_success ".NET SDK $version installed"
        return
    fi
    
    print_warning ".NET SDK not found"
    
    if [[ $UNATTENDED == false ]]; then
        read -p "Install .NET SDK 6.0? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_warning "Skipping .NET SDK installation"
            return
        fi
    fi
    
    if [[ "$OS" == "linux" ]]; then
        wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh
        chmod +x /tmp/dotnet-install.sh
        /tmp/dotnet-install.sh --channel 6.0
    elif [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew install --cask dotnet-sdk
        else
            print_error "Homebrew not found. Install from: https://brew.sh"
            exit 1
        fi
    fi
    
    print_success ".NET SDK installed"
}

install_gcc() {
    print_step "Checking C Compiler"
    
    if command_exists gcc; then
        version=$(gcc --version | head -1)
        print_success "GCC installed: $version"
        return
    fi
    
    print_warning "GCC not found"
    
    if [[ $UNATTENDED == false ]]; then
        read -p "Install GCC? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_warning "Skipping GCC installation. Build will fail!"
            return
        fi
    fi
    
    if [[ "$OS" == "linux" ]]; then
        if command_exists apt; then
            sudo apt update
            sudo apt install -y build-essential
        elif command_exists yum; then
            sudo yum groupinstall -y "Development Tools"
        elif command_exists pacman; then
            sudo pacman -S --noconfirm base-devel
        else
            print_error "Unknown package manager. Install GCC manually."
            exit 1
        fi
    elif [[ "$OS" == "macos" ]]; then
        xcode-select --install 2>/dev/null || true
    fi
    
    print_success "GCC installed"
}

install_powershell() {
    print_step "Checking PowerShell Core"
    
    if command_exists pwsh; then
        version=$(pwsh --version)
        print_success "PowerShell Core installed: $version"
        return
    fi
    
    print_warning "PowerShell Core not found"
    
    if [[ $UNATTENDED == false ]]; then
        read -p "Install PowerShell Core? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_error "PowerShell Core required! Exiting."
            exit 1
        fi
    fi
    
    if [[ "$OS" == "linux" ]]; then
        if command_exists snap; then
            sudo snap install powershell --classic
        elif command_exists apt; then
            wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            sudo apt update
            sudo apt install -y powershell
        else
            print_error "Install PowerShell Core manually: https://aka.ms/powershell-release?tag=stable"
            exit 1
        fi
    elif [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew install --cask powershell
        else
            print_error "Homebrew required. Install from: https://brew.sh"
            exit 1
        fi
    fi
    
    print_success "PowerShell Core installed"
}

build_native() {
    print_step "Building Native Library"
    
    if [[ ! -f "matlabcpp_c_bridge.c" ]]; then
        print_error "Source file not found: matlabcpp_c_bridge.c"
        exit 1
    fi
    
    if [[ "$OS" == "linux" ]]; then
        gcc -shared -fPIC -O2 -o libmatlabcpp_c_bridge.so matlabcpp_c_bridge.c -I../include -lm
        LIB_NAME="libmatlabcpp_c_bridge.so"
    elif [[ "$OS" == "macos" ]]; then
        gcc -dynamiclib -O2 -o libmatlabcpp_c_bridge.dylib matlabcpp_c_bridge.c -I../include -lm
        LIB_NAME="libmatlabcpp_c_bridge.dylib"
    fi
    
    if [[ ! -f "$LIB_NAME" ]]; then
        print_error "Native build failed"
        exit 1
    fi
    
    print_success "Native library built: $LIB_NAME"
}

build_csharp() {
    print_step "Building C# Module"
    
    if [[ ! -f "MatLabCppPowerShell.csproj" ]]; then
        print_error "Project file not found"
        exit 1
    fi
    
    dotnet build -c Release --nologo
    
    if [[ $? -ne 0 ]]; then
        print_error "C# build failed"
        exit 1
    fi
    
    print_success "C# module built"
}

install_module() {
    print_step "Installing Module"
    
    mkdir -p "$INSTALL_DIR"
    
    # Copy binaries
    cp -r bin/Release/net6.0/* "$INSTALL_DIR/"
    
    if [[ "$OS" == "linux" ]]; then
        cp libmatlabcpp_c_bridge.so "$INSTALL_DIR/"
    elif [[ "$OS" == "macos" ]]; then
        cp libmatlabcpp_c_bridge.dylib "$INSTALL_DIR/"
    fi
    
    # Make executable
    chmod +x "$INSTALL_DIR"/*.dll 2>/dev/null || true
    
    print_success "Module installed to: $INSTALL_DIR"
}

test_module() {
    print_step "Testing Module"
    
    pwsh -NoProfile -Command "
        Import-Module '$INSTALL_DIR/MatLabCppPowerShell.dll'
        \$mat = Get-Material aluminum_6061
        if (\$mat) {
            Write-Host '✓ Module test passed' -ForegroundColor Green
        } else {
            Write-Host '✗ Module test failed' -ForegroundColor Red
            exit 1
        }
    "
}

create_profile_entry() {
    print_step "Adding to PowerShell Profile"
    
    profile_path="$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
    profile_dir=$(dirname "$profile_path")
    
    mkdir -p "$profile_dir"
    
    if [[ -f "$profile_path" ]] && grep -q "MatLabCppPowerShell" "$profile_path"; then
        print_success "Already in PowerShell profile"
        return
    fi
    
    echo "" >> "$profile_path"
    echo "# MatLabC++ PowerShell Module" >> "$profile_path"
    echo "Import-Module '$INSTALL_DIR/MatLabCppPowerShell.dll'" >> "$profile_path"
    
    print_success "Added to PowerShell profile"
}

show_summary() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  MatLabC++ PowerShell - Installation Complete!   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}Available Cmdlets:${NC}"
    echo "  Get-Material          - Get material properties"
    echo "  Find-Material         - Find material by density"
    echo "  Get-Constant          - Get physical constants"
    echo "  Invoke-ODEIntegration - Run physics simulations"
    echo "  Invoke-MatrixMultiply - Matrix operations"
    echo ""
    
    echo -e "${YELLOW}Try it now:${NC}"
    echo "  pwsh -Command 'Import-Module $INSTALL_DIR/MatLabCppPowerShell.dll; Get-Material aluminum_6061'"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --unattended|-y)
            UNATTENDED=true
            shift
            ;;
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-deps        Skip dependency installation"
            echo "  --unattended, -y   Non-interactive mode"
            echo "  --install-dir DIR  Custom installation directory"
            echo "  --help, -h         Show this help"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Main installation
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  MatLabC++ PowerShell - Automated Installer      ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

check_os

if [[ $SKIP_DEPS == false ]]; then
    install_dotnet
    install_gcc
    install_powershell
fi

build_native
build_csharp
install_module
test_module

if [[ $UNATTENDED == false ]]; then
    read -p "Add module to PowerShell profile? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        create_profile_entry
    fi
fi

show_summary

print_success "Installation successful!"
