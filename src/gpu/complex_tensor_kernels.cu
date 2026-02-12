// GPU kernels for complex tensor operations
// Compile with: nvcc -arch=sm_70 -c complex_tensor_kernels.cu

#include <cuda_runtime.h>
#include <cuComplex.h>
#include <cublas_v2.h>
#include <cusolverDn.h>
#include <cufft.h>

namespace matlabcpp {
namespace gpu {

// ========== Device Helpers ==========

__device__ inline cuDoubleComplex to_cuda(const std::complex<double>& z) {
    return make_cuDoubleComplex(z.real(), z.imag());
}

__device__ inline std::complex<double> from_cuda(const cuDoubleComplex& z) {
    return std::complex<double>(cuCreal(z), cuCimag(z));
}

// ========== Basic Kernels ==========

// Complex addition: C = A + B
__global__ void add_kernel(
    const cuDoubleComplex* A,
    const cuDoubleComplex* B,
    cuDoubleComplex* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuCadd(A[idx], B[idx]);
    }
}

// Complex subtraction: C = A - B
__global__ void sub_kernel(
    const cuDoubleComplex* A,
    const cuDoubleComplex* B,
    cuDoubleComplex* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuCsub(A[idx], B[idx]);
    }
}

// Element-wise multiply: C = A .* B
__global__ void times_kernel(
    const cuDoubleComplex* A,
    const cuDoubleComplex* B,
    cuDoubleComplex* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuCmul(A[idx], B[idx]);
    }
}

// Element-wise divide: C = A ./ B
__global__ void rdivide_kernel(
    const cuDoubleComplex* A,
    const cuDoubleComplex* B,
    cuDoubleComplex* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuCdiv(A[idx], B[idx]);
    }
}

// Scalar multiply: C = A * s
__global__ void scalar_mul_kernel(
    const cuDoubleComplex* A,
    cuDoubleComplex s,
    cuDoubleComplex* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuCmul(A[idx], s);
    }
}

// Complex conjugate: C = conj(A)
__global__ void conj_kernel(
    const cuDoubleComplex* A,
    cuDoubleComplex* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuConj(A[idx]);
    }
}

// Magnitude: C = |A| (real output)
__global__ void abs_kernel(
    const cuDoubleComplex* A,
    double* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuCabs(A[idx]);
    }
}

// Phase angle: C = angle(A) (real output)
__global__ void angle_kernel(
    const cuDoubleComplex* A,
    double* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = atan2(cuCimag(A[idx]), cuCreal(A[idx]));
    }
}

// Real part: C = real(A)
__global__ void real_kernel(
    const cuDoubleComplex* A,
    double* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuCreal(A[idx]);
    }
}

// Imaginary part: C = imag(A)
__global__ void imag_kernel(
    const cuDoubleComplex* A,
    double* C,
    size_t n
) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = cuCimag(A[idx]);
    }
}

// ========== Matrix Operations ==========

// Transpose (with conjugate): B = A'
__global__ void transpose_conj_kernel(
    const cuDoubleComplex* A,
    cuDoubleComplex* B,
    size_t rows,
    size_t cols
) {
    size_t i = blockIdx.y * blockDim.y + threadIdx.y;
    size_t j = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (i < rows && j < cols) {
        // A is column-major: A[i + j*rows]
        // B is column-major: B[j + i*cols]
        B[j + i*cols] = cuConj(A[i + j*rows]);
    }
}

// Transpose (no conjugate): B = A.'
__global__ void transpose_kernel(
    const cuDoubleComplex* A,
    cuDoubleComplex* B,
    size_t rows,
    size_t cols
) {
    size_t i = blockIdx.y * blockDim.y + threadIdx.y;
    size_t j = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (i < rows && j < cols) {
        B[j + i*cols] = A[i + j*rows];
    }
}

// ========== Reduction Kernels ==========

// Sum reduction (complex)
__global__ void sum_reduction_kernel(
    const cuDoubleComplex* input,
    cuDoubleComplex* output,
    size_t n
) {
    extern __shared__ cuDoubleComplex sdata[];
    
    size_t tid = threadIdx.x;
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Load data into shared memory
    sdata[tid] = (idx < n) ? input[idx] : make_cuDoubleComplex(0.0, 0.0);
    __syncthreads();
    
    // Reduction in shared memory
    for (size_t s = blockDim.x/2; s > 0; s >>= 1) {
        if (tid < s) {
            sdata[tid] = cuCadd(sdata[tid], sdata[tid + s]);
        }
        __syncthreads();
    }
    
    // Write result for this block
    if (tid == 0) {
        output[blockIdx.x] = sdata[0];
    }
}

// Norm squared (for Frobenius norm)
__global__ void norm_squared_kernel(
    const cuDoubleComplex* input,
    double* output,
    size_t n
) {
    extern __shared__ double sdata[];
    
    size_t tid = threadIdx.x;
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Compute |z|^2 and load into shared memory
    if (idx < n) {
        double re = cuCreal(input[idx]);
        double im = cuCimag(input[idx]);
        sdata[tid] = re*re + im*im;
    } else {
        sdata[tid] = 0.0;
    }
    __syncthreads();
    
    // Reduction
    for (size_t s = blockDim.x/2; s > 0; s >>= 1) {
        if (tid < s) {
            sdata[tid] += sdata[tid + s];
        }
        __syncthreads();
    }
    
    if (tid == 0) {
        output[blockIdx.x] = sdata[0];
    }
}

