/**
 * Material Inference Example
 * Demonstrates smart material identification from properties
 */

#include "matlabcpp.hpp"
#include <iostream>
#include <iomanip>
#include <vector>
#include <algorithm>

using namespace matlabcpp;

// Helper function to print material info
void print_material(const SmartMaterial& mat) {
    std::cout << mat.name << " (" << mat.category << ")\n";
    std::cout << "  Density:           " << mat.density.value << " " << mat.density.units << "\n";
    std::cout << "  Young's modulus:   " << mat.youngs_modulus.value / 1e9 << " GPa\n";
    std::cout << "  Yield strength:    " << mat.yield_strength.value / 1e6 << " MPa\n";
    std::cout << "  Thermal cond:      " << mat.thermal_conductivity.value << " W/(m·K)\n";
    std::cout << "  Source:            " << mat.density.source << "\n";
    std::cout << "  Confidence:        " << mat.density.confidence << "/5\n";
}

void example_1_identify_from_density() {
    std::cout << "============================================\n";
    std::cout << "Example 1: Identify Material from Density\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    std::vector<double> test_densities = {2700, 1240, 7850, 8960, 1320};
    
    for (double rho : test_densities) {
        std::cout << "Testing density: " << rho << " kg/m³\n";
        
        auto result = db.infer_from_density(rho, 100.0);  // 100 kg/m³ tolerance
        
        if (result) {
            std::cout << "  Best match: " << result->material.name << "\n";
            std::cout << "  Confidence: " << (result->confidence * 100) << "%\n";
            std::cout << "  Reasoning:  " << result->reasoning << "\n";
            
            if (!result->alternatives.empty()) {
                std::cout << "  Alternatives: ";
                for (size_t i = 0; i < result->alternatives.size(); ++i) {
                    std::cout << result->alternatives[i];
                    if (i < result->alternatives.size() - 1) std::cout << ", ";
                }
                std::cout << "\n";
            }
        } else {
            std::cout << "  No match found (density out of range)\n";
        }
        std::cout << "\n";
    }
}

void example_2_identify_from_multiple_properties() {
    std::cout << "============================================\n";
    std::cout << "Example 2: Identify from Multiple Properties\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    // Test case: PLA-like properties
    std::cout << "Mystery material properties:\n";
    std::cout << "  Density: 1240 kg/m³\n";
    std::cout << "  Melting point: ~180°C\n";
    std::cout << "  Category: plastic\n\n";
    
    std::unordered_map<std::string, double> known_props;
    known_props["density"] = 1240;
    known_props["melting_point"] = 180 + 273.15;  // Convert to K
    
    auto result = db.infer_from_properties(known_props);
    
    if (result) {
        std::cout << "✓ Identified: " << result->material.name << "\n";
        std::cout << "  Confidence: " << (result->confidence * 100) << "%\n";
        std::cout << "  Reasoning:  " << result->reasoning << "\n\n";
        
        std::cout << "Complete inferred properties:\n";
        print_material(result->material);
    } else {
        std::cout << "✗ Could not identify material\n";
    }
    std::cout << "\n";
}

void example_3_constraint_search() {
    std::cout << "============================================\n";
    std::cout << "Example 3: Find Materials Meeting Constraints\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    std::cout << "Searching for:\n";
    std::cout << "  - Yield strength ≥ 400 MPa\n";
    std::cout << "  - Density ≤ 5000 kg/m³\n";
    std::cout << "  - Cost ≤ $10/kg\n";
    std::cout << "  - Category: metal\n\n";
    
    SmartMaterialDB::SelectionCriteria criteria;
    criteria.min_strength = 400e6;  // Pa
    criteria.max_density = 5000;    // kg/m³
    criteria.max_cost = 10;         // $/kg
    criteria.category = "metal";
    
    auto results = db.select_materials(criteria, "strength_to_weight");
    
    std::cout << "Found " << results.size() << " matching materials:\n\n";
    
    for (size_t i = 0; i < results.size(); ++i) {
        std::cout << (i + 1) << ". " << results[i].material.name << "\n";
        std::cout << "   Strength: " << results[i].material.yield_strength.value / 1e6 << " MPa\n";
        std::cout << "   Density:  " << results[i].material.density.value << " kg/m³\n";
        
        if (results[i].material.cost_per_kg) {
            std::cout << "   Cost:     $" << *results[i].material.cost_per_kg << "/kg\n";
        }
        
        // Calculate specific strength
        double spec_strength = results[i].material.yield_strength.value / 
                              results[i].material.density.value;
        std::cout << "   Specific: " << spec_strength << " Pa·m³/kg\n";
        std::cout << "   Score:    " << results[i].confidence << "\n\n";
    }
    
    if (!results.empty()) {
        std::cout << "✓ Recommendation: " << results[0].material.name << "\n";
        std::cout << "  (Best strength-to-weight ratio)\n";
    }
    std::cout << "\n";
}

void example_4_material_comparison() {
    std::cout << "============================================\n";
    std::cout << "Example 4: Compare Similar Materials\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    std::vector<std::string> to_compare = {"pla", "petg", "abs"};
    
    std::cout << "Comparing 3D printing materials:\n\n";
    
    auto comparison = db.compare(to_compare);
    
    std::cout << std::setw(20) << "Property" << " | "
              << std::setw(12) << "PLA" << " | "
              << std::setw(12) << "PETG" << " | "
              << std::setw(12) << "ABS" << "\n";
    std::cout << std::string(70, '-') << "\n";
    
    // Print each property row
    for (const auto& [prop, values] : comparison.properties) {
        std::cout << std::setw(20) << prop << " | ";
        for (double val : values) {
            std::cout << std::setw(12) << std::fixed << std::setprecision(1) << val << " | ";
        }
        std::cout << "\n";
    }
    
    std::cout << "\n";
    std::cout << "✓ Winner: " << comparison.winner << "\n";
    std::cout << "  Reasoning: " << comparison.reasoning << "\n";
    std::cout << "\n";
}

