# MATLAB Code in Multiple Formats - Documentation

## Overview

MatLabC++ examples now include MATLAB equivalent code in **three formats**:

1. **`.c` files** - Embedded MATLAB as C strings
2. **`.txt` files** - CLI examples with MATLAB blocks (flagged)
3. **`.m` files** - Pure MATLAB scripts (runnable)

This multi-format approach enables:
- Side-by-side comparison
- Easy migration from MATLAB
- Teaching and documentation
- Automated code generation
- Format conversion tools

---

## Format 1: MATLAB in `.c` Files

### Location
`examples/matlab/matlab_examples.c`

### Purpose
Embed MATLAB code as C strings for comparison and documentation

### Structure
```c
const char* matlab_code = 
    "% MATLAB: Example Code\n"
    "x = [1 2 3];\n"
    "y = x.^2;\n";

const char* matlabcpp_cli = 
    ">>> calc [1,2,3]^2\n"
    "Result: [1, 4, 9]\n";

const char* matlabcpp_cpp = 
    "Vec3 x{1, 2, 3};\n"
    "auto y = x.square();\n";
```

### Why `.c` Format?

**Advantages:**
- ✓ All formats in one file
- ✓ Can be compiled and run
- ✓ Easy to parse programmatically
- ✓ Enables automated testing
- ✓ Documentation stays with code
- ✓ Facilitates code generation tools

**Use Cases:**
- Migration tools (MATLAB → C++)
- Code comparison utilities
- Teaching materials
- Automated validation
- Documentation generation

### Usage
```bash
# Compile
gcc -std=c99 -o matlab_examples matlab_examples.c

# Run (displays all examples)
./matlab_examples

# Extract MATLAB code programmatically
grep "const char\* matlab" matlab_examples.c
```

### Example Output
```
============================================
Example 1: Material Property Lookup
============================================

MATLAB CODE:
------------
% MATLAB: Material Property Lookup
materials.pla.density = 1240;     % kg/m³
materials.pla.strength = 50e6;    % Pa
...

MatLabC++ CLI EQUIVALENT:
-------------------------
>>> material pla
PLA
  Density: 1240 kg/m³
  Strength: 50 MPa
...

MatLabC++ C++ EQUIVALENT:
-------------------------
SmartMaterialDB db;
auto pla = db.get("pla");
...
```

---

## Format 2: MATLAB in `.txt` Files (Flagged)

### Location
`examples/cli/*.txt` (comparison.txt, basic_usage.txt, etc.)

### Purpose
Show CLI commands with MATLAB equivalents inline

### Flag Format
```
# [MATLAB EQUIVALENT]
# -------------------
# % MATLAB code here
# x = [1 2 3];
# 
# % ~10 lines of MATLAB vs 1 MatLabC++ command
```

### Structure
```
>>> matlabcpp_command

[Output of command]

# [MATLAB EQUIVALENT]
# -------------------
# % MATLAB code to achieve same result
# matlab_function();
# 
# % Line count comparison
```

### Example
From `comparison.txt`:
```
>>> compare pla petg abs

┌─────────────────────────────────────┐
│  3D PRINTING MATERIAL COMPARISON    │
├─────────────────────────────────────┤
│ Property  │ PLA  │ PETG │ ABS │ Win│
└─────────────────────────────────────┘

# [MATLAB EQUIVALENT]
# -------------------
# % MATLAB: 3D Printing Materials Comparison
# materials = {
#     struct('name', 'PLA',  'density', 1240),
#     struct('name', 'PETG', 'density', 1270),
#     struct('name', 'ABS',  'density', 1060)
# };
# 
# % Display comparison (15+ lines of code)
# ...
# 
# % ~25 lines of MATLAB vs 1 MatLabC++ CLI command
```

### Why Flagged `.txt`?

**Advantages:**
- ✓ Shows context immediately
- ✓ Easy to find (`grep "MATLAB EQUIVALENT"`)
- ✓ CLI-focused (primary use case)
- ✓ Doesn't clutter main flow
- ✓ Can be parsed/extracted

**Guidelines:**
- Flag every significant command
- Show line count comparison
- Keep MATLAB code concise but complete
- Always show the result difference

### Parsing Flags
```bash
# Extract all MATLAB blocks
grep -A 20 "\[MATLAB EQUIVALENT\]" examples/cli/*.txt

# Count MATLAB lines vs CLI lines
# (Shows the conciseness advantage)
```

