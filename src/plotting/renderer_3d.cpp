// 3D Plotting Renderer - ASCII isometric projection
// src/plotting/renderer_3d.cpp

#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm>
#include <map>

namespace matlabcpp {
namespace plotting {

// 3D point
struct Point3D {
    double x, y, z;
};

// Isometric projection to 2D
struct Point2D {
    int x, y;
};

class Renderer3D_ASCII {
    int width_ = 80;
    int height_ = 40;

    // Isometric projection (standard 30-degree angles)
    Point2D project(const Point3D& p, double scale) {
        Point2D result;
        result.x = (int)((p.x - p.y) * scale * 0.866);  // cos(30°)
        result.y = (int)((p.x + p.y) * scale * 0.5 - p.z * scale);  // sin(30°)
        return result;
    }

public:
    void set_size(int width, int height) {
        width_ = width;
        height_ = height;
    }

    void render_surface(const std::vector<std::vector<Point3D>>& grid,
                       const std::string& title = "") {

        if (grid.empty() || grid[0].empty()) return;

        // Find bounds
        double xmin = grid[0][0].x, xmax = grid[0][0].x;
        double ymin = grid[0][0].y, ymax = grid[0][0].y;
        double zmin = grid[0][0].z, zmax = grid[0][0].z;

        for (const auto& row : grid) {
            for (const auto& p : row) {
                xmin = std::min(xmin, p.x); xmax = std::max(xmax, p.x);
                ymin = std::min(ymin, p.y); ymax = std::max(ymax, p.y);
                zmin = std::min(zmin, p.z); zmax = std::max(zmax, p.z);
            }
        }

        // Normalize to [-1, 1]
        auto normalize = [&](Point3D& p) {
            p.x = 2.0 * (p.x - xmin) / (xmax - xmin) - 1.0;
            p.y = 2.0 * (p.y - ymin) / (ymax - ymin) - 1.0;
            p.z = 2.0 * (p.z - zmin) / (zmax - zmin) - 1.0;
        };

        std::vector<std::vector<Point3D>> normalized = grid;
        for (auto& row : normalized) {
            for (auto& p : row) {
                normalize(p);
            }
        }

        // Canvas
        std::vector<std::vector<char>> canvas(height_, std::vector<char>(width_, ' '));

        double scale = std::min(width_, height_) / 4.0;
        int cx = width_ / 2;
        int cy = height_ / 2;

        // Draw grid lines
        for (size_t i = 0; i < normalized.size(); ++i) {
            for (size_t j = 0; j < normalized[i].size(); ++j) {
                Point2D p = project(normalized[i][j], scale);
                int x = cx + p.x;
                int y = cy + p.y;

                if (x >= 0 && x < width_ && y >= 0 && y < height_) {
                    // Height-based shading
                    double z_norm = (grid[i][j].z - zmin) / (zmax - zmin);
                    char shade = z_norm > 0.66 ? '#' : (z_norm > 0.33 ? '+' : '.');
                    canvas[y][x] = shade;
                }

                // Draw lines to adjacent points
                if (j + 1 < normalized[i].size()) {
                    Point2D next = project(normalized[i][j + 1], scale);
                    draw_line(canvas, cx + p.x, cy + p.y, cx + next.x, cy + next.y, '-');
                }
                if (i + 1 < normalized.size()) {
                    Point2D next = project(normalized[i + 1][j], scale);
                    draw_line(canvas, cx + p.x, cy + p.y, cx + next.x, cy + next.y, '|');
                }
            }
        }

        // Print
        if (!title.empty()) {
            std::cout << "\n  " << title << "\n\n";
        }

        for (const auto& row : canvas) {
            std::cout << "  ";
            for (char c : row) {
                std::cout << c;
            }
            std::cout << "\n";
        }

        std::cout << "\n  Z-axis: . (low) + (mid) # (high)\n";
    }

    void render_scatter3d(const std::vector<Point3D>& points,
                         const std::string& title = "") {

        if (points.empty()) return;

        // Find bounds
        double xmin = points[0].x, xmax = points[0].x;
        double ymin = points[0].y, ymax = points[0].y;
        double zmin = points[0].z, zmax = points[0].z;

        for (const auto& p : points) {
            xmin = std::min(xmin, p.x); xmax = std::max(xmax, p.x);
            ymin = std::min(ymin, p.y); ymax = std::max(ymax, p.y);
            zmin = std::min(zmin, p.z); zmax = std::max(zmax, p.z);
        }

        // Normalize
        std::vector<Point3D> normalized;
        for (const auto& p : points) {
            Point3D n;
            n.x = 2.0 * (p.x - xmin) / (xmax - xmin) - 1.0;
            n.y = 2.0 * (p.y - ymin) / (ymax - ymin) - 1.0;
            n.z = 2.0 * (p.z - zmin) / (zmax - zmin) - 1.0;
            normalized.push_back(n);
        }

        // Canvas
        std::vector<std::vector<char>> canvas(height_, std::vector<char>(width_, ' '));

        double scale = std::min(width_, height_) / 4.0;
        int cx = width_ / 2;
        int cy = height_ / 2;

        // Draw points
        for (const auto& p : normalized) {
            Point2D proj = project(p, scale);
            int x = cx + proj.x;
            int y = cy + proj.y;

            if (x >= 0 && x < width_ && y >= 0 && y < height_) {
                canvas[y][x] = '*';
            }
        }

        // Print
        if (!title.empty()) {
            std::cout << "\n  " << title << "\n\n";
        }

        for (const auto& row : canvas) {
            std::cout << "  ";
            for (char c : row) {
                std::cout << c;
            }
            std::cout << "\n";
        }
        std::cout << "\n";
    }

private:
    void draw_line(std::vector<std::vector<char>>& canvas,
                   int x0, int y0, int x1, int y1, char ch) {
        // Bresenham's line algorithm
        int dx = std::abs(x1 - x0);
        int dy = std::abs(y1 - y0);
        int sx = x0 < x1 ? 1 : -1;
        int sy = y0 < y1 ? 1 : -1;
        int err = dx - dy;

        while (true) {
            if (x0 >= 0 && x0 < width_ && y0 >= 0 && y0 < height_) {
                if (canvas[y0][x0] == ' ') {
                    canvas[y0][x0] = ch;
                }
            }

            if (x0 == x1 && y0 == y1) break;

            int e2 = 2 * err;
            if (e2 > -dy) {
                err -= dy;
                x0 += sx;
            }
            if (e2 < dx) {
                err += dx;
                y0 += sy;
            }
        }
    }
};

// Global renderer
static Renderer3D_ASCII g_renderer3d;

// Public API
void plot3d_scatter(const std::vector<Point3D>& points, const std::string& title) {
    g_renderer3d.render_scatter3d(points, title);
}

void plot3d_surface(const std::vector<std::vector<Point3D>>& grid, const std::string& title) {
    g_renderer3d.render_surface(grid, title);
}

} // namespace plotting
} // namespace matlabcpp

