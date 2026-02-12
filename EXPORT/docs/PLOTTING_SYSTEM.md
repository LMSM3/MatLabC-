# MatLabC++ Plotting System

**Compile MATLAB plots → Plot Spec JSON → Native C++ Renderer**

Not a graphics library. A plotting compiler with native backends.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  MATLAB Plotting Code                                       │
│  figure; plot(x, y); xlabel('Time'); exportgraphics(...)    │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Plot Compiler (mlab++ plotting parser)                     │
│  Parses: figure/axes/plot/scatter/surf/title/legend/...     │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Plot Spec JSON (intermediate representation)               │
│  {                                                           │
│    "figure": {"size": [800, 600], "theme": "business"},     │
│    "axes": [...],                                            │
│    "series": [...],                                          │
│    "export": {"format": "png", "dpi": 300}                  │
│  }                                                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  C++ Renderer (backend selection)                           │
│  • 2D: Cairo/AGG/Skia                                        │
│  • 3D: OpenGL/VTK/Three.js                                   │
│  • Vector: SVG/PDF                                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Output Files                                                │
│  • PNG (raster, high DPI)                                    │
│  • SVG (vector, scalable)                                    │
│  • PDF (publication quality)                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Plot Spec JSON Schema

### Complete Example

```json
{
  "version": "1.0",
  "metadata": {
    "generated_by": "matlabcpp-v0.3.0",
    "source_file": "example.m",
    "timestamp": "2024-01-15T10:30:00Z"
  },
  
  "figure": {
    "id": "fig1",
    "size": [800, 600],
    "units": "pixels",
    "theme": "business",
    "background": "#ffffff",
    "title": "Engineering Analysis Results",
    "layout": "single"
  },
  
  "axes": [
    {
      "id": "ax1",
      "position": [0.1, 0.1, 0.8, 0.8],
      "title": "Stress vs Strain",
      "xlabel": {
        "text": "Strain (%)",
        "fontsize": 12,
        "fontweight": "normal"
      },
      "ylabel": {
        "text": "Stress (MPa)",
        "fontsize": 12,
        "fontweight": "normal"
      },
      "xlim": [0, 5],
      "ylim": [0, 400],
      "grid": true,
      "grid_style": "minor",
      "box": true,
      "aspect": "auto"
    }
  ],
  
  "series": [
    {
      "type": "line",
      "axes_id": "ax1",
      "xdata": [0, 1, 2, 3, 4, 5],
      "ydata": [0, 80, 160, 240, 320, 400],
      "style": {
        "color": "#0072BD",
        "linewidth": 2,
        "linestyle": "-",
        "marker": "o",
        "markersize": 6,
        "markerfacecolor": "#0072BD",
        "markeredgecolor": "#000000"
      },
      "legend": "Aluminum 6061-T6"
    },
    {
      "type": "line",
      "axes_id": "ax1",
      "xdata": [0, 1, 2, 3, 4, 5],
      "ydata": [0, 100, 200, 300, 350, 380],
      "style": {
        "color": "#D95319",
        "linewidth": 2,
        "linestyle": "--",
        "marker": "s",
        "markersize": 6
      },
      "legend": "Steel 316L"
    }
  ],
  
  "annotations": [
    {
      "type": "text",
      "axes_id": "ax1",
      "position": [2.5, 300],
      "text": "Yield point",
      "fontsize": 10,
      "color": "#000000"
    },
    {
      "type": "arrow",
      "axes_id": "ax1",
      "start": [2.5, 280],
      "end": [2.0, 240]
    }
  ],
  
  "legend": {
    "show": true,
    "location": "northwest",
    "fontsize": 10,
    "box": true,
    "background": "#ffffff",
    "alpha": 0.9
  },
  
  "colorbar": {
    "show": false
  },
  
  "export": {
    "format": ["png", "svg"],
    "filename": "stress_strain",
    "dpi": 300,
    "bbox_inches": "tight",
    "transparent": false
  },
  
  "style_preset": "engineering"
}
```

### 3D Surface Example

