# Visual Demos

Self-installing visual demonstrations with automatic package management.

Intent: Show how MatLabC++ handles dependencies and renders graphics.

---

## Quick Start

### One Command

```bash
# Interactive menu
./demos/run_demo.sh

# Or specific version
./demos/run_demo.sh --python          # Python with matplotlib
./demos/run_demo.sh --cpp             # C++ static
./demos/run_demo.sh --cpp-animate     # C++ animated
```

### Python Demo (Recommended)

```bash
# Auto-installs numpy and matplotlib if missing
python3 demos/self_install_demo.py
```

### C++ Demo

```bash
# Compile once
g++ -std=c++17 -O2 -pthread demos/green_square_demo.cpp -o demos/green_square_demo

# Run
./demos/green_square_demo              # Static
./demos/green_square_demo --animate    # Animated
```

---

## Features

### Self-Installation

**Python demo:**
- Automatically detects missing packages
- Installs numpy and matplotlib via pip
- Shows progress bars during installation
- No user input required

**C++ demo:**
- Checks for OpenGL libraries
- Provides install commands if missing
- Falls back to ASCII rendering
- No runtime dependencies

### Visual Output

**Python (matplotlib):**
- Green square on black background
- Animated pulsing effect
- Professional rendering
- ~6x6 inch window

**C++ (ASCII):**
- Terminal-based green square
- Optional pulsing animation
- Works over SSH
- No GUI required

---

## Python Demo Details

### What It Does

1. **Checks** for numpy and matplotlib
2. **Installs** missing packages automatically
3. **Shows** progress bars during installation
4. **Renders** green square with matplotlib
5. **Animates** pulsing effect (optional)

### Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MatLabC++ Self-Installing Visual Demo
Automatic package detection and installation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checking dependencies...

  Checking NumPy (numerical computing)... missing
  Checking Matplotlib (plotting)... missing

Summary:
  Installed: 0/2
  Missing:   2/2

Installing missing packages...

Installing NumPy (numerical computing)...
  NumPy [████████████████████████████████████████] 100% ✓

Installing Matplotlib (plotting)...
  Matplotlib [█████████████████████████████████████] 100% ✓

All packages installed successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Setup Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Choose visualization:
  1. Static green square
  2. Animated green square (pulsing)

Enter choice [1/2, default=2]: 2

Generating animated visual...

  ✓ Creating animation frames...
  ✓ Applying pulsing effect...
  ✓ Starting animation...

[Matplotlib window opens with pulsing green square]
```

### Code Structure

```python
# Package management
check_package(name)           # Check if installed
install_package(name)         # Install with pip
ensure_packages()             # Ensure all deps

# Visual rendering
draw_green_square()           # Static square
draw_animated_green_square()  # Pulsing animation
```

---

## C++ Demo Details

### What It Does

1. **Checks** for OpenGL libraries
2. **Compiles** if binary doesn't exist
3. **Renders** ASCII art green square
4. **Animates** pulsing effect (optional)

### Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MatLabC++ Visual Demo - Green Square
Self-installing with OpenGL rendering
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checking dependencies...

  Checking OpenGL... ✓ (Mesa/NVIDIA)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Setup Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rendering green square...

  Initializing OpenGL context [███████████████████] 100% ✓
  Compiling shaders [█████████████████████████████] 100% ✓
  Creating vertex buffers [████████████████████████] 100% ✓
  Setting up viewport [███████████████████████████] 100% ✓
  Rendering frame [████████████████████████████████] 100% ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                                                 
                      ████████████████████                       
                      ████████████████████                       
                      ████████████████████                       
                      ████████████████████                       
                      ████████████████████                       
                      ████████████████████                       
                      ████████████████████                       
                      ████████████████████                       
                      ████████████████████                       
                      ████████████████████                       
                                                                 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                  MatLabC++ Visual Demo Active                   
                     All Systems Operational                      

Tip: Run with --animate for animation
```

### Animated Version

```bash
./demos/green_square_demo --animate
```

Shows pulsing square that grows and shrinks in the terminal.

---

## Comparison

| Feature | Python | C++ |
|---------|--------|-----|
| **Auto-install** | Yes (pip) | No (suggests commands) |
| **Dependencies** | numpy, matplotlib | None (ASCII) or OpenGL |
| **Rendering** | High-quality | ASCII art |
| **Animation** | Smooth | Terminal-based |
| **SSH-friendly** | No (needs X11) | Yes (ASCII) |
| **Speed** | Slow startup | Instant |
| **File size** | ~8 KB | ~150 KB (compiled) |

---

## Installation Behavior

### Python Demo

**First run:**
```bash
python3 demos/self_install_demo.py
# Installs numpy + matplotlib (takes 30-60 seconds)
# Then shows green square
```

**Subsequent runs:**

```bash
python3 demos/self_install_demo.py
# Instant (packages already installed)
```

### C++ Demo

**First run:**
```bash
./demos/run_demo.sh --cpp
# Compiles demo (takes 2-3 seconds)
# Then shows green square
```

**Subsequent runs:**
```bash
./demos/green_square_demo
# Instant (already compiled)
```

---

## Use Cases

### Python Demo

**Use when:**
- Want high-quality graphics
- Have internet connection (for pip)
- Can wait for package installation
- Want matplotlib demonstration

### C++ Demo

**Use when:**
- No internet connection
- Over SSH without X11 forwarding
- Want instant execution
- Don't want to install packages
- Teaching C++ integration

---

## Troubleshooting

### Python: Package installation fails

```bash
# Upgrade pip
python3 -m pip install --upgrade pip

# Install manually
pip install numpy matplotlib

# Run demo again
python3 demos/self_install_demo.py
```

### C++ Compilation fails

```bash
# Install compiler
sudo apt install g++         # Ubuntu/Debian
brew install gcc             # macOS

# Compile manually
g++ -std=c++17 -O2 -pthread demos/green_square_demo.cpp -o demos/green_square_demo
```

### OpenGL missing

**Linux:**
```bash
sudo apt install libgl1-mesa-dev    # Ubuntu/Debian
sudo dnf install mesa-libGL-devel   # Fedora
```

**Note:** C++ demo falls back to ASCII if OpenGL missing.

---

## Advanced Usage

### Python: Customize square

Edit `draw_animated_green_square()` in `self_install_demo.py`:

```python
# Change color
square.set_facecolor('#ff0000')  # Red instead of green

# Change size
square = plt.Rectangle((0.1, 0.1), 0.8, 0.8, ...)  # Larger

# Change pulse speed
pulse = 0.02 * np.sin(frame * 0.5)  # Faster
```

### C++: Customize output

Edit `draw_ascii_square()` in `green_square_demo.cpp`:

```cpp
// Change color (use RED instead)
std::cout << BOLD << RED << "█" << NC;

// Change size
for (int j = 0; j < 30; j++) { ... }  // Wider square
```

---

## Files

| File | Purpose | Size |
|------|---------|------|
| `demos/self_install_demo.py` | Python demo | ~8 KB |
| `demos/green_square_demo.cpp` | C++ source | ~7 KB |
| `demos/run_demo.sh` | Launcher script | ~3 KB |
| `demos/green_square_demo` | Compiled binary | ~150 KB |

---

## See Also

- **scripts/fancy_install.sh** - Fancy installation scripts
- **scripts/ultra_fancy_build.sh** - Animated build system
- **tools/bundle_installer.cpp** - C++ installer

---

**Self-installing demos. No manual setup. Just works.**

Two implementations. Same goal. Zero excuses. 🟩✨
