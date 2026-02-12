pragma once
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <optional>
#include <numbers>

namespace matlabcpp::constants {

struct PhysicalConstants {
    static constexpr double c = 299792458.0;
    static constexpr double h = 6.62607015e-34;
    static constexpr double G = 6.67430e-11;
    static constexpr double g = 9.80665;
    static constexpr double k_B = 1.380649e-23;
    static constexpr double N_A = 6.02214076e23;
    static constexpr double R = 8.314462618;
};

class ConstantsRegistry {
    std::unordered_map<std::string, double> registry_;
    
public:
    ConstantsRegistry() {
        registry_["c"] = PhysicalConstants::c;
        registry_["G"] = PhysicalConstants::G;
        registry_["g"] = PhysicalConstants::g;
        registry_["gravity"] = PhysicalConstants::g;
        registry_["pi"] = std::numbers::pi;
        registry_["e"] = std::numbers::e;
        registry_["rho_aluminum"] = 2700.0;
        registry_["rho_copper"] = 8960.0;
        registry_["rho_steel"] = 7850.0;
        registry_["rho_water"] = 1000.0;
    }
    
    [[nodiscard]] std::optional<double> get(const std::string& name) const {
        auto it = registry_.find(name);
        return (it != registry_.end()) ? std::optional{it->second} : std::nullopt;
    }
    
    void set(const std::string& name, double value) {
        registry_[name] = value;
    }
    
    [[nodiscard]] size_t count() const { return registry_.size(); }
};

inline ConstantsRegistry& registry() {
    static ConstantsRegistry instance;
    return instance;
}

} // namespace matlabcpp::constants