```json
{
  "figure": {
    "size": [1000, 800],
    "theme": "engineering"
  },
  
  "axes": [
    {
      "id": "ax1",
      "type": "3d",
      "title": "Temperature Distribution",
      "xlabel": {"text": "X Position (mm)"},
      "ylabel": {"text": "Y Position (mm)"},
      "zlabel": {"text": "Temperature (°C)"},
      "view": [45, 30],
      "axis_equal": true,
      "lighting": "gouraud"
    }
  ],
  
  "series": [
    {
      "type": "surface",
      "axes_id": "ax1",
      "xdata": [[0, 1, 2], [0, 1, 2], [0, 1, 2]],
      "ydata": [[0, 0, 0], [1, 1, 1], [2, 2, 2]],
      "zdata": [[20, 25, 22], [25, 30, 27], [22, 27, 24]],
      "colormap": "jet",
      "shading": "interp",
      "alpha": 1.0
    }
  ],
  
  "colorbar": {
    "show": true,
    "label": "Temperature (°C)",
    "location": "eastoutside"
  }
}
```

### Tiled Layout (Dashboard)

```json
{
  "figure": {
    "size": [1200, 800],
    "theme": "business",
    "layout": "tiled",
    "tiled_config": {
      "rows": 2,
      "cols": 2,
      "padding": 0.05
    }
  },
  
  "axes": [
    {
      "id": "ax1",
      "tile_position": [1, 1],
      "title": "Revenue by Quarter"
    },
    {
      "id": "ax2",
      "tile_position": [1, 2],
      "title": "Customer Acquisition"
    },
    {
      "id": "ax3",
      "tile_position": [2, 1],
      "title": "Operating Costs"
    },
    {
      "id": "ax4",
      "tile_position": [2, 2],
      "title": "Profit Margin"
    }
  ]
}
```

---

## MATLAB Plotting Subset

### Supported Commands

```matlab
% Figure creation
figure
figure('Position', [100, 100, 800, 600])
clf

% Axes
axes
subplot(m, n, p)
tiledlayout(m, n)
nexttile

% 2D Plotting
plot(x, y)
plot(x, y, 'LineWidth', 2, 'Color', 'r')
scatter(x, y)
bar(x, y)
histogram(x)
errorbar(x, y, err)

% 3D Plotting
plot3(x, y, z)
scatter3(x, y, z)
surf(X, Y, Z)
mesh(X, Y, Z)
contour(X, Y, Z)

% Formatting
title('Title Text')
xlabel('X Label')
ylabel('Y Label')
zlabel('Z Label')
legend('Series 1', 'Series 2')
grid on
grid minor
box on
axis equal
xlim([xmin, xmax])
ylim([ymin, ymax])
zlim([zmin, zmax])

% Properties
set(gca, 'FontSize', 12)
set(gca, 'LineWidth', 1.5)
set(gca, 'XScale', 'log')

% View control (3D)
view(azimuth, elevation)
camlight
lighting gouraud

% Colormap
colormap('jet')
colorbar
caxis([cmin, cmax])

% Export
exportgraphics(gcf, 'figure.png', 'Resolution', 300)
saveas(gcf, 'figure.svg')
print('-dpdf', 'figure.pdf')
```

---

## Style Presets

### Business Theme

```json
{
  "name": "business",
  "description": "Clean corporate look for presentations",
  
  "figure": {
    "background": "#ffffff",
    "default_size": [800, 600]
  },
  
  "axes": {
    "fontname": "Arial",
    "fontsize": 11,
    "linewidth": 1.0,
    "box": true,
    "grid": true,
    "grid_alpha": 0.15,
    "grid_linestyle": "-",
    "grid_linewidth": 0.5
  },
  
  "colors": {
    "default_order": [
      "#0072BD",
      "#D95319",
      "#EDB120",
      "#7E2F8E",
      "#77AC30",
      "#4DBEEE",
      "#A2142F"
    ]
  },
  
  "lines": {
    "linewidth": 2,
    "markersize": 6
  },
  
  "legend": {
    "fontsize": 10,
    "location": "best",
    "box": true,
    "shadow": false
  },
  
  "text": {
    "fontsize": 12,
    "fontweight": "normal"
  },
  
  "export": {
    "dpi": 150,
    "bbox_inches": "tight"
  }
}
```

### Engineering Theme

