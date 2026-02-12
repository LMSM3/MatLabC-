# MatLabC++ Pre-Flight Checklist

Complete checklist before shipping release.

---

## Automated Verification

### ✅ Run Automated Script

```bash
./scripts/automate_all.sh
```

**This will:**
- Verify system
- Set permissions
- Build components
- Run tests
- Export documentation
- Create release package

**Expected output:**
```
✓ System verification passed
✓ Permissions updated
✓ ZIP bundle
✓ Shell bundle
✓ Bundle system tests passed
✓ Release preparation complete
```

---

## Manual Verification

### 1. Documentation Export

**Check Desktop:**
```bash
ls ~/Desktop/MatLabCpp_Docs/
```

**Should contain:**
- [ ] 00_INDEX.txt
- [ ] 00_Main_README.md
- [ ] 01_User_Guide.md
- [ ] 02-12 numbered .md files

### 2. Release Package

**Check Desktop:**
```bash
ls ~/Desktop/matlabcpp_v0.3.0_release.tar.gz
```

**Extract and verify:**
```bash
cd /tmp
tar -xzf ~/Desktop/matlabcpp_v0.3.0_release.tar.gz
ls
# Should see: dist/ demos/ docs/ RELEASE_INFO.txt
```

### 3. Distribution Bundles

**Check dist directory:**
```bash
ls dist/
```

**Should contain:**
- [ ] matlabcpp_examples_v0.3.0.zip (~50 KB)
- [ ] mlabpp_examples_bundle.sh (~50 KB)

**Test ZIP:**
```bash
unzip -t dist/matlabcpp_examples_v0.3.0.zip
# Should show: No errors detected
```

**Test shell bundle:**
```bash
head -n 20 dist/mlabpp_examples_bundle.sh
# Should show bash script header
grep -q "__PAYLOAD_BELOW__" dist/mlabpp_examples_bundle.sh && echo "✓ Payload marker present"
```

### 4. Demos

**Test Python demo:**
```bash
python3 demos/self_install_demo.py
# Should auto-install packages and show green square
```

**Test C++ demo (if compiled):**
```bash
./demos/green_square_demo
# Should show ASCII green square
```

**Test launcher:**
```bash
./demos/run_demo.sh
# Should show interactive menu
```

### 5. Tools

**Check C++ installer (if built):**
```bash
./tools/bundle_installer --help 2>&1 | head -n5
# Should show usage message
```

### 6. Scripts Executable

**Verify permissions:**
```bash
find scripts tools demos -name "*.sh" -exec test -x {} \; -print
# All scripts should be listed
```

---

## Platform Testing

### Linux

- [ ] Extract ZIP bundle
- [ ] Run shell bundle
- [ ] Execute Python demo
- [ ] Execute C++ demo
- [ ] Test bundle installer

### macOS

- [ ] Double-click ZIP extraction
- [ ] Run shell bundle
- [ ] Python demo works
- [ ] C++ demo compiles

### Windows/WSL

- [ ] Extract ZIP with Explorer
- [ ] Run Python demo
- [ ] Shell bundle in WSL
- [ ] Basic functionality

---

## Documentation Review

### User-Facing Docs

- [ ] README.md - Clear project overview
- [ ] FOR_NORMAL_PEOPLE.md - Beginner-friendly
- [ ] ACTIVE_WINDOW_DEMO.md - Demo instructions
- [ ] EXAMPLES_BUNDLE.md - Distribution guide

### Technical Docs

- [ ] scripts/README.md - Scripts explained
- [ ] tools/INSTALLER.md - Installer guide
- [ ] demos/README.md - Demo documentation

### Quick References

- [ ] DISTRIBUTION_QUICKSTART.md - Quick start
- [ ] DISTRIBUTION_CHEATSHEET.md - Copy-paste commands

---

## Code Quality

### Python

- [ ] demos/self_install_demo.py - Runs without errors
- [ ] scripts/verify_system.py - Passes all checks
- [ ] No syntax errors
- [ ] Proper error handling

