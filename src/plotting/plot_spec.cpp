// Plot Specification - Data structure for plot configuration
// src/plotting/plot_spec.cpp

#include <string>
#include <vector>
#include <map>

namespace matlabcpp {
namespace plotting {

// Line styles
enum class LineStyle {
    Solid,      // '-'
    Dashed,     // '--'
    Dotted,     // ':'
    DashDot,    // '-.'
    None
};

// Marker styles
enum class MarkerStyle {
    None,
    Circle,     // 'o'
    Cross,      // 'x'
    Plus,       // '+'
    Star,       // '*'
    Square,     // 's'
    Diamond,    // 'd'
    Triangle    // '^'
};

// Color specification
struct Color {
    double r, g, b;  // [0, 1]

    static Color from_name(const std::string& name) {
        static std::map<std::string, Color> colors = {
            {"red",     {1.0, 0.0, 0.0}},
            {"green",   {0.0, 1.0, 0.0}},
            {"blue",    {0.0, 0.0, 1.0}},
            {"yellow",  {1.0, 1.0, 0.0}},
            {"cyan",    {0.0, 1.0, 1.0}},
            {"magenta", {1.0, 0.0, 1.0}},
            {"black",   {0.0, 0.0, 0.0}},
            {"white",   {1.0, 1.0, 1.0}}
        };
        auto it = colors.find(name);
        return it != colors.end() ? it->second : Color{0, 0, 0};
    }
};

// Plot specification
struct PlotSpec {
    std::vector<double> x_data;
    std::vector<double> y_data;
    std::vector<double> z_data;  // For 3D

    std::string label;
    Color color = {0, 0, 1};  // Default blue
    LineStyle line_style = LineStyle::Solid;
    MarkerStyle marker_style = MarkerStyle::None;
    double line_width = 1.0;
    double marker_size = 6.0;

    // Axes labels
    std::string xlabel;
    std::string ylabel;
    std::string zlabel;

    // Title
    std::string title;

    // Grid
    bool grid = false;

    // Legend
    std::string legend_location = "best";  // "northeast", "northwest", etc.

    // Axis limits (auto if not set)
    bool auto_xlim = true;
    bool auto_ylim = true;
    double xlim_min = 0.0, xlim_max = 1.0;
    double ylim_min = 0.0, ylim_max = 1.0;
};

// Figure configuration
struct FigureSpec {
    int width = 800;
    int height = 600;
    Color background = {1.0, 1.0, 1.0};
    std::string title;

    std::vector<PlotSpec> plots;
};

} // namespace plotting
} // namespace matlabcpp

