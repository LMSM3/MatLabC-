# CRITICAL PATH: MATLAB Experience Features

**These are the killer features that make MatLabC++ feel like MATLAB**

---

## 🎯 Two Critical Features

### 1. publish() - Report Generation
**Why critical:** Scientific workflows require publication-ready reports

### 2. Active Figure Windows
**Why critical:** Interactive data exploration is MATLAB's core strength

**Current Status:** We have ActiveWindow foundation, need graphics integration

---

## 🔥 Priority 1: publish() System

### What It Does:
```matlab
% my_analysis.m
%% Section 1: Data Loading
% This loads experimental data
load('data.mat')

%% Section 2: Analysis
x = 1:100;
y = sin(x/10);

%% Section 3: Visualization
figure
plot(x, y)
title('Results')

%% Publish to PDF
publish('my_analysis.m', 'pdf')
```

**Output:** Beautiful PDF with:
- Formatted code blocks
- Captured output
- Embedded figures
- Section headers
- LaTeX math

---

## Implementation Plan

### Phase 1: Basic publish() (v0.5.2) - 1 week

**File:** `src/publishing/publisher.cpp`

```cpp
namespace matlabcpp {
namespace publishing {

class Publisher {
public:
    // Main entry point
    void publish(const std::string& script_file, 
                 const std::string& format = "html",
                 const PublishOptions& options = {});
    
private:
    // Parse script into cells
    std::vector<Cell> parse_cells(const std::string& content);
    
    // Execute cell and capture output
    CellOutput execute_cell(const Cell& cell);
    
    // Generate output format
    void generate_html(const std::vector<CellOutput>& outputs);
    void generate_pdf(const std::vector<CellOutput>& outputs);
    void generate_latex(const std::vector<CellOutput>& outputs);
};

struct Cell {
    CellType type;      // code, text, section
    std::string content;
    int line_start;
};

struct CellOutput {
    std::string code;
    std::string text_output;
    std::vector<Figure> figures;
    bool has_error;
    std::string error_msg;
};

} // namespace publishing
} // namespace matlabcpp
```

**Features:**
- Parse `%%` cell markers
- Execute code cells
- Capture stdout/stderr
- Capture figures
- Generate HTML/PDF

**Dependencies:**
- Script execution (v0.4.1) ✅
- Figure capture
- HTML generation (simple)
- PDF generation (wkhtmltopdf or LaTeX)

---

### Phase 2: Figure Capture (v0.5.1) - 1 week

**Integration with Active Window:**

```cpp
// src/graphics/figure_manager.cpp
namespace matlabcpp {
namespace graphics {

class FigureManager {
public:
    // Create new figure window
    FigureHandle figure(int num = -1);
    
    // Capture current figure
    Image capture_figure(FigureHandle handle);
    
    // Save to file
    void save_figure(FigureHandle handle, 
                     const std::string& filename,
                     const std::string& format = "png");
    
    // For publish()
    std::vector<Image> get_all_figures();
    
private:
    std::map<int, std::unique_ptr<FigureWindow>> figures_;
    FigureHandle current_figure_;
};

class FigureWindow {
public:
    void plot(const Vector& x, const Vector& y, const PlotOptions& opts);
    void hold(bool on);
    void grid(bool on);
    void title(const std::string& text, const TextOptions& opts);
    void xlabel(const std::string& text, const TextOptions& opts);
    void ylabel(const std::string& text, const TextOptions& opts);
    
    // Capture
    Image render_to_image(int width, int height);
    
private:
    Cairo::RefPtr<Cairo::ImageSurface> surface_;
    Cairo::RefPtr<Cairo::Context> context_;
    // ... plotting state
};

} // namespace graphics
} // namespace matlabcpp
```

---

### Phase 3: Real-Time Figure Windows (v0.5.1) - 1 week

**Active Window Implementation:**

