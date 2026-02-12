// MatLabC++ Publication-Quality Plotting System
// include/matlabcpp/plotting.hpp
//
// Full MATLAB-compatible plotting API with Cairo backend for
// publication-quality graphics (300 DPI PNG/PDF export).

#pragma once

#include <string>
#include <vector>
#include <memory>
#include <map>
#include <cstdint>

namespace matlabcpp {
namespace plotting {

// ========== COLOR ==========

struct Color {
    double r, g, b, a = 1.0;  // [0, 1]
    
    Color() : r(0), g(0), b(0), a(1) {}
    Color(double r_, double g_, double b_, double a_ = 1.0) 
        : r(r_), g(g_), b(b_), a(a_) {}
    
    static Color from_name(const std::string& name);
    static Color from_char(char c);  // MATLAB color codes: 'r', 'g', 'b', etc.
};

// Standard MATLAB colors
namespace colors {
    const Color blue   {0.0000, 0.4470, 0.7410};
    const Color red    {0.8500, 0.3250, 0.0980};
    const Color yellow {0.9290, 0.6940, 0.1250};
    const Color purple {0.4940, 0.1840, 0.5560};
    const Color green  {0.4660, 0.6740, 0.1880};
    const Color cyan   {0.3010, 0.7450, 0.9330};
    const Color maroon {0.6350, 0.0780, 0.1840};
    const Color black  {0.0, 0.0, 0.0};
    const Color white  {1.0, 1.0, 1.0};
}

// ========== LINE STYLE ==========

enum class LineStyle {
    Solid,      // '-'
    Dashed,     // '--'
    Dotted,     // ':'
    DashDot,    // '-.'
    None        // 'none'
};

enum class Marker {
    None,
    Circle,     // 'o'
    Plus,       // '+'
    Star,       // '*'
    Point,      // '.'
    Cross,      // 'x'
    Square,     // 's'
    Diamond,    // 'd'
    Triangle    // '^'
};

// ========== DATA SERIES ==========

struct DataSeries {
    std::vector<double> x;
    std::vector<double> y;
    std::string label;
    Color color = colors::blue;
    LineStyle line_style = LineStyle::Solid;
    double line_width = 1.5;
    Marker marker = Marker::None;
    double marker_size = 6.0;
};

// ========== AXIS PROPERTIES ==========

struct AxisLimits {
    bool auto_x = true;
    bool auto_y = true;
    double xmin = 0.0, xmax = 1.0;
    double ymin = 0.0, ymax = 1.0;
};

struct AxisLabels {
    std::string xlabel;
    std::string ylabel;
    std::string title;
};

struct AxisProperties {
    bool grid = false;
    bool box = true;
    Color grid_color = Color(0.15, 0.15, 0.15, 0.3);
    Color axis_color = colors::black;
    std::string font_name = "Times New Roman";
    int font_size = 12;
    int title_font_size = 14;
};

// ========== LEGEND ==========

struct Legend {
    bool visible = false;
    std::string location = "northeast";  // northeast, northwest, southeast, southwest, best
    std::vector<std::string> labels;
    std::string font_name = "Times New Roman";
    int font_size = 11;
};

// ========== AXES (SUBPLOT) ==========

class Axes {
    std::vector<DataSeries> series_;
    AxisLimits limits_;
    AxisLabels labels_;
    AxisProperties properties_;
    Legend legend_;
    bool hold_state_ = false;
    
public:
    Axes();
    
    // Add data
    void plot(const std::vector<double>& x, const std::vector<double>& y,
              const std::string& fmt = "");
    void plot_series(const DataSeries& series);
    
    // Labels
    void set_xlabel(const std::string& label);
    void set_ylabel(const std::string& label);
    void set_title(const std::string& title);
    
    // Axis limits
    void set_xlim(double xmin, double xmax);
    void set_ylim(double ymin, double ymax);
    void auto_xlim();
    void auto_ylim();
    