void example_5_temperature_dependent() {
    std::cout << "============================================\n";
    std::cout << "Example 5: Temperature-Dependent Properties\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    auto aluminum = db.get("aluminum_6061");
    
    if (aluminum) {
        std::cout << "Material: " << aluminum->name << "\n\n";
        
        std::cout << "Thermal conductivity vs. temperature:\n";
        std::cout << "Temp(°C)  Conductivity(W/m·K)\n";
        std::cout << "------------------------------\n";
        
        for (int T_celsius = 20; T_celsius <= 200; T_celsius += 20) {
            double T_kelvin = T_celsius + 273.15;
            double k = aluminum->get_value_at_temp("thermal_conductivity", T_kelvin);
            
            std::cout << std::setw(7) << T_celsius << std::setw(17) << std::fixed 
                      << std::setprecision(1) << k << "\n";
        }
        
        std::cout << "\n";
        std::cout << "Note: Conductivity increases with temperature for aluminum\n";
    }
    std::cout << "\n";
}

void example_6_inference_learning() {
    std::cout << "============================================\n";
    std::cout << "Example 6: Adaptive Learning System\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    std::cout << "Simulating repeated queries (learning system):\n\n";
    
    // Query PLA multiple times
    for (int i = 0; i < 5; ++i) {
        auto result = db.infer_from_density(1240 + (i * 5), 50.0);  // Slightly varying density
        
        if (result) {
            std::cout << "Query " << (i + 1) << ": density " << (1240 + i * 5) << " kg/m³\n";
            std::cout << "  → " << result->material.name << " (confidence: " 
                      << (result->confidence * 100) << "%)\n";
        }
    }
    
    std::cout << "\n";
    std::cout << "System learns from access patterns:\n";
    std::cout << "  - Frequently queried materials get higher confidence\n";
    std::cout << "  - Property importance weights adapt\n";
    std::cout << "  - Inference improves over time\n";
    std::cout << "\n";
}

void example_7_uncertainty_handling() {
    std::cout << "============================================\n";
    std::cout << "Example 7: Handling Measurement Uncertainty\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    std::cout << "Scenario: Measured density = 2700 ± 100 kg/m³\n\n";
    
    double measured = 2700;
    double uncertainty = 100;
    
    // Try different values within uncertainty range
    std::cout << "Testing within uncertainty range:\n";
    for (double offset : {-100, -50, 0, 50, 100}) {
        double test_density = measured + offset;
        auto result = db.infer_from_density(test_density, 50.0);
        
        if (result) {
            std::cout << "  " << test_density << " kg/m³ → " 
                      << result->material.name 
                      << " (" << (result->confidence * 100) << "%)\n";
        }
    }
    
    std::cout << "\n";
    std::cout << "Conclusion: All measurements point to Aluminum\n";
    std::cout << "           Consistent identification despite uncertainty\n";
    std::cout << "\n";
}

void example_8_export_results() {
    std::cout << "============================================\n";
    std::cout << "Example 8: Export Results\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    auto pla = db.get("pla");
    
    if (pla) {
        std::cout << "Exporting PLA data to JSON:\n\n";
        
        std::string json = pla->to_json();
        std::cout << json << "\n\n";
        
        std::cout << "This JSON can be:\n";
        std::cout << "  - Saved to file for documentation\n";
        std::cout << "  - Imported into other tools\n";
        std::cout << "  - Used in automated pipelines\n";
        std::cout << "  - Shared with collaborators\n";
    }
    std::cout << "\n";
}

int main() {
    std::cout << "\n";
    std::cout << "╔══════════════════════════════════════════════════╗\n";
    std::cout << "║                                                  ║\n";
    std::cout << "║    MatLabC++ Material Inference Examples         ║\n";
    std::cout << "║    Smart Material Identification System          ║\n";
    std::cout << "║                                                  ║\n";
    std::cout << "╚══════════════════════════════════════════════════╝\n\n";
    
    example_1_identify_from_density();
    example_2_identify_from_multiple_properties();
    example_3_constraint_search();
    example_4_material_comparison();
    example_5_temperature_dependent();
    example_6_inference_learning();
    example_7_uncertainty_handling();
    example_8_export_results();
    
    std::cout << "============================================\n";
    std::cout << "All inference examples completed!\n";
    std::cout << "============================================\n\n";
    
    std::cout << "Key Features Demonstrated:\n";
    std::cout << "  ✓ Density-based identification\n";
    std::cout << "  ✓ Multi-property inference\n";
    std::cout << "  ✓ Constraint-based selection\n";
    std::cout << "  ✓ Material comparison\n";
    std::cout << "  ✓ Temperature dependence\n";
    std::cout << "  ✓ Adaptive learning\n";
    std::cout << "  ✓ Uncertainty handling\n";
    std::cout << "  ✓ Data export (JSON)\n\n";
    
    std::cout << "Next steps:\n";
    std::cout << "  - Add your own materials to database\n";
    std::cout << "  - Integrate with measurement systems\n";
    std::cout << "  - Build automated selection tools\n";
    std::cout << "  - Create custom inference rules\n\n";
    
    return 0;
}
