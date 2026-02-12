#pragma once
#include "matlabcpp/value.hpp"
#include <string>
#include <optional>

namespace matlabcpp {

// Parse MATLAB-style matrix literals
class MatrixParser {
public:
    // Parse: [1 2 3]           -> 1x3 vector
    // Parse: [1; 2; 3]         -> 3x1 vector
    // Parse: [1 2; 3 4]        -> 2x2 matrix
    // Parse: [1 2 3; 4 5 6]    -> 2x3 matrix
    static std::optional<Value> parse(const std::string& str);
    
    // Parse individual number (with error checking)
    static std::optional<double> parse_number(const std::string& str);
    
private:
    // Helper: split by delimiters
    static std::vector<std::string> split(const std::string& str, char delim);
    
    // Helper: trim whitespace
    static std::string trim(const std::string& str);
    
    // Helper: remove brackets
    static std::string strip_brackets(const std::string& str);
};

// MATLAB-style 1-based indexing wrapper
class MatlabValue {
public:
    MatlabValue() = default;
    MatlabValue(const Value& v) : value_(v) {}
    MatlabValue(Value&& v) : value_(std::move(v)) {}
    
    // MATLAB-style 1-based indexing
    double& at(size_t i, size_t j);              // 1-based: A.at(1,1)
    double at(size_t i, size_t j) const;
    double& at(size_t i);                        // Linear 1-based
    double at(size_t i) const;
    
    // C++ style 0-based (direct access to underlying Value)
    Value& value() { return value_; }
    const Value& value() const { return value_; }
    
    // Operators (MATLAB-style)
    MatlabValue operator+(const MatlabValue& other) const;
    MatlabValue operator-(const MatlabValue& other) const;
    MatlabValue operator*(const MatlabValue& other) const;   // Matrix multiply
    MatlabValue times(const MatlabValue& other) const;       // .* element-wise
    MatlabValue transpose() const;                           // A'
    
    // Shape (1-based conventions)
    size_t rows() const { return value_.rows(); }
    size_t cols() const { return value_.cols(); }
    std::pair<size_t, size_t> size() const { return {rows(), cols()}; }
    
    // Display
    std::string to_string() const { return value_.to_string(); }
    
private:
    Value value_;
};

// Quick constructors with both syntaxes
// C++ style:
Value make_matrix_cpp(size_t rows, size_t cols, const std::vector<double>& data);

// MATLAB style:
std::optional<Value> make_matrix_matlab(const std::string& literal);

// Example usage:
// C++:     Value A(3, 3);                    // 3x3 zeros
//          A(0, 0) = 5.0;                     // 0-based
//
// MATLAB:  MatlabValue A = parse("[1 2; 3 4]");
//          A.at(1, 1) = 5.0;                  // 1-based
//
// Hybrid:  Value A = parse("[1 2; 3 4]").value();
//          A(0, 0) = 5.0;                     // Back to 0-based

} // namespace matlabcpp