    // Properties
    void set_grid(bool on);
    void set_hold(bool on);
    void set_font(const std::string& name, int size);
    
    // Legend
    void add_legend_entry(const std::string& label);
    void set_legend_location(const std::string& loc);
    void show_legend(bool visible);
    
    // Getters
    const std::vector<DataSeries>& get_series() const { return series_; }
    const AxisLimits& get_limits() const { return limits_; }
    const AxisLabels& get_labels() const { return labels_; }
    const AxisProperties& get_properties() const { return properties_; }
    const Legend& get_legend() const { return legend_; }
    bool is_hold() const { return hold_state_; }
    
    // Clear
    void clear();
    
private:
    void compute_auto_limits();
    DataSeries parse_format_string(const std::string& fmt);
};

// ========== FIGURE ==========

class Figure {
    int width_;
    int height_;
    Color background_;
    std::string title_;
    std::vector<std::vector<std::shared_ptr<Axes>>> subplot_grid_;
    int current_row_ = 0;
    int current_col_ = 0;
    int subplot_rows_ = 1;
    int subplot_cols_ = 1;
    
public:
    explicit Figure(int width = 800, int height = 600);
    
    // Subplot management
    void subplot(int rows, int cols, int index);
    Axes& get_current_axes();
    Axes& get_axes(int row, int col);
    
    // Figure properties
    void set_size(int width, int height);
    void set_background(const Color& color);
    void set_title(const std::string& title);
    
    // Export
    bool save_png(const std::string& filename, int dpi = 300);
    bool save_pdf(const std::string& filename);
    bool save_svg(const std::string& filename);
    
    // Getters
    int get_width() const { return width_; }
    int get_height() const { return height_; }
    const std::string& get_title() const { return title_; }
    int get_subplot_rows() const { return subplot_rows_; }
    int get_subplot_cols() const { return subplot_cols_; }
    
private:
    void ensure_subplot_grid();
};

// ========== FIGURE MANAGER ==========

class FigureManager {
    std::map<int, std::shared_ptr<Figure>> figures_;
    int current_figure_id_ = 1;
    int next_figure_id_ = 1;
    
public:
    static FigureManager& instance();
    
    // Figure creation
    Figure& figure(int id = 0);  // 0 = create new
    void close(int id);
    void close_all();
    
    // Current figure
    Figure& gcf();  // Get current figure
    Axes& gca();    // Get current axes
    
    bool has_figure(int id) const;
    
private:
    FigureManager() = default;
};

// ========== MATLAB-COMPATIBLE API ==========

// Figure management
Figure& figure(int id = 0);
void close(int id);
void close_all();
void subplot(int rows, int cols, int index);

// Plotting
void plot(const std::vector<double>& x, const std::vector<double>& y, 
          const std::string& fmt = "");
void plot(const std::vector<double>& y, const std::string& fmt = "");

// Labels and titles
void xlabel(const std::string& label);
void ylabel(const std::string& label);
void title(const std::string& title);
void sgtitle(const std::string& title);  // Super-title for whole figure

// Axis properties
void xlim(double xmin, double xmax);
void ylim(double ymin, double ymax);
void grid_on();
void grid_off();
void hold_on();
void hold_off();

// Legend
void legend(const std::vector<std::string>& labels, 
            const std::string& location = "best");

// Figure properties
void set_gcf_size(int width, int height);
void set_gcf_color(const Color& color);

// Export
void print_png(const std::string& filename, int dpi = 300);
void print_pdf(const std::string& filename);
void savefig(const std::string& filename);

// ========== RENDERER INTERFACE ==========

class Renderer {
public:
    virtual ~Renderer() = default;
    
    virtual bool render_figure(const Figure& fig, const std::string& filename, int dpi = 300) = 0;
    virtual bool supports_format(const std::string& format) const = 0;
};

// Factory
std::unique_ptr<Renderer> create_renderer(const std::string& backend = "auto");

} // namespace plotting
} // namespace matlabcpp
