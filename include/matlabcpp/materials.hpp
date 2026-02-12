#pragma once
#include <string>
#include <unordered_map>
#include <optional>
#include <vector>
#include <functional>
#include <cmath>
#include <algorithm>

namespace matlabcpp {

// ========== Universal Property Container ==========
struct MaterialProperty {
    double value;
    double uncertainty = 0.0;    // ±tolerance
    std::string units;
    std::string source = "internal";  // "NIST", "ASM", "datasheet"
    int confidence = 3;          // 1-5 (5 = verified standard)
    
    // Temperature dependence (optional)
    struct TempDependence {
        bool is_temp_dependent = false;
        double temp_coeff = 0.0;  // Linear: value(T) = value + temp_coeff * (T - 293)
        double ref_temp = 293.0;  // Reference temperature [K]
    } temp_dep;
    
    MaterialProperty() = default;
    MaterialProperty(double v, std::string u, std::string src = "internal", int conf = 3)
        : value(v), units(std::move(u)), source(std::move(src)), confidence(conf) {}
    
    // Get value at specific temperature
    [[nodiscard]] double at_temp(double temp_K) const {
        if (!temp_dep.is_temp_dependent) return value;
        return value + temp_dep.temp_coeff * (temp_K - temp_dep.ref_temp);
    }
};

// ========== Smart Material Entry ==========
class SmartMaterial {
public:
    std::string name;
    std::string key;         // Lowercase unique ID
    std::string category;    // "metal", "plastic", "composite", "ceramic"
    std::string subcategory; // "steel", "aluminum", "carbon_fiber"
    
    // Core properties (always present)
    MaterialProperty density;
    MaterialProperty youngs_modulus;
    MaterialProperty yield_strength;
    MaterialProperty ultimate_strength;
    MaterialProperty poisson_ratio;
    
    // Thermal properties
    MaterialProperty thermal_conductivity;
    MaterialProperty specific_heat;
    MaterialProperty thermal_expansion;
    MaterialProperty melting_point;
    std::optional<MaterialProperty> glass_transition;
    
    // Optional properties
    std::optional<MaterialProperty> shear_modulus;
    std::optional<MaterialProperty> hardness;
    std::optional<MaterialProperty> fracture_toughness;
    
    // Cost & availability
    std::optional<double> cost_per_kg;        // USD
    std::optional<std::string> availability;  // "common", "specialty", "rare"
    
    // Applications & notes
    std::vector<std::string> typical_uses;
    std::vector<std::string> warnings;
    
    // Constructors
    SmartMaterial() = default;
    SmartMaterial(std::string n, std::string cat) 
        : name(std::move(n)), category(std::move(cat)) {
        // Generate key from name
        key = name;
        std::transform(key.begin(), key.end(), key.begin(), ::tolower);
        std::replace(key.begin(), key.end(), ' ', '_');
        std::replace(key.begin(), key.end(), '-', '_');
    }
    
    // Query interface
    [[nodiscard]] std::optional<MaterialProperty> get_property(const std::string& prop_name) const {
        if (prop_name == "density") return density;
        if (prop_name == "youngs_modulus") return youngs_modulus;
        if (prop_name == "yield_strength") return yield_strength;
        if (prop_name == "thermal_conductivity") return thermal_conductivity;
        if (prop_name == "specific_heat") return specific_heat;
        return std::nullopt;
    }
    
    // Inference vector for matching
    [[nodiscard]] std::unordered_map<std::string, double> get_inference_vector() const {
        return {
            {"density", density.value},
            {"youngs_modulus", youngs_modulus.value},
            {"yield_strength", yield_strength.value},
            {"thermal_conductivity", thermal_conductivity.value}
        };
    }
};

// ========== Smart Database with Inference ==========
class SmartMaterialDB {
    std::unordered_map<std::string, SmartMaterial> materials_;
    
    // Learning state
    mutable std::unordered_map<std::string, int> access_counts_;
    mutable std::unordered_map<std::string, double> property_weights_;
    
public:
    SmartMaterialDB() {
        // Initialize default property weights
        property_weights_["density"] = 1.0;
        property_weights_["youngs_modulus"] = 0.8;
        property_weights_["yield_strength"] = 0.9;
        property_weights_["thermal_conductivity"] = 0.6;
        
        // Load built-in materials
        load_builtin_materials();
    }
    
