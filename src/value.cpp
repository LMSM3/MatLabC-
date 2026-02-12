#include "matlabcpp/value.hpp"
#include <stdexcept>
#include <sstream>
#include <iomanip>
#include <cmath>
#include <algorithm>

namespace matlabcpp {

// ========== Constructors ==========

Value::Value() : type_(SCALAR), rows_(1), cols_(1), data_(1, 0.0) {}

Value::Value(double scalar) 
    : type_(SCALAR), rows_(1), cols_(1), data_(1, scalar) {}

Value::Value(const std::vector<double>& vec)
    : type_(VECTOR), rows_(vec.size()), cols_(1), data_(vec) {}

Value::Value(size_t rows, size_t cols)
    : type_(MATRIX), rows_(rows), cols_(cols), data_(rows * cols, 0.0) {}

Value::Value(size_t rows, size_t cols, const std::vector<double>& data)
    : type_(MATRIX), rows_(rows), cols_(cols), data_(data) {
    if (data.size() != rows * cols) {
        throw std::runtime_error("Data size doesn't match dimensions");
    }
}

// ========== Data Access ==========

double Value::as_scalar() const {
    if (type_ != SCALAR) {
        throw std::runtime_error("Value is not a scalar");
    }
    return data_[0];
}

double& Value::operator()(size_t i) {
    return data_[i];
}

double Value::operator()(size_t i) const {
    return data_[i];
}

double& Value::operator()(size_t i, size_t j) {
    return data_[linear_index(i, j)];
}

double Value::operator()(size_t i, size_t j) const {
    return data_[linear_index(i, j)];
}

// ========== Operators ==========

Value Value::operator+(const Value& other) const {
    if (rows_ != other.rows_ || cols_ != other.cols_) {
        throw std::runtime_error("Size mismatch for addition");
    }
    
    Value result(rows_, cols_);
    for (size_t i = 0; i < data_.size(); ++i) {
        result.data_[i] = data_[i] + other.data_[i];
    }
    return result;
}

Value Value::operator-(const Value& other) const {
    if (rows_ != other.rows_ || cols_ != other.cols_) {
        throw std::runtime_error("Size mismatch for subtraction");
    }
    
    Value result(rows_, cols_);
    for (size_t i = 0; i < data_.size(); ++i) {
        result.data_[i] = data_[i] - other.data_[i];
    }
    return result;
}

Value Value::operator*(const Value& other) const {
    // Matrix multiply
    if (cols_ != other.rows_) {
        throw std::runtime_error("Size mismatch for matrix multiply");
    }
    
    Value result(rows_, other.cols_);
    
    for (size_t i = 0; i < rows_; ++i) {
        for (size_t j = 0; j < other.cols_; ++j) {
            double sum = 0.0;
            for (size_t k = 0; k < cols_; ++k) {
                sum += (*this)(i, k) * other(k, j);
            }
            result(i, j) = sum;
        }
    }
    
    return result;
}

Value Value::dot_times(const Value& other) const {
    // Element-wise multiply
    if (rows_ != other.rows_ || cols_ != other.cols_) {
        throw std::runtime_error("Size mismatch for element-wise multiply");
    }
    
    Value result(rows_, cols_);
    for (size_t i = 0; i < data_.size(); ++i) {
        result.data_[i] = data_[i] * other.data_[i];
    }
    return result;
}

Value Value::transpose() const {
    Value result(cols_, rows_);
    
    for (size_t i = 0; i < rows_; ++i) {
        for (size_t j = 0; j < cols_; ++j) {
            result(j, i) = (*this)(i, j);
        }
    }
    
    return result;
}

// ========== Display ==========

std::string Value::to_string() const {
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(4);
    
    if (is_scalar()) {
        oss << data_[0];
        return oss.str();
    }
    
    // Matrix/vector display
    for (size_t i = 0; i < rows_; ++i) {
        oss << "    ";
        for (size_t j = 0; j < cols_; ++j) {
            oss << std::setw(10) << (*this)(i, j);
        }
        oss << "\n";
    }
    
    return oss.str();
}

// ========== Helper Functions ==========

Value zeros(size_t rows, size_t cols) {
    return Value(rows, cols);
}

Value ones(size_t rows, size_t cols) {
    Value result(rows, cols);
    for (size_t i = 0; i < rows * cols; ++i) {
        result.data()[i] = 1.0;
    }
    return result;
}

Value eye(size_t n) {
    Value result(n, n);
    for (size_t i = 0; i < n; ++i) {
        result(i, i) = 1.0;
    }
    return result;
}

// ========== Statistics ==========

double sum(const Value& v) {
    double result = 0.0;
    for (double val : v.data()) {
        result += val;
    }
    return result;
}

double mean(const Value& v) {
    return sum(v) / v.size();
}

double min(const Value& v) {
    return *std::min_element(v.data().begin(), v.data().end());
}

double max(const Value& v) {
    return *std::max_element(v.data().begin(), v.data().end());
}

} // namespace matlabcpp
