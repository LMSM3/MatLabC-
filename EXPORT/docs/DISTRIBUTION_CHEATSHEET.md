# 📦 Distribution Cheat Sheet

**Copy-paste commands for instant distribution**

---

## 🔨 Maintainers: Create & Distribute

```bash
# Generate bundles
./scripts/generate_examples_zip.sh
./scripts/generate_examples_bundle.sh

# Upload
scp dist/matlabcpp_examples_v0.3.0.zip server:/var/www/downloads/
scp dist/mlabpp_examples_bundle.sh server:/var/www/downloads/

# Or test locally
ls -lh dist/
```

---

## 📥 Users: Download & Install

### Windows

```cmd
curl -O https://site.com/matlabcpp_examples_v0.3.0.zip
tar -xf matlabcpp_examples_v0.3.0.zip
cd matlabcpp_examples
mlab++ basic_demo.m
```

### macOS

```bash
curl -O https://site.com/matlabcpp_examples_v0.3.0.zip
unzip matlabcpp_examples_v0.3.0.zip
cd matlabcpp_examples
./install.sh && mlab++ basic_demo.m
```

### Linux (Fast)

```bash
wget https://site.com/mlabpp_examples_bundle.sh
bash mlabpp_examples_bundle.sh && cd examples && mlab++ basic_demo.m
```

### Linux (ZIP)

```bash
wget https://site.com/matlabcpp_examples_v0.3.0.zip
unzip matlabcpp_examples_v0.3.0.zip && cd matlabcpp_examples
bash install.sh && mlab++ basic_demo.m
```

---

## ⚡ One-Liners

### Generate both formats
```bash
./scripts/generate_examples_zip.sh && ./scripts/generate_examples_bundle.sh
```

### Test ZIP bundle
```bash
cd /tmp && unzip /path/to/dist/matlabcpp_examples_v0.3.0.zip && ls matlabcpp_examples/
```

### Test shell bundle
```bash
cd /tmp && bash /path/to/dist/mlabpp_examples_bundle.sh && ls examples/
```

### Install and run (Linux)
```bash
bash mlabpp_examples_bundle.sh && cd examples && mlab++ basic_demo.m
```

---

## 🎯 Decision Matrix

| If you have... | Use... |
|----------------|--------|
| Windows | ZIP |
| macOS | ZIP or Shell |
| Linux | Shell (fast) or ZIP |
| Mixed audience | ZIP |
| Email | ZIP only |
| Developers | Shell |
| Beginners | ZIP |

---

## 📋 Quick Checks

### Verify bundle generated
```bash
ls -lh dist/
# Should see: matlabcpp_examples_v0.3.0.zip (~50 KB)
#             mlabpp_examples_bundle.sh (~50 KB)
```

### Verify ZIP contents
```bash
unzip -l dist/matlabcpp_examples_v0.3.0.zip | grep .m$
# Should list all .m files
```

### Verify shell bundle
```bash
head -n 20 dist/mlabpp_examples_bundle.sh
# Should show bash script header
```

### Test extraction
```bash
cd /tmp && unzip /path/to/bundle.zip && test -f matlabcpp_examples/basic_demo.m && echo "✓ OK"
```

---

## 🔧 Customization

### Add example
```bash
vim matlab_examples/new_demo.m
./scripts/generate_examples_zip.sh  # Regenerate
```

### Change version
```bash
sed -i 's/VERSION="0.3.0"/VERSION="0.4.0"/' scripts/generate_examples_*.sh
./scripts/generate_examples_zip.sh  # Regenerate
```

### Include docs
```bash
# Edit scripts/generate_examples_zip.sh
# Add: cp docs/*.md staging/matlabcpp_examples/
./scripts/generate_examples_zip.sh
```

---

## 🆘 Troubleshooting One-Liners

```bash
# Fix permissions
chmod +x scripts/*.sh matlabcpp_examples/*.sh

# Check ZIP format
file dist/matlabcpp_examples_v0.3.0.zip

# Test bundle extraction
cd /tmp && bash /path/to/bundle.sh && ls examples/

# Verify mlab++ installed
mlab++ --version || echo "Install MatLabC++ first!"
```

---

**Keep this card handy for instant distribution!** 📦⚡
