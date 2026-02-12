# Crystallography System Expansion Plan

## Current Status: Materials Database Exists, Crystallography Missing

**What We Have:**
- ✅ Material properties (density, strength, thermal)
- ✅ Smart material database with inference
- ✅ Temperature-dependent properties
- ✅ Material comparison and selection

**What's Missing:**
- ❌ Crystal structure data
- ❌ Lattice parameters (a, b, c, α, β, γ)
- ❌ Space groups and symmetry
- ❌ Unit cell information
- ❌ Miller indices and plane calculations
- ❌ Diffraction pattern calculations
- ❌ Crystal orientation and texture

---

## Phase 1: Core Crystallography Data Structure

### 1.1 Crystal System Classification

```cpp
// include/matlabcpp/crystallography.hpp

namespace matlabcpp {

enum class CrystalSystem {
    CUBIC,          // a=b=c, α=β=γ=90°
    TETRAGONAL,     // a=b≠c, α=β=γ=90°
    ORTHORHOMBIC,   // a≠b≠c, α=β=γ=90°
    HEXAGONAL,      // a=b≠c, α=β=90°, γ=120°
    TRIGONAL,       // a=b=c, α=β=γ≠90° (rhombohedral)
    MONOCLINIC,     // a≠b≠c, α=γ=90°≠β
    TRICLINIC       // a≠b≠c, α≠β≠γ
};

enum class BravaisLattice {
    CUBIC_P,        // Simple cubic (primitive)
    CUBIC_I,        // Body-centered cubic
    CUBIC_F,        // Face-centered cubic
    TETRAGONAL_P,   // Simple tetragonal
    TETRAGONAL_I,   // Body-centered tetragonal
    ORTHORHOMBIC_P, // Simple orthorhombic
    ORTHORHOMBIC_C, // Base-centered orthorhombic
    ORTHORHOMBIC_I, // Body-centered orthorhombic
    ORTHORHOMBIC_F, // Face-centered orthorhombic
    HEXAGONAL_P,    // Simple hexagonal
    TRIGONAL_R,     // Rhombohedral
    MONOCLINIC_P,   // Simple monoclinic
    MONOCLINIC_C,   // Base-centered monoclinic
    TRICLINIC_P     // Triclinic (only primitive)
};

// Lattice parameters
struct LatticeParameters {
    // Unit cell dimensions [Angstroms]
    double a = 0.0;
    double b = 0.0;
    double c = 0.0;
    
    // Unit cell angles [degrees]
    double alpha = 90.0;
    double beta = 90.0;
    double gamma = 90.0;
    
    // Temperature at which measured [K]
    double temp_K = 293.15;
    
    // Uncertainty
    double uncertainty_a = 0.0;
    
    // Data source
    std::string source = "internal";
    
    // Validation
    [[nodiscard]] bool is_valid() const {
        return a > 0 && b > 0 && c > 0 &&
               alpha > 0 && alpha < 180 &&
               beta > 0 && beta < 180 &&
               gamma > 0 && gamma < 180;
    }
    
    // Calculate unit cell volume [Angstrom³]
    [[nodiscard]] double volume() const {
        double cos_alpha = std::cos(alpha * M_PI / 180.0);
        double cos_beta = std::cos(beta * M_PI / 180.0);
        double cos_gamma = std::cos(gamma * M_PI / 180.0);
        
        return a * b * c * std::sqrt(
            1.0 - cos_alpha*cos_alpha 
                - cos_beta*cos_beta 
                - cos_gamma*cos_gamma 
                + 2.0 * cos_alpha * cos_beta * cos_gamma
        );
    }
    
    // Reciprocal lattice parameters
    [[nodiscard]] LatticeParameters reciprocal() const;
};

struct AtomicPosition {
    std::string element;     // "Fe", "C", "O"
    double x, y, z;          // Fractional coordinates (0-1)
    double occupancy = 1.0;  // Site occupancy
    std::string wyckoff;     // Wyckoff position (e.g., "4a", "8c")
    
    // Thermal parameters (Debye-Waller factor)
    double B_iso = 0.0;      // Isotropic temperature factor
};

} // namespace matlabcpp
```

### 1.2 Space Group Information

