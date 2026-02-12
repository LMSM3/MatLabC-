#!/usr/bin/env bash
# launch_build.sh - Launch build in external terminal
#
# This script opens a new terminal window and runs the build

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect terminal and launch
if command -v gnome-terminal >/dev/null 2>&1; then
    # GNOME Terminal (Ubuntu, Fedora)
    gnome-terminal -- bash -c "cd '$SCRIPT_DIR' && ./setup_project.sh && ./build.sh install; echo ''; echo 'Press Enter to close...'; read"
    
elif command -v konsole >/dev/null 2>&1; then
    # KDE Konsole
    konsole -e bash -c "cd '$SCRIPT_DIR' && ./setup_project.sh && ./build.sh install; echo ''; echo 'Press Enter to close...'; read"
    
elif command -v xterm >/dev/null 2>&1; then
    # XTerm (fallback)
    xterm -e "cd '$SCRIPT_DIR' && ./setup_project.sh && ./build.sh install; echo ''; echo 'Press Enter to close...'; read"
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS Terminal
    osascript -e "tell application \"Terminal\" to do script \"cd '$SCRIPT_DIR' && ./setup_project.sh && ./build.sh install; echo ''; echo 'Press Enter to close...'; read\""
    
else
    # Fallback: run in current terminal
    echo "Could not detect terminal, running in current window..."
    cd "$SCRIPT_DIR"
    ./setup_project.sh
    ./build.sh install
fi

echo "Build launched in external terminal!"
