// MatLabC++ Main Executable
// src/main.cpp

#include <iostream>
#include <string>
#include "matlabcpp/active_window.hpp"

void print_usage() {
std::cout << "MatLabC++ v0.4.0 - Professional MATLAB-Compatible Environment\n\n";
std::cout << "Usage:\n";
    std::cout << "  mlab++                Run interactive active window\n";
    std::cout << "  mlab++ script.m       Execute MATLAB script\n";
    std::cout << "  mlab++ --version      Show version information\n";
    std::cout << "  mlab++ --help         Show this help\n";
    std::cout << "\n";
}

int main(int argc, char** argv) {
    // Parse command line
    if (argc == 1) {
        // No arguments: start active window
        matlabcpp::ActiveWindow window;
        window.start();
        return 0;
    }
    
    std::string arg = argv[1];
    
    if (arg == "--version" || arg == "-v") {
        std::cout << "MatLabC++ version 0.4.0\n";
        std::cout << "Professional MATLAB-Compatible Numerical Computing\n";
        return 0;
    }
    
    if (arg == "--help" || arg == "-h") {
        print_usage();
        return 0;
    }
    
    // TODO: Execute script file
    std::cout << "Script execution not yet implemented: " << arg << "\n";
    std::cout << "For now, use interactive mode: mlab++\n";
    return 1;
}
