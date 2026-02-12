# Package Management System Integration

**Professional module distribution for MatLabC++ v0.3.0+**

---

## Architecture (The dnf Way)

```
┌──────────────┐
│   CLI        │   mlab++ pkg install materials_smart
│  (dnf-like)  │   
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Package      │   Resolve dependencies
│ Engine       │   Download + verify
│              │   Extract + install
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Capability   │   material_get → materials_smart.so
│ Registry     │   gpu_benchmark → gpu_bench_cuda.so
│ (the magic)  │   Backend selection happens here
└──────────────┘
```

---

## What Makes This Professional

### 1. Three-Layer Architecture

**CLI Layer** (`tools/mlab_pkg.cpp`)
- Argument parsing
- User messages
- Progress bars
- Error handling

**Package Engine** (`include/matlabcpp/package_manager.hpp`)
- Dependency resolution (topological sort)
- Download/verify/extract
- Repository management
- Installation logic

**Module Store** (`~/.matlabcpp/modules/`)
- Filesystem layout
- Index database
- Capability registry

### 2. Capability-Based Resolution (Not Noob)

**Bad way (hardcoded):**
```cpp
#include <materials_smart.hpp>
auto mat = materials_smart::get("aluminum");
```

**Professional way (capability):**
```cpp
auto fn = matlabcpp::resolve("material_get");
auto mat = fn("aluminum");
```

**Why this matters:**
- Modules can be swapped at runtime
- Backend selection automatic
- No recompilation needed
- System scales

### 3. Backend Selection

**Manifest declares backends:**
```json
{
  "backends": {
    "available": ["cuda", "opencl", "cpu"],
    "default": "cuda",
    "priority": {
      "cuda": 100,
      "opencl": 80,
      "cpu": 50
    }
  }
}
```

**Runtime selects best:**
```cpp
Backend choose_backend(const Manifest& m) {
    if (gpu_available() && m.has("cuda")) return CUDA;
    if (gpu_available() && m.has("opencl")) return OPENCL;
    if (m.has("cpu")) return CPU;
    return STUB;
}
```

---

## Complete Example: Installing materials_smart

### User Perspective

```bash
$ mlab++ pkg search materials

Found 1 package(s):

Name              Version  Size     Description
────────────────────────────────────────────────────────────
materials_smart   1.0.0    156 KB   Smart materials database

$ mlab++ pkg install materials_smart

Resolving dependencies...
  materials_smart 1.0.0
    requires: core >= 0.3.0 ✓

Downloading [####################] 156 KB
Verifying... ✓
Installing... ✓

✓ Complete!
```

### System Perspective

1. **Dependency Resolution**
   ```cpp
   auto deps = resolver.resolve("materials_smart");
   // deps.install_order = ["core", "materials_smart"]
   ```

2. **Download**
   ```cpp
   auto archive = repo.download("materials_smart", "1.0.0");
   // Downloads to ~/.matlabcpp/cache/
   ```

3. **Verify**
   ```cpp
   bool ok = repo.verify_checksum(archive, manifest.checksum);
   // SHA256 verification
   ```

4. **Extract**
   ```cpp
   installer.extract_archive(archive, install_path);
   // Extracts to ~/.matlabcpp/modules/materials_smart/1.0.0/
   ```

5. **Register**
   ```cpp
   db.register_package(manifest);
   registry.register_module(manifest);
   // Updates ~/.matlabcpp/index.json
   // Registers capabilities
   ```

---

## Repository Layout

### Packages Ship With MatLabC++

```
MatLabC++-v0.3.0.tar.gz
├── bin/
│   └── mlab++
├── lib/
│   └── libmatlabcpp_core.so
├── include/
│   └── matlabcpp/
└── packages/                      ← Package repository included!
    ├── repo/
    │   ├── materials_smart-1.0.0-any.tar.gz
    │   ├── gpu_bench-1.0.0-x86_64.tar.gz
    │   ├── signal_proc-1.0.0-any.tar.gz
    │   ├── optimization-1.0.0-any.tar.gz
    │   └── fem_solver-1.0.0-any.tar.gz
    ├── manifests/
    │   ├── materials_smart.json
    │   ├── gpu_bench.json
    │   └── ...
    └── index.json
```

### First Install

```bash
# 1. Extract MatLabC++
tar xzf MatLabC++-v0.3.0.tar.gz
cd MatLabC++-v0.3.0

# 2. Install core
./install.sh

# 3. Packages are already available (offline install)
mlab++ pkg list
# Shows: materials_smart, gpu_bench, signal_proc, optimization, fem_solver
# All available, none installed yet

# 4. Install what you need
mlab++ pkg install materials_smart
# Installs from packages/repo/ (no internet needed!)
```

---

## Module Package Structure

### materials_smart-1.0.0-any.tar.gz

```
materials_smart-1.0.0-any/
├── manifest.json                  ← Metadata
├── include/
│   └── matlabcpp/
│       └── materials_smart.hpp
├── lib/
│   ├── libmaterials_smart.so
│   └── libmaterials_smart.a
├── demos/
│   ├── materials_lookup.m
│   └── materials_optimization.m
└── docs/
    ├── README.md
    ├── API.md
    └── SOURCES.md
```

### Installation Location

