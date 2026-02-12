# Roadmap — MatLabC++

Versioned milestones for the project. Items marked ✅ are complete; ⬜ are
planned.

---

## v0.4.0 — Core Platform

- ✅ Interactive REPL (Active Window) with workspace
- ✅ Scalar arithmetic, trig, exp/log, constants
- ✅ Vector & matrix types with basic linear algebra
- ✅ Material-property database (smart lookup)
- ✅ Package-manager framework (manifests, install, dependency resolver)
- ✅ CMake build system with optional Cairo / OpenGL / CUDA
- ✅ Unit test harness (`ctest`)
- ✅ 2-D plotting (ASCII renderer, plot specs, style presets)
- ✅ 3-D plotting (ASCII isometric projection, scatter, surface)

## v0.5.0 — Script Execution & Publishing *(current)*

- ✅ `.m` file lexer with full token set
- ✅ Variable assignment, `if`/`elseif`/`else`/`end` control flow
- ✅ `for`/`while` loops with range parsing
- ✅ Line continuation (`...`), inline comments
- ✅ Script runner integrated with ActiveWindow evaluation
- ✅ `mlab++ script.m` command-line execution
- ✅ `publish()` — HTML report generation from `.m` scripts
- ✅ Syntax-highlighted code blocks in reports
- ✅ Section headers from `%%` comments, table of contents
- ✅ Output capture per code block
- ✅ ComplexTensor with CPU implementation (all operations)
- ✅ GPU CUDA kernels (add, sub, mul, div, conj, transpose, matmul, FFT)
- ✅ CPU fallback when CUDA unavailable
- ✅ LU, QR, SVD, eigenvalue decompositions
- ✅ FFT / IFFT / FFT2 (Cooley-Tukey on CPU, cuFFT on GPU)

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

## v0.8.0 — Advanced Features

- ⬜ User-defined functions (`function ... end`)
- ⬜ `fprintf`, `sprintf` format-string builtins
- ⬜ LaTeX math rendering in published figures
- ⬜ PDF report output from `publish()`

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
