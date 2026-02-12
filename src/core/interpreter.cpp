// MatLabC++ .m Script Interpreter
// src/core/interpreter.cpp
//
// Tokenizes and executes .m files line-by-line, supporting:
//   - Variable assignment (scalars, vectors, matrices)
//   - Arithmetic expressions with operator precedence
//   - for/while loops, if/elseif/else/end control flow
//   - Built-in functions (sin, cos, sqrt, fprintf, disp, ...)
//   - %% section comments, % line comments
//   - Semicolon output suppression

#include "matlabcpp/active_window.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <unordered_map>
#include <functional>
#include <cmath>
#include <algorithm>
#include <regex>
#include <stack>
#include <memory>
#include <stdexcept>
#include <iomanip>
#include <chrono>

namespace matlabcpp {
namespace interpreter {

// ========== TOKEN TYPES ==========

enum class TokenType {
    Number, String, Identifier, Operator, Assign,
    LParen, RParen, LBracket, RBracket,
    Semicolon, Comma, Colon, Dot, Newline,
    Keyword_if, Keyword_elseif, Keyword_else, Keyword_end,
    Keyword_for, Keyword_while, Keyword_break, Keyword_continue,
    Keyword_function, Keyword_return,
    Keyword_clear, Keyword_clc, Keyword_close,
    Comment, SectionComment,
    EndOfFile
};

struct Token {
    TokenType type;
    std::string value;
    int line;
    int col;
};

// ========== LEXER ==========

class Lexer {
    std::string source_;
    size_t pos_ = 0;
    int line_ = 1;
    int col_ = 1;

    static const std::unordered_map<std::string, TokenType> keywords_;

public:
    explicit Lexer(const std::string& source) : source_(source) {}

