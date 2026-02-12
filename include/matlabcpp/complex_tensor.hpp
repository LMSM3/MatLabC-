#pragma once
#include <complex>
#include <vector>
#include <cstddef>
#include <string>
#include <memory>

namespace matlabcpp {

// Forward declarations
class TensorStorage;
enum class Device { CPU, GPU };

// Complex-aware tensor for MATLAB compatibility
class ComplexTensor {
public:
    using Complex = std::complex<double>;
    
    // Constructors
    ComplexTensor();                                           // Empty
    ComplexTensor(size_t rows, size_t cols, Device device = Device::CPU);
    ComplexTensor(size_t rows, size_t cols, size_t depth, Device device = Device::CPU);
    
    // From real data
    static ComplexTensor from_real(const std::vector<double>& data, size_t rows, size_t cols);
    
    // From complex data
    static ComplexTensor from_complex(const std::vector<Complex>& data, size_t rows, size_t cols);
    
    // Shape
    size_t rows() const { return rows_; }
    size_t cols() const { return cols_; }
    size_t depth() const { return depth_; }
    size_t ndim() const { return depth_ > 1 ? 3 : 2; }
    size_t size() const { return rows_ * cols_ * depth_; }
    bool is_scalar() const { return rows_ == 1 && cols_ == 1 && depth_ == 1; }
    bool is_vector() const { return (rows_ == 1 || cols_ == 1) && depth_ == 1; }
    bool is_matrix() const { return rows_ > 1 && cols_ > 1 && depth_ == 1; }
    bool is_3d() const { return depth_ > 1; }
    
    // Device management
    Device device() const { return device_; }
    void to_gpu();                // Move to GPU
    void to_cpu();                // Move to CPU
    ComplexTensor on_gpu() const; // Copy to GPU
    ComplexTensor on_cpu() const; // Copy to CPU
    
    // Data access (CPU only)
    Complex& operator()(size_t i, size_t j);
    Complex operator()(size_t i, size_t j) const;
    Complex& operator()(size_t i, size_t j, size_t k);
    Complex operator()(size_t i, size_t j, size_t k) const;
    
    const Complex* data() const;
    Complex* data();
    
    // Real/Imaginary parts
    ComplexTensor real() const;
    ComplexTensor imag() const;
    ComplexTensor conj() const;  // Complex conjugate
    ComplexTensor abs() const;   // Magnitude
    ComplexTensor angle() const; // Phase
    
    // Basic operations (GPU-accelerated if on GPU)
    ComplexTensor operator+(const ComplexTensor& other) const;
    ComplexTensor operator-(const ComplexTensor& other) const;
    ComplexTensor operator*(const ComplexTensor& other) const;  // Matrix multiply
    ComplexTensor operator/(const ComplexTensor& other) const;  // Element-wise
    
    ComplexTensor& operator+=(const ComplexTensor& other);
    ComplexTensor& operator-=(const ComplexTensor& other);
    
    // Scalar operations
    ComplexTensor operator*(const Complex& scalar) const;
    ComplexTensor operator/(const Complex& scalar) const;
    
    // Element-wise operations
    ComplexTensor times(const ComplexTensor& other) const;  // .*
    ComplexTensor rdivide(const ComplexTensor& other) const; // ./
    
    // Linear algebra
    ComplexTensor transpose() const;        // A'  (conjugate transpose)
    ComplexTensor transpose_no_conj() const; // A.' (transpose without conjugate)
    ComplexTensor inv() const;              // Matrix inverse
    ComplexTensor solve(const ComplexTensor& b) const; // A\b
    
    // Reductions
    Complex sum() const;
    Complex mean() const;
    Complex trace() const;  // Sum of diagonal
    double norm() const;    // Frobenius norm
    
    // Decompositions (GPU-accelerated)
    void lu(ComplexTensor& L, ComplexTensor& U, ComplexTensor& P) const;
    void qr(ComplexTensor& Q, ComplexTensor& R) const;
    void svd(ComplexTensor& U, std::vector<double>& S, ComplexTensor& V) const;
    void eig(std::vector<Complex>& eigenvalues, ComplexTensor& eigenvectors) const;
    
    // FFT (GPU-accelerated)
    ComplexTensor fft() const;
    ComplexTensor ifft() const;
    ComplexTensor fft2() const;  // 2D FFT
    ComplexTensor ifft2() const;
    
    // Display
    std::string to_string() const;
    
    // Memory info
    size_t memory_bytes() const { return size() * sizeof(Complex); }
    bool is_on_gpu() const { return device_ == Device::GPU; }
    
private:
    size_t rows_;
    size_t cols_;
    size_t depth_;
    Device device_;
    std::unique_ptr<TensorStorage> storage_;
    
    void ensure_cpu() const;
    void sync_if_needed() const;
};

// Tensor storage abstraction (CPU/GPU)
class TensorStorage {
public:
    using Complex = std::complex<double>;
    
    virtual ~TensorStorage() = default;
    
    virtual Complex* data() = 0;
    virtual const Complex* data() const = 0;
    virtual size_t size() const = 0;
    virtual Device device() const = 0;
    
    virtual void to_gpu() = 0;
    virtual void to_cpu() = 0;
    virtual std::unique_ptr<TensorStorage> clone() const = 0;
};

// CPU storage
class CPUStorage : public TensorStorage {
public:
    explicit CPUStorage(size_t size);
    CPUStorage(const std::vector<Complex>& data);
    
    Complex* data() override { return data_.data(); }
    const Complex* data() const override { return data_.data(); }
    size_t size() const override { return data_.size(); }
    Device device() const override { return Device::CPU; }
    
    void to_gpu() override;
    void to_cpu() override {} // Already on CPU
    std::unique_ptr<TensorStorage> clone() const override;
    
private:
    std::vector<Complex> data_;
};

// GPU storage (CUDA)
class GPUStorage : public TensorStorage {
public:
    explicit GPUStorage(size_t size);
    GPUStorage(const Complex* host_data, size_t size);
    ~GPUStorage() override;
    
    // GPU memory access (for kernels)
    Complex* gpu_ptr() { return gpu_data_; }
    const Complex* gpu_ptr() const { return gpu_data_; }
    
    // Host access (requires sync)
    Complex* data() override;
    const Complex* data() const override;
    size_t size() const override { return size_; }
    Device device() const override { return Device::GPU; }
    
    void to_gpu() override {} // Already on GPU
    void to_cpu() override;
    std::unique_ptr<TensorStorage> clone() const override;
    
private:
    Complex* gpu_data_;          // Device pointer
    mutable std::vector<Complex> host_cache_; // For CPU access
    size_t size_;
    mutable bool host_dirty_;
    mutable bool gpu_dirty_;
    
    void sync_to_host() const;
    void sync_to_gpu();
    void allocate_gpu();
    void free_gpu();
};

// Helper functions
ComplexTensor zeros(size_t rows, size_t cols, Device device = Device::CPU);
ComplexTensor ones(size_t rows, size_t cols, Device device = Device::CPU);
ComplexTensor eye(size_t n, Device device = Device::CPU);
ComplexTensor randn(size_t rows, size_t cols, Device device = Device::CPU); // Gaussian random

} // namespace matlabcpp
