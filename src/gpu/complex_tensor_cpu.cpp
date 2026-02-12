// ComplexTensor CPU Implementation - Always available, no CUDA required
// src/gpu/complex_tensor_cpu.cpp
//
// Complete CPU-side implementation of the ComplexTensor class.
// When CUDA is available, operations dispatch to GPU kernels.
// When CUDA is absent, all operations use optimised CPU routines.

#include "matlabcpp/complex_tensor.hpp"
#include <algorithm>
#include <numeric>
#include <random>
#include <cmath>
#include <cassert>
#include <sstream>
#include <iomanip>
#include <stdexcept>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace matlabcpp {

// ========== CPU STORAGE ==========

CPUStorage::CPUStorage(size_t size) : data_(size, {0.0, 0.0}) {}
CPUStorage::CPUStorage(const std::vector<Complex>& data) : data_(data) {}

void CPUStorage::to_gpu() {
#ifdef HAVE_CUDA
    // Implemented in complex_tensor_kernels.cu
#else
    throw std::runtime_error("GPU support not available (compiled without CUDA)");
#endif
}

std::unique_ptr<TensorStorage> CPUStorage::clone() const {
    return std::make_unique<CPUStorage>(data_);
}

// ========== GPU STORAGE (stub for non-CUDA builds) ==========

#ifndef HAVE_CUDA

GPUStorage::GPUStorage(size_t size) : gpu_data_(nullptr), size_(size), host_dirty_(false), gpu_dirty_(false) {
    throw std::runtime_error("GPU support not available (compiled without CUDA)");
}

GPUStorage::GPUStorage(const Complex* host_data, size_t size)
    : gpu_data_(nullptr), size_(size), host_dirty_(false), gpu_dirty_(false) {
    throw std::runtime_error("GPU support not available (compiled without CUDA)");
}

GPUStorage::~GPUStorage() {}

GPUStorage::Complex* GPUStorage::data() { return nullptr; }
const GPUStorage::Complex* GPUStorage::data() const { return nullptr; }
void GPUStorage::to_cpu() {}
std::unique_ptr<TensorStorage> GPUStorage::clone() const { return nullptr; }
void GPUStorage::sync_to_host() const {}
void GPUStorage::sync_to_gpu() {}
void GPUStorage::allocate_gpu() {}
void GPUStorage::free_gpu() {}

#endif // !HAVE_CUDA

// ========== COMPLEX TENSOR ==========

ComplexTensor::ComplexTensor()
    : rows_(0), cols_(0), depth_(1), device_(Device::CPU) {}

ComplexTensor::ComplexTensor(size_t rows, size_t cols, Device device)
    : rows_(rows), cols_(cols), depth_(1), device_(device) {
    if (device == Device::CPU) {
        storage_ = std::make_unique<CPUStorage>(rows * cols);
    } else {
        storage_ = std::make_unique<GPUStorage>(rows * cols);
    }
}

ComplexTensor::ComplexTensor(size_t rows, size_t cols, size_t depth, Device device)
    : rows_(rows), cols_(cols), depth_(depth), device_(device) {
    if (device == Device::CPU) {
        storage_ = std::make_unique<CPUStorage>(rows * cols * depth);
    } else {
        storage_ = std::make_unique<GPUStorage>(rows * cols * depth);
    }
}

ComplexTensor ComplexTensor::from_real(const std::vector<double>& data, size_t rows, size_t cols) {
    ComplexTensor t(rows, cols);
    for (size_t i = 0; i < data.size() && i < rows * cols; i++) {
        t.data()[i] = {data[i], 0.0};
    }
    return t;
}

ComplexTensor ComplexTensor::from_complex(const std::vector<Complex>& data, size_t rows, size_t cols) {
    ComplexTensor t(rows, cols);
    std::copy_n(data.begin(), std::min(data.size(), rows * cols), t.data());
    return t;
}

// Data access
ComplexTensor::Complex& ComplexTensor::operator()(size_t i, size_t j) {
    ensure_cpu();
    return storage_->data()[i * cols_ + j];
}

