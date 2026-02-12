// MatLabC++ Main Executable
// src/main.cpp

#include <iostream>
#include <string>
#include <filesystem>
#include "matlabcpp/active_window.hpp"

// Forward declaration from interpreter
namespace matlabcpp { namespace interpreter {
    int run_script(const std::string& path);
}}

// Forward declaration from publisher
namespace matlabcpp { namespace publishing {
    int publish(const std::string& script_path, const std::string& format);
}}

void print_usage() {
    std::cout << "MatLabC++ v0.5.0 - Professional MATLAB-Compatible Environment\n\n";
    std::cout << "Usage:\n";
    std::cout << "  mlab++                    Run interactive active window\n";
    std::cout << "  mlab++ script.m           Execute MATLAB script\n";
    std::cout << "  mlab++ publish script.m   Generate HTML report from script\n";
    std::cout << "  mlab++ --version          Show version information\n";
    std::cout << "  mlab++ --help             Show this help\n";
    std::cout << "\n";
}

int main(int argc, char** argv) {
    // No arguments: start interactive active window
    if (argc == 1) {
        matlabcpp::ActiveWindow window;
        window.start();
        return 0;
    }

    std::string arg = argv[1];

    if (arg == "--version" || arg == "-v") {
        std::cout << "MatLabC++ version 0.5.0\n";
        std::cout << "Professional MATLAB-Compatible Numerical Computing\n";
        return 0;
    }

    if (arg == "--help" || arg == "-h") {
        print_usage();
        return 0;
    }

    // publish command: mlab++ publish script.m [format]
    if (arg == "publish" && argc >= 3) {
        std::string script = argv[2];
        std::string format = (argc >= 4) ? argv[3] : "html";
        return matlabcpp::publishing::publish(script, format);
    }

    // Execute .m script file
    if (arg.size() > 2 && arg.substr(arg.size() - 2) == ".m") {
        if (!std::filesystem::exists(arg)) {
            std::cerr << "Error: File not found: " << arg << "\n";
            return 1;
        }
        return matlabcpp::interpreter::run_script(arg);
    }

    // Unknown argument
    std::cerr << "Unknown command: " << arg << "\n";
    std::cerr << "Run 'mlab++ --help' for usage information.\n";
    return 1;
}
