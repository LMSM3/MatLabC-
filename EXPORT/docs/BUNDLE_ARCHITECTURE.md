# MatLabC++ Self-Extracting Bundle System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DEVELOPER WORKFLOW                              │
└─────────────────────────────────────────────────────────────────────────┘

    ┌─── Create Demos ──────────────────────────────────────────┐
    │                                                            │
    │  vim matlab_examples/basic_demo.m                          │
    │  vim matlab_examples/materials_lookup.m                    │
    │  vim matlab_examples/gpu_benchmark.m                       │
    │  (6 total demo files)                                      │
    │                                                            │
    └────────────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
    ┌─── Generate Bundle ───────────────────────────────────────┐
    │                                                            │
    │  $ ./scripts/generate_examples_bundle.sh                   │
    │                                                            │
    │  Process:                                                  │
    │   1. Validate matlab_examples/ has .m files                │
    │   2. Read template: mlabpp_examples_bundle.sh              │
    │   3. Archive: tar -czf - matlab_examples/*.m               │
    │   4. Encode: base64                                        │
    │   5. Append to template after __PAYLOAD_BELOW__            │
    │   6. chmod +x dist/mlabpp_examples_bundle.sh               │
    │                                                            │
    │  Output: dist/mlabpp_examples_bundle.sh (50 KB)            │
    │                                                            │
    └────────────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
    ┌─── Test Bundle ───────────────────────────────────────────┐
    │                                                            │
    │  $ ./scripts/test_bundle_system.sh                         │
    │                                                            │
    │  Tests:                                                    │
    │   ✓ Prerequisites check                                    │
    │   ✓ Bundle generation                                      │
    │   ✓ Contents verification                                  │
    │   ✓ Installation test                                      │
    │   ✓ Annotation verification                                │
    │   ✓ Idempotency test                                       │
    │                                                            │
    │  All tests pass ✓                                          │
    │                                                            │
    └────────────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
    ┌─── Distribute ────────────────────────────────────────────┐
    │                                                            │
    │  • Web server:                                             │
    │    scp dist/mlabpp_examples_bundle.sh server:/www/         │
    │                                                            │
    │  • GitHub release:                                         │
    │    gh release upload v1.0 dist/mlabpp_examples_bundle.sh   │
    │                                                            │
    │  • Email attachment:                                       │
    │    (Safe text file, ~50 KB)                                │
    │                                                            │
    │  • Direct download:                                        │
    │    https://example.com/mlabpp_examples_bundle.sh           │
    │                                                            │
    └────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│                          USER WORKFLOW                                  │
└─────────────────────────────────────────────────────────────────────────┘

    ┌─── Download ──────────────────────────────────────────────┐
    │                                                            │
    │  $ curl -O https://example.com/mlabpp_examples_bundle.sh   │
    │                                                            │
    │  or                                                        │
    │                                                            │
    │  $ wget https://example.com/mlabpp_examples_bundle.sh      │
    │                                                            │
    │  Single file: 50 KB                                        │
    │                                                            │
    └────────────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
    ┌─── Install ───────────────────────────────────────────────┐
    │                                                            │
    │  $ bash mlabpp_examples_bundle.sh                          │
    │                                                            │
    │  Process:                                                  │
    │   1. Create ./examples/ directory                          │
    │   2. Extract payload:                                      │
    │      awk → base64 -d → tar -xz                             │
    │   3. Annotate each .m file with install info               │
    │   4. Print success message + run instructions              │
    │   5. Self-delete (if from temp location)                   │
    │                                                            │
    │  Time: 1 second                                            │
    │                                                            │
    └────────────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
    ┌─── Run Demos ─────────────────────────────────────────────┐
    │                                                            │
    │  $ cd examples                                             │
    │  $ ls -la                                                  │
    │    basic_demo.m                                            │
    │    materials_lookup.m                                      │
    │    materials_optimization.m                                │
    │    gpu_benchmark.m                                         │
    │    signal_processing.m                                     │
    │    linear_algebra.m                                        │
    │                                                            │
    │  $ mlab++ materials_lookup.m --visual                      │
    │                                                            │
    │  Output:                                                   │
    │    MatLabC++ Materials Database Demo                       │
    │    ================================                         │
    │    1. Basic Material Lookup                                │
    │    Material: Aluminum 6061-T6                              │
    │    Density: 2700 kg/m³                                     │
    │    Young's Modulus: 68.9 GPa                               │
    │    ...                                                     │
    │                                                            │
    └────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│                        BUNDLE FILE STRUCTURE                            │
└─────────────────────────────────────────────────────────────────────────┘

mlabpp_examples_bundle.sh:
╔═══════════════════════════════════════════════════════════════════════╗
║ #!/usr/bin/env bash                                                   ║
║ # Self-extracting installer                                           ║
║                                                                        ║
║ set -euo pipefail                                                      ║
║                                                                        ║
║ INSTALL_ROOT="${1:-$(pwd)}"                                            ║
║ EXAMPLES_DIR="${INSTALL_ROOT%/}/examples"                              ║
║                                                                        ║
║ # Create directory                                                     ║
║ mkdir -p "$EXAMPLES_DIR"                                               ║
║                                                                        ║
║ # Extract payload                                                      ║
║ _payload_extract() {                                                   ║
║   awk 'BEGIN{p=0} /^__PAYLOAD_BELOW__$/ {p=1; next} {if(p) print}'    ║
║     "$SELF_PATH" \                                                     ║
║     | base64 -d \                                                      ║
║     | tar -xz -C "$EXAMPLES_DIR"                                       ║
║ }                                                                      ║
║                                                                        ║
║ _payload_extract                                                       ║
║                                                                        ║
║ # Annotate files                                                       ║
║ for f in "$EXAMPLES_DIR"/*.m; do                                       ║
║   # Prepend install note to each file                                  ║
║   ...                                                                  ║
║ done                                                                   ║
║                                                                        ║
║ echo "✓ Installed to: $EXAMPLES_DIR"                                   ║
║                                                                        ║
║ # Self-delete logic                                                    ║
║ if is_tempish; then rm -f "$SELF_PATH"; fi                             ║
║                                                                        ║
║ __PAYLOAD_BELOW__                                                      ║
╠═══════════════════════════════════════════════════════════════════════╣
║ H4sIAAAAAAAAA+1ba3PbNhL+vr8CM51Lk0nGjizZdhK3k0wnnXZ6c7177+bbwCJI        ║
║ ooYICgAlK/31dwGSlGRHdtK7a9tpmomNB4DdxeOBBYD//s//+PDz4uLJ/v7+02fP      ║
║ nj7b33/2fP/Zs/0nTw72Dw4O9p8e7D89OHj65OnBwf7BwcH+/v7+/sHBk/39g/2D       ║
║ g4Onh08enuzv7z85PDw42N8/fHKw//Tg4ODgycH+/pOD/ScH+08PD5/s7z85PDx4       ║
║ cn1wdP/p4cHh/tODJ/v7h4dPD/b3nx4+Pdjff3J4+GT/6cHT/ScHTw4P9vefPjk8      ║
║ fPrk8PDJ/v7+08PD/f39J0+eHBw+Pdjff3r49ODJ/v7h4ZODp/tPD/b3n+wfPDk8      ║
║ 2N9/evDkyeH+/sHT/YODw4ODp08O9vcP9p8+2d/ff/rk8PDJ/v7B/tP9g4Mnhwf7      ║
║ +wdPnhwcPj08fLL/5ODgycH+/v7hk8PDJ4eH+/v7T/eff3Dw9ODw8Mnh4f7B/v7B      ║
║ ... (base64-encoded tar.gz continues for ~40 KB)                       ║
╚═══════════════════════════════════════════════════════════════════════╝

Size breakdown:
  - Bash header: ~8 KB (100 lines)
  - Base64 payload: ~42 KB (compressed 26 KB → 42 KB after base64)
  - Total: ~50 KB


┌─────────────────────────────────────────────────────────────────────────┐
│                      MATERIALS DATABASE INTEGRATION                     │
└─────────────────────────────────────────────────────────────────────────┘

materials_lookup.m demonstrates:
┌──────────────────────────────────────────────────────────────────────┐
│ 1. Basic Lookup                                                      │
│    material = material_get('aluminum_6061')                          │
│    → Returns full material with all properties                       │
│                                                                      │
│ 2. Smart Inference                                                   │
│    result = material_infer_density(2700, 100)                        │
│    → Infers "aluminum_6061" from density alone                       │
│    → Confidence: 0.95                                                │
│                                                                      │
│ 3. Constraint Selection                                              │
│    candidates = material_select(criteria, 'strength_to_weight')      │
│    → Returns ranked materials meeting all constraints                │
│    → Optimized for specific objective                                │
│                                                                      │
│ 4. Comparison                                                        │
│    comparison = material_compare({'aluminum_6061', 'steel'})         │
│    → Side-by-side property table                                     │
│    → Winner and reasoning                                            │
│                                                                      │
│ 5. Recommendations                                                   │
│    rec = material_recommend('3d_printing', 'cost_effective')         │
│    → Best material for application                                   │
│    → Alternatives listed                                             │
│                                                                      │
│ 6. Temperature Analysis                                              │
│    k = material_prop_at_temp(aluminum, 'thermal_conductivity', 373)  │
│    → Temperature-dependent property lookup                           │
└──────────────────────────────────────────────────────────────────────┘

materials_optimization.m shows:
┌──────────────────────────────────────────────────────────────────────┐
│ Real Engineering Design Problem: Drone Frame Arm                     │
│                                                                      │
│ Given:                                                               │
│  - Length: 250 mm                                                    │
│  - Load: 5 N                                                         │
│  - Max deflection: 2 mm                                              │
│  - Temp range: -20°C to 60°C                                         │
│  - Max cost: $5                                                      │
│                                                                      │
│ Process:                                                             │
│  1. Calculate required Young's modulus from deflection               │
│  2. Query database with constraints                                  │
│  3. Multi-objective optimization (weight, cost, performance)         │
│  4. Temperature-dependent analysis across range                      │
│  5. Safety factor calculation                                        │
│  6. Compare alternatives                                             │
│                                                                      │
│ Result:                                                              │
│  - Optimal material selected                                         │
│  - Weight, cost, safety factor calculated                            │
│  - Verified across temperature range                                 │
│  - Alternatives compared                                             │
└──────────────────────────────────────────────────────────────────────┘

Links to C++ implementation:
  include/matlabcpp/materials_smart.hpp
  src/materials_smart.cpp
  examples/materials_smart_demo.cpp


┌─────────────────────────────────────────────────────────────────────────┐
│                        COMPLETE FILE TREE                               │
└─────────────────────────────────────────────────────────────────────────┘

MatLabC++/
│
├── scripts/                         ← Bundle generation system
│   ├── mlabpp_examples_bundle.sh         Template installer (~8 KB)
│   ├── generate_examples_bundle.sh       Generator script (~3 KB)
│   ├── test_bundle_system.sh             Integration tests (~5 KB)
│   └── README.md                          Technical documentation
│
├── matlab_examples/                 ← Source demo files
│   ├── basic_demo.m                      Matrix operations
│   ├── materials_lookup.m                Materials database queries
│   ├── materials_optimization.m          Engineering design
│   ├── gpu_benchmark.m                   GPU acceleration
│   ├── signal_processing.m               DSP pipeline
│   └── linear_algebra.m                  Decompositions, solvers
│
├── dist/                            ← Generated bundles
│   └── mlabpp_examples_bundle.sh         Self-extracting bundle (50 KB)
│
├── include/matlabcpp/               ← C++ headers
│   ├── materials_smart.hpp               Smart materials database
│   ├── materials.hpp                     Basic materials
│   └── advanced.hpp                      Advanced features
│
├── src/                             ← C++ implementation
│   └── materials_smart.cpp               Materials database impl
│
├── examples/                        ← C++ examples
│   └── materials_smart_demo.cpp          C++ materials demo
│
├── EXAMPLES_BUNDLE.md               ← User guide (~15 KB)
├── BUNDLE_QUICKREF.md               ← Quick reference (~3 KB)
├── BUNDLE_INTEGRATION.md            ← Integration summary (~18 KB)
├── MATERIALS_DATABASE.md            ← Materials system guide
├── INSTALL_OPTIONS.md               ← Installation methods (updated)
├── README.md                        ← Main README (updated)
└── README_NEW.md                    ← New README (updated)


┌─────────────────────────────────────────────────────────────────────────┐
│                          KEY STATISTICS                                 │
└─────────────────────────────────────────────────────────────────────────┘

Bundle System:
  - Total code: ~16 KB (3 bash scripts)
  - Documentation: ~36 KB (4 markdown files)
  - Demo files: ~26 KB (6 MATLAB files)
  - Generated bundle: ~50 KB (single distributable file)

Integration:
  - Materials database: ✓ Full integration
  - C++ implementation: ✓ Complete (materials_smart.hpp/cpp)
  - Documentation: ✓ Comprehensive (4 docs)
  - Testing: ✓ 6 automated tests

Features:
  ✓ One-command install
  ✓ Zero dependencies (standard Unix tools)
  ✓ Portable (Linux, macOS, WSL)
  ✓ Self-extracting
  ✓ Auto-annotating
  ✓ Idempotent
  ✓ Smart cleanup
  ✓ Size-efficient (~50 KB)

Security:
  ✓ Pure bash (no binaries)
  ✓ No network calls
  ✓ No privilege escalation
  ✓ Open-source
  ✓ Auditable


┌─────────────────────────────────────────────────────────────────────────┐
│                       USAGE SUMMARY                                     │
└─────────────────────────────────────────────────────────────────────────┘

╔═══════════════════════════════════════════════════════════════════════╗
║                          DEVELOPER                                    ║
╠═══════════════════════════════════════════════════════════════════════╣
║  $ ./scripts/generate_examples_bundle.sh                              ║
║  ✓ Self-extracting bundle created!                                    ║
║    Output: dist/mlabpp_examples_bundle.sh                             ║
║    Size: 50 KB                                                        ║
╚═══════════════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════════════╗
║                          END USER                                     ║
╠═══════════════════════════════════════════════════════════════════════╣
║  $ curl -O https://example.com/mlabpp_examples_bundle.sh              ║
║  $ bash mlabpp_examples_bundle.sh                                     ║
║  ✓ Installed MATLAB examples to: ./examples/                          ║
║                                                                       ║
║  $ cd examples && mlab++ materials_lookup.m --visual                  ║
║  MatLabC++ Materials Database Demo                                    ║
║  ==================================                                    ║
║  1. Basic Material Lookup                                             ║
║  Material: Aluminum 6061-T6                                           ║
║  Density: 2700 kg/m³                                                  ║
║  ...                                                                  ║
╚═══════════════════════════════════════════════════════════════════════╝


"Because GUIs are for cowards, and we ship single executable files."
```
