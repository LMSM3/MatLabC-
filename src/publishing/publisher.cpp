// MatLabC++ publish() - Generate reports from .m scripts
// src/publishing/publisher.cpp
//
// MATLAB-compatible publish() that generates HTML reports from .m scripts.
// Parses %% section headers, captures code blocks and console output,
// and produces a self-contained HTML document.

#include "matlabcpp/active_window.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <filesystem>
#include <chrono>
#include <iomanip>
#include <regex>

namespace matlabcpp {
namespace publishing {

// ========== DOCUMENT STRUCTURE ==========

struct CodeBlock {
    std::string code;
    std::string output;
};

struct Section {
    std::string title;
    std::string description;      // % comment lines after %%
    std::vector<CodeBlock> blocks;
};

struct Document {
    std::string title;
    std::string source_file;
    std::string date;
    std::vector<Section> sections;
};

// ========== PARSER ==========

static std::string trim(const std::string& str) {
    size_t start = str.find_first_not_of(" \t\r\n");
    if (start == std::string::npos) return "";
    size_t end = str.find_last_not_of(" \t\r\n");
    return str.substr(start, end - start + 1);
}

static std::string html_escape(const std::string& text) {
    std::string result;
    result.reserve(text.size());
    for (char c : text) {
        switch (c) {
            case '<': result += "&lt;"; break;
            case '>': result += "&gt;"; break;
            case '&': result += "&amp;"; break;
            case '"': result += "&quot;"; break;
            default:  result += c;
        }
    }
    return result;
}

Document parse_script(const std::string& path) {
    Document doc;
    doc.source_file = path;
    
    // Date
    auto now = std::chrono::system_clock::now();
    auto t = std::chrono::system_clock::to_time_t(now);
    std::ostringstream date_ss;
    date_ss << std::put_time(std::localtime(&t), "%Y-%m-%d %H:%M");
    doc.date = date_ss.str();
    
    // Read file
    std::ifstream file(path);
    if (!file.is_open()) {
        throw std::runtime_error("Cannot open: " + path);
    }
    
    std::vector<std::string> lines;
    std::string line;
    while (std::getline(file, line)) {
        lines.push_back(line);
    }
    file.close();
    
    // Extract title from first comment line
    if (!lines.empty() && lines[0].size() > 1 && lines[0][0] == '%') {
        doc.title = trim(lines[0].substr(1));
        // Remove trailing extensions
        auto dot_pos = doc.title.find(".M");
        if (dot_pos != std::string::npos) {
            doc.title = trim(doc.title.substr(0, dot_pos));
        }
    } else {
        doc.title = std::filesystem::path(path).stem().string();
    }
    
    // Parse into sections
    Section current_section;
    current_section.title = doc.title;
    CodeBlock current_block;
    bool in_header_comments = true;
    bool collecting_description = false;
    
    for (size_t i = 0; i < lines.size(); i++) {
        const std::string& raw = lines[i];
        std::string trimmed = trim(raw);
        
        // Section header: %%
        if (trimmed.size() >= 2 && trimmed[0] == '%' && trimmed[1] == '%') {
            // Save previous block
            if (!current_block.code.empty()) {
                current_section.blocks.push_back(current_block);
                current_block = CodeBlock();
            }
            
            // Save previous section
            if (!current_section.title.empty() || !current_section.blocks.empty()) {
                doc.sections.push_back(current_section);
            }
            
            // Start new section
            current_section = Section();
            current_section.title = trim(trimmed.substr(2));
            collecting_description = true;
            in_header_comments = false;
            continue;
        }
        
        // Description lines (% after %%)
        if (collecting_description && !trimmed.empty() && trimmed[0] == '%' && trimmed[1] != '%') {
            current_section.description += trim(trimmed.substr(1)) + "\n";
            continue;
        }
        collecting_description = false;
        
        // Skip pure header comments at top of file
        if (in_header_comments && !trimmed.empty() && trimmed[0] == '%') {
            continue;
        }
        in_header_comments = false;
        
        // Empty lines
        if (trimmed.empty()) {
            if (!current_block.code.empty()) {
                current_block.code += "\n";
            }
            continue;
        }
        
        // Code line
        current_block.code += raw + "\n";
    }
    
    // Save final block and section
    if (!current_block.code.empty()) {
        current_section.blocks.push_back(current_block);
    }
    if (!current_section.title.empty() || !current_section.blocks.empty()) {
        doc.sections.push_back(current_section);
    }
    
    return doc;
}

// ========== OUTPUT CAPTURE ==========

void execute_and_capture(Document& doc, ActiveWindow& window) {
    for (auto& section : doc.sections) {
        for (auto& block : section.blocks) {
            // Redirect stdout to capture output
            std::ostringstream captured;
            auto* old_buf = std::cout.rdbuf(captured.rdbuf());
            
            // Execute each line
            std::istringstream code_stream(block.code);
            std::string line;
            while (std::getline(code_stream, line)) {
                std::string trimmed = trim(line);
                if (trimmed.empty() || trimmed[0] == '%') continue;
                
                try {
                    window.process_command_external(trimmed);
                } catch (const std::exception& e) {
                    captured << "Error: " << e.what() << "\n";
                }
            }
            
            // Restore stdout
            std::cout.rdbuf(old_buf);
            block.output = captured.str();
        }
    }
}

// ========== HTML GENERATOR ==========

std::string generate_html(const Document& doc) {
    std::ostringstream html;
    
    html << R"(<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>)" << html_escape(doc.title) << R"(</title>
<style>
  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    max-width: 900px;
    margin: 0 auto;
    padding: 40px 20px;
    background: #fafafa;
    color: #333;
    line-height: 1.6;
  }
  h1 {
    color: #1a1a2e;
    border-bottom: 3px solid #16213e;
    padding-bottom: 10px;
  }
  h2 {
    color: #16213e;
    margin-top: 40px;
    border-bottom: 1px solid #ddd;
    padding-bottom: 6px;
  }
  .meta {
    color: #777;
    font-size: 0.9em;
    margin-bottom: 30px;
  }
  .description {
    color: #555;
    font-style: italic;
    margin-bottom: 16px;
  }
  .code-block {
    background: #1e1e1e;
    color: #d4d4d4;
    padding: 16px 20px;
    border-radius: 6px;
    font-family: 'Cascadia Code', 'Fira Code', 'Consolas', monospace;
    font-size: 0.9em;
    overflow-x: auto;
    margin: 12px 0;
    white-space: pre;
  }
  .output-block {
    background: #fff;
    border-left: 4px solid #0078d4;
    padding: 12px 16px;
    font-family: 'Consolas', monospace;
    font-size: 0.85em;
    color: #333;
    margin: 8px 0 20px 0;
    white-space: pre-wrap;
    overflow-x: auto;
  }
  .section { margin-bottom: 32px; }
  .keyword { color: #569cd6; }
  .comment { color: #6a9955; }
  .string  { color: #ce9178; }
  .number  { color: #b5cea8; }
  .func    { color: #dcdcaa; }
  footer {
    margin-top: 60px;
    padding-top: 20px;
    border-top: 1px solid #ddd;
    color: #999;
    font-size: 0.8em;
    text-align: center;
  }
</style>
</head>
<body>
)";
    
    // Title
    html << "<h1>" << html_escape(doc.title) << "</h1>\n";
    html << "<div class=\"meta\">Source: <code>" << html_escape(doc.source_file) 
         << "</code> &nbsp;|&nbsp; Published: " << html_escape(doc.date) 
         << " &nbsp;|&nbsp; Generated by MatLabC++ publish()</div>\n\n";
    
    // Table of contents
    if (doc.sections.size() > 2) {
        html << "<h2>Contents</h2>\n<ul>\n";
        int sec_num = 0;
        for (const auto& section : doc.sections) {
            if (!section.title.empty()) {
                html << "  <li><a href=\"#section-" << sec_num << "\">" 
                     << html_escape(section.title) << "</a></li>\n";
            }
            sec_num++;
        }
        html << "</ul>\n\n";
    }
    
    // Sections
    int sec_num = 0;
    for (const auto& section : doc.sections) {
        html << "<div class=\"section\" id=\"section-" << sec_num << "\">\n";
        
        if (!section.title.empty()) {
            html << "<h2>" << html_escape(section.title) << "</h2>\n";
        }
        
        if (!section.description.empty()) {
            html << "<div class=\"description\">" << html_escape(section.description) << "</div>\n";
        }
        
        for (const auto& block : section.blocks) {
            if (!block.code.empty()) {
                // Syntax-highlight the code
                html << "<div class=\"code-block\">";
                std::string code = html_escape(block.code);
                
                // Simple keyword highlighting via regex replacement
                // Comments
                std::string highlighted = std::regex_replace(code, 
                    std::regex("(%[^\n]*)"), "<span class=\"comment\">$1</span>");
                // Strings
                highlighted = std::regex_replace(highlighted,
                    std::regex("(&apos;[^&]*&apos;)"), "<span class=\"string\">$1</span>");
                // Numbers
                highlighted = std::regex_replace(highlighted,
                    std::regex("\\b(\\d+\\.?\\d*(?:e[+-]?\\d+)?)\\b"), "<span class=\"number\">$1</span>");
                // Keywords
                for (const auto& kw : {"for", "end", "if", "else", "elseif", "while", 
                                        "function", "return", "break", "continue",
                                        "clear", "close", "clc"}) {
                    std::string pattern = "\\b(" + std::string(kw) + ")\\b";
                    highlighted = std::regex_replace(highlighted, std::regex(pattern), 
                                                     "<span class=\"keyword\">$1</span>");
                }
                // Known functions
                for (const auto& fn : {"fprintf", "sprintf", "disp", "plot", "subplot",
                                        "xlabel", "ylabel", "title", "legend", "grid",
                                        "figure", "hold", "set", "zeros", "ones",
                                        "linspace", "sqrt", "sin", "cos", "pi",
                                        "max", "min", "abs", "find", "length"}) {
                    std::string pattern = "\\b(" + std::string(fn) + ")\\b";
                    highlighted = std::regex_replace(highlighted, std::regex(pattern),
                                                     "<span class=\"func\">$1</span>");
                }
                
                html << highlighted;
                html << "</div>\n";
            }
            
            if (!block.output.empty()) {
                html << "<div class=\"output-block\">" 
                     << html_escape(block.output) << "</div>\n";
            }
        }
        
        html << "</div>\n\n";
        sec_num++;
    }
    
    // Footer
    html << R"(<footer>
  Generated by <strong>MatLabC++ publish()</strong> &mdash; 
  Free MATLAB alternative &mdash; 
  <a href="https://github.com/LMSM3/MatLabC-">github.com/LMSM3/MatLabC-</a>
</footer>
</body>
</html>
)";
    
    return html.str();
}

// ========== PUBLIC API ==========

int publish(const std::string& script_path, const std::string& format) {
    std::cout << "╔══════════════════════════════════════════════╗\n";
    std::cout << "║         MatLabC++ publish()                  ║\n";
    std::cout << "╚══════════════════════════════════════════════╝\n\n";
    
    std::cout << "  Source:  " << script_path << "\n";
    std::cout << "  Format:  " << format << "\n\n";
    
    try {
        // Parse script into document structure
        std::cout << "  Parsing script...\n";
        Document doc = parse_script(script_path);
        std::cout << "  Found " << doc.sections.size() << " sections\n";
        
        // Execute code and capture output
        std::cout << "  Executing code blocks...\n";
        ActiveWindow window;
        window.set_fancy_mode(false);
        window.set_echo(false);
        execute_and_capture(doc, window);
        
        // Generate output
        std::string output;
        std::string extension;
        
        if (format == "html") {
            std::cout << "  Generating HTML...\n";
            output = generate_html(doc);
            extension = ".html";
        } else {
            std::cerr << "  Unsupported format: " << format << " (supported: html)\n";
            return 1;
        }
        
        // Write output file
        std::string output_path = std::filesystem::path(script_path)
                                      .replace_extension(extension).string();
        
        std::ofstream out_file(output_path);
        if (!out_file.is_open()) {
            std::cerr << "  Error: Cannot write to " << output_path << "\n";
            return 1;
        }
        out_file << output;
        out_file.close();
        
        std::cout << "\n  ✓ Published: " << output_path << "\n";
        std::cout << "    Size: " << output.size() << " bytes\n";
        std::cout << "    Sections: " << doc.sections.size() << "\n\n";
        
        return 0;
        
    } catch (const std::exception& e) {
        std::cerr << "  Error: " << e.what() << "\n";
        return 1;
    }
}

} // namespace publishing
} // namespace matlabcpp