```cpp
struct SpaceGroup {
    int number;              // 1-230 (International Tables)
    std::string hermann_mauguin;  // "Fm-3m", "P63/mmc"
    std::string schoenflies;      // "Oh^5", "D6h^4"
    std::string hall;             // Hall symbol
    CrystalSystem system;
    BravaisLattice bravais;
    
    // Symmetry operations
    std::vector<std::string> symmetry_operations;
    int num_symmetry_ops;
    
    // Point group
    std::string point_group;
    
    // Special positions (Wyckoff)
    struct WyckoffPosition {
        std::string letter;       // "a", "b", "c", etc.
        int multiplicity;         // Number of equivalent positions
        std::string site_symmetry;
        std::vector<std::array<double, 3>> positions;  // Fractional coords
    };
    std::vector<WyckoffPosition> wyckoff_positions;
    
    // Static database
    [[nodiscard]] static const SpaceGroup& get(int number);
    [[nodiscard]] static std::optional<SpaceGroup> find(const std::string& symbol);
};
```

### 1.3 Complete Crystal Structure

```cpp
class CrystalStructure {
public:
    std::string name;              // "α-Fe (BCC Iron)", "Diamond"
    std::string chemical_formula;  // "Fe", "C", "SiO2"
    
    // Crystallographic data
    SpaceGroup space_group;
    LatticeParameters lattice;
    BravaisLattice bravais_type;
    
    // Atomic structure
    std::vector<AtomicPosition> atoms;
    int atoms_per_unit_cell;
    
    // Physical parameters
    double density;              // g/cm³ (calculated from structure)
    double molar_mass;           // g/mol
    
    // Temperature dependence
    struct ThermalExpansion {
        double alpha_a = 0.0;    // Linear expansion coefficient [1/K]
        double alpha_b = 0.0;
        double alpha_c = 0.0;
        double ref_temp = 293.15;
    } thermal_expansion;
    
    // Methods
    [[nodiscard]] double calculated_density() const;
    [[nodiscard]] LatticeParameters lattice_at_temp(double T_kelvin) const;
    [[nodiscard]] std::vector<AtomicPosition> apply_symmetry() const;
    [[nodiscard]] double nearest_neighbor_distance() const;
    
    // Miller indices utilities
    [[nodiscard]] double d_spacing(int h, int k, int l) const;
    [[nodiscard]] std::vector<int> allowed_reflections(double d_min) const;
    
    // Visualization
    [[nodiscard]] std::string to_cif() const;  // Crystallographic Information File
    [[nodiscard]] std::string to_pdb() const;  // Protein Data Bank format
};
```

---

## Phase 2: Common Crystal Structures Database

### 2.1 Built-In Structures

```cpp
class CrystalDatabase {
    std::unordered_map<std::string, CrystalStructure> structures_;
    
public:
    CrystalDatabase() {
        // Initialize with common structures
        add_common_metals();
        add_ceramics();
        add_semiconductors();
        add_minerals();
    }
    
private:
    void add_common_metals() {
        // FCC metals
        add_fcc("Al", 4.0495);   // Aluminum
        add_fcc("Cu", 3.6149);   // Copper
        add_fcc("Au", 4.0782);   // Gold
        add_fcc("Ag", 4.0853);   // Silver
        add_fcc("Ni", 3.5238);   // Nickel
        add_fcc("Pt", 3.9242);   // Platinum
        add_fcc("Pb", 4.9508);   // Lead
        
        // BCC metals
        add_bcc("Fe", 2.8665);   // α-Iron (ferrite)
        add_bcc("Cr", 2.8847);   // Chromium
        add_bcc("W",  3.1652);   // Tungsten
        add_bcc("Mo", 3.1472);   // Molybdenum
        add_bcc("V",  3.0399);   // Vanadium
        add_bcc("Nb", 3.3008);   // Niobium
        add_bcc("Ta", 3.3058);   // Tantalum
        
        // HCP metals
        add_hcp("Mg", 3.2094, 5.2105);  // Magnesium
        add_hcp("Ti", 2.9508, 4.6855);  // Titanium
        add_hcp("Zn", 2.6649, 4.9468);  // Zinc
        add_hcp("Cd", 2.9793, 5.6181);  // Cadmium
        add_hcp("Co", 2.5071, 4.0695);  // Cobalt
        add_hcp("Zr", 3.2316, 5.1477);  // Zirconium
    }
    
    void add_ceramics() {
        // Rocksalt (NaCl structure)
        add_rocksalt("NaCl", 5.6402);
        add_rocksalt("MgO",  4.2112);
        add_rocksalt("TiN",  4.2417);
        
        // Fluorite (CaF2 structure)
        add_fluorite("CaF2", 5.4631);
        add_fluorite("UO2",  5.4704);
        
        // Perovskite (cubic)
        add_perovskite("SrTiO3", 3.905);
        add_perovskite("BaTiO3", 4.004);
        
        // Spinel
        add_spinel("MgAl2O4", 8.0832);
        
        // Corundum (α-Al2O3)
        add_corundum("Al2O3", 4.7592, 12.9933);
    }
    
    void add_semiconductors() {
        // Diamond structure
        add_diamond("C",  3.5668);   // Diamond
        add_diamond("Si", 5.4310);   // Silicon
        add_diamond("Ge", 5.6579);   // Germanium
        
        // Zinc blende
        add_zincblende("GaAs", 5.6533);
        add_zincblende("InP",  5.8687);
        add_zincblende("GaN",  4.52);   // Cubic phase
        
        // Wurtzite
        add_wurtzite("GaN",  3.189, 5.185);  // Hexagonal phase
        add_wurtzite("ZnO",  3.2496, 5.2065);
        add_wurtzite("AlN",  3.112, 4.982);
    }
};
```