### Shell Scripts

- [ ] All scripts use `set -euo pipefail`
- [ ] Proper error messages
- [ ] Clean output formatting
- [ ] Exit codes correct

### C++

- [ ] Compiles without warnings
- [ ] No memory leaks (basic check)
- [ ] Cross-platform compatible
- [ ] Proper error handling

---

## File Checklist

### Required Files

```
MatLabC++/
├── README.md                          ✓
├── FOR_NORMAL_PEOPLE.md               ✓
├── ACTIVE_WINDOW_DEMO.md              ✓
├── MATH_ACCURACY_TESTS.md             ✓
├── MATERIALS_DATABASE.md              ✓
├── EXAMPLES_BUNDLE.md                 ✓
├── DISTRIBUTION_COMPARISON.md         ✓
├── DISTRIBUTION_QUICKSTART.md         ✓
├── DISTRIBUTION_CHEATSHEET.md         ✓
│
├── demos/
│   ├── self_install_demo.py           ✓
│   ├── green_square_demo.cpp          ✓
│   ├── run_demo.sh                    ✓
│   └── README.md                      ✓
│
├── scripts/
│   ├── generate_examples_zip.sh       ✓
│   ├── generate_examples_bundle.sh    ✓
│   ├── test_bundle_system.sh          ✓
│   ├── ship_release.sh                ✓
│   ├── automate_all.sh                ✓
│   ├── verify_system.py               ✓
│   ├── fancy_install.sh               ✓
│   ├── ultra_fancy_build.sh           ✓
│   ├── README.md                      ✓
│   └── FANCY_BUILDS.md                ✓
│
├── tools/
│   ├── bundle_installer.cpp           ✓
│   ├── build_installer.sh             ✓
│   ├── CMakeLists.txt                 ✓
│   └── INSTALLER.md                   ✓
│
├── matlab_examples/
│   ├── basic_demo.m                   ✓
│   ├── materials_lookup.m             ✓
│   ├── test_math_accuracy.m           ✓
│   └── ... (other examples)           ✓
│
└── dist/
    ├── matlabcpp_examples_v0.3.0.zip  ✓
    └── mlabpp_examples_bundle.sh      ✓
```

---

## Final Checks

### Before Distribution

- [ ] All automated checks pass
- [ ] Documentation exported to Desktop
- [ ] Release package created
- [ ] Tested on at least one platform
- [ ] No obvious errors in output
- [ ] Version numbers consistent (v0.3.0)

### Desktop Deliverables

**Check these exist:**
```bash
ls ~/Desktop/MatLabCpp_Docs/                   # Documentation
ls ~/Desktop/matlabcpp_v0.3.0_release.tar.gz  # Release archive
```

### Distribution Readiness

- [ ] ZIP bundle < 100 KB
- [ ] Shell bundle < 100 KB
- [ ] All scripts executable
- [ ] Documentation complete
- [ ] Demos functional

---

## Quick Test Commands

```bash
# Automated full check
./scripts/automate_all.sh

# Manual verification
python3 scripts/verify_system.py

# Test bundles
bash scripts/test_bundle_system.sh

# Test demo
python3 demos/self_install_demo.py

# Build check
bash scripts/generate_examples_zip.sh
bash scripts/generate_examples_bundle.sh

# Permission check
find scripts tools demos -name "*.sh" ! -perm -u+x
# (Should return nothing)
```

---

## Sign-Off

**Before declaring ready to ship, verify:**

- ✅ `./scripts/automate_all.sh` completes successfully
- ✅ Documentation on Desktop
- ✅ Release archive on Desktop
- ✅ All bundles in `dist/`
- ✅ Demos run without errors
- ✅ README files clear and complete

**Final command:**
```bash
./scripts/automate_all.sh && echo "✓ READY TO SHIP"
```

---

**Checklist complete. Ship it.** 🚀
