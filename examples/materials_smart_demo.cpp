// Example: Using the Smart Materials Database

#include "matlabcpp/materials_smart.hpp"
#include <iostream>
#include <iomanip>

using namespace matlabcpp;

int main() {
    std::cout << "MatLabC++ Smart Materials Database Demo\n";
    std::cout << "========================================\n\n";
    
    // ========== Basic Material Lookup ==========
    std::cout << "1. Basic Material Lookup\n";
    std::cout << "------------------------\n";
    
    auto aluminum = get_material("aluminum_6061");
    if (aluminum) {
        std::cout << "Material: " << aluminum->name << "\n";
        std::cout << "Category: " << aluminum->category << "\n";
        std::cout << "Density: " << aluminum->density.value << " " << aluminum->density.units << "\n";
        std::cout << "Yield Strength: " << aluminum->yield_strength.value / 1e6 << " MPa\n";
        std::cout << "Source: " << aluminum->density.source << "\n";
        std::cout << "Strength/Weight: " << aluminum->get_strength_to_weight() << "\n\n";
    }
    
    // ========== Search ==========
    std::cout << "2. Search for Materials\n";
    std::cout << "-----------------------\n";
    
    auto plastics = search_materials("plastic");
    std::cout << "Found " << plastics.size() << " plastics:\n";
    for (const auto& mat : plastics) {
        std::cout << "  - " << mat.name << " (" << mat.subcategory << ")\n";
    }
    std::cout << "\n";
    
    // ========== Infer from Density ==========
    std::cout << "3. Infer Material from Density\n";
    std::cout << "------------------------------\n";
    
    double unknown_density = 2710;
    auto inferred = find_material_by_density(unknown_density, 50);
    
    if (inferred) {
        std::cout << "Density " << unknown_density << " kg/m³ matches:\n";
        std::cout << "  Material: " << inferred->material.name << "\n";
        std::cout << "  Confidence: " << (inferred->confidence * 100) << "%\n";
        std::cout << "  Reasoning: " << inferred->reasoning << "\n";
        
        if (!inferred->alternatives.empty()) {
            std::cout << "  Alternatives:\n";
            for (const auto& alt : inferred->alternatives) {
                std::cout << "    - " << alt << "\n";
            }
        }
    }
    std::cout << "\n";
    
    // ========== Material Selection ==========
    std::cout << "4. Material Selection (Optimization)\n";
    std::cout << "-----------------------------------\n";
    
    SelectionCriteria criteria;
    criteria.min_strength = 200e6;  // 200 MPa minimum
    criteria.max_density = 5000;    // 5000 kg/m³ maximum
    criteria.max_cost = 20.0;       // $20/kg maximum
    
    auto& db = global_material_db();
    auto selected = db.select_materials(criteria, "strength_to_weight");
    
    std::cout << "Materials meeting criteria (optimized for strength/weight):\n";
    for (size_t i = 0; i < std::min(selected.size(), size_t(3)); i++) {
        const auto& result = selected[i];
        std::cout << "  " << (i+1) << ". " << result.material.name << "\n";
        std::cout << "     Score: " << result.confidence << "\n";
        std::cout << "     " << result.reasoning << "\n";
    }
    std::cout << "\n";
    
    // ========== Material Comparison ==========
    std::cout << "5. Compare Materials\n";
    std::cout << "--------------------\n";
    
    std::vector<std::string> to_compare = {"aluminum_6061", "steel", "peek"};
    auto comparison = db.compare(to_compare);
    
    std::cout << "Comparing: ";
    for (const auto& name : comparison.materials) {
        std::cout << name << " ";
    }
    std::cout << "\n\n";
    
    std::cout << std::left;
    std::cout << std::setw(25) << "Property";
    for (const auto& name : comparison.materials) {
        std::cout << std::setw(15) << name;
    }
    std::cout << "\n";
    std::cout << std::string(70, '-') << "\n";
    
    for (const auto& [prop, values] : comparison.properties) {
        std::cout << std::setw(25) << prop;
        for (double val : values) {
            std::cout << std::setw(15) << std::fixed << std::setprecision(2) << val;
        }
        std::cout << "\n";
    }
    
    std::cout << "\nWinner: " << comparison.winner << "\n";
    std::cout << "Reason: " << comparison.reasoning << "\n\n";
    
    // ========== Application Recommendation ==========
    std::cout << "6. Recommend Material for Application\n";
    std::cout << "--------------------------------------\n";
    
    auto recommendation = db.recommend_for_application("3d_printing");
    
    std::cout << "For 3D printing application:\n";
    std::cout << "  Recommended: " << recommendation.material.name << "\n";
    std::cout << "  Reasoning: " << recommendation.reasoning << "\n";
    
    if (recommendation.material.cost_per_kg) {
        std::cout << "  Cost: $" << *recommendation.material.cost_per_kg << "/kg\n";
    }
    
    if (!recommendation.material.typical_uses.empty()) {
        std::cout << "  Typical uses:\n";
        for (const auto& use : recommendation.material.typical_uses) {
            std::cout << "    - " << use << "\n";
        }
    }
    std::cout << "\n";
    
    // ========== Temperature-Dependent Properties ==========
    std::cout << "7. Temperature-Dependent Properties\n";
    std::cout << "-----------------------------------\n";
    
    if (aluminum) {
        std::cout << "Aluminum 6061 thermal conductivity:\n";
        
        std::vector<double> temps = {273, 293, 373, 473};  // 0°C, 20°C, 100°C, 200°C
        for (double T : temps) {
            double k = aluminum->get_value_at_temp("thermal_conductivity", T);
            std::cout << "  At " << (T - 273) << "°C: " << k << " W/(m·K)\n";
        }
    }
    std::cout << "\n";
    
    // ========== Database Statistics ==========
    std::cout << "8. Database Statistics\n";
    std::cout << "----------------------\n";
    
    std::cout << "Total materials: " << db.count() << "\n";
    
    auto categories = db.categories();
    std::cout << "Categories: ";
    for (const auto& cat : categories) {
        std::cout << cat << " ";
    }
    std::cout << "\n\n";
    
    auto all_materials = db.list_all();
    std::cout << "All materials:\n";
    for (const auto& name : all_materials) {
        std::cout << "  - " << name << "\n";
    }
    std::cout << "\n";
    
    // ========== Validation ==========
    std::cout << "9. Database Validation\n";
    std::cout << "---------------------\n";
    
    auto issues = db.validate();
    if (issues.empty()) {
        std::cout << "✓ Database validation passed - no issues found\n";
    } else {
        std::cout << "⚠ Validation issues found:\n";
        for (const auto& issue : issues) {
            std::cout << "  - " << issue << "\n";
        }
    }
    
    return 0;
}