### 2.2 Structure Templates

```cpp
// Quick constructors for common structures
CrystalStructure create_fcc(const std::string& element, double a);
CrystalStructure create_bcc(const std::string& element, double a);
CrystalStructure create_hcp(const std::string& element, double a, double c);
CrystalStructure create_diamond(const std::string& element, double a);
CrystalStructure create_zincblende(const std::string& formula, double a);
CrystalStructure create_wurtzite(const std::string& formula, double a, double c);
CrystalStructure create_rocksalt(const std::string& formula, double a);
```

---

## Phase 3: Diffraction Calculations

### 3.1 X-Ray Diffraction

```cpp
struct DiffractionPeak {
    int h, k, l;              // Miller indices
    double d_spacing;         // Angstroms
    double theta;             // Bragg angle [degrees]
    double intensity;         // Relative intensity (0-100)
    int multiplicity;         // Number of equivalent planes
};

class XRayDiffraction {
public:
    struct XRaySource {
        std::string name;      // "Cu Kα", "Mo Kα"
        double wavelength;     // Angstroms
        double K_alpha1 = 0.0;
        double K_alpha2 = 0.0;
        double ratio_12 = 2.0; // Intensity ratio α1:α2
    };
    
    // Calculate diffraction pattern
    [[nodiscard]] std::vector<DiffractionPeak> calculate_pattern(
        const CrystalStructure& crystal,
        const XRaySource& source,
        double theta_min = 10.0,
        double theta_max = 90.0
    ) const;
    
    // Structure factor calculation
    [[nodiscard]] std::complex<double> structure_factor(
        const CrystalStructure& crystal,
        int h, int k, int l
    ) const;
    
    // Systematic absences (forbidden reflections)
    [[nodiscard]] bool is_allowed(
        const SpaceGroup& sg,
        int h, int k, int l
    ) const;
    
    // Common X-ray sources
    static const XRaySource Cu_K_alpha;  // 1.5406 Å
    static const XRaySource Mo_K_alpha;  // 0.7107 Å
    static const XRaySource Cr_K_alpha;  // 2.2897 Å
};
```

### 3.2 Powder Diffraction

```cpp
class PowderDiffraction {
public:
    struct Pattern {
        std::vector<double> two_theta;
        std::vector<double> intensity;
        std::string source;
        double wavelength;
    };
    
    // Generate theoretical pattern
    [[nodiscard]] Pattern calculate_powder_pattern(
        const CrystalStructure& crystal,
        const XRayDiffraction::XRaySource& source,
        double step_size = 0.02,
        double lorentz_width = 0.1
    ) const;
    
    // Peak finding
    [[nodiscard]] std::vector<DiffractionPeak> find_peaks(
        const Pattern& pattern,
        double threshold = 0.05
    ) const;
    
    // Phase identification
    [[nodiscard]] std::vector<std::pair<std::string, double>> identify_phases(
        const Pattern& experimental,
        const CrystalDatabase& db
    ) const;
};
```

