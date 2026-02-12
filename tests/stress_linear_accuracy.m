% STRESS_LINEAR_ACCURACY.M - Linear Algebra Accuracy Validation
% Tests: Numerical accuracy of GPU operations vs CPU reference
%
% Usage: Run in MatLabC++ REPL
% Expected: All errors < 1e-10 (double precision)

fprintf('\n========================================\n');
fprintf('STRESS TEST: LINEAR ALGEBRA ACCURACY\n');
fprintf('========================================\n\n');

% Track errors
errors = struct();
test_count = 0;
pass_count = 0;

%% Test 1: Basic Arithmetic Accuracy
fprintf('Test 1: Basic arithmetic operations...\n');
N = 1000;
A = randn(N, N) + 1i*randn(N, N);
B = randn(N, N) + 1i*randn(N, N);
A_gpu = gpu(A);
B_gpu = gpu(B);

% Addition
C_cpu = A + B;
C_gpu = cpu(A_gpu + B_gpu);
err_add = norm(C_cpu - C_gpu, 'fro') / norm(C_cpu, 'fro');
fprintf('  Addition error:           %.2e', err_add);
test_count = test_count + 1;
if err_add < 1e-14
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.addition = err_add;

% Subtraction
C_cpu = A - B;
C_gpu = cpu(A_gpu - B_gpu);
err_sub = norm(C_cpu - C_gpu, 'fro') / norm(C_cpu, 'fro');
fprintf('  Subtraction error:        %.2e', err_sub);
test_count = test_count + 1;
if err_sub < 1e-14
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.subtraction = err_sub;

% Element-wise multiply
C_cpu = A .* B;
C_gpu = cpu(A_gpu .* B_gpu);
err_times = norm(C_cpu - C_gpu, 'fro') / norm(C_cpu, 'fro');
fprintf('  Element-wise multiply:    %.2e', err_times);
test_count = test_count + 1;
if err_times < 1e-14
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.times = err_times;

% Matrix multiply
C_cpu = A * B;
C_gpu = cpu(A_gpu * B_gpu);
err_matmul = norm(C_cpu - C_gpu, 'fro') / norm(C_cpu, 'fro');
fprintf('  Matrix multiply:          %.2e', err_matmul);
test_count = test_count + 1;
if err_matmul < 1e-12  % Slightly relaxed for accumulation
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.matmul = err_matmul;

%% Test 2: Complex Operations Accuracy
fprintf('\nTest 2: Complex-specific operations...\n');

% Conjugate
C_cpu = conj(A);
C_gpu = cpu(conj(A_gpu));
err_conj = norm(C_cpu - C_gpu, 'fro') / norm(C_cpu, 'fro');
fprintf('  Conjugate:                %.2e', err_conj);
test_count = test_count + 1;
if err_conj < 1e-15
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.conjugate = err_conj;