    // Add material
    void add(const SmartMaterial& mat) {
        materials_[mat.key] = mat;
    }
    
    // Get material
    [[nodiscard]] std::optional<SmartMaterial> get(const std::string& name) const {
        std::string key = name;
        std::transform(key.begin(), key.end(), key.begin(), ::tolower);
        std::replace(key.begin(), key.end(), ' ', '_');
        std::replace(key.begin(), key.end(), '-', '_');
        
        auto it = materials_.find(key);
        if (it != materials_.end()) {
            access_counts_[key]++;  // Learning
            return it->second;
        }
        return std::nullopt;
    }
    
    // Inference: Find material from density
    struct InferenceResult {
        SmartMaterial material;
        double confidence;
        std::string reasoning;
        std::vector<std::string> alternatives;
    };
    
    [[nodiscard]] std::optional<InferenceResult> infer_from_density(
        double rho, 
        double tolerance = 100.0
    ) const {
        std::vector<std::pair<std::string, double>> matches;
        
        for (const auto& [key, mat] : materials_) {
            double diff = std::abs(mat.density.value - rho);
            if (diff <= tolerance) {
                matches.emplace_back(key, diff);
            }
        }
        
        if (matches.empty()) return std::nullopt;
        
        // Sort by difference
        std::sort(matches.begin(), matches.end(),
            [](const auto& a, const auto& b) { return a.second < b.second; });
        
        const auto& best = materials_.at(matches[0].first);
        double confidence = 1.0 - (matches[0].second / tolerance);
        
        InferenceResult result;
        result.material = best;
        result.confidence = confidence;
        result.reasoning = "Matched by density: " + std::to_string(rho) + " kg/m³";
        
        // Add alternatives
        for (size_t i = 1; i < std::min(matches.size(), size_t(3)); ++i) {
            result.alternatives.push_back(materials_.at(matches[i].first).name);
        }
        
        access_counts_[matches[0].first]++;  // Learning
        
        return result;
    }
    
    // Inference from multiple properties
    [[nodiscard]] std::optional<InferenceResult> infer_from_properties(
        const std::unordered_map<std::string, double>& known_props
    ) const {
        if (known_props.empty()) return std::nullopt;
        
        std::vector<std::pair<std::string, double>> scores;
        
        for (const auto& [key, mat] : materials_) {
            double score = compute_similarity(known_props, mat);
            scores.emplace_back(key, score);
        }
        
        if (scores.empty()) return std::nullopt;
        
        // Sort by score (lower is better)
        std::sort(scores.begin(), scores.end(),
            [](const auto& a, const auto& b) { return a.second < b.second; });
        
        const auto& best = materials_.at(scores[0].first);
        double confidence = std::exp(-scores[0].second / 10.0);  // Exponential decay
        
        InferenceResult result;
        result.material = best;
        result.confidence = std::clamp(confidence, 0.0, 1.0);
        result.reasoning = "Matched " + std::to_string(known_props.size()) + " properties";
        
        for (size_t i = 1; i < std::min(scores.size(), size_t(3)); ++i) {
            result.alternatives.push_back(materials_.at(scores[i].first).name);
        }
        
        return result;
    }
    
    // Material selection with constraints
    [[nodiscard]] std::vector<SmartMaterial> select(
        double min_strength = 0,
        double max_density = 1e6,
        double max_cost = 1e6,
        const std::string& category = "any"
    ) const {
        std::vector<SmartMaterial> results;
        
        for (const auto& [key, mat] : materials_) {
            // Check category
            if (category != "any" && mat.category != category) continue;
            
            // Check constraints
            if (mat.yield_strength.value < min_strength) continue;
            if (mat.density.value > max_density) continue;
            if (mat.cost_per_kg && *mat.cost_per_kg > max_cost) continue;
            
            results.push_back(mat);
        }
        
        // Sort by strength-to-weight ratio
        std::sort(results.begin(), results.end(),
            [](const SmartMaterial& a, const SmartMaterial& b) {
                double ratio_a = a.yield_strength.value / a.density.value;
                double ratio_b = b.yield_strength.value / b.density.value;
                return ratio_a > ratio_b;
            });
        
        return results;
    }
    
