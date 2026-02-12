# 3D Visualization Examples - MatLabC++ v0.2.0

**External Build 3D Output Programs**

Three approaches to generate and visualize 3D structural analysis data.

---

## Programs Overview

### 1. **beam_stress_3d.cpp** (Full-Featured C++)
- **Purpose:** Complete structural analysis with material database integration
- **Features:**
  - Material property lookup from database
  - Cantilever beam stress analysis (von Mises)
  - 3D mesh generation with displacement calculation
  - Multiple export formats (CSV, VTK, Python, Gnuplot)
  - Safety factor analysis
- **Build:** `g++ -std=c++20 -I../../include beam_stress_3d.cpp -o beam_stress_3d`
- **Run:** `./beam_stress_3d`
- **Output:** 
  - `beam_stress_3d.csv` - Raw data
  - `beam_stress_3d.vtk` - ParaView format
  - `view_beam_3d.py` - Python viewer (auto-generated)
  - `view_beam_3d.gp` - Gnuplot script (auto-generated)

### 2. **beam_simple_3d.c** (Standalone C Script)
- **Purpose:** Lightweight 3D stress visualization
- **Features:**
  - Pure C99 implementation
  - Self-contained material properties
  - Fast compilation and execution
  - Python viewer generation
- **Run (as script):** `./matlabcpp run examples/scripts/beam_simple_3d.c`
- **Run (compiled):** `gcc -std=c99 -O2 -lm beam_simple_3d.c -o beam && ./beam`
- **Output:**
  - `beam_3d.csv` - 3D mesh data
  - `view_3d.py` - Python viewer (auto-generated)

### 3. **beam_3d.m** (MATLAB/Octave Script)
- **Purpose:** MATLAB-syntax structural analysis
- **Features:**
  - Vector operations for mesh generation
  - Built-in 3D plotting (if GUI available)
  - CSV export for external tools
  - Octave compatible (no MATLAB license needed)
- **Run (as script):** `./matlabcpp run examples/scripts/beam_3d.m`
- **Run (direct):** `octave beam_3d.m`
- **Output:**
  - `beam_3d_matlab.csv` - Data export
  - `beam_3d_matlab.png` - Visualization (if GUI available)

---

## Quick Start

### Method 1: C++ (Recommended - Full Features)

```bash
cd examples/cpp
g++ -std=c++20 -I../../include beam_stress_3d.cpp -o beam_stress_3d
./beam_stress_3d

# Visualize with Python
python3 view_beam_3d.py

# Or with Gnuplot
gnuplot view_beam_3d.gp

# Or with ParaView (professional)
paraview beam_stress_3d.vtk
```

### Method 2: C Script (Fastest)

```bash
# Via MatLabC++ CLI
./matlabcpp
>>> run examples/scripts/beam_simple_3d.c

# View results
python3 view_3d.py
```

### Method 3: MATLAB Script (Familiar Syntax)

```bash
# Via MatLabC++ CLI
./matlabcpp
>>> run examples/scripts/beam_3d.m

# View results
octave --persist beam_3d.m  # Interactive mode
```

---

## Visualization Tools

### 1. Python (matplotlib) - **Recommended**
```bash
python3 view_beam_3d.py
```
**Pros:** Easy, interactive, publication-quality
**Cons:** Requires matplotlib

**Install matplotlib:**
```bash
pip install matplotlib numpy
```

### 2. Gnuplot - **Fast**
```bash
gnuplot view_beam_3d.gp
```
**Pros:** Fast, no dependencies (if gnuplot installed)
**Cons:** Less interactive

**Install gnuplot:**
```bash
sudo apt install gnuplot    # Ubuntu/Debian
brew install gnuplot        # macOS
```

### 3. ParaView - **Professional**
```bash
paraview beam_stress_3d.vtk
```
**Pros:** Industry-standard, powerful, 3D volume rendering
**Cons:** Large download (~500 MB)

**Install ParaView:**
```bash
sudo apt install paraview   # Ubuntu/Debian
brew install --cask paraview  # macOS
# Or download: https://www.paraview.org/download/
```

### 4. MATLAB/Octave - **Built-in**
```matlab
data = csvread('beam_stress_3d.csv', 1, 0);
scatter3(data(:,1), data(:,2), data(:,3), 10, data(:,4), 'filled');
colorbar;
xlabel('Length (m)');
ylabel('Width (m)');
zlabel('Height (m)');
title('Stress (MPa)');
```

