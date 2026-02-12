# 🔧 WSL Graphics Environment Setup Guide
## OpenGL Support for MatLabC++ Visualization

**Target:** Debian 13 / WSL 2.7.3  
**Goal:** Enable OpenGL rendering for future sphere visualization  
**Status:** SETUP REQUIRED  

---

## 📋 Current State Assessment

### Environment Detection

Run these commands to assess your current WSL setup:

```bash
# 1. Check WSL version
wsl --version

# 2. Check distribution
cat /etc/os-release

# 3. Check display environment
echo $DISPLAY

# 4. Check OpenGL
glxinfo 2>&1 | grep "OpenGL version"

# 5. Check X11
which xeyes

# 6. Check PowerShell version
pwsh --version 2>/dev/null || echo "PowerShell Core not installed"
```

**Expected Issues:**
- `$DISPLAY` is empty → No X server configured
- `glxinfo: command not found` → Graphics libraries not installed
- `xeyes: command not found` → X11 apps not installed
- PowerShell version confusion → Need PowerShell 7.x, not "2.7"

---

## 🚀 Phase 1: Install Required Packages

### Step 1: Update System

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### Step 2: Install X11 and Graphics Libraries

```bash
# X11 basic support
sudo apt-get install -y \
    x11-apps \
    mesa-utils \
    libx11-dev

# OpenGL development libraries
sudo apt-get install -y \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libglew-dev \
    freeglut3-dev

# GLFW (modern window management)
sudo apt-get install -y \
    libglfw3-dev \
    libglfw3

# GLM (math library for OpenGL)
sudo apt-get install -y \
    libglm-dev

# Additional useful tools
sudo apt-get install -y \
    vulkan-tools \
    mesa-vulkan-drivers
```

### Step 3: Install PowerShell Core (7.x)

```bash
# Download PowerShell 7.4
cd /tmp
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb

# Install
sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb
sudo apt-get install -f -y

# Verify
pwsh --version
# Should output: PowerShell 7.4.0
```

---

## 🖥️ Phase 2: Configure Display Server

### Option A: Windows 11 with WSLg (Recommended)

**Check if you have WSLg:**
```bash
# In PowerShell (Windows):
wsl --version

# Look for:
# WSL version: 2.1.0 or higher
# Kernel version: 5.15.x or higher
```

**If you have WSL 2.1+:**
```bash
# WSLg is built-in! Just verify:
echo $DISPLAY
# Should show: :0

# Test X11:
xeyes
# Should display eyes following cursor

# Test OpenGL:
glxgears
# Should display spinning gears
```

**If WSLg works:** Skip to Phase 3! ✅

### Option B: Windows 10 or WSLg Not Available

**Install VcXsrv X Server:**

1. **Download VcXsrv:**
   - URL: https://sourceforge.net/projects/vcxsrv/
   - Download: vcxsrv-64.*.setup.exe
   - Install to default location

2. **Launch VcXsrv:**
   ```
   Start Menu → VcXsrv → XLaunch
   
   Settings:
   - Display settings: Multiple windows
   - Client startup: Start no client
   - Extra settings: 
     ✓ Disable access control
     ✓ Native opengl (optional)
   - Save configuration (optional)
   ```

3. **Configure WSL:**
   ```bash
   # Add to ~/.bashrc
   echo 'export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk "{print \$2}"):0' >> ~/.bashrc
   echo 'export LIBGL_ALWAYS_INDIRECT=1' >> ~/.bashrc
   
   # Reload
   source ~/.bashrc
   
   # Verify
   echo $DISPLAY
   # Should show something like: 172.24.32.1:0
   ```

4. **Test Connection:**
   ```bash
   # Test X11
   xeyes &
   # Eyes should appear in Windows
   
   # Test OpenGL
   glxgears
   # Gears should spin (may be slow - software rendering)
   ```

### Option C: X410 (Premium, Better Performance)

**Alternative to VcXsrv:**
1. Purchase X410 from Microsoft Store (~$10)
2. Launch X410
3. Configure same as VcXsrv (simpler interface)