---

## Format 3: MATLAB `.m` Files (Pure)

### Location
`examples/matlab/*.m`

### Purpose
Runnable MATLAB scripts for complete examples

### Files
- `material_comparison.m` - Complete comparison system
- `ode_solving.m` - ODE solvers (ode45, ode15s)
- `matlab_examples.c` - Embedded format (see Format 1)

### Structure
```matlab
function compare_materials()
    % Complete MATLAB function
    % Shows full implementation
    
    materials = struct();
    % ... full code ...
    
    % Display results
    fprintf('Results:\n');
    % ... output ...
end
```

### Usage
```matlab
% In MATLAB:
cd examples/matlab
material_comparison  % Run all examples
ode_solving         % Run ODE examples

% Or individual functions:
compare_3d_printing_materials();
spring_mass_damper();
```

### Why Pure `.m`?

**Advantages:**
- ✓ Actually runnable in MATLAB
- ✓ Complete, production-quality code
- ✓ Shows best-practices MATLAB
- ✓ Can be tested and validated
- ✓ Familiar to MATLAB users

---

## Visual Comparison: All Three Formats

### Task: Compare PLA, PETG, ABS

#### Format 1: `.c` (Embedded)
```c
const char* matlab_code = 
    "materials = {...};\n"
    "for i = 1:length(materials)\n"
    "  fprintf('%s\\n', materials{i}.name);\n"
    "end\n";

const char* cli = ">>> compare pla petg abs\n";
```

#### Format 2: `.txt` (Flagged CLI)
```
>>> compare pla petg abs
[Table output]

# [MATLAB EQUIVALENT]
# % materials = {...};
# % for loop ...
```

#### Format 3: `.m` (Pure MATLAB)
```matlab
function compare_3d_printing_materials()
    materials = {...};
    for i = 1:length(materials)
        fprintf('%s\n', materials{i}.name);
    end
end
```

---

## When to Use Each Format

### Use `.c` Format When:
- Building migration tools
- Need programmatic access
- Comparing implementations
- Generating documentation
- Teaching side-by-side
- Creating automated tests

### Use `.txt` Format When:
- Learning CLI commands
- Need quick reference
- Want context with examples
- Showing conciseness advantage
- CLI is primary interface

### Use `.m` Format When:
- Actually running in MATLAB
- Need complete implementation
- Testing MATLAB approach
- Migrating existing code
- Full MATLAB workflow

---

## Directory Structure

```
examples/
├── matlab/
│   ├── matlab_examples.c          [Format 1: Embedded]
│   ├── material_comparison.m      [Format 3: Pure .m]
│   ├── ode_solving.m              [Format 3: Pure .m]
│   └── README.md                  [Documentation]
│
├── cli/
│   ├── comparison.txt             [Format 2: Flagged]
│   ├── basic_usage.txt            [Format 2: Flagged]
│   ├── material_lookup.txt        [Format 2: Flagged]
│   └── inference_demo.txt         [Format 2: Flagged]
│
└── MATLAB_FORMAT_GUIDE.md         [This file]
```

---

## Extracting Code

### Extract from `.c` Files
```bash
# Get MATLAB code
gcc -E matlab_examples.c | grep "const char\* matlab"

# Or parse programmatically:
cat matlab_examples.c | awk '/^const char\* matlab/,/";$/'
```

### Extract from `.txt` Files
```bash
# Get all MATLAB blocks
grep -A 50 "\[MATLAB EQUIVALENT\]" examples/cli/*.txt \
    | grep "^# %" \
    | sed 's/^# %//'

# Count comparisons
grep "lines of MATLAB vs" examples/cli/*.txt
```

### Run `.m` Files
```matlab
% In MATLAB:
addpath('examples/matlab');
material_comparison;
```

---

## Code Generation Examples

### Generate C++ from MATLAB (Conceptual)

```python
# Python script to parse embedded MATLAB and suggest C++
import re

def parse_matlab_from_c(filename):
    with open(filename) as f:
        content = f.read()
    
    # Extract MATLAB code strings
    pattern = r'const char\* matlab_\w+ = \n\s+"(.+?)";'
    matches = re.findall(pattern, content, re.DOTALL)
    
    for matlab_code in matches:
        # Parse MATLAB syntax
        # Suggest C++ equivalent
        # Generate MatLabC++ code
        pass

# Usage
parse_matlab_from_c('examples/matlab/matlab_examples.c')
```

