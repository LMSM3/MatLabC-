// MatLabC++ Active Window - Professional MATLAB-like interactive environment
// src/active_window.cpp

#include "matlabcpp/active_window.hpp"
#include <iostream>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <cmath>
#include <limits>

namespace matlabcpp {

// ========== VARIABLE STORAGE ==========

class Workspace {
    std::unordered_map<std::string, Variable> vars_;
    
public:
    void set(const std::string& name, const Variable& var) {
        vars_[name] = var;
    }
    
    Variable get(const std::string& name) const {
        auto it = vars_.find(name);
        if (it != vars_.end()) {
            return it->second;
        }
        throw std::runtime_error("Undefined variable: " + name);
    }
    
    bool exists(const std::string& name) const {
        return vars_.find(name) != vars_.end();
    }
    
    void clear() {
        vars_.clear();
    }
    
    void clear_var(const std::string& name) {
        vars_.erase(name);
    }
    
    std::vector<std::string> list() const {
        std::vector<std::string> names;
        for (const auto& pair : vars_) {
            names.push_back(pair.first);
        }
        std::sort(names.begin(), names.end());
        return names;
    }
    
    size_t memory_usage() const {
        size_t total = 0;
        for (const auto& pair : vars_) {
            total += pair.second.memory_size();
        }
        return total;
    }
};

// ========== ACTIVE WINDOW ==========

ActiveWindow::ActiveWindow() 
    : workspace_(std::make_unique<Workspace>())
    , running_(false)
    , echo_commands_(true)
    , fancy_mode_(true)
{
}

ActiveWindow::~ActiveWindow() = default;

void ActiveWindow::start() {
    running_ = true;
    print_banner();
    
    std::string line;
    while (running_) {
        print_prompt();
        
        if (!std::getline(std::cin, line)) {
            break;  // EOF
        }
        
        // Trim whitespace
        line = trim(line);
        
        if (line.empty()) {
            continue;
        }
        
        // Process command
        try {
            process_command(line);
        } catch (const std::exception& e) {
            print_error(e.what());
        }
    }
    
    print_goodbye();
}

void ActiveWindow::process_command(const std::string& line) {
    // Check for special commands
    if (line == "quit" || line == "exit") {
        running_ = false;
        return;
    }
    
    if (line == "clear") {
        workspace_->clear();
        std::cout << "\n";
        return;
    }
    
    if (line == "clc") {
        clear_screen();
        return;
    }
    
    if (line == "who") {
        list_variables();
        return;
    }
    
    if (line == "whos") {
        list_variables_detailed();
        return;
    }
    
    if (line.substr(0, 5) == "clear" && line.length() > 6) {
        std::string var_name = line.substr(6);
        workspace_->clear_var(trim(var_name));
        return;
    }
    
    if (line == "help") {
        print_help();
        return;
    }
    
    // Check if line ends with semicolon (suppress output)
    bool suppress_output = (!line.empty() && line.back() == ';');
    std::string cmd = suppress_output ? line.substr(0, line.length() - 1) : line;
    cmd = trim(cmd);
    
    // Parse and execute
    if (is_assignment(cmd)) {
        execute_assignment(cmd, suppress_output);
    } else {
        execute_expression(cmd, suppress_output);
    }
}

bool ActiveWindow::is_assignment(const std::string& cmd) const {
    return cmd.find('=') != std::string::npos;
}

void ActiveWindow::execute_assignment(const std::string& cmd, bool suppress) {
    // Parse: variable_name = expression
    size_t eq_pos = cmd.find('=');
    if (eq_pos == std::string::npos) {
        throw std::runtime_error("Invalid assignment");
    }
    
    std::string var_name = trim(cmd.substr(0, eq_pos));
    std::string expr = trim(cmd.substr(eq_pos + 1));
    
    // Validate variable name
    if (!is_valid_name(var_name)) {
        throw std::runtime_error("Invalid variable name: " + var_name);
    }
    
    // Evaluate expression
    Variable result = evaluate_expression(expr);
    
    // Store variable
    workspace_->set(var_name, result);
    
    // Display result (unless suppressed)
    if (!suppress) {
        std::cout << "\n";
        display_variable(var_name, result);
    }
}

void ActiveWindow::execute_expression(const std::string& expr, bool suppress) {
    // Check if it's a statement-like function (disp, fprintf, etc.)
    // These don't need to show return values
    size_t open_paren = expr.find('(');
    if (open_paren != std::string::npos && expr.back() == ')') {
        std::string func_name = trim(expr.substr(0, open_paren));
        if (func_name == "disp" || func_name == "fprintf" || func_name == "printf") {
            // Execute but don't show return value
            evaluate_expression(expr);
            return;
        }
    }
    
    Variable result = evaluate_expression(expr);
    
    if (!suppress) {
        std::cout << "\nans =\n\n";
        display_value(result);
        std::cout << "\n";
        
        // Store as 'ans'
        workspace_->set("ans", result);
    }
}

Variable ActiveWindow::evaluate_expression(const std::string& expr) {
    // Check for function calls: function_name(args)
    size_t open_paren = expr.find('(');
    if (open_paren != std::string::npos && expr.back() == ')') {
        std::string func_name = trim(expr.substr(0, open_paren));
        std::string args_str = expr.substr(open_paren + 1, expr.length() - open_paren - 2);
        return evaluate_function_call(func_name, args_str);
    }
    
    // Check if it's a vector/matrix literal: [...]
    if (!expr.empty() && expr.front() == '[' && expr.back() == ']') {
        return parse_vector(expr);
    }
    
    // Check if it's a variable reference
    if (is_valid_name(expr) && workspace_->exists(expr)) {
        return workspace_->get(expr);
    }
    
    // Check if it's a number
    if (is_number(expr)) {
        return Variable(std::stod(expr));
    }
    
    // Try to evaluate as expression (simple math)
    return evaluate_math_expression(expr);
}

Variable ActiveWindow::parse_vector(const std::string& expr) {
    // Remove brackets
    std::string content = expr.substr(1, expr.length() - 2);
    content = trim(content);
    
    // Check for matrix (contains semicolons)
    if (content.find(';') != std::string::npos) {
        return parse_matrix(content);
    }
    
    // Parse vector: split by spaces or commas
    std::vector<double> values;
    std::istringstream iss(content);
    std::string token;
    
    while (iss >> token) {
        // Remove commas
        token.erase(std::remove(token.begin(), token.end(), ','), token.end());
        
        if (!token.empty()) {
            try {
                values.push_back(std::stod(token));
            } catch (...) {
                throw std::runtime_error("Invalid number in vector: " + token);
            }
        }
    }
    
    return Variable(values);
}

Variable ActiveWindow::parse_matrix(const std::string& content) {
    // Split by semicolons (rows)
    std::vector<std::vector<double>> rows;
    std::istringstream row_stream(content);
    std::string row_str;
    
    while (std::getline(row_stream, row_str, ';')) {
        row_str = trim(row_str);
        if (row_str.empty()) continue;
        
        std::vector<double> row;
        std::istringstream col_stream(row_str);
        std::string token;
        
        while (col_stream >> token) {
            token.erase(std::remove(token.begin(), token.end(), ','), token.end());
            if (!token.empty()) {
                row.push_back(std::stod(token));
            }
        }
        
        if (!row.empty()) {
            rows.push_back(row);
        }
    }
    
    return Variable(rows);
}

Variable ActiveWindow::evaluate_math_expression(const std::string& expr) {
    // Simple expression evaluator (supports +, -, *, /, ^)
    // For now, just try to parse as a number
    try {
        return Variable(std::stod(expr));
    } catch (...) {
        throw std::runtime_error("Cannot evaluate expression: " + expr);
    }
}

Variable ActiveWindow::evaluate_function_call(const std::string& func_name, const std::string& args_str) {
    // Parse arguments (simple: split by commas)
    std::vector<Variable> args;
    std::istringstream iss(args_str);
    std::string arg;
    
    while (std::getline(iss, arg, ',')) {
        arg = trim(arg);
        if (!arg.empty()) {
            args.push_back(evaluate_expression(arg));
        }
    }
    
    // Handle built-in functions
    if (func_name == "disp") {
        // Display value(s)
        for (const auto& arg : args) {
            display_value(arg);
            std::cout << "\n";
        }
        // disp() doesn't return a value, but we need to return something
        return Variable(0.0);
    }
    else if (func_name == "size") {
        if (args.empty()) {
            throw std::runtime_error("size() requires at least one argument");
        }
        const auto& var = args[0];
        if (var.is_scalar()) {
            return Variable(std::vector<double>{1.0, 1.0});
        } else if (var.is_vector()) {
            return Variable(std::vector<double>{1.0, static_cast<double>(var.as_vector().size())});
        } else if (var.is_matrix()) {
            const auto& mat = var.as_matrix();
            return Variable(std::vector<double>{
                static_cast<double>(mat.size()), 
                static_cast<double>(mat.empty() ? 0 : mat[0].size())
            });
        }
    }
    else if (func_name == "length") {
        if (args.empty()) {
            throw std::runtime_error("length() requires one argument");
        }
        const auto& var = args[0];
        if (var.is_scalar()) {
            return Variable(1.0);
        } else if (var.is_vector()) {
            return Variable(static_cast<double>(var.as_vector().size()));
        } else if (var.is_matrix()) {
            const auto& mat = var.as_matrix();
            size_t max_dim = std::max(mat.size(), mat.empty() ? 0 : mat[0].size());
            return Variable(static_cast<double>(max_dim));
        }
    }
    else if (func_name == "sum") {
        if (args.empty()) {
            throw std::runtime_error("sum() requires one argument");
        }
        const auto& var = args[0];
        double total = 0.0;
        if (var.is_scalar()) {
            total = var.as_scalar();
        } else if (var.is_vector()) {
            for (double v : var.as_vector()) {
                total += v;
            }
        } else if (var.is_matrix()) {
            for (const auto& row : var.as_matrix()) {
                for (double v : row) {
                    total += v;
                }
            }
        }
        return Variable(total);
    }
    else if (func_name == "mean") {
        if (args.empty()) {
            throw std::runtime_error("mean() requires one argument");
        }
        const auto& var = args[0];
        double total = 0.0;
        size_t count = 0;
        if (var.is_scalar()) {
            return var;
        } else if (var.is_vector()) {
            for (double v : var.as_vector()) {
                total += v;
                count++;
            }
        } else if (var.is_matrix()) {
            for (const auto& row : var.as_matrix()) {
                for (double v : row) {
                    total += v;
                    count++;
                }
            }
        }
        return Variable(count > 0 ? total / count : 0.0);
    }
    else if (func_name == "min") {
        if (args.empty()) {
            throw std::runtime_error("min() requires one argument");
        }
        const auto& var = args[0];
        double min_val = std::numeric_limits<double>::max();
        if (var.is_scalar()) {
            return var;
        } else if (var.is_vector()) {
            for (double v : var.as_vector()) {
                min_val = std::min(min_val, v);
            }
        } else if (var.is_matrix()) {
            for (const auto& row : var.as_matrix()) {
                for (double v : row) {
                    min_val = std::min(min_val, v);
                }
            }
        }
        return Variable(min_val);
    }
    else if (func_name == "max") {
        if (args.empty()) {
            throw std::runtime_error("max() requires one argument");
        }
        const auto& var = args[0];
        double max_val = std::numeric_limits<double>::lowest();
        if (var.is_scalar()) {
            return var;
        } else if (var.is_vector()) {
            for (double v : var.as_vector()) {
                max_val = std::max(max_val, v);
            }
        } else if (var.is_matrix()) {
            for (const auto& row : var.as_matrix()) {
                for (double v : row) {
                    max_val = std::max(max_val, v);
                }
            }
        }
        return Variable(max_val);
    }
    else if (func_name == "sqrt") {
        if (args.empty()) {
            throw std::runtime_error("sqrt() requires one argument");
        }
        const auto& var = args[0];
        if (var.is_scalar()) {
            return Variable(std::sqrt(var.as_scalar()));
        }
        throw std::runtime_error("sqrt() only supports scalar arguments for now");
    }
    else if (func_name == "abs") {
        if (args.empty()) {
            throw std::runtime_error("abs() requires one argument");
        }
        const auto& var = args[0];
        if (var.is_scalar()) {
            return Variable(std::abs(var.as_scalar()));
        }
        throw std::runtime_error("abs() only supports scalar arguments for now");
    }
    else if (func_name == "sin" || func_name == "cos" || func_name == "tan" ||
             func_name == "exp" || func_name == "log" || func_name == "log10") {
        if (args.empty()) {
            throw std::runtime_error(func_name + "() requires one argument");
        }
        const auto& var = args[0];
        if (!var.is_scalar()) {
            throw std::runtime_error(func_name + "() only supports scalar arguments for now");
        }
        double val = var.as_scalar();
        double result;
        if (func_name == "sin") result = std::sin(val);
        else if (func_name == "cos") result = std::cos(val);
        else if (func_name == "tan") result = std::tan(val);
        else if (func_name == "exp") result = std::exp(val);
        else if (func_name == "log") result = std::log(val);
        else if (func_name == "log10") result = std::log10(val);
        return Variable(result);
    }
    
    // Unknown function
    throw std::runtime_error("Unknown function: " + func_name + "()");
}

void ActiveWindow::display_variable(const std::string& name, const Variable& var) {
    if (fancy_mode_) {
        std::cout << "\033[1;36m" << name << "\033[0m = \n\n";
    } else {
        std::cout << name << " = \n\n";
    }
    
    display_value(var);
    std::cout << "\n";
}

void ActiveWindow::display_value(const Variable& var) {
    if (var.is_scalar()) {
        // Single number
        std::cout << "    " << std::setprecision(4) << var.as_scalar() << "\n";
    } else if (var.is_vector()) {
        // Vector
        const auto& vec = var.as_vector();
        std::cout << "    ";
        for (size_t i = 0; i < vec.size(); ++i) {
            std::cout << std::setw(10) << std::setprecision(4) << vec[i];
            if (i < vec.size() - 1) std::cout << "  ";
        }
        std::cout << "\n";
    } else if (var.is_matrix()) {
        // Matrix
        const auto& mat = var.as_matrix();
        for (const auto& row : mat) {
            std::cout << "    ";
            for (size_t j = 0; j < row.size(); ++j) {
                std::cout << std::setw(10) << std::setprecision(4) << row[j];
                if (j < row.size() - 1) std::cout << "  ";
            }
            std::cout << "\n";
        }
    }
}

void ActiveWindow::list_variables() {
    auto names = workspace_->list();
    
    if (names.empty()) {
        std::cout << "\n  (no variables in workspace)\n\n";
        return;
    }
    
    std::cout << "\n  Your variables are:\n\n  ";
    for (size_t i = 0; i < names.size(); ++i) {
        std::cout << names[i];
        if (i < names.size() - 1) std::cout << "  ";
    }
    std::cout << "\n\n";
}

void ActiveWindow::list_variables_detailed() {
    auto names = workspace_->list();
    
    if (names.empty()) {
        std::cout << "\n  (no variables in workspace)\n\n";
        return;
    }
    
    std::cout << "\n  Name          Size              Bytes  Class\n";
    std::cout << "  ────────────  ────────────────  ──────  ──────\n";
    
    for (const auto& name : names) {
        Variable var = workspace_->get(name);
        std::cout << "  " << std::setw(12) << std::left << name;
        std::cout << "  " << std::setw(16) << var.size_string();
        std::cout << "  " << std::setw(6) << std::right << var.memory_size();
        std::cout << "  " << var.type_string() << "\n";
    }
    std::cout << "\n";
}

void ActiveWindow::print_banner() {
    if (!fancy_mode_) return;
    
    std::cout << "\033[2J\033[H";  // Clear screen
    std::cout << "\n";
    std::cout << "  ╔══════════════════════════════════════════════════════════╗\n";
    std::cout << "  ║                                                          ║\n";
    std::cout << "  ║      \033[1;36mMatLabC++\033[0m                     Version 0.3.0      ║\n";
    std::cout << "  ║                                                          ║\n";
    std::cout << "  ║      Professional MATLAB-Compatible Environment         ║\n";
    std::cout << "  ║                                                          ║\n";
    std::cout << "  ╚══════════════════════════════════════════════════════════╝\n";
    std::cout << "\n";
    std::cout << "  Type '\033[1;33mhelp\033[0m' for commands, '\033[1;33mquit\033[0m' to exit\n";
    std::cout << "\n";
}

void ActiveWindow::print_prompt() {
    if (fancy_mode_) {
        std::cout << "\033[1;32m>>\033[0m ";
    } else {
        std::cout << ">> ";
    }
    std::cout.flush();
}

void ActiveWindow::print_error(const std::string& msg) {
    if (fancy_mode_) {
        std::cout << "\n\033[1;31mError:\033[0m " << msg << "\n\n";
    } else {
        std::cout << "\nError: " << msg << "\n\n";
    }
}

void ActiveWindow::print_help() {
    std::cout << "\n";
    std::cout << "  \033[1;36mMatLabC++ Active Window Commands\033[0m\n";
    std::cout << "  ══════════════════════════════════════════════\n\n";
    
    std::cout << "  \033[1mVariables:\033[0m\n";
    std::cout << "    x = 5                 Assign scalar\n";
    std::cout << "    v = [1 2 3 4]         Create vector\n";
    std::cout << "    M = [1 2; 3 4]        Create matrix\n";
    std::cout << "    x = 5;                Suppress output (semicolon)\n\n";
    
    std::cout << "  \033[1mFunctions:\033[0m\n";
    std::cout << "    disp(x)               Display variable\n";
    std::cout << "    size(x)               Get dimensions\n";
    std::cout << "    length(x)             Get length\n";
    std::cout << "    sum(x)                Sum elements\n";
    std::cout << "    mean(x)               Average\n";
    std::cout << "    min(x), max(x)        Minimum/maximum\n";
    std::cout << "    sqrt(x), abs(x)       Square root, absolute value\n";
    std::cout << "    sin(x), cos(x), tan(x)  Trigonometric\n";
    std::cout << "    exp(x), log(x)        Exponential, logarithm\n\n";
    
    std::cout << "  \033[1mWorkspace:\033[0m\n";
    std::cout << "    who                   List variables\n";
    std::cout << "    whos                  Detailed variable info\n";
    std::cout << "    clear                 Clear all variables\n";
    std::cout << "    clear x               Clear variable x\n\n";
    
    std::cout << "  \033[1mDisplay:\033[0m\n";
    std::cout << "    clc                   Clear screen\n";
    std::cout << "    help                  Show this help\n\n";
    
    std::cout << "  \033[1mControl:\033[0m\n";
    std::cout << "    quit, exit            Exit active window\n";
    std::cout << "\n";
    std::cout << "  \033[2mTip: Type commands followed by Enter. Use semicolon to suppress output.\033[0m\n";
    std::cout << "\n";
}

void ActiveWindow::print_goodbye() {
    if (fancy_mode_) {
        std::cout << "\n  \033[1;36mThank you for using MatLabC++!\033[0m\n\n";
    } else {
        std::cout << "\nGoodbye!\n\n";
    }
}

void ActiveWindow::clear_screen() {
    std::cout << "\033[2J\033[H";
}

// ========== UTILITY FUNCTIONS ==========

std::string ActiveWindow::trim(const std::string& str) {
    size_t start = str.find_first_not_of(" \t\n\r");
    if (start == std::string::npos) return "";
    
    size_t end = str.find_last_not_of(" \t\n\r");
    return str.substr(start, end - start + 1);
}

bool ActiveWindow::is_valid_name(const std::string& name) const {
    if (name.empty()) return false;
    if (!std::isalpha(name[0]) && name[0] != '_') return false;
    
    for (char c : name) {
        if (!std::isalnum(c) && c != '_') return false;
    }
    
    return true;
}

bool ActiveWindow::is_number(const std::string& str) const {
    try {
        std::stod(str);
        return true;
    } catch (...) {
        return false;
    }
}

} // namespace matlabcpp