ComplexTensor::Complex ComplexTensor::operator()(size_t i, size_t j) const {
    ensure_cpu();
    return storage_->data()[i * cols_ + j];
}

ComplexTensor::Complex& ComplexTensor::operator()(size_t i, size_t j, size_t k) {
    ensure_cpu();
    return storage_->data()[(k * rows_ + i) * cols_ + j];
}

ComplexTensor::Complex ComplexTensor::operator()(size_t i, size_t j, size_t k) const {
    ensure_cpu();
    return storage_->data()[(k * rows_ + i) * cols_ + j];
}

const ComplexTensor::Complex* ComplexTensor::data() const {
    ensure_cpu();
    return storage_->data();
}

ComplexTensor::Complex* ComplexTensor::data() {
    ensure_cpu();
    return storage_->data();
}

// Device management
void ComplexTensor::to_gpu() { storage_->to_gpu(); device_ = Device::GPU; }
void ComplexTensor::to_cpu() { storage_->to_cpu(); device_ = Device::CPU; }

ComplexTensor ComplexTensor::on_gpu() const {
    ComplexTensor copy(rows_, cols_, Device::GPU);
    // Copy data
    auto cloned = storage_->clone();
    cloned->to_gpu();
    copy.storage_ = std::move(cloned);
    return copy;
}

ComplexTensor ComplexTensor::on_cpu() const {
    ComplexTensor copy(rows_, cols_, Device::CPU);
    auto cloned = storage_->clone();
    cloned->to_cpu();
    copy.storage_ = std::move(cloned);
    return copy;
}

// ========== ELEMENT-WISE OPERATIONS ==========

ComplexTensor ComplexTensor::real() const {
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) {
        result.data()[i] = {data()[i].real(), 0.0};
    }
    return result;
}

ComplexTensor ComplexTensor::imag() const {
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) {
        result.data()[i] = {data()[i].imag(), 0.0};
    }
    return result;
}

ComplexTensor ComplexTensor::conj() const {
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) {
        result.data()[i] = std::conj(data()[i]);
    }
    return result;
}

ComplexTensor ComplexTensor::abs() const {
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) {
        result.data()[i] = {std::abs(data()[i]), 0.0};
    }
    return result;
}

ComplexTensor ComplexTensor::angle() const {
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) {
        result.data()[i] = {std::arg(data()[i]), 0.0};
    }
    return result;
}

// ========== ARITHMETIC ==========

ComplexTensor ComplexTensor::operator+(const ComplexTensor& other) const {
    assert(rows_ == other.rows_ && cols_ == other.cols_);
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) {
        result.data()[i] = data()[i] + other.data()[i];
    }
    return result;
}

ComplexTensor ComplexTensor::operator-(const ComplexTensor& other) const {
    assert(rows_ == other.rows_ && cols_ == other.cols_);
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) {
        result.data()[i] = data()[i] - other.data()[i];
    }
    return result;
}

ComplexTensor ComplexTensor::operator*(const ComplexTensor& other) const {
    // Matrix multiplication
    assert(cols_ == other.rows_);
    ComplexTensor result(rows_, other.cols_);
    
    for (size_t i = 0; i < rows_; i++) {
        for (size_t j = 0; j < other.cols_; j++) {
            Complex sum = {0.0, 0.0};
            for (size_t k = 0; k < cols_; k++) {
                sum += (*this)(i, k) * other(k, j);
            }
            result(i, j) = sum;
        }
    }
    return result;
}

ComplexTensor ComplexTensor::operator/(const ComplexTensor& other) const {
    assert(rows_ == other.rows_ && cols_ == other.cols_);
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) {
        result.data()[i] = data()[i] / other.data()[i];
    }
    return result;
}

ComplexTensor& ComplexTensor::operator+=(const ComplexTensor& other) {
    for (size_t i = 0; i < size(); i++) data()[i] += other.data()[i];
    return *this;
}

ComplexTensor& ComplexTensor::operator-=(const ComplexTensor& other) {
    for (size_t i = 0; i < size(); i++) data()[i] -= other.data()[i];
    return *this;
}

