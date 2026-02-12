# ═══════════════════════════════════════════════════════════════════════════════
# PDF Generation Script for MatLabC++ PowerShell Guide
# ═══════════════════════════════════════════════════════════════════════════════
#
# This script generates a professional PDF from POWERSHELL_GUIDE.md
# using various available tools (pandoc, wkhtmltopdf, or browser-based)
#
# Usage: .\Generate-PDF.ps1 [-Method pandoc|wkhtmltopdf|browser]
# ═══════════════════════════════════════════════════════════════════════════════

param(
    [ValidateSet('pandoc', 'wkhtmltopdf', 'browser', 'auto')]
    [string]$Method = 'auto',
    
    [string]$InputMarkdown = "POWERSHELL_GUIDE.md",
    
    [string]$OutputPdf = "MatLabCpp_PowerShell_Guide.pdf"
)

Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MatLabC++ PDF Generator                  ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════════════════════════

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Generate-WithPandoc {
    param([string]$Input, [string]$Output)
    
    Write-Host "Using Pandoc..." -ForegroundColor Yellow
    
    # Create temporary metadata file for better formatting
    $metadata = @"
---
title: "MatLabC++ PowerShell Integration Guide"
author: "MatLabC++ v0.3.0"
date: "$(Get-Date -Format 'MMMM yyyy')"
geometry: margin=1in
fontsize: 11pt
colorlinks: true
---
"@
    
    $tempMetadata = [System.IO.Path]::GetTempFileName()
    $metadata | Out-File -FilePath $tempMetadata -Encoding UTF8
    
    try {
        # Combine metadata with content
        $fullContent = (Get-Content $tempMetadata -Raw) + (Get-Content $Input -Raw)
        $tempInput = [System.IO.Path]::GetTempFileName() + ".md"
        $fullContent | Out-File -FilePath $tempInput -Encoding UTF8
        
        # Generate PDF with pandoc (try xelatex first, fall back to pdflatex)
        $pandocArgs = @(
            $tempInput,
            "-o", $Output,
            "--pdf-engine=xelatex",
            "--toc",
            "--toc-depth=3",
            "--number-sections",
            "--highlight-style=tango",
            "-V", "geometry:margin=1in",
            "-V", "linkcolor:blue"
        )
        
        $result = & pandoc $pandocArgs 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Trying with pdflatex..." -ForegroundColor Yellow
            $pandocArgs[3] = "--pdf-engine=pdflatex"
            $result = & pandoc $pandocArgs 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ PDF generated successfully: $Output" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Pandoc failed: $result" -ForegroundColor Red
            return $false
        }
    }
    finally {
        Remove-Item $tempMetadata -ErrorAction SilentlyContinue
        Remove-Item $tempInput -ErrorAction SilentlyContinue
    }
}