% Transpose (conjugate transpose)
C_cpu = A';
C_gpu = cpu(A_gpu');
err_trans = norm(C_cpu - C_gpu, 'fro') / norm(C_cpu, 'fro');
fprintf('  Conjugate transpose:      %.2e', err_trans);
test_count = test_count + 1;
if err_trans < 1e-15
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.transpose = err_trans;

% Magnitude
C_cpu = abs(A);
C_gpu = cpu(abs(A_gpu));
err_abs = norm(C_cpu - C_gpu, 'fro') / norm(C_cpu, 'fro');
fprintf('  Absolute value:           %.2e', err_abs);
test_count = test_count + 1;
if err_abs < 1e-14
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.abs = err_abs;

% Phase
C_cpu = angle(A);
C_gpu = cpu(angle(A_gpu));
err_angle = norm(C_cpu - C_gpu, 'fro') / (2*pi);  % Normalize by max phase
fprintf('  Phase angle:              %.2e', err_angle);
test_count = test_count + 1;
if err_angle < 1e-14
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.angle = err_angle;

%% Test 3: Reduction Operations Accuracy
fprintf('\nTest 3: Reduction operations...\n');

% Sum
s_cpu = sum(A(:));
s_gpu = cpu(sum(A_gpu(:)));
err_sum = abs(s_cpu - s_gpu) / abs(s_cpu);
fprintf('  Sum:                      %.2e', err_sum);
test_count = test_count + 1;
if err_sum < 1e-12
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.sum = err_sum;

% Mean
m_cpu = mean(A(:));
m_gpu = cpu(mean(A_gpu(:)));
err_mean = abs(m_cpu - m_gpu) / abs(m_cpu);
fprintf('  Mean:                     %.2e', err_mean);
test_count = test_count + 1;
if err_mean < 1e-12
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.mean = err_mean;

% Frobenius norm
n_cpu = norm(A, 'fro');
n_gpu = cpu(norm(A_gpu, 'fro'));
err_norm = abs(n_cpu - n_gpu) / n_cpu;
fprintf('  Frobenius norm:           %.2e', err_norm);
test_count = test_count + 1;
if err_norm < 1e-12
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.norm = err_norm;

%% Test 4: Matrix Decomposition Accuracy
fprintf('\nTest 4: Matrix decompositions...\n');

% QR decomposition
[Q_cpu, R_cpu] = qr(A);
[Q_gpu, R_gpu] = qr(A_gpu);
Q_gpu = cpu(Q_gpu);
R_gpu = cpu(R_gpu);

% Check orthogonality of Q
I_cpu = Q_cpu' * Q_cpu;
I_gpu = Q_gpu' * Q_gpu;
err_qr_ortho = norm(I_gpu - eye(N), 'fro');
fprintf('  QR orthogonality:         %.2e', err_qr_ortho);
test_count = test_count + 1;
if err_qr_ortho < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.qr_ortho = err_qr_ortho;

% Check reconstruction A = Q*R
A_recon_cpu = Q_cpu * R_cpu;
A_recon_gpu = Q_gpu * R_gpu;
err_qr_recon = norm(A - A_recon_gpu, 'fro') / norm(A, 'fro');
fprintf('  QR reconstruction:        %.2e', err_qr_recon);
test_count = test_count + 1;
if err_qr_recon < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.qr_recon = err_qr_recon;

% LU decomposition
[L_cpu, U_cpu, P_cpu] = lu(A);
[L_gpu, U_gpu, P_gpu] = lu(A_gpu);
L_gpu = cpu(L_gpu);
U_gpu = cpu(U_gpu);
P_gpu = cpu(P_gpu);

% Check reconstruction P*A = L*U
PA_cpu = P_cpu * A;
LU_gpu = L_gpu * U_gpu;
err_lu = norm(P_gpu*A - LU_gpu, 'fro') / norm(A, 'fro');
fprintf('  LU reconstruction:        %.2e', err_lu);
test_count = test_count + 1;
if err_lu < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.lu = err_lu;

% SVD
N_svd = 500;  % Smaller for speed
A_svd = randn(N_svd, N_svd) + 1i*randn(N_svd, N_svd);
A_svd_gpu = gpu(A_svd);

[U_cpu, S_cpu, V_cpu] = svd(A_svd);
[U_gpu, S_gpu, V_gpu] = svd(A_svd_gpu);
U_gpu = cpu(U_gpu);
S_gpu = cpu(S_gpu);
V_gpu = cpu(V_gpu);

% Check reconstruction A = U*S*V'
A_recon_svd = U_gpu * diag(S_gpu) * V_gpu';
err_svd = norm(A_svd - A_recon_svd, 'fro') / norm(A_svd, 'fro');
fprintf('  SVD reconstruction:       %.2e', err_svd);
test_count = test_count + 1;
if err_svd < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.svd = err_svd;

% Check singular values match
err_sv = norm(S_cpu - S_gpu) / norm(S_cpu);
fprintf('  SVD singular values:      %.2e', err_sv);
test_count = test_count + 1;
if err_sv < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.sv = err_sv;

%% Test 5: Linear System Solving Accuracy
fprintf('\nTest 5: Linear system solving...\n');

N_solve = 1000;
A_solve = randn(N_solve, N_solve) + 1i*randn(N_solve, N_solve);
A_solve = A_solve + N_solve*eye(N_solve);  % Well-conditioned
b = randn(N_solve, 1) + 1i*randn(N_solve, 1);

A_solve_gpu = gpu(A_solve);
b_gpu = gpu(b);

% Solve
x_cpu = A_solve \ b;
x_gpu = cpu(A_solve_gpu \ b_gpu);

% Check solution
residual_cpu = norm(A_solve*x_cpu - b) / norm(b);
residual_gpu = norm(A_solve*x_gpu - b) / norm(b);
fprintf('  CPU residual:             %.2e ✓\n', residual_cpu);
fprintf('  GPU residual:             %.2e', residual_gpu);
test_count = test_count + 1;
if residual_gpu < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.solve = residual_gpu;

% Check solution difference
err_solve = norm(x_cpu - x_gpu) / norm(x_cpu);
fprintf('  Solution difference:      %.2e', err_solve);
test_count = test_count + 1;
if err_solve < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.solve_diff = err_solve;

%% Test 6: FFT Accuracy
fprintf('\nTest 6: FFT accuracy...\n');

N_fft = 10000;
x = randn(N_fft, 1) + 1i*randn(N_fft, 1);
x_gpu = gpu(x);

% Forward FFT
X_cpu = fft(x);
X_gpu = cpu(fft(x_gpu));
err_fft = norm(X_cpu - X_gpu) / norm(X_cpu);
fprintf('  FFT forward:              %.2e', err_fft);
test_count = test_count + 1;
if err_fft < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.fft = err_fft;

% Inverse FFT
x_back_cpu = ifft(X_cpu);
X_gpu_full = gpu(X_cpu);  % Use CPU result to test inverse only
x_back_gpu = cpu(ifft(X_gpu_full));
err_ifft = norm(x_back_cpu - x_back_gpu) / norm(x_back_cpu);
fprintf('  FFT inverse:              %.2e', err_ifft);
test_count = test_count + 1;
if err_ifft < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.ifft = err_ifft;

% Round-trip
x_roundtrip = cpu(ifft(fft(x_gpu)));
err_roundtrip = norm(x - x_roundtrip) / norm(x);
fprintf('  FFT round-trip:           %.2e', err_roundtrip);
test_count = test_count + 1;
if err_roundtrip < 1e-10
    fprintf(' ✓\n');
    pass_count = pass_count + 1;
else
    fprintf(' ✗\n');
end
errors.fft_roundtrip = err_roundtrip;

%% Summary
fprintf('\n========================================\n');
fprintf('LINEAR ALGEBRA ACCURACY TEST COMPLETE\n');
fprintf('========================================\n');

fprintf('Tests passed: %d / %d (%.1f%%)\n', pass_count, test_count, 100*pass_count/test_count);

% Find worst error
field_names = fieldnames(errors);
max_error = 0;
worst_test = '';
for i = 1:length(field_names)
    if errors.(field_names{i}) > max_error
        max_error = errors.(field_names{i});
        worst_test = field_names{i};
    end
end

fprintf('Worst error: %.2e (%s)\n', max_error, worst_test);

if pass_count == test_count
    fprintf('\nStatus: ✓ ALL TESTS PASSED\n');
    fprintf('GPU accuracy: EXCELLENT (double precision)\n');
elseif pass_count >= test_count * 0.9
    fprintf('\nStatus: ⚠ MOSTLY PASSED\n');
    fprintf('GPU accuracy: GOOD (minor issues)\n');
else
    fprintf('\nStatus: ✗ FAILURES DETECTED\n');
    fprintf('GPU accuracy: POOR (needs investigation)\n');
end

fprintf('========================================\n\n');

% Cleanup
clear all;