ComplexTensor ComplexTensor::operator*(const Complex& scalar) const {
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) result.data()[i] = data()[i] * scalar;
    return result;
}

ComplexTensor ComplexTensor::operator/(const Complex& scalar) const {
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) result.data()[i] = data()[i] / scalar;
    return result;
}

ComplexTensor ComplexTensor::times(const ComplexTensor& other) const {
    assert(rows_ == other.rows_ && cols_ == other.cols_);
    ComplexTensor result(rows_, cols_);
    for (size_t i = 0; i < size(); i++) result.data()[i] = data()[i] * other.data()[i];
    return result;
}

ComplexTensor ComplexTensor::rdivide(const ComplexTensor& other) const {
    return *this / other;
}

// ========== LINEAR ALGEBRA ==========

ComplexTensor ComplexTensor::transpose() const {
    ComplexTensor result(cols_, rows_);
    for (size_t i = 0; i < rows_; i++) {
        for (size_t j = 0; j < cols_; j++) {
            result(j, i) = std::conj((*this)(i, j));
        }
    }
    return result;
}

ComplexTensor ComplexTensor::transpose_no_conj() const {
    ComplexTensor result(cols_, rows_);
    for (size_t i = 0; i < rows_; i++) {
        for (size_t j = 0; j < cols_; j++) {
            result(j, i) = (*this)(i, j);
        }
    }
    return result;
}

ComplexTensor ComplexTensor::inv() const {
    assert(rows_ == cols_);
    size_t n = rows_;
    
    // Augmented matrix [A | I]
    ComplexTensor aug(n, 2 * n);
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            aug(i, j) = (*this)(i, j);
        }
        aug(i, n + i) = {1.0, 0.0};
    }
    
    // Gauss-Jordan elimination
    for (size_t k = 0; k < n; k++) {
        // Partial pivoting
        size_t max_row = k;
        double max_val = std::abs(aug(k, k));
        for (size_t i = k + 1; i < n; i++) {
            if (std::abs(aug(i, k)) > max_val) {
                max_val = std::abs(aug(i, k));
                max_row = i;
            }
        }
        
        if (max_val < 1e-14) throw std::runtime_error("Matrix is singular");
        
        // Swap rows
        if (max_row != k) {
            for (size_t j = 0; j < 2 * n; j++) {
                std::swap(aug(k, j), aug(max_row, j));
            }
        }
        
        // Scale pivot row
        Complex pivot = aug(k, k);
        for (size_t j = 0; j < 2 * n; j++) aug(k, j) /= pivot;
        
        // Eliminate column
        for (size_t i = 0; i < n; i++) {
            if (i == k) continue;
            Complex factor = aug(i, k);
            for (size_t j = 0; j < 2 * n; j++) {
                aug(i, j) -= factor * aug(k, j);
            }
        }
    }
    
    // Extract inverse
    ComplexTensor result(n, n);
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            result(i, j) = aug(i, n + j);
        }
    }
    return result;
}

ComplexTensor ComplexTensor::solve(const ComplexTensor& b) const {
    // A\b using LU decomposition
    assert(rows_ == cols_ && rows_ == b.rows_);
    size_t n = rows_;
    
    // Copy A and b
    ComplexTensor A_copy(n, n);
    ComplexTensor b_copy(n, b.cols_);
    for (size_t i = 0; i < n * n; i++) A_copy.data()[i] = data()[i];
    for (size_t i = 0; i < b.size(); i++) b_copy.data()[i] = b.data()[i];
    
    // LU with partial pivoting (in-place)
    std::vector<size_t> perm(n);
    std::iota(perm.begin(), perm.end(), 0);
    
    for (size_t k = 0; k < n; k++) {
        size_t max_row = k;
        double max_val = std::abs(A_copy(k, k));
        for (size_t i = k + 1; i < n; i++) {
            if (std::abs(A_copy(i, k)) > max_val) {
                max_val = std::abs(A_copy(i, k));
                max_row = i;
            }
        }
        
        if (max_val < 1e-14) throw std::runtime_error("Singular matrix in solve()");
        
        if (max_row != k) {
            std::swap(perm[k], perm[max_row]);
            for (size_t j = 0; j < n; j++) std::swap(A_copy(k, j), A_copy(max_row, j));
            for (size_t j = 0; j < b.cols_; j++) std::swap(b_copy(k, j), b_copy(max_row, j));
        }
        
        for (size_t i = k + 1; i < n; i++) {
            Complex factor = A_copy(i, k) / A_copy(k, k);
            for (size_t j = k + 1; j < n; j++) A_copy(i, j) -= factor * A_copy(k, j);
            for (size_t j = 0; j < b.cols_; j++) b_copy(i, j) -= factor * b_copy(k, j);
        }
    }
    
    // Back substitution
    ComplexTensor x(n, b.cols_);
    for (size_t col = 0; col < b.cols_; col++) {
        for (int i = static_cast<int>(n) - 1; i >= 0; i--) {
            Complex sum = b_copy(i, col);
            for (size_t j = i + 1; j < n; j++) sum -= A_copy(i, j) * x(j, col);
            x(i, col) = sum / A_copy(i, i);
        }
    }
    
    return x;
}

