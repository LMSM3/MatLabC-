#pragma once
#include <string>
#include <vector>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <cstdlib>

namespace matlabcpp::script {

enum class ScriptType { MATLAB, C_SOURCE, UNKNOWN };

inline ScriptType detect_type(const std::string& path) {
    std::filesystem::path p(path);
    auto ext = p.extension().string();
    if (ext == ".m") return ScriptType::MATLAB;
    if (ext == ".c") return ScriptType::C_SOURCE;
    return ScriptType::UNKNOWN;
}

struct ScriptResult {
    bool success;
    std::string output;
    std::string error;
    int exit_code;
};

inline ScriptResult run_matlab_script(const std::string& path) {
    // For .m files: interpret as MATLAB/Octave-compatible syntax
    // (Placeholder: actual MATLAB interpreter would go here)
    std::ifstream ifs(path);
    if (!ifs) return {false, "", "Failed to open " + path, 1};
    
    std::string content((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());
    
    // Simple execution: pass to octave if available, otherwise return content
    std::string cmd = "octave --silent --eval \"run('" + path + "')\" 2>&1";
    FILE* pipe = popen(cmd.c_str(), "r");
    if (!pipe) {
        return {false, content, "Octave not available; showing script content only", 127};
    }
    
    std::string result;
    char buffer[256];
    while (fgets(buffer, sizeof(buffer), pipe)) {
        result += buffer;
    }
    int ret = pclose(pipe);
    
    return {ret == 0, result, ret == 0 ? "" : "Execution failed", ret};
}

inline ScriptResult run_c_script(const std::string& path) {
    // For .c files: quick compile with matlabcpp headers, then run
    std::filesystem::path p(path);
    std::string base = p.stem().string();
    std::string tmp_exe = "/tmp/" + base + "_exec";
    
    // Compile
    std::string compile_cmd = "gcc -std=c99 -O2 -lm -I./include " + path + " -o " + tmp_exe + " 2>&1";
    FILE* compile_pipe = popen(compile_cmd.c_str(), "r");
    if (!compile_pipe) {
        return {false, "", "Failed to start compiler", 1};
    }
    
    std::string compile_out;
    char buffer[256];
    while (fgets(buffer, sizeof(buffer), compile_pipe)) {
        compile_out += buffer;
    }
    int compile_ret = pclose(compile_pipe);
    
    if (compile_ret != 0) {
        return {false, "", "Compilation failed:\n" + compile_out, compile_ret};
    }
    
    // Run
    FILE* run_pipe = popen((tmp_exe + " 2>&1").c_str(), "r");
    if (!run_pipe) {
        return {false, "", "Failed to run compiled script", 1};
    }
    
    std::string output;
    while (fgets(buffer, sizeof(buffer), run_pipe)) {
        output += buffer;
    }
    int run_ret = pclose(run_pipe);
    
    // Cleanup
    std::remove(tmp_exe.c_str());
    
    return {run_ret == 0, output, run_ret == 0 ? "" : "Execution error", run_ret};
}

inline ScriptResult run_script(const std::string& path) {
    auto type = detect_type(path);
    
    switch(type) {
        case ScriptType::MATLAB:
            return run_matlab_script(path);
        case ScriptType::C_SOURCE:
            return run_c_script(path);
        default:
            return {false, "", "Unknown script type: " + path, 1};
    }
}

inline std::string get_type_description(ScriptType type) {
    switch(type) {
        case ScriptType::MATLAB: return "MATLAB/Octave (.m)";
        case ScriptType::C_SOURCE: return "C source (.c)";
        default: return "Unknown";
    }
}

} // namespace matlabcpp::script
