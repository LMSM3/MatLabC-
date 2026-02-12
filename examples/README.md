# MatLabC++ Examples Directory

Complete collection of working examples, tutorials, and use cases.

## Directory Structure

```
examples/
??? cli/                    # Command-line interface demos
?   ??? basic_usage.txt
?   ??? material_lookup.txt
?   ??? inference_demo.txt
?   ??? comparison.txt
??? python/                 # Python scripts
?   ??? quick_start.py
?   ??? material_selection.py
?   ??? temperature_analysis.py
?   ??? constraint_solving.py
??? cpp/                    # C++ programs
?   ??? basic_ode.cpp
?   ??? material_inference.cpp
?   ??? multi_material_analysis.cpp
?   ??? demo_pipeline.cpp      # Matmul + solve + deterministic export (CSV/JSON)
??? data/                   # Sample data files
?   ??? custom_materials.json
?   ??? test_data.csv
?   ??? experimental_alloys.json
??? tutorials/              # Step-by-step guides
?   ??? 01_first_calculation.md
?   ??? 02_material_database.md
?   ??? 03_inference_system.md
?   ??? 04_custom_materials.md
??? real_world/            # Engineering scenarios
    ??? drone_arm_design.py
    ??? 3d_print_material.py
    ??? heat_sink_selection.py
    ??? structural_beam.py
```

## Quick Navigation

### For Beginners
- Start with `tutorials/01_first_calculation.md`
- Try `cli/basic_usage.txt` examples
- Run `python/quick_start.py`

### For 3D Visualization (NEW!)
- **C++ Full-Featured:** `cpp/beam_stress_3d.cpp` - Material database + VTK export
- **C Script:** `scripts/beam_simple_3d.c` - Run via `./matlabcpp run ...`
- **MATLAB Script:** `scripts/beam_3d.m` - Octave compatible
- **Complete Guide:** `cpp/3D_VISUALIZATION_README.md`

### For Material Selection
- See `python/material_selection.py`
- Read `cli/material_lookup.txt`
- Study `real_world/3d_print_material.py`

### For Advanced Users
- Explore `cpp/material_inference.cpp`
- Check `python/constraint_solving.py`
- Review `real_world/` scenarios

---

All examples are runnable and tested. Copy-paste to get started!

## Usage

### CLI Examples
Copy commands from `cli/*.txt` files into your terminal:
```bash
cd build
./matlabcpp
# Then paste commands from examples
```

### Python Examples
Run Python scripts directly:
```bash
cd examples/python
python3 quick_start.py
python3 material_selection.py
```

### C++ Examples
Compile and run:
```bash
cd examples/cpp
g++ -std=c++20 -I../../include basic_ode.cpp -o basic_ode
./basic_ode
```

### Script Examples (NEW in v0.2.0)
Run `.m` (MATLAB) or `.c` (C) scripts directly via CLI:
```bash
cd build
./matlabcpp
>>> run examples/scripts/helix_plot.c
>>> run examples/scripts/helix_plot.m
>>> run examples/scripts/leakage_sim.c
>>> run examples/scripts/leakage_sim.m
```

Or quick-compile C scripts directly:
```bash
gcc -std=c99 -O2 -lm examples/scripts/helix_plot.c -o helix && ./helix
```

Or run MATLAB scripts with Octave:
```bash
octave --silent examples/scripts/helix_plot.m
```

**See `docs/SCRIPT_FORMAT_V0.2.0.md` for full documentation.**

### Install (build + stage to dist/)
```bash
./scripts/install.sh
./dist/bin/matlabcpp
```

## Example Output

All examples produce formatted output showing:
- Material properties and comparisons
- ODE solutions with time series
- Design recommendations with reasoning
- Performance metrics and trade-offs

## Contributing Examples

Add your own examples:
1. Follow existing structure
2. Include clear comments
3. Show expected output
4. Test before committing