// ========== REDUCTIONS ==========

ComplexTensor::Complex ComplexTensor::sum() const {
    Complex total = {0.0, 0.0};
    for (size_t i = 0; i < size(); i++) total += data()[i];
    return total;
}

ComplexTensor::Complex ComplexTensor::mean() const {
    return sum() / Complex(static_cast<double>(size()), 0.0);
}

ComplexTensor::Complex ComplexTensor::trace() const {
    Complex total = {0.0, 0.0};
    size_t n = std::min(rows_, cols_);
    for (size_t i = 0; i < n; i++) total += (*this)(i, i);
    return total;
}

double ComplexTensor::norm() const {
    double sum_sq = 0.0;
    for (size_t i = 0; i < size(); i++) {
        sum_sq += std::norm(data()[i]);  // |z|^2
    }
    return std::sqrt(sum_sq);
}

// ========== FFT (CPU Cooley-Tukey) ==========

static void fft_recursive(std::vector<ComplexTensor::Complex>& x) {
    size_t n = x.size();
    if (n <= 1) return;
    
    std::vector<ComplexTensor::Complex> even(n / 2), odd(n / 2);
    for (size_t i = 0; i < n / 2; i++) {
        even[i] = x[2 * i];
        odd[i] = x[2 * i + 1];
    }
    
    fft_recursive(even);
    fft_recursive(odd);
    
    for (size_t k = 0; k < n / 2; k++) {
        double angle = -2.0 * M_PI * k / n;
        ComplexTensor::Complex w = {std::cos(angle), std::sin(angle)};
        x[k] = even[k] + w * odd[k];
        x[k + n / 2] = even[k] - w * odd[k];
    }
}

ComplexTensor ComplexTensor::fft() const {
    assert(is_vector());
    size_t n = size();
    
    // Pad to next power of 2
    size_t n2 = 1;
    while (n2 < n) n2 <<= 1;
    
    std::vector<Complex> x(n2, {0.0, 0.0});
    for (size_t i = 0; i < n; i++) x[i] = data()[i];
    
    fft_recursive(x);
    
    return ComplexTensor::from_complex(x, 1, n2);
}

ComplexTensor ComplexTensor::ifft() const {
    // ifft = conj(fft(conj(x))) / n
    auto conj_data = this->conj();
    auto fft_result = conj_data.fft();
    auto result = fft_result.conj();
    Complex scale = {1.0 / static_cast<double>(result.size()), 0.0};
    return result * scale;
}

// ========== DECOMPOSITIONS (CPU) ==========

