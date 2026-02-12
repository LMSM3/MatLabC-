pragma once
#include "materials.hpp"
#include <vector>
#include <algorithm>
#include <cmath>
#include <limits>
#include <optional>

namespace matlabcpp {

struct PropertyVector {
    double density = 0;
    double thermal_conductivity = 0;
    uint32_t known_mask = 0;
    
    void set_density(double v) { density = v; known_mask |= 1; }
    void set_conductivity(double v) { thermal_conductivity = v; known_mask |= 2; }
    [[nodiscard]] bool has_density() const { return known_mask & 1; }
};

struct InferenceResult {
    std::string material_name;
    PlasticProps properties;
    double confidence;
    std::string reasoning;
    
    InferenceResult(std::string name, PlasticProps props, double conf, std::string reason)
        : material_name(std::move(name)), properties(std::move(props)), 
          confidence(conf), reasoning(std::move(reason)) {}
};

class MaterialInferenceEngine {
    struct MaterialNode {
        std::string name;
        PlasticProps props;
        
        MaterialNode(std::string n, PlasticProps p) : name(std::move(n)), props(std::move(p)) {}
    };
    
    std::vector<MaterialNode> knowledge_base_;
    
public:
    void learn(const std::string& name, const PlasticProps& props) {
        knowledge_base_.emplace_back(name, props);
    }
    
    [[nodiscard]] std::optional<InferenceResult> infer_by_density(double rho, double tolerance = 50.0) const {
        for (const auto& node : knowledge_base_) {
            double diff = std::abs(node.props.thermal.density - rho);
            if (diff <= tolerance) {
                return InferenceResult{
                    node.name,
                    node.props,
                    1.0 - diff / tolerance,
                    "Matched by density"
                };
            }
        }
        return std::nullopt;
    }
    
    [[nodiscard]] size_t knowledge_size() const { return knowledge_base_.size(); }
};

inline MaterialInferenceEngine& inference_engine() {
    static MaterialInferenceEngine engine;
    return engine;
}

inline void init_material_inference(const MaterialDB& db) {
    auto& engine = inference_engine();
    for (const auto& [key, props] : db) {
        engine.learn(key, props);
    }
}

inline std::optional<InferenceResult> identify_material(double density) {
    return inference_engine().infer_by_density(density);
}

} // namespace matlabcpp
