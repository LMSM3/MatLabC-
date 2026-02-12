% STRESS_MATRIX_PARALLEL_CPU_ONLY.M - CPU-Only Matrix Baseline
% Runs matrix tests in CPU mode only (no GPU required)
% Use this to establish baseline performance before GPU comparison
%
% Usage: ./build/mlab++ < tests/stress_matrix_parallel_cpu_only.m

fprintf('\n========================================\n');
fprintf('STRESS TEST: MATRIX OPERATIONS (CPU ONLY)\n');
fprintf('========================================\n\n');

%% Configuration
sizes = [500, 1000, 2000];  % Reduced for CPU-only
fprintf('Testing matrix sizes: ');
fprintf('%d ', sizes);
fprintf('\n');
fprintf('Mode: CPU ONLY (no GPU)\n\n');

%% Test 1: Matrix Multiplication Scaling
fprintf('Test 1: Matrix multiplication scaling...\n');
fprintf('%-8s %-12s %-15s\n', 'Size', 'Time (s)', 'GFLOPS');
fprintf('%-8s %-12s %-15s\n', '----', '-------', '------');

times = zeros(length(sizes), 1);

for i = 1:length(sizes)
    N = sizes(i);
    
    % Create complex matrices
    fprintf('  Creating %dx%d complex matrices... ', N, N);
    A = randn(N, N) + 1i*randn(N, N);
    B = randn(N, N) + 1i*randn(N, N);
    fprintf('done\n');
    
    % CPU multiply
    fprintf('  Computing A * B... ');
    tic;
    C = A * B;
    t = toc;
    fprintf('done\n');
    
    times(i) = t;
    
    % Calculate GFLOPS (8*N^3 for complex matmul)
    flops = 8 * N^3;
    gflops = flops / t / 1e9;
    
    fprintf('%-8d %-12.4f %-15.2f\n', N, t, gflops);
end

fprintf('\n');

%% Test 2: Matrix Operations (N=1000)
fprintf('Test 2: Matrix operations (1000x1000)...\n');
N = 1000;
A = randn(N, N) + 1i*randn(N, N);
B = randn(N, N) + 1i*randn(N, N);

% Addition
fprintf('  A + B... ');
tic;
C = A + B;
t_add = toc;
fprintf('%.3f s\n', t_add);

% Element-wise multiply
fprintf('  A .* B... ');
tic;
C = A .* B;
t_times = toc;
fprintf('%.3f s\n', t_times);

% Transpose (conjugate)
fprintf('  A''... ');
tic;
C = A';
t_trans = toc;
fprintf('%.3f s\n', t_trans);

% Complex conjugate
fprintf('  conj(A)... ');
tic;
C = conj(A);
t_conj = toc;
fprintf('%.3f s\n', t_conj);

% Matrix multiply
fprintf('  A * B... ');
tic;
C = A * B;
t_mult = toc;
fprintf('%.3f s\n', t_mult);

fprintf('\n');

%% Test 3: Matrix Decompositions
fprintf('Test 3: Matrix decompositions (1000x1000)...\n');

% QR Decomposition
fprintf('  QR decomposition... ');
tic;
[Q, R] = qr(A);
t_qr = toc;
fprintf('%.3f s\n', t_qr);

% Verify
I_check = Q' * Q;
error_ortho = norm(I_check - eye(N), 'fro');
error_recon = norm(A - Q*R, 'fro') / norm(A, 'fro');
fprintf('    Orthogonality error: %.2e\n', error_ortho);
fprintf('    Reconstruction error: %.2e\n', error_recon);

% LU Decomposition
fprintf('  LU decomposition... ');
tic;
[L, U, P] = lu(A);
t_lu = toc;
fprintf('%.3f s\n', t_lu);

% SVD
fprintf('  SVD (500x500)... ');
N_svd = 500;
A_svd = randn(N_svd, N_svd) + 1i*randn(N_svd, N_svd);
tic;
[U, S, V] = svd(A_svd);
t_svd = toc;
fprintf('%.3f s\n', t_svd);

fprintf('\n');

%% Test 4: Linear System Solving
fprintf('Test 4: Linear system solving (1000x1000)...\n');
N = 1000;
A_sys = randn(N, N) + 1i*randn(N, N);
b = randn(N, 1) + 1i*randn(N, 1);

% Make well-conditioned
A_sys = A_sys + N*eye(N);

fprintf('  Solving A\\b... ');
tic;
x = A_sys \ b;
t_solve = toc;
fprintf('%.3f s\n', t_solve);

% Check solution
residual = norm(A_sys*x - b) / norm(b);
fprintf('  Residual: %.2e\n', residual);

if residual < 1e-10
    fprintf('  ✓ PASS: Solution accurate\n');
end

fprintf('\n');

%% Test 5: Batch Operations
fprintf('Test 5: Batch matrix operations...\n');
N = 500;
num_matrices = 50;  % Reduced for CPU

fprintf('  Processing %d matrices of size %dx%d...\n', num_matrices, N, N);

% Create batch
A_batch = cell(num_matrices, 1);
for i = 1:num_matrices
    A_batch{i} = randn(N, N) + 1i*randn(N, N);
end

% Batch multiply
tic;
C_batch = cell(num_matrices, 1);
for i = 1:num_matrices
    C_batch{i} = A_batch{i} * A_batch{i}';
end
t_batch = toc;

fprintf('  Total: %.3f s (%.1f ms per matrix)\n', t_batch, t_batch*1000/num_matrices);

fprintf('\n');

%% Summary
fprintf('========================================\n');
fprintf('CPU BASELINE RESULTS\n');
fprintf('========================================\n');

fprintf('\nMatrix Multiply Performance:\n');
for i = 1:length(sizes)
    flops = 8 * sizes(i)^3;
    gflops = flops / times(i) / 1e9;
    fprintf('  %dx%d: %.2f GFLOPS\n', sizes(i), sizes(i), gflops);
end

fprintf('\nOperation Times (1000x1000):\n');
fprintf('  Addition:       %.3f s\n', t_add);
fprintf('  Element-wise:   %.3f s\n', t_times);
fprintf('  Transpose:      %.3f s\n', t_trans);
fprintf('  Conjugate:      %.3f s\n', t_conj);
fprintf('  Multiply:       %.3f s\n', t_mult);

fprintf('\nDecomposition Times (1000x1000):\n');
fprintf('  QR:             %.3f s\n', t_qr);
fprintf('  LU:             %.3f s\n', t_lu);
fprintf('  SVD (500x500):  %.3f s\n', t_svd);

fprintf('\nLinear Solve:      %.3f s\n', t_solve);
fprintf('Batch (50x500²):   %.3f s\n', t_batch);

fprintf('\n========================================\n');
fprintf('CPU baseline established ✓\n');
fprintf('Build GPU version for comparison!\n');
fprintf('========================================\n\n');

% Save results for comparison
save('cpu_baseline.mat', 'times', 't_add', 't_mult', 't_qr', 't_lu', 't_svd', 't_solve', 't_batch');
fprintf('Results saved to cpu_baseline.mat\n\n');
