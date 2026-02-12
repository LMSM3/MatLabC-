#include "matlabcpp/debug_flags.hpp"
#include <cmath>
#include <limits>
#include <sstream>
#include <iostream>

namespace matlabcpp {

// Static members
bool DebugFlags::enabled_ = false;
const char* DebugFlags::config_file_ = "debug.cfg";

bool DebugFlags::load() {
    std::ifstream file(config_file_);
    if (!file.is_open()) {
        // Create default config (disabled)
        save(false);
        return false;
    }
    
    // Read 2 lines:
    // Line 1: "enabled" or "disabled"
    // Line 2: ignored (for future use)
    std::string line;
    if (std::getline(file, line)) {
        enabled_ = (line == "enabled" || line == "1" || line == "true");
    }
    
    file.close();
    return enabled_;
}

void DebugFlags::save(bool enabled) {
    std::ofstream file(config_file_);
    if (!file.is_open()) {
        std::cerr << "Warning: Could not write debug.cfg\n";
        return;
    }
    
    file << (enabled ? "enabled" : "disabled") << "\n";
    file << "# Debug flags: visual markers and error highlighting\n";
    file.close();
    
    enabled_ = enabled;
}

bool DebugFlags::has_nan(const Value& v) {
    for (size_t i = 0; i < v.size(); ++i) {
        if (std::isnan(v.data()[i])) {
            return true;
        }
    }
    return false;
}

bool DebugFlags::has_inf(const Value& v) {
    for (size_t i = 0; i < v.size(); ++i) {
        if (std::isinf(v.data()[i])) {
            return true;
        }
    }
    return false;
}

bool DebugFlags::is_corrupt(const Value& v) {
    // Check for suspiciously large values (> 1e100)
    // or other signs of corruption
    const double max_reasonable = 1e100;
    
    for (size_t i = 0; i < v.size(); ++i) {
        double val = std::abs(v.data()[i]);
        
        // Skip inf/nan (handled separately)
        if (std::isnan(val) || std::isinf(val)) {
            continue;
        }
        
        // Check if value is unreasonably large
        if (val > max_reasonable) {
            return true;
        }
    }
    return false;
}

std::string DebugFlags::colorize_result(const Value& v, const std::string& text) {
    if (!enabled_) {
        return text;
    }
    
    // Priority: corruption > NaN > Inf > normal
    if (is_corrupt(v)) {
        return red() + text + " [CORRUPT]" + reset();
    }
    
    if (has_nan(v)) {
        return red() + text + " [NaN detected]" + reset();
    }
    
    if (has_inf(v)) {
        return yellow() + text + " [Inf detected]" + reset();
    }
    
    // Normal - use green for success
    return green() + text + reset();
}

std::string DebugFlags::colorize_error(const std::string& msg) {
    if (!enabled_) {
        return msg;
    }
    
    return red() + "ERROR: " + msg + reset();
}

} // namespace matlabcpp