```json
{
  "name": "engineering",
  "description": "Technical plots for engineering reports",
  
  "figure": {
    "background": "#ffffff",
    "default_size": [1000, 750]
  },
  
  "axes": {
    "fontname": "Times New Roman",
    "fontsize": 12,
    "linewidth": 1.5,
    "box": true,
    "grid": true,
    "grid_alpha": 0.3,
    "grid_linestyle": ":",
    "grid_linewidth": 0.5,
    "minor_grid": true
  },
  
  "colors": {
    "default_order": [
      "#000000",
      "#E41A1C",
      "#377EB8",
      "#4DAF4A",
      "#984EA3",
      "#FF7F00"
    ]
  },
  
  "lines": {
    "linewidth": 1.5,
    "markersize": 8
  },
  
  "legend": {
    "fontsize": 11,
    "location": "best",
    "box": true,
    "shadow": true
  },
  
  "text": {
    "fontsize": 12,
    "fontweight": "bold"
  },
  
  "3d": {
    "axis_equal": true,
    "lighting": "gouraud",
    "view": [45, 30],
    "projection": "perspective"
  },
  
  "colorbar": {
    "always_show_units": true,
    "fontsize": 11
  },
  
  "export": {
    "dpi": 300,
    "bbox_inches": "tight"
  }
}
```

---

## C++ Renderer API

### Core Classes

```cpp
// include/matlabcpp/plotting/renderer.hpp

namespace matlabcpp {
namespace plotting {

class PlotRenderer {
public:
    virtual ~PlotRenderer() = default;
    
    // Load plot specification
    virtual void load_spec(const std::string& json_path) = 0;
    
    // Render to image
    virtual void render_to_file(const std::string& output_path) = 0;
    virtual void render_to_buffer(std::vector<uint8_t>& buffer) = 0;
    
    // Interactive display
    virtual void show() = 0;
};

// 2D Renderer (Cairo backend)
class Renderer2D : public PlotRenderer {
    void load_spec(const std::string& json_path) override;
    void render_to_file(const std::string& output_path) override;
    void show() override;
    
private:
    void render_line_series(const LineSeries& series);
    void render_scatter_series(const ScatterSeries& series);
    void render_axes(const Axes& axes);
    void render_legend(const Legend& legend);
    void apply_style_preset(const std::string& preset);
};

// 3D Renderer (OpenGL/VTK backend)
class Renderer3D : public PlotRenderer {
    void load_spec(const std::string& json_path) override;
    void render_to_file(const std::string& output_path) override;
    void show() override;
    
private:
    void render_surface(const SurfaceSeries& series);
    void render_mesh(const MeshSeries& series);
    void setup_camera(const Camera& camera);
    void setup_lighting(const Lighting& lighting);
};

// Vector Renderer (SVG/PDF)
class VectorRenderer : public PlotRenderer {
    void load_spec(const std::string& json_path) override;
    void render_to_file(const std::string& output_path) override;
    void show() override;  // Opens in browser
};

// Factory
class RendererFactory {
public:
    static std::unique_ptr<PlotRenderer> create(
        const std::string& backend,
        const std::string& output_format
    );
    
    // Auto-select based on plot spec
    static std::unique_ptr<PlotRenderer> auto_create(
        const std::string& json_path
    );
};

}} // namespace
```

---

## Usage Examples

### Example 1: Engineering Report (2D)

**MATLAB Code:**
```matlab
% stress_strain.m
strain = 0:0.1:5;
stress_al = 68.9e9 * strain / 100;  % Aluminum
stress_st = 200e9 * strain / 100;   % Steel

figure('Position', [100, 100, 800, 600]);
set(gcf, 'Theme', 'engineering');

plot(strain, stress_al/1e6, 'LineWidth', 2, 'Color', '#0072BD', 'Marker', 'o');
hold on;
plot(strain, stress_st/1e6, 'LineWidth', 2, 'Color', '#D95319', 'Marker', 's');

xlabel('Strain (%)', 'FontSize', 12);
ylabel('Stress (MPa)', 'FontSize', 12);
title('Material Stress-Strain Comparison');
legend('Aluminum 6061', 'Steel 316L', 'Location', 'northwest');
grid on;
grid minor;

exportgraphics(gcf, 'stress_strain.png', 'Resolution', 300);
```

