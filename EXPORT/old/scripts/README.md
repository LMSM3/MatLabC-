# MatLabC++ Scripts Directory

Build automation and distribution tools.

MatLabC++ is MATLAB-style execution backed by a C++ runtime. Same workflow mindset, fewer excuses.

---

## ⚡ Quick Start

### Maintainers: Create Distribution Bundles

```bash
# Generate both formats
./scripts/generate_examples_zip.sh      # ZIP (works everywhere)
./scripts/generate_examples_bundle.sh   # Shell (Unix only)

# Check output
ls -lh dist/
# matlabcpp_examples_v0.3.0.zip    ~50 KB
# mlabpp_examples_bundle.sh        ~50 KB
```

Upload `dist/` contents to wherever you host files. Done.

---

### End Users: Install Examples

**Got a ZIP file?**

```bash
# Windows: Right-click → "Extract All..."
# macOS:   Double-click to extract
# Linux:   unzip matlabcpp_examples_v0.3.0.zip

cd matlabcpp_examples
mlab++ basic_demo.m
```

**Got a shell bundle?**

```bash
# Linux/macOS only
bash mlabpp_examples_bundle.sh
cd examples
mlab++ basic_demo.m
```

That's it. Start coding.

---

## Distribution Methods

### Choose Your Format

| Method | Best For | Platform | Size |
|--------|----------|----------|------|
| **ZIP Bundle** | Windows users, universal | All | ~50 KB |
| **Self-Extracting Shell** | Linux/macOS power users | Unix | ~50 KB |
| **Direct Download** | Quick testing | All | ~20 KB |

---

## ZIP Bundle (Universal)

Universal, predictable, and compatible with environments that treat shells as contraband.

### Generate

```bash
./scripts/generate_examples_zip.sh
```

**Output:** `dist/matlabcpp_examples_v0.3.0.zip`

### Distribute

Upload `dist/matlabcpp_examples_v0.3.0.zip` to any location you control and share the download link.

Via web:
```bash
scp dist/matlabcpp_examples_v0.3.0.zip user@server:/var/www/downloads/
```

Via email: Just attach it. Works on Outlook, Gmail, corporate filters.

### Why ZIP?

✅ Built into Windows/macOS/Linux  
✅ Works with GUI extraction (Explorer/Finder) and CLI tools  
✅ Friendly to email and institutional IT  
✅ Small, auditable, boring in the best way  

### End User Installation

**Windows:**
1. Download `matlabcpp_examples_v0.3.0.zip`
2. Right-click → "Extract All..."
3. Run: `mlab++ basic_demo.m`

**macOS:**
1. Download `matlabcpp_examples_v0.3.0.zip`
2. Double-click to extract
3. Terminal: `cd matlabcpp_examples && mlab++ basic_demo.m`

**Linux:**
```bash
unzip matlabcpp_examples_v0.3.0.zip
cd matlabcpp_examples
mlab++ basic_demo.m
```

### What's Inside

```
matlabcpp_examples_v0.3.0.zip
├── README.txt                      # Plain text instructions
├── basic_demo.m                    # Introduction
├── materials_lookup.m              # Materials database
├── materials_optimization.m        # Optimization example
├── gpu_benchmark.m                 # GPU testing
├── signal_processing.m             # Signal processing
├── linear_algebra.m                # Matrix operations
├── engineering_report_demo.m       # Engineering plots
├── business_dashboard_demo.m       # Business charts
├── test_math_accuracy.m            # Accuracy verification
├── EXAMPLES.md                     # Documentation
├── install.bat                     # Windows helper
└── install.sh                      # Unix helper
```

---

## Self-Extracting Shell Bundle (Unix)

For people who prefer one installer file and trust their own eyes more than "download managers."

### Generate

```bash
./scripts/generate_examples_bundle.sh
```

**Output:** `dist/mlabpp_examples_bundle.sh`

### Distribute

```bash
scp dist/mlabpp_examples_bundle.sh user@server:/var/www/downloads/
```

### End User Installation

```bash
bash mlabpp_examples_bundle.sh
cd examples
mlab++ basic_demo.m
```

### Why Shell Bundle?

