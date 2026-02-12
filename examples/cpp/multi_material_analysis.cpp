/**
 * Multi-Material Analysis Example
 * Demonstrates analyzing and comparing multiple materials for design
 */

#include "matlabcpp.hpp"
#include <iostream>
#include <iomanip>
#include <vector>
#include <algorithm>
#include <cmath>

using namespace matlabcpp;

struct DesignRequirements {
    double min_strength;
    double max_weight;
    double max_cost;
    double min_stiffness;
    std::string environment;  // "indoor", "outdoor", "high_temp", etc.
};

struct AnalysisResult {
    std::string material_name;
    double score;
    double mass;
    double cost;
    double safety_factor;
    std::vector<std::string> pros;
    std::vector<std::string> cons;
};

// Analyze material for beam application
AnalysisResult analyze_for_beam(const SmartMaterial& mat, const DesignRequirements& req) {
    AnalysisResult result;
    result.material_name = mat.name;
    
    // Assume simple beam: 1m long, square cross-section
    double length = 1.0;  // m
    double load = 1000;   // N
    
    // Required cross-sectional area for strength
    double area_required = load * req.min_stiffness / mat.yield_strength.value;
    
    // Mass
    result.mass = area_required * length * mat.density.value;
    
    // Cost
    if (mat.cost_per_kg) {
        result.cost = result.mass * (*mat.cost_per_kg);
    } else {
        result.cost = 0;
    }
    
    // Safety factor
    double actual_stress = load / area_required;
    result.safety_factor = mat.yield_strength.value / actual_stress;
    
    // Scoring (0-100)
    double weight_score = 100.0 / (1.0 + result.mass);
    double cost_score = (result.cost > 0) ? (100.0 / (1.0 + result.cost)) : 50.0;
    double strength_score = std::min(result.safety_factor * 20.0, 100.0);
    
    result.score = (weight_score * 0.4) + (cost_score * 0.3) + (strength_score * 0.3);
    
    // Pros and cons
    if (result.mass < 1.0) {
        result.pros.push_back("Lightweight");
    } else {
        result.cons.push_back("Heavy");
    }
    
    if (result.cost < 10.0) {
        result.pros.push_back("Affordable");
    } else {
        result.cons.push_back("Expensive");
    }
    
    if (result.safety_factor > 3.0) {
        result.pros.push_back("High safety margin");
    } else if (result.safety_factor < 1.5) {
        result.cons.push_back("Low safety margin");
    }
    
    return result;
}

void example_1_beam_comparison() {
    std::cout << "============================================\n";
    std::cout << "Example 1: Structural Beam Material Selection\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    DesignRequirements req;
    req.min_strength = 200e6;    // 200 MPa
    req.max_weight = 5.0;        // 5 kg
    req.max_cost = 50.0;         // $50
    req.min_stiffness = 50e9;    // 50 GPa
    
    std::cout << "Design requirements:\n";
    std::cout << "  Min strength: " << req.min_strength / 1e6 << " MPa\n";
    std::cout << "  Max weight:   " << req.max_weight << " kg\n";
    std::cout << "  Max cost:     $" << req.max_cost << "\n";
    std::cout << "  Min stiffness: " << req.min_stiffness / 1e9 << " GPa\n\n";
    
    std::vector<std::string> candidates = {
        "aluminum_6061", "steel_mild", "aluminum_7075", "titanium_6al4v"
    };
    
    std::vector<AnalysisResult> results;
    
    for (const auto& mat_name : candidates) {
        auto mat = db.get(mat_name);
        if (mat) {
            auto analysis = analyze_for_beam(*mat, req);
            results.push_back(analysis);
        }
    }
    
    // Sort by score
    std::sort(results.begin(), results.end(), 
              [](const AnalysisResult& a, const AnalysisResult& b) {
                  return a.score > b.score;
              });
    
    std::cout << "Analysis results (ranked by score):\n\n";
    
    for (size_t i = 0; i < results.size(); ++i) {
        const auto& r = results[i];
        std::cout << (i + 1) << ". " << r.material_name << " (Score: " 
                  << std::fixed << std::setprecision(1) << r.score << "/100)\n";
        std::cout << "   Mass:          " << std::setprecision(2) << r.mass << " kg\n";
        std::cout << "   Cost:          $" << r.cost << "\n";
        std::cout << "   Safety factor: " << r.safety_factor << "\n";
        
        if (!r.pros.empty()) {
            std::cout << "   Pros: ";
            for (size_t j = 0; j < r.pros.size(); ++j) {
                std::cout << r.pros[j];
                if (j < r.pros.size() - 1) std::cout << ", ";
            }
            std::cout << "\n";
        }
        
        if (!r.cons.empty()) {
            std::cout << "   Cons: ";
            for (size_t j = 0; j < r.cons.size(); ++j) {
                std::cout << r.cons[j];
                if (j < r.cons.size() - 1) std::cout << ", ";
            }
            std::cout << "\n";
        }
        std::cout << "\n";
    }
    
    std::cout << "✓ Recommendation: " << results[0].material_name << "\n";
    std::cout << "  Best balance of weight, cost, and strength\n\n";
}

