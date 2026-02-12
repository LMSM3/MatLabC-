# Self-Extracting MATLAB Examples Bundle

**Single-file portable installer for MatLabC++ MATLAB demos**

Because GUIs are for cowards, and we ship single executable files.

---

## Quick Start

```bash
# Download and run in one line
curl -O https://example.com/mlabpp_examples_bundle.sh && bash mlabpp_examples_bundle.sh

# That's it! Examples are now in ./examples/
cd examples && ls -la
```

---

## What Is This?

A **self-extracting bash script** that bundles all MATLAB demo files into a single portable executable.

### Features

✓ **Single file** - No git, no build system, just one bash script  
✓ **Self-contained** - Everything embedded as base64+tar.gz  
✓ **Automatic** - Extracts, annotates, and cleans up  
✓ **Portable** - Works on Linux, macOS, WSL  
✓ **Idempotent** - Safe to run multiple times  
✓ **Smart cleanup** - Self-deletes from temp locations  
✓ **Zero dependencies** - Only standard Unix tools  

### Bundle Contents

| Demo File | What It Shows | Lines | Features |
|-----------|---------------|-------|----------|
| `basic_demo.m` | Matrix operations, eigenvalues | 50 | Core linear algebra |
| `materials_lookup.m` | Smart materials database | 120 | Inference, selection, comparison |
| `gpu_benchmark.m` | GPU acceleration | 80 | CUDA/OpenCL benchmarking |
| `signal_processing.m` | FFT, filters, spectrograms | 100 | DSP pipeline |
| `linear_algebra.m` | Decompositions, solvers | 110 | LU, QR, SVD, least squares |

**Total size:** ~50 KB compressed, ~200 KB extracted

---

## Installation

### Basic Installation

Extract to current directory:

```bash
./mlabpp_examples_bundle.sh
```

Extracts to: `./examples/`

### Custom Location

Install to specific directory:

```bash
./mlabpp_examples_bundle.sh /opt/matlabcpp
```

Extracts to: `/opt/matlabcpp/examples/`

### Installation from URL

Direct download and install:

```bash
curl https://example.com/mlabpp_examples_bundle.sh | bash
```

### Force Self-Delete

Always delete installer after extraction:

```bash
FORCE_SELF_DELETE=1 ./mlabpp_examples_bundle.sh
```

---

## Running the Examples

After installation, each `.m` file has instructions prepended:

```matlab
% ============================================================
% Installed by mlabpp_examples_bundle.sh
% Location: /path/to/examples
% 
% Run with: mlab++ <file>.m --visual --enableGPU --noerrorlogs --silentcli
% ============================================================

% (actual demo code follows)
```

### Example Commands

```bash
cd examples

# Basic demo (no special flags needed)
mlab++ basic_demo.m --visual

# Materials database (shows smart inference)
mlab++ materials_lookup.m --visual --noerrorlogs

# GPU benchmark (requires GPU + drivers)
mlab++ gpu_benchmark.m --enableGPU --visual

# Signal processing (DSP pipeline)
mlab++ signal_processing.m --visual --silentcli

# Linear algebra (decompositions and solvers)
mlab++ linear_algebra.m --visual
```

---

## Creating Your Own Bundle

### Step 1: Prepare Demo Files

```bash
mkdir matlab_examples
cd matlab_examples

# Add your .m files
vim my_awesome_demo.m
vim another_demo.m
vim heat_equation_solver.m

cd ..
```

### Step 2: Generate Bundle

```bash
./scripts/generate_examples_bundle.sh
```

Output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Generating self-extracting MATLAB examples bundle
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Found 8 MATLAB demo file(s)
✓ Template: scripts/mlabpp_examples_bundle.sh

Building self-extracting bundle...
  • Archiving examples...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Self-extracting bundle created successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Output: ./dist/mlabpp_examples_bundle.sh
  Size:   78 KB
  Files:  8 MATLAB demos