    std::vector<Token> tokenize() {
        std::vector<Token> tokens;

        while (pos_ < source_.size()) {
            skip_whitespace_no_newline();
            if (pos_ >= source_.size()) break;

            char c = source_[pos_];

            // Newline
            if (c == '\n') {
                tokens.push_back({TokenType::Newline, "\\n", line_, col_});
                advance();
                continue;
            }

            // Section comment %%
            if (c == '%' && pos_ + 1 < source_.size() && source_[pos_ + 1] == '%') {
                std::string comment = read_to_eol();
                tokens.push_back({TokenType::SectionComment, comment, line_, col_});
                continue;
            }

            // Line comment %
            if (c == '%') {
                std::string comment = read_to_eol();
                tokens.push_back({TokenType::Comment, comment, line_, col_});
                continue;
            }

            // String literal
            if (c == '\'') {
                tokens.push_back(read_string());
                continue;
            }

            // Number
            if (std::isdigit(c) || (c == '.' && pos_ + 1 < source_.size() && std::isdigit(source_[pos_ + 1]))) {
                tokens.push_back(read_number());
                continue;
            }

            // Identifier or keyword
            if (std::isalpha(c) || c == '_') {
                tokens.push_back(read_identifier());
                continue;
            }

            // Line continuation ...
            if (c == '.' && pos_ + 2 < source_.size() && 
                source_[pos_ + 1] == '.' && source_[pos_ + 2] == '.') {
                pos_ += 3;
                read_to_eol();  // skip rest of line
                continue;
            }

            // Operators and punctuation
            int start_col = col_;
            switch (c) {
                case '=':
                    if (peek() == '=') { advance(); advance(); tokens.push_back({TokenType::Operator, "==", line_, start_col}); }
                    else { advance(); tokens.push_back({TokenType::Assign, "=", line_, start_col}); }
                    break;
                case '+': advance(); tokens.push_back({TokenType::Operator, "+", line_, start_col}); break;
                case '-': advance(); tokens.push_back({TokenType::Operator, "-", line_, start_col}); break;
                case '*': advance(); tokens.push_back({TokenType::Operator, "*", line_, start_col}); break;
                case '/': advance(); tokens.push_back({TokenType::Operator, "/", line_, start_col}); break;
                case '^': advance(); tokens.push_back({TokenType::Operator, "^", line_, start_col}); break;
                case '<':
                    if (peek() == '=') { advance(); advance(); tokens.push_back({TokenType::Operator, "<=", line_, start_col}); }
                    else { advance(); tokens.push_back({TokenType::Operator, "<", line_, start_col}); }
                    break;
                case '>':
                    if (peek() == '=') { advance(); advance(); tokens.push_back({TokenType::Operator, ">=", line_, start_col}); }
                    else { advance(); tokens.push_back({TokenType::Operator, ">", line_, start_col}); }
                    break;
                case '~':
                    if (peek() == '=') { advance(); advance(); tokens.push_back({TokenType::Operator, "~=", line_, start_col}); }
                    else { advance(); tokens.push_back({TokenType::Operator, "~", line_, start_col}); }
                    break;
                case '&':
                    if (peek() == '&') { advance(); advance(); tokens.push_back({TokenType::Operator, "&&", line_, start_col}); }
                    else { advance(); tokens.push_back({TokenType::Operator, "&", line_, start_col}); }
                    break;
                case '|':
                    if (peek() == '|') { advance(); advance(); tokens.push_back({TokenType::Operator, "||", line_, start_col}); }
                    else { advance(); tokens.push_back({TokenType::Operator, "|", line_, start_col}); }
                    break;
                case '.':
                    if (peek() == '*') { advance(); advance(); tokens.push_back({TokenType::Operator, ".*", line_, start_col}); }
                    else if (peek() == '/') { advance(); advance(); tokens.push_back({TokenType::Operator, "./", line_, start_col}); }
                    else if (peek() == '^') { advance(); advance(); tokens.push_back({TokenType::Operator, ".^", line_, start_col}); }
                    else if (peek() == '\'') { advance(); advance(); tokens.push_back({TokenType::Operator, ".'", line_, start_col}); }
                    else { advance(); tokens.push_back({TokenType::Dot, ".", line_, start_col}); }
                    break;
                case '(': advance(); tokens.push_back({TokenType::LParen, "(", line_, start_col}); break;
                case ')': advance(); tokens.push_back({TokenType::RParen, ")", line_, start_col}); break;
                case '[': advance(); tokens.push_back({TokenType::LBracket, "[", line_, start_col}); break;
                case ']': advance(); tokens.push_back({TokenType::RBracket, "]", line_, start_col}); break;
                case ';': advance(); tokens.push_back({TokenType::Semicolon, ";", line_, start_col}); break;
                case ',': advance(); tokens.push_back({TokenType::Comma, ",", line_, start_col}); break;
                case ':': advance(); tokens.push_back({TokenType::Colon, ":", line_, start_col}); break;
                default:
                    advance();
                    break;
            }
        }

        tokens.push_back({TokenType::EndOfFile, "", line_, col_});
        return tokens;
    }

private:
    char peek() const {
        return (pos_ + 1 < source_.size()) ? source_[pos_ + 1] : '\0';
    }

    void advance() {
        if (source_[pos_] == '\n') { line_++; col_ = 1; }
        else { col_++; }
        pos_++;
    }

    void skip_whitespace_no_newline() {
        while (pos_ < source_.size() && (source_[pos_] == ' ' || source_[pos_] == '\t' || source_[pos_] == '\r')) {
            advance();
        }
    }

    std::string read_to_eol() {
        std::string result;
        while (pos_ < source_.size() && source_[pos_] != '\n') {
            result += source_[pos_];
            advance();
        }
        return result;
    }

    Token read_number() {
        std::string num;
        int start_col = col_;
        while (pos_ < source_.size() && (std::isdigit(source_[pos_]) || source_[pos_] == '.')) {
            num += source_[pos_]; advance();
        }
        // Scientific notation
        if (pos_ < source_.size() && (source_[pos_] == 'e' || source_[pos_] == 'E')) {
            num += source_[pos_]; advance();
            if (pos_ < source_.size() && (source_[pos_] == '+' || source_[pos_] == '-')) {
                num += source_[pos_]; advance();
            }
            while (pos_ < source_.size() && std::isdigit(source_[pos_])) {
                num += source_[pos_]; advance();
            }
        }
        return {TokenType::Number, num, line_, start_col};
    }