void example_2_thermal_analysis() {
    std::cout << "============================================\n";
    std::cout << "Example 2: Heat Sink Material Comparison\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    std::cout << "Application: CPU heat sink (100W dissipation)\n\n";
    
    std::vector<std::string> candidates = {"aluminum_6061", "copper_pure"};
    
    double power = 100.0;  // Watts
    double area = 50e-4;   // m² (50 cm²)
    double thickness = 0.02;  // m (2 cm)
    double T_ambient = 25.0;  // °C
    
    std::cout << "Heat sink geometry:\n";
    std::cout << "  Base area: " << area * 1e4 << " cm²\n";
    std::cout << "  Thickness: " << thickness * 100 << " cm\n";
    std::cout << "  Power:     " << power << " W\n\n";
    
    for (const auto& mat_name : candidates) {
        auto mat = db.get(mat_name);
        if (!mat) continue;
        
        double k = mat->thermal_conductivity.value;
        double rho = mat->density.value;
        double cost_per_kg = mat->cost_per_kg ? *mat->cost_per_kg : 0;
        
        // Thermal resistance (simplified)
        double R_cond = thickness / (k * area);
        
        // Temperature rise (conduction only)
        double delta_T_cond = power * R_cond;
        
        // Assume convection R = 0.5 K/W
        double R_conv = 0.5;
        double delta_T_conv = power * R_conv;
        
        double T_cpu = T_ambient + delta_T_cond + delta_T_conv;
        
        // Mass and cost
        double volume = area * thickness;
        double mass = volume * rho;
        double cost = mass * cost_per_kg;
        
        std::cout << mat->name << ":\n";
        std::cout << "  Thermal conductivity: " << k << " W/(m·K)\n";
        std::cout << "  Thermal resistance:   " << std::fixed << std::setprecision(4) 
                  << R_cond << " K/W\n";
        std::cout << "  Temperature rise:     " << std::setprecision(1) 
                  << delta_T_cond << "°C (conduction)\n";
        std::cout << "  CPU temperature:      " << T_cpu << "°C\n";
        std::cout << "  Mass:                 " << std::setprecision(1) 
                  << mass * 1000 << " g\n";
        std::cout << "  Cost:                 $" << std::setprecision(2) << cost << "\n";
        
        if (T_cpu > 85) {
            std::cout << "  Status: ✗ TOO HOT (exceeds 85°C limit)\n";
        } else {
            std::cout << "  Status: ✓ Safe temperature\n";
        }
        std::cout << "\n";
    }
    
    std::cout << "Conclusion:\n";
    std::cout << "  - Copper: Better cooling but heavier and more expensive\n";
    std::cout << "  - Aluminum: Good enough for most CPUs, practical choice\n";
    std::cout << "  - Real-world: Hybrid (copper base + aluminum fins)\n\n";
}