    // Statistics
    [[nodiscard]] size_t count() const { return materials_.size(); }
    
    [[nodiscard]] std::vector<std::string> list_all() const {
        std::vector<std::string> names;
        for (const auto& [key, mat] : materials_) {
            names.push_back(mat.name);
        }
        std::sort(names.begin(), names.end());
        return names;
    }
    
    [[nodiscard]] auto begin() const { return materials_.begin(); }
    [[nodiscard]] auto end() const { return materials_.end(); }
    
private:
    void load_builtin_materials() {
        // Load the existing materials from materials.hpp
        // Then add extended materials
        
        // Example: Steel 4340
        SmartMaterial steel_4340("Steel 4340", "metal");
        steel_4340.subcategory = "steel";
        steel_4340.density = MaterialProperty(7850, "kg/m³", "ASM Handbook", 5);
        steel_4340.youngs_modulus = MaterialProperty(200e9, "Pa", "ASTM E111", 5);
        steel_4340.yield_strength = MaterialProperty(470e6, "Pa", "MMPDS", 5);
        steel_4340.ultimate_strength = MaterialProperty(745e6, "Pa", "MMPDS", 5);
        steel_4340.poisson_ratio = MaterialProperty(0.29, "dimensionless", "ASM", 5);
        steel_4340.thermal_conductivity = MaterialProperty(44.5, "W/(m·K)", "NIST", 5);
        steel_4340.specific_heat = MaterialProperty(475, "J/(kg·K)", "NIST", 5);
        steel_4340.thermal_expansion = MaterialProperty(12.3e-6, "1/K", "ASM", 5);
        steel_4340.melting_point = MaterialProperty(1700, "K", "ASM", 5);
        steel_4340.cost_per_kg = 3.50;
        steel_4340.typical_uses = {"Aircraft landing gear", "Shafts", "Gears", "High-stress parts"};
        materials_[steel_4340.key] = steel_4340;
        
        // Titanium Ti-6Al-4V
        SmartMaterial ti64("Titanium Ti-6Al-4V", "metal");
        ti64.subcategory = "titanium";
        ti64.density = MaterialProperty(4430, "kg/m³", "ASM", 5);
        ti64.youngs_modulus = MaterialProperty(113.8e9, "Pa", "ASTM", 5);
        ti64.yield_strength = MaterialProperty(880e6, "Pa", "MMPDS", 5);
        ti64.ultimate_strength = MaterialProperty(950e6, "Pa", "MMPDS", 5);
        ti64.poisson_ratio = MaterialProperty(0.342, "dimensionless", "ASM", 5);
        ti64.thermal_conductivity = MaterialProperty(6.7, "W/(m·K)", "NIST", 5);
        ti64.specific_heat = MaterialProperty(526, "J/(kg·K)", "NIST", 5);
        ti64.thermal_expansion = MaterialProperty(8.6e-6, "1/K", "ASM", 5);
        ti64.melting_point = MaterialProperty(1933, "K", "ASM", 5);
        ti64.cost_per_kg = 35.00;
        ti64.typical_uses = {"Aerospace", "Medical implants", "High-performance parts"};
        materials_[ti64.key] = ti64;
        
        // Add more materials here...
        // (Implementation would include all 50+ materials)
    }
    
    [[nodiscard]] double compute_similarity(
        const std::unordered_map<std::string, double>& known_props,
        const SmartMaterial& mat
    ) const {
        double total_distance = 0.0;
        int count = 0;
        
        for (const auto& [prop, value] : known_props) {
            if (auto mat_prop = mat.get_property(prop)) {
                double weight = property_weights_.count(prop) ? property_weights_.at(prop) : 0.5;
                
                // Normalized difference
                double diff = std::abs(value - mat_prop->value) / mat_prop->value;
                total_distance += weight * diff * diff;
                count++;
            }
        }
        
        return count > 0 ? std::sqrt(total_distance / count) : 1e9;
    }
};

} // namespace matlabcpp