**Generated Plot Spec:**
```json
{
  "figure": {"theme": "engineering"},
  "axes": [{
    "title": "Material Stress-Strain Comparison",
    "xlabel": {"text": "Strain (%)", "fontsize": 12},
    "ylabel": {"text": "Stress (MPa)", "fontsize": 12},
    "grid": true,
    "grid_style": "minor"
  }],
  "series": [
    {
      "type": "line",
      "xdata": [0, 0.1, 0.2, ..., 5.0],
      "ydata": [...],
      "style": {"color": "#0072BD", "linewidth": 2, "marker": "o"},
      "legend": "Aluminum 6061"
    },
    ...
  ],
  "export": {"format": "png", "dpi": 300}
}
```

**Render:**
```cpp
auto renderer = RendererFactory::auto_create("stress_strain_spec.json");
renderer->render_to_file("stress_strain.png");
```

### Example 2: Business Dashboard

**MATLAB Code:**
```matlab
% dashboard.m
figure('Position', [100, 100, 1200, 800]);
set(gcf, 'Theme', 'business');

tiledlayout(2, 2, 'Padding', 'compact');

% Q1: Revenue
nexttile;
bar([Q1, Q2, Q3, Q4]);
title('Quarterly Revenue');
ylabel('Revenue ($M)');
grid on;

% Q2: Customers
nexttile;
plot(months, customers, 'LineWidth', 2);
title('Customer Growth');
ylabel('Active Customers');

% Q3: Costs
nexttile;
area(months, [labor, materials, overhead]);
title('Cost Breakdown');
legend('Labor', 'Materials', 'Overhead');

% Q4: Margin
nexttile;
plot(months, margin, 'LineWidth', 3, 'Color', '#77AC30');
title('Profit Margin (%)');
ylim([0, 30]);

exportgraphics(gcf, 'dashboard.png', 'Resolution', 150);
```

**Output:** Clean 4-panel dashboard, business theme

### Example 3: 3D Engineering Surface

**MATLAB Code:**
```matlab
% heat_distribution.m
[X, Y] = meshgrid(0:0.1:10, 0:0.1:10);
Z = 100 * exp(-((X-5).^2 + (Y-5).^2) / 10);

figure;
set(gcf, 'Theme', 'engineering');

surf(X, Y, Z);
title('Temperature Distribution');
xlabel('X Position (mm)');
ylabel('Y Position (mm)');
zlabel('Temperature (°C)');
colorbar;
colormap('jet');
view(45, 30);
camlight;
lighting gouraud;
axis equal;

exportgraphics(gcf, 'heat_dist.png', 'Resolution', 300);
```

**Render:** 3D surface with proper lighting, engineering style

---

## Backend Selection

### Automatic Backend Choice

```cpp
// Based on plot type and output format
Backend choose_backend(const PlotSpec& spec) {
    if (spec.has_3d_axes()) {
        if (spec.export_format == "interactive")
            return Backend::WEBGL;
        else
            return Backend::OPENGL;
    } else {
        if (spec.export_format == "svg" || spec.export_format == "pdf")
            return Backend::CAIRO_VECTOR;
        else if (spec.export_format == "png")
            return Backend::CAIRO_RASTER;
    }
}
```

### Available Backends

| Backend | Use Case | Output |
|---------|----------|--------|
| Cairo (raster) | 2D charts, PNG export | PNG, high DPI |
| Cairo (vector) | 2D charts, publication | SVG, PDF |
| OpenGL | 3D surfaces, fast | PNG (via FBO) |
| VTK | 3D scientific vis | PNG, interactive |
| WebGL/Three.js | Interactive 3D | HTML + JS |

---

## Integration with Package Manager

### plotting Module

```json
{
  "name": "plotting",
  "version": "1.0.0",
  "description": "Native plotting with business and engineering themes",
  
  "requires": ["core >= 0.3.0"],
  
  "backends": {
    "available": ["cairo", "opengl", "svg"],
    "default": "cairo"
  },
  
  "provides": [
    "plot",
    "scatter",
    "surf",
    "exportgraphics",
    "figure",
    "axes"
  ],
  
  "style_presets": ["business", "engineering"]
}
```

### Installation

```bash
mlab++ pkg install plotting
```

---

## See Also

- [packages/manifests/plotting.json](../packages/manifests/plotting.json)
- [examples/plotting_demo.m](../examples/plotting_demo.m)
- [include/matlabcpp/plotting/](../include/matlabcpp/plotting/)

---

**"Compile plots to JSON. Render in native C++. Look professional."**
