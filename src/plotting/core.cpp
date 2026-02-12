// MatLabC++ Plotting Core Implementation
// src/plotting/core.cpp

#include "matlabcpp/plotting.hpp"
#include <algorithm>
#include <cmath>
#include <limits>
#include <sstream>
#include <stdexcept>

namespace matlabcpp {
namespace plotting {

// ========== COLOR ==========

Color Color::from_name(const std::string& name) {
    static const std::map<std::string, Color> color_map = {
        {"red", colors::red}, {"r", colors::red},
        {"green", colors::green}, {"g", colors::green},
        {"blue", colors::blue}, {"b", colors::blue},
        {"cyan", colors::cyan}, {"c", colors::cyan},
        {"magenta", Color(1, 0, 1)}, {"m", Color(1, 0, 1)},
        {"yellow", colors::yellow}, {"y", colors::yellow},
        {"black", colors::black}, {"k", colors::black},
        {"white", colors::white}, {"w", colors::white}
    };
    
    auto it = color_map.find(name);
    return (it != color_map.end()) ? it->second : colors::blue;
}

Color Color::from_char(char c) {
    switch (c) {
        case 'r': return colors::red;
        case 'g': return colors::green;
        case 'b': return colors::blue;
        case 'c': return colors::cyan;
        case 'm': return Color(1, 0, 1);
        case 'y': return colors::yellow;
        case 'k': return colors::black;
        case 'w': return colors::white;
        default:  return colors::blue;
    }
}

// ========== AXES ==========

Axes::Axes() {
    properties_.font_name = "Times New Roman";
    properties_.font_size = 12;
    properties_.title_font_size = 16;
}

void Axes::plot(const std::vector<double>& x, const std::vector<double>& y,
                const std::string& fmt) {
    if (x.size() != y.size()) {
        throw std::invalid_argument("plot(): x and y must have same length");
    }
    
    DataSeries series;
    series.x = x;
    series.y = y;
    
    // Parse format string
    if (!fmt.empty()) {
        DataSeries fmt_parsed = parse_format_string(fmt);
        series.color = fmt_parsed.color;
        series.line_style = fmt_parsed.line_style;
        series.marker = fmt_parsed.marker;
        series.line_width = fmt_parsed.line_width;
    }
    
    // Use default color cycle if not specified
    if (fmt.empty() || (fmt.find_first_of("rgbcmykw") == std::string::npos)) {
        static const std::vector<Color> default_colors = {
            colors::blue, colors::red, colors::yellow, colors::purple,
            colors::green, colors::cyan, colors::maroon
        };
        series.color = default_colors[series_.size() % default_colors.size()];
    }
    
    if (!hold_state_) {
        series_.clear();
        legend_.labels.clear();
    }
    
    series_.push_back(series);
    compute_auto_limits();
}

void Axes::plot_series(const DataSeries& series) {
    if (!hold_state_) {
        series_.clear();
        legend_.labels.clear();
    }
    series_.push_back(series);
    compute_auto_limits();
}

void Axes::set_xlabel(const std::string& label) {
    labels_.xlabel = label;
}

void Axes::set_ylabel(const std::string& label) {
    labels_.ylabel = label;
}

void Axes::set_title(const std::string& title) {
    labels_.title = title;
}

void Axes::set_xlim(double xmin, double xmax) {
    limits_.auto_x = false;
    limits_.xmin = xmin;
    limits_.xmax = xmax;
}

void Axes::set_ylim(double ymin, double ymax) {
    limits_.auto_y = false;
    limits_.ymin = ymin;
    limits_.ymax = ymax;
}

void Axes::auto_xlim() {
    limits_.auto_x = true;
    compute_auto_limits();
}

void Axes::auto_ylim() {
    limits_.auto_y = true;
    compute_auto_limits();
}

void Axes::set_grid(bool on) {
    properties_.grid = on;
}

void Axes::set_hold(bool on) {
    hold_state_ = on;
}

void Axes::set_font(const std::string& name, int size) {
    properties_.font_name = name;
    properties_.font_size = size;
}

void Axes::add_legend_entry(const std::string& label) {
    legend_.labels.push_back(label);
    legend_.visible = true;
}

void Axes::set_legend_location(const std::string& loc) {
    legend_.location = loc;
}

void Axes::show_legend(bool visible) {
    legend_.visible = visible;
}

void Axes::clear() {
    series_.clear();
    legend_.labels.clear();
    labels_ = AxisLabels();
    limits_ = AxisLimits();
}

void Axes::compute_auto_limits() {
    if (series_.empty()) return;
    
    double xmin = std::numeric_limits<double>::max();
    double xmax = std::numeric_limits<double>::lowest();
    double ymin = std::numeric_limits<double>::max();
    double ymax = std::numeric_limits<double>::lowest();
    
    for (const auto& s : series_) {
        for (double val : s.x) {
            xmin = std::min(xmin, val);
            xmax = std::max(xmax, val);
        }
        for (double val : s.y) {
            ymin = std::min(ymin, val);
            ymax = std::max(ymax, val);
        }
    }
    
    // Add 5% margin
    double xmargin = (xmax - xmin) * 0.05;
    double ymargin = (ymax - ymin) * 0.05;
    
    if (limits_.auto_x) {
        limits_.xmin = xmin - xmargin;
        limits_.xmax = xmax + xmargin;
    }
    
    if (limits_.auto_y) {
        limits_.ymin = ymin - ymargin;
        limits_.ymax = ymax + ymargin;
    }
}

DataSeries Axes::parse_format_string(const std::string& fmt) {
    DataSeries result;
    result.line_style = LineStyle::Solid;
    result.marker = Marker::None;
    result.color = colors::blue;
    result.line_width = 1.5;
    
    // Parse color
    if (fmt.find('r') != std::string::npos) result.color = colors::red;
    else if (fmt.find('g') != std::string::npos) result.color = colors::green;
    else if (fmt.find('b') != std::string::npos) result.color = colors::blue;
    else if (fmt.find('c') != std::string::npos) result.color = colors::cyan;
    else if (fmt.find('m') != std::string::npos) result.color = Color(1, 0, 1);
    else if (fmt.find('y') != std::string::npos) result.color = colors::yellow;
    else if (fmt.find('k') != std::string::npos) result.color = colors::black;
    else if (fmt.find('w') != std::string::npos) result.color = colors::white;
    
    // Parse line style
    if (fmt.find("--") != std::string::npos) result.line_style = LineStyle::Dashed;
    else if (fmt.find("-.") != std::string::npos) result.line_style = LineStyle::DashDot;
    else if (fmt.find(':') != std::string::npos) result.line_style = LineStyle::Dotted;
    else if (fmt.find('-') != std::string::npos) result.line_style = LineStyle::Solid;
    
    // Parse marker
    if (fmt.find('o') != std::string::npos) result.marker = Marker::Circle;
    else if (fmt.find('+') != std::string::npos) result.marker = Marker::Plus;
    else if (fmt.find('*') != std::string::npos) result.marker = Marker::Star;
    else if (fmt.find('.') != std::string::npos && fmt.find("-.") == std::string::npos) 
        result.marker = Marker::Point;
    else if (fmt.find('x') != std::string::npos) result.marker = Marker::Cross;
    else if (fmt.find('s') != std::string::npos) result.marker = Marker::Square;
    else if (fmt.find('d') != std::string::npos) result.marker = Marker::Diamond;
    else if (fmt.find('^') != std::string::npos) result.marker = Marker::Triangle;
    
    return result;
}

// ========== FIGURE ==========

Figure::Figure(int width, int height) 
    : width_(width), height_(height), background_(colors::white) {
    subplot_grid_.resize(1, std::vector<std::shared_ptr<Axes>>(1, std::make_shared<Axes>()));
}

void Figure::subplot(int rows, int cols, int index) {
    subplot_rows_ = rows;
    subplot_cols_ = cols;
    
    // Ensure grid is large enough
    if (subplot_grid_.size() < rows) {
        subplot_grid_.resize(rows);
    }
    for (auto& row : subplot_grid_) {
        if (row.size() < cols) {
            row.resize(cols);
        }
    }
    
    // Convert 1-indexed to 0-indexed
    index--;
    current_row_ = index / cols;
    current_col_ = index % cols;
    
    // Create axes if not exists
    if (!subplot_grid_[current_row_][current_col_]) {
        subplot_grid_[current_row_][current_col_] = std::make_shared<Axes>();
    }
}

Axes& Figure::get_current_axes() {
    ensure_subplot_grid();
    return *subplot_grid_[current_row_][current_col_];
}

Axes& Figure::get_axes(int row, int col) {
    if (row >= subplot_grid_.size() || col >= subplot_grid_[row].size()) {
        throw std::out_of_range("Axes index out of range");
    }
    if (!subplot_grid_[row][col]) {
        subplot_grid_[row][col] = std::make_shared<Axes>();
    }
    return *subplot_grid_[row][col];
}

void Figure::set_size(int width, int height) {
    width_ = width;
    height_ = height;
}

void Figure::set_background(const Color& color) {
    background_ = color;
}

void Figure::set_title(const std::string& title) {
    title_ = title;
}

void Figure::ensure_subplot_grid() {
    if (subplot_grid_.empty() || subplot_grid_[0].empty() || !subplot_grid_[0][0]) {
        subplot_grid_.resize(1, std::vector<std::shared_ptr<Axes>>(1, std::make_shared<Axes>()));
        current_row_ = 0;
        current_col_ = 0;
    }
}

// ========== FIGURE MANAGER ==========

FigureManager& FigureManager::instance() {
    static FigureManager mgr;
    return mgr;
}

Figure& FigureManager::figure(int id) {
    if (id == 0) {
        id = next_figure_id_++;
    }
    
    if (figures_.find(id) == figures_.end()) {
        figures_[id] = std::make_shared<Figure>();
    }
    
    current_figure_id_ = id;
    return *figures_[id];
}

void FigureManager::close(int id) {
    figures_.erase(id);
    if (current_figure_id_ == id && !figures_.empty()) {
        current_figure_id_ = figures_.begin()->first;
    }
}

void FigureManager::close_all() {
    figures_.clear();
    current_figure_id_ = 0;
}

Figure& FigureManager::gcf() {
    if (figures_.empty() || figures_.find(current_figure_id_) == figures_.end()) {
        return figure();
    }
    return *figures_[current_figure_id_];
}

Axes& FigureManager::gca() {
    return gcf().get_current_axes();
}

bool FigureManager::has_figure(int id) const {
    return figures_.find(id) != figures_.end();
}

// ========== MATLAB API ==========

Figure& figure(int id) {
    return FigureManager::instance().figure(id);
}

void close(int id) {
    FigureManager::instance().close(id);
}

void close_all() {
    FigureManager::instance().close_all();
}

void subplot(int rows, int cols, int index) {
    FigureManager::instance().gcf().subplot(rows, cols, index);
}

void plot(const std::vector<double>& x, const std::vector<double>& y, const std::string& fmt) {
    FigureManager::instance().gca().plot(x, y, fmt);
}

void plot(const std::vector<double>& y, const std::string& fmt) {
    std::vector<double> x(y.size());
    for (size_t i = 0; i < y.size(); i++) x[i] = static_cast<double>(i);
    plot(x, y, fmt);
}

void xlabel(const std::string& label) {
    FigureManager::instance().gca().set_xlabel(label);
}

void ylabel(const std::string& label) {
    FigureManager::instance().gca().set_ylabel(label);
}

void title(const std::string& title) {
    FigureManager::instance().gca().set_title(title);
}

void sgtitle(const std::string& title) {
    FigureManager::instance().gcf().set_title(title);
}

void xlim(double xmin, double xmax) {
    FigureManager::instance().gca().set_xlim(xmin, xmax);
}

void ylim(double ymin, double ymax) {
    FigureManager::instance().gca().set_ylim(ymin, ymax);
}

void grid_on() {
    FigureManager::instance().gca().set_grid(true);
}

void grid_off() {
    FigureManager::instance().gca().set_grid(false);
}

void hold_on() {
    FigureManager::instance().gca().set_hold(true);
}

void hold_off() {
    FigureManager::instance().gca().set_hold(false);
}

void legend(const std::vector<std::string>& labels, const std::string& location) {
    auto& axes = FigureManager::instance().gca();
    for (const auto& label : labels) {
        axes.add_legend_entry(label);
    }
    axes.set_legend_location(location);
}

void set_gcf_size(int width, int height) {
    FigureManager::instance().gcf().set_size(width, height);
}

void set_gcf_color(const Color& color) {
    FigureManager::instance().gcf().set_background(color);
}

} // namespace plotting
} // namespace matlabcpp
