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
    int publish_with_options(const std::string& script_path, const std::string& format,
                            const std::string& theme, const std::string& font, int fontsize);
    void print_style_options();
}}

void print_usage() {
    std::cout << "MatLabC++ v0.5.0 - Professional MATLAB-Compatible Environment\n\n";
    std::cout << "Usage:\n";
    std::cout << "  mlab++                    Run interactive active window\n";
    std::cout << "  mlab++ script.m           Execute MATLAB script\n";
    std::cout << "  mlab++ publish script.m   Generate HTML report (MATLAB theme)\n";
    std::cout << "  mlab++ publish script.m --theme dark\n";
    std::cout << "  mlab++ publish script.m --font Arial --fontsize 14\n";
    std::cout << "  mlab++ --version          Show version information\n";
    std::cout << "  mlab++ --help             Show this help\n";
    std::cout << "\n";
    std::cout << "Publish options:\n";
    std::cout << "  --theme <name>    Theme: default, classic, dark\n";
    std::cout << "  --font <name>     Font family override\n";
    std::cout << "  --fontsize <px>   Font size override\n";
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

    // publish command: mlab++ publish script.m [format] [options]
    if (arg == "publish" && argc >= 3) {
        std::string script = argv[2];
        std::string format = "html";
        std::string theme = "default";
        std::string font = "";
        int fontsize = 0;

        // Parse optional arguments
        for (int i = 3; i < argc; i++) {
            std::string opt = argv[i];

            if (opt == "--help" || opt == "-h") {
                matlabcpp::publishing::print_style_options();
                return 0;
            }
            else if (opt == "--theme" && i + 1 < argc) {
                theme = argv[++i];
            }
            else if (opt == "--font" && i + 1 < argc) {
                font = argv[++i];
            }
            else if (opt == "--fontsize" && i + 1 < argc) {
                fontsize = std::stoi(argv[++i]);
            }
            else if (opt[0] != '-') {
                format = opt;
            }
        }

        // Use customized publish if options provided
        if (theme != "default" || !font.empty() || fontsize > 0) {
            return matlabcpp::publishing::publish_with_options(script, format, theme, font, fontsize);
        }

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