---

## 🔍 Phase 3: Verify Installation

### Test Script

Save as `test_graphics.sh`:

```bash
#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  WSL Graphics Environment Test                                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 NOT installed"
        return 1
    fi
}

# Test commands
echo "Command Availability:"
test_command glxinfo
test_command glxgears
test_command xeyes
test_command pwsh

echo ""
echo "Environment Variables:"
if [ -z "$DISPLAY" ]; then
    echo -e "${RED}✗${NC} DISPLAY not set"
else
    echo -e "${GREEN}✓${NC} DISPLAY=$DISPLAY"
fi

echo ""
echo "OpenGL Information:"
if command -v glxinfo &> /dev/null; then
    GL_VERSION=$(glxinfo 2>&1 | grep "OpenGL version" | cut -d: -f2 | xargs)
    if [ -z "$GL_VERSION" ]; then
        echo -e "${RED}✗${NC} OpenGL not available"
    else
        echo -e "${GREEN}✓${NC} OpenGL version: $GL_VERSION"
    fi
    
    GL_RENDERER=$(glxinfo 2>&1 | grep "OpenGL renderer" | cut -d: -f2 | xargs)
    echo "  Renderer: $GL_RENDERER"
    
    DIRECT=$(glxinfo 2>&1 | grep "direct rendering" | cut -d: -f2 | xargs)
    echo "  Direct rendering: $DIRECT"
fi

echo ""
echo "Graphics Libraries:"
test_command glxinfo && echo "  (mesa-utils)"
pkg-config --exists glfw3 && echo -e "${GREEN}✓${NC} GLFW3 installed" || echo -e "${RED}✗${NC} GLFW3 NOT installed"
pkg-config --exists glew && echo -e "${GREEN}✓${NC} GLEW installed" || echo -e "${RED}✗${NC} GLEW NOT installed"
pkg-config --exists glm && echo -e "${GREEN}✓${NC} GLM installed" || echo -e "${RED}✗${NC} GLM NOT installed"

echo ""
echo "Test X11 connection:"
if [ ! -z "$DISPLAY" ]; then
    echo "  Running: xeyes (close window to continue)"
    timeout 5 xeyes 2>/dev/null && echo -e "${GREEN}✓${NC} X11 working!" || echo -e "${YELLOW}⚠${NC} X11 connection issue"
else
    echo -e "${RED}✗${NC} Cannot test - DISPLAY not set"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Test complete!"
```

**Run test:**
```bash
chmod +x test_graphics.sh
./test_graphics.sh
```

**Expected Output (Success):**
```
✓ glxinfo installed
✓ glxgears installed
✓ xeyes installed
✓ pwsh installed

✓ DISPLAY=:0

✓ OpenGL version: 4.6 (or similar)
  Renderer: Mesa (software or hardware)
  Direct rendering: Yes

✓ GLFW3 installed
✓ GLEW installed
✓ GLM installed

✓ X11 working!
```

---

## 🐛 Troubleshooting

### Issue 1: "DISPLAY not set"

**Symptom:**
```bash
$ echo $DISPLAY
# (empty)
```

**Solution for WSLg (Windows 11):**
```bash
# Update WSL
wsl --update

# Restart WSL
wsl --shutdown
# Then reopen WSL
```

**Solution for VcXsrv (Windows 10):**
```bash
# Make sure VcXsrv is running in Windows

# Set DISPLAY manually
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0

# Add to ~/.bashrc to persist
echo 'export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk "{print \$2}"):0' >> ~/.bashrc
```

### Issue 2: "cannot open display"

**Symptom:**
```bash
$ xeyes
Error: Cannot open display
```

**Check:**
1. VcXsrv is running in Windows
2. Windows Firewall allows VcXsrv
3. DISPLAY is set correctly

**Fix Firewall:**
```powershell
# In PowerShell (Windows) as Administrator:
New-NetFirewallRule -DisplayName "WSL X Server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 6000
```

### Issue 3: "glxinfo: command not found"

**Solution:**
```bash
sudo apt-get install -y mesa-utils
```

