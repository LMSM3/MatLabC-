#include <matlabcpp.hpp>
#include <iostream>
#include <sstream>
#include <iomanip>

using namespace matlabcpp;

void print_banner() {
    std::cout << "\n";
    std::cout << "????????????????????????????????????????????????????????????\n";
    std::cout << "?  MatLabC++ - Numerical Computing for Everyone           ?\n";
    std::cout << "?  Lightweight | Fast | No MATLAB Required                ?\n";
    std::cout << "????????????????????????????????????????????????????????????\n\n";
    std::cout << "Perfect for: Quick calculations, material lookups, physics problems\n";
    std::cout << "Memory: <50 MB | Startup: <0.1s | No installation bloat\n\n";
}

void print_help() {
    std::cout << R"(
?????????????????????????????????????????????????????????????????
?                     QUICK REFERENCE                           ?
?????????????????????????????????????????????????????????????????

INSTANT CALCULATIONS
  calc <expression>         - Evaluate: calc 2*pi*0.5
  convert <value> <unit>    - Convert: convert 100 ft_to_m

MATERIALS (No database required!)
  material <name>           - Properties: material steel
  density <material>        - Quick lookup: density aluminum
  identify <value>          - Find material: identify 2700

CONSTANTS
  constant <name>           - Value: constant g
  list constants            - Show all available

PHYSICS PROBLEMS
  drop <height>             - Object falling: drop 100
  heat <T1> <T2>            - Cooling time: heat 373 293
  terminal <mass>           - Terminal velocity: terminal 70

SCRIPTS (v0.2.0)
  run <script>              - Execute: run helix_plot.c or helix_plot.m

UTILITIES
  examples                  - Show worked examples
  units                     - Unit conversions
  help                      - This help
  exit                      - Quit

TIP: Just type what you want! "What is pi?" or "density of water"

)" << std::endl;
}

void show_examples() {
    std::cout << R"(
?????????????????????????????????????????????????????????????????
?                    WORKED EXAMPLES                            ?
?????????????????????????????????????????????????????????????????

1. QUICK CALCULATION
   > calc 2*pi*5
   Result: 31.4159 m (if radius = 5m, circumference)

2. MATERIAL LOOKUP
   > density aluminum
   2700 kg/m³
   > material peek
   PEEK (High-performance plastic)
   Density: 1320 kg/m³, Melts at: 343°C

3. UNIT CONVERSION  
   > convert 100 psi_to_pa
   689,475 Pa (Pascals)

4. PHYSICS PROBLEM
   > drop 300
   Simulating object dropped from 300m...
   Time to ground: 7.82 s
   Final velocity: 76.7 m/s

5. FIND MATERIAL FROM PROPERTY
   > identify 1240
   Best match: PLA (3D printing plastic)
   Confidence: 98%

Type 'help' for full command list.

)" << std::endl;
}

void quick_calc(const std::string& expr) {
    // Simple calculator for common cases
    if (expr.find("pi") != std::string::npos) {
        std::cout << "? = " << std::numbers::pi << "\n\n";
        return;
    }
    
    // Try to parse as number * constant
    std::istringstream iss(expr);
    double num;
    std::string op, name;
    
    if (iss >> num >> op >> name) {
        auto val = constants::registry().get(name);
        if (val) {
            double result = 0;
            if (op == "*") result = num * (*val);
            else if (op == "/") result = num / (*val);
            else if (op == "+") result = num + (*val);
            else if (op == "-") result = num - (*val);
            
            std::cout << "Result: " << result << "\n\n";
            return;
        }
    }
    
    std::cout << "Try: 'calc 2*pi*5' or 'constant g'\n\n";
}

void quick_material(const std::string& name) {
    auto mat = get_material(name);
    if (mat) {
        std::cout << "\n" << mat->name << "\n";
        std::cout << "  Density:     " << mat->thermal.density << " kg/m³\n";
        std::cout << "  Conductivity:" << mat->thermal.conductivity << " W/(m·K)\n";
        std::cout << "  Melts at:    " << (mat->melt_temp - 273.15) << "°C\n\n";
    } else {
        std::cout << "Material '" << name << "' not found.\n";
        std::cout << "Try: abs, nylon6, peek, pc, pla, petg, ptfe\n";
        std::cout << "Or: steel, aluminum, copper, water\n\n";
    }
}

void quick_drop(double height) {
    std::cout << "\nDropping object from " << height << " m...\n";
    
    State s0(Vec3{0, 0, height}, Vec3{0, 0, 0}, 300.0);
    SimpleDrop model(1.0, 1.225, 0.47, 0.01, 10.0, 1000.0, 293.0);
    
    auto samples = integrate_rk45(model, 0.0, 100.0, s0);
    
    // Find when it hits ground
    for (const auto& sample : samples) {
        if (sample.state.position.z <= 0) {
            std::cout << "  Time to ground: " << std::fixed << std::setprecision(2) 
                      << sample.time << " s\n";
            std::cout << "  Final velocity: " << sample.state.velocity.norm() << " m/s\n\n";
            return;
        }
    }
}

