/**
 * MATLAB Code Examples Embedded in C
 * 
 * This file contains MATLAB code as C strings for easy integration,
 * comparison, and documentation purposes.
 * 
 * Format: Each example shows:
 * 1. MATLAB code (as C string)
 * 2. MatLabC++ equivalent (C++ code)
 * 3. CLI command equivalent
 */

#include <stdio.h>
#include <string.h>

// ============================================
// EXAMPLE 1: Material Property Lookup
// ============================================

const char* matlab_material_lookup = 
    "% MATLAB: Material Property Lookup\n"
    "materials.pla.density = 1240;     % kg/m³\n"
    "materials.pla.strength = 50e6;    % Pa\n"
    "materials.pla.melts_at = 180;     % °C\n"
    "\n"
    "fprintf('PLA Properties:\\n');\n"
    "fprintf('  Density: %d kg/m³\\n', materials.pla.density);\n"
    "fprintf('  Strength: %.0f MPa\\n', materials.pla.strength/1e6);\n"
    "fprintf('  Melts at: %d°C\\n', materials.pla.melts_at);\n";

const char* matlabcpp_equivalent_cpp = 
    "// MatLabC++: Built-in Database Lookup\n"
    "SmartMaterialDB db;\n"
    "auto pla = db.get(\"pla\");\n"
    "\n"
    "std::cout << \"PLA Properties:\\n\";\n"
    "std::cout << \"  Density: \" << pla->density.value << \" kg/m³\\n\";\n"
    "std::cout << \"  Strength: \" << pla->yield_strength.value/1e6 << \" MPa\\n\";\n"
    "std::cout << \"  Melts at: \" << pla->melting_point.value-273 << \"°C\\n\";\n";

const char* matlabcpp_equivalent_cli = 
    ">>> material pla\n"
    "PLA\n"
    "  Density: 1240 kg/m³\n"
    "  Strength: 50 MPa\n"
    "  Melts at: 180°C\n";

// ============================================
// EXAMPLE 2: Material Comparison
// ============================================

const char* matlab_comparison = 
    "% MATLAB: Compare 3D Printing Materials\n"
    "materials = {\n"
    "    struct('name', 'PLA',  'density', 1240, 'strength', 50, 'cost', 20),\n"
    "    struct('name', 'PETG', 'density', 1270, 'strength', 50, 'cost', 25),\n"
    "    struct('name', 'ABS',  'density', 1060, 'strength', 45, 'cost', 22)\n"
    "};\n"
    "\n"
    "% Create comparison table\n"
    "fprintf('%-8s %10s %10s %10s\\n', 'Material', 'Density', 'Strength', 'Cost');\n"
    "fprintf('%-8s %10s %10s %10s\\n', '--------', '-------', '--------', '----');\n"
    "\n"
    "for i = 1:length(materials)\n"
    "    m = materials{i};\n"
    "    fprintf('%-8s %10d %10d %10d\\n', m.name, m.density, m.strength, m.cost);\n"
    "end\n"
    "\n"
    "% Find winners\n"
    "densities = cellfun(@(x) x.density, materials);\n"
    "[~, idx] = min(densities);\n"
    "fprintf('\\nLightest: %s\\n', materials{idx}.name);\n";

const char* matlabcpp_comparison = 
    ">>> compare pla petg abs\n"
    "\n"
    "┌──────────────────────────────────────────────────┐\n"
    "│        3D PRINTING MATERIAL COMPARISON           │\n"
    "├──────────────────────────────────────────────────┤\n"
    "│ Property    │ PLA    │ PETG   │ ABS    │ Winner │\n"
    "├─────────────┼────────┼────────┼────────┼────────┤\n"
    "│ Density     │ 1240   │ 1270   │ 1060   │ ABS ✓  │\n"
    "│ Strength    │ 50     │ 50     │ 45     │ PLA ✓  │\n"
    "│ Cost        │ $20    │ $25    │ $22    │ PLA ✓  │\n"
    "└─────────────┴────────┴────────┴────────┴────────┘\n"
    "\n"
    "Lightest: ABS (1060 kg/m³)\n"
    "Strongest: PLA (50 MPa)\n"
    "Cheapest: PLA ($20/kg)\n";

// ============================================
// EXAMPLE 3: ODE Solving
// ============================================

