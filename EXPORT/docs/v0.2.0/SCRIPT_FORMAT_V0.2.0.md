# MatLabC++ v0.2.0 - Universal Script Format

## What Changed

MatLabC++ now accepts **both `.m` and `.c` files** as first-class script formats.

### Supported Formats

| Format | Description | Execution |
|--------|-------------|-----------|
| `.m` | MATLAB/Octave syntax | Runs via `octave` if available |
| `.c` | C source scripts | Quick-compiles with `gcc` then runs |

### New Script Handler

```cpp
#include <matlabcpp/script.hpp>

auto result = matlabcpp::script::run_script("helix_plot.c");
// or
auto result = matlabcpp::script::run_script("leakage_sim.m");

if (result.success) {
    std::cout << result.output;
} else {
    std::cerr << result.error;
}
```

---

## Examples

### Helix Plot

**C version (`helix_plot.c`):**
```c
#include <stdio.h>
#include <math.h>

int main() {
    const double pi = 3.14159265358979323846;
    for (int i = 0; i < 100; i++) {
        double t = (i / 100.0) * 10 * pi;
        printf("%.6f, %.6f, %.6f, %.6f\n", t, sin(t), cos(t), t);
    }
    return 0;
}
```

**MATLAB version (`helix_plot.m`):**
```matlab
t = 0:pi/50:10*pi;
x = sin(t); y = cos(t); z = t;
csvwrite('helix_data.csv', [t' x' y' z']);
```

Run either:
```bash
./matlabcpp run helix_plot.c
./matlabcpp run helix_plot.m
```

### Leaking Tank Simulation

**C version (`leakage_sim.c`):**
```c
#include <stdio.h>
#include <math.h>

double tankODE(double h, double Qin, double g, double Atank, double Ahole) {
    double Qout = Ahole * sqrt(2.0 * g * fmax(h, 0.0));
    return (Qin - Qout) / Atank;
}

int main() {
    const double g = 9.81, h0 = 2.0, Qin = 0.01;
    // ... simulation loop with Euler integration
    return 0;
}
```

**MATLAB version (`leakage_sim.m`):**
```matlab
tankODE = @(t,h) (Qin - Ahole * sqrt(2 * g * max(h,0))) / Atank;
[t,h] = ode45(tankODE, [0 100], h0);
plot(t, h);
```

---

## CLI Integration

Add to CLI parser:

```cpp
if (cmd == "run" && args.size() > 0) {
    auto result = matlabcpp::script::run_script(args[0]);
    if (result.success) {
        std::cout << result.output << "\n";
    } else {
        std::cerr << "Error: " << result.error << "\n";
        return result.exit_code;
    }
}
```

Usage:
```bash
matlabcpp run examples/scripts/helix_plot.c
matlabcpp run examples/scripts/leakage_sim.m
```

---

## Build Requirements

- **For `.c` scripts:** `gcc` or `clang` in PATH
- **For `.m` scripts:** `octave` or `matlab` in PATH

Scripts compile/run on-the-fly with no manual build step.

---

## Script Locations

```
examples/
  scripts/
    helix_plot.c        # C version
    helix_plot.m        # MATLAB version
    leakage_sim.c       # C version
    leakage_sim.m       # MATLAB version
```

---

## Migration from v0.1.x

### Before (v0.1.x)
- Only C++ programs: `g++ my_program.cpp`
- No script support

### After (v0.2.0)
- Drop-in `.c` or `.m` scripts: `matlabcpp run my_script.c`
- Automatic compile+run for C
- Automatic octave/matlab exec for .m

### Your Workflow Example

```bash
# Write mixed shell/C script
cat > my_analysis.c <<'EOF'
#include <stdio.h>
#include <math.h>
int main() {
    for (int i = 0; i < 10; i++) {
        printf("sin(%d) = %.4f\n", i, sin(i));
    }
    return 0;
}
EOF

# Run directly
matlabcpp run my_analysis.c

# Or use bash wrapper
echo "matlabcpp run my_analysis.c" > run_it.sh
bash run_it.sh
```

---

## Version Info

- **Version:** 0.2.0
- **Released:** 2025-01-22
- **Key Feature:** Universal `.m` and `.c` script execution
- **Backward Compatible:** Yes (existing C++ API unchanged)

---

Run `./scripts/install.sh` to build v0.2.0 with script support enabled.
