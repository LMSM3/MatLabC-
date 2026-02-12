#!/usr/bin/env python3
"""
self_install_demo.py
MatLabC++ - Self-Installing Visual Demo

Intent: Demonstrate automatic package installation with visual feedback.
Starts with nothing, ends with a green square on screen.

No user input required. Just run.
"""

import sys
import subprocess
import time
import os

# ========== ANSI COLORS ==========
BOLD = '\033[1m'
DIM = '\033[2m'
GREEN = '\033[32m'
RED = '\033[31m'
YELLOW = '\033[33m'
CYAN = '\033[36m'
MAGENTA = '\033[35m'
NC = '\033[0m'

# ========== ANIMATION ==========
def spinner_animation(duration=1.0):
    """Show spinning animation"""
    spinners = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
    end_time = time.time() + duration
    i = 0
    while time.time() < end_time:
        print(f'\r  {CYAN}{spinners[i % len(spinners)]}{NC}', end='', flush=True)
        time.sleep(0.1)
        i += 1
    print('\r  ', end='', flush=True)

def progress_bar(current, total, label='Progress'):
    """Show progress bar"""
    width = 50
    percent = int((current / total) * 100)
    filled = int(width * current / total)
    bar = '█' * filled + '░' * (width - filled)
    
    # Color based on progress
    if percent == 100:
        color = GREEN
    elif percent > 66:
        color = CYAN
    else:
        color = YELLOW
    
    print(f'\r  {label} {color}[{bar}]{NC} {BOLD}{percent}%{NC}', end='', flush=True)
    
    if percent == 100:
        print(f' {GREEN}✓{NC}')

# ========== BANNER ==========
def show_banner():
    """Show startup banner"""
    print(f'\n{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}')
    print(f'{BOLD}{CYAN}MatLabC++ Self-Installing Visual Demo{NC}')
    print(f'{DIM}Automatic package detection and installation{NC}')
    print(f'{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}\n')

# ========== PACKAGE MANAGEMENT ==========
def check_package(package_name):
    """Check if a Python package is installed"""
    try:
        __import__(package_name)
        return True
    except ImportError:
        return False

def upgrade_pip():
    """Ensure pip is up to date"""
    try:
        subprocess.run(
            [sys.executable, '-m', 'pip', 'install', '--upgrade', 'pip', '--quiet'],
            capture_output=True,
            timeout=30
        )
        return True
    except:
        return False

