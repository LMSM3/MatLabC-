# MatLabC++ Package Repository Structure

Professional module distribution system for MatLabC++ v0.3.0+

---

## Repository Layout

```
packages/
├── repo/                          ← Module archives (ready to install)
│   ├── materials_smart-1.0.0-any.tar.gz
│   ├── gpu_bench-1.0.0-any.tar.gz
│   ├── signal_proc-1.0.0-any.tar.gz
│   ├── fem_solver-1.0.0-any.tar.gz
│   └── optimization-1.0.0-any.tar.gz
│
├── manifests/                     ← Module metadata
│   ├── materials_smart.json
│   ├── gpu_bench.json
│   ├── signal_proc.json
│   ├── fem_solver.json
│   └── optimization.json
│
├── index.json                     ← Repository index
├── README.md                      ← This file
└── build_packages.sh              ← Package builder

~/.matlabcpp/                      ← User installation directory
├── modules/                       ← Installed modules
│   ├── materials_smart/
│   │   └── 1.0.0/
│   │       ├── manifest.json
│   │       ├── include/
│   │       ├── lib/
│   │       └── demos/
│   └── gpu_bench/
│       └── 1.0.0/
│           ├── manifest.json
│           └── ...
│
├── cache/                         ← Downloaded archives
│   ├── materials_smart-1.0.0-any.tar.gz
│   └── gpu_bench-1.0.0-any.tar.gz
│
└── index.json                     ← Installed modules DB
```

---

## Package Structure

Each module archive contains:

```
materials_smart-1.0.0-any.tar.gz
├── manifest.json                  ← Module metadata
├── include/
│   └── matlabcpp/
│       └── materials_smart.hpp    ← Headers
├── lib/
│   ├── libmaterials_smart.so      ← Shared library
│   └── libmaterials_smart.a       ← Static library
├── demos/
│   ├── materials_lookup.m         ← MATLAB demos
│   └── materials_optimization.m
└── docs/
    └── README.md                  ← Module documentation
```

---

## Manifest Format

**manifests/materials_smart.json:**

```json
{
  "name": "materials_smart",
  "version": "1.0.0",
  "arch": "any",
  "description": "Smart materials database with inference",
  "category": "data",
  
  "requires": [
    "core >= 0.3.0"
  ],
  
  "provides": [
    "material",
    "material_get",
    "material_infer_density",
    "material_select",
    "material_compare",
    "material_recommend"
  ],
  
  "backends": ["cpu"],
  
  "files": {
    "include": ["include/matlabcpp/materials_smart.hpp"],
    "lib": ["lib/libmaterials_smart.so", "lib/libmaterials_smart.a"],
    "demos": ["demos/materials_lookup.m", "demos/materials_optimization.m"]
  },
  
  "size": 156000,
  "checksum": "sha256:abc123...",
  "license": "MIT",
  "author": "MatLabC++ Contributors",
  "url": "https://github.com/matlabcpp/matlabcpp"
}
```

---

## Repository Index

**packages/index.json:**

```json
{
  "version": "1.0",
  "updated": "2024-01-15T10:30:00Z",
  "packages": {
    "materials_smart": {
      "latest": "1.0.0",
      "versions": {
        "1.0.0": {
          "file": "materials_smart-1.0.0-any.tar.gz",
          "size": 156000,
          "checksum": "sha256:abc123..."
        }
      }
    },
    "gpu_bench": {
      "latest": "1.0.0",
      "versions": {
        "1.0.0": {
          "file": "gpu_bench-1.0.0-any.tar.gz",
          "size": 48000,
          "checksum": "sha256:def456..."
        }
      }
    }
  }
}
```

---

## Package Manager CLI

### Installation

```bash
# Install package manager (ships with MatLabC++)
./install.sh --with-packages

# Or standalone
./scripts/install_pkg_manager.sh
```

### Usage

```bash
# Search for packages
mlab++ pkg search materials

# Show package info
mlab++ pkg info materials_smart

# Install package
mlab++ pkg install materials_smart

# List installed
mlab++ pkg list

# Remove package
mlab++ pkg remove materials_smart

# Update all packages
mlab++ pkg update
```

---

## Package Installation Flow

### User Perspective

```bash
$ mlab++ pkg install materials_smart

Resolving dependencies...
  materials_smart 1.0.0
    requires: core >= 0.3.0 ✓

Downloading:
  materials_smart-1.0.0-any.tar.gz [##########] 156 KB

Verifying checksum... ✓
Extracting... ✓
Installing... ✓

Installed: materials_smart 1.0.0
  Provides: material, material_get, material_infer_density, ...
  Location: ~/.matlabcpp/modules/materials_smart/1.0.0/

Run demos:
  cd ~/.matlabcpp/modules/materials_smart/1.0.0/demos/
  mlab++ materials_lookup.m --visual

Complete!
```

### System Perspective

1. **Resolve Dependencies**
   - Read manifest
   - Check requirements
   - Topological sort

2. **Download**
   - Check cache first
   - Fetch from repo
   - Verify checksum

3. **Extract**
   - Uncompress tar.gz
   - Validate structure

4. **Install**
   - Copy to `~/.matlabcpp/modules/<name>/<version>/`
   - Update `~/.matlabcpp/index.json`
   - Register capabilities

5. **Configure**
   - Add to load path
   - Compile if needed
   - Run post-install hooks

---

## Capability Resolution

### Traditional (Bad)

```cpp
// Hardcoded dependency
#include <matlabcpp/materials_smart.hpp>
auto mat = materials_smart_get("aluminum");
```