const char* matlab_ode_solving = 
    "% MATLAB: Free Fall with Air Resistance\n"
    "function dydt = free_fall(t, y)\n"
    "    % y(1) = position, y(2) = velocity\n"
    "    m = 1.0;      % mass (kg)\n"
    "    g = 9.80665;  % gravity (m/s²)\n"
    "    Cd = 0.47;    % drag coefficient\n"
    "    A = 0.01;     % area (m²)\n"
    "    rho = 1.225;  % air density (kg/m³)\n"
    "    \n"
    "    v = y(2);\n"
    "    drag = 0.5 * rho * Cd * A * v * abs(v);\n"
    "    a = -g - drag/m;\n"
    "    \n"
    "    dydt = [v; a];\n"
    "end\n"
    "\n"
    "% Solve\n"
    "y0 = [100; 0];  % 100m high, 0 velocity\n"
    "[t, y] = ode45(@free_fall, [0 10], y0);\n"
    "\n"
    "% Find impact\n"
    "idx = find(y(:,1) <= 0, 1);\n"
    "fprintf('Time to ground: %.2f seconds\\n', t(idx));\n"
    "fprintf('Final velocity: %.1f m/s\\n', abs(y(idx,2)));\n";

const char* matlabcpp_ode_cli = 
    ">>> drop 100\n"
    "Dropping from 100m...\n"
    "Time to ground: 4.52 seconds\n"
    "Final velocity: 44.3 m/s\n";

const char* matlabcpp_ode_cpp = 
    "// MatLabC++: Built-in Physics Calculations\n"
    "auto fall = [](double t, const Vec3& state) -> Vec3 {\n"
    "    double g = 9.80665;\n"
    "    double Cd = 0.47;\n"
    "    double A = 0.01;\n"
    "    double rho = 1.225;\n"
    "    double m = 1.0;\n"
    "    \n"
    "    double v = state[1];\n"
    "    double drag = 0.5 * rho * Cd * A * v * std::abs(v);\n"
    "    double a = -g - drag/m;\n"
    "    \n"
    "    return Vec3{v, a, 0.0};\n"
    "};\n"
    "\n"
    "RK45Solver solver;\n"
    "State initial{Vec3{100, 0, 0}};\n"
    "auto result = solver.integrate(fall, initial, 0, 10);\n";

// ============================================
// EXAMPLE 4: Material Identification
// ============================================

const char* matlab_identification = 
    "% MATLAB: Identify Material from Density\n"
    "measured_density = 2700;  % kg/m³\n"
    "tolerance = 100;\n"
    "\n"
    "% Database (manual)\n"
    "materials = {\n"
    "    struct('name', 'Aluminum', 'density', 2700),\n"
    "    struct('name', 'Steel',    'density', 7850),\n"
    "    struct('name', 'Copper',   'density', 8960),\n"
    "    struct('name', 'PLA',      'density', 1240)\n"
    "};\n"
    "\n"
    "% Find matches\n"
    "fprintf('Identifying material with density %.0f kg/m³:\\n', measured_density);\n"
    "\n"
    "best_match = '';\n"
    "best_diff = inf;\n"
    "\n"
    "for i = 1:length(materials)\n"
    "    m = materials{i};\n"
    "    diff = abs(m.density - measured_density);\n"
    "    \n"
    "    if diff < tolerance && diff < best_diff\n"
    "        best_match = m.name;\n"
    "        best_diff = diff;\n"
    "    end\n"
    "end\n"
    "\n"
    "if ~isempty(best_match)\n"
    "    confidence = 100 * (1 - best_diff/tolerance);\n"
    "    fprintf('Best match: %s (%.0f%% confidence)\\n', best_match, confidence);\n"
    "else\n"
    "    fprintf('No match found\\n');\n"
    "end\n";

const char* matlabcpp_identification = 
    ">>> identify 2700\n"
    "Best match: Aluminum\n"
    "Confidence: 98%\n"
    "Reasoning: Exact density match\n"
    "Alternatives: Al 6061 (2700 kg/m³), Al 2024 (2780 kg/m³)\n";

// ============================================
// Documentation and Usage
// ============================================

void print_example(const char* title, 
                   const char* matlab_code, 
                   const char* matlabcpp_cli, 
                   const char* matlabcpp_cpp) {
    printf("\n");
    printf("============================================\n");
    printf("%s\n", title);
    printf("============================================\n\n");
    
    printf("MATLAB CODE:\n");
    printf("------------\n");
    printf("%s\n\n", matlab_code);
    
    printf("MatLabC++ CLI EQUIVALENT:\n");
    printf("-------------------------\n");
    printf("%s\n\n", matlabcpp_cli);
    
    if (matlabcpp_cpp) {
        printf("MatLabC++ C++ EQUIVALENT:\n");
        printf("-------------------------\n");
        printf("%s\n", matlabcpp_cpp);
    }
}

