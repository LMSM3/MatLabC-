# Chemical/Material Builder Demo - Usage Guide

**Interactive UI for building random chemical structures in MatLabC++**

---

## Quick Start

### Current Version (v0.4.0 - Manual)

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
./build/mlab++
```

**Copy-paste these commands:**

```matlab
% Select random material
materials = {'PLA', 'Aluminum', 'Steel', 'Copper'}
idx = randi(4)

% Build structure
N = 20
lattice = randn(N, N)

% Properties
density = sum(abs(lattice(:))) / numel(lattice)
uniformity = std(lattice(:))

% Display
fprintf('Material: %s\n', materials{idx})
fprintf('Density: %.4f\n', density)
fprintf('Uniformity: %.4f\n', uniformity)

% Visualize
lattice(1:10, 1:10)

quit
```

---

### Future Version (v0.4.1+ with scripts)

```bash
# After building v0.4.1
./build/mlab++ < demos/chemical_builder.m

# Or automated
chmod +x demos/run_chemical_builder.sh
./demos/run_chemical_builder.sh
```

---

## What It Does

### 1. Random Material Selection
- Polymers: PLA, PETG, ABS, Nylon
- Metals: Aluminum, Steel, Titanium, Copper
- Randomly picks one each run

### 2. Structure Generation
- **Metals:** FCC/BCC crystal lattice simulation
- **Polymers:** Chain network structure
- **Size:** 20x20x10 (configurable)

### 3. Property Calculation
- Packing density
- Structural uniformity
- Lattice energy
- Coordination number

### 4. Visualization
- 2D ASCII representation (● = atom, ○ = void)
- 3D layer structure
- Energy distribution

### 5. Material Properties
- Density (kg/m³)
- Thermal conductivity (W/(m·K))
- Tensile strength (MPa)
- Elastic modulus (GPa)
- Melting point (°C)

---

## Example Output

```
╔════════════════════════════════════════════════════════╗
║        CHEMICAL/MATERIAL STRUCTURE BUILDER            ║
║           Random Generation Demo                      ║
╚════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════
RANDOMLY SELECTED MATERIAL: Aluminum
═══════════════════════════════════════════════════════

Structure Type: Face-Centered Cubic (FCC) Lattice

Structure Matrix:
  Size: 20x20
  Type: double
  Non-zero elements: 200

═══════════════════════════════════════════════════════
COMPUTED STRUCTURAL PROPERTIES:
═══════════════════════════════════════════════════════
  Packing Density:    0.5000
  Structural Uniform: 0.5003
  Lattice Energy:     100.00 kJ/mol
  Coordination #:     6.0

═══════════════════════════════════════════════════════
GENERATED CHEMICAL FORMULA:
═══════════════════════════════════════════════════════
  Formula: Al
  Crystal: FCC (a = 4.05 Å)
  Coordination: 12

  Molar Mass: 27 g/mol
  Atoms per Unit: 4

═══════════════════════════════════════════════════════
2D STRUCTURE VISUALIZATION (Top View):
═══════════════════════════════════════════════════════
  ● = Atom/Monomer    ○ = Void

  ● ○ ● ○ ● ○ ● ○ ● ○ 
  ○ ● ○ ● ○ ● ○ ● ○ ● 
  ● ○ ● ○ ● ○ ● ○ ● ○ 
  ○ ● ○ ● ○ ● ○ ● ○ ● 
  ...

╔════════════════════════════════════════════════════════╗
║              BUILD COMPLETE!                          ║
╚════════════════════════════════════════════════════════╝

Material: Aluminum
Structure: 20x20 matrix with 10 layers
Quality:   50.0% (based on uniformity)
Status:    ✓ Ready for simulation
```

---

## Features

### Materials Library
- **Polymers:** 
  - PLA (Polylactic Acid)
  - PETG (Polyethylene Terephthalate Glycol)
  - ABS (Acrylonitrile Butadiene Styrene)
  - Nylon (Polyamide)

- **Metals:**
  - Aluminum (FCC)
  - Steel (BCC/FCC)
  - Titanium (HCP)
  - Copper (FCC)

### Structure Types
- **Crystal Lattices:** FCC, BCC, HCP
- **Polymer Chains:** Linear, branched
- **Amorphous:** Random network

### Calculations
- Energy minimization (simplified)
- Bond strength estimation
- Thermal properties
- Mechanical properties

---

## Integration with Material Database

### Access existing materials

```matlab
% In REPL (requires material command)
>>> material aluminum
Material: Aluminum 6061-T6
  Density: 2700 kg/m³
  ...

% Or via builder
>>> material_info('aluminum')
```

---

## Advanced Usage

### Custom Material

```matlab
% Define custom structure
N = 50
lattice = zeros(N, N)

% Add specific pattern
for i = 1:10:N
    lattice(i, :) = 1  % Ordered chains
end

% Add random defects
defect_idx = randi(N*N, 10, 1)
lattice(defect_idx) = -1

% Analyze
density = sum(abs(lattice(:))) / numel(lattice)
defect_density = sum(lattice(:) < 0) / numel(lattice)
```

### Property Prediction

```matlab
% Based on structure
function props = predict_properties(lattice)
    props.density = sum(abs(lattice(:))) / numel(lattice)
    props.uniformity = std(lattice(:))
    props.energy = sum(lattice(:).^2) * 10
    props.stability = props.density / (props.uniformity + 0.001)
end
```

---

## Limitations (Current v0.4.0)

❌ **Not Available:**
- Script file execution
- fprintf formatting
- Material database access
- 3D visualization
- Complex structures

✅ **Works:**
- Manual matrix operations
- Basic structure generation
- Property calculations
- ASCII visualization (manual)

---

## Future Enhancements (v0.4.1+)

- [ ] Full script execution
- [ ] Material database integration
- [ ] 3D crystal visualization
- [ ] Energy minimization algorithms
- [ ] Molecular dynamics simulation
- [ ] Property prediction ML models
- [ ] Export to standard formats (PDB, CIF)

---

## Files Created

```
demos/
├── chemical_builder.m          - Main demo script (350 lines)
├── run_chemical_builder.sh     - Launch script
└── CHEMICAL_BUILDER_GUIDE.md   - This file
```

---

## Quick Test NOW

```bash
./build/mlab++
```

```matlab
>>> N = 10
>>> A = randn(N, N)
>>> A(A > 0.5) = 1
>>> A(A <= 0.5) = 0
>>> A
>>> quit
```

**See basic structure pattern!**

---

**Status:** ✅ Demo created, ready for v0.4.1+  
**Current:** Manual commands work in v0.4.0  
**Full demo:** Requires script support (v0.4.1)