    Token read_string() {
        std::string str;
        int start_col = col_;
        advance(); // skip opening '
        while (pos_ < source_.size() && source_[pos_] != '\'') {
            str += source_[pos_]; advance();
        }
        if (pos_ < source_.size()) advance(); // skip closing '
        return {TokenType::String, str, line_, start_col};
    }

    Token read_identifier() {
        std::string id;
        int start_col = col_;
        while (pos_ < source_.size() && (std::isalnum(source_[pos_]) || source_[pos_] == '_')) {
            id += source_[pos_]; advance();
        }
        // Check keywords
        auto it = keywords_.find(id);
        if (it != keywords_.end()) {
            return {it->second, id, line_, start_col};
        }
        return {TokenType::Identifier, id, line_, start_col};
    }
};

const std::unordered_map<std::string, TokenType> Lexer::keywords_ = {
    {"if", TokenType::Keyword_if}, {"elseif", TokenType::Keyword_elseif},
    {"else", TokenType::Keyword_else}, {"end", TokenType::Keyword_end},
    {"for", TokenType::Keyword_for}, {"while", TokenType::Keyword_while},
    {"break", TokenType::Keyword_break}, {"continue", TokenType::Keyword_continue},
    {"function", TokenType::Keyword_function}, {"return", TokenType::Keyword_return},
    {"clear", TokenType::Keyword_clear}, {"clc", TokenType::Keyword_clc},
    {"close", TokenType::Keyword_close}
};

// ========== SCRIPT RUNNER ==========

class ScriptRunner {
    ActiveWindow& window_;
    std::string script_path_;
    std::vector<std::string> lines_;
    std::unordered_map<std::string, double> variables_;
    std::ostringstream captured_output_;
    std::vector<std::string> section_titles_;
    bool verbose_ = true;

public:
    ScriptRunner(ActiveWindow& window, const std::string& path)
        : window_(window), script_path_(path) {}

    struct RunResult {
        bool success;
        std::string output;
        std::vector<std::string> errors;
        std::vector<std::string> sections;
        double elapsed_seconds;
    };

    RunResult execute() {
        RunResult result;
        result.success = false;

        // Load script
        std::ifstream file(script_path_);
        if (!file.is_open()) {
            result.errors.push_back("Failed to open: " + script_path_);
            return result;
        }

        std::string content((std::istreambuf_iterator<char>(file)),
                            std::istreambuf_iterator<char>());
        file.close();

        // Split into lines
        std::istringstream stream(content);
        std::string line;
        while (std::getline(stream, line)) {
            lines_.push_back(line);
        }

        if (verbose_) {
            std::cout << "Running script: " << script_path_ << "\n";
            std::cout << "Lines: " << lines_.size() << "\n\n";
        }

        auto start_time = std::chrono::high_resolution_clock::now();

        // Execute line by line
        size_t i = 0;
        while (i < lines_.size()) {
            try {
                i = execute_line(i, result);
            } catch (const std::exception& e) {
                result.errors.push_back("Line " + std::to_string(i + 1) + ": " + e.what());
                if (verbose_) {
                    std::cerr << "Error at line " << (i + 1) << ": " << e.what() << "\n";
                }
                i++;
            }
        }

        auto end_time = std::chrono::high_resolution_clock::now();
        result.elapsed_seconds = std::chrono::duration<double>(end_time - start_time).count();
        result.output = captured_output_.str();
        result.sections = section_titles_;
        result.success = result.errors.empty();

        if (verbose_) {
            std::cout << "\nScript completed in " << std::fixed << std::setprecision(3)
                      << result.elapsed_seconds << " s";
            if (!result.errors.empty()) {
                std::cout << " with " << result.errors.size() << " error(s)";
            }
            std::cout << "\n";
        }

        return result;
    }