### Capability-Based (Good)

```cpp
// Request capability
auto fn = matlabcpp::resolve("material_get");
auto mat = fn("aluminum");
```

### Backend Selection

```json
{
  "backends": ["gpu", "cpu", "matlab"],
  "backend_priority": {
    "gpu": 100,
    "cpu": 50,
    "matlab": 10
  }
}
```

Runtime chooses best available:
1. GPU if CUDA available
2. CPU otherwise
3. MATLAB fallback if linked

---

## Available Packages (v0.3.0)

| Package | Size | Category | Description |
|---------|------|----------|-------------|
| **materials_smart** | 156 KB | Data | Smart materials database with inference |
| **gpu_bench** | 48 KB | Tools | GPU benchmarking suite |
| **signal_proc** | 224 KB | DSP | FFT, filters, spectrograms |
| **optimization** | 180 KB | Math | Gradient descent, simplex, constraints |
| **fem_solver** | 420 KB | FEM | Finite element basics |
| **control_systems** | 320 KB | Control | PID, LQR, state-space |

**Total:** 1.3 MB (all packages)

---

## Package Development

### Creating a New Package

```bash
# 1. Create module directory
mkdir -p my_module/{include,lib,demos,docs}

# 2. Write manifest
cat > my_module/manifest.json <<EOF
{
  "name": "my_module",
  "version": "1.0.0",
  "requires": ["core >= 0.3.0"],
  "provides": ["my_function"]
}
EOF

# 3. Build package
./packages/build_packages.sh my_module

# Output: packages/repo/my_module-1.0.0-any.tar.gz
```

### Testing Package

```bash
# Install locally
mlab++ pkg install --local my_module-1.0.0-any.tar.gz

# Test
mlab++ -c "my_function()"

# Uninstall
mlab++ pkg remove my_module
```

---

## Repository Hosting

### Local Repository (Default)

Packages included in MatLabC++ distribution at `packages/repo/`

### Remote Repository

```bash
# Add remote repo
mlab++ pkg repo add official https://packages.matlabcpp.org/v0.3/

# Install from remote
mlab++ pkg install materials_smart

# List repos
mlab++ pkg repo list
```

### Mirror Setup

```bash
# Host packages/ directory
cd packages
python3 -m http.server 8000

# Configure client
mlab++ pkg repo add local http://localhost:8000/
```

---

## Security

### Checksum Verification

All packages have SHA256 checksums in manifests:

```bash
# Verify package
sha256sum materials_smart-1.0.0-any.tar.gz
# Should match manifest checksum
```

### Signature Verification (Future)

```json
{
  "signature": {
    "type": "gpg",
    "key": "0x12345678",
    "signature": "base64..."
  }
}
```

---

## Comparison with Other Systems

| Feature | MatLabC++ Pkg | pip | dnf | npm |
|---------|---------------|-----|-----|-----|
| Binary packages | ✓ | ✗ | ✓ | ✗ |
| Dependency resolution | ✓ | ✓ | ✓ | ✓ |
| Capability-based | ✓ | ✗ | ✗ | ✗ |
| Backend selection | ✓ | ✗ | ✗ | ✗ |
| Offline install | ✓ | ✓ | ✓ | ✓ |
| Size | 1.3 MB | N/A | N/A | N/A |

---

## Integration with Bundle System

### Bundle Contains Packages

```
mlabpp_examples_bundle.sh
  ├── examples/                    ← Demo files
  └── packages/                    ← Package archives
      ├── materials_smart.tar.gz
      ├── gpu_bench.tar.gz
      └── index.json
```

### Install Flow

```bash
# 1. Run bundle
bash mlabpp_examples_bundle.sh

# 2. Install packages
cd packages
mlab++ pkg install --local materials_smart.tar.gz

# 3. Run demos
cd examples
mlab++ materials_lookup.m --visual
```

---

## Troubleshooting

### Package Not Found

```bash
$ mlab++ pkg install materials_smart
Error: Package not found

# Solution: Update package index
$ mlab++ pkg update

# Or add repository
$ mlab++ pkg repo add official https://...
```

### Dependency Conflicts

```bash
$ mlab++ pkg install fem_solver
Error: Requires optimization >= 2.0, but 1.0 is installed

# Solution: Update dependencies
$ mlab++ pkg update optimization

# Or force install (not recommended)
$ mlab++ pkg install --force fem_solver
```

### Module Not Loading

```bash
$ mlab++
>> material('aluminum')
Error: Function 'material' not found

# Solution: Check installation
$ mlab++ pkg list
# If not installed:
$ mlab++ pkg install materials_smart
```

---

## Future Enhancements

### Short-term
- [ ] Add update command
- [ ] Implement rollback
- [ ] Add search filters
- [ ] Package verification

### Medium-term
- [ ] GPG signature support
- [ ] Delta updates
- [ ] Parallel downloads
- [ ] Dependency conflict resolution (SAT solver)

### Long-term
- [ ] Binary compatibility detection
- [ ] Cross-compilation support
- [ ] Private repositories
- [ ] Package building service

---

## See Also

- [BUNDLE_INTEGRATION.md](../BUNDLE_INTEGRATION.md) - Bundle system
- [INSTALL_OPTIONS.md](../INSTALL_OPTIONS.md) - Installation methods
- [packages/BUILD.md](BUILD.md) - Building packages
- [packages/HOSTING.md](HOSTING.md) - Repository hosting

---

**Professional package management that feels like dnf, but for numerical computing.**
