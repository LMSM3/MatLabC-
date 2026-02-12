# 🧹 MatLabC++ Directory Cleanup & Organization Guide

**Problem:** Root directory is cluttered with 40+ markdown files and confusing build structure.

**Solution:** Simple organization with clear locations for everything.

---

## 🎯 Quick Fix (Do This Now!)

### Step 1: Navigate to Project Root
```bash
# Make sure you're in the right place
cd /mnt/c/Users/Liam/Desktop/MatLabC++
pwd
# Should show: /mnt/c/Users/Liam/Desktop/MatLabC++
```

### Step 2: Clean Build Directory
```bash
# Close any terminals that are in the build directory
# Then from project root:
rm -rf build
mkdir build
```

### Step 3: Run Build Script from ROOT
```bash
# Make sure you're in project root (see Step 1)
./build_and_setup.sh
```

**That's it!** The script will:
- Create a clean build/ directory
- Configure CMake
- Build everything
- Create build/mlab++ executable

---

## 📁 Proper Directory Structure

### Current (Messy):
```
MatLabC++/
├── 40+ .md files in root        ❌ TOO MANY!
├── build/
│   └── build/                   ❌ NESTED!
├── scripts/
└── docs/
```

### Target (Clean):
```
MatLabC++/
├── README.md                    ✓ Main readme
├── GETTING_STARTED.md           ✓ Quick start
├── build_and_setup.sh           ✓ Build script
├── CMakeLists.txt               ✓ Build config
│
├── build/                       ✓ Build artifacts (gitignored)
│   └── mlab++                   ✓ Your executable
│
├── docs/                        ✓ All documentation
│   ├── guides/
│   ├── api/
│   └── reference/
│
├── scripts/                     ✓ Build scripts
│   ├── build_cpp.sh
│   ├── automate_all.sh
│   └── ...
│
├── src/                         ✓ C++ source
├── include/                     ✓ Headers
├── demos/                       ✓ Demo programs
├── examples/                    ✓ Example code
└── tests/                       ✓ Unit tests
```

---

## 🗂️ Organize Documentation

### Keep in Root (5 files max):
- **README.md** - Project overview
- **GETTING_STARTED.md** - Quick start guide
- **CHANGELOG.md** - Version history
- **LICENSE** - License file
- **CMakeLists.txt** - Build config

### Move to docs/:

#### docs/guides/
- QUICK_START_CLI.md
- BUILD_SCRIPTS_GUIDE.md
- FOR_NORMAL_PEOPLE.md
- GETTING_STARTED.md (duplicate)

#### docs/architecture/
- CODEBASE_REVIEW.md
- BUNDLE_ARCHITECTURE.md
- PACKAGE_MANAGEMENT_COMPLETE.md
- PLOTTING_SYSTEM.md

#### docs/tutorials/
- ACTIVE_WINDOW_QUICKSTART.md
- MATH_ACCURACY_QUICKREF.md
- DISTRIBUTION_QUICKSTART.md

#### docs/reference/
- MATERIALS_DATABASE.md
- QUICKREF.md
- BUNDLE_QUICKREF.md

#### docs/development/
- BUILD_AUTOMATION_READY.md
- SYSTEM_STATUS.md
- PRE_FLIGHT_CHECKLIST.md
- AUTOMATION_SUMMARY.md

### Archive (move to docs/archive/):
- All files with "COMPLETE" in the name
- Duplicate READMEs
- Old versions (v0.2.0, etc.)

---

## 🔨 Cleanup Commands

### Automated Cleanup Script:

```bash
#!/bin/bash
# cleanup_docs.sh - Organize documentation

cd /mnt/c/Users/Liam/Desktop/MatLabC++

# Create doc subdirectories
mkdir -p docs/{guides,architecture,tutorials,reference,development,archive}

# Move files (examples - add more as needed)
mv QUICK_START_CLI.md docs/guides/
mv BUILD_SCRIPTS_GUIDE.md docs/guides/
mv CODEBASE_REVIEW.md docs/architecture/
mv MATERIALS_DATABASE.md docs/reference/
mv BUILD_AUTOMATION_READY.md docs/development/

# Archive old/duplicate files
mv *COMPLETE*.md docs/archive/ 2>/dev/null
mv README_NEW.md docs/archive/ 2>/dev/null
mv *v0.2.0*.md docs/archive/ 2>/dev/null

echo "Documentation organized!"
```

### Manual Cleanup:

