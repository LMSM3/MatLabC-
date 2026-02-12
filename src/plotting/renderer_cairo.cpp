// Cairo Renderer - Publication-quality PNG/PDF export
// src/plotting/renderer_cairo.cpp
//
// Requires: libcairo2-dev, libfreetype6-dev
// Compile with: -DHAVE_CAIRO -lcairo -lfreetype

#include "matlabcpp/plotting.hpp"
#include <cmath>
#include <algorithm>
#include <memory>
#include <sstream>
#include <iomanip>

#ifdef HAVE_CAIRO
#include <cairo/cairo.h>
#include <cairo/cairo-pdf.h>
#include <cairo/cairo-svg.h>
#endif

namespace matlabcpp {
namespace plotting {

#ifdef HAVE_CAIRO

class CairoRenderer : public Renderer {
public:
    bool render_figure(const Figure& fig, const std::string& filename, int dpi = 300) override {
        std::string ext = get_extension(filename);
        
        if (ext == "png") {
            return render_png(fig, filename, dpi);
        } else if (ext == "pdf") {
            return render_pdf(fig, filename);
        } else if (ext == "svg") {
            return render_svg(fig, filename);
        }
        
        return false;
    }
    
    bool supports_format(const std::string& format) const override {
        return (format == "png" || format == "pdf" || format == "svg");
    }
    
private:
    bool render_png(const Figure& fig, const std::string& filename, int dpi) {
        // Calculate pixel dimensions from DPI
        double scale = dpi / 72.0;  // Cairo uses 72 DPI as base
        int width_px = fig.get_width() * scale;
        int height_px = fig.get_height() * scale;
        
        cairo_surface_t* surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width_px, height_px);
        cairo_t* cr = cairo_create(surface);
        
        // Scale to maintain logical size
        cairo_scale(cr, scale, scale);
        
        render_to_context(cr, fig);
        
        cairo_surface_write_to_png(surface, filename.c_str());
        
        cairo_destroy(cr);
        cairo_surface_destroy(surface);
        
        return true;
    }
    
    bool render_pdf(const Figure& fig, const std::string& filename) {
        cairo_surface_t* surface = cairo_pdf_surface_create(filename.c_str(), 
                                                             fig.get_width(), 
                                                             fig.get_height());
        cairo_t* cr = cairo_create(surface);
        
        render_to_context(cr, fig);
        
        cairo_surface_show_page(surface);
        cairo_destroy(cr);
        cairo_surface_destroy(surface);
        
        return true;
    }
    
    bool render_svg(const Figure& fig, const std::string& filename) {
        cairo_surface_t* surface = cairo_svg_surface_create(filename.c_str(),
                                                             fig.get_width(),
                                                             fig.get_height());
        cairo_t* cr = cairo_create(surface);
        
        render_to_context(cr, fig);
        
        cairo_destroy(cr);
        cairo_surface_destroy(surface);
        
        return true;
    }
    
    void render_to_context(cairo_t* cr, const Figure& fig) {
        // Fill background
        set_cairo_color(cr, Color(1, 1, 1));  // White background
        cairo_paint(cr);
        
        int rows = fig.get_subplot_rows();
        int cols = fig.get_subplot_cols();
        
        // Calculate subplot dimensions
        double subplot_width = fig.get_width() / cols;
        double subplot_height = fig.get_height() / rows;
        
        // Leave margins
        double margin_left = 80;
        double margin_right = 20;
        double margin_top = 60;
        double margin_bottom = 60;
        
        double plot_width = subplot_width - margin_left - margin_right;
        double plot_height = subplot_height - margin_top - margin_bottom;
        
        // Render super-title
        if (!fig.get_title().empty()) {
            render_sgtitle(cr, fig, subplot_width * cols / 2, 30);
        }
        
        // Render each subplot
        for (int row = 0; row < rows; row++) {
            for (int col = 0; col < cols; col++) {
                double x = col * subplot_width + margin_left;
                double y = row * subplot_height + margin_top;
                
                cairo_save(cr);
                cairo_translate(cr, x, y);
                
                // Get axes (this will create if not exists)
                try {
                    const Axes& axes = const_cast<Figure&>(fig).get_axes(row, col);
                    render_axes(cr, axes, plot_width, plot_height);
                } catch (...) {
                    // Subplot doesn't exist
                }
                
                cairo_restore(cr);
            }
        }
    }
    