```cpp
// src/graphics/figure_window.cpp
#include <gtk/gtk.h>  // or Qt, or custom windowing

class FigureWindow {
public:
    FigureWindow(int figure_num) 
        : number_(figure_num), visible_(true) {
        
        // Create GTK window
        window_ = gtk_window_new(GTK_WINDOW_TOPLEVEL);
        gtk_window_set_title(GTK_WINDOW(window_), 
                            ("Figure " + std::to_string(number_)).c_str());
        gtk_window_set_default_size(GTK_WINDOW(window_), 800, 600);
        
        // Create drawing area
        canvas_ = gtk_drawing_area_new();
        gtk_container_add(GTK_CONTAINER(window_), canvas_);
        
        // Connect draw callback
        g_signal_connect(canvas_, "draw", G_CALLBACK(on_draw), this);
        
        gtk_widget_show_all(window_);
    }
    
    void plot(const Vector& x, const Vector& y, const PlotOptions& opts) {
        // Add to plot queue
        PlotData data{x, y, opts};
        if (!hold_on_) {
            plot_data_.clear();
        }
        plot_data_.push_back(data);
        
        // Trigger redraw
        gtk_widget_queue_draw(canvas_);
    }
    
    void update() {
        // Process GTK events
        while (gtk_events_pending()) {
            gtk_main_iteration();
        }
    }
    
private:
    static gboolean on_draw(GtkWidget* widget, cairo_t* cr, gpointer data) {
        auto* window = static_cast<FigureWindow*>(data);
        window->render(cr);
        return FALSE;
    }
    
    void render(cairo_t* cr) {
        // Clear background
        cairo_set_source_rgb(cr, 1, 1, 1);
        cairo_paint(cr);
        
        // Render all plot data
        for (const auto& data : plot_data_) {
            render_line(cr, data);
        }
        
        // Render axes, labels, grid
        render_axes(cr);
    }
    
    GtkWidget* window_;
    GtkWidget* canvas_;
    std::vector<PlotData> plot_data_;
    bool hold_on_ = false;
};
```

---

## 🎨 Usage Example (Complete Workflow)

### Script: `beam_analysis.m`

```matlab
%% Beam Deflection Analysis
% Analysis of simply supported beam under point load
% Author: Engineering Team
% Date: 2025-01-23

%% Parameters
fprintf('Setting up beam parameters...\n');

L = 5;          % Length (m)
E = 200e9;      % Young's modulus (Pa) - steel
I = 8.33e-6;    % Second moment of area (m^4)
P = 10000;      % Point load (N)

fprintf('  Length: %.1f m\n', L);
fprintf('  Load: %.0f N\n', P);

%% Analytical Solution
x = linspace(0, L, 100);
a = L/2;  % Load at midpoint

% Deflection equation
delta = zeros(size(x));
for i = 1:length(x)
    if x(i) <= a
        delta(i) = (P*x(i)*(L^2 - x(i)^2 - (L-a)^2)) / (6*E*I*L);
    else
        delta(i) = (P*a*(L^2 - a^2 - (L-x(i))^2)) / (6*E*I*L);
    end
end

delta_max = max(abs(delta));
fprintf('\nMaximum deflection: %.4f mm\n', delta_max*1000);

%% Visualization
figure(1)
plot(x, delta*1000, 'b-', 'LineWidth', 2)
hold on
plot(L/2, delta_max*1000, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
grid on
xlabel('Position along beam (m)', 'FontName', 'Times New Roman', 'FontSize', 14)
ylabel('Deflection (mm)', 'FontName', 'Times New Roman', 'FontSize', 14)
title('Beam Deflection Profile', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold')
legend('Deflection', 'Maximum', 'Location', 'south')

%% Stress Distribution
sigma = zeros(size(x));
for i = 1:length(x)
    % Bending moment at x
    if x(i) <= a
        M = P*x(i)/2;
    else
        M = P*(L-x(i))/2;
    end
    % Stress at extreme fiber (h=0.1m assumed)
    c = 0.05;
    sigma(i) = M*c/I;
end

figure(2)
plot(x, sigma/1e6, 'r-', 'LineWidth', 2)
grid on
xlabel('Position along beam (m)', 'FontName', 'Times New Roman', 'FontSize', 14)
ylabel('Bending Stress (MPa)', 'FontName', 'Times New Roman', 'FontSize', 14)
title('Stress Distribution', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold')

%% Summary
fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Maximum stress: %.1f MPa\n', max(sigma)/1e6);
fprintf('Safety factor: %.1f\n', 250/max(sigma)*1e6);
```

### Generate Report:

```matlab
% In REPL or script
publish('beam_analysis.m', 'pdf');
```

**Output:** `beam_analysis.pdf` with:
1. Title "Beam Deflection Analysis"
2. Code block with syntax highlighting
3. Console output (fprintf text)
4. Figure 1 embedded (deflection plot)
5. More code
6. Figure 2 embedded (stress plot)
7. Summary section

---

## 📊 publish() Output Formats

### HTML (Default)
```matlab
publish('script.m', 'html');
```
- Self-contained HTML
- Embedded CSS
- Base64 encoded images
- Interactive (links work)

### PDF (Professional)
```matlab
publish('script.m', 'pdf');
```
- Publication quality
- Vector graphics preserved
- Page breaks at sections
- Table of contents

### LaTeX
```matlab
publish('script.m', 'latex');
```
- For journal submission
- Full LaTeX source
- EPS figures
- Bibliography support

---

## 🎨 Publish Options

```matlab
options = struct();
options.format = 'pdf';
options.outputDir = './reports';
options.showCode = true;
options.evalCode = true;
options.catchError = true;
options.maxHeight = 400;  % pixels
options.maxWidth = 600;

publish('analysis.m', options);
```

---

## 🔧 Implementation Phases