✅ One file  
✅ Auto-extract + setup  
✅ Idempotent (safe to run multiple times)  
✅ No dependency on external installers  
✅ Readable script (audit before running)  

---

## Comparison

| Feature | ZIP Bundle | Shell Bundle |
|---------|------------|--------------|
| **Platform** | Windows/macOS/Linux | Linux/macOS/WSL |
| **Skill level** | Beginner-friendly | Terminal-comfortable |
| **Install** | Manual extract | Auto-extract |
| **IT acceptance** | High | Sometimes blocked |
| **Dependencies** | unzip (built-in) | bash + base64 + tar |
| **Email-safe** | Yes | May be filtered |

**Recommendation:** ZIP is primary. Shell bundle is optional for Unix users.

---

## Creating Distribution Bundles

### Generate Both Formats

```bash
./scripts/generate_examples_zip.sh
./scripts/generate_examples_bundle.sh
ls -lh dist/
```

Output:
- `matlabcpp_examples_v0.3.0.zip` (~50 KB)
- `mlabpp_examples_bundle.sh` (~50 KB)

### Customize ZIP Contents

Edit `scripts/generate_examples_zip.sh`:

```bash
#!/usr/bin/env bash
VERSION="0.3.0"
OUTPUT_DIR="dist"
ZIP_NAME="matlabcpp_examples_v${VERSION}.zip"

mkdir -p staging/matlabcpp_examples
cp matlab_examples/*.m staging/matlabcpp_examples/
cp docs/EXAMPLES.md staging/matlabcpp_examples/

cat > staging/matlabcpp_examples/README.txt <<'EOF'
MatLabC++ Examples v0.3.0

Install:
1) Extract the ZIP into a folder
2) Run: mlab++ basic_demo.m

MatLabC++ is MATLAB-style execution backed by a C++ runtime.
Same workflow mindset, fewer excuses.
EOF

cd staging
zip -r "../${OUTPUT_DIR}/${ZIP_NAME}" matlabcpp_examples/
cd ..
rm -rf staging

echo "✓ ZIP bundle created: ${OUTPUT_DIR}/${ZIP_NAME}"
```

---

## Files

### Distribution Scripts

| File | Purpose | Platform |
|------|---------|----------|
| `generate_examples_zip.sh` | Creates ZIP bundle | All |
| `generate_examples_bundle.sh` | Creates shell installer | Unix |

### Output Files

| File | Format | Size |
|------|--------|------|
| `dist/matlabcpp_examples_v0.3.0.zip` | ZIP | ~50 KB |
| `dist/mlabpp_examples_bundle.sh` | Shell | ~50 KB |

### Source Files

| File | Purpose |
|------|---------|
| `mlabpp_examples_bundle.sh` | Shell template (header logic) |
| `../matlab_examples/*.m` | MATLAB-style example scripts |

### Build Scripts

| File | Purpose |
|------|---------|
| `build_cpp.sh` | C++ compilation |
| `setup_all.sh` | Full installation |
| `test_suite.sh` | Run tests |

---

## Usage Examples

### Example 1: Maintainer Workflow

```bash
# Create distributions
cd /path/to/matlabcpp
./scripts/generate_examples_zip.sh
./scripts/generate_examples_bundle.sh

# Upload
scp dist/*.{zip,sh} server:/var/www/downloads/

# Update download page
echo "Examples v0.3.0 available" >> downloads.html
```

### Example 2: Windows User

```cmd
REM Download
curl -O https://site.com/matlabcpp_examples_v0.3.0.zip

REM Extract (command line)
tar -xf matlabcpp_examples_v0.3.0.zip

REM Or: Right-click → Extract All in Explorer

REM Run
cd matlabcpp_examples
mlab++ basic_demo.m
mlab++ test_math_accuracy.m
```

### Example 3: Linux User

```bash
# Download and install (one line)
wget https://site.com/mlabpp_examples_bundle.sh && bash mlabpp_examples_bundle.sh

# Run examples
cd examples
mlab++ basic_demo.m
mlab++  # Start Active Window
```

---

## Testing Before Distribution

### Test ZIP Bundle