    void render_axes(cairo_t* cr, const Axes& axes, double width, double height) {
        const auto& series = axes.get_series();
        if (series.empty()) return;
        
        const auto& limits = axes.get_limits();
        const auto& labels = axes.get_labels();
        const auto& props = axes.get_properties();
        const auto& legend = axes.get_legend();
        
        // Draw box
        if (props.box) {
            cairo_set_line_width(cr, 1.0);
            set_cairo_color(cr, props.axis_color);
            cairo_rectangle(cr, 0, 0, width, height);
            cairo_stroke(cr);
        }
        
        // Draw grid
        if (props.grid) {
            render_grid(cr, axes, width, height);
        }
        
        // Set clipping region
        cairo_rectangle(cr, 0, 0, width, height);
        cairo_clip(cr);
        
        // Render data series
        for (const auto& s : series) {
            render_series(cr, s, limits, width, height);
        }
        
        cairo_reset_clip(cr);
        
        // Render axes (ticks, labels)
        render_axes_decoration(cr, axes, width, height);
        
        // Render legend
        if (legend.visible && !legend.labels.empty()) {
            render_legend(cr, axes, width, height);
        }
    }
    
    void render_series(cairo_t* cr, const DataSeries& series, 
                      const AxisLimits& limits, double width, double height) {
        if (series.x.empty()) return;
        
        // Transform data to pixel coordinates
        auto to_pixel_x = [&](double x) {
            return (x - limits.xmin) / (limits.xmax - limits.xmin) * width;
        };
        auto to_pixel_y = [&](double y) {
            return height - (y - limits.ymin) / (limits.ymax - limits.ymin) * height;
        };
        
        // Set line properties
        cairo_set_line_width(cr, series.line_width);
        set_cairo_color(cr, series.color);
        
        // Set line style
        switch (series.line_style) {
            case LineStyle::Dashed:
                cairo_set_dash(cr, (double[]){10.0, 5.0}, 2, 0);
                break;
            case LineStyle::Dotted:
                cairo_set_dash(cr, (double[]){2.0, 3.0}, 2, 0);
                break;
            case LineStyle::DashDot:
                cairo_set_dash(cr, (double[]){10.0, 3.0, 2.0, 3.0}, 4, 0);
                break;
            default:
                cairo_set_dash(cr, nullptr, 0, 0);
        }
        
        // Draw line
        if (series.line_style != LineStyle::None) {
            cairo_move_to(cr, to_pixel_x(series.x[0]), to_pixel_y(series.y[0]));
            for (size_t i = 1; i < series.x.size(); i++) {
                cairo_line_to(cr, to_pixel_x(series.x[i]), to_pixel_y(series.y[i]));
            }
            cairo_stroke(cr);
        }
        
        // Draw markers
        if (series.marker != Marker::None) {
            cairo_set_dash(cr, nullptr, 0, 0);  // No dash for markers
            for (size_t i = 0; i < series.x.size(); i++) {
                double px = to_pixel_x(series.x[i]);
                double py = to_pixel_y(series.y[i]);
                render_marker(cr, series.marker, px, py, series.marker_size);
            }
        }
    }
    
    void render_marker(cairo_t* cr, Marker marker, double x, double y, double size) {
        switch (marker) {
            case Marker::Circle:
                cairo_arc(cr, x, y, size/2, 0, 2*M_PI);
                cairo_fill(cr);
                break;
            case Marker::Plus:
                cairo_move_to(cr, x - size/2, y);
                cairo_line_to(cr, x + size/2, y);
                cairo_move_to(cr, x, y - size/2);
                cairo_line_to(cr, x, y + size/2);
                cairo_stroke(cr);
                break;
            case Marker::Star:
                // 5-pointed star
                for (int i = 0; i < 5; i++) {
                    double angle = -M_PI/2 + i * 2*M_PI/5;
                    double r = (i % 2 == 0) ? size/2 : size/4;
                    double px = x + r * std::cos(angle);
                    double py = y + r * std::sin(angle);
                    if (i == 0) cairo_move_to(cr, px, py);
                    else cairo_line_to(cr, px, py);
                }
                cairo_close_path(cr);
                cairo_fill(cr);
                break;
            case Marker::Square:
                cairo_rectangle(cr, x - size/2, y - size/2, size, size);
                cairo_fill(cr);
                break;
            case Marker::Point:
                cairo_arc(cr, x, y, 2, 0, 2*M_PI);
                cairo_fill(cr);
                break;
            default:
                break;
        }
    }
    
