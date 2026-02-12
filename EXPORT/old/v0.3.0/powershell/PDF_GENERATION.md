# PDF Generation Guide

## Quick Start

Generate PDF documentation from the comprehensive PowerShell guide:

```powershell
cd v0.3.0/powershell
.\Generate-PDF.ps1
```

The script auto-detects available tools and generates **MatLabCpp_PowerShell_Guide.pdf**.

---

## Method 1: Pandoc (Recommended)

**Best quality**, supports LaTeX for professional formatting.

### Install Pandoc

**Windows:**
```powershell
# Using Chocolatey
choco install pandoc

# Or download installer from:
# https://github.com/jgm/pandoc/releases/latest
```

**Linux:**
```bash
sudo apt install pandoc texlive-xetex  # Ubuntu/Debian
sudo dnf install pandoc texlive-xetex  # Fedora
```

**macOS:**
```bash
brew install pandoc basictex
```

### Generate PDF

```powershell
pandoc POWERSHELL_GUIDE.md -o MatLabCpp_PowerShell_Guide.pdf `
    --pdf-engine=xelatex `
    --toc `
    --toc-depth=3 `
    --number-sections `
    --highlight-style=tango `
    -V geometry:margin=1in `
    -V linkcolor:blue
```

**Result:** Professional PDF with table of contents, syntax highlighting, and hyperlinks.

---

## Method 2: wkhtmltopdf

HTML-based rendering, good for quick previews.

### Install wkhtmltopdf

**Windows:**
```powershell
choco install wkhtmltopdf
# Or download: https://wkhtmltopdf.org/downloads.html
```

**Linux:**
```bash
sudo apt install wkhtmltopdf  # Ubuntu/Debian
```

**macOS:**
```bash
brew install wkhtmltopdf
```

### Generate PDF

```powershell
# First convert markdown to HTML (using any MD→HTML tool)
# Then:
wkhtmltopdf POWERSHELL_GUIDE.html MatLabCpp_PowerShell_Guide.pdf `
    --enable-local-file-access `
    --margin-top 20mm `
    --margin-bottom 20mm
```

---

## Method 3: VS Code (Easiest)

If you have Visual Studio Code installed:

1. **Install Extension:**
   - Open Extensions (`Ctrl+Shift+X`)
   - Search for "Markdown PDF" by yzane
   - Click Install

2. **Generate PDF:**
   - Open `POWERSHELL_GUIDE.md` in VS Code
   - Right-click in editor
   - Select **"Markdown PDF: Export (pdf)"**
   - PDF saves to same directory automatically

**Pros:** No command-line tools needed, good formatting.

---

## Method 4: Online Converters

**No installation required** - upload and convert in browser.

### Recommended Services

1. **Markdown to PDF Online**
   - URL: https://www.markdowntopdf.com/
   - Upload `POWERSHELL_GUIDE.md`
   - Click "Convert"
   - Download PDF

2. **MD2PDF**
   - URL: https://md2pdf.netlify.app/
   - Paste markdown or upload file
   - Customize styling (optional)
   - Generate and download

3. **Dillinger.io**
   - URL: https://dillinger.io/
   - Paste markdown
   - Preview on right
   - Export → PDF

**Note:** Some services may have file size limits or require login.

---

## Method 5: Browser Print

Manual but universal method (works on any system).

### Steps

1. **Install browser markdown viewer** (Chrome/Edge):
   - Extension: "Markdown Viewer"
   - Or use GitHub Gist (paste and view)

2. **Open markdown** in viewer

3. **Print to PDF:**
   - Press `Ctrl+P` (Windows) or `Cmd+P` (macOS)
   - Destination: **"Save as PDF"**
   - Settings:
     - Layout: Portrait
     - Margins: Normal (or Custom: 0.5in)
     - Scale: Shrink to fit
     - Background graphics: ✓ Enabled
   - Click **Save**

4. **Save as:** `MatLabCpp_PowerShell_Guide.pdf`

**Pros:** Works anywhere, no installation.  
**Cons:** Manual process, may need formatting adjustments.

---

## Automated Script

Use the provided PowerShell script for automatic method selection:

```powershell
# Auto-detect best available method
.\Generate-PDF.ps1

# Force specific method
.\Generate-PDF.ps1 -Method pandoc
.\Generate-PDF.ps1 -Method wkhtmltopdf
.\Generate-PDF.ps1 -Method browser

# Custom input/output
.\Generate-PDF.ps1 -InputMarkdown "README.md" -OutputPdf "MyGuide.pdf"
```

The script will:
- Check for pandoc (tries first)
- Fall back to wkhtmltopdf
- Finally offer browser-based conversion
- Open generated PDF automatically

---

## Comparison Table

