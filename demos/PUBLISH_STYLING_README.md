# Publish Styling Demo

This demo showcases the MatLabC++ `publish()` command with interactive CLI customization.

## Quick Start

### 1. Run with Default (MATLAB) Theme
```bash
mlab++ publish demos/publish_styling_demo.m
```
**Output**: `publish_styling_demo.html` with MATLAB-style light theme

### 2. Run with Dark Theme
```bash
mlab++ publish demos/publish_styling_demo.m --theme dark
```
**Output**: VS Code-style dark theme

### 3. Run with Classic MATLAB Theme
```bash
mlab++ publish demos/publish_styling_demo.m --theme classic
```
**Output**: Classic gray MATLAB theme

### 4. Custom Font
```bash
mlab++ publish demos/publish_styling_demo.m --font "Times New Roman" --fontsize 14
```
**Output**: Custom typography

---

## Available Themes

### `default` (MATLAB Default)
- **Background**: Light (#fafafa)
- **Text**: Dark (#333)
- **Code block**: Dark background (#1e1e1e) with syntax highlighting
- **Output**: White box with blue left border
- **Font**: Segoe UI, sans-serif
- **Use case**: Modern, professional reports

### `classic` (Classic MATLAB)
- **Background**: Light gray (#f5f5f5)
- **Text**: Black
- **Code block**: Light gray (#f0f0f0)
- **Output**: White box with MATLAB blue border
- **Font**: Arial, sans-serif
- **Use case**: Traditional MATLAB look-and-feel

### `dark` (VS Code Style)
- **Background**: Dark (#1e1e1e)
- **Text**: Light (#d4d4d4)
- **Code block**: Slightly lighter dark (#2d2d2d)
- **Output**: Dark gray with cyan border
- **Font**: Segoe UI, sans-serif
- **Use case**: Night mode, presentations

---

## CLI Options

```
mlab++ publish <script.m> [options]

Options:
  --theme <name>      Choose theme (default, classic, dark)
  --font <name>       Override font family
  --fontsize <px>     Override font size (default: 16)
  --help              Show styling options
```

### Examples

**Dark theme with custom font:**
```bash
mlab++ publish script.m --theme dark --font "Fira Code" --fontsize 15
```

**Classic MATLAB with larger text:**
```bash
mlab++ publish script.m --theme classic --fontsize 18
```

**Help:**
```bash
mlab++ publish --help
```

---

## Demo Sections

The `publish_styling_demo.m` demonstrates:

1. **Section headers** - From `%%` comments
2. **Code blocks** - Syntax-highlighted MATLAB code
3. **Output capture** - Console output with formatting
4. **Mathematics** - Basic computations and formulas
5. **Loops & conditionals** - Control flow examples
6. **Matrices** - Matrix operations and display
7. **Formatted tables** - Box-drawing characters preserved
8. **LaTeX-style math** - Subscripts and symbols (in comments)

---

## Output Files

After running:
```bash
mlab++ publish demos/publish_styling_demo.m
```

You'll get:
- `demos/publish_styling_demo.html` - Self-contained HTML report
- Opens in any web browser
- No external dependencies
- Embedded CSS styling
- Syntax highlighting for MATLAB keywords

---

## Comparison with MATLAB

| Feature | MATLAB `publish()` | MatLabC++ `publish()` |
|---------|-------------------|-----------------------|
| `%%` section headers | ✅ | ✅ |
| Code syntax highlighting | ✅ | ✅ |
| Output capture | ✅ | ✅ |
| HTML export | ✅ | ✅ |
| PDF export | ✅ | ⬜ (v0.6.0) |
| Theme customization | ⚠️ Limited | ✅ CLI options |
| LaTeX math | ✅ Full | ⚠️ Basic |
| Figure embedding | ✅ | ⬜ (v0.6.0) |

---

## Integration with Scripts

Your projectile motion script:
```bash
mlab++ publish demos/projectile_motion_physics.m
```

Will generate a professional HTML report with:
- 6 sections from `%%` comments
- All `fprintf` output captured
- Syntax-highlighted code blocks
- Box-drawing characters preserved
- MATLAB-style formatting by default

---

## Tips

1. **Use `%%` for sections**: Creates H2 headers in HTML
2. **Add description comments**: Lines after `%%` become section descriptions
3. **Use `fprintf` for output**: Better formatting than `disp`
4. **Box-drawing works**: Unicode characters like `╔═╗` are preserved
5. **Test themes**: Try all 3 themes to see which fits your use case

---

## Future Enhancements (v0.6.0+)

- ⬜ PDF export via LaTeX
- ⬜ Figure embedding (PNG from `plot()`)
- ⬜ Full LaTeX math rendering
- ⬜ Code folding in HTML
- ⬜ Custom CSS injection
- ⬜ Table of contents with anchors
- ⬜ Syntax themes (Monokai, Solarized, etc.)

---

## Support

Report issues: https://github.com/LMSM3/MatLabC-/issues

Documentation: `docs/PLOTTING_PUBLICATION_QUALITY.md`