### 5. Online Viewers - **No Installation**
Upload CSV to:
- **Plotly Chart Studio** - chart-studio.plotly.com
- **Google Colab** - colab.research.google.com
- **Jupyter** - jupyter.org/try

---

## Understanding the Output

### Data Format (CSV)

```csv
x,y,z,stress_MPa,displacement_mm
0.000000, 0.000000, 0.050000, 0.000, 0.000000
0.050000, 0.000000, 0.050000, 24.510, 0.002345
0.100000, 0.000000, 0.050000, 44.118, 0.008932
...
```

**Columns:**
- `x` - Position along beam length (m)
- `y` - Position across width (m)
- `z` - Position along height (m)
- `stress_MPa` - von Mises stress (MPa)
- `displacement_mm` - Vertical deflection (mm)

### Physics Behind the Visualization

**Cantilever Beam:**
```
Fixed End |=================> Load (F)
          |                   
          |------ Length (L) ------>
```

**Key Equations:**

1. **Bending Moment:** `M(x) = F * (L - x)`
2. **Bending Stress:** `σ = M * c / I`
   - `c` = distance from neutral axis
   - `I` = second moment of area = `(w * h³) / 12`
3. **Deflection:** `v(x) = (F * x²) / (6 * E * I) * (3L - x)`

**Color Coding:**
- **Blue** → Low stress (< 20% yield)
- **Cyan** → Moderate stress (20-40%)
- **Green** → Elevated stress (40-60%)
- **Yellow** → High stress (60-80%)
- **Red** → Critical stress (> 80% yield)

---

## Modifying the Examples

### Change Material

**In C++ (beam_stress_3d.cpp):**
```cpp
// Line 286: Change material name
auto mat = get_material("steel");     // Try: aluminum_6061, peek, nylon6
```

**In C (beam_simple_3d.c):**
```c
// Lines 143-147: Modify properties
Material steel = {
    .name = "Steel A36",
    .youngs_modulus = 200e9,
    .yield_strength = 250e6
};
```

**In MATLAB (beam_3d.m):**
```matlab
% Lines 11-14: Change properties
material.E = 200e9;       % Steel
material.yield = 250e6;
```

### Change Geometry

**All programs:**
```c
double length = 2.0;    // Try: 0.5 to 5.0 meters
double width = 0.10;    // Try: 0.02 to 0.20 meters
double height = 0.15;   // Try: 0.05 to 0.30 meters
double load = 2000.0;   // Try: 100 to 10000 Newtons
```

### Change Resolution

Higher resolution = more points = better visualization (but slower):

```c
int resolution = 30;    // Try: 10 (fast) to 50 (detailed)
```

**Point count formula:** `resolution * (resolution/2) * (resolution*2)`
- Resolution 10 → 1,000 points
- Resolution 20 → 8,000 points
- Resolution 30 → 27,000 points
- Resolution 50 → 125,000 points

---

## Use Cases

### 1. Material Selection
Run the same geometry with different materials to compare:

```bash
# Aluminum
sed -i 's/get_material(".*")/get_material("aluminum_6061")/' beam_stress_3d.cpp
make && ./beam_stress_3d

# Steel
sed -i 's/get_material(".*")/get_material("steel")/' beam_stress_3d.cpp
make && ./beam_stress_3d

# Compare safety factors
```

### 2. Design Optimization
Iterate on geometry to minimize weight while maintaining safety factor:

```bash
for h in 0.05 0.08 0.10 0.12 0.15; do
    sed -i "s/double height = .*/double height = $h;/" beam_stress_3d.cpp
    make && ./beam_stress_3d | grep "Safety factor"
done
```

### 3. Failure Analysis
Increase load until safety factor < 1.0:

```bash
for load in 500 1000 1500 2000 2500; do
    sed -i "s/double load = .*/double load = $load;/" beam_stress_3d.cpp
    make && ./beam_stress_3d
done
```

### 4. Educational Demo
Show students how stress varies along beam:

```bash
# Generate visualization
./beam_stress_3d
python3 view_beam_3d.py  # Interactive 3D plot

# Point out:
# - Stress highest at fixed end
# - Stress maximum at outer fibers (top/bottom)
# - Displacement maximum at free end
```

---

## Troubleshooting

