// MatLabC++ Active Window Header
// include/matlabcpp/active_window.hpp

#pragma once

#include <string>
#include <vector>
#include <unordered_map>
#include <memory>

namespace matlabcpp {

// ========== VARIABLE STORAGE ==========

class Variable {
public:
    enum class Type { Scalar, Vector, Matrix };
    
private:
    Type type_;
    double scalar_value_;
    std::vector<double> vector_value_;
    std::vector<std::vector<double>> matrix_value_;
    
public:
    // Constructors
    Variable() : type_(Type::Scalar), scalar_value_(0.0) {}
    
    explicit Variable(double value) 
        : type_(Type::Scalar), scalar_value_(value) {}
    
    explicit Variable(const std::vector<double>& vec) 
        : type_(Type::Vector), scalar_value_(0.0), vector_value_(vec) {}
    
    explicit Variable(const std::vector<std::vector<double>>& mat) 
        : type_(Type::Matrix), scalar_value_(0.0), matrix_value_(mat) {}
    
    // Type checks
    bool is_scalar() const { return type_ == Type::Scalar; }
    bool is_vector() const { return type_ == Type::Vector; }
    bool is_matrix() const { return type_ == Type::Matrix; }
    
    // Accessors
    double as_scalar() const { return scalar_value_; }
    const std::vector<double>& as_vector() const { return vector_value_; }
    const std::vector<std::vector<double>>& as_matrix() const { return matrix_value_; }
    
    // Info
    std::string type_string() const {
        switch (type_) {
            case Type::Scalar: return "double";
            case Type::Vector: return "double";
            case Type::Matrix: return "double";
        }
        return "unknown";
    }
    
    std::string size_string() const {
        switch (type_) {
            case Type::Scalar: return "1x1";
            case Type::Vector: return "1x" + std::to_string(vector_value_.size());
            case Type::Matrix: {
                if (matrix_value_.empty()) return "0x0";
                return std::to_string(matrix_value_.size()) + "x" + 
                       std::to_string(matrix_value_[0].size());
            }
        }
        return "0x0";
    }
    
    size_t memory_size() const {
        switch (type_) {
            case Type::Scalar: return sizeof(double);
            case Type::Vector: return vector_value_.size() * sizeof(double);
            case Type::Matrix: {
                size_t total = 0;
                for (const auto& row : matrix_value_) {
                    total += row.size() * sizeof(double);
                }
                return total;
            }
        }
        return 0;
    }
};

// Forward declaration
class Workspace;

// ========== ACTIVE WINDOW ==========

class ActiveWindow {
    std::unique_ptr<Workspace> workspace_;
    bool running_;
    bool echo_commands_;
    bool fancy_mode_;
    
public:
    ActiveWindow();
    ~ActiveWindow();
    
    // Main interface
    void start();
    
    // Configuration
    void set_fancy_mode(bool fancy) { fancy_mode_ = fancy; }
    void set_echo(bool echo) { echo_commands_ = echo; }
    
private:
    // Command processing
    void process_command(const std::string& line);
    bool is_assignment(const std::string& cmd) const;
    void execute_assignment(const std::string& cmd, bool suppress);
    void execute_expression(const std::string& expr, bool suppress);
    
    // Expression evaluation
    Variable evaluate_expression(const std::string& expr);
    Variable evaluate_function_call(const std::string& func_name, const std::string& args_str);
    Variable parse_vector(const std::string& expr);
    Variable parse_matrix(const std::string& content);
    Variable evaluate_math_expression(const std::string& expr);
    
    // Display
    void display_variable(const std::string& name, const Variable& var);
    void display_value(const Variable& var);
    void list_variables();
    void list_variables_detailed();
    
    // UI
    void print_banner();
    void print_prompt();
    void print_error(const std::string& msg);
    void print_help();
    void print_goodbye();
    void clear_screen();
    
    // Utilities
    std::string trim(const std::string& str);
    bool is_valid_name(const std::string& name) const;
    bool is_number(const std::string& str) const;
};

} // namespace matlabcpp
