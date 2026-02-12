% STRESS_MATRIX_PARALLEL.M - Parallel Matrix Operations GPU Stress Test
% Tests: Large matrix multiply, decompositions, parallel algorithms
%
% Usage: Run in MatLabC++ REPL
% Expected: GPU speedup 50-150x vs CPU for large matrices

fprintf('\n========================================\n');
fprintf('STRESS TEST: PARALLEL MATRIX OPERATIONS\n');
fprintf('========================================\n\n');
% Change to 500% to 2000% speedup expectation based on GPU and matrix size  
%% Configuration
sizes = [500, 1000, 2000, 4000];
fprintf('Testing matrix sizes: ');
fprintf('%d ', sizes);
fprintf('\n\n');

%% Test 1: Matrix Multiplication Scaling
fprintf('Test 1: Matrix multiplication scaling (CPU vs GPU)...\n');
fprintf('%-8s %-12s %-12s %-10s\n', 'Size', 'CPU (s)', 'GPU (s)', 'Speedup');
fprintf('%-8s %-12s %-12s %-10s\n', '----', '-------', '-------', '-------');

speedups = zeros(length(sizes), 1);

for i = 1:length(sizes)
    N = sizes(i);
    
    % Create complex matrices
    A = randn(N, N) + 1i*randn(N, N);
    B = randn(N, N) + 1i*randn(N, N);
    
    % CPU
    tic;
    C_cpu = A * B;
    t_cpu = toc;
    
    % GPU
    A_gpu = gpu(A);
    B_gpu = gpu(B);
    tic;
    C_gpu = A_gpu * B_gpu;
    t_gpu = toc;
    
    speedup = t_cpu / t_gpu;
    speedups(i) = speedup;
    
    fprintf('%-8d %-12.4f %-12.4f %-10.1f\n', N, t_cpu, t_gpu, speedup);
    
    % Verify accuracy
    C_from_gpu = cpu(C_gpu);
    error = norm(C_cpu - C_from_gpu, 'fro') / norm(C_cpu, 'fro');
    if error > 1e-10
        fprintf('  ⚠ WARNING: Error %.2e for N=%d\n', error, N);
    end
end

fprintf('\nAverage speedup: %.1fx\n', mean(speedups));
if mean(speedups) > 50
    fprintf('✓ PASS: Excellent GPU acceleration\n');
end

%% Test 2: Matrix-Matrix Operations (Large Scale)
fprintf('\nTest 2: Large-scale matrix operations...\n');
N = 2000;
fprintf('Matrix size: %dx%d (%.1f MB)\n', N, N, N*N*16/1e6);

A = randn(N, N) + 1i*randn(N, N);
B = randn(N, N) + 1i*randn(N, N);
A_gpu = gpu(A);
B_gpu = gpu(B);

fprintf('\nOperation benchmarks:\n');

% Addition
tic;
C = A + B;
t_add_cpu = toc;
tic;
C_gpu = A_gpu + B_gpu;
t_add_gpu = toc;
fprintf('  A + B:    CPU %.3fs, GPU %.3fs (%.1fx)\n', ...
    t_add_cpu, t_add_gpu, t_add_cpu/t_add_gpu);

% Element-wise multiply
tic;
C = A .* B;
t_times_cpu = toc;
tic;
C_gpu = A_gpu .* B_gpu;
t_times_gpu = toc;
fprintf('  A .* B:   CPU %.3fs, GPU %.3fs (%.1fx)\n', ...
    t_times_cpu, t_times_gpu, t_times_cpu/t_times_gpu);

% Transpose (conjugate)
tic;
C = A';
t_trans_cpu = toc;
tic;
C_gpu = A_gpu';
t_trans_gpu = toc;
fprintf('  A'':       CPU %.3fs, GPU %.3fs (%.1fx)\n', ...
    t_trans_cpu, t_trans_gpu, t_trans_cpu/t_trans_gpu);

