// Style Presets - Publication-quality plot styles
// src/plotting/style_presets.cpp

#include <map>
#include <string>
#include <vector>

namespace matlabcpp {
namespace plotting {

// Forward declarations from plot_spec.cpp
struct Color;
struct PlotSpec;
struct FigureSpec;

// Style preset definitions
struct StylePreset {
    std::string name;
    std::vector<Color> color_cycle;
    std::string font_family;
    int font_size;
    bool grid_default;
    double line_width;
};

class StylePresets {
public:
    static StylePreset get_preset(const std::string& name) {
        static std::map<std::string, StylePreset> presets = {
            {"default", {
                "default",
                {{0, 0, 1}, {1, 0, 0}, {0, 1, 0}, {1, 0.5, 0}},
                "sans-serif",
                10,
                false,
                1.0
            }},
            {"publication", {
                "publication",
                {{0, 0.4470, 0.7410}, {0.8500, 0.3250, 0.0980}, 
                 {0.9290, 0.6940, 0.1250}, {0.4940, 0.1840, 0.5560}},
                "Times New Roman",
                14,
                true,
                2.0
            }},
            {"matlab", {
                "matlab",
                {{0, 0.4470, 0.7410}, {0.8500, 0.3250, 0.0980}, 
                 {0.9290, 0.6940, 0.1250}, {0.4940, 0.1840, 0.5560},
                 {0.4660, 0.6740, 0.1880}, {0.3010, 0.7450, 0.9330}, 
                 {0.6350, 0.0780, 0.1840}},
                "Helvetica",
                11,
                false,
                1.5
            }},
            {"dark", {
                "dark",
                {{0.2, 0.6, 1.0}, {1.0, 0.4, 0.4}, {0.4, 1.0, 0.4}, {1.0, 1.0, 0.4}},
                "sans-serif",
                10,
                true,
                1.5
            }},
            {"minimal", {
                "minimal",
                {{0.2, 0.2, 0.2}, {0.5, 0.5, 0.5}, {0.7, 0.7, 0.7}},
                "Arial",
                9,
                false,
                1.0
            }}
        };

        auto it = presets.find(name);
        return it != presets.end() ? it->second : presets["default"];
    }

    static std::vector<std::string> list_presets() {
        return {"default", "publication", "matlab", "dark", "minimal"};
    }
};

// Global style state
static StylePreset g_current_style = StylePresets::get_preset("default");

// Public API
void set_style(const std::string& name) {
    g_current_style = StylePresets::get_preset(name);
}

std::string get_current_style() {
    return g_current_style.name;
}

std::vector<std::string> list_styles() {
    return StylePresets::list_presets();
}

} // namespace plotting
} // namespace matlabcpp

