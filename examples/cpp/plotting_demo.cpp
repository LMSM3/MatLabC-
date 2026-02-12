// ASCII Plotting Demo - 2D and 3D visualization
// Compile: g++ -std=c++17 -I../../include -o plotting_demo plotting_demo.cpp ../../src/plotting/renderer_2d.cpp ../../src/plotting/renderer_3d.cpp

#include <iostream>
#include <vector>
#include <cmath>

// From our plotting implementation
namespace matlabcpp {
namespace plotting {
    struct Plot2D {
        std::vector<double> x;
        std::vector<double> y;
        std::string label;
        char marker = '*';
    };
    
    void plot2d(const std::vector<double>& x, const std::vector<double>& y, const std::string& label = "");
    void plot2d_multi(const std::vector<Plot2D>& plots, const std::string& title = "");
    
    struct Point3D { double x, y, z; };
    void plot3d_scatter(const std::vector<Point3D>& points, const std::string& title = "");
    void plot3d_surface(const std::vector<std::vector<Point3D>>& grid, const std::string& title = "");
}
}

int main() {
    using namespace matlabcpp::plotting;
    
    std::cout << "\n╔══════════════════════════════════════════════════════╗\n";
    std::cout << "║       MatLabC++ ASCII Plotting Demo                 ║\n";
    std::cout << "╚══════════════════════════════════════════════════════╝\n\n";
    
    // ========== 2D PLOT DEMO ==========
    std::cout << "═══ 2D Plotting Demo ═══\n\n";
    
    std::cout << "1. Simple Sine Wave:\n";
    std::vector<double> x1, y1;
    for (int i = 0; i <= 50; i++) {
        double x = i * 0.2;
        x1.push_back(x);
        y1.push_back(std::sin(x));
    }
    plot2d(x1, y1, "sin(x)");
    
    std::cout << "\n\n2. Multiple Data Series (Trig Functions):\n";
    std::vector<Plot2D> multi_plots;
    
    // Sine
    Plot2D p1;
    p1.marker = '*';
    p1.label = "sin(x)";
    for (int i = 0; i <= 40; i++) {
        double x = i * 0.3;
        p1.x.push_back(x);
        p1.y.push_back(std::sin(x));
    }
    
    // Cosine
    Plot2D p2;
    p2.marker = 'o';
    p2.label = "cos(x)";
    for (int i = 0; i <= 40; i++) {
        double x = i * 0.3;
        p2.x.push_back(x);
        p2.y.push_back(std::cos(x));
    }
    
    multi_plots.push_back(p1);
    multi_plots.push_back(p2);
    plot2d_multi(multi_plots, "Trigonometric Functions");
    
    std::cout << "\n\n3. Projectile Trajectory (Physics!):\n";
    std::vector<double> x_proj, y_proj;
    double v0 = 45.0, angle = 45.0 * M_PI / 180.0, g = 9.81, h0 = 2.0;
    double vx = v0 * std::cos(angle);
    double vy = v0 * std::sin(angle);
    
    for (double t = 0; t < 7.0; t += 0.1) {
        double x = vx * t;
        double y = h0 + vy * t - 0.5 * g * t * t;
        if (y < 0) break;
        x_proj.push_back(x);
        y_proj.push_back(y);
    }
    plot2d(x_proj, y_proj, "Projectile Path");
    
    // ========== 3D PLOT DEMO ==========
    std::cout << "\n\n═══ 3D Plotting Demo ═══\n\n";
    
    std::cout << "4. 3D Scatter Plot (Helix):\n";
    std::vector<Point3D> helix;
    for (int i = 0; i < 50; i++) {
        double t = i * 0.3;
        helix.push_back({
            std::cos(t),
            std::sin(t),
            t * 0.1
        });
    }
    plot3d_scatter(helix, "3D Helix");
    
    std::cout << "\n\n5. 3D Surface Plot (Saddle / Hyperbolic Paraboloid):\n";
    std::vector<std::vector<Point3D>> surface;
    int grid_size = 15;
    for (int i = 0; i < grid_size; i++) {
        std::vector<Point3D> row;
        for (int j = 0; j < grid_size; j++) {
            double x = -1.5 + 3.0 * i / (grid_size - 1);
            double y = -1.5 + 3.0 * j / (grid_size - 1);
            double z = x * x - y * y;  // Saddle function
            row.push_back({x, y, z});
        }
        surface.push_back(row);
    }
    plot3d_surface(surface, "Saddle Surface (z = x² - y²)");
    
    std::cout << "\n\n6. 3D Surface Plot (Gaussian Peak):\n";
    std::vector<std::vector<Point3D>> gaussian;
    for (int i = 0; i < grid_size; i++) {
        std::vector<Point3D> row;
        for (int j = 0; j < grid_size; j++) {
            double x = -2.0 + 4.0 * i / (grid_size - 1);
            double y = -2.0 + 4.0 * j / (grid_size - 1);
            double z = std::exp(-(x*x + y*y));  // Gaussian
            row.push_back({x, y, z});
        }
        gaussian.push_back(row);
    }
    plot3d_surface(gaussian, "Gaussian Peak (z = e^(-x²-y²))");
    
    std::cout << "\n\n╔══════════════════════════════════════════════════════╗\n";
    std::cout << "║              Demo Complete!                          ║\n";
    std::cout << "╚══════════════════════════════════════════════════════╝\n";
    std::cout << "\nKey Features:\n";
    std::cout << "  • 2D plots: Auto-scaling, axis labels, multi-series\n";
    std::cout << "  • 3D plots: Isometric projection, height-based shading\n";
    std::cout << "  • ASCII-based: Works on any terminal, no dependencies\n";
    std::cout << "  • Publication-ready layout from style presets\n\n";
    
    return 0;
}