    void render_grid(cairo_t* cr, const Axes& axes, double width, double height) {
        const auto& props = axes.get_properties();
        const auto& limits = axes.get_limits();
        
        cairo_save(cr);
        set_cairo_color(cr, props.grid_color);
        cairo_set_line_width(cr, 0.5);
        
        // Vertical grid lines
        int num_x_ticks = 10;
        for (int i = 0; i <= num_x_ticks; i++) {
            double x = width * i / num_x_ticks;
            cairo_move_to(cr, x, 0);
            cairo_line_to(cr, x, height);
        }
        
        // Horizontal grid lines
        int num_y_ticks = 10;
        for (int i = 0; i <= num_y_ticks; i++) {
            double y = height * i / num_y_ticks;
            cairo_move_to(cr, 0, y);
            cairo_line_to(cr, width, y);
        }
        
        cairo_stroke(cr);
        cairo_restore(cr);
    }
    
    void render_axes_decoration(cairo_t* cr, const Axes& axes, double width, double height) {
        const auto& labels = axes.get_labels();
        const auto& props = axes.get_properties();
        const auto& limits = axes.get_limits();
        
        cairo_select_font_face(cr, props.font_name.c_str(), 
                              CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size(cr, props.font_size);
        set_cairo_color(cr, colors::black);
        
        // X-axis label
        if (!labels.xlabel.empty()) {
            cairo_text_extents_t extents;
            cairo_text_extents(cr, labels.xlabel.c_str(), &extents);
            cairo_move_to(cr, (width - extents.width) / 2, height + 45);
            cairo_show_text(cr, labels.xlabel.c_str());
        }
        
        // Y-axis label (rotated)
        if (!labels.ylabel.empty()) {
            cairo_save(cr);
            cairo_move_to(cr, -40, height/2);
            cairo_rotate(cr, -M_PI/2);
            cairo_text_extents_t extents;
            cairo_text_extents(cr, labels.ylabel.c_str(), &extents);
            cairo_rel_move_to(cr, -extents.width/2, 0);
            cairo_show_text(cr, labels.ylabel.c_str());
            cairo_restore(cr);
        }
        
        // Title
        if (!labels.title.empty()) {
            cairo_set_font_size(cr, props.title_font_size);
            cairo_select_font_face(cr, props.font_name.c_str(),
                                  CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
            cairo_text_extents_t extents;
            cairo_text_extents(cr, labels.title.c_str(), &extents);
            cairo_move_to(cr, (width - extents.width) / 2, -10);
            cairo_show_text(cr, labels.title.c_str());
        }
        
        // Axis ticks and labels
        cairo_set_font_size(cr, 10);
        cairo_select_font_face(cr, props.font_name.c_str(),
                              CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        
        // X-axis ticks
        int num_x_ticks = 5;
        for (int i = 0; i <= num_x_ticks; i++) {
            double x = width * i / num_x_ticks;
            double val = limits.xmin + (limits.xmax - limits.xmin) * i / num_x_ticks;
            
            std::ostringstream oss;
            oss << std::fixed << std::setprecision(1) << val;
            std::string label = oss.str();
            
            cairo_text_extents_t extents;
            cairo_text_extents(cr, label.c_str(), &extents);
            cairo_move_to(cr, x - extents.width/2, height + 20);
            cairo_show_text(cr, label.c_str());
            
            // Tick mark
            cairo_move_to(cr, x, height);
            cairo_line_to(cr, x, height + 5);
            cairo_stroke(cr);
        }
        
        // Y-axis ticks
        int num_y_ticks = 5;
        for (int i = 0; i <= num_y_ticks; i++) {
            double y = height - height * i / num_y_ticks;
            double val = limits.ymin + (limits.ymax - limits.ymin) * i / num_y_ticks;
            
            std::ostringstream oss;
            oss << std::fixed << std::setprecision(1) << val;
            std::string label = oss.str();
            
            cairo_text_extents_t extents;
            cairo_text_extents(cr, label.c_str(), &extents);
            cairo_move_to(cr, -extents.width - 10, y + extents.height/2);
            cairo_show_text(cr, label.c_str());
            
            // Tick mark
            cairo_move_to(cr, -5, y);
            cairo_line_to(cr, 0, y);
            cairo_stroke(cr);
        }
    }
    
    void render_legend(cairo_t* cr, const Axes& axes, double width, double height) {
        const auto& legend = axes.get_legend();
        const auto& series = axes.get_series();
        
        if (legend.labels.empty()) return;
        
        double legend_width = 150;
        double legend_height = 30 + legend.labels.size() * 20;
        double legend_x, legend_y;
        
        // Position legend
        if (legend.location == "northeast") {
            legend_x = width - legend_width - 20;
            legend_y = 20;
        } else if (legend.location == "northwest") {
            legend_x = 20;
            legend_y = 20;
        } else if (legend.location == "southeast") {
            legend_x = width - legend_width - 20;
            legend_y = height - legend_height - 20;
        } else if (legend.location == "southwest") {
            legend_x = 20;
            legend_y = height - legend_height - 20;
        } else {
            legend_x = width - legend_width - 20;
            legend_y = 20;
        }
        
        // Draw legend box
        cairo_set_source_rgba(cr, 1, 1, 1, 0.9);
        cairo_rectangle(cr, legend_x, legend_y, legend_width, legend_height);
        cairo_fill_preserve(cr);
        set_cairo_color(cr, colors::black);
        cairo_set_line_width(cr, 1);
        cairo_stroke(cr);
        
        // Draw legend entries
        cairo_select_font_face(cr, legend.font_name.c_str(),
                              CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size(cr, legend.font_size);
        
        for (size_t i = 0; i < std::min(legend.labels.size(), series.size()); i++) {
            double y = legend_y + 20 + i * 20;
            
            // Draw line sample
            set_cairo_color(cr, series[i].color);
            cairo_set_line_width(cr, series[i].line_width);
            cairo_move_to(cr, legend_x + 10, y);
            cairo_line_to(cr, legend_x + 30, y);
            cairo_stroke(cr);
            
            // Draw text
            set_cairo_color(cr, colors::black);
            cairo_move_to(cr, legend_x + 35, y + 5);
            cairo_show_text(cr, legend.labels[i].c_str());
        }
    }
    
    void render_sgtitle(cairo_t* cr, const Figure& fig, double x, double y) {
        cairo_select_font_face(cr, "Times New Roman",
                              CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
        cairo_set_font_size(cr, 18);
        set_cairo_color(cr, colors::black);
        
        cairo_text_extents_t extents;
        cairo_text_extents(cr, fig.get_title().c_str(), &extents);
        cairo_move_to(cr, x - extents.width/2, y);
        cairo_show_text(cr, fig.get_title().c_str());
    }
    
    void set_cairo_color(cairo_t* cr, const Color& color) {
        cairo_set_source_rgba(cr, color.r, color.g, color.b, color.a);
    }
    
    std::string get_extension(const std::string& filename) {
        size_t dot = filename.rfind('.');
        if (dot == std::string::npos) return "";
        return filename.substr(dot + 1);
    }
};

#else

// Stub renderer when Cairo not available
class CairoRenderer : public Renderer {
public:
    bool render_figure(const Figure& fig, const std::string& filename, int dpi = 300) override {
        std::cerr << "Error: Cairo renderer not available (compile with -DHAVE_CAIRO -lcairo)\n";
        return false;
    }
    
    bool supports_format(const std::string& format) const override {
        return false;
    }
};

#endif

// Factory function
std::unique_ptr<Renderer> create_renderer(const std::string& backend) {
    if (backend == "cairo" || backend == "auto") {
        return std::make_unique<CairoRenderer>();
    }
    return nullptr;
}

// Implement Figure save methods
bool Figure::save_png(const std::string& filename, int dpi) {
    auto renderer = create_renderer("cairo");
    return renderer && renderer->render_figure(*this, filename, dpi);
}

bool Figure::save_pdf(const std::string& filename) {
    auto renderer = create_renderer("cairo");
    return renderer && renderer->render_figure(*this, filename, 300);
}

bool Figure::save_svg(const std::string& filename) {
    auto renderer = create_renderer("cairo");
    return renderer && renderer->render_figure(*this, filename, 300);
}

// Implement global save functions
void print_png(const std::string& filename, int dpi) {
    FigureManager::instance().gcf().save_png(filename, dpi);
}

void print_pdf(const std::string& filename) {
    FigureManager::instance().gcf().save_pdf(filename);
}

void savefig(const std::string& filename) {
    std::string ext = filename.substr(filename.rfind('.') + 1);
    if (ext == "png") print_png(filename);
    else if (ext == "pdf") print_pdf(filename);
    else if (ext == "svg") {
        FigureManager::instance().gcf().save_svg(filename);
    }
}

} // namespace plotting
} // namespace matlabcpp
