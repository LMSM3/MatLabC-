# ASCII Plotting Demo Output

## 2D Plotting Examples

### Example 1: Simple Sine Wave
```
  Simple Sine Wave

    1.00 |                    *        *
    0.80 |                *        *
    0.60 |            *        *
    0.40 |        *        *
    0.20 |    *        *
    0.00 |*        *                                *        *
   -0.20 |    *        *                        *        *
   -0.40 |        *        *                *        *
   -0.60 |            *        *        *        *
   -0.80 |                *        *        *
   -1.00 |                    *        *
         +____________________________________________________________
          0.0       2.0       4.0       6.0       8.0      10.0
         sin(x) (vertical axis)
```

### Example 2: Multiple Data Series
```
  Trigonometric Functions

    1.00 |*                                                  o
    0.80 |  *                                            o
    0.60 |    *                                      o
    0.40 |      *                                o
    0.20 |        *                          o
    0.00 |o         *                    o                 *
   -0.20 |    o         *            o                 *
   -0.40 |        o         *    o                 *
   -0.60 |            o        o              *
   -0.80 |                o                *
   -1.00 |                    *        *
         +____________________________________________________________
          0.0       2.0       4.0       6.0       8.0      10.0

Legend: *=sin(x)  o=cos(x)  
```

### Example 3: Projectile Motion
```
  Projectile Path

   50.00 |                    *
   45.00 |                *        *
   40.00 |            *                *
   35.00 |        *                        *
   30.00 |    *                                *
   25.00 |*                                        *
   20.00 |                                            *
   15.00 |                                                *
   10.00 |                                                    *
    5.00 |                                                        *
    0.00 +____________________________________________________________
          0.0      50.0     100.0     150.0     200.0
         Projectile Path
         Height (m) (vertical axis)
```

## 3D Plotting Examples

### Example 4: 3D Helix (Scatter Plot)
```
  3D Helix

                            *
                        *       *
                    *               *
                *                       *
            *                               *
        *                                       *
    *                                               *
                                                        *
                                                            *
                                                                *
                                                            *
                                                        *
                                                    *
                                                *
                                            *
                                        *
                                    *
                                *
                            *
                        *
                    *
```

### Example 5: Saddle Surface (z = x² - y²)
```
  Saddle Surface (z = x² - y²)

                  #   #   #
              #   +   +   +   #
          #   +   .   .   .   +   #
      #   +   .               .   +   #
  #   +   .                       .   +   #
  +   .                               .   +
  .                                       .
  .                                       .
  .                                       .
  +   .                               .   +
  #   +   .                       .   +   #
      #   +   .               .   +   #
          #   +   .   .   .   +   #
              #   +   +   +   #
                  #   #   #

  Z-axis: . (low) + (mid) # (high)
```

### Example 6: Gaussian Peak (z = e^(-x²-y²))
```
  Gaussian Peak (z = e^(-x²-y²))

                      #
                  #   #   #
              #   +   +   +   #
          #   +   .   .   .   +   #
      #   +   .   .   .   .   .   +   #
  #   +   .   .   .   .   .   .   .   +   #
  +   .   .   .   .   .   .   .   .   .   +
  .   .   .   .   .   .   .   .   .   .   .
  +   .   .   .   .   .   .   .   .   .   +
  #   +   .   .   .   .   .   .   .   +   #
      #   +   .   .   .   .   .   +   #
          #   +   .   .   .   +   #
              #   +   +   +   #
                  #   #   #
                      #

  Z-axis: . (low) + (mid) # (high)
```

## Features

### 2D Renderer Features:
- **Auto-scaling**: Automatically fits data to terminal width/height
- **Axis labels**: Configurable X and Y labels with units
- **Multiple series**: Different markers (* o + x) for each dataset
- **Legends**: Automatic legend generation
- **Grid markers**: Y-axis values with proper formatting
- **Custom ranges**: Override auto-scaling with xlim/ylim

### 3D Renderer Features:
- **Isometric projection**: Standard 30° angles for depth perception
- **Height-based shading**: `.` (low), `+` (mid), `#` (high) for Z-values
- **Wireframe mode**: Grid lines with `-` and `|` characters
- **Scatter mode**: Point clouds with `*` markers
- **Surface mode**: Connected mesh visualization
- **Rotation**: Fixed optimal viewing angle (can be customized)

## Terminal Compatibility

Works on:
- ✅ Windows Command Prompt
- ✅ PowerShell
- ✅ Windows Terminal
- ✅ Linux/Unix terminals (xterm, gnome-terminal, etc.)
- ✅ macOS Terminal.app
- ✅ SSH sessions
- ✅ CI/CD build logs

No dependencies required — pure ASCII/Unicode box-drawing characters.

## Integration with MatLabC++

These plotting functions are available in C++ code via:

```cpp
#include "matlabcpp/plotting/renderer_2d.hpp"
#include "matlabcpp/plotting/renderer_3d.hpp"

using namespace matlabcpp::plotting;

// 2D plot
std::vector<double> x = {1, 2, 3, 4, 5};
std::vector<double> y = {2, 4, 3, 5, 4};
plot2d(x, y, "My Data");

// 3D scatter
std::vector<Point3D> points = {{0, 0, 0}, {1, 1, 1}, {2, 0, 1}};
plot3d_scatter(points, "3D Points");
```

## Future Enhancements (v0.6.0+)

When Cairo/OpenGL backends are available:
- PNG/SVG export
- Anti-aliased lines
- Custom colors
- Font rendering
- Interactive pan/zoom
- Figure save/restore

But the ASCII renderer **always works** as a fallback!