function Generate-WithWkHtmlToPdf {
    param([string]$Input, [string]$Output)
    
    Write-Host "Using wkhtmltopdf..." -ForegroundColor Yellow
    
    # First convert markdown to HTML
    $tempHtml = [System.IO.Path]::GetTempFileName() + ".html"
    
    # Simple markdown to HTML converter
    $markdown = Get-Content $Input -Raw
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MatLabC++ PowerShell Integration Guide</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        h3 { color: #7f8c8d; }
        code { background: #ecf0f1; padding: 2px 5px; border-radius: 3px; font-family: 'Courier New', monospace; }
        pre { background: #2c3e50; color: #ecf0f1; padding: 15px; border-radius: 5px; overflow-x: auto; }
        pre code { background: none; color: inherit; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #bdc3c7; padding: 10px; text-align: left; }
        th { background: #3498db; color: white; }
        .note { background: #fff3cd; border-left: 4px solid #ffc107; padding: 10px; margin: 10px 0; }
        .warning { background: #f8d7da; border-left: 4px solid #dc3545; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
"@
    
    # Very basic markdown conversion (this would need a proper markdown parser for production)
    $html += "<h1>MatLabC++ PowerShell Integration Guide</h1>"
    $html += "<p><em>Generated: $(Get-Date -Format 'yyyy-MM-dd')</em></p>"
    $html += "<hr>"
    $html += $markdown -replace '(?m)^# (.+)$', '<h1>$1</h1>' `
                      -replace '(?m)^## (.+)$', '<h2>$1</h2>' `
                      -replace '(?m)^### (.+)$', '<h3>$1</h3>' `
                      -replace '```powershell\r?\n([\s\S]*?)```', '<pre><code>$1</code></pre>' `
                      -replace '```c\r?\n([\s\S]*?)```', '<pre><code>$1</code></pre>' `
                      -replace '`([^`]+)`', '<code>$1</code>' `
                      -replace '\*\*([^*]+)\*\*', '<strong>$1</strong>' `
                      -replace '\*([^*]+)\*', '<em>$1</em>'
    
    $html += "</body></html>"
    
    $html | Out-File -FilePath $tempHtml -Encoding UTF8
    
    try {
        $wkArgs = @(
            $tempHtml,
            $Output,
            "--enable-local-file-access",
            "--print-media-type",
            "--margin-top", "20mm",
            "--margin-bottom", "20mm",
            "--margin-left", "15mm",
            "--margin-right", "15mm"
        )
        
        $result = & wkhtmltopdf $wkArgs 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ PDF generated successfully: $Output" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ wkhtmltopdf failed: $result" -ForegroundColor Red
            return $false
        }
    }
    finally {
        Remove-Item $tempHtml -ErrorAction SilentlyContinue
    }
}

function Generate-WithBrowser {
    param([string]$Input, [string]$Output)
    
    Write-Host "Using browser print-to-PDF..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual steps:" -ForegroundColor Cyan
    Write-Host "1. Convert markdown to HTML using an online tool:"
    Write-Host "   → https://markdowntohtml.com/"
    Write-Host "   → https://dillinger.io/"
    Write-Host ""
    Write-Host "2. Open the HTML file in Chrome/Edge"
    Write-Host ""
    Write-Host "3. Press Ctrl+P (Print)"
    Write-Host ""
    Write-Host "4. Select 'Save as PDF' as destination"
    Write-Host ""
    Write-Host "5. Adjust settings:"
    Write-Host "   • Layout: Portrait"
    Write-Host "   • Margins: Normal"
    Write-Host "   • Scale: 100%"
    Write-Host "   • Background graphics: On"
    Write-Host ""
    Write-Host "6. Click 'Save' and save as: $Output"
    Write-Host ""
    
    # Try to open markdown in default browser with GitHub-style viewer
    $tempHtml = [System.IO.Path]::GetTempFileName() + ".html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MatLabC++ PowerShell Guide</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.1.0/github-markdown.min.css">
    <style>
        .markdown-body { box-sizing: border-box; min-width: 200px; max-width: 980px; margin: 0 auto; padding: 45px; }
        @media (max-width: 767px) { .markdown-body { padding: 15px; } }
        @media print { .no-print { display: none; } }
    </style>
</head>
<body>
    <div class="markdown-body">
        <div class="no-print" style="background: #fff3cd; padding: 15px; margin-bottom: 20px; border-radius: 5px;">
            <strong>📄 Print to PDF:</strong> Press <kbd>Ctrl+P</kbd> and select "Save as PDF"
        </div>
        <div id="content"></div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script>
        fetch('$($Input -replace '\\', '/')')
            .then(response => response.text())
            .then(markdown => {
                document.getElementById('content').innerHTML = marked.parse(markdown);
            });
    </script>
</body>
</html>
"@
    
    $html | Out-File -FilePath $tempHtml -Encoding UTF8
    
    Write-Host "Opening preview in browser..." -ForegroundColor Yellow
    Start-Process $tempHtml
    
    Write-Host ""
    Write-Host "Note: HTML file created at: $tempHtml" -ForegroundColor Gray
    Write-Host "      Delete after generating PDF" -ForegroundColor Gray
    
    return $false  # User must complete manually
}

# ═══════════════════════════════════════════════════════════════════════════════
# Main Logic
# ═══════════════════════════════════════════════════════════════════════════════

if (-not (Test-Path $InputMarkdown)) {
    Write-Host "✗ Input file not found: $InputMarkdown" -ForegroundColor Red
    exit 1
}

$success = $false

if ($Method -eq 'auto') {
    Write-Host "Auto-detecting PDF generation tool..." -ForegroundColor Yellow
    
    if (Test-CommandExists 'pandoc') {
        $Method = 'pandoc'
    } elseif (Test-CommandExists 'wkhtmltopdf') {
        $Method = 'wkhtmltopdf'
    } else {
        $Method = 'browser'
    }
    
    Write-Host "  Selected method: $Method" -ForegroundColor Cyan
    Write-Host ""
}

switch ($Method) {
    'pandoc' {
        if (-not (Test-CommandExists 'pandoc')) {
            Write-Host "✗ Pandoc not found. Install from: https://pandoc.org/installing.html" -ForegroundColor Red
            Write-Host "  Windows: choco install pandoc" -ForegroundColor Gray
            Write-Host "  or download from: https://github.com/jgm/pandoc/releases" -ForegroundColor Gray
            exit 1
        }
        $success = Generate-WithPandoc -Input $InputMarkdown -Output $OutputPdf
    }
    
    'wkhtmltopdf' {
        if (-not (Test-CommandExists 'wkhtmltopdf')) {
            Write-Host "✗ wkhtmltopdf not found. Install from: https://wkhtmltopdf.org/downloads.html" -ForegroundColor Red
            exit 1
        }
        $success = Generate-WithWkHtmlToPdf -Input $InputMarkdown -Output $OutputPdf
    }
    
    'browser' {
        Generate-WithBrowser -Input $InputMarkdown -Output $OutputPdf
        Write-Host ""
        Write-Host "Waiting for manual PDF generation..." -ForegroundColor Yellow
        Write-Host "Press any key when done..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        if (Test-Path $OutputPdf) {
            $success = $true
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan

if ($success -and (Test-Path $OutputPdf)) {
    $fileInfo = Get-Item $OutputPdf
    Write-Host "✓ PDF Generation Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  File: $OutputPdf" -ForegroundColor White
    Write-Host "  Size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor White
    Write-Host "  Method: $Method" -ForegroundColor White
    Write-Host ""
    
    # Try to open PDF
    $openPdf = Read-Host "Open PDF now? (Y/n)"
    if ($openPdf -ne 'n' -and $openPdf -ne 'N') {
        Start-Process $OutputPdf
    }
} else {
    Write-Host "⚠ PDF not generated automatically" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternative options:" -ForegroundColor Cyan
    Write-Host "  1. Install Pandoc: choco install pandoc" -ForegroundColor White
    Write-Host "     Then run: .\Generate-PDF.ps1 -Method pandoc" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Use online converter:" -ForegroundColor White
    Write-Host "     → https://www.markdowntopdf.com/" -ForegroundColor White
    Write-Host "     → https://md2pdf.netlify.app/" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. Use VS Code extension:" -ForegroundColor White
    Write-Host "     → Markdown PDF by yzane" -ForegroundColor White
    Write-Host "     → Right-click markdown → 'Markdown PDF: Export (pdf)'" -ForegroundColor White
}

Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