// ========== Host-callable wrappers ==========

extern "C" {

void gpu_add(
    const cuDoubleComplex* A,
    const cuDoubleComplex* B,
    cuDoubleComplex* C,
    size_t n
) {
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    add_kernel<<<blocks, threads>>>(A, B, C, n);
    cudaDeviceSynchronize();
}

void gpu_sub(
    const cuDoubleComplex* A,
    const cuDoubleComplex* B,
    cuDoubleComplex* C,
    size_t n
) {
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    sub_kernel<<<blocks, threads>>>(A, B, C, n);
    cudaDeviceSynchronize();
}

void gpu_times(
    const cuDoubleComplex* A,
    const cuDoubleComplex* B,
    cuDoubleComplex* C,
    size_t n
) {
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    times_kernel<<<blocks, threads>>>(A, B, C, n);
    cudaDeviceSynchronize();
}

void gpu_conj(
    const cuDoubleComplex* A,
    cuDoubleComplex* C,
    size_t n
) {
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    conj_kernel<<<blocks, threads>>>(A, C, n);
    cudaDeviceSynchronize();
}

void gpu_abs(
    const cuDoubleComplex* A,
    double* C,
    size_t n
) {
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    abs_kernel<<<blocks, threads>>>(A, C, n);
    cudaDeviceSynchronize();
}

void gpu_transpose_conj(
    const cuDoubleComplex* A,
    cuDoubleComplex* B,
    size_t rows,
    size_t cols
) {
    dim3 threads(16, 16);
    dim3 blocks((cols + 15)/16, (rows + 15)/16);
    transpose_conj_kernel<<<blocks, threads>>>(A, B, rows, cols);
    cudaDeviceSynchronize();
}

// Matrix multiply using cuBLAS
void gpu_matmul(
    const cuDoubleComplex* A, size_t A_rows, size_t A_cols,
    const cuDoubleComplex* B, size_t B_rows, size_t B_cols,
    cuDoubleComplex* C
) {
    cublasHandle_t handle;
    cublasCreate(&handle);
    
    const cuDoubleComplex alpha = make_cuDoubleComplex(1.0, 0.0);
    const cuDoubleComplex beta = make_cuDoubleComplex(0.0, 0.0);
    
    // C = A * B
    // cuBLAS uses column-major, matching MATLAB
    cublasZgemm(
        handle,
        CUBLAS_OP_N, CUBLAS_OP_N,
        A_rows, B_cols, A_cols,
        &alpha,
        A, A_rows,
        B, B_rows,
        &beta,
        C, A_rows
    );
    
    cublasDestroy(handle);
    cudaDeviceSynchronize();
}

// Sum using reduction
cuDoubleComplex gpu_sum(const cuDoubleComplex* data, size_t n) {
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    
    cuDoubleComplex* d_temp;
    cudaMalloc(&d_temp, blocks * sizeof(cuDoubleComplex));
    
    sum_reduction_kernel<<<blocks, threads, threads*sizeof(cuDoubleComplex)>>>(
        data, d_temp, n
    );
    
    // Final reduction on CPU (small)
    cuDoubleComplex* h_temp = new cuDoubleComplex[blocks];
    cudaMemcpy(h_temp, d_temp, blocks*sizeof(cuDoubleComplex), cudaMemcpyDeviceToHost);
    
    cuDoubleComplex result = make_cuDoubleComplex(0.0, 0.0);
    for (int i = 0; i < blocks; ++i) {
        result = cuCadd(result, h_temp[i]);
    }
    
    delete[] h_temp;
    cudaFree(d_temp);
    
    return result;
}

// Frobenius norm
double gpu_norm(const cuDoubleComplex* data, size_t n) {
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    
    double* d_temp;
    cudaMalloc(&d_temp, blocks * sizeof(double));
    
    norm_squared_kernel<<<blocks, threads, threads*sizeof(double)>>>(
        data, d_temp, n
    );
    
    double* h_temp = new double[blocks];
    cudaMemcpy(h_temp, d_temp, blocks*sizeof(double), cudaMemcpyDeviceToHost);
    
    double sum = 0.0;
    for (int i = 0; i < blocks; ++i) {
        sum += h_temp[i];
    }
    
    delete[] h_temp;
    cudaFree(d_temp);
    
    return sqrt(sum);
}

// FFT using cuFFT
void gpu_fft(cuDoubleComplex* data, size_t n) {
    cufftHandle plan;
    cufftPlan1d(&plan, n, CUFFT_Z2Z, 1);
    cufftExecZ2Z(plan, data, data, CUFFT_FORWARD);
    cufftDestroy(plan);
    cudaDeviceSynchronize();
}

void gpu_ifft(cuDoubleComplex* data, size_t n) {
    cufftHandle plan;
    cufftPlan1d(&plan, n, CUFFT_Z2Z, 1);
    cufftExecZ2Z(plan, data, data, CUFFT_INVERSE);
    cufftDestroy(plan);
    cudaDeviceSynchronize();
    
    // Scale by 1/n
    cuDoubleComplex scale = make_cuDoubleComplex(1.0/n, 0.0);
    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;
    scalar_mul_kernel<<<blocks, threads>>>(data, scale, data, n);
    cudaDeviceSynchronize();
}

} // extern "C"

} // namespace gpu
} // namespace matlabcpp