```bash
./scripts/generate_examples_zip.sh
cd /tmp
unzip /path/to/dist/matlabcpp_examples_v0.3.0.zip
ls matlabcpp_examples/
test -f matlabcpp_examples/basic_demo.m && echo "✓ OK"
```

### Test Shell Bundle

```bash
./scripts/generate_examples_bundle.sh
cd /tmp
bash /path/to/dist/mlabpp_examples_bundle.sh
ls examples/
test -f examples/basic_demo.m && echo "✓ OK"
```

---

## Bundle Contents

**Included:**
- 10 MATLAB examples (`.m` files)
- README.txt (plain text instructions)
- EXAMPLES.md (detailed documentation)
- install.bat (Windows helper)
- install.sh (Unix helper)

**Size:** ~50 KB compressed, ~280 KB extracted

---

## Customization

### Add Examples

```bash
vim matlab_examples/new_demo.m
./scripts/generate_examples_zip.sh
./scripts/generate_examples_bundle.sh
```

New example now included in both bundles.

### Change Version

```bash
# Edit both generation scripts
sed -i 's/VERSION="0.3.0"/VERSION="0.4.0"/' scripts/generate_examples_*.sh

# Regenerate
./scripts/generate_examples_zip.sh
./scripts/generate_examples_bundle.sh

# Output: matlabcpp_examples_v0.4.0.zip
```

---

## Troubleshooting

### ZIP Issues

**Problem:** "Cannot open ZIP file"

**Solution:**
```bash
# Verify format
file dist/matlabcpp_examples_v0.3.0.zip
# Should show: "Zip archive data"

# Test with 7-Zip
7z t dist/matlabcpp_examples_v0.3.0.zip
```

**Problem:** "Permission denied" after extraction

**Solution:**
```bash
chmod +x matlabcpp_examples/*.sh
```

### Shell Bundle Issues

**Problem:** `base64: command not found`

**Solution:** Install coreutils (rare on most systems)
```bash
# Ubuntu/Debian
sudo apt install coreutils

# macOS (usually built-in)
brew install coreutils
```

**Problem:** Bundle won't execute on Windows

**Solution:** Use ZIP format. Shell bundles require WSL or Git Bash on Windows.

---

## Distribution Strategy

### For Public Release

Provide two options:

1. **ZIP bundle** (primary) - Windows/macOS/Linux, beginner-friendly
2. **Shell bundle** (optional) - Unix power users

Example download page:

```markdown
## Download Examples

### Universal (Recommended)
[matlabcpp_examples_v0.3.0.zip](link) (50 KB)
- Works on Windows, macOS, Linux
- Extract and run

### Linux/macOS (Advanced)
[mlabpp_examples_bundle.sh](link) (50 KB)
- One-command installation
- Run: bash mlabpp_examples_bundle.sh
```

### For Corporate/Education

**Use ZIP exclusively.**

Why:
- IT departments recognize and trust ZIP
- Email systems don't block ZIP
- Antivirus software scans ZIP automatically
- Works on locked-down systems
- No script execution required

---

## FAQ

**Q: Which format should I distribute?**  
A: **ZIP** for universal compatibility. Shell bundle is optional for Unix users.

**Q: Can I email these?**  
A: **ZIP** works everywhere. Shell bundles may be filtered by corporate email.

**Q: Maximum bundle size?**  
A: Keep under 5 MB for email attachments. Current bundles are ~50 KB.

**Q: How to add examples?**  
A: Add `.m` files to `matlab_examples/`, regenerate bundles.

**Q: Will this work on my university's locked-down computers?**  
A: ZIP format will. Shell bundles might not if script execution is restricted.

---

## See Also

- **DISTRIBUTION_QUICKSTART.md** - Quick reference
- **DISTRIBUTION_CHEATSHEET.md** - Copy-paste commands
- **DISTRIBUTION_COMPARISON.md** - Detailed format comparison
- **BUILD.md** - Build system documentation
- **FOR_NORMAL_PEOPLE.md** - User guide

---

**Distribution: Generate once, works everywhere.**

Two scripts. Two files. All platforms covered.

No drama, no dependencies, no excuses.