### Validate MATLAB Blocks in `.txt`

```bash
#!/bin/bash
# Extract and validate MATLAB code from CLI examples

# Extract MATLAB blocks
grep -A 100 "\[MATLAB EQUIVALENT\]" examples/cli/*.txt \
    | grep "^# %" \
    | sed 's/^# %//' > /tmp/extracted_matlab.m

# Try to run in MATLAB (requires MATLAB installed)
matlab -batch "run /tmp/extracted_matlab.m"
```

---

## Benefits of Multi-Format Approach

### For Users
- ✓ Choose format that suits workflow
- ✓ Easy migration from MATLAB
- ✓ Understand equivalences
- ✓ Copy-paste ready code

### For Developers
- ✓ Automated testing possible
- ✓ Code generation tools enabled
- ✓ Easy to maintain consistency
- ✓ Documentation auto-generated

### For Teaching
- ✓ Side-by-side comparison
- ✓ Shows conciseness advantage
- ✓ Multiple learning styles
- ✓ Complete examples available

---

## Maintenance Guidelines

### When Adding Examples

1. **Start with `.m`** - Write full MATLAB version
2. **Create CLI equivalent** - Test in MatLabC++
3. **Add to `.txt`** - Flag with `[MATLAB EQUIVALENT]`
4. **Optionally add to `.c`** - If useful for comparison

### Consistency Checks

```bash
# Ensure all formats agree
./scripts/validate_matlab_examples.sh

# Check line counts are accurate
grep "lines of MATLAB" examples/cli/*.txt

# Verify .m files run
matlab -batch "run_all_examples"
```

### Version Control

- `.m` files are source of truth for MATLAB code
- `.txt` files show CLI usage (primary)
- `.c` files for documentation/tools (secondary)

---

## Examples of Each Format

### Example: Material Lookup

#### `.c` Format
```c
const char* matlab_lookup = 
    "materials.pla.density = 1240;\n"
    "fprintf('%d\\n', materials.pla.density);\n";

const char* cli = ">>> material pla\nDensity: 1240\n";
```

#### `.txt` Format
```
>>> material pla
Density: 1240 kg/m³

# [MATLAB EQUIVALENT]
# materials.pla.density = 1240;
# fprintf('%d kg/m³\n', materials.pla.density);
```

#### `.m` Format
```matlab
function lookup_material()
    materials.pla.density = 1240;
    fprintf('Density: %d kg/m³\n', materials.pla.density);
end
```

---

## Migration Path

### MATLAB User → MatLabC++

1. **Read `.m` examples** - Understand full MATLAB approach
2. **Check `.txt` files** - See CLI equivalents
3. **Use CLI** - Start with simple commands
4. **Gradually adopt** - Mix MATLAB and MatLabC++
5. **Full transition** - Move to C++ API if needed

### Example Migration
```
Week 1: Use .txt files for reference, run MATLAB
Week 2: Try MatLabC++ CLI for simple tasks
Week 3: Mix MATLAB (visualization) + MatLabC++ (computation)
Week 4: Primarily MatLabC++, MATLAB for plots
Week 5: Full MatLabC++ workflow
```

---

## Summary

| Format | File Type | Purpose | Primary Use |
|--------|-----------|---------|-------------|
| **Embedded** | `.c` | Documentation, tools | Code generation |
| **Flagged** | `.txt` | CLI reference | Learning, quick ref |
| **Pure** | `.m` | Runnable MATLAB | Full implementation |

**All three formats show the same functionality, just presented differently for different use cases.**

---

## Questions & Answers

**Q: Why embed MATLAB in C files?**
A: Enables programmatic parsing, comparison, and code generation tools. All formats in one place.

**Q: Can I run the `.c` file?**
A: Yes! Compile with `gcc` and it displays all examples with side-by-side comparisons.

**Q: Do I need to maintain all three?**
A: `.txt` is primary. `.m` and `.c` are optional but recommended for completeness.

**Q: Which format for beginners?**
A: Start with `.txt` (CLI examples). Move to `.m` if you know MATLAB.

**Q: How do I add a new example?**
A: 
1. Write `.m` file (runnable MATLAB)
2. Test MatLabC++ CLI equivalent
3. Add to `.txt` with `[MATLAB EQUIVALENT]` flag
4. Optionally add to `.c` for documentation

---

**This multi-format approach gives users maximum flexibility while maintaining consistency across all documentation.**
