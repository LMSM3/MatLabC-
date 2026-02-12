# 🎉 BUILD NOW! - Open Terminal and Run

---

## ⚡ FASTEST WAY (30 seconds)

### Linux / macOS

Open terminal in project directory and run:

```bash
chmod +x launch_build.sh && ./launch_build.sh
```

This opens a new window and builds everything automatically!

### Windows

Double-click `launch_build.bat` OR open Command Prompt and run:

```cmd
launch_build.bat
```

---

## 📝 Manual Build (If Launcher Doesn't Work)

### Linux / macOS

```bash
# 1. Make scripts executable
chmod +x setup_project.sh build.sh

# 2. Setup and build
./setup_project.sh
./build.sh install

# 3. Test
export PATH="$HOME/.local/bin:$PATH"
mlab++ --version
```

### Windows

```cmd
REM Open "Developer Command Prompt for VS 2019" or MinGW terminal

REM 1. Setup and build
setup_project.bat
build.bat install

REM 2. Test
set PATH=%USERPROFILE%\.local\bin;%PATH%
mlab++ --version
```

---

## ✅ What Happens

1. **Setup** - Creates directories and stub files (5 seconds)
2. **Configure** - Runs CMake (10 seconds)
3. **Build** - Compiles code (30-90 seconds)
4. **Install** - Installs to ~/.local (5 seconds)
5. **Done** - `mlab++` ready to use!

---

## 🎯 After Build

```bash
# Install packages
mlab++ pkg install materials_smart plotting

# Run demo
mlab++ matlab_examples/basic_demo.m

# Interactive mode
mlab++
```

---

## 📚 Documentation

- **READY_TO_BUILD.md** - Complete instructions
- **BUILD_QUICKSTART.md** - Quick reference
- **BUILD.md** - Detailed guide

---

**Ready? Open terminal and build now!** 🚀