    const std::vector<std::string>& get_lines() const { return lines_; }
    const std::vector<std::string>& get_sections() const { return section_titles_; }

private:
    size_t execute_line(size_t idx, RunResult& result) {
        const std::string& raw_line = lines_[idx];
        std::string line = trim(raw_line);

        // Empty line
        if (line.empty()) return idx + 1;

        // Section comment %%
        if (line.size() >= 2 && line[0] == '%' && line[1] == '%') {
            std::string title = trim(line.substr(2));
            section_titles_.push_back(title);
            if (verbose_ && !title.empty()) {
                std::cout << "\n── " << title << " ──\n";
            }
            return idx + 1;
        }

        // Line comment %
        if (line[0] == '%') return idx + 1;

        // Strip inline comment
        size_t comment_pos = line.find('%');
        if (comment_pos != std::string::npos) {
            // Make sure it's not inside a string
            bool in_string = false;
            for (size_t j = 0; j < comment_pos; j++) {
                if (line[j] == '\'') in_string = !in_string;
            }
            if (!in_string) {
                line = trim(line.substr(0, comment_pos));
            }
        }

        if (line.empty()) return idx + 1;

        // Handle line continuation ...
        while (line.size() >= 3 && line.substr(line.size() - 3) == "...") {
            line = line.substr(0, line.size() - 3);
            idx++;
            if (idx < lines_.size()) {
                line += " " + trim(lines_[idx]);
            }
        }

        // Control flow: for
        if (line.substr(0, 4) == "for " || line.substr(0, 4) == "for(") {
            return execute_for(idx, result);
        }

        // Control flow: while
        if (line.substr(0, 6) == "while " || line.substr(0, 6) == "while(") {
            return execute_while(idx, result);
        }

        // Control flow: if
        if (line.substr(0, 3) == "if " || line.substr(0, 3) == "if(") {
            return execute_if(idx, result);
        }

        // Special: clear all, close all, clc
        if (line == "clear all" || line == "clear" || 
            line == "close all" || line == "close" || line == "clc") {
            // Feed to active window
            window_.process_command_external(line);
            return idx + 1;
        }

        // Feed line to ActiveWindow evaluation
        window_.process_command_external(line);
        return idx + 1;
    }

    size_t execute_for(size_t start_idx, RunResult& result) {
        // Parse: for var = start:step:end  or  for var = start:end
        std::string header = trim(lines_[start_idx]);

        // Collect body until matching 'end'
        std::vector<std::string> body;
        size_t end_idx = find_matching_end(start_idx + 1);
        for (size_t i = start_idx + 1; i < end_idx; i++) {
            body.push_back(lines_[i]);
        }

        // Parse loop variable and range from header
        // "for i = 1:10" or "for i = 1:0.5:10"
        std::string after_for = trim(header.substr(3));
        size_t eq_pos = after_for.find('=');
        if (eq_pos == std::string::npos) {
            throw std::runtime_error("Invalid for loop syntax");
        }

        std::string var_name = trim(after_for.substr(0, eq_pos));
        std::string range_str = trim(after_for.substr(eq_pos + 1));

        // Parse range: start:end or start:step:end
        std::vector<double> range_vals;
        std::istringstream rss(range_str);
        std::string part;
        while (std::getline(rss, part, ':')) {
            range_vals.push_back(std::stod(trim(part)));
        }

        double loop_start, loop_step, loop_end;
        if (range_vals.size() == 2) {
            loop_start = range_vals[0]; loop_step = 1.0; loop_end = range_vals[1];
        } else if (range_vals.size() == 3) {
            loop_start = range_vals[0]; loop_step = range_vals[1]; loop_end = range_vals[2];
        } else {
            throw std::runtime_error("Invalid range in for loop");
        }

        // Execute loop body
        for (double val = loop_start; 
             (loop_step > 0 ? val <= loop_end : val >= loop_end); 
             val += loop_step) {
            // Set loop variable
            std::string assign_cmd = var_name + " = " + std::to_string(val) + ";";
            window_.process_command_external(assign_cmd);

            // Execute body lines
            for (const auto& body_line : body) {
                std::string bl = trim(body_line);
                if (!bl.empty() && bl[0] != '%') {
                    window_.process_command_external(bl);
                }
            }
        }

        return end_idx + 1;
    }