def install_package(package_name, display_name=None):
    """Install a Python package with progress feedback"""
    if display_name is None:
        display_name = package_name
    
    print(f'\n{BOLD}Installing {display_name}...{NC}')
    
    # Show progress animation
    spinner_animation(0.5)
    
    # Try to install
    try:
        # Run pip install in subprocess
        process = subprocess.Popen(
            [sys.executable, '-m', 'pip', 'install', package_name, '--quiet', '--upgrade'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        # Animate while installing
        start_time = time.time()
        max_time = 60.0  # Max 60 seconds per package
        
        while process.poll() is None:
            elapsed = time.time() - start_time
            if elapsed > max_time:
                process.kill()
                print(f'\n  {RED}✗{NC} Installation timeout')
                return False
            
            # Show progress (estimated)
            progress = min(int((elapsed / 20.0) * 100), 95)  # Cap at 95% until done
            progress_bar(progress, 100, f'  {display_name}')
            time.sleep(0.2)
        
        # Check result
        if process.returncode == 0:
            progress_bar(100, 100, f'  {display_name}')
            
            # Verify installation
            if check_package(package_name):
                return True
            else:
                print(f'\n  {YELLOW}!{NC} Installed but import failed')
                return False
        else:
            print(f'\n  {RED}✗{NC} Installation failed')
            stderr = process.stderr.read().decode('utf-8')
            if stderr:
                print(f'{DIM}{stderr[:200]}{NC}')
            return False
    
    except Exception as e:
        print(f'\n  {RED}✗{NC} Exception: {e}')
        return False

def ensure_packages():
    """Ensure all required packages are installed"""
    print(f'{BOLD}Checking dependencies...{NC}\n')
    
    packages = [
        ('numpy', 'NumPy (numerical computing)'),
        ('matplotlib', 'Matplotlib (plotting)'),
    ]
    
    installed = []
    to_install = []
    
    # Check what's installed
    for pkg_name, display_name in packages:
        print(f'  Checking {display_name}... ', end='', flush=True)
        if check_package(pkg_name):
            print(f'{GREEN}✓{NC}')
            installed.append(display_name)
        else:
            print(f'{YELLOW}missing{NC}')
            to_install.append((pkg_name, display_name))
    
    # Summary
    print(f'\n{BOLD}Summary:{NC}')
    print(f'  Installed: {len(installed)}/{len(packages)}')
    print(f'  Missing:   {len(to_install)}/{len(packages)}')
    
    # Install missing packages
    if to_install:
        print(f'\n{YELLOW}Installing missing packages...{NC}')
        
        # Upgrade pip first
        print(f'\n{DIM}Upgrading pip...{NC}')
        upgrade_pip()
        
        # Install each package
        for pkg_name, display_name in to_install:
            if not install_package(pkg_name, display_name):
                print(f'\n{RED}Failed to install {display_name}{NC}')
                print(f'{DIM}Try manually: pip install {pkg_name}{NC}')
                print(f'{DIM}Or: python3 -m pip install {pkg_name}{NC}')
                return False
        
        print(f'\n{GREEN}{BOLD}All packages installed successfully{NC}\n')
    else:
        print(f'\n{GREEN}{BOLD}All packages already installed{NC}\n')
    
    return True

# ========== VISUAL DEMO ==========
def draw_green_square():
    """Draw a green square using matplotlib"""
    print(f'{BOLD}Generating visual output...{NC}\n')
    
    # Import after ensuring packages are installed
    try:
        import numpy as np
        import matplotlib.pyplot as plt
    except ImportError as e:
        print(f'{RED}Import failed: {e}{NC}')
        return False
    
    # Create figure
    fig, ax = plt.subplots(figsize=(6, 6), facecolor='#1a1a1a')
    ax.set_facecolor('#1a1a1a')
    
    # Draw green square
    square = plt.Rectangle((0.25, 0.25), 0.5, 0.5, 
                           facecolor='#00ff00', 
                           edgecolor='#00cc00', 
                           linewidth=3)
    ax.add_patch(square)
    
    # Style
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Title
    fig.suptitle('MatLabC++ Visual Demo', 
                 fontsize=20, 
                 fontweight='bold', 
                 color='#00ff00',
                 y=0.95)
    
    # Subtitle
    ax.text(0.5, 0.1, 'Self-Installation Complete', 
           ha='center', 
           va='center', 
           fontsize=14, 
           color='#ffffff',
           style='italic')
    
    # Show with animation
    print(f'  {GREEN}✓{NC} Rendering green square...')
    time.sleep(0.3)
    
    print(f'  {GREEN}✓{NC} Applying visual styles...')
    time.sleep(0.3)
    
    print(f'  {GREEN}✓{NC} Opening display window...\n')
    time.sleep(0.3)
    
    plt.tight_layout()
    plt.show()
    
    return True

# ========== ADVANCED DEMO ==========
def draw_animated_green_square():
    """Draw animated green square with pulsing effect"""
    print(f'{BOLD}Generating animated visual...{NC}\n')
    
    try:
        import numpy as np
        import matplotlib.pyplot as plt
        import matplotlib.animation as animation
    except ImportError as e:
        print(f'{RED}Import failed: {e}{NC}')
        return False
    
    # Create figure
    fig, ax = plt.subplots(figsize=(8, 8), facecolor='#0a0a0a')
    ax.set_facecolor('#0a0a0a')
    
    # Initial square
    square = plt.Rectangle((0.25, 0.25), 0.5, 0.5, 
                           facecolor='#00ff00', 
                           edgecolor='#00cc00', 
                           linewidth=3)
    ax.add_patch(square)
    
    # Style
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Title
    title = fig.suptitle('MatLabC++ Visual Demo', 
                        fontsize=20, 
                        fontweight='bold', 
                        color='#00ff00',
                        y=0.95)
    
    # Status text
    status_text = ax.text(0.5, 0.1, 'Initializing...', 
                         ha='center', 
                         va='center', 
                         fontsize=14, 
                         color='#00ff00',
                         style='italic')
    
    # Animation function
    def animate(frame):
        # Pulsing effect
        pulse = 0.02 * np.sin(frame * 0.2)
        size = 0.5 + pulse
        offset = (1 - size) / 2
        
        # Update square
        square.set_xy((offset, offset))
        square.set_width(size)
        square.set_height(size)
        
        # Update color intensity
        intensity = int(200 + 55 * np.sin(frame * 0.1))
        color = f'#{0:02x}{intensity:02x}{0:02x}'
        square.set_facecolor(color)
        
        # Update status
        statuses = [
            'Self-Installation Complete',
            'All Systems Operational',
            'Ready for Computation',
            'MatLabC++ Active'
        ]
        status_text.set_text(statuses[(frame // 30) % len(statuses)])
        
        return square, status_text
    
    # Show animation info
    print(f'  {GREEN}✓{NC} Creating animation frames...')
    time.sleep(0.3)
    print(f'  {GREEN}✓{NC} Applying pulsing effect...')
    time.sleep(0.3)
    print(f'  {GREEN}✓{NC} Starting animation...\n')
    time.sleep(0.3)
    
    # Create animation
    anim = animation.FuncAnimation(fig, animate, frames=200, 
                                  interval=50, blit=True)
    
    plt.tight_layout()
    plt.show()
    
    return True

# ========== MAIN ==========
def main():
    """Main entry point"""
    show_banner()
    
    # Ensure packages are installed
    if not ensure_packages():
        print(f'\n{RED}Setup failed. Cannot continue.{NC}')
        print(f'\n{BOLD}Try manually:${NC}')
        print(f'  {CYAN}pip install numpy matplotlib{NC}')
        print(f'  {CYAN}python3 -m pip install numpy matplotlib{NC}')
        sys.exit(1)
    
    # Wait a moment
    time.sleep(0.5)
    
    # Show success
    print(f'{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}')
    print(f'{GREEN}{BOLD}Setup Complete{NC}')
    print(f'{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}\n')
    
    # Ask user preference (with auto-select)
    print(f'{BOLD}Choose visualization:{NC}')
    print(f'  {CYAN}1.{NC} Static green square')
    print(f'  {CYAN}2.{NC} Animated green square (pulsing) {DIM}[recommended]{NC}')
    print()
    
    try:
        choice = input(f'{BOLD}Enter choice [1/2, default=2]:{NC} ').strip()
    except (KeyboardInterrupt, EOFError):
        choice = '2'  # Default on Ctrl+D or Ctrl+C during input
        print()
    
    # Run demo
    success = False
    if choice == '1':
        success = draw_green_square()
    else:
        success = draw_animated_green_square()
    
    # Final message
    if success:
        print(f'\n{GREEN}{BOLD}Demo complete{NC}')
        print(f'{DIM}All dependencies self-installed and verified{NC}\n')
    else:
        print(f'\n{YELLOW}Demo completed with issues{NC}\n')

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print(f'\n\n{YELLOW}Interrupted by user{NC}')
        sys.exit(0)
    except Exception as e:
        print(f'\n{RED}Error: {e}{NC}')
        import traceback
        traceback.print_exc()
        sys.exit(1)