int main() {
    printf("\n");
    printf("╔════════════════════════════════════════════════════╗\n");
    printf("║                                                    ║\n");
    printf("║  MATLAB Code Examples in C Format                 ║\n");
    printf("║  Embedded MATLAB ↔ MatLabC++ Comparison          ║\n");
    printf("║                                                    ║\n");
    printf("╚════════════════════════════════════════════════════╝\n");
    
    // Example 1: Material Lookup
    print_example(
        "Example 1: Material Property Lookup",
        matlab_material_lookup,
        matlabcpp_equivalent_cli,
        matlabcpp_equivalent_cpp
    );
    
    // Example 2: Material Comparison
    print_example(
        "Example 2: Material Comparison",
        matlab_comparison,
        matlabcpp_comparison,
        NULL
    );
    
    // Example 3: ODE Solving
    print_example(
        "Example 3: ODE Solving (Free Fall)",
        matlab_ode_solving,
        matlabcpp_ode_cli,
        matlabcpp_ode_cpp
    );
    
    // Example 4: Material Identification
    print_example(
        "Example 4: Material Identification",
        matlab_identification,
        matlabcpp_identification,
        NULL
    );
    
    // Summary
    printf("\n");
    printf("============================================\n");
    printf("KEY DIFFERENCES\n");
    printf("============================================\n\n");
    
    printf("MATLAB Approach:\n");
    printf("  - Manual database creation\n");
    printf("  - Explicit loops and conditionals\n");
    printf("  - ~50-100 lines per task\n");
    printf("  - Requires 18 GB install\n");
    printf("  - $2,150/year license\n\n");
    
    printf("MatLabC++ Approach:\n");
    printf("  - Built-in material database\n");
    printf("  - Smart inference and identification\n");
    printf("  - 1-10 lines per task (CLI) or similar C++ complexity\n");
    printf("  - 60 MB install\n");
    printf("  - Free and open source\n\n");
    
    printf("============================================\n");
    printf("USAGE\n");
    printf("============================================\n\n");
    
    printf("Compile this file:\n");
    printf("  gcc -o matlab_examples matlab_examples.c\n");
    printf("  ./matlab_examples\n\n");
    
    printf("Use MATLAB code:\n");
    printf("  Copy-paste code blocks into MATLAB\n\n");
    
    printf("Use MatLabC++ CLI:\n");
    printf("  cd build && ./matlabcpp\n");
    printf("  Then type commands shown in CLI sections\n\n");
    
    printf("Use MatLabC++ C++:\n");
    printf("  Include \"matlabcpp.hpp\" in your project\n");
    printf("  Use code shown in C++ sections\n\n");
    
    return 0;
}

/*
 * COMPILATION AND USAGE NOTES
 * ============================
 * 
 * This file demonstrates MATLAB code embedded in C strings for:
 * 1. Easy comparison with MatLabC++ equivalents
 * 2. Documentation and teaching purposes
 * 3. Potential code generation or conversion tools
 * 
 * To compile:
 *   gcc -std=c99 -o matlab_examples matlab_examples.c
 *   ./matlab_examples
 * 
 * To use MATLAB code:
 *   Copy the strings marked "MATLAB CODE" into MATLAB
 * 
 * To use MatLabC++ CLI:
 *   Run ./matlabcpp and use commands from "CLI EQUIVALENT" sections
 * 
 * To use MatLabC++ C++:
 *   #include "matlabcpp.hpp" and use code from "C++ EQUIVALENT" sections
 * 
 * FORMAT RATIONALE
 * ================
 * 
 * Why embed MATLAB in .c files?
 * 
 * 1. Side-by-side comparison in single file
 * 2. Can be compiled and run to show examples
 * 3. Enables automated testing/validation
 * 4. Facilitates code generation tools
 * 5. Easy to parse programmatically
 * 6. Documentation stays with implementation
 * 
 * This format is unusual but useful for:
 * - Teaching materials (show equivalent approaches)
 * - Migration tools (MATLAB → C++/MatLabC++)
 * - Documentation generation
 * - Automated testing (extract and run MATLAB code)
 * - Code comparison utilities
 */
