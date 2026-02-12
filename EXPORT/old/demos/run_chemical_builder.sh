#!/bin/bash
# RUN_CHEMICAL_BUILDER.SH - Interactive Material Builder Demo
# Runs the chemical builder UI in MatLabC++ REPL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
MLAB="${PROJECT_ROOT}/build/mlab++"

# Check build exists
if [ ! -f "$MLAB" ]; then
    echo "ERROR: Build not found at $MLAB"
    echo "Run: ./build_and_setup.sh"
    exit 1
fi

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     MatLabC++ CHEMICAL/MATERIAL BUILDER DEMO          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if script runner is available (v0.4.1+)
# For now, simulate with manual commands

echo "Building random chemical structure..."
echo ""

# Run the demo
if [ -f "${PROJECT_ROOT}/demos/chemical_builder.m" ]; then
    echo "Method 1: Running MATLAB script (requires v0.4.1+)"
    echo "         $ $MLAB < demos/chemical_builder.m"
    echo ""
    echo "Current version doesn't support script files yet."
    echo ""
    echo "Method 2: Manual REPL commands (works NOW)"
    echo ""
    echo -e "${GREEN}Starting interactive mode...${NC}"
    echo ""
    
    # Display manual commands
    cat << 'EOF'
Copy-paste these commands into the REPL:

>>> % Build random material
>>> material_type = randi(3)
>>> 
>>> % Generate structure
>>> N = 20
>>> lattice = randn(N, N)
>>> density = sum(abs(lattice(:))) / numel(lattice)
>>> 
>>> % Display
>>> fprintf('Material Structure Generated\n')
>>> fprintf('Size: %dx%d\n', N, N)
>>> fprintf('Density: %.4f\n', density)
>>> 
>>> % Visualize small section
>>> lattice(1:5, 1:5)
>>> 
>>> quit

EOF
    
    # Start REPL
    $MLAB
    
else
    echo "ERROR: Demo script not found"
    echo "Expected: ${PROJECT_ROOT}/demos/chemical_builder.m"
    exit 1
fi