void example_3_corrosion_environment() {
    std::cout << "============================================\n";
    std::cout << "Example 3: Environmental Resistance Analysis\n";
    std::cout << "============================================\n\n";
    
    std::cout << "Scenario: Outdoor structure near ocean (salt spray)\n\n";
    
    struct MaterialRating {
        std::string name;
        int corrosion_resistance;  // 1-10
        double cost_multiplier;
        std::string coating_needed;
    };
    
    std::vector<MaterialRating> materials = {
        {"Mild Steel", 2, 1.0, "Essential (galvanizing/paint)"},
        {"Stainless 304", 8, 3.0, "Not required"},
        {"Stainless 316", 9, 4.0, "Not required"},
        {"Aluminum 6061", 6, 2.5, "Recommended (anodizing)"},
        {"Aluminum 5083 (marine)", 8, 3.5, "Optional"},
        {"Titanium", 10, 10.0, "Not required"}
    };
    
    std::cout << std::setw(25) << "Material" 
              << std::setw(15) << "Corr. Resist" 
              << std::setw(15) << "Cost Factor"
              << std::setw(30) << "Coating\n";
    std::cout << std::string(85, '-') << "\n";
    
    for (const auto& mat : materials) {
        std::string rating;
        if (mat.corrosion_resistance >= 8) rating = "Excellent";
        else if (mat.corrosion_resistance >= 6) rating = "Good";
        else if (mat.corrosion_resistance >= 4) rating = "Fair";
        else rating = "Poor";
        
        std::cout << std::setw(25) << mat.name
                  << std::setw(10) << rating << " (" << mat.corrosion_resistance << "/10)"
                  << std::setw(8) << std::fixed << std::setprecision(1) << mat.cost_multiplier << "x"
                  << "  " << mat.coating_needed << "\n";
    }
    
    std::cout << "\n";
    std::cout << "Recommendations:\n";
    std::cout << "  Budget option:      Galvanized mild steel (low initial cost)\n";
    std::cout << "  Balanced:           Aluminum 5083 marine grade\n";
    std::cout << "  Premium/permanent:  Stainless 316 or Titanium\n";
    std::cout << "  Consider:           Maintenance costs over lifetime\n\n";
}

void example_4_weight_optimization() {
    std::cout << "============================================\n";
    std::cout << "Example 4: Weight Optimization (Aerospace)\n";
    std::cout << "============================================\n\n";
    
    SmartMaterialDB db;
    db.load_builtin_materials();
    
    std::cout << "Application: Aircraft component (tensile load)\n";
    std::cout << "Goal: Minimize weight for 500 MPa design stress\n\n";
    
    std::vector<std::string> candidates = {
        "aluminum_7075", "titanium_6al4v", "steel_4340"
    };
    
    double required_stress = 500e6;  // Pa
    double safety_factor = 1.5;
    double length = 1.0;  // m
    
    std::cout << "Required stress: " << required_stress / 1e6 << " MPa\n";
    std::cout << "Safety factor:   " << safety_factor << "\n";
    std::cout << "Length:          " << length << " m\n\n";
    
    struct WeightAnalysis {
        std::string name;
        double area_required;
        double mass;
        double cost;
        double spec_strength;
    };
    
    std::vector<WeightAnalysis> results;
    
    for (const auto& mat_name : candidates) {
        auto mat = db.get(mat_name);
        if (!mat) continue;
        
        WeightAnalysis wa;
        wa.name = mat->name;
        
        // Required area for strength
        double allowable_stress = mat->yield_strength.value / safety_factor;
        wa.area_required = required_stress / allowable_stress;
        
        // Mass
        wa.mass = wa.area_required * length * mat->density.value;
        
        // Cost
        wa.cost = mat->cost_per_kg ? (wa.mass * (*mat->cost_per_kg)) : 0;
        
        // Specific strength
        wa.spec_strength = mat->yield_strength.value / mat->density.value;
        
        results.push_back(wa);
    }
    
    // Sort by mass
    std::sort(results.begin(), results.end(),
              [](const WeightAnalysis& a, const WeightAnalysis& b) {
                  return a.mass < b.mass;
              });
    
    std::cout << "Weight comparison:\n\n";
    std::cout << std::setw(20) << "Material" 
              << std::setw(15) << "Mass (kg)"
              << std::setw(15) << "Cost ($)"
              << std::setw(20) << "Spec Strength\n";
    std::cout << std::string(70, '-') << "\n";
    
    for (const auto& r : results) {
        std::cout << std::setw(20) << r.name
                  << std::setw(15) << std::fixed << std::setprecision(3) << r.mass
                  << std::setw(15) << std::setprecision(2) << r.cost
                  << std::setw(20) << std::setprecision(0) << r.spec_strength << "\n";
    }
    
    std::cout << "\n";
    std::cout << "✓ Lightest: " << results[0].name << " (" << results[0].mass << " kg)\n";
    
    // Weight savings
    double heaviest_mass = results.back().mass;
    double lightest_mass = results[0].mass;
    double savings_kg = heaviest_mass - lightest_mass;
    double savings_percent = (savings_kg / heaviest_mass) * 100;
    
    std::cout << "  Weight savings vs. heaviest: " << savings_kg << " kg (" 
              << savings_percent << "%)\n";
    std::cout << "  Critical for fuel efficiency in aerospace\n\n";
}