void ComplexTensor::lu(ComplexTensor& L, ComplexTensor& U, ComplexTensor& P) const {
    assert(rows_ == cols_);
    size_t n = rows_;
    
    U = ComplexTensor(n, n);
    L = ComplexTensor(n, n);
    P = ComplexTensor(n, n);
    
    // Copy to U
    for (size_t i = 0; i < n * n; i++) U.data()[i] = data()[i];
    
    // Initialize P = I
    for (size_t i = 0; i < n; i++) P(i, i) = {1.0, 0.0};
    // Initialize L = I
    for (size_t i = 0; i < n; i++) L(i, i) = {1.0, 0.0};
    
    for (size_t k = 0; k < n; k++) {
        // Pivot
        size_t max_row = k;
        double max_val = std::abs(U(k, k));
        for (size_t i = k + 1; i < n; i++) {
            if (std::abs(U(i, k)) > max_val) {
                max_val = std::abs(U(i, k));
                max_row = i;
            }
        }
        
        if (max_row != k) {
            for (size_t j = 0; j < n; j++) {
                std::swap(U(k, j), U(max_row, j));
                std::swap(P(k, j), P(max_row, j));
            }
            for (size_t j = 0; j < k; j++) {
                std::swap(L(k, j), L(max_row, j));
            }
        }
        
        for (size_t i = k + 1; i < n; i++) {
            Complex factor = U(i, k) / U(k, k);
            L(i, k) = factor;
            for (size_t j = k; j < n; j++) {
                U(i, j) -= factor * U(k, j);
            }
        }
    }
}

void ComplexTensor::eig(std::vector<Complex>& eigenvalues, ComplexTensor& eigenvectors) const {
    assert(rows_ == cols_);
    size_t n = rows_;
    
    // Simple QR algorithm for eigenvalues
    ComplexTensor A(n, n);
    for (size_t i = 0; i < n * n; i++) A.data()[i] = data()[i];
    
    eigenvectors = ComplexTensor(n, n);
    for (size_t i = 0; i < n; i++) eigenvectors(i, i) = {1.0, 0.0};
    
    // QR iteration (simplified)
    for (int iter = 0; iter < 100; iter++) {
        // Compute QR via Gram-Schmidt
        ComplexTensor Q(n, n), R(n, n);
        A.qr(Q, R);
        A = R * Q;
        eigenvectors = eigenvectors * Q;
    }
    
    eigenvalues.resize(n);
    for (size_t i = 0; i < n; i++) {
        eigenvalues[i] = A(i, i);
    }
}

void ComplexTensor::qr(ComplexTensor& Q, ComplexTensor& R) const {
    size_t m = rows_, n = cols_;
    Q = ComplexTensor(m, m);
    R = ComplexTensor(m, n);
    
    // Modified Gram-Schmidt
    std::vector<std::vector<Complex>> columns(n);
    for (size_t j = 0; j < n; j++) {
        columns[j].resize(m);
        for (size_t i = 0; i < m; i++) columns[j][i] = (*this)(i, j);
    }
    
    std::vector<std::vector<Complex>> q_cols(n);
    for (size_t j = 0; j < n; j++) {
        q_cols[j] = columns[j];
        
        for (size_t k = 0; k < j; k++) {
            Complex dot = {0.0, 0.0};
            for (size_t i = 0; i < m; i++) dot += std::conj(q_cols[k][i]) * q_cols[j][i];
            R(k, j) = dot;
            for (size_t i = 0; i < m; i++) q_cols[j][i] -= dot * q_cols[k][i];
        }
        
        double col_norm = 0.0;
        for (size_t i = 0; i < m; i++) col_norm += std::norm(q_cols[j][i]);
        col_norm = std::sqrt(col_norm);
        R(j, j) = {col_norm, 0.0};
        
        if (col_norm > 1e-14) {
            for (size_t i = 0; i < m; i++) q_cols[j][i] /= col_norm;
        }
    }
    
    for (size_t j = 0; j < std::min(m, n); j++) {
        for (size_t i = 0; i < m; i++) Q(i, j) = q_cols[j][i];
    }
}

