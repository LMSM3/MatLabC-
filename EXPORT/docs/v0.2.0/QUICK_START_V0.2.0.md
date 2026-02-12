# MatLabC++ v0.2.0 - Quick Start Guide

**5-Minute Guide to Universal Script Execution**

---

## What is v0.2.0?

MatLabC++ now accepts **both MATLAB (.m) and C (.c) files** as runnable scripts.

**Before v0.2.0:**
```bash
# Had to compile C programs manually
gcc my_program.c -o my_program
./my_program
```

**With v0.2.0:**
```bash
./matlabcpp
>>> run my_program.c    # Auto-compiles and runs!
```

---

## Installation

### 1. Build MatLabC++
```bash
git clone <repo>
cd MatLabC++
./scripts/build_cpp.sh
```

### 2. Install Dependencies (Optional)
```bash
# For C script support (usually pre-installed):
sudo apt install gcc

# For MATLAB script support:
sudo apt install octave
```

---

## Your First Scripts

### Try the Built-in Examples

#### C Script: 3D Helix
```bash
cd build
./matlabcpp
>>> run examples/scripts/helix_plot.c
```

**Output:** CSV data for 3D helix (t, x=sin(t), y=cos(t), z=t)

#### MATLAB Script: Same Helix
```bash
>>> run examples/scripts/helix_plot.m
```

**Output:** Identical CSV data, MATLAB syntax

#### ODE Simulation: Leaking Tank
```bash
>>> run examples/scripts/leakage_sim.c     # C version (Euler)
>>> run examples/scripts/leakage_sim.m     # MATLAB version (ode45)
```

---

## Create Your Own Scripts

### Example 1: Simple C Script

**File:** `hello.c`
```c
#include <stdio.h>
#include <math.h>

int main() {
    printf("The answer is: %.2f\n", 6 * 7);
    printf("π ≈ %.6f\n", M_PI);
    return 0;
}
```

**Run:**
```bash
./matlabcpp
>>> run hello.c
```

**Output:**
```
Executing hello.c...
The answer is: 42.00
π ≈ 3.141593
```

### Example 2: Simple MATLAB Script

**File:** `hello.m`
```matlab
fprintf('The answer is: %.2f\n', 6 * 7);
fprintf('π ≈ %.6f\n', pi);
```

**Run:**
```bash
>>> run hello.m
```

**Output:** (Same as C version)

---

## Common Use Cases

### 1. Quick Numerical Experiment

**Want to test an idea in C?**

```bash
echo '#include <stdio.h>
#include <math.h>
int main() {
    for (int i = 0; i < 10; i++) {
        printf("%d: %.4f\n", i, exp(-i * 0.5));
    }
    return 0;
}' > decay.c

./matlabcpp
>>> run decay.c
```

No manual compilation needed!

### 2. Port MATLAB Code

**Have existing MATLAB code?**

Just run it:
```bash
>>> run my_matlab_script.m
```

No MATLAB license required (uses Octave).

### 3. Compare C vs MATLAB Performance

```bash
>>> run algorithm.c       # C version
>>> run algorithm.m       # MATLAB version
```

Both produce same output - which is faster?

---

## How It Works

### C Scripts (.c)
1. MatLabC++ detects `.c` extension
2. Compiles to `/tmp/script_exec` using gcc
3. Runs the executable
4. Captures output
5. Cleans up temporary files

**Benefits:**
- Native C performance
- Type safety (gcc catches errors)
- Full C99/C11 feature support
- No manual compilation step

### MATLAB Scripts (.m)
1. MatLabC++ detects `.m` extension
2. Calls `octave --silent --eval` with your script
3. Captures output
4. Returns results

**Benefits:**
- MATLAB syntax (ode45, plot, matrix ops)
- No MATLAB license required
- Octave's extensive library
- Instant execution (no compilation)

---

## Command Reference

### Inside MatLabC++ CLI