---

## Phase 4: Integration with Materials Database

### 4.1 Extended SmartMaterial Class

```cpp
class SmartMaterial {
public:
    // ... existing properties ...
    
    // Crystallographic data (optional for non-crystalline materials)
    std::optional<CrystalStructure> crystal_structure;
    
    // Polymorphs (multiple crystal forms)
    std::vector<CrystalStructure> polymorphs;
    
    // Phase transitions
    struct PhaseTransition {
        std::string from_phase;
        std::string to_phase;
        double transition_temp;  // K
        double transition_pressure; // GPa
        std::string type;  // "martensitic", "displacive", "order-disorder"
    };
    std::vector<PhaseTransition> phase_transitions;
    
    // Methods
    [[nodiscard]] CrystalStructure crystal_at_temp(double T) const;
    [[nodiscard]] bool has_crystal_structure() const;
    [[nodiscard]] double theoretical_density() const;  // From crystal structure
};
```

### 4.2 Crystallography Query Interface

```cpp
class CrystallographyDB {
    CrystalDatabase crystals_;
    
public:
    // Query by material
    [[nodiscard]] std::optional<CrystalStructure> get_structure(
        const std::string& material
    ) const;
    
    // Query by space group
    [[nodiscard]] std::vector<CrystalStructure> find_by_space_group(
        int space_group_number
    ) const;
    
    // Query by system
    [[nodiscard]] std::vector<CrystalStructure> find_by_system(
        CrystalSystem system
    ) const;
    
    // Query by lattice parameter
    [[nodiscard]] std::vector<CrystalStructure> find_by_lattice(
        double a_min, double a_max,
        std::optional<double> c_a_ratio = std::nullopt
    ) const;
    
    // Density matching
    [[nodiscard]] std::vector<CrystalStructure> find_by_density(
        double density,
        double tolerance = 0.1
    ) const;
};
```

---

## Phase 5: MATLAB Interface Functions

### 5.1 Basic Queries

```matlab
% MatLabC++ Commands

% Get crystal structure
structure = crystal('Fe')
structure = crystal('BCC')
structure = crystal_fcc('Al', 4.05)

% Properties
structure.lattice.a
structure.space_group.number
structure.atoms_per_unit_cell

% Calculations
d = d_spacing(structure, [1 1 1])
vol = unit_cell_volume(structure)
rho = crystal_density(structure)

% List available structures
crystal_list()
crystal_list('metal')
crystal_list('cubic')
```

### 5.2 Diffraction

```matlab
% X-ray diffraction pattern
peaks = xrd(structure, 'Cu')
peaks = xrd(structure, 'wavelength', 1.5406)
peaks = xrd(structure, 'theta_range', [10 90])

% Display results
xrd_plot(peaks)
print_peaks(peaks)

% Powder diffraction
pattern = powder_xrd(structure, 'Cu', 'step', 0.02)
plot(pattern.two_theta, pattern.intensity)

% Phase identification
identify_phase(experimental_data, crystal_database)
```

### 5.3 Structure Analysis

```matlab
% Symmetry operations
ops = symmetry_operations(structure)
wyckoff = wyckoff_positions(structure)

% Neighbors
nn_dist = nearest_neighbor(structure)
coordination = coordination_number(structure)

% Transformations
structure_300K = structure_at_temp(structure, 300)
structure_1000K = structure_at_temp(structure, 1000)

% Export
export_cif(structure, 'output.cif')
export_pdb(structure, 'output.pdb')
```

---

## Phase 6: Data Sources and Validation

### 6.1 Trusted Sources for Crystal Data

**Primary Sources:**
1. **Crystallography Open Database (COD)** - crystallography.net
   - 500,000+ structures
   - Open access, peer-reviewed
   - API available

2. **Inorganic Crystal Structure Database (ICSD)**
   - Gold standard for inorganic crystals
   - Subscription required (academic)
   - Rigorous quality control

3. **American Mineralogist Crystal Structure Database**
   - minerals.gps.caltech.edu
   - Free access
   - High quality mineral data

4. **Pearson's Crystal Data**
   - Comprehensive commercial database
   - Metals and alloys focus