### Issue 4: Software Rendering (Slow)

**Symptom:**
```bash
$ glxinfo | grep "direct rendering"
direct rendering: No
```

**Solutions:**

**For WSLg:**
```bash
# Update GPU drivers on Windows
# Then update WSL:
wsl --update
```

**For VcXsrv:**
```
# In VcXsrv settings:
- Enable "Native opengl"
- Enable "Disable access control"
- Restart VcXsrv
```

**Note:** Software rendering is SLOW but functional for development.

### Issue 5: Library Not Found Errors

**Symptom:**
```bash
error while loading shared libraries: libGL.so.1
```

**Solution:**
```bash
# Install missing libraries
sudo apt-get install -y \
    libgl1-mesa-glx \
    libglu1-mesa \
    libglew2.1

# Update library cache
sudo ldconfig
```

---

## 📦 Complete Installation Script

Save as `install_graphics.sh`:

```bash
#!/bin/bash

set -e  # Exit on error

echo "═══════════════════════════════════════════════════════════════"
echo "  MatLabC++ Graphics Environment Setup for WSL"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Update system
echo "[1/5] Updating system..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq

# Install X11 and OpenGL
echo "[2/5] Installing graphics libraries..."
sudo apt-get install -y -qq \
    x11-apps \
    mesa-utils \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libglew-dev \
    freeglut3-dev \
    libglfw3-dev \
    libglm-dev \
    vulkan-tools

# Install PowerShell
echo "[3/5] Installing PowerShell Core..."
if ! command -v pwsh &> /dev/null; then
    cd /tmp
    wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb
    sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb 2>/dev/null || true
    sudo apt-get install -f -y -qq
    rm powershell_7.4.0-1.deb_amd64.deb
    echo "  PowerShell installed: $(pwsh --version)"
else
    echo "  PowerShell already installed: $(pwsh --version)"
fi

# Configure DISPLAY
echo "[4/5] Configuring display..."
if grep -q "export DISPLAY=" ~/.bashrc; then
    echo "  DISPLAY already configured in ~/.bashrc"
else
    echo 'export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk "{print \$2}"):0' >> ~/.bashrc
    echo '  Added DISPLAY to ~/.bashrc'
fi

source ~/.bashrc

# Test installation
echo "[5/5] Testing installation..."
echo ""
echo "Installed packages:"
dpkg -l | grep -E "(libgl|glfw|glew|glm)" | awk '{print "  " $2 " - " $3}'

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Installation Complete!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Start VcXsrv in Windows (if using Windows 10)"
echo "  2. Restart WSL terminal: exit and reopen"
echo "  3. Run test: xeyes"
echo "  4. Run test: glxgears"
echo ""
```

**Run installer:**
```bash
chmod +x install_graphics.sh
./install_graphics.sh
```

---

## 🎯 Summary

### What We Installed

| Component | Purpose | Size |
|-----------|---------|------|
| X11 apps | Testing (xeyes, xclock) | ~5 MB |
| mesa-utils | OpenGL testing (glxgears, glxinfo) | ~2 MB |
| OpenGL libs | Development headers | ~50 MB |
| GLFW | Window management | ~1 MB |
| GLEW | OpenGL extensions | ~2 MB |
| GLM | Math library | ~1 MB |
| PowerShell 7 | Cross-platform PowerShell | ~60 MB |

**Total:** ~120 MB

### Verification Checklist

- [ ] `glxinfo` shows OpenGL version
- [ ] `xeyes` displays eyes in Windows
- [ ] `glxgears` shows spinning gears
- [ ] `pwsh --version` shows 7.x
- [ ] `echo $DISPLAY` shows value (not empty)
- [ ] `pkg-config --modversion glfw3` shows version

### Next Steps

1. ✅ Graphics environment ready
2. ⏭️ Wait for MatLabC++ v0.4.0 with OpenGL support
3. ⏭️ Or contribute OpenGL implementation to v0.3.1

---

**Document Created:** 2026-01-23  
**Last Updated:** 2026-01-23  
**Status:** READY FOR EXECUTION  