```bash
./matlabcpp
>>> help                           # Show all commands
>>> run <script>                   # Execute .c or .m script
>>> run examples/scripts/helix_plot.c
>>> run examples/scripts/leakage_sim.m
>>> exit                           # Quit
```

### Direct Execution (Alternative)

**C scripts:**
```bash
gcc -std=c99 -O2 -lm my_script.c -o my_script && ./my_script
```

**MATLAB scripts:**
```bash
octave --silent my_script.m
```

---

## Troubleshooting

### "gcc: command not found"
Install gcc:
```bash
sudo apt install gcc       # Ubuntu/Debian
brew install gcc           # macOS
```

### "octave: command not found"
Install Octave (only needed for .m scripts):
```bash
sudo apt install octave    # Ubuntu/Debian
brew install octave        # macOS
```

### "Script execution failed"
Check for:
- Typos in file path
- Syntax errors (gcc will report them)
- Missing #include statements
- Wrong file extension (.c or .m required)

### Script output is empty
- Make sure your script prints to stdout (printf/fprintf)
- Check that script has executable logic in main()
- Verify script compiles manually: `gcc -std=c99 your_script.c`

---

## Examples Directory

All examples are in `examples/scripts/`:

```
examples/scripts/
├── helix_plot.c        # 3D parametric curve (C)
├── helix_plot.m        # 3D parametric curve (MATLAB)
├── leakage_sim.c       # ODE simulation (C)
└── leakage_sim.m       # ODE simulation (MATLAB)
```

**Try them all:**
```bash
./matlabcpp
>>> run examples/scripts/helix_plot.c
>>> run examples/scripts/helix_plot.m
>>> run examples/scripts/leakage_sim.c
>>> run examples/scripts/leakage_sim.m
```

---

## Next Steps

### Learn More
- Read `docs/SCRIPT_FORMAT_V0.2.0.md` for full documentation
- Study `examples/MATLAB_vs_MatLabCPP.md` for language comparison
- Check `docs/V0.2.0_RELEASE_SUMMARY.md` for complete release notes

### Create Your Own
1. Write a C or MATLAB script
2. Save as `.c` or `.m`
3. Run with `>>> run your_script.c` or `>>> run your_script.m`

### Share
- Add your scripts to `examples/scripts/`
- Contribute to the repository
- Help others learn!

---

## Why v0.2.0?

### The Old Way
```bash
# Write C code
vim my_calc.c

# Compile
gcc my_calc.c -o my_calc

# Run
./my_calc

# Edit and repeat...
vim my_calc.c
gcc my_calc.c -o my_calc
./my_calc
```

### The New Way (v0.2.0)
```bash
# Write C code
vim my_calc.c

# Run directly (compilation is automatic)
./matlabcpp
>>> run my_calc.c

# Edit and repeat...
vim my_calc.c
>>> run my_calc.c        # Auto-recompiles!
```

**Same for MATLAB:**
```bash
vim my_calc.m
>>> run my_calc.m
```

---

## Summary

**What you get:**
- ✅ Run C scripts without manual compilation
- ✅ Run MATLAB scripts without MATLAB license
- ✅ Choose syntax based on what feels natural
- ✅ Zero breaking changes (all v0.1.x code still works)
- ✅ Full type safety (C) or high-level syntax (MATLAB)

**What you need:**
- gcc (for C scripts)
- octave (optional, for MATLAB scripts)
- MatLabC++ v0.2.0

**Get started in 5 minutes:**
```bash
./scripts/build_cpp.sh
./build/matlabcpp
>>> run examples/scripts/helix_plot.c
>>> run examples/scripts/helix_plot.m
```

---

**MatLabC++ v0.2.0 - Universal Script Engine**  
_The language that feels natural to you._

**Questions?** Read `docs/SCRIPT_FORMAT_V0.2.0.md`  
**Issues?** Check `docs/V0.2.0_CHECKLIST.md`  
**Deep dive?** See `docs/V0.2.0_RELEASE_SUMMARY.md`
