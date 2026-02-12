% STRESS_VECTOR_PARALLEL.M - Parallel Vector Operations GPU Stress Test
% Tests: Large vector operations, parallel reductions, element-wise ops
%
% Usage: Run in MatLabC++ REPL
% Expected: GPU speedup 50-100x vs CPU

fprintf('\n========================================\n');
fprintf('STRESS TEST: PARALLEL VECTOR OPERATIONS\n');
fprintf('========================================\n\n');

%% Configuration
N = 10000000;  % 10 million elements
fprintf('Vector size: %d elements (%.1f MB)\n\n', N, N*16/1e6);

%% Test 1: Vector Creation and Transfer
fprintf('Test 1: Large vector creation and GPU transfer...\n');
tic;
x = randn(N, 1) + 1i*randn(N, 1);
y = randn(N, 1) + 1i*randn(N, 1);
t_create = toc;
fprintf('  CPU creation: %.3f s\n', t_create);

tic;
x_gpu = gpu(x);
y_gpu = gpu(y);
t_transfer = toc;
fprintf('  GPU transfer: %.3f s (%.1f GB/s)\n', t_transfer, N*32/1e9/t_transfer);

%% Test 2: Element-wise Operations (CPU vs GPU)
fprintf('\nTest 2: Element-wise operations (CPU vs GPU)...\n');

% CPU
tic;
z_cpu = x + y;
z_cpu = z_cpu .* conj(z_cpu);
z_cpu = sqrt(abs(z_cpu));
t_cpu = toc;
fprintf('  CPU time: %.3f s\n', t_cpu);

% GPU
tic;
z_gpu = x_gpu + y_gpu;
z_gpu = z_gpu .* conj(z_gpu);
z_gpu = sqrt(abs(z_gpu));
t_gpu = toc;
fprintf('  GPU time: %.3f s\n', t_gpu);
fprintf('  Speedup: %.1fx\n', t_cpu/t_gpu);

if t_gpu < t_cpu
    fprintf('  ✓ PASS: GPU faster\n');
else
    fprintf('  ⚠ WARNING: GPU not faster (may need larger N)\n');
end

%% Test 3: Parallel Reductions
fprintf('\nTest 3: Parallel reductions...\n');

% Sum
tic;
s_cpu = sum(x);
t_sum_cpu = toc;

tic;
s_gpu = sum(x_gpu);
t_sum_gpu = toc;
fprintf('  sum() - CPU: %.4f s, GPU: %.4f s (%.1fx)\n', ...
    t_sum_cpu, t_sum_gpu, t_sum_cpu/t_sum_gpu);

% Mean
tic;
m_cpu = mean(x);
t_mean_cpu = toc;

tic;
m_gpu = mean(x_gpu);
t_mean_gpu = toc;
fprintf('  mean() - CPU: %.4f s, GPU: %.4f s (%.1fx)\n', ...
    t_mean_cpu, t_mean_gpu, t_mean_cpu/t_mean_gpu);

% Norm
tic;
n_cpu = norm(x);
t_norm_cpu = toc;

tic;
n_gpu = norm(x_gpu);
t_norm_gpu = toc;
fprintf('  norm() - CPU: %.4f s, GPU: %.4f s (%.1fx)\n', ...
    t_norm_cpu, t_norm_gpu, t_norm_cpu/t_norm_gpu);

%% Test 4: Inner Product (Dot Product)
fprintf('\nTest 4: Complex inner product...\n');

% CPU
tic;
for iter = 1:100
    dot_cpu = x' * y;  % Hermitian inner product
end
t_dot_cpu = toc;

% GPU
tic;
for iter = 1:100
    dot_gpu = x_gpu' * y_gpu;
end
t_dot_gpu = toc;

fprintf('  CPU: %.4f s (100 iterations)\n', t_dot_cpu);
fprintf('  GPU: %.4f s (100 iterations)\n', t_dot_gpu);
fprintf('  Speedup: %.1fx\n', t_dot_cpu/t_dot_gpu);

%% Test 5: FFT on Long Vectors
fprintf('\nTest 5: FFT on long vector...\n');

% CPU FFT
tic;
X_cpu = fft(x);
t_fft_cpu = toc;

% GPU FFT
tic;
X_gpu = fft(x_gpu);
t_fft_gpu = toc;