### v0.5.1 - Basic Plotting (CRITICAL) - 1 week
- Cairo backend
- Figure windows (GTK/Qt)
- plot(), hold, grid
- xlabel, ylabel, title
- legend

### v0.5.2 - publish() System - 1 week
- Parse %% cells
- Execute code cells
- Capture stdout
- Capture figures
- Generate HTML

### v0.5.3 - PDF Output - 3 days
- wkhtmltopdf integration OR
- LaTeX generation + pdflatex
- Professional formatting

### v0.5.4 - Advanced Publish - 3 days
- Syntax highlighting
- LaTeX math rendering
- Custom CSS/templates
- Image optimization

---

## 🎯 Why These Are Critical

### publish() enables:
1. **Reproducible research** - Code + results in one document
2. **Reports** - Automatic generation from analysis
3. **Documentation** - Living documents that update
4. **Collaboration** - Share complete workflows
5. **Teaching** - Lecture notes with executable code

### Figure windows enable:
1. **Exploration** - Try different visualizations
2. **Debugging** - See data immediately
3. **Interactivity** - Zoom, pan, rotate (future)
4. **Multiple views** - Compare plots side-by-side
5. **Animation** - Update plots in loop

---

## 💡 Quick Implementation Strategy

### Week 1: Figure Windows
```cpp
// Minimal implementation
class SimpleFigure {
    Cairo::ImageSurface surface(800, 600);
    
    void plot(x, y) {
        // Render to surface
    }
    
    void show() {
        // Display window (GTK/SDL/Qt)
    }
    
    void save(filename) {
        surface.write_to_png(filename);
    }
};
```

### Week 2: publish() Basic
```cpp
class Publisher {
    void publish(script) {
        auto cells = parse_cells(script);
        
        std::string html = "<html><body>";
        
        for (auto& cell : cells) {
            if (cell.type == SECTION) {
                html += "<h2>" + cell.text + "</h2>";
            }
            else if (cell.type == CODE) {
                auto output = execute(cell.code);
                html += "<pre>" + cell.code + "</pre>";
                html += "<pre>" + output.text + "</pre>";
                
                for (auto& fig : output.figures) {
                    html += "<img src='data:image/png;base64," 
                          + base64(fig) + "'/>";
                }
            }
        }
        
        html += "</body></html>";
        write_file(html);
    }
};
```

---

## 📋 Dependencies

### For Figure Windows:
- Cairo (2D graphics) ✅ Optional in current build
- GTK+ or Qt (windowing)
- OpenGL (future, 3D)

### For publish():
- Script execution ✅ v0.4.1
- Figure capture (needs v0.5.1)
- HTML generation (easy, std::string)
- PDF: wkhtmltopdf OR pandoc OR pdflatex

---

## 🚀 Immediate Action Plan

**Priority Order:**

1. **v0.4.1** (Scripts) - 2-3 hours
   - Needed for everything else

2. **v0.5.1** (Plotting) - 1 week ← **START HERE**
   - Figure windows
   - Basic plot()
   - Figure capture

3. **v0.5.2** (publish()) - 1 week
   - Cell parsing
   - Code execution
   - HTML output

4. **v0.5.3** (PDF publish) - 3 days
   - Professional reports

**Total: ~3 weeks to have both critical features working**

---

## 🎓 Example: Complete Scientific Workflow

```matlab
%% Load Data
data = load('experiment.mat');

%% Process
filtered = smooth(data.signal);

%% Analyze
[peaks, locs] = findpeaks(filtered);
frequency = 1/mean(diff(locs));

%% Visualize
figure(1)
subplot(2,1,1)
plot(data.time, data.signal)
title('Raw Signal')

subplot(2,1,2)
plot(data.time, filtered, peaks, locs, 'ro')
title('Filtered with Peaks')

%% Results
fprintf('Detected frequency: %.2f Hz\n', frequency);
fprintf('Number of peaks: %d\n', length(peaks));

%% Generate Report
publish('signal_analysis.m', 'pdf');
```

**One command** creates professional PDF with:
- All code
- All output
- Both figures
- Formatted headers

**THIS is the MATLAB experience!**

---

## 💎 Bottom Line

**These two features transform MatLabC++ from:**
- ❌ "A numerical library"
- ❌ "A MATLAB clone"

**To:**
- ✅ "A complete scientific computing environment"
- ✅ "MATLAB-level productivity"
- ✅ "Publication-ready workflow tool"

**Time Investment:** 3 weeks  
**Impact:** 🔥 **TRANSFORMATIVE** 🔥

---

**Recommendation:** 
1. Finish v0.4.1 (scripts) this week
2. Build v0.5.1 (plotting) next week
3. Add publish() week after
4. THEN we have the true MATLAB experience

**Status:** 📋 **CRITICAL PATH IDENTIFIED** ✅