5. **Materials Project** - materialsproject.org
   - 150,000+ computed structures
   - DFT-calculated properties
   - API available (free)

### 6.2 Data Validation Checklist

For each crystal structure entry:

```cpp
struct CrystalValidation {
    // Geometric validation
    bool valid_lattice_params;     // a,b,c > 0; angles in (0,180)
    bool valid_space_group;        // Number 1-230
    bool valid_fractional_coords;  // x,y,z in [0,1]
    
    // Physical validation
    bool density_matches;          // Within 5% of experimental
    bool symmetry_consistent;      // Atoms respect space group
    
    // Data quality
    std::string source;            // COD, ICSD, etc.
    int confidence_level;          // 1-5
    std::string citation;          // DOI or reference
};
```

### 6.3 Automated Import

```cpp
class CrystalImporter {
public:
    // Import from CIF file
    [[nodiscard]] CrystalStructure from_cif(const std::string& filepath);
    
    // Import from COD
    [[nodiscard]] CrystalStructure from_cod(int cod_id);
    
    // Import from Materials Project
    [[nodiscard]] CrystalStructure from_mp(const std::string& mp_id);
    
    // Validate imported structure
    [[nodiscard]] CrystalValidation validate(const CrystalStructure& s);
};
```

---

## Implementation Timeline

### Week 1: Core Data Structures
- [ ] Implement `LatticeParameters` struct
- [ ] Implement `CrystalSystem` and `BravaisLattice` enums
- [ ] Implement `AtomicPosition` struct
- [ ] Implement `SpaceGroup` class with static database
- [ ] Unit tests for geometric calculations

### Week 2: CrystalStructure Class
- [ ] Complete `CrystalStructure` implementation
- [ ] Miller indices calculations
- [ ] d-spacing calculations
- [ ] Density calculations
- [ ] Temperature dependence

### Week 3: Common Structures Database
- [ ] FCC, BCC, HCP templates
- [ ] Diamond, zinc blende templates
- [ ] Add 50+ common structures
- [ ] Validation tests

### Week 4: Diffraction Calculations
- [ ] Structure factor calculations
- [ ] XRD pattern generation
- [ ] Powder diffraction patterns
- [ ] Peak finding algorithms

### Week 5: Integration with Materials
- [ ] Extend `SmartMaterial` class
- [ ] Link crystal data to materials
- [ ] Add phase transformation data
- [ ] Update `SmartMaterialDB`

### Week 6: MATLAB Interface
- [ ] Implement `crystal()` function
- [ ] Implement `xrd()` function
- [ ] Implement plotting functions
- [ ] Write usage examples

### Week 7: Data Import & Validation
- [ ] CIF parser
- [ ] COD API integration
- [ ] Materials Project API
- [ ] Validation system

### Week 8: Testing & Documentation
- [ ] Comprehensive unit tests
- [ ] Integration tests
- [ ] User documentation
- [ ] Example gallery

---

## File Structure

```
MatLabC++/
├── include/matlabcpp/
│   ├── crystallography.hpp         (Core structures)
│   ├── crystal_systems.hpp         (Enums and constants)
│   ├── space_groups.hpp            (Space group data)
│   ├── diffraction.hpp             (XRD calculations)
│   ├── crystal_database.hpp        (Structure database)
│   └── materials_smart.hpp         (Extended with crystal data)
├── src/
│   ├── crystallography.cpp
│   ├── space_groups.cpp            (Static database)
│   ├── diffraction.cpp
│   ├── crystal_database.cpp
│   └── crystal_templates.cpp       (FCC, BCC, etc.)
├── data/
│   ├── crystals/
│   │   ├── metals.json
│   │   ├── ceramics.json
│   │   ├── semiconductors.json
│   │   └── minerals.json
│   └── space_groups/
│       └── sg_database.json        (All 230 space groups)
├── tests/
│   ├── test_crystallography.cpp
│   ├── test_diffraction.cpp
│   └── test_crystal_database.cpp
└── docs/
    ├── CRYSTALLOGRAPHY_GUIDE.md
    ├── SPACE_GROUPS_REFERENCE.md
    └── XRD_TUTORIAL.md
```

---

## Success Criteria

