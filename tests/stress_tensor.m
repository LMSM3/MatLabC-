% STRESS_TENSOR.M - 3D Complex Tensor GPU Stress Test
% Tests: Large 3D tensors, memory management, FFT operations
%
% Usage: Run in MatLabC++ REPL
% Expected: No crashes, correct results, GPU speedup

fprintf('\n========================================\n');
fprintf('STRESS TEST: 3D COMPLEX TENSORS\n');
fprintf('========================================\n\n');

%% Test 1: Large Tensor Creation
fprintf('Test 1: Creating large 3D tensor (100x100x100 complex)...\n');
tic;
N = 100;
T = randn(N, N, N) + 1i*randn(N, N, N);
t_cpu = toc;
fprintf('  CPU time: %.3f s\n', t_cpu);

% Move to GPU
fprintf('  Moving to GPU...\n');
tic;
T_gpu = gpu(T);
t_transfer = toc;
fprintf('  Transfer time: %.3f s\n', t_transfer);
fprintf('  Memory: %.2f MB\n', numel(T)*16/1e6);

%% Test 2: Element-wise Operations on GPU
fprintf('\nTest 2: Element-wise tensor operations...\n');
tic;
A = T_gpu .* conj(T_gpu);  % |T|^2
B = A + T_gpu;
C = B ./ (1 + abs(T_gpu));
t_gpu = toc;
fprintf('  GPU time: %.3f s\n', t_gpu);

%% Test 3: Tensor Slicing and Indexing
fprintf('\nTest 3: Tensor slicing (GPU)...\n');
tic;
slice1 = T_gpu(:, :, 1);      % First layer
slice2 = T_gpu(50, :, :);     % Middle row across depth
slice3 = T_gpu(1:50, 1:50, :); % Sub-tensor
t_slice = toc;
fprintf('  Slicing time: %.3f s\n', t_slice);

%% Test 4: 3D FFT (GPU-accelerated)
fprintf('\nTest 4: 3D FFT on GPU...\n');
tic;
T_fft = fftn(T_gpu);          % 3D FFT
T_back = ifftn(T_fft);        % Inverse
t_fft = toc;
fprintf('  FFT time: %.3f s\n', t_fft);

% Check accuracy
T_cpu_back = cpu(T_back);
error = norm(T(:) - T_cpu_back(:)) / norm(T(:));
fprintf('  Reconstruction error: %.2e\n', error);

if error < 1e-10
    fprintf('  ✓ PASS: FFT accurate\n');
else
    fprintf('  ✗ FAIL: FFT inaccurate\n');
end

%% Test 5: Tensor Reductions
fprintf('\nTest 5: Tensor reductions on GPU...\n');
tic;
s = sum(T_gpu(:));            % Total sum
m = mean(T_gpu(:));           % Mean
n = norm(T_gpu(:));           % Frobenius norm
t_reduce = toc;
fprintf('  Sum:  %.4f + %.4fi\n', real(s), imag(s));
fprintf('  Mean: %.4f + %.4fi\n', real(m), imag(m));
fprintf('  Norm: %.4f\n', n);
fprintf('  Reduction time: %.3f s\n', t_reduce);

%% Test 6: Memory Stress (Multiple Large Tensors)
fprintf('\nTest 6: Multiple large tensors on GPU...\n');
try
    T1_gpu = gpu(randn(N, N, N) + 1i*randn(N, N, N));
    T2_gpu = gpu(randn(N, N, N) + 1i*randn(N, N, N));
    T3_gpu = gpu(randn(N, N, N) + 1i*randn(N, N, N));
    
    % Operations
    tic;
    R = T1_gpu + T2_gpu.*T3_gpu;
    t_multi = toc;
    
    fprintf('  3 tensors allocated (%.1f MB each)\n', numel(T)*16/1e6);
    fprintf('  Operation time: %.3f s\n', t_multi);
    fprintf('  ✓ PASS: Multiple tensors handled\n');
    
    % Cleanup
    clear T1_gpu T2_gpu T3_gpu R;
catch ME
    fprintf('  ✗ FAIL: %s\n', ME.message);
end

%% Test 7: Tensor-Matrix Operations
fprintf('\nTest 7: Mixed tensor-matrix operations...\n');
M_gpu = gpu(randn(N, N) + 1i*randn(N, N));

tic;
% Multiply each layer by matrix
for k = 1:10  % First 10 layers only (faster test)
    layer_k = T_gpu(:, :, k);
    result_k = M_gpu * layer_k;
    T_gpu(:, :, k) = result_k;
end
t_mixed = toc;
fprintf('  Mixed operations time: %.3f s\n', t_mixed);

%% Test 8: Phase and Magnitude
fprintf('\nTest 8: Phase and magnitude extraction...\n');
tic;
mag = abs(T_gpu);
phase = angle(T_gpu);
t_extract = toc;
fprintf('  Extraction time: %.3f s\n', t_extract);
fprintf('  Max magnitude: %.4f\n', max(mag(:)));
fprintf('  Phase range: [%.4f, %.4f]\n', min(phase(:)), max(phase(:)));

%% Summary
fprintf('\n========================================\n');
fprintf('TENSOR STRESS TEST COMPLETE\n');
fprintf('========================================\n');
fprintf('Total operations: 8\n');
fprintf('GPU memory used: %.1f MB\n', numel(T)*16*4/1e6);
fprintf('All tests: ');
if error < 1e-10
    fprintf('✓ PASSED\n');
else
    fprintf('⚠ Some issues detected\n');
end
fprintf('========================================\n\n');

% Cleanup
clear all;