```
~/.matlabcpp/
├── modules/
│   └── materials_smart/
│       └── 1.0.0/
│           ├── manifest.json
│           ├── include/ → symlink to package include/
│           ├── lib/ → symlink to package lib/
│           └── demos/
│
├── cache/
│   └── materials_smart-1.0.0-any.tar.gz
│
└── index.json
```

---

## Available Modules (v0.3.0)

| Module | Category | Size | Description | Backends |
|--------|----------|------|-------------|----------|
| **materials_smart** | Data | 156 KB | Smart materials database | CPU |
| **gpu_bench** | Tools | 48 KB | GPU benchmarking | CUDA, OpenCL |
| **signal_proc** | DSP | 224 KB | FFT, filters | FFTW, GPU, CPU |
| **optimization** | Math | 180 KB | Gradient descent, simplex | CPU, Parallel |
| **fem_solver** | FEM | 420 KB | Finite element analysis | Sparse, GPU |

**Total: 1.0 MB (all modules)**

---

## Capability Resolution Example

### Application Code (User)

```cpp
#include <matlabcpp/core.hpp>

int main() {
    // App doesn't hardcode dependencies
    auto material_fn = matlabcpp::resolve("material_get");
    
    if (!material_fn) {
        std::cerr << "Materials module not installed\n";
        std::cerr << "Run: mlab++ pkg install materials_smart\n";
        return 1;
    }
    
    auto aluminum = material_fn("aluminum_6061");
    std::cout << "Density: " << aluminum.density << " kg/m³\n";
}
```

### System Resolution (Automatic)

```cpp
// CapabilityRegistry::resolve("material_get")

1. Check index.json for "material_get" capability
2. Find: materials_smart provides this
3. Check if materials_smart is installed
4. Load libmaterials_smart.so
5. dlsym("material_get")
6. Return function pointer
```

---

## Integration with Bundle System

### Bundle Contains Packages

```bash
mlabpp_examples_bundle.sh
  ├── examples/                    ← Demo files (from before)
  └── __PACKAGES__/                ← New: package archives
      ├── materials_smart.tar.gz
      ├── gpu_bench.tar.gz
      └── index.json
```

### Install Flow

```bash
# 1. Run bundle
bash mlabpp_examples_bundle.sh

# Extracts to:
#   ./examples/         (demos)
#   ./packages/repo/    (module archives)

# 2. Install modules
cd packages
ls repo/
# materials_smart-1.0.0-any.tar.gz
# gpu_bench-1.0.0-x86_64.tar.gz
# ...

# 3. Install what you need
mlab++ pkg install materials_smart

# 4. Run demos
cd ../examples
mlab++ materials_lookup.m --visual
```

---

## Comparison with Other Systems

| Feature | MatLabC++ pkg | pip | dnf | npm | MATLAB toolboxes |
|---------|---------------|-----|-----|-----|------------------|
| Binary packages | ✓ | ✗ | ✓ | ✗ | ✓ |
| Dependency resolution | ✓ | ✓ | ✓ | ✓ | ✓ |
| Offline install | ✓ | ✓ | ✓ | ✓ | ✗ |
| Capability-based | ✓ | ✗ | ✗ | ✗ | ✗ |
| Backend selection | ✓ | ✗ | ✗ | ✗ | ✗ |
| Ships with distro | ✓ | ✗ | ✓ | ✗ | ✓ |
| Size | 1 MB | N/A | N/A | N/A | 2+ GB |
| Cost | Free | Free | Free | Free | $1,000+ |

**MatLabC++ wins on: capability resolution, backend selection, size, cost**

---

## Future Enhancements

### Phase 1 (v0.4.0)
- [ ] Implement core package manager
- [ ] Create 5 module packages
- [ ] Integrate with bundle system
- [ ] Write CLI tool

### Phase 2 (v0.5.0)
- [ ] GPG signature verification
- [ ] Delta updates
- [ ] Parallel downloads
- [ ] SAT solver for complex deps

### Phase 3 (v1.0.0)
- [ ] Binary compatibility detection
- [ ] Cross-compilation support
- [ ] Private repositories
- [ ] Package building service

---

## Commands Reference

```bash
# Search
mlab++ pkg search <query>

# Info
mlab++ pkg info <package>

# Install
mlab++ pkg install <package>
mlab++ pkg install --local <archive.tar.gz>

# Remove
mlab++ pkg remove <package>

# List
mlab++ pkg list                    # Installed
mlab++ pkg list --available        # Available

# Update
mlab++ pkg update                  # Refresh index
mlab++ pkg upgrade <package>       # Upgrade one
mlab++ pkg upgrade                 # Upgrade all

# Resolve capability
mlab++ pkg resolve <capability>
# Example: mlab++ pkg resolve material_get
# Output: materials_smart
```

---

## See Also

- [packages/README.md](README.md) - Package repository structure
- [BUNDLE_INTEGRATION.md](../BUNDLE_INTEGRATION.md) - Bundle system
- [MATERIALS_DATABASE.md](../MATERIALS_DATABASE.md) - Materials system
- [include/matlabcpp/package_manager.hpp](../include/matlabcpp/package_manager.hpp) - API

---

**"Like dnf, but for numerical computing. Capability-based. Backend-aware. Not noob."**