    size_t execute_while(size_t start_idx, RunResult& result) {
        std::string header = trim(lines_[start_idx]);

        // Collect body
        size_t end_idx = find_matching_end(start_idx + 1);
        std::vector<std::string> body;
        for (size_t i = start_idx + 1; i < end_idx; i++) {
            body.push_back(lines_[i]);
        }

        // Parse condition
        std::string condition = trim(header.substr(5));

        // Execute while condition is true (with safety limit)
        int max_iterations = 100000;
        int iter = 0;
        while (iter++ < max_iterations) {
            // Evaluate condition via window
            if (!evaluate_condition(condition)) break;

            for (const auto& body_line : body) {
                std::string bl = trim(body_line);
                if (!bl.empty() && bl[0] != '%') {
                    window_.process_command_external(bl);
                }
            }
        }

        return end_idx + 1;
    }

    size_t execute_if(size_t start_idx, RunResult& result) {
        std::string header = trim(lines_[start_idx]);
        size_t end_idx = find_matching_end(start_idx + 1);

        // Collect all branches (if / elseif / else)
        struct Branch {
            std::string condition;  // empty for 'else'
            std::vector<std::string> body;
        };

        std::vector<Branch> branches;
        Branch current;
        current.condition = trim(header.substr(2));  // after "if"

        for (size_t i = start_idx + 1; i < end_idx; i++) {
            std::string line = trim(lines_[i]);
            if (line.substr(0, 6) == "elseif") {
                branches.push_back(current);
                current = Branch();
                current.condition = trim(line.substr(6));
            } else if (line == "else") {
                branches.push_back(current);
                current = Branch();
                current.condition = "";  // else branch
            } else {
                current.body.push_back(lines_[i]);
            }
        }
        branches.push_back(current);

        // Evaluate branches
        for (const auto& branch : branches) {
            bool should_run = branch.condition.empty() || evaluate_condition(branch.condition);
            if (should_run) {
                for (const auto& body_line : branch.body) {
                    std::string bl = trim(body_line);
                    if (!bl.empty() && bl[0] != '%') {
                        window_.process_command_external(bl);
                    }
                }
                break;
            }
        }

        return end_idx + 1;
    }

    size_t find_matching_end(size_t start) {
        int depth = 1;
        for (size_t i = start; i < lines_.size(); i++) {
            std::string line = trim(lines_[i]);
            // Count nested blocks
            if (line.substr(0, 4) == "for " || line.substr(0, 6) == "while " ||
                line.substr(0, 3) == "if " || line.substr(0, 3) == "if(") {
                depth++;
            }
            if (line == "end" || line == "end;" || line.substr(0, 4) == "end ") {
                depth--;
                if (depth == 0) return i;
            }
        }
        throw std::runtime_error("Missing 'end' for control block starting near line " + std::to_string(start));
    }

    bool evaluate_condition(const std::string& condition) {
        // Evaluate condition by assigning to temp and checking
        try {
            std::string cmd = "__cond_tmp__ = (" + condition + ");";
            window_.process_command_external(cmd);
            // Read the result back - non-zero means true
            return window_.get_scalar("__cond_tmp__") != 0.0;
        } catch (...) {
            return false;
        }
    }

    static std::string trim(const std::string& str) {
        size_t start = str.find_first_not_of(" \t\r\n");
        if (start == std::string::npos) return "";
        size_t end = str.find_last_not_of(" \t\r\n");
        return str.substr(start, end - start + 1);
    }
};

// ========== PUBLIC API ==========

// Execute a .m script file
int run_script(const std::string& path) {
    ActiveWindow window;
    window.set_fancy_mode(false);
    window.set_echo(false);

    ScriptRunner runner(window, path);
    auto result = runner.execute();

    return result.success ? 0 : 1;
}

// Execute a .m script with an existing window (for REPL integration)
int run_script_in_window(ActiveWindow& window, const std::string& path) {
    ScriptRunner runner(window, path);
    auto result = runner.execute();
    return result.success ? 0 : 1;
}

} // namespace interpreter
} // namespace matlabcpp

