#pragma once

#include <string>
#include <unordered_map>
#include <optional>
#include <vector>
#include <functional>
#include <memory>

namespace matlabcpp {

// ========== Universal Property Container ==========
struct MaterialProperty {
    double value;
    double uncertainty = 0.0;
    std::string units;
    std::string source;
    int confidence = 3;  // 1-5 (5 = verified standard)
    
    // Temperature dependence (optional)
    std::function<double(double)> temp_function = nullptr;
    
    // Get value at specific temperature
    double at_temp(double temp_K) const {
        if (temp_function) {
            return temp_function(temp_K);
        }
        return value;
    }
    
    // Convenience constructors
    MaterialProperty() = default;
    
    MaterialProperty(double v, std::string u, std::string src, int conf = 3)
        : value(v), units(std::move(u)), source(std::move(src)), confidence(conf) {}
    
    MaterialProperty(double v, double unc, std::string u, std::string src, int conf = 3)
        : value(v), uncertainty(unc), units(std::move(u)), source(std::move(src)), confidence(conf) {}
};

// ========== Smart Material Entry ==========
class SmartMaterial {
public:
    std::string name;
    std::string category;      // "metal", "plastic", "composite", "ceramic"
    std::string subcategory;   // "steel", "aluminum", "carbon_fiber"
    
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
    std::optional<MaterialProperty> bulk_modulus;
    std::optional<MaterialProperty> hardness;
    std::optional<MaterialProperty> fracture_toughness;
    std::optional<MaterialProperty> fatigue_strength;
    
    // Cost & availability
    std::optional<double> cost_per_kg;
    std::optional<std::string> availability;
    
    // Applications & notes
    std::vector<std::string> typical_uses;
    std::vector<std::string> warnings;
    
    // Inference data
    std::unordered_map<std::string, double> inference_vector;
    
    // Constructors
    SmartMaterial() = default;
    SmartMaterial(std::string n, std::string cat) 
        : name(std::move(n)), category(std::move(cat)) {}
    
    // Query interface
    std::optional<MaterialProperty> get_property(const std::string& prop_name) const;
    
    // Temperature-dependent lookup
    double get_value_at_temp(const std::string& prop_name, double temp_K) const;
    
    // Calculate derived properties
    double get_strength_to_weight() const {
        return yield_strength.value / density.value;
    }
    
    double get_stiffness_to_weight() const {
        return youngs_modulus.value / density.value;
    }
    
    // Export/Import
    std::string to_json() const;
    static SmartMaterial from_json(const std::string& json);
    
    // Comparison
    bool operator==(const SmartMaterial& other) const {
        return name == other.name;
    }
};

// ========== Inference Results ==========
struct InferenceResult {
    SmartMaterial material;
    double confidence = 0.0;
    std::string reasoning;
    std::vector<std::string> alternatives;
    
    InferenceResult() = default;
    InferenceResult(SmartMaterial mat, double conf, std::string reason)
        : material(std::move(mat)), confidence(conf), reasoning(std::move(reason)) {}
};

// ========== Material Comparison ==========
struct MaterialComparison {
    std::vector<std::string> materials;
    std::unordered_map<std::string, std::vector<double>> properties;
    std::string winner;
    std::string reasoning;
    double score = 0.0;
};

// ========== Selection Criteria ==========
struct SelectionCriteria {
    double min_strength = 0;
    double max_density = 1e6;
    double min_temp = 0;
    double max_temp = 1e6;
    double max_cost = 1e6;
    std::string category = "any";
    std::vector<std::string> required_properties;
};

// ========== Smart Database ==========
class SmartMaterialDB {
private:
    std::unordered_map<std::string, SmartMaterial> materials_;
    
    // Inference cache
    struct InferenceCache {
        std::vector<std::string> last_queries;
        std::unordered_map<std::string, int> access_counts;
        std::unordered_map<std::string, double> property_weights;
    } cache_;
    
    // Helper methods
    double calculate_similarity(
        const SmartMaterial& mat,
        const std::unordered_map<std::string, double>& target_props
    ) const;
    
    void normalize_name(std::string& name) const;
    
public:
    SmartMaterialDB();
    
    // Add material (with validation)
    bool add(const SmartMaterial& mat);
    bool add(SmartMaterial&& mat);
    
    // Load from external sources
    bool load_from_json(const std::string& filepath);
    bool load_from_csv(const std::string& filepath);
    bool load_builtin();
    
    // Basic query
    std::optional<SmartMaterial> get(const std::string& name) const;
    std::vector<SmartMaterial> search(const std::string& query) const;
    
    // Smart inference
    std::optional<InferenceResult> infer_from_density(
        double rho,
        double tolerance = 100.0
    ) const;
    
    std::optional<InferenceResult> infer_from_properties(
        const std::unordered_map<std::string, double>& known_props
    ) const;
    
    // Material selection
    std::vector<InferenceResult> select_materials(
        const SelectionCriteria& criteria,
        const std::string& optimize_for = "strength_to_weight"
    ) const;
    
    // Compare materials
    MaterialComparison compare(const std::vector<std::string>& material_names) const;
    
    // Recommend material for application
    InferenceResult recommend_for_application(
        const std::string& application,
        const std::unordered_map<std::string, double>& constraints = {}
    ) const;
    
    // Statistics
    size_t count() const { return materials_.size(); }
    std::vector<std::string> categories() const;
    std::vector<std::string> list_all() const;
    
    // Validation
    std::vector<std::string> validate() const;
    
    // Learning
    void record_query(const std::string& property);
    std::unordered_map<std::string, double> get_property_importance() const;
};

// ========== Global Instance ==========
SmartMaterialDB& global_material_db();

// ========== Convenience Functions ==========
inline std::optional<SmartMaterial> get_material(const std::string& name) {
    return global_material_db().get(name);
}

inline std::vector<SmartMaterial> search_materials(const std::string& query) {
    return global_material_db().search(query);
}

inline std::optional<InferenceResult> find_material_by_density(double rho, double tol = 100.0) {
    return global_material_db().infer_from_density(rho, tol);
}

} // namespace matlabcpp
