#!/bin/bash
# Setup-Bash-Integration.sh - Configure MatLabC++ for bash/WSL

set -e

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  MatLabC++ Bash/WSL Integration Setup"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

BASHRC="$HOME/.bashrc"
if [[ ! -f "$BASHRC" ]]; then
    BASHRC="$HOME/.bash_profile"
fi

if [[ ! -f "$BASHRC" ]]; then
    echo "ERROR: Could not find .bashrc or .bash_profile" >&2
    exit 1
fi

echo "[OK] Using: $BASHRC"
echo ""

MLCPP_PATH="/mnt/c/Users/Liam/Desktop/MatLabC++/build/Release/matlabcpp.exe"

if [[ ! -f "$MLCPP_PATH" ]]; then
    echo "ERROR: matlabcpp.exe not found at: $MLCPP_PATH" >&2
    echo "Did you build the Release executable?" >&2
    exit 1
fi

echo "[OK] MatLabC++ executable found"
echo "[OK] Size: $(du -h "$MLCPP_PATH" | cut -f1)"
echo ""

MARKER="# MatLabC++ CLI Integration (v0.3.1)"

if grep -q "$MARKER" "$BASHRC"; then
    echo "[OK] Configuration already present in $BASHRC"
else
    echo "Adding configuration to $BASHRC..."
    
    cat >> "$BASHRC" << 'BASH_CONFIG'

# MatLabC++ CLI Integration (v0.3.1)
alias mlcpp='/mnt/c/Users/Liam/Desktop/MatLabC++/build/Release/matlabcpp.exe'
alias mlc='/mnt/c/Users/Liam/Desktop/MatLabC++/build/Release/matlabcpp.exe'

# Enable command completion for mlcpp (optional)
_mlcpp_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local options="--version --help compile run execute"
    COMPREPLY=( $(compgen -W "$options" -- "$cur") )
}
complete -F _mlcpp_completion mlcpp
complete -F _mlcpp_completion mlc

BASH_CONFIG
    
    echo "[OK] Configuration added"
fi

echo ""
echo "Reloading bash configuration..."
source "$BASHRC"

echo ""
echo "Testing mlcpp command..."
if command -v mlcpp &> /dev/null; then
    echo "[OK] mlcpp command is available"
else
    echo "ERROR: mlcpp command not found after reload" >&2
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  Integration Complete!"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "You can now use:"
echo "  mlcpp --version"
echo "  mlcpp compile program.m"
echo "  mlcpp run program.m"
echo ""
echo "From any directory in bash/WSL!"
echo ""
