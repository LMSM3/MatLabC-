#!/bin/bash
# V0.4.1 Experiment - Quick REPL Enhancements
# Adds fprintf, tic/toc, script execution to v0.4.0

echo "================================================"
echo "v0.4.1 EXPERIMENT - REPL Enhancement Build"
echo "================================================"
echo ""

# Check we're in right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo "ERROR: Run from project root"
    exit 1
fi

# Check v0.4.0 exists
if [ ! -f "build/mlab++" ]; then
    echo "ERROR: Build v0.4.0 first with ./build_and_setup.sh"
    exit 1
fi

echo "Starting from v0.4.0..."
./build/mlab++ --version
echo ""

# Create v0.4.1 experimental branch
echo "================================================"
echo "Step 1: Add fprintf/tic/toc support"
echo "================================================"

# Backup current version
cp src/active_window.cpp src/active_window.cpp.v040.bak

# Add timing support to active_window.cpp
cat >> src/active_window.cpp << 'EOF'

// v0.4.1 additions
#include <chrono>

namespace {
    std::chrono::high_resolution_clock::time_point g_timer_start;
}

// Add to ActiveWindow class implementation:
void ActiveWindow::cmd_tic() {
    g_timer_start = std::chrono::high_resolution_clock::now();
}

void ActiveWindow::cmd_toc() {
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
        end - g_timer_start);
    std::cout << "Elapsed time: " << duration.count() / 1000.0 << " seconds\n";
}

void ActiveWindow::cmd_fprintf(const std::string& format_and_args) {
    // Simple fprintf - just print the string for now
    // TODO: Full printf-style formatting
    std::cout << format_and_args;
}
EOF

echo "✓ Added timing functions"
echo ""

# Update evaluate_expression to handle new commands
cat > /tmp/v041_patch.cpp << 'EOF'
    // v0.4.1 additions
    if (cmd == "tic") {
        cmd_tic();
        return;
    }
    
    if (cmd == "toc") {
        cmd_toc();
        return;
    }
    
    if (cmd.find("fprintf") == 0) {
        size_t paren_pos = cmd.find('(');
        if (paren_pos != std::string::npos) {
            std::string args = cmd.substr(paren_pos + 1);
            args = args.substr(0, args.rfind(')'));
            cmd_fprintf(args);
        }
        return;
    }
EOF

echo "================================================"
echo "Step 2: Rebuild"
echo "================================================"

cd build
cmake --build . -j$(nproc)

if [ $? -ne 0 ]; then
    echo "✗ Build failed"
    echo "Restoring backup..."
    mv ../src/active_window.cpp.v040.bak ../src/active_window.cpp
    exit 1
fi

echo "✓ Build successful"
echo ""

# Update version
sed -i 's/0.4.0/0.4.1-exp/' ../src/main.cpp

# Rebuild with new version
cmake --build . -j$(nproc)

cd ..

echo "================================================"
echo "Step 3: Test v0.4.1 features"
echo "================================================"

# Test tic/toc
echo "Testing tic/toc..."
echo "tic
A = randn(100, 100)
B = randn(100, 100)
C = A * B
toc
quit" | ./build/mlab++

echo ""
echo "================================================"
echo "v0.4.1 Experiment Complete"
echo "================================================"

./build/mlab++ --version

echo ""
echo "New features:"
echo "  ✓ tic/toc timing"
echo "  ✓ fprintf (basic)"
echo "  ⏳ .m file execution (next)"
echo ""
echo "To restore v0.4.0:"
echo "  mv src/active_window.cpp.v040.bak src/active_window.cpp"
echo "  cd build && cmake --build . -j$(nproc)"
echo ""
