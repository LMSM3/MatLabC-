# Getting Started with MatLabC++

**Build and run MatLabC++ in 3 simple commands.**

---

## 🚀 Quick Start

```bash
# 1. Navigate to project root
cd /mnt/c/Users/Liam/Desktop/MatLabC++

# 2. Run automated build
./build_and_setup.sh

# 3. Start MatLabC++
cd build && ./mlab++
```

That's it! You're ready to code.

---

## 💻 Using MatLabC++

### First Commands

```matlab
>>> 2 + 2
ans = 4

>>> x = [1, 2, 3, 4, 5]
x = [1.0  2.0  3.0  4.0  5.0]

>>> material pla
Material: PLA (Polylactic Acid)
  Density: 1240 kg/m³

>>> help
[Shows all commands]

>>> quit
[Exit]
```

---

## 🐛 Troubleshooting

### Error: "could not load cache"
**Problem:** You're in the wrong directory.

**Solution:**
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
./build_and_setup.sh
```

### Error: "No such file or directory"
**Problem:** Script not found (wrong directory).

**Solution:**
```bash
# Navigate to project root first
cd /mnt/c/Users/Liam/Desktop/MatLabC++
ls build_and_setup.sh  # Verify it exists
./build_and_setup.sh
```

### Build directory is nested (build/build)
**Problem:** Multiple builds created nested directories.

**Solution:**
```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
rm -rf build
./build_and_setup.sh
```

---

## 📚 Next Steps

- **Full CLI Guide:** `docs/guides/QUICK_START_CLI.md`
- **Build System:** `docs/guides/BUILD_SCRIPTS_GUIDE.md`
- **Project Overview:** `docs/architecture/CODEBASE_REVIEW.md`
- **All Documentation:** `docs/INDEX.md`

---

## 🔄 After Code Changes

Quick rebuild without full cleanup:

```bash
cd build
cmake --build . -j$(nproc)
./mlab++
```

Full rebuild:

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
./build_and_setup.sh
```

---

## ✅ Essential Files

```
MatLabC++/
├── build_and_setup.sh    ← Run this to build
├── CMakeLists.txt        ← Build configuration
├── build/
│   └── mlab++           ← Your executable (after build)
├── docs/                ← All documentation
├── examples/            ← Example code
└── matlab_examples/     ← MATLAB scripts
```

---

**Need help?** See `CLEANUP_AND_ORGANIZE.md` for directory structure and common issues.
