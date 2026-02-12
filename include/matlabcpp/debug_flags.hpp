#pragma once
#include "matlabcpp/value.hpp"
#include <string>
#include <fstream>

namespace matlabcpp {

// Visual debugging system
class DebugFlags {
public:
    // Load from debug.cfg (2-line CSV)
    static bool load();
    static void save(bool enabled);
    
    // Check if debugging enabled
    static bool is_enabled() { return enabled_; }
    
    // Visual markers (printed after operations)
    static std::string vector_marker()  { return enabled_ ? " |" : ""; }
    static std::string matrix_marker()  { return enabled_ ? " --" : ""; }
    static std::string var_created()    { return enabled_ ? " #" : ""; }
    
    // Color codes (ANSI escape sequences)
    static std::string red()     { return enabled_ ? "\033[31m" : ""; }
    static std::string yellow()  { return enabled_ ? "\033[33m" : ""; }
    static std::string green()   { return enabled_ ? "\033[32m" : ""; }
    static std::string reset()   { return enabled_ ? "\033[0m" : ""; }
    
    // Check for problems
    static bool has_nan(const Value& v);
    static bool has_inf(const Value& v);
    static bool is_corrupt(const Value& v);  // e^405, huge values
    
    // Colorize output based on state
    static std::string colorize_result(const Value& v, const std::string& text);
    static std::string colorize_error(const std::string& msg);
    
private:
    static bool enabled_;
    static const char* config_file_;
};

// Helper: Print with debug markers
inline std::string debug_print(const Value& v, const std::string& var_name = "") {
    std::string result = v.to_string();
    
    if (DebugFlags::is_enabled()) {
        // Add type marker
        if (v.is_vector()) {
            result += DebugFlags::vector_marker();
        } else if (v.is_matrix() && (v.rows() > 1 || v.cols() > 1)) {
            result += DebugFlags::matrix_marker();
        }
        
        // Add creation marker if named
        if (!var_name.empty()) {
            result += DebugFlags::var_created();
        }
        
        // Colorize if problems detected
        result = DebugFlags::colorize_result(v, result);
    }
    
    return result;
}

} // namespace matlabcpp
