#include "matlabcpp/matrix_parser.hpp"
#include <sstream>
#include <algorithm>
#include <cctype>
#include <stdexcept>

namespace matlabcpp {

// ========== MatrixParser Implementation ==========

std::optional<Value> MatrixParser::parse(const std::string& str) {
    // Remove leading/trailing whitespace
    std::string trimmed = trim(str);
    
    // Must start with [ and end with ]
    if (trimmed.empty() || trimmed.front() != '[' || trimmed.back() != ']') {
        return std::nullopt;
    }
    
    // Remove brackets
    std::string content = strip_brackets(trimmed);
    
    // Split by semicolons (rows)
    std::vector<std::string> rows = split(content, ';');
    
    if (rows.empty()) {
        return std::nullopt;
    }
    
    std::vector<std::vector<double>> matrix_data;
    size_t num_cols = 0;
    
    // Parse each row
    for (size_t r = 0; r < rows.size(); ++r) {
        std::string row_str = trim(rows[r]);
        if (row_str.empty()) continue;
        
        // Split by spaces or commas (columns)
        std::vector<std::string> elements;
        std::string current;
        
        for (char c : row_str) {
            if (c == ' ' || c == ',' || c == '\t') {
                if (!current.empty()) {
                    elements.push_back(current);
                    current.clear();
                }
            } else {
                current += c;
            }
        }
        if (!current.empty()) {
            elements.push_back(current);
        }
        
        // Parse numbers
        std::vector<double> row_data;
        for (const auto& elem : elements) {
            auto num = parse_number(elem);
            if (!num) {
                return std::nullopt;  // Invalid number
            }
            row_data.push_back(*num);
        }
        
        // Check column consistency
        if (r == 0) {
            num_cols = row_data.size();
        } else if (row_data.size() != num_cols) {
            return std::nullopt;  // Inconsistent columns
        }
        
        matrix_data.push_back(row_data);
    }
    
    // Build Value
    size_t num_rows = matrix_data.size();
    
    // Flatten to column-major storage
    std::vector<double> data;
    data.reserve(num_rows * num_cols);
    
    for (size_t j = 0; j < num_cols; ++j) {
        for (size_t i = 0; i < num_rows; ++i) {
            data.push_back(matrix_data[i][j]);
        }
    }
    
    // Special cases
    if (num_rows == 1 && num_cols == 1) {
        return Value(data[0]);  // Scalar
    }
    
    return Value(num_rows, num_cols, data);
}

std::optional<double> MatrixParser::parse_number(const std::string& str) {
    try {
        size_t pos;
        double val = std::stod(str, &pos);
        if (pos == str.length()) {
            return val;
        }
    } catch (...) {
        // Not a number
    }
    return std::nullopt;
}

std::vector<std::string> MatrixParser::split(const std::string& str, char delim) {
    std::vector<std::string> result;
    std::stringstream ss(str);
    std::string item;
    
    while (std::getline(ss, item, delim)) {
        result.push_back(item);
    }
    
    return result;
}

std::string MatrixParser::trim(const std::string& str) {
    auto start = std::find_if_not(str.begin(), str.end(), ::isspace);
    auto end = std::find_if_not(str.rbegin(), str.rend(), ::isspace).base();
    return (start < end) ? std::string(start, end) : std::string();
}

std::string MatrixParser::strip_brackets(const std::string& str) {
    if (str.length() >= 2 && str.front() == '[' && str.back() == ']') {
        return str.substr(1, str.length() - 2);
    }
    return str;
}

// ========== MatlabValue Implementation ==========

double& MatlabValue::at(size_t i, size_t j) {
    // Convert from 1-based to 0-based
    if (i < 1 || i > value_.rows() || j < 1 || j > value_.cols()) {
        throw std::out_of_range("Index out of bounds (1-based)");
    }
    return value_(i - 1, j - 1);
}

double MatlabValue::at(size_t i, size_t j) const {
    if (i < 1 || i > value_.rows() || j < 1 || j > value_.cols()) {
        throw std::out_of_range("Index out of bounds (1-based)");
    }
    return value_(i - 1, j - 1);
}

double& MatlabValue::at(size_t i) {
    if (i < 1 || i > value_.size()) {
        throw std::out_of_range("Index out of bounds (1-based)");
    }
    return value_(i - 1);
}

double MatlabValue::at(size_t i) const {
    if (i < 1 || i > value_.size()) {
        throw std::out_of_range("Index out of bounds (1-based)");
    }
    return value_(i - 1);
}

MatlabValue MatlabValue::operator+(const MatlabValue& other) const {
    return MatlabValue(value_ + other.value_);
}

MatlabValue MatlabValue::operator-(const MatlabValue& other) const {
    return MatlabValue(value_ - other.value_);
}

MatlabValue MatlabValue::operator*(const MatlabValue& other) const {
    return MatlabValue(value_ * other.value_);
}

MatlabValue MatlabValue::times(const MatlabValue& other) const {
    return MatlabValue(value_.dot_times(other.value_));
}

MatlabValue MatlabValue::transpose() const {
    return MatlabValue(value_.transpose());
}

// ========== Helper Functions ==========

Value make_matrix_cpp(size_t rows, size_t cols, const std::vector<double>& data) {
    return Value(rows, cols, data);
}

std::optional<Value> make_matrix_matlab(const std::string& literal) {
    return MatrixParser::parse(literal);
}

} // namespace matlabcpp