void ComplexTensor::svd(ComplexTensor& U_out, std::vector<double>& S, ComplexTensor& V_out) const {
    // SVD via eigendecomposition of A'A
    ComplexTensor AtA = this->transpose() * (*this);
    
    std::vector<Complex> eigenvalues;
    ComplexTensor eigenvectors(1, 1);
    AtA.eig(eigenvalues, eigenvectors);
    
    size_t n = std::min(rows_, cols_);
    S.resize(n);
    for (size_t i = 0; i < n; i++) {
        S[i] = std::sqrt(std::max(0.0, eigenvalues[i].real()));
    }
    
    V_out = eigenvectors;
    
    // U = A * V * S^(-1)
    U_out = ComplexTensor(rows_, n);
    for (size_t j = 0; j < n; j++) {
        if (S[j] > 1e-14) {
            for (size_t i = 0; i < rows_; i++) {
                Complex sum = {0.0, 0.0};
                for (size_t k = 0; k < cols_; k++) {
                    sum += (*this)(i, k) * V_out(k, j);
                }
                U_out(i, j) = sum / Complex(S[j], 0.0);
            }
        }
    }
}

// ========== 2D FFT ==========

ComplexTensor ComplexTensor::fft2() const {
    assert(depth_ == 1);
    ComplexTensor result(rows_, cols_);
    
    // FFT along rows
    for (size_t i = 0; i < rows_; i++) {
        std::vector<Complex> row(cols_);
        for (size_t j = 0; j < cols_; j++) row[j] = (*this)(i, j);
        
        size_t n2 = 1;
        while (n2 < cols_) n2 <<= 1;
        row.resize(n2, {0.0, 0.0});
        fft_recursive(row);
        
        for (size_t j = 0; j < cols_; j++) result(i, j) = row[j];
    }
    
    // FFT along columns
    for (size_t j = 0; j < cols_; j++) {
        std::vector<Complex> col(rows_);
        for (size_t i = 0; i < rows_; i++) col[i] = result(i, j);
        
        size_t n2 = 1;
        while (n2 < rows_) n2 <<= 1;
        col.resize(n2, {0.0, 0.0});
        fft_recursive(col);
        
        for (size_t i = 0; i < rows_; i++) result(i, j) = col[i];
    }
    
    return result;
}

ComplexTensor ComplexTensor::ifft2() const {
    auto conj_data = this->conj();
    auto fft_result = conj_data.fft2();
    auto result = fft_result.conj();
    Complex scale = {1.0 / static_cast<double>(size()), 0.0};
    return result * scale;
}

// ========== DISPLAY ==========

std::string ComplexTensor::to_string() const {
    std::ostringstream ss;
    ss << std::fixed << std::setprecision(4);
    
    if (is_scalar()) {
        Complex v = data()[0];
        ss << v.real();
        if (v.imag() != 0.0) ss << " + " << v.imag() << "i";
    } else {
        for (size_t i = 0; i < rows_; i++) {
            ss << "  ";
            for (size_t j = 0; j < cols_; j++) {
                Complex v = (*this)(i, j);
                ss << std::setw(10) << v.real();
                if (v.imag() != 0.0) ss << "+" << v.imag() << "i";
                ss << "  ";
            }
            ss << "\n";
        }
    }
    return ss.str();
}

void ComplexTensor::ensure_cpu() const {
    if (device_ != Device::CPU && storage_) {
        const_cast<ComplexTensor*>(this)->to_cpu();
    }
}

void ComplexTensor::sync_if_needed() const {
    ensure_cpu();
}

// ========== FACTORY FUNCTIONS ==========

ComplexTensor zeros(size_t rows, size_t cols, Device device) {
    return ComplexTensor(rows, cols, device);
}

ComplexTensor ones(size_t rows, size_t cols, Device device) {
    ComplexTensor t(rows, cols, device);
    for (size_t i = 0; i < rows * cols; i++) t.data()[i] = {1.0, 0.0};
    return t;
}

ComplexTensor eye(size_t n, Device device) {
    ComplexTensor t(n, n, device);
    for (size_t i = 0; i < n; i++) t(i, i) = {1.0, 0.0};
    return t;
}

ComplexTensor randn(size_t rows, size_t cols, Device device) {
    ComplexTensor t(rows, cols, device);
    std::mt19937 gen(std::random_device{}());
    std::normal_distribution<double> dist(0.0, 1.0);
    for (size_t i = 0; i < rows * cols; i++) {
        t.data()[i] = {dist(gen), dist(gen)};
    }
    return t;
}

} // namespace matlabcpp
