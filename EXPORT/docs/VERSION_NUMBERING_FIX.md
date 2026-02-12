# Version Numbering Clarification

**Date:** 2025-01-23  
**Issue:** Inconsistent version numbering (v0.8.0.1 vs standard)

---

## Current Confusion

We've been using: **v0.8.0.1**  
This is: **Non-standard 4-part versioning**

---

## Standard Semantic Versioning

```
vMAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

Examples:
v0.4.0              - Stable release
v0.8.0-alpha        - Alpha version
v0.8.0-beta.1       - First beta
v0.8.0-rc.1         - Release candidate 1
v0.8.0+20250123     - With build metadata
```

### Rules:
1. **MAJOR** (0): Breaking changes
2. **MINOR** (8): New features, backwards-compatible
3. **PATCH** (0): Bug fixes only
4. **PRERELEASE** (-beta.1): Optional, before stable
5. **BUILD** (+20250123): Optional metadata

---

## Recommended Fix

### GPU Development Versions:

**OLD (incorrect):**
```
v0.8.0.1 beta
```

**NEW (correct):**
```
v0.8.0-alpha       - Initial GPU work
v0.8.0-beta.1      - First beta ← WE ARE HERE
v0.8.0-beta.2      - Bug fixes
v0.8.0-rc.1        - Release candidate
v0.8.0             - Stable GPU release
```

---

## Version Progression (Fixed)

```
v0.4.0             ✅ CPU stable (current)
  ↓
v0.4.1             ⏳ Scripts
v0.4.2             ⏳ Linear algebra
v0.4.3             ⏳ Complex
v0.4.4             ⏳ Mechanics
v0.4.5             ⏳ Optimization
  ↓
v0.5.0             🎯 Stable feature-complete CPU // Transitional state
  ↓
v0.8.0-alpha       🔬 GPU experiments start
v0.8.0-beta.1      🧪 GPU stress tests ← HERE
v0.8.0-beta.2      🐛 Bug fixes
v0.8.0-rc.1        🎯 Release candidate
v0.8.0             🚀 GPU stable release
  ↓
v1.0.0-rc.1        🏆 Production candidate
v1.0.0             🎉 Official release
```

---

## What to Change

### Files to Update:

1. **CMakeLists.txt**
```cmake
project(MatLabCPlusPlus VERSION 0.4.0 LANGUAGES CXX)
# Future: 0.8.0 (remove beta suffix from version number)
```

2. **Version strings in code**
```cpp
const char* VERSION = "0.4.0";
// Future: "0.8.0-beta.1"
```

3. **Documentation**
- All `.md` files referring to "v0.8.0.1"
- Change to "v0.8.0-beta.1"

4. **Build scripts**
- Test result filenames
- Package names

---

## Alternative: Keep 4-Part

**If you prefer 4-part versioning:**

```
v0.8.0.0    - Initial GPU
v0.8.0.1    - Build 1
v0.8.0.2    - Build 2
...
v0.8.1.0    - Next feature
```

**Pros:**
- Simple incrementing
- Build number tracking
- Windows-style versioning

**Cons:**
- Not standard semver
- Package managers may not recognize
- Harder to indicate pre-release status

---

## Recommendation

**Use Semantic Versioning (Option 1):**

```bash
# Current
v0.4.0

# GPU work
v0.8.0-alpha        # Experiments
v0.8.0-beta.1       # Testing ← USE THIS
v0.8.0-beta.2       # Fixes
v0.8.0-rc.1         # Release candidate
v0.8.0              # Stable
```

**Why:**
- Industry standard
- Package manager compatible
- Clear pre-release indication
- Better for CI/CD tools
- Semantic meaning

---

## Implementation

### Update version in main.cpp:
```cpp
#define VERSION_MAJOR 0
#define VERSION_MINOR 8
#define VERSION_PATCH 0
#define VERSION_PRERELEASE "beta.1"

std::string get_version() {
    std::string ver = std::to_string(VERSION_MAJOR) + "."
                    + std::to_string(VERSION_MINOR) + "."
                    + std::to_string(VERSION_PATCH);
    if (strlen(VERSION_PRERELEASE) > 0) {
        ver += "-" + std::string(VERSION_PRERELEASE);
    }
    return ver;
}
```

### Output:
```
$ ./mlab++ --version
MatLabC++ version 0.8.0-beta.1
GPU acceleration enabled (CUDA 12.3)
```

---

## Summary

| Aspect | Old | New (Recommended) |
|--------|-----|-------------------|
| Current | v0.4.0 | v0.4.0 ✅ |
| GPU beta | v0.8.0.1 ❌ | v0.8.0-beta.1 ✅ |
| GPU stable | v0.8.0 | v0.8.0 ✅ |
| Notation | 4-part custom | Semver standard |

**Action:** Update all references from `v0.8.0.1` to `v0.8.0-beta.1`

---

## Files Needing Update

```bash
# Search for v0.8.0.1
grep -r "0\.8\.0\.1" .

# Replace with v0.8.0-beta.1
sed -i 's/0\.8\.0\.1/0.8.0-beta.1/g' *.md
```

**Affected files:**
- V0.8.0.1_BETA_GPU_BUILD.md → rename to V0.8.0-beta.1_GPU_BUILD.md
- V0.8.0.1_COMPLETE_SYSTEM.md → update references
- All stress test documentation

---

**Decision:** Use `v0.8.0-beta.1` going forward? ✅