void example_5_lifecycle_cost() {
    std::cout << "============================================\n";
    std::cout << "Example 5: Lifecycle Cost Analysis\n";
    std::cout << "============================================\n\n";
    
    std::cout << "Comparing total cost of ownership (10 years)\n\n";
    
    struct LifecycleCost {
        std::string material;
        double initial_cost;
        double maintenance_per_year;
        double replacement_years;
        double total_10yr;
    };
    
    std::vector<LifecycleCost> options = {
        {"Mild steel (painted)", 100, 20, 5, 0},        // Needs repainting
        {"Galvanized steel", 150, 5, 10, 0},            // Lasts longer
        {"Stainless 304", 300, 2, 20, 0},               // Minimal maintenance
        {"Aluminum (anodized)", 250, 5, 15, 0}          // Good balance
    };
    
    // Calculate 10-year costs
    for (auto& opt : options) {
        double replacements = std::floor(10.0 / opt.replacement_years);
        opt.total_10yr = opt.initial_cost * (1 + replacements) + 
                        (opt.maintenance_per_year * 10);
    }
    
    std::cout << std::setw(25) << "Material"
              << std::setw(12) << "Initial"
              << std::setw(15) << "Maint/yr"
              << std::setw(15) << "Life (yr)"
              << std::setw(15) << "10yr Total\n";
    std::cout << std::string(82, '-') << "\n";
    
    for (const auto& opt : options) {
        std::cout << std::setw(25) << opt.material
                  << std::setw(11) << "$" << std::fixed << std::setprecision(0) << opt.initial_cost
                  << std::setw(14) << "$" << opt.maintenance_per_year
                  << std::setw(15) << opt.replacement_years
                  << std::setw(14) << "$" << opt.total_10yr << "\n";
    }
    
    // Find best
    auto best = std::min_element(options.begin(), options.end(),
                                 [](const LifecycleCost& a, const LifecycleCost& b) {
                                     return a.total_10yr < b.total_10yr;
                                 });
    
    std::cout << "\n";
    std::cout << "✓ Lowest 10-year cost: " << best->material 
              << " ($" << best->total_10yr << ")\n";
    std::cout << "\n";
    std::cout << "Key insight: Higher initial cost can be cheaper long-term\n";
    std::cout << "            (factor in maintenance, replacement, downtime)\n\n";
}

int main() {
    std::cout << "\n";
    std::cout << "╔══════════════════════════════════════════════════╗\n";
    std::cout << "║                                                  ║\n";
    std::cout << "║   MatLabC++ Multi-Material Analysis Examples     ║\n";
    std::cout << "║   Real-World Design Decision Making              ║\n";
    std::cout << "║                                                  ║\n";
    std::cout << "╚══════════════════════════════════════════════════╝\n\n";
    
    example_1_beam_comparison();
    example_2_thermal_analysis();
    example_3_corrosion_environment();
    example_4_weight_optimization();
    example_5_lifecycle_cost();
    
    std::cout << "============================================\n";
    std::cout << "All multi-material examples completed!\n";
    std::cout << "============================================\n\n";
    
    std::cout << "Key Lessons:\n";
    std::cout << "  1. No single 'best' material - context matters\n";
    std::cout << "  2. Weight critical in aerospace/automotive\n";
    std::cout << "  3. Environment affects material lifespan\n";
    std::cout << "  4. Lifecycle cost != initial cost\n";
    std::cout << "  5. Trade-offs: performance vs. cost vs. weight\n\n";
    
    std::cout << "Design Process:\n";
    std::cout << "  → Define requirements clearly\n";
    std::cout << "  → Identify candidate materials\n";
    std::cout << "  → Analyze each against criteria\n";
    std::cout << "  → Consider real-world factors (corrosion, maintenance)\n";
    std::cout << "  → Calculate lifecycle costs\n";
    std::cout << "  → Make informed decision\n\n";
    
    return 0;
}
