#include "matlabcpp/materials_smart.hpp"
#include <algorithm>
#include <cmath>
#include <sstream>
#include <fstream>
#include <stdexcept>

namespace matlabcpp {

// ========== MaterialProperty Implementation ==========

// (Methods already inline in header)

// ========== SmartMaterial Implementation ==========

std::optional<MaterialProperty> SmartMaterial::get_property(const std::string& prop_name) const {
    if (prop_name == "density") return density;
    if (prop_name == "youngs_modulus") return youngs_modulus;
    if (prop_name == "yield_strength") return yield_strength;
    if (prop_name == "ultimate_strength") return ultimate_strength;
    if (prop_name == "poisson_ratio") return poisson_ratio;
    if (prop_name == "thermal_conductivity") return thermal_conductivity;
    if (prop_name == "specific_heat") return specific_heat;
    if (prop_name == "thermal_expansion") return thermal_expansion;
    if (prop_name == "melting_point") return melting_point;
    
    if (prop_name == "glass_transition" && glass_transition) return *glass_transition;
    if (prop_name == "shear_modulus" && shear_modulus) return *shear_modulus;
    if (prop_name == "bulk_modulus" && bulk_modulus) return *bulk_modulus;
    if (prop_name == "hardness" && hardness) return *hardness;
    if (prop_name == "fracture_toughness" && fracture_toughness) return *fracture_toughness;
    if (prop_name == "fatigue_strength" && fatigue_strength) return *fatigue_strength;
    
    return std::nullopt;
}

double SmartMaterial::get_value_at_temp(const std::string& prop_name, double temp_K) const {
    auto prop = get_property(prop_name);
    if (!prop) {
        throw std::runtime_error("Property '" + prop_name + "' not found");
    }
    return prop->at_temp(temp_K);
}

std::string SmartMaterial::to_json() const {
    std::ostringstream oss;
    oss << "{\n";
    oss << "  \"name\": \"" << name << "\",\n";
    oss << "  \"category\": \"" << category << "\",\n";
    oss << "  \"subcategory\": \"" << subcategory << "\",\n";
    
    // Core properties
    oss << "  \"density\": " << density.value << ",\n";
    oss << "  \"youngs_modulus\": " << youngs_modulus.value << ",\n";
    oss << "  \"yield_strength\": " << yield_strength.value << "\n";
    
    oss << "}";
    return oss.str();
}

SmartMaterial SmartMaterial::from_json(const std::string& json) {
    // Simplified JSON parsing (real implementation would use a library)
    SmartMaterial mat;
    
    // Parse basic fields
    size_t pos = json.find("\"name\":");
    if (pos != std::string::npos) {
        size_t start = json.find("\"", pos + 7) + 1;
        size_t end = json.find("\"", start);
        mat.name = json.substr(start, end - start);
    }
    
    // TODO: Full JSON parsing implementation
    
    return mat;
}

// ========== SmartMaterialDB Implementation ==========

SmartMaterialDB::SmartMaterialDB() {
    // Initialize default property weights
    cache_.property_weights["density"] = 1.0;
    cache_.property_weights["youngs_modulus"] = 0.8;
    cache_.property_weights["yield_strength"] = 0.9;
    cache_.property_weights["thermal_conductivity"] = 0.6;
    
    // Load built-in materials
    load_builtin();
}

bool SmartMaterialDB::add(const SmartMaterial& mat) {
    if (mat.name.empty()) {
        return false;
    }
    
    std::string key = mat.name;
    normalize_name(key);
    
    materials_[key] = mat;
    return true;
}

bool SmartMaterialDB::add(SmartMaterial&& mat) {
    if (mat.name.empty()) {
        return false;
    }
    
    std::string key = mat.name;
    normalize_name(key);
    
    materials_[key] = std::move(mat);
    return true;
}

bool SmartMaterialDB::load_builtin() {
    // Aluminum 6061-T6
    SmartMaterial al6061("aluminum_6061", "metal");
    al6061.subcategory = "aluminum";
    al6061.density = MaterialProperty(2700, 50, "kg/m³", "ASM Handbook", 5);
    al6061.youngs_modulus = MaterialProperty(68.9e9, 2e9, "Pa", "ASM Handbook", 5);
    al6061.yield_strength = MaterialProperty(276e6, 10e6, "Pa", "MMPDS", 5);
    al6061.ultimate_strength = MaterialProperty(310e6, 10e6, "Pa", "MMPDS", 5);
    al6061.poisson_ratio = MaterialProperty(0.33, 0.01, "", "ASM", 5);
    al6061.thermal_conductivity = MaterialProperty(167, 5, "W/(m·K)", "NIST", 5);
    al6061.specific_heat = MaterialProperty(896, 20, "J/(kg·K)", "NIST", 5);
    al6061.thermal_expansion = MaterialProperty(23.6e-6, 0.5e-6, "1/K", "ASM", 5);
    al6061.melting_point = MaterialProperty(855, 5, "K", "ASM", 5);
    al6061.cost_per_kg = 3.50;
    al6061.availability = "common";
    al6061.typical_uses = {"Aircraft fittings", "Bicycle frames", "General structures"};
    add(std::move(al6061));
    
    // Steel (generic carbon steel)
    SmartMaterial steel("steel", "metal");
    steel.subcategory = "steel";
    steel.density = MaterialProperty(7850, 50, "kg/m³", "ASM Handbook", 5);
    steel.youngs_modulus = MaterialProperty(200e9, 10e9, "Pa", "ASM Handbook", 5);
    steel.yield_strength = MaterialProperty(250e6, 20e6, "Pa", "ASTM A36", 5);
    steel.ultimate_strength = MaterialProperty(400e6, 20e6, "Pa", "ASTM A36", 5);
    steel.poisson_ratio = MaterialProperty(0.30, 0.01, "", "ASM", 5);
    steel.thermal_conductivity = MaterialProperty(50, 5, "W/(m·K)", "NIST", 5);
    steel.specific_heat = MaterialProperty(490, 20, "J/(kg·K)", "NIST", 5);
    steel.thermal_expansion = MaterialProperty(12e-6, 0.5e-6, "1/K", "ASM", 5);
    steel.melting_point = MaterialProperty(1811, 20, "K", "ASM", 5);
    steel.cost_per_kg = 0.80;
    steel.availability = "common";
    steel.typical_uses = {"Construction", "General fabrication", "Structural beams"};
    steel.warnings = {"Susceptible to corrosion", "Brittle at low temperatures"};
    add(std::move(steel));
    
    // PEEK polymer
    SmartMaterial peek("peek", "plastic");
    peek.subcategory = "thermoplastic";
    peek.density = MaterialProperty(1320, 20, "kg/m³", "Victrex datasheet", 4);
    peek.youngs_modulus = MaterialProperty(3.6e9, 0.2e9, "Pa", "ISO 527", 4);
    peek.yield_strength = MaterialProperty(90e6, 5e6, "Pa", "ISO 527", 4);
    peek.ultimate_strength = MaterialProperty(100e6, 5e6, "Pa", "ISO 527", 4);
    peek.poisson_ratio = MaterialProperty(0.40, 0.02, "", "ISO", 4);
    peek.thermal_conductivity = MaterialProperty(0.25, 0.02, "W/(m·K)", "ASTM E1530", 4);
    peek.specific_heat = MaterialProperty(1340, 50, "J/(kg·K)", "DSC", 4);
    peek.thermal_expansion = MaterialProperty(47e-6, 2e-6, "1/K", "ISO 11359", 4);
    peek.melting_point = MaterialProperty(616, 5, "K", "DSC", 4);
    peek.glass_transition = MaterialProperty(416, 5, "K", "DSC", 4);
    peek.cost_per_kg = 80.0;
    peek.availability = "specialty";
    peek.typical_uses = {"Medical implants", "Aerospace components", "High-temp bearings"};
    add(std::move(peek));
    
    // PLA (3D printing)
    SmartMaterial pla("pla", "plastic");
    pla.subcategory = "thermoplastic";
    pla.density = MaterialProperty(1240, 30, "kg/m³", "NatureWorks", 4);
    pla.youngs_modulus = MaterialProperty(3.5e9, 0.3e9, "Pa", "ASTM D638", 4);
    pla.yield_strength = MaterialProperty(50e6, 5e6, "Pa", "ASTM D638", 4);
    pla.ultimate_strength = MaterialProperty(60e6, 5e6, "Pa", "ASTM D638", 4);
    pla.poisson_ratio = MaterialProperty(0.36, 0.02, "", "ASTM", 3);
    pla.thermal_conductivity = MaterialProperty(0.13, 0.02, "W/(m·K)", "measurement", 3);
    pla.specific_heat = MaterialProperty(1800, 100, "J/(kg·K)", "DSC", 3);
    pla.thermal_expansion = MaterialProperty(68e-6, 5e-6, "1/K", "TMA", 3);
    pla.melting_point = MaterialProperty(423, 5, "K", "DSC", 4);
    pla.glass_transition = MaterialProperty(333, 5, "K", "DSC", 4);
    pla.cost_per_kg = 20.0;
    pla.availability = "common";
    pla.typical_uses = {"3D printing", "Packaging", "Prototyping"};
    pla.warnings = {"Low heat resistance", "Biodegradable"};
    add(std::move(pla));
    
    return true;
}

std::optional<SmartMaterial> SmartMaterialDB::get(const std::string& name) const {
    std::string key = name;
    normalize_name(key);
    
    auto it = materials_.find(key);
    if (it != materials_.end()) {
        return it->second;
    }
    
    return std::nullopt;
}

std::vector<SmartMaterial> SmartMaterialDB::search(const std::string& query) const {
    std::vector<SmartMaterial> results;
    
    std::string query_lower = query;
    std::transform(query_lower.begin(), query_lower.end(), query_lower.begin(), ::tolower);
    
    for (const auto& [key, mat] : materials_) {
        std::string name_lower = mat.name;
        std::transform(name_lower.begin(), name_lower.end(), name_lower.begin(), ::tolower);
        
        if (name_lower.find(query_lower) != std::string::npos ||
            mat.category.find(query_lower) != std::string::npos ||
            mat.subcategory.find(query_lower) != std::string::npos) {
            results.push_back(mat);
        }
    }
    
    return results;
}

std::optional<InferenceResult> SmartMaterialDB::infer_from_density(
    double rho,
    double tolerance
) const {
    InferenceResult best;
    best.confidence = 0.0;
    
    std::vector<std::string> candidates;
    
    for (const auto& [key, mat] : materials_) {
        double mat_rho = mat.density.value;
        double diff = std::abs(mat_rho - rho);
        
        if (diff <= tolerance) {
            double conf = 1.0 - (diff / tolerance);
            candidates.push_back(mat.name);
            
            if (conf > best.confidence) {
                best.material = mat;
                best.confidence = conf;
                best.reasoning = "Density match: " + std::to_string(mat_rho) + " kg/m³ (within " +
                                std::to_string(diff) + " kg/m³)";
            }
        }
    }
    
    if (best.confidence > 0.0) {
        best.alternatives = candidates;
        return best;
    }
    
    return std::nullopt;
}

std::optional<InferenceResult> SmartMaterialDB::infer_from_properties(
    const std::unordered_map<std::string, double>& known_props
) const {
    InferenceResult best;
    best.confidence = 0.0;
    
    for (const auto& [key, mat] : materials_) {
        double similarity = calculate_similarity(mat, known_props);
        
        if (similarity > best.confidence) {
            best.material = mat;
            best.confidence = similarity;
            best.reasoning = "Property match score: " + std::to_string(similarity);
        }
    }
    
    if (best.confidence > 0.5) {
        return best;
    }
    
    return std::nullopt;
}

double SmartMaterialDB::calculate_similarity(
    const SmartMaterial& mat,
    const std::unordered_map<std::string, double>& target_props
) const {
    double score = 0.0;
    double total_weight = 0.0;
    
    for (const auto& [prop_name, target_value] : target_props) {
        auto mat_prop = mat.get_property(prop_name);
        if (!mat_prop) continue;
        
        double mat_value = mat_prop->value;
        double diff = std::abs(mat_value - target_value);
        double relative_diff = diff / std::max(mat_value, target_value);
        
        double match_score = std::exp(-relative_diff);
        
        double weight = 1.0;
        auto weight_it = cache_.property_weights.find(prop_name);
        if (weight_it != cache_.property_weights.end()) {
            weight = weight_it->second;
        }
        
        score += match_score * weight;
        total_weight += weight;
    }
    
    return (total_weight > 0) ? (score / total_weight) : 0.0;
}

std::vector<InferenceResult> SmartMaterialDB::select_materials(
    const SelectionCriteria& criteria,
    const std::string& optimize_for
) const {
    std::vector<InferenceResult> results;
    
    for (const auto& [key, mat] : materials_) {
        // Check category
        if (criteria.category != "any" && mat.category != criteria.category) {
            continue;
        }
        
        // Check constraints
        if (mat.yield_strength.value < criteria.min_strength) continue;
        if (mat.density.value > criteria.max_density) continue;
        
        if (mat.cost_per_kg && *mat.cost_per_kg > criteria.max_cost) continue;
        
        // Calculate score based on optimization criterion
        double score = 0.0;
        if (optimize_for == "strength_to_weight") {
            score = mat.get_strength_to_weight();
        } else if (optimize_for == "stiffness_to_weight") {
            score = mat.get_stiffness_to_weight();
        } else {
            score = 1.0;
        }
        
        InferenceResult result;
        result.material = mat;
        result.confidence = score;
        result.reasoning = "Meets all constraints, " + optimize_for + " = " + std::to_string(score);
        
        results.push_back(result);
    }
    
    // Sort by score (descending)
    std::sort(results.begin(), results.end(),
              [](const InferenceResult& a, const InferenceResult& b) {
                  return a.confidence > b.confidence;
              });
    
    return results;
}

MaterialComparison SmartMaterialDB::compare(const std::vector<std::string>& material_names) const {
    MaterialComparison comp;
    comp.materials = material_names;
    
    // Collect properties
    std::vector<std::string> props = {
        "density", "youngs_modulus", "yield_strength", "thermal_conductivity"
    };
    
    for (const auto& prop_name : props) {
        std::vector<double> values;
        
        for (const auto& mat_name : material_names) {
            auto mat = get(mat_name);
            if (mat) {
                auto prop = mat->get_property(prop_name);
                if (prop) {
                    values.push_back(prop->value);
                } else {
                    values.push_back(0.0);
                }
            }
        }
        
        comp.properties[prop_name] = values;
    }
    
    // Determine winner (highest strength-to-weight)
    double best_score = 0.0;
    for (const auto& mat_name : material_names) {
        auto mat = get(mat_name);
        if (mat) {
            double score = mat->get_strength_to_weight();
            if (score > best_score) {
                best_score = score;
                comp.winner = mat_name;
                comp.score = score;
            }
        }
    }
    
    comp.reasoning = "Best strength-to-weight ratio: " + std::to_string(best_score);
    
    return comp;
}

InferenceResult SmartMaterialDB::recommend_for_application(
    const std::string& application,
    const std::unordered_map<std::string, double>& constraints
) const {
    // Application-specific recommendations
    SelectionCriteria criteria;
    
    if (application == "3d_printing") {
        criteria.category = "plastic";
        criteria.max_cost = 50.0;
    } else if (application == "aerospace") {
        criteria.min_strength = 300e6;
        criteria.max_density = 3000;
    } else if (application == "structural") {
        criteria.min_strength = 200e6;
        criteria.max_cost = 5.0;
    }
    
    // Apply user constraints
    for (const auto& [key, value] : constraints) {
        if (key == "min_strength") criteria.min_strength = value;
        if (key == "max_density") criteria.max_density = value;
        if (key == "max_cost") criteria.max_cost = value;
    }
    
    auto results = select_materials(criteria, "strength_to_weight");
    
    if (!results.empty()) {
        results[0].reasoning = "Recommended for " + application + ": " + results[0].reasoning;
        return results[0];
    }
    
    return InferenceResult();
}

std::vector<std::string> SmartMaterialDB::categories() const {
    std::vector<std::string> cats;
    for (const auto& [key, mat] : materials_) {
        if (std::find(cats.begin(), cats.end(), mat.category) == cats.end()) {
            cats.push_back(mat.category);
        }
    }
    return cats;
}

std::vector<std::string> SmartMaterialDB::list_all() const {
    std::vector<std::string> names;
    for (const auto& [key, mat] : materials_) {
        names.push_back(mat.name);
    }
    std::sort(names.begin(), names.end());
    return names;
}

std::vector<std::string> SmartMaterialDB::validate() const {
    std::vector<std::string> issues;
    
    for (const auto& [key, mat] : materials_) {
        // Check for negative values
        if (mat.density.value <= 0) {
            issues.push_back(mat.name + ": Negative or zero density");
        }
        
        // Check reasonable ranges
        if (mat.category == "metal" && mat.density.value < 1000) {
            issues.push_back(mat.name + ": Suspiciously low density for metal");
        }
        
        if (mat.youngs_modulus.value <= 0) {
            issues.push_back(mat.name + ": Invalid Young's modulus");
        }
        
        // Check source quality
        if (mat.density.confidence < 3) {
            issues.push_back(mat.name + ": Low confidence density data");
        }
    }
    
    return issues;
}

void SmartMaterialDB::normalize_name(std::string& name) const {
    std::transform(name.begin(), name.end(), name.begin(), ::tolower);
    std::replace(name.begin(), name.end(), ' ', '_');
    std::replace(name.begin(), name.end(), '-', '_');
}

void SmartMaterialDB::record_query(const std::string& property) {
    cache_.access_counts[property]++;
    cache_.last_queries.push_back(property);
    
    if (cache_.last_queries.size() > 100) {
        cache_.last_queries.erase(cache_.last_queries.begin());
    }
}

std::unordered_map<std::string, double> SmartMaterialDB::get_property_importance() const {
    return cache_.property_weights;
}

// ========== Global Instance ==========
SmartMaterialDB& global_material_db() {
    static SmartMaterialDB instance;
    return instance;
}

} // namespace matlabcpp