### Minimum Viable Product (MVP)
- [ ] 50+ common crystal structures (metals, semiconductors, ceramics)
- [ ] Lattice parameter calculations
- [ ] d-spacing calculations for Miller indices
- [ ] Basic XRD pattern generation
- [ ] MATLAB query interface working

### Full Feature Set
- [ ] 200+ crystal structures
- [ ] Complete space group database (all 230)
- [ ] Powder diffraction simulation
- [ ] Phase identification
- [ ] Temperature-dependent structures
- [ ] CIF import/export
- [ ] Materials Project integration

### Quality Metrics
- [ ] All calculations match published data within 0.1%
- [ ] XRD patterns match experimental within 5%
- [ ] Code coverage > 90%
- [ ] Documentation complete
- [ ] Zero segfaults or crashes

---

## Testing Strategy

### Unit Tests
```cpp
TEST(Crystallography, LatticeVolume) {
    LatticeParameters cubic;
    cubic.a = cubic.b = cubic.c = 3.0;
    EXPECT_NEAR(cubic.volume(), 27.0, 1e-6);
}

TEST(Crystallography, DSpacing_FCC) {
    auto Al = create_fcc("Al", 4.0495);
    double d_111 = Al.d_spacing(1, 1, 1);
    EXPECT_NEAR(d_111, 2.338, 0.001);  // Published value
}

TEST(XRD, CopperKAlpha_Silicon) {
    auto Si = create_diamond("Si", 5.4310);
    auto peaks = xrd.calculate_pattern(Si, XRayDiffraction::Cu_K_alpha);
    // Check (111) peak at 2θ ≈ 28.44°
    EXPECT_NEAR(peaks[0].theta, 28.44, 0.1);
}
```

### Integration Tests
- Compare calculated XRD patterns with experimental data (PDF cards)
- Verify density calculations match experimental values
- Check space group symmetry operations generate correct atom positions

### Performance Tests
- Diffraction pattern calculation < 100ms
- Database query < 10ms
- Structure validation < 1ms

---

## Example Use Cases

### 1. Identify Unknown Phase from XRD
```matlab
% Load experimental data
exp = load_xrd('sample.xy');

% Identify phase
results = identify_phase(exp);
disp(results(1).name);          % "α-Fe (BCC Iron)"
disp(results(1).confidence);    % 0.95
disp(results(1).lattice.a);     % 2.866 Å
```

### 2. Calculate Theoretical Density
```matlab
% Get structure
structure = crystal('diamond');

% Calculate density
rho = crystal_density(structure);
disp(rho);  % 3.515 g/cm³ (matches diamond)
```

### 3. Thermal Expansion
```matlab
% Iron at room temperature
Fe_RT = crystal('Fe');
disp(Fe_RT.lattice.a);  % 2.8665 Å

% Iron at 1000 K
Fe_1000K = structure_at_temp(Fe_RT, 1000);
disp(Fe_1000K.lattice.a);  % ~2.90 Å (expanded)
```

### 4. Design Material by Structure
```matlab
% Find all FCC metals
fcc_metals = find_structures('bravais', 'FCC', 'category', 'metal');

% Filter by density
dense_fcc = filter_by_density(fcc_metals, 'min', 10);  % > 10 g/cm³

% Compare properties
compare_materials(dense_fcc);
```

---

## Next Steps After This Document

1. **Review with domain experts** - crystallographers, materials scientists
2. **Prioritize features** - what's critical for v0.4.0?
3. **Set up data sources** - COD API, Materials Project access
4. **Create test dataset** - 10-20 well-known structures for validation
5. **Prototype core classes** - start with `LatticeParameters` and `CrystalStructure`

---

## References

**Books:**
- International Tables for Crystallography, Vol. A (Space Groups)
- Kelly & Knowles, "Crystallography and Crystal Defects"
- Hammond, "The Basics of Crystallography and Diffraction"

**Databases:**
- Crystallography Open Database: http://crystallography.net/
- Materials Project: https://materialsproject.org/
- American Mineralogist: http://rruff.geo.arizona.edu/AMS/

**Standards:**
- CIF (Crystallographic Information File) format specification
- ICDD PDF-4 Database (powder diffraction)

---

**Status:** Planning complete, ready for implementation review.
**Target Release:** v0.4.0 or v0.5.0 depending on priority.
**Dependencies:** Materials database (already exists), basic array support (v0.3.2).