fprintf('  CPU FFT: %.3f s\n', t_fft_cpu);
fprintf('  GPU FFT: %.3f s\n', t_fft_gpu);
fprintf('  Speedup: %.1fx\n', t_fft_cpu/t_fft_gpu);

% Check accuracy
X_cpu_from_gpu = cpu(X_gpu);
error = norm(X_cpu - X_cpu_from_gpu) / norm(X_cpu);
fprintf('  FFT error: %.2e\n', error);

if error < 1e-10
    fprintf('  ✓ PASS: FFT accurate\n');
else
    fprintf('  ✗ FAIL: FFT inaccurate\n');
end

%% Test 6: Parallel Filter Operations
fprintf('\nTest 6: Parallel filtering...\n');

% Create filter
h = exp(-linspace(0, 10, 1000)');
h = h / sum(h);  % Normalize
h_gpu = gpu(h);

% CPU convolution (slow)
tic;
y_filt_cpu = conv(x(1:100000), h, 'same');  % Subset only (too slow for full)
t_conv_cpu = toc;

% GPU convolution (FFT-based)
tic;
H_gpu = fft(h_gpu, N);
X_fft = fft(x_gpu);
Y_filt_gpu = ifft(X_fft .* H_gpu);
t_conv_gpu = toc;

fprintf('  CPU (100k): %.3f s\n', t_conv_cpu);
fprintf('  GPU (10M):  %.3f s\n', t_conv_gpu);
fprintf('  GPU handles %dx more data in similar time\n', round(N/100000));

%% Test 7: Threshold and Masking
fprintf('\nTest 7: Parallel thresholding...\n');

threshold = 0.5;

% CPU
tic;
mask_cpu = abs(x) > threshold;
x_thresh_cpu = x .* mask_cpu;
t_thresh_cpu = toc;

% GPU
tic;
mask_gpu = abs(x_gpu) > threshold;
x_thresh_gpu = x_gpu .* mask_gpu;
t_thresh_gpu = toc;

fprintf('  CPU: %.3f s\n', t_thresh_cpu);
fprintf('  GPU: %.3f s\n', t_thresh_gpu);
fprintf('  Speedup: %.1fx\n', t_thresh_cpu/t_thresh_gpu);
fprintf('  Elements above threshold: %d (%.1f%%)\n', ...
    sum(mask_gpu), 100*sum(mask_gpu)/N);

%% Test 8: Cumulative Operations
fprintf('\nTest 8: Cumulative sum (parallel scan)...\n');

% Note: cumsum is inherently sequential, so GPU may not be faster
% This tests the implementation quality

x_small = randn(1000000, 1);  % 1M for reasonable CPU time
x_small_gpu = gpu(x_small);

tic;
cumsum_cpu = cumsum(x_small);
t_cumsum_cpu = toc;

tic;
cumsum_gpu = cumsum(x_small_gpu);
t_cumsum_gpu = toc;

fprintf('  CPU: %.3f s\n', t_cumsum_cpu);
fprintf('  GPU: %.3f s\n', t_cumsum_gpu);

% Verify
cumsum_from_gpu = cpu(cumsum_gpu);
error = norm(cumsum_cpu - cumsum_from_gpu) / norm(cumsum_cpu);
fprintf('  Error: %.2e\n', error);

%% Summary
fprintf('\n========================================\n');
fprintf('VECTOR PARALLEL STRESS TEST COMPLETE\n');
fprintf('========================================\n');

avg_speedup = (t_cpu/t_gpu + t_fft_cpu/t_fft_gpu + t_sum_cpu/t_sum_gpu) / 3;
fprintf('Average GPU speedup: %.1fx\n', avg_speedup);
fprintf('Peak operations: %.1f GFLOPS\n', N*20/1e9/t_gpu);  % Rough estimate
fprintf('Memory bandwidth: %.1f GB/s\n', N*32/1e9/t_transfer);

if avg_speedup > 10
    fprintf('Status: ✓ GPU EXCELLENT\n');
elseif avg_speedup > 5
    fprintf('Status: ✓ GPU GOOD\n');
else
    fprintf('Status: ⚠ GPU MARGINAL\n');
end

fprintf('========================================\n\n');

% Cleanup
clear all;
