pragma once
#include "core.hpp"
#include "constants.hpp"
#include "materials.hpp"
#include "materials_inference.hpp"
#include "system.hpp"

namespace matlabcpp {

class System {
    bool initialized_ = false;
    MaterialDB materials_;
    
public:
    void initialize() {
        if (initialized_) return;
        
        system::print_motd();
        init_material_inference(materials_);
        
        initialized_ = true;
        
        std::cout << "System initialized\n";
        std::cout << "  Constants:  " << constants::registry().count() << " available\n";
        std::cout << "  Materials:  " << materials_.size() << " in database\n";
        std::cout << "  Inference:  " << inference_engine().knowledge_size() << " materials learned\n\n";
    }
    
    [[nodiscard]] MaterialDB& materials() { return materials_; }
    [[nodiscard]] const MaterialDB& materials() const { return materials_; }
};

inline System& system() {
    static System sys;
    return sys;
}

inline std::optional<double> lookup(const std::string& name) {
    return constants::registry().get(name);
}

inline void set_constant(const std::string& name, double value) {
    constants::registry().set(name, value);
}

inline std::optional<PlasticProps> get_material(const std::string& name) {
    return system().materials().get(name);
}

inline std::optional<InferenceResult> guess_material(double density) {
    return identify_material(density);
}

struct QuickProblem {
    State initial_state;
    SimpleDrop model;
    RK45Options options;
    
    QuickProblem(Vec3 x0, Vec3 v0, double T0, const std::string& material_name = "pla") {
        initial_state = State(x0, v0, T0);
        
        auto mat = get_material(material_name);
        double m = 68.1;
        double cp = 1400.0;
        
        if (mat) {
            m = mat->thermal.density * 0.001;
            cp = mat->thermal.specific_heat;
        }
        
        model = SimpleDrop(m, 1.225, 0.47, 0.0314159, 10.0, cp, 293.0);
    }
    
    [[nodiscard]] std::vector<Sample> solve(double t_end = 10.0) const {
        return integrate_rk45(model, 0.0, t_end, initial_state, options);
    }
};

} // namespace matlabcpp