### "Material not found"
**Problem:** Material database not initialized  
**Solution:** 
```cpp
system().initialize();  // Add before get_material()
```

### "Cannot open output file"
**Problem:** No write permissions  
**Solution:**
```bash
chmod +w .
mkdir -p output && cd output
../beam_stress_3d
```

### Python viewer shows nothing
**Problem:** matplotlib backend issue  
**Solution:**
```bash
# Try different backend
export MPLBACKEND=TkAgg
python3 view_beam_3d.py

# Or use non-interactive backend
sed -i '1a import matplotlib\nmatplotlib.use("Agg")' view_beam_3d.py
```

### Octave crashes
**Problem:** No display for plotting  
**Solution:**
```matlab
% Edit beam_3d.m, comment out figure commands
% Or run in headless mode:
octave --no-gui beam_3d.m
```

### VTK file won't open
**Problem:** Wrong ParaView version  
**Solution:** VTK format is ASCII, check with:
```bash
head -20 beam_stress_3d.vtk
```

---

## Performance

### Benchmark (on typical laptop)

| Resolution | Points  | Generate | Python | Gnuplot | ParaView |
|------------|---------|----------|--------|---------|----------|
| 10         | 1,000   | 0.05s    | 0.5s   | 0.2s    | 1.0s     |
| 20         | 8,000   | 0.15s    | 1.2s   | 0.4s    | 1.5s     |
| 30         | 27,000  | 0.40s    | 2.5s   | 0.8s    | 2.0s     |
| 50         | 125,000 | 1.50s    | 8.0s   | 2.0s    | 3.5s     |

**Recommendation:** Use resolution 20-30 for interactive work, 50 for final visualization.

---

## Next Steps

1. **Try all three approaches** - See which syntax you prefer
2. **Experiment with parameters** - Change materials, geometry, load
3. **Add more materials** - See `MATERIALS_DATABASE.md` for how to extend
4. **Create your own analysis** - Use these as templates
5. **Share your results** - Contribute examples to the repository

---

## Advanced: Batch Processing

### Generate Multiple Scenarios

```bash
#!/bin/bash
# generate_all_materials.sh

for material in aluminum_6061 steel peek nylon6; do
    echo "Analyzing $material..."
    sed -i "s/get_material(\".*\")/get_material(\"$material\")/" beam_stress_3d.cpp
    make clean && make
    ./beam_stress_3d
    mv beam_stress_3d.png ${material}_beam.png
    echo "Saved: ${material}_beam.png"
done

# Create comparison montage
montage *_beam.png -geometry +5+5 -tile 2x2 all_materials_comparison.png
```

### Parametric Study

```python
#!/usr/bin/env python3
# parametric_study.py

import subprocess
import pandas as pd
import numpy as np

results = []

for length in np.linspace(0.5, 3.0, 10):
    for height in np.linspace(0.05, 0.20, 10):
        # Modify source
        with open('beam_stress_3d.cpp', 'r') as f:
            code = f.read()
        
        code = code.replace('double length = 1.0', f'double length = {length}')
        code = code.replace('double height = 0.10', f'double height = {height}')
        
        with open('beam_stress_3d.cpp', 'w') as f:
            f.write(code)
        
        # Build and run
        subprocess.run(['g++', '-std=c++20', '-I../../include', 
                       'beam_stress_3d.cpp', '-o', 'beam_stress_3d'])
        output = subprocess.check_output(['./beam_stress_3d']).decode()
        
        # Parse safety factor
        for line in output.split('\n'):
            if 'Safety factor' in line:
                sf = float(line.split(':')[1].strip())
                results.append({'length': length, 'height': height, 'safety': sf})

# Create heatmap
df = pd.DataFrame(results)
df.to_csv('parametric_results.csv', index=False)
print("Results saved: parametric_results.csv")
```

---

## References

- **Beam Theory:** Gere & Timoshenko, "Mechanics of Materials"
- **FEA Concepts:** Zienkiewicz & Taylor, "The Finite Element Method"
- **Material Properties:** ASM Handbook Vol. 1-2
- **Visualization:** ParaView User Guide, matplotlib documentation

---

**MatLabC++ v0.2.0** - Making structural analysis accessible with beautiful 3D visualizations.

Questions? See `docs/SCRIPT_FORMAT_V0.2.0.md` or examples/README.md
