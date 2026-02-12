#!/usr/bin/env bash
# setup_project.sh - Create project structure and stub files
#
# Run this before building to create necessary directories and stub files

set -euo pipefail

echo "Setting up MatLabC++ v0.3.0 project structure..."
echo ""

# Create directory structure
mkdir -p src/core
mkdir -p src/plotting
mkdir -p src/package_manager
mkdir -p src/cli
mkdir -p include/matlabcpp/plotting
mkdir -p include/matlabcpp/package_manager
mkdir -p examples
mkdir -p tests
mkdir -p build

echo "✓ Directories created"

# Create stub source files if they don't exist

# Core
if [ ! -f "src/core/matrix.cpp" ]; then
    cat > src/core/matrix.cpp <<'EOF'
#include "matlabcpp/core.hpp"
// Matrix implementation stub
namespace matlabcpp {
    // TODO: Implement matrix operations
}
EOF
fi

if [ ! -f "src/core/vector.cpp" ]; then
    cat > src/core/vector.cpp <<'EOF'
#include "matlabcpp/core.hpp"
// Vector implementation stub
namespace matlabcpp {
    // TODO: Implement vector operations
}
EOF
fi

if [ ! -f "src/core/functions.cpp" ]; then
    cat > src/core/functions.cpp <<'EOF'
#include "matlabcpp/core.hpp"
// Core functions stub
namespace matlabcpp {
    // TODO: Implement core functions
}
EOF
fi

if [ ! -f "src/core/interpreter.cpp" ]; then
    cat > src/core/interpreter.cpp <<'EOF'
#include "matlabcpp/core.hpp"
// Interpreter stub
namespace matlabcpp {
    // TODO: Implement interpreter
}
EOF
fi

# Main executable
if [ ! -f "src/main.cpp" ]; then
    cat > src/main.cpp <<'EOF'
#include <iostream>
#include <string>

int main(int argc, char** argv) {
    std::cout << "MatLabC++ v0.3.0\n";
    
    if (argc > 1) {
        std::string arg = argv[1];
        if (arg == "--version" || arg == "-v") {
            std::cout << "MatLabC++ version 0.3.0\n";
            return 0;
        }
    }
    
    std::cout << "Type 'help' for usage information\n";
    std::cout << ">> ";
    
    std::string input;
    while (std::getline(std::cin, input)) {
        if (input == "quit" || input == "exit") {
            break;
        }
        std::cout << ">> ";
    }
    
    return 0;
}
EOF
fi

# CLI
if [ ! -f "src/cli/argument_parser.cpp" ]; then
    cat > src/cli/argument_parser.cpp <<'EOF'
// Argument parser stub
namespace matlabcpp {
namespace cli {
    // TODO: Implement argument parsing
}
}
EOF
fi

if [ ! -f "src/cli/repl.cpp" ]; then
    cat > src/cli/repl.cpp <<'EOF'
// REPL stub
namespace matlabcpp {
namespace cli {
    // TODO: Implement REPL
}
}
EOF
fi

# Plotting
if [ ! -f "src/plotting/renderer_2d.cpp" ]; then
    cat > src/plotting/renderer_2d.cpp <<'EOF'
#include "matlabcpp/plotting/renderer.hpp"
// 2D renderer stub
namespace matlabcpp {
namespace plotting {
    // TODO: Implement 2D renderer
}
}
EOF
fi

if [ ! -f "src/plotting/renderer_3d.cpp" ]; then
    cat > src/plotting/renderer_3d.cpp <<'EOF'
#include "matlabcpp/plotting/renderer.hpp"
// 3D renderer stub
namespace matlabcpp {
namespace plotting {
    // TODO: Implement 3D renderer
}
}
EOF
fi

if [ ! -f "src/plotting/plot_spec.cpp" ]; then
    cat > src/plotting/plot_spec.cpp <<'EOF'
#include "matlabcpp/plotting/plot_spec.hpp"
// Plot spec parser stub
namespace matlabcpp {
namespace plotting {
    // TODO: Implement plot spec parser
}
}
EOF
fi

if [ ! -f "src/plotting/style_presets.cpp" ]; then
    cat > src/plotting/style_presets.cpp <<'EOF'
#include "matlabcpp/plotting/style_presets.hpp"
// Style presets stub
namespace matlabcpp {
namespace plotting {
    // TODO: Implement style presets (business/engineering)
}
}
EOF
fi

# Package manager
if [ ! -f "src/package_manager/database.cpp" ]; then
    cat > src/package_manager/database.cpp <<'EOF'
#include "matlabcpp/package_manager.hpp"
// Package database stub
namespace matlabcpp {
namespace pkg {
    // TODO: Implement package database
}
}
EOF
fi

if [ ! -f "src/package_manager/repository.cpp" ]; then
    cat > src/package_manager/repository.cpp <<'EOF'
#include "matlabcpp/package_manager.hpp"
// Repository stub
namespace matlabcpp {
namespace pkg {
    // TODO: Implement repository
}
}
EOF
fi

if [ ! -f "src/package_manager/resolver.cpp" ]; then
    cat > src/package_manager/resolver.cpp <<'EOF'
#include "matlabcpp/package_manager.hpp"
// Dependency resolver stub
namespace matlabcpp {
namespace pkg {
    // TODO: Implement dependency resolver
}
}
EOF
fi

if [ ! -f "src/package_manager/installer.cpp" ]; then
    cat > src/package_manager/installer.cpp <<'EOF'
#include "matlabcpp/package_manager.hpp"
// Package installer stub
namespace matlabcpp {
namespace pkg {
    // TODO: Implement package installer
}
}
EOF
fi

if [ ! -f "src/package_manager/capability_registry.cpp" ]; then
    cat > src/package_manager/capability_registry.cpp <<'EOF'
#include "matlabcpp/package_manager.hpp"
// Capability registry stub
namespace matlabcpp {
namespace pkg {
    // TODO: Implement capability registry
}
}
EOF
fi

# Stub headers if needed
if [ ! -f "include/matlabcpp/core.hpp" ]; then
    cat > include/matlabcpp/core.hpp <<'EOF'
#pragma once
namespace matlabcpp {
    // Core types and functions
}
EOF
fi

if [ ! -f "include/matlabcpp/plotting/renderer.hpp" ]; then
    cat > include/matlabcpp/plotting/renderer.hpp <<'EOF'
#pragma once
namespace matlabcpp {
namespace plotting {
    // Renderer interface
}
}
EOF
fi

if [ ! -f "include/matlabcpp/plotting/plot_spec.hpp" ]; then
    cat > include/matlabcpp/plotting/plot_spec.hpp <<'EOF'
#pragma once
namespace matlabcpp {
namespace plotting {
    // Plot specification
}
}
EOF
fi

if [ ! -f "include/matlabcpp/plotting/style_presets.hpp" ]; then
    cat > include/matlabcpp/plotting/style_presets.hpp <<'EOF'
#pragma once
namespace matlabcpp {
namespace plotting {
    // Style presets
}
}
EOF
fi

echo "✓ Stub source files created"
echo ""
echo "Project structure ready!"
echo ""
echo "Next steps:"
echo "  1. Review created files"
echo "  2. Run: ./build.sh build"
echo "  3. Implement TODO items in source files"
echo ""
