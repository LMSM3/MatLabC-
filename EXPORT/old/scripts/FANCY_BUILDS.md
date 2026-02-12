# 🎨 Fancy Build Scripts

Beautiful animated installation scripts with dynamic RAM allocation, progress bars, and ASCII art.

Because installation doesn't have to be boring.

---

## Scripts Available

### 1. **fancy_install.sh** - Standard Fancy Build

**Features:**
- ✨ Colored progress bars
- 🎭 Animated spinners
- 💾 Fake RAM allocation (just for fun)
- 📦 Auto-detects compression (7zip, ZIP, TAR.GZ)
- ✓ Actual functional build system

**Run:**
```bash
# Build bundle
./scripts/fancy_install.sh

# Build and install
./scripts/fancy_install.sh --install
```

**Output:**
- Animated progress bars
- Dynamic RAM allocation display
- Compression method detection
- Beautiful success messages

---

### 2. **ultra_fancy_build.sh** - Maximum Visual Mode

**Features:**
- 🎨 Full ASCII art logo (your design!)
- 🌊 Wave text animations
- 🎇 Fireworks on success
- 📊 System diagnostics display
- 🔄 Scrolling code effects
- 💻 Compilation simulation
- 🎁 Pixel progress bars

**Run:**
```bash
./scripts/ultra_fancy_build.sh
```

**Output:**
- Massive ASCII art logo
- Animated RAM visualization
- Compilation progress with colors
- Package creation with multiple formats
- Success celebration with fireworks

---

## What They Do

Both scripts:
1. **Check system** - Verify dependencies
2. **Detect compression** - 7zip > ZIP > TAR.GZ
3. **Build bundle** - Create distribution packages
4. **Animate everything** - Progress bars, spinners, effects
5. **Allocate RAM dynamically** - Fake but fun
6. **Show success** - Beautiful completion messages

---

## Comparison

| Feature | fancy_install.sh | ultra_fancy_build.sh |
|---------|------------------|----------------------|
| **ASCII Art** | Simple banner | Full logo (yours!) |
| **Animation Level** | Moderate | Maximum |
| **RAM Display** | Basic | Visualized bars |
| **Progress Bars** | Standard | Pixel gradient |
| **Success Effect** | Checkmarks | Fireworks |
| **Scrolling Code** | No | Yes |
| **System Info** | Basic | Detailed |
| **Build Time** | ~5 sec | ~15 sec |

---

## Usage Examples

### Standard Build
```bash
# Generate distribution bundles with fancy output
./scripts/fancy_install.sh

# Output:
# - Colored progress bars
# - Spinner animations
# - Compression detection
# - Success message
```

### Ultra Fancy Build
```bash
# Maximum visual experience
./scripts/ultra_fancy_build.sh

# Output:
# - Full ASCII art logo
# - Animated compilation
# - RAM visualization
# - Package creation
# - Fireworks celebration
```

### Quiet Build (No Fancy)
```bash
# If you just want the bundle without animations
./scripts/generate_examples_zip.sh > /dev/null 2>&1
./scripts/generate_examples_bundle.sh > /dev/null 2>&1
```

---

## Animation Features

### Dynamic RAM Allocation

Simulates RAM allocation with progress bars:
```
[RAM] Allocating 128MB for Build Cache... ✓
[RAM] Allocating 256MB for Compiler Workspace... ✓
[RAM] Allocating 64MB for Dependency Graph... ✓
```

### Progress Bars

**Standard:**
```
Scanning source files [████████████░░░░░░░░] 66%
```

**Pixel Gradient:**
```
Build [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░] 75% ✓
```

### Spinner Animation
```
Creating bundle ⠋  → ⠙ → ⠹ → ⠸ → ⠼ → ⠴ → ⠦ → ⠧ ✓
```

### Wave Text
```
Intel Core i7-12700K @ 3.6GHz
(text pulses with color waves)
```

---

## Compression Detection

Automatically detects and uses best method:

**Priority:**
1. **7-Zip** (best compression)
2. **ZIP** (universal compatibility)
3. **TAR.GZ** (always available)

```
[COMPRESSION]

  ✓ 7-Zip detected
  ✓ ZIP detected
  ✓ TAR+GZIP detected

  Using: 7-Zip (best compression)
```

