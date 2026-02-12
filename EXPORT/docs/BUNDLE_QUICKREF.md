# Examples Bundle Quick Reference

**Single-file self-extracting MATLAB demo installer**

---

## Generate Bundle

```bash
./scripts/generate_examples_bundle.sh
```

**Output:** `dist/mlabpp_examples_bundle.sh` (50 KB)

---

## Install Bundle

```bash
# Current directory
bash mlabpp_examples_bundle.sh

# Custom location
bash mlabpp_examples_bundle.sh /opt/matlabcpp

# From URL
curl https://example.com/mlabpp_examples_bundle.sh | bash
```

**Installs to:** `<install_root>/examples/`

---

## Run Examples

```bash
cd examples

mlab++ basic_demo.m --visual
mlab++ materials_lookup.m --visual --noerrorlogs
mlab++ materials_optimization.m --visual
mlab++ gpu_benchmark.m --enableGPU --visual
mlab++ signal_processing.m --visual
mlab++ linear_algebra.m --visual
```

---

## Add New Examples

```bash
# 1. Create demo file
vim matlab_examples/my_demo.m

# 2. Regenerate bundle
./scripts/generate_examples_bundle.sh

# 3. Test
cd /tmp && bash /path/to/dist/mlabpp_examples_bundle.sh
```

---

## Verify Bundle

```bash
# List contents (without extracting)
awk '/^__PAYLOAD_BELOW__$/{p=1;next}p' dist/mlabpp_examples_bundle.sh \
  | base64 -d | tar -tzv

# Check size
ls -lh dist/mlabpp_examples_bundle.sh

# Test in isolated directory
mkdir /tmp/test && cd /tmp/test
bash /path/to/dist/mlabpp_examples_bundle.sh
```

---

## Distribute

```bash
# Web server
scp dist/mlabpp_examples_bundle.sh user@server:/var/www/downloads/

# GitHub release
gh release upload v1.0 dist/mlabpp_examples_bundle.sh

# Email
# Just attach dist/mlabpp_examples_bundle.sh (it's safe text)

# Students
# Upload to LMS, they download and run
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No .m files found | Check `matlab_examples/` exists and has `.m` files |
| Permission denied | Run with `bash` prefix: `bash mlabpp_examples_bundle.sh` |
| base64 not found | Install coreutils: `sudo apt install coreutils` |
| Files not annotated | Already had annotations (idempotent) |
| Wrong location | Pass install path: `bash bundle.sh /correct/path` |

---

## What's Included

| File | Description | Size |
|------|-------------|------|
| `basic_demo.m` | Matrix operations, eigenvalues | 2 KB |
| `materials_lookup.m` | Materials database queries | 5 KB |
| `materials_optimization.m` | Engineering design optimization | 8 KB |
| `gpu_benchmark.m` | GPU acceleration tests | 3 KB |
| `signal_processing.m` | FFT, filters, spectrograms | 4 KB |
| `linear_algebra.m` | Decompositions, solvers | 4 KB |

**Total:** 6 demos, ~200 lines each, 26 KB source, 50 KB bundled

---

## Features

✓ Single executable file  
✓ No dependencies (just bash)  
✓ Works on Linux, macOS, WSL  
✓ Self-extracting  
✓ Auto-annotating  
✓ Idempotent  
✓ Safe self-delete  

---

## Security

- Pure bash script (no binaries)
- No network calls
- No privilege escalation
- Open-source header
- Human-readable code

**Verify:** `head -n 200 mlabpp_examples_bundle.sh`

---

## Full Documentation

- [EXAMPLES_BUNDLE.md](EXAMPLES_BUNDLE.md) - Complete guide
- [scripts/README.md](scripts/README.md) - Technical details
- [INSTALL_OPTIONS.md](INSTALL_OPTIONS.md) - All install methods

---

**One file. One command. Done.**