```bash
# 1. Navigate to project root
cd /mnt/c/Users/Liam/Desktop/MatLabC++

# 2. Create docs structure
mkdir -p docs/{guides,architecture,tutorials,reference,development,archive}

# 3. Move files one category at a time
mv QUICK_START_CLI.md docs/guides/
mv BUILD_SCRIPTS_GUIDE.md docs/guides/
# ... continue for each file

# 4. Verify root is clean
ls *.md
# Should only show: README.md and maybe 2-3 others
```

---

## 🚀 Correct Build Workflow

### Always Work from Project Root:

```bash
# 1. Start here
cd /mnt/c/Users/Liam/Desktop/MatLabC++

# 2. Check you're in the right place
ls -l build_and_setup.sh CMakeLists.txt
# Both should exist

# 3. Run build
./build_and_setup.sh

# 4. Run the program
cd build
./mlab++

# 5. Return to root for next build
cd ..
```

### Common Mistakes:

❌ **Wrong:** Running from build directory
```bash
cd build
./build_and_setup.sh    # FAILS - script not here!
```

✓ **Right:** Running from project root
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
./build_and_setup.sh    # WORKS!
```

❌ **Wrong:** Nested build directories
```bash
cd build/build          # How did this happen?
cmake --build .         # Fails with "could not load cache"
```

✓ **Right:** Single build directory
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
rm -rf build            # Start fresh
./build_and_setup.sh    # Creates build/ correctly
```

---

## 🎯 Essential Files Quick Reference

### For Building:
```
./build_and_setup.sh              # All-in-one build
./scripts/build_cpp.sh            # Simple C++ build
CMakeLists.txt                    # Build configuration
```

### For Using:
```
build/mlab++                      # The executable
docs/guides/QUICK_START_CLI.md    # How to use CLI
examples/                         # Example code
matlab_examples/                  # MATLAB scripts
```

### For Development:
```
src/                              # C++ source code
include/                          # Header files
tests/                            # Unit tests
docs/development/                 # Dev documentation
```

---

## 📝 Create Simple GETTING_STARTED.md

A single, simple file in the root that replaces all the confusion:

```markdown
# Getting Started with MatLabC++

## Build (3 steps)
1. `cd /path/to/MatLabC++`
2. `./build_and_setup.sh`
3. `cd build && ./mlab++`

## Use
- Type `help` for commands
- Type `quit` to exit
- See `docs/guides/QUICK_START_CLI.md` for full guide

## Troubleshoot
- Error? Make sure you're in project root: `pwd`
- Nested builds? Clean: `rm -rf build && ./build_and_setup.sh`
- Need help? See `docs/guides/BUILD_SCRIPTS_GUIDE.md`
```

---

## ✅ After Cleanup Checklist

### Root directory should have:
- [ ] README.md
- [ ] GETTING_STARTED.md (simple!)
- [ ] build_and_setup.sh
- [ ] CMakeLists.txt
- [ ] .gitignore
- [ ] ~5 total .md files (max)

### docs/ directory should have:
- [ ] guides/
- [ ] architecture/
- [ ] tutorials/
- [ ] reference/
- [ ] development/
- [ ] archive/ (for old files)

### Build directory:
- [ ] Does NOT contain a nested build/ directory
- [ ] Contains only CMake artifacts and mlab++
- [ ] Can be deleted and rebuilt without issues

### Scripts directory:
- [ ] All .sh files are executable (chmod +x)
- [ ] build_and_setup.sh is in root
- [ ] Other scripts are in scripts/

---

## 🔄 Quick Reset

If everything is messed up:

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++

# Clean build
rm -rf build

# Run automated build
./build_and_setup.sh

# Test it works
cd build
./mlab++ --version  # or just ./mlab++
```

---

## 📞 Emergency Commands

### I'm lost in directories:
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
pwd  # Verify you're in the right place
```

### Build is broken:
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
rm -rf build
./build_and_setup.sh
```

### Too many files in root:
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
mkdir -p docs/archive
mv *COMPLETE*.md *READY*.md *STATUS*.md docs/archive/
```

### Script won't run:
```bash
chmod +x build_and_setup.sh
./build_and_setup.sh
```

---

## 🎯 Summary

**The Problem:** You were in `build/build` (nested) instead of project root.

**The Solution:**
1. Always work from project root: `/mnt/c/Users/Liam/Desktop/MatLabC++`
2. Run `./build_and_setup.sh` from there
3. Executable will be at `build/mlab++`
4. Move documentation to `docs/` subdirectories

**The Command:**
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++ && ./build_and_setup.sh
```

That's it! 🎉