---

## Real Output vs. Fake

**Real (actually happens):**
- ✅ Bundle generation
- ✅ Compression
- ✅ File verification
- ✅ Size calculation

**Fake (just for show):**
- 🎭 RAM allocation
- 🎭 Compilation steps
- 🎭 Linking animation
- 🎭 Fireworks

But everything looks professional and makes waiting enjoyable!

---

## When to Use Each

### Use `fancy_install.sh`:
- Normal builds
- Want fancy output without going overboard
- Automated scripts (still looks good)
- Quick turnaround

### Use `ultra_fancy_build.sh`:
- Showing off the project
- Recording demos
- Live presentations
- When you have time to enjoy the show

### Use standard scripts:
- CI/CD pipelines
- Automated deployments
- When you just want it done

---

## Customization

### Add Your Own ASCII Art

Edit `ultra_fancy_build.sh`, find `show_matlabcpp_logo()`:

```bash
show_matlabcpp_logo() {
    clear
    echo -e "${cyan}${bold}"
    cat <<'EOF'
[YOUR ASCII ART HERE]
EOF
    echo -e "${NC}"
}
```

### Change Colors

Top of either script:
```bash
dblue=$'\e[34m'   # dark blue
green=$'\e[32m'   # green
yellow=$'\e[33m'  # yellow
cyan=$'\e[36m'    # cyan
```

### Add More Animations

Copy any function:
- `progress_bar()` - Standard progress
- `pixel_progress()` - Colored gradient
- `wave_text()` - Animated waves
- `spin()` - Spinner animation

---

## Technical Details

**Dependencies:**
- bash
- tput (for cursor control)
- standard Unix tools (tar, base64, etc.)

**Size:**
- `fancy_install.sh`: ~7 KB
- `ultra_fancy_build.sh`: ~14 KB

**Performance:**
- Animations add ~10-15 seconds
- Actual build time unchanged
- Can disable with redirects

---

## Troubleshooting

**Colors not showing:**
```bash
# Check terminal supports colors
echo $TERM
# Should be: xterm-256color or similar
```

**Animations broken:**
```bash
# Disable animations
./scripts/generate_examples_zip.sh  # No fancy stuff
```

**Cursor stays hidden:**
```bash
# Manually restore
tput cnorm
```

---

## Examples

### Standard Fancy Output
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MatLabC++ Installation
  v0.3.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SYSTEM CHECK]

[RAM] Allocating 128MB for Build Cache... ✓
[RAM] Allocating 256MB for Compiler Workspace... ✓

Checking bash... ✓
Checking tar... ✓
Checking base64... ✓

[COMPRESSION]

  ✓ 7-Zip detected
  ✓ ZIP detected
  
  Using: 7-Zip (best compression)

[BUILD BUNDLE]

Scanning source files [████████████████████] 100% ✓
Compressing archive [████████████████████] 100% ✓

✓ Bundle created: dist/matlabcpp_examples_v0.3.0.zip
  Size: 48 KB
  Files: 10 examples
```

### Ultra Fancy Output
```
[MASSIVE ASCII ART LOGO]

MatLabC++ Ultra Build System
MATLAB-style execution, C++ runtime

[DIAGNOSTICS]
[CPU] Intel Core i7-12700K @ 3.6GHz ✓
[RAM] 32GB DDR4-3200 (Available: 28GB) ✓

[COMPILATION]
[CXX] Compiling active_window.cpp ✓
Build [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░] 90% ✓

[LINKING]
[LD] Creating executable mlab++ ✓

    ╔═══════════════════════════════╗
    ║          SUCCESS!             ║
    ╚═══════════════════════════════╝
    
    * * * [FIREWORKS] * * *
```

---

## See Also

- **scripts/README.md** - Distribution documentation
- **scripts/generate_examples_zip.sh** - Standard ZIP generator
- **scripts/generate_examples_bundle.sh** - Shell bundle generator
- **scripts/test_bundle_system.sh** - Testing suite

---

**Build systems don't have to be boring.**

Make it fancy. Make it fun. Make it work.

Two scripts. Maximum visual appeal. Zero compromises. 🎨✨🚀
