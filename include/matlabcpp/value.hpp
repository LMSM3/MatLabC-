#pragma once
#include <vector>
#include <string>
#include <variant>
#include <cstddef>

namespace matlabcpp {

// Simple Value type: scalar, vector, or matrix
class Value {
public:
    enum Type { SCALAR, VECTOR, MATRIX };
    
    // Constructors
    Value();                                    // Empty
    Value(double scalar);                       // Scalar
    Value(const std::vector<double>& vec);      // Vector
    Value(size_t rows, size_t cols);            // Matrix (zeros)
    Value(size_t rows, size_t cols, const std::vector<double>& data);
    
    // Type queries
    Type type() const { return type_; }
    bool is_scalar() const { return type_ == SCALAR; }
    bool is_vector() const { return type_ == VECTOR; }
    bool is_matrix() const { return type_ == MATRIX; }
    
    // Shape
    size_t rows() const { return rows_; }
    size_t cols() const { return cols_; }
    size_t size() const { return data_.size(); }
    
    // Data access
    double as_scalar() const;
    double& operator()(size_t i);                    // Linear index
    double operator()(size_t i) const;
    double& operator()(size_t i, size_t j);          // 2D index
    double operator()(size_t i, size_t j) const;
    
    const std::vector<double>& data() const { return data_; }
    std::vector<double>& data() { return data_; }
    
    // Operators (basic)
    Value operator+(const Value& other) const;
    Value operator-(const Value& other) const;
    Value operator*(const Value& other) const;       // Matrix multiply
    Value dot_times(const Value& other) const;       // Element-wise .*
    Value transpose() const;                         // A'
    
    // Display
    std::string to_string() const;
    
private:
    Type type_;
    size_t rows_;
    size_t cols_;
    std::vector<double> data_;  // Column-major storage
    
    size_t linear_index(size_t i, size_t j) const {
        return i + j * rows_;  // Column-major
    }
};

// Helper functions
Value zeros(size_t rows, size_t cols);
Value ones(size_t rows, size_t cols);
Value eye(size_t n);

// Statistics
double sum(const Value& v);
double mean(const Value& v);
double min(const Value& v);
double max(const Value& v);

} // namespace matlabcpp
