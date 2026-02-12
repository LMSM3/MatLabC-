// 2D Plotting Renderer - Simple ASCII + optional Cairo backend
// src/plotting/renderer_2d.cpp

#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm>
#include <sstream>
#include <iomanip>

namespace matlabcpp {
namespace plotting {

// Simple 2D plot data structure
struct Plot2D {
    std::vector<double> x;
    std::vector<double> y;
    std::string label;
    char marker = '*';
};

// ASCII-based 2D renderer (always available, no dependencies)
class Renderer2D_ASCII {
    int width_ = 60;
    int height_ = 20;

public:
    void set_size(int width, int height) {
        width_ = width;
        height_ = height;
    }

    void render(const std::vector<Plot2D>& plots,
                const std::string& title = "",
                const std::string& xlabel = "",
                const std::string& ylabel = "") {

        if (plots.empty()) return;

        // Find data bounds
        double xmin = plots[0].x[0], xmax = plots[0].x[0];
        double ymin = plots[0].y[0], ymax = plots[0].y[0];

        for (const auto& plot : plots) {
            for (size_t i = 0; i < plot.x.size(); ++i) {
                xmin = std::min(xmin, plot.x[i]);
                xmax = std::max(xmax, plot.x[i]);
                ymin = std::min(ymin, plot.y[i]);
                ymax = std::max(ymax, plot.y[i]);
            }
        }

        // Add 5% margin
        double xmargin = (xmax - xmin) * 0.05;
        double ymargin = (ymax - ymin) * 0.05;
        xmin -= xmargin; xmax += xmargin;
        ymin -= ymargin; ymax += ymargin;

        // Create canvas
        std::vector<std::vector<char>> canvas(height_, std::vector<char>(width_, ' '));

        // Plot data points
        for (const auto& plot : plots) {
            for (size_t i = 0; i < plot.x.size(); ++i) {
                int col = (int)((plot.x[i] - xmin) / (xmax - xmin) * (width_ - 1));
                int row = height_ - 1 - (int)((plot.y[i] - ymin) / (ymax - ymin) * (height_ - 1));

                if (row >= 0 && row < height_ && col >= 0 && col < width_) {
                    canvas[row][col] = plot.marker;
                }
            }
        }

        // Draw axes
        for (int i = 0; i < height_; ++i) {
            canvas[i][0] = '|';
        }
        for (int j = 0; j < width_; ++j) {
            canvas[height_ - 1][j] = '_';
        }
        canvas[height_ - 1][0] = '+';

        // Print title
        if (!title.empty()) {
            std::cout << "\n  " << title << "\n";
        }

        // Print canvas with y-axis labels
        for (int i = 0; i < height_; ++i) {
            double yval = ymax - (double)i / (height_ - 1) * (ymax - ymin);
            std::cout << std::setw(8) << std::fixed << std::setprecision(2) << yval << " ";
            for (int j = 0; j < width_; ++j) {
                std::cout << canvas[i][j];
            }
            std::cout << "\n";
        }

        // Print x-axis labels
        std::cout << "         ";
        for (int j = 0; j < width_; j += 10) {
            double xval = xmin + (double)j / (width_ - 1) * (xmax - xmin);
            std::cout << std::setw(10) << std::fixed << std::setprecision(1) << xval;
        }
        std::cout << "\n";

        if (!xlabel.empty()) {
            std::cout << "         " << xlabel << "\n";
        }
        if (!ylabel.empty()) {
            std::cout << ylabel << " (vertical axis)\n";
        }

        // Legend
        if (plots.size() > 1) {
            std::cout << "\nLegend: ";
            for (const auto& plot : plots) {
                std::cout << plot.marker << "=" << plot.label << "  ";
            }
            std::cout << "\n";
        }
    }
};

// Global renderer instance
static Renderer2D_ASCII g_renderer;

// Public API
void plot2d(const std::vector<double>& x, const std::vector<double>& y, const std::string& label) {
    Plot2D p;
    p.x = x;
    p.y = y;
    p.label = label;
    g_renderer.render({p});
}

void plot2d_multi(const std::vector<Plot2D>& plots, const std::string& title) {
    g_renderer.render(plots, title);
}

} // namespace plotting
} // namespace matlabcpp