% Complex conjugate
tic;
C = conj(A);
t_conj_cpu = toc;
tic;
C_gpu = conj(A_gpu);
t_conj_gpu = toc;
fprintf('  conj(A):  CPU %.3fs, GPU %.3fs (%.1fx)\n', ...
    t_conj_cpu, t_conj_gpu, t_conj_cpu/t_conj_gpu);

%% Test 3: Matrix Decompositions (cuSOLVER)
fprintf('\nTest 3: Matrix decompositions (GPU-accelerated)...\n');
N = 1000;
A = randn(N, N) + 1i*randn(N, N);
A_gpu = gpu(A);

% QR Decomposition
fprintf('  QR decomposition...\n');
tic;
[Q_cpu, R_cpu] = qr(A);
t_qr_cpu = toc;

tic;
[Q_gpu, R_gpu] = qr(A_gpu);
t_qr_gpu = toc;

fprintf('    CPU: %.3f s, GPU: %.3f s (%.1fx speedup)\n', ...
    t_qr_cpu, t_qr_gpu, t_qr_cpu/t_qr_gpu);

% Verify: Q should be unitary
Q_from_gpu = cpu(Q_gpu);
R_from_gpu = cpu(R_gpu);
I_check = Q_from_gpu' * Q_from_gpu;
error_ortho = norm(I_check - eye(N), 'fro');
error_recon = norm(A - Q_from_gpu*R_from_gpu, 'fro') / norm(A, 'fro');
fprintf('    Orthogonality error: %.2e\n', error_ortho);
fprintf('    Reconstruction error: %.2e\n', error_recon);

if error_ortho < 1e-10 && error_recon < 1e-10
    fprintf('    ✓ PASS: QR accurate\n');
end

% LU Decomposition
fprintf('  LU decomposition...\n');
tic;
[L_cpu, U_cpu, P_cpu] = lu(A);
t_lu_cpu = toc;

tic;
[L_gpu, U_gpu, P_gpu] = lu(A_gpu);
t_lu_gpu = toc;

fprintf('    CPU: %.3f s, GPU: %.3f s (%.1fx speedup)\n', ...
    t_lu_cpu, t_lu_gpu, t_lu_cpu/t_lu_gpu);

% SVD (Most expensive)
fprintf('  SVD (singular value decomposition)...\n');
N_svd = 500;  % Smaller for reasonable time
A_svd = randn(N_svd, N_svd) + 1i*randn(N_svd, N_svd);
A_svd_gpu = gpu(A_svd);

tic;
[U_cpu, S_cpu, V_cpu] = svd(A_svd);
t_svd_cpu = toc;

tic;
[U_gpu, S_gpu, V_gpu] = svd(A_svd_gpu);
t_svd_gpu = toc;

fprintf('    CPU: %.3f s, GPU: %.3f s (%.1fx speedup)\n', ...
    t_svd_cpu, t_svd_gpu, t_svd_cpu/t_svd_gpu);

%% Test 4: Solving Linear Systems
fprintf('\nTest 4: Solving linear systems (A\\b)...\n');
N = 2000;
A = randn(N, N) + 1i*randn(N, N);
b = randn(N, 1) + 1i*randn(N, 1);

% Make A well-conditioned
A = A + N*eye(N);

A_gpu = gpu(A);
b_gpu = gpu(b);

% CPU solve
tic;
x_cpu = A \ b;
t_solve_cpu = toc;

% GPU solve
tic;
x_gpu = A_gpu \ b_gpu;
t_solve_gpu = toc;

fprintf('  CPU: %.3f s\n', t_solve_cpu);
fprintf('  GPU: %.3f s\n', t_solve_gpu);
fprintf('  Speedup: %.1fx\n', t_solve_cpu/t_solve_gpu);

% Check solution
x_from_gpu = cpu(x_gpu);
residual_cpu = norm(A*x_cpu - b) / norm(b);
residual_gpu = norm(A*x_from_gpu - b) / norm(b);
fprintf('  CPU residual: %.2e\n', residual_cpu);
fprintf('  GPU residual: %.2e\n', residual_gpu);

if residual_gpu < 1e-10
    fprintf('  ✓ PASS: Solution accurate\n');