| Method | Quality | Setup | Speed | Pros | Cons |
|--------|---------|-------|-------|------|------|
| **Pandoc** | ⭐⭐⭐⭐⭐ | Medium | Fast | Professional, LaTeX | Requires install |
| **wkhtmltopdf** | ⭐⭐⭐⭐ | Medium | Fast | Good HTML rendering | Requires install |
| **VS Code** | ⭐⭐⭐⭐ | Easy | Fast | One-click, no CLI | Need VS Code |
| **Online** | ⭐⭐⭐ | None | Medium | No install needed | Upload required |
| **Browser** | ⭐⭐⭐ | None | Slow | Universal | Manual process |

---

## Customization

### Add Cover Page (Pandoc)

Create `metadata.yaml`:
```yaml
---
title: "MatLabC++ PowerShell Integration"
subtitle: "Native Cmdlets for Scientific Computing"
author: "MatLabC++ v0.3.0"
date: "January 2026"
abstract: |
  Complete guide to using MatLabC++ library functions through
  native PowerShell cmdlets. Covers material database queries,
  ODE integration, matrix operations, and automation examples.
---
```

Generate with metadata:
```powershell
pandoc metadata.yaml POWERSHELL_GUIDE.md -o guide.pdf --pdf-engine=xelatex
```

### Custom Styling (wkhtmltopdf)

Create `styles.css`:
```css
body {
    font-family: 'Segoe UI', Arial, sans-serif;
    line-height: 1.6;
    color: #333;
}

h1 { color: #0078d4; border-bottom: 3px solid #0078d4; }
h2 { color: #106ebe; margin-top: 2em; }
code { background: #f5f5f5; padding: 2px 6px; border-radius: 3px; }
pre { background: #1e1e1e; color: #d4d4d4; padding: 16px; }
```

Link in HTML:
```html
<link rel="stylesheet" href="styles.css">
```

---

## Troubleshooting

### Pandoc: "pdflatex not found"

**Solution:** Install TeX distribution:
- Windows: MiKTeX or TeX Live
- Linux: `sudo apt install texlive-xetex`
- macOS: `brew install basictex`

### wkhtmltopdf: "Exit with code 1"

**Solution:** Try adding flags:
```powershell
--enable-local-file-access
--no-stop-slow-scripts
```

### Browser: Formatting issues

**Solution:** Use GitHub-style CSS:
```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.1.0/github-markdown.min.css">
```

### File size too large

**Solution:** Compress images first:
```powershell
# If guide has embedded images
Get-ChildItem *.png | ForEach-Object {
    magick convert $_ -quality 85 "compressed_$_"
}
```

---

## Output Verification

After generating PDF, verify quality:

```powershell
# Check file created
if (Test-Path "MatLabCpp_PowerShell_Guide.pdf") {
    $file = Get-Item "MatLabCpp_PowerShell_Guide.pdf"
    Write-Host "✓ PDF created: $($file.Length / 1KB) KB"
    
    # Open for review
    Start-Process $file.FullName
}
```

Expected PDF properties:
- **Size:** 300-500 KB (no images) or 1-2 MB (with screenshots)
- **Pages:** ~20-30 pages
- **Format:** US Letter (8.5" × 11") or A4
- **Features:** 
  - Table of contents (if using pandoc with --toc)
  - Syntax-highlighted code blocks
  - Clickable hyperlinks
  - Section numbering (if enabled)

---

## Next Steps

After generating PDF:

1. **Review formatting** - Check headers, code blocks, tables render correctly

2. **Test hyperlinks** - Click links to verify they work

3. **Distribute** - Share PDF with team or publish to documentation site

4. **Version control** - Add to git for versioned releases:
   ```bash
   git add MatLabCpp_PowerShell_Guide.pdf
   git commit -m "Add v0.3.0 PowerShell integration PDF guide"
   git tag v0.3.0-powershell-docs
   ```

5. **Automate** - Add to CI/CD pipeline:
   ```yaml
   # GitHub Actions example
   - name: Generate PDF
     run: |
       cd v0.3.0/powershell
       pandoc POWERSHELL_GUIDE.md -o guide.pdf --pdf-engine=xelatex
   - name: Upload artifact
     uses: actions/upload-artifact@v3
     with:
       name: powershell-guide
       path: v0.3.0/powershell/guide.pdf
   ```

---

## Resources

- **Pandoc Manual:** https://pandoc.org/MANUAL.html
- **wkhtmltopdf Documentation:** https://wkhtmltopdf.org/usage/wkhtmltopdf.txt
- **Markdown Guide:** https://www.markdownguide.org/
- **LaTeX Distributions:**
  - MiKTeX (Windows): https://miktex.org/
  - TeX Live (Cross-platform): https://www.tug.org/texlive/
  - BasicTeX (macOS): https://www.tug.org/mactex/morepackages.html

---

**Generated:** January 2026  
**Version:** MatLabC++ v0.3.0 PowerShell Integration  
**License:** MIT (same as MatLabC++)