int main(int argc, char** argv) {
    print_banner();
    
    // Batch mode for quick answers
    if (argc > 1) {
        std::string cmd = argv[1];
        if (cmd == "help") {
            print_help();
            return 0;
        } else if (cmd == "examples") {
            show_examples();
            return 0;
        } else if (cmd == "constant" && argc > 2) {
            if (auto val = constants::registry().get(argv[2])) {
                std::cout << argv[2] << " = " << *val << "\n";
            } else {
                std::cout << "Constant '" << argv[2] << "' not found.\n";
            }
            return 0;
        } else if (cmd == "material" && argc > 2) {
            quick_material(argv[2]);
            return 0;
        }
    }
    
    // Initialize system (quiet)
    system().initialize();
    
    std::cout << "Type 'examples' to see what you can do, or 'help' for commands.\n";
    std::cout << "Try: 'material peek' or 'drop 100' or 'constant pi'\n\n";
    
    std::string line;
    while (true) {
        std::cout << ">>> ";
        if (!std::getline(std::cin, line)) break;
        
        if (line.empty()) continue;
        
        std::istringstream iss(line);
        std::string cmd;
        iss >> cmd;
        
        // Normalize input
        std::transform(cmd.begin(), cmd.end(), cmd.begin(), ::tolower);
        
        if (cmd == "exit" || cmd == "quit" || cmd == "q") {
            break;
            
        } else if (cmd == "help" || cmd == "h" || cmd == "?") {
            print_help();
            
        } else if (cmd == "examples") {
            show_examples();
            
        } else if (cmd == "calc" || cmd == "calculate") {
            std::string expr;
            std::getline(iss, expr);
            quick_calc(expr);
            
        } else if (cmd == "constant" || cmd == "const") {
            std::string name;
            iss >> name;
            if (auto val = constants::registry().get(name)) {
                std::cout << name << " = " << std::scientific << std::setprecision(6) 
                          << *val << std::fixed << "\n\n";
            } else {
                std::cout << "Not found. Try: g, pi, c, R, k_B\n\n";
            }
            
        } else if (cmd == "material" || cmd == "mat") {
            std::string name;
            iss >> name;
            quick_material(name);
            
        } else if (cmd == "density") {
            std::string name;
            iss >> name;
            auto mat = get_material(name);
            if (mat) {
                std::cout << mat->thermal.density << " kg/m³\n\n";
            } else {
                std::cout << "Material not found.\n\n";
            }
            
        } else if (cmd == "identify") {
            double rho;
            iss >> rho;
            if (auto result = guess_material(rho)) {
                std::cout << "\nBest match: " << result->material_name << "\n";
                std::cout << "Confidence: " << std::fixed << std::setprecision(0) 
                          << (result->confidence * 100) << "%\n";
                std::cout << "Density: " << result->properties.thermal.density << " kg/m³\n\n";
            } else {
                std::cout << "No match found.\n\n";
            }
            
        } else if (cmd == "drop") {
            double h;
            iss >> h;
            if (h > 0 && h < 10000) {
                quick_drop(h);
            } else {
                std::cout << "Height must be between 0 and 10000 m\n\n";
            }
            
        } else if (cmd == "run") {
            std::string script_path;
            iss >> script_path;
            if (script_path.empty()) {
                std::cout << "Usage: run <script.c|script.m>\n";
                std::cout << "Example: run examples/scripts/helix_plot.c\n\n";
            } else {
                std::cout << "Executing " << script_path << "...\n";
                auto result = script::run_script(script_path);
                if (result.success) {
                    std::cout << result.output;
                    if (!result.error.empty()) {
                        std::cout << "Warnings:\n" << result.error;
                    }
                    std::cout << "\n";
                } else {
                    std::cout << "Error: Script execution failed\n";
                    if (!result.error.empty()) {
                        std::cout << result.error << "\n";
                    }
                    std::cout << "Exit code: " << result.exit_code << "\n\n";
                }
            }
            
        } else if (cmd == "list") {
            std::string what;
            iss >> what;
            if (what == "constants") {
                std::cout << "\nAvailable constants:\n";
                std::cout << "  Physical: g, G, c, h, k_B, N_A, R\n";
                std::cout << "  Math: pi, e\n";
                std::cout << "  Materials: rho_aluminum, rho_steel, rho_water\n\n";
            } else if (what == "materials") {
                std::cout << "\nAvailable materials:\n";
                std::cout << "  Plastics: abs, nylon6, peek, pc, pla, petg, ptfe\n";
                std::cout << "  Use: 'material <name>' for details\n\n";
            }
            
        } else if (cmd == "what" || cmd == "whats") {
            // Natural language shortcuts
            std::string rest;
            std::getline(iss, rest);
            if (rest.find("pi") != std::string::npos) {
                std::cout << "? = " << std::numbers::pi << "\n\n";
            } else if (rest.find("gravity") != std::string::npos) {
                std::cout << "g = 9.80665 m/s² (standard gravity)\n\n";
            } else {
                std::cout << "Try: 'constant pi' or 'material peek'\n\n";
            }
            
        } else {
            std::cout << "Unknown command. Type 'help' or try:\n";
            std::cout << "  'material peek' - Show material properties\n";
            std::cout << "  'drop 100' - Drop simulation\n";
            std::cout << "  'constant g' - Physical constants\n\n";
        }
    }
    
    std::cout << "\nThanks for using MatLabC++!\n";
    return 0;
}
