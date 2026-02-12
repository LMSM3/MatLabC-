% gpu_benchmark.m
% GPU acceleration demonstration and benchmarking
%
% Run with: mlab++ gpu_benchmark.m --enableGPU --visual

disp('MatLabC++ GPU Benchmark');
disp('=======================');
disp('');

% Check GPU availability
if gpuDeviceCount == 0
    error('No GPU detected! Run with --enableGPU flag');
end

gpu_info = gpuDevice;
fprintf('GPU: %s\n', gpu_info.Name);
fprintf('Compute capability: %.1f\n', gpu_info.ComputeCapability);
fprintf('Memory: %.1f GB\n', gpu_info.TotalMemory / 1e9);
disp('');

% ========== MATRIX MULTIPLICATION BENCHMARK ==========
disp('1. Matrix Multiplication Benchmark');
disp('-----------------------------------');

sizes = [1000, 2000, 4000];
for n = sizes
    fprintf('Matrix size: %dx%d\n', n, n);
    
    % CPU version
    A_cpu = rand(n, n);
    B_cpu = rand(n, n);
    
    tic;
    C_cpu = A_cpu * B_cpu;
    time_cpu = toc;
    
    % GPU version
    A_gpu = gpuArray(A_cpu);
    B_gpu = gpuArray(B_cpu);
    
    tic;
    C_gpu = A_gpu * B_gpu;
    wait(gpuDevice);
    time_gpu = toc;
    
    speedup = time_cpu / time_gpu;
    fprintf('  CPU: %.3f s\n', time_cpu);
    fprintf('  GPU: %.3f s\n', time_gpu);
    fprintf('  Speedup: %.1fx\n', speedup);
    disp('');
end

% ========== FFT BENCHMARK ==========
disp('2. FFT Benchmark');
disp('----------------');

n_fft = 2^20;  % 1M points
x_cpu = rand(n_fft, 1);

tic;
X_cpu = fft(x_cpu);
time_fft_cpu = toc;

x_gpu = gpuArray(x_cpu);
tic;
X_gpu = fft(x_gpu);
wait(gpuDevice);
time_fft_gpu = toc;

fprintf('FFT size: %d points\n', n_fft);
fprintf('  CPU: %.3f s\n', time_fft_cpu);
fprintf('  GPU: %.3f s\n', time_fft_gpu);
fprintf('  Speedup: %.1fx\n', time_fft_cpu / time_fft_gpu);
disp('');

% ========== ELEMENT-WISE OPERATIONS ==========
disp('3. Element-wise Operations');
disp('--------------------------');

n = 10000000;  % 10M elements
x = rand(n, 1);

tic;
y_cpu = sin(x) .* cos(x) + sqrt(abs(x));
time_elem_cpu = toc;

x_gpu = gpuArray(x);
tic;
y_gpu = sin(x_gpu) .* cos(x_gpu) + sqrt(abs(x_gpu));
wait(gpuDevice);
time_elem_gpu = toc;

fprintf('Vector size: %d elements\n', n);
fprintf('  CPU: %.3f s\n', time_elem_cpu);
fprintf('  GPU: %.3f s\n', time_elem_gpu);
fprintf('  Speedup: %.1fx\n', time_elem_cpu / time_elem_gpu);
disp('');

disp('Benchmark complete!');
fprintf('Average speedup: %.1fx\n', mean([time_cpu/time_gpu, time_fft_cpu/time_fft_gpu, time_elem_cpu/time_elem_gpu]));