```

### Step 3: Distribute

```bash
# Copy to web server
scp dist/mlabpp_examples_bundle.sh user@webserver:/var/www/downloads/

# Or distribute via GitHub releases
gh release upload v1.0 dist/mlabpp_examples_bundle.sh

# Or email to students
# (it's just a bash script, safe to attach)
```

---

## Technical Details

### Architecture

```
mlabpp_examples_bundle.sh structure:
┌─────────────────────────────────────┐
│ Bash script header                  │ ~100 lines
│  - Argument parsing                 │
│  - Extraction logic                 │
│  - Annotation engine                │
│  - Self-delete logic                │
├─────────────────────────────────────┤
│ __PAYLOAD_BELOW__ marker            │
├─────────────────────────────────────┤
│ base64(tar.gz(examples/))           │ Variable size
│  - All .m files compressed          │
│  - Maintains directory structure    │
└─────────────────────────────────────┘
```

### Payload Format

1. **Archive:** `tar czf - matlab_examples/*.m`
2. **Encode:** `base64`
3. **Embed:** Append to script after `__PAYLOAD_BELOW__`

### Extraction Process

1. Script runs
2. Uses `awk` to find `__PAYLOAD_BELOW__`
3. Pipes remainder through `base64 -d | tar -xz`
4. Extracts to `examples/` directory
5. Annotates each `.m` file with install location
6. Prints success message
7. Self-deletes if running from temp directory

### Dependencies

**Required (standard on all Unix systems):**
- bash
- awk
- base64
- tar with gzip support

**That's it.** No Python, no Ruby, no Node.js, no external packages.

---

## Use Cases

### 1. Student Distribution

Professor distributing assignments:

```bash
# Generate bundle with assignment files
cp assignment1.m assignment2.m assignment3.m matlab_examples/
./scripts/generate_examples_bundle.sh

# Email single file to students
# Students run: bash mlabpp_examples_bundle.sh
```

### 2. Remote Server Setup

Setting up on a server without git:

```bash
ssh remote-server
curl -O https://internal.company.com/mlabpp_examples_bundle.sh
bash mlabpp_examples_bundle.sh /opt/tools/matlabcpp
cd /opt/tools/matlabcpp/examples
mlab++ basic_demo.m
```

### 3. Air-Gapped Systems

Transferring to isolated networks:

```bash
# On internet-connected machine
./scripts/generate_examples_bundle.sh

# Copy to USB drive
cp dist/mlabpp_examples_bundle.sh /media/usb/

# On air-gapped machine
cp /media/usb/mlabpp_examples_bundle.sh ~/
bash mlabpp_examples_bundle.sh
```

### 4. Conference Demos

Quick setup at conferences/workshops:

```bash
# Attendees can download and run immediately
curl -L bit.ly/matlabcpp-demos | bash

# Ready to demo in seconds
cd examples && mlab++ materials_lookup.m --visual
```

---

## Troubleshooting

### Bundle Won't Extract

**Problem:** `base64: command not found`

**Solution:** Install coreutils (rare on modern systems)
```bash
# Debian/Ubuntu
sudo apt install coreutils

# macOS (should be built-in)
brew install coreutils
```

---

### Files Not Annotated

**Problem:** `.m` files don't have install comments

**Solution:** They already had the comments (idempotent check passed)
```bash
# Check if annotations exist
head -n 5 examples/basic_demo.m
```

---

### Self-Delete Didn't Work

**Problem:** Script still exists after installation

**Solution:** That's intentional! Only deletes from temp locations
```bash
# Force delete
FORCE_SELF_DELETE=1 ./mlabpp_examples_bundle.sh

# Or manual delete
rm mlabpp_examples_bundle.sh
```

---

### Wrong Install Location

**Problem:** Installed to wrong directory

**Solution:** Pass correct path as argument
```bash
./mlabpp_examples_bundle.sh /correct/path
```

Files go to: `/correct/path/examples/`

---

## Advanced Usage

### Verify Bundle Integrity

Check what's inside before extracting:

```bash
# View payload size
awk '/^__PAYLOAD_BELOW__$/{p=1;next}p' mlabpp_examples_bundle.sh | wc -c

# List files in bundle (without extracting)
awk '/^__PAYLOAD_BELOW__$/{p=1;next}p' mlabpp_examples_bundle.sh \
  | base64 -d | tar -tzv
```

### Extract to Stdout (Pipe to Other Tools)

```bash
# Extract specific file
awk '/^__PAYLOAD_BELOW__$/{p=1;next}p' mlabpp_examples_bundle.sh \
  | base64 -d | tar -xzO materials_lookup.m
```

### Custom Annotation

Modify `INSTALL_NOTE` in the script template before generating:

```bash
# Edit scripts/mlabpp_examples_bundle.sh
INSTALL_NOTE="% Custom header here\n% Your organization\n\n"
```

Then regenerate bundle.

---

## Comparison with Other Distribution Methods

| Method | Size | Dependencies | Setup Time | Portability |
|--------|------|--------------|------------|-------------|
| **Self-extracting bundle** | 50 KB | bash, tar | 1 second | ✓✓✓ |
| Git clone | N/A | git, build tools | 2 minutes | ✓✓ |
| Zip archive | 40 KB | unzip | 5 seconds | ✓✓✓ |
| Installer script | N/A | curl, tar | 30 seconds | ✓✓ |
| Package manager | N/A | apt/yum/brew | 1 minute | ✓ |

**Winner:** Self-extracting bundle for simple demo distribution

---

## Security Considerations

### Is It Safe?

**Yes**, if you trust the source:

✓ Pure bash script (human-readable header)  
✓ No external network calls  
✓ No privilege escalation  
✓ Only writes to specified directory  
✓ No compilation or binary execution  
✓ Open-source and auditable  

### Verify Before Running

```bash
# Check what it does (read the header)
head -n 200 mlabpp_examples_bundle.sh

# Verify no malicious content
grep -i "sudo\|rm -rf /\|curl.*|.*bash" mlabpp_examples_bundle.sh

# Run in isolated directory
mkdir /tmp/safe-test && cd /tmp/safe-test
bash ~/mlabpp_examples_bundle.sh
```

### Generate Your Own

Most secure: Generate from trusted source files:

```bash
# Use your own .m files
./scripts/generate_examples_bundle.sh

# Now you control 100% of the content
```

---

## Contributing

### Adding New Demos

1. Create `.m` file in `matlab_examples/`
2. Add descriptive header comments
3. Test with `mlab++ your_demo.m`
4. Regenerate bundle: `./scripts/generate_examples_bundle.sh`
5. Submit PR with new demo

### Template Improvements

Edit `scripts/mlabpp_examples_bundle.sh`:
- Better error handling
- Progress bars
- Checksum verification
- Multi-platform compatibility

Then regenerate bundles.

---

## FAQ

**Q: Why base64? Isn't that inefficient?**  
A: ~33% overhead, but ensures text-mode safety. Bundle is still <100 KB.

**Q: Can I bundle C++ code too?**  
A: Yes! Just put `.cpp` files in `matlab_examples/` and modify annotation logic.

**Q: Does it work on Windows?**  
A: Yes, in WSL or Git Bash. Native Windows CMD doesn't support bash.

**Q: Can I encrypt the bundle?**  
A: Yes, wrap with `openssl enc` or `gpg`. Recipient decrypts before running.

**Q: Maximum bundle size?**  
A: Tested up to 10 MB. Bash handles strings fine. Practical limit: network transfer speed.

**Q: How to update examples?**  
A: Just run bundle again. It's idempotent (won't duplicate annotations).

---

## License

Same as MatLabC++: MIT License

Distribute freely, modify as needed, no warranty.

---

## Credits

**Concept:** makeself, shar (Unix shell archives)  
**Implementation:** Pure bash, awk, base64, tar  
**Philosophy:** Single-file distribution, no external dependencies  

---

**"Because sometimes you just want to send one file and be done with it."**
