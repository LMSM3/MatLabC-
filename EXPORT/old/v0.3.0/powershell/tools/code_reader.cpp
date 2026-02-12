/*
 * Code Reader & Analyzer
 * Reads source code and provides statistics, complexity analysis
 * Compile: g++ -O2 -std=c++17 -o codereader code_reader.cpp
 */

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <filesystem>
#include <algorithm>
#include <regex>

namespace fs = std::filesystem;

struct CodeStats {
    size_t total_lines = 0;
    size_t code_lines = 0;
    size_t comment_lines = 0;
    size_t blank_lines = 0;
    size_t function_count = 0;
    size_t class_count = 0;
    size_t include_count = 0;
    std::map<std::string, size_t> keyword_freq;
};

class CodeAnalyzer {
private:
    std::string filename;
    std::string language;
    CodeStats stats;
    
    std::string detect_language(const std::string& fname) {
        std::string ext = fs::path(fname).extension().string();
        std::transform(ext.begin(), ext.end(), ext.begin(), ::tolower);
        
        if (ext == ".cpp" || ext == ".cc" || ext == ".cxx") return "C++";
        if (ext == ".c") return "C";
        if (ext == ".h" || ext == ".hpp") return "Header";
        if (ext == ".py") return "Python";
        if (ext == ".js") return "JavaScript";
        if (ext == ".sh" || ext == ".bash") return "Shell";
        if (ext == ".rs") return "Rust";
        if (ext == ".go") return "Go";
        return "Unknown";
    }
    
    bool is_comment_line(const std::string& line, const std::string& lang) {
        std::string trimmed = line;
        trimmed.erase(0, trimmed.find_first_not_of(" \t"));
        
        if (lang == "C++" || lang == "C" || lang == "JavaScript") {
            return trimmed.substr(0, 2) == "//" || 
                   trimmed.substr(0, 2) == "/*" ||
                   trimmed.find("*/") != std::string::npos;
        }
        if (lang == "Python" || lang == "Shell") {
            return trimmed[0] == '#';
        }
        return false;
    }
    
    bool is_blank_line(const std::string& line) {
        return std::all_of(line.begin(), line.end(), ::isspace);
    }
    
    void count_functions(const std::string& content) {
        // Simple heuristic: count function signatures
        std::regex func_pattern(R"(\w+\s+\w+\s*\([^)]*\)\s*[{;])");
        auto words_begin = std::sregex_iterator(content.begin(), content.end(), func_pattern);
        auto words_end = std::sregex_iterator();
        stats.function_count = std::distance(words_begin, words_end);
    }
    
    void count_classes(const std::string& content) {
        std::regex class_pattern(R"(\bclass\s+\w+)");
        auto words_begin = std::sregex_iterator(content.begin(), content.end(), class_pattern);
        auto words_end = std::sregex_iterator();
        stats.class_count = std::distance(words_begin, words_end);
    }
    
    void count_includes(const std::string& content) {
        std::regex include_pattern(R"(#include\s*[<"])");
        auto words_begin = std::sregex_iterator(content.begin(), content.end(), include_pattern);
        auto words_end = std::sregex_iterator();
        stats.include_count = std::distance(words_begin, words_end);
    }
    
    void analyze_keywords(const std::string& content) {
        std::vector<std::string> keywords = {
            "if", "else", "while", "for", "return", "switch", "case",
            "break", "continue", "const", "static", "void", "int", "double"
        };
        
        for (const auto& kw : keywords) {
            std::regex kw_pattern("\\b" + kw + "\\b");
            auto words_begin = std::sregex_iterator(content.begin(), content.end(), kw_pattern);
            auto words_end = std::sregex_iterator();
            size_t count = std::distance(words_begin, words_end);
            if (count > 0) {
                stats.keyword_freq[kw] = count;
            }
        }
    }
    
public:
    CodeAnalyzer(const std::string& fname) : filename(fname) {
        language = detect_language(fname);
    }
    
    bool analyze() {
        std::ifstream file(filename);
        if (!file) {
            std::cerr << "Error: Cannot open file: " << filename << "\n";
            return false;
        }
        
        std::string line;
        std::string full_content;
        
        while (std::getline(file, line)) {
            stats.total_lines++;
            full_content += line + "\n";
            
            if (is_blank_line(line)) {
                stats.blank_lines++;
            } else if (is_comment_line(line, language)) {
                stats.comment_lines++;
            } else {
                stats.code_lines++;
            }
        }
        
        // Advanced analysis
        count_functions(full_content);
        count_classes(full_content);
        count_includes(full_content);
        analyze_keywords(full_content);
        
        return true;
    }
    
    void print_report() {
        std::cout << "\n╔═══════════════════════════════════════════════════╗\n";
        std::cout << "║  Code Analysis Report                             ║\n";
        std::cout << "╚═══════════════════════════════════════════════════╝\n\n";
        
        std::cout << "File:     " << filename << "\n";
        std::cout << "Language: " << language << "\n";
        std::cout << "Size:     " << fs::file_size(filename) << " bytes\n";
        std::cout << "\n";
        
        std::cout << "Line Statistics:\n";
        std::cout << "  Total lines:   " << stats.total_lines << "\n";
        std::cout << "  Code lines:    " << stats.code_lines << " (" 
                  << (stats.total_lines > 0 ? 100.0 * stats.code_lines / stats.total_lines : 0)
                  << "%)\n";
        std::cout << "  Comment lines: " << stats.comment_lines << " ("
                  << (stats.total_lines > 0 ? 100.0 * stats.comment_lines / stats.total_lines : 0)
                  << "%)\n";
        std::cout << "  Blank lines:   " << stats.blank_lines << "\n";
        std::cout << "\n";
        
        std::cout << "Structure:\n";
        std::cout << "  Includes:  " << stats.include_count << "\n";
        std::cout << "  Classes:   " << stats.class_count << "\n";
        std::cout << "  Functions: " << stats.function_count << "\n";
        std::cout << "\n";
        
        if (!stats.keyword_freq.empty()) {
            std::cout << "Top Keywords:\n";
            
            std::vector<std::pair<std::string, size_t>> sorted(
                stats.keyword_freq.begin(), stats.keyword_freq.end()
            );
            std::sort(sorted.begin(), sorted.end(),
                     [](const auto& a, const auto& b) { return a.second > b.second; });
            
            for (size_t i = 0; i < std::min(size_t(10), sorted.size()); i++) {
                std::cout << "  " << sorted[i].first << ": " << sorted[i].second << "\n";
            }
        }
        
        std::cout << "\nComplexity Assessment:\n";
        size_t complexity_score = stats.keyword_freq["if"] + 
                                  stats.keyword_freq["while"] + 
                                  stats.keyword_freq["for"] * 2;
        
        if (complexity_score < 10) {
            std::cout << "  ✓ Simple (score: " << complexity_score << ")\n";
        } else if (complexity_score < 50) {
            std::cout << "  ⚠ Moderate (score: " << complexity_score << ")\n";
        } else {
            std::cout << "  ⚠️ Complex (score: " << complexity_score << ") - consider refactoring\n";
        }
    }
};

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " <source_file>\n";
        std::cout << "\nAnalyze source code and provide statistics\n";
        std::cout << "Supports: C, C++, Python, JavaScript, Shell\n";
        return 1;
    }
    
    std::string filename = argv[1];
    
    if (!fs::exists(filename)) {
        std::cerr << "Error: File not found: " << filename << "\n";
        return 1;
    }
    
    CodeAnalyzer analyzer(filename);
    
    if (analyzer.analyze()) {
        analyzer.print_report();
        return 0;
    }
    
    return 1;
}