end

%% Test 5: Parallel Power Iteration (Eigenvalue)
fprintf('\nTest 5: Power iteration (largest eigenvalue)...\n');
N = 1000;
A = randn(N, N) + 1i*randn(N, N);
A = A + A';  % Make Hermitian
A_gpu = gpu(A);

% Initial guess
v = randn(N, 1) + 1i*randn(N, 1);
v = v / norm(v);
v_gpu = gpu(v);

% CPU power iteration
tic;
for iter = 1:50
    v = A * v;
    v = v / norm(v);
end
lambda_cpu = v' * (A * v);
t_power_cpu = toc;

% GPU power iteration
v_gpu = gpu(v);  % Reset
tic;
for iter = 1:50
    v_gpu = A_gpu * v_gpu;
    v_gpu = v_gpu / norm(v_gpu);
end
lambda_gpu = v_gpu' * (A_gpu * v_gpu);
t_power_gpu = toc;

fprintf('  CPU: %.3f s (lambda = %.4f)\n', t_power_cpu, abs(lambda_cpu));
fprintf('  GPU: %.3f s (lambda = %.4f)\n', t_power_gpu, abs(lambda_gpu));
fprintf('  Speedup: %.1fx\n', t_power_cpu/t_power_gpu);

%% Test 6: Batch Matrix Operations
fprintf('\nTest 6: Batch matrix operations...\n');
N = 500;
num_matrices = 100;

fprintf('  Processing %d matrices of size %dx%d...\n', num_matrices, N, N);

% Create batch
A_batch = cell(num_matrices, 1);
for i = 1:num_matrices
    A_batch{i} = randn(N, N) + 1i*randn(N, N);
end

% CPU batch multiply
tic;
C_batch_cpu = cell(num_matrices, 1);
for i = 1:num_matrices
    C_batch_cpu{i} = A_batch{i} * A_batch{i}';
end
t_batch_cpu = toc;

% GPU batch multiply
A_gpu_batch = cellfun(@gpu, A_batch, 'UniformOutput', false);
tic;
C_batch_gpu = cell(num_matrices, 1);
for i = 1:num_matrices
    C_batch_gpu{i} = A_gpu_batch{i} * A_gpu_batch{i}';
end
t_batch_gpu = toc;

fprintf('  CPU: %.3f s (%.1f ms per matrix)\n', t_batch_cpu, t_batch_cpu*1000/num_matrices);
fprintf('  GPU: %.3f s (%.1f ms per matrix)\n', t_batch_gpu, t_batch_gpu*1000/num_matrices);
fprintf('  Speedup: %.1fx\n', t_batch_cpu/t_batch_gpu);

%% Summary
fprintf('\n========================================\n');
fprintf('MATRIX PARALLEL STRESS TEST COMPLETE\n');
fprintf('========================================\n');

fprintf('Matrix multiply: %.1fx average speedup\n', mean(speedups));
fprintf('QR decomposition: %.1fx speedup\n', t_qr_cpu/t_qr_gpu);
fprintf('LU decomposition: %.1fx speedup\n', t_lu_cpu/t_lu_gpu);
fprintf('SVD: %.1fx speedup\n', t_svd_cpu/t_svd_gpu);
fprintf('Linear solve: %.1fx speedup\n', t_solve_cpu/t_solve_gpu);

avg_speedup = mean([mean(speedups), t_qr_cpu/t_qr_gpu, t_lu_cpu/t_lu_gpu, ...
                    t_svd_cpu/t_svd_gpu, t_solve_cpu/t_solve_gpu]);
fprintf('\nOverall average: %.1fx GPU speedup\n', avg_speedup);

if avg_speedup > 50
    fprintf('Status: ✓ EXCELLENT GPU PERFORMANCE\n');
elseif avg_speedup > 20
    fprintf('Status: ✓ GOOD GPU PERFORMANCE\n');
else
    fprintf('Status: ⚠ MARGINAL GPU PERFORMANCE\n');
end

fprintf('========================================\n\n');

% Cleanup
clear all;
