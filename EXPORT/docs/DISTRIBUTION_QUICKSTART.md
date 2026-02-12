# 📦 Distribution Quick Reference

**30-second guide to creating and using MatLabC++ example bundles**

---

## 🚀 For Maintainers (Create Bundles)

### Generate Both Formats

```bash
./scripts/generate_examples_zip.sh      # ZIP (universal)
./scripts/generate_examples_bundle.sh   # Shell (Unix)
```

**Output:**
- `dist/matlabcpp_examples_v0.3.0.zip` (~50 KB)
- `dist/mlabpp_examples_bundle.sh` (~50 KB)

### Distribute

```bash
# Upload to web
scp dist/*.{zip,sh} server:/var/www/downloads/

# Email (ZIP only)
# Attach: dist/matlabcpp_examples_v0.3.0.zip

# Share link
https://yoursite.com/matlabcpp_examples_v0.3.0.zip
```

---

## 📥 For End Users (Install)

### Windows (ZIP)

```
1. Download: matlabcpp_examples_v0.3.0.zip
2. Right-click → "Extract All..."
3. Open folder
4. Run: mlab++ basic_demo.m
```

### macOS (ZIP)

```bash
# Double-click to extract, then:
cd matlabcpp_examples
./install.sh
mlab++ basic_demo.m
```

### Linux (Shell - Fast!)

```bash
wget https://site.com/mlabpp_examples_bundle.sh
bash mlabpp_examples_bundle.sh
cd examples
mlab++ basic_demo.m
```

### Linux (ZIP - Also works)

```bash
wget https://site.com/matlabcpp_examples_v0.3.0.zip
unzip matlabcpp_examples_v0.3.0.zip
cd matlabcpp_examples
bash install.sh
mlab++ basic_demo.m
```

---

## 🎯 Quick Decisions

**Choose ZIP if:**
- Distributing to Windows users
- Sending via email
- Want universal compatibility
- Targeting beginners

**Choose Shell if:**
- Linux/macOS only
- Targeting developers
- Want one-command install
- Comfortable with terminal

**Provide both if:**
- Mixed audience
- Public release
- Maximum compatibility

---

## ✅ What's Included

Both bundles contain:

```
✓ basic_demo.m              # Intro
✓ test_math_accuracy.m      # Tests
✓ materials_lookup.m        # Database
✓ engineering_report_demo.m # Plots
✓ README.txt                # Instructions
✓ install.bat/install.sh    # Helpers
```

**Total:** 10 examples, ~50 KB compressed

---

## 🧪 Quick Test

```bash
# Generate
./scripts/generate_examples_zip.sh

# Test
cd /tmp
unzip /path/to/dist/matlabcpp_examples_v0.3.0.zip
ls matlabcpp_examples/
# Should see: basic_demo.m, README.txt, etc.
```

---

## 🔧 Quick Customization

**Add new example:**
```bash
vim matlab_examples/my_demo.m
./scripts/generate_examples_zip.sh
# Now included!
```

**Change version:**
```bash
# Edit VERSION="0.3.0" in:
# - scripts/generate_examples_zip.sh
# - scripts/generate_examples_bundle.sh
```

---

## 💡 Common Commands

### Maintainer Workflow

```bash
# 1. Update examples
vim matlab_examples/*.m

# 2. Regenerate bundles
./scripts/generate_examples_zip.sh
./scripts/generate_examples_bundle.sh

# 3. Verify
ls -lh dist/

# 4. Upload
scp dist/*.{zip,sh} server:/var/www/
```

### User Workflow (Windows)

```cmd
REM 1. Download
curl -O https://site.com/matlabcpp_examples_v0.3.0.zip

REM 2. Extract
tar -xf matlabcpp_examples_v0.3.0.zip

REM 3. Install
cd matlabcpp_examples
install.bat

REM 4. Use
mlab++ basic_demo.m
```

### User Workflow (Linux)

```bash
# 1. Download & install
wget https://site.com/mlabpp_examples_bundle.sh
bash mlabpp_examples_bundle.sh

# 2. Use
cd examples
mlab++ basic_demo.m
```

---

## 🆘 Quick Troubleshooting

**"Cannot open ZIP"**
→ Ensure ZIP format: `file bundle.zip`

**"Permission denied"**
→ Make executable: `chmod +x install.sh`

**"Command not found"**
→ Ensure mlab++ installed: `mlab++ --version`

**Windows: "Script blocked"**
→ Use ZIP format instead of shell

---

## 📊 Platform Summary

| Platform | Format | Command |
|----------|--------|---------|
| Windows | ZIP | Right-click → Extract |
| macOS | ZIP or Shell | `unzip` or `bash` |
| Linux | ZIP or Shell | `unzip` or `bash` |

---

## 📖 Full Documentation

- **scripts/README.md** - Complete guide
- **DISTRIBUTION_COMPARISON.md** - Format comparison
- **EXAMPLES_BUNDLE.md** - User documentation

---

**Quick. Simple. Works everywhere.** 📦✨

**Generate:** `./scripts/generate_examples_zip.sh`  
**Distribute:** Upload/email ZIP file  
**Install:** Extract and run

**Done!** 🎉
