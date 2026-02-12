# Roadmap — MatLabC++

Versioned milestones for the project. Items marked ✅ are complete; ⬜ are
planned.

---

## v0.4.0 — Core Platform *(current)*

- ✅ Interactive REPL (Active Window) with workspace
- ✅ Scalar arithmetic, trig, exp/log, constants
- ✅ Vector & matrix types with basic linear algebra
- ✅ Material-property database (smart lookup)
- ✅ Package-manager framework (manifests, install)
- ✅ CMake build system with optional Cairo / OpenGL / CUDA
- ✅ Unit test harness (`ctest`)

## v0.5.0 — Script Execution

- ⬜ `.m` file tokeniser and parser
- ⬜ Variable assignment, `if`/`else`, `for`/`while` loops
- ⬜ User-defined functions (`function ... end`)
- ⬜ `fprintf`, `disp`, `sprintf` runtime builtins
- ⬜ `clear`, `close`, `clc` workspace commands in scripts

## v0.6.0 — Plotting & Visualisation

- ⬜ `plot()`, `hold on`, `xlabel`, `ylabel`, `title`, `legend`
- ⬜ `subplot`, `figure`, `grid on`
- ⬜ PNG / SVG export (`print`, `saveas`)
- ⬜ Interactive figure windows (pan, zoom)

## v0.7.0 — Numerical Methods

- ⬜ ODE solvers: `ode45`, `ode23`
- ⬜ Root finding: `fzero`, `fsolve`
- ⬜ Integration: `integral`, `trapz`
- ⬜ Interpolation: `interp1`, `spline`

## v0.8.0 — Publication & Reporting

- ⬜ `publish()` — generate PDF / HTML reports from `.m` scripts
- ⬜ LaTeX math rendering in figures
- ⬜ Section headers from `%%` comments

## v1.0.0 — Stable Release

- ⬜ Full `.m` script compatibility for common student/engineer workflows
- ⬜ Comprehensive test suite (accuracy, stress, regression)
- ⬜ Binary installers (Linux `.deb`, macOS `.dmg`, Windows `.msi`)
- ⬜ Documentation site

---

## Future Ideas

- GPU-accelerated matrix operations (CUDA / Vulkan compute)
- Symbolic math basics (`sym`, `diff`, `int`)
- Simulink-style block diagrams
- Crystallography / FEM solver packages
