% RUN_GPU_STRESS_TESTS.M - Master GPU Stress Test Suite
% Runs all 4 stress tests and generates comprehensive report
%
% Usage: ./build/mlab++ < tests/run_gpu_stress_tests.m
%
% Tests:
%   1. stress_tensor.m - 3D tensor operations
%   2. stress_vector_parallel.m - Large vector operations  
%   3. stress_matrix_parallel.m - Matrix operations
%   4. stress_linear_accuracy.m - Numerical accuracy
%
% Expected runtime: 5-15 minutes depending on GPU

fprintf('\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('  MatLabC++ v0.8.0.1 Beta - GPU STRESS TEST SUITE\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('\n');

% System info
fprintf('System Information:\n');
fprintf('  MatLabC++ version: ');
version
fprintf('  Date: %s\n', datestr(now));
fprintf('  GPU available: ');
try
    gpu_test = gpu(rand(10, 10));
    fprintf('YES ✓\n');
    clear gpu_test;
catch
    fprintf('NO ✗\n');
    fprintf('\nERROR: GPU not available. Run with CUDA support.\n');
    return;
end
fprintf('\n');

% Track results
results = struct();
results.tests = {};
results.passed = [];
results.errors = [];
results.times = [];

start_time_total = tic;

%% Test 1: Tensor Operations
fprintf('════════════════════════════════════════════════════════\n');
fprintf('TEST 1/4: 3D TENSOR OPERATIONS\n');
fprintf('════════════════════════════════════════════════════════\n');
start_time = tic;
try
    run('tests/stress_tensor.m');
    test_time = toc(start_time);
    results.tests{end+1} = 'Tensor Operations';
    results.passed(end+1) = true;
    results.errors(end+1) = 0;
    results.times(end+1) = test_time;
    fprintf('Result: ✓ PASSED (%.1f s)\n', test_time);
catch ME
    test_time = toc(start_time);
    results.tests{end+1} = 'Tensor Operations';
    results.passed(end+1) = false;
    results.errors(end+1) = 1;
    results.times(end+1) = test_time;
    fprintf('Result: ✗ FAILED (%.1f s)\n', test_time);
    fprintf('Error: %s\n', ME.message);
end
fprintf('\n');

%% Test 2: Vector Parallel Operations
fprintf('════════════════════════════════════════════════════════\n');
fprintf('TEST 2/4: PARALLEL VECTOR OPERATIONS\n');
fprintf('════════════════════════════════════════════════════════\n');
start_time = tic;
try
    run('tests/stress_vector_parallel.m');
    test_time = toc(start_time);
    results.tests{end+1} = 'Vector Parallel';
    results.passed(end+1) = true;
    results.errors(end+1) = 0;
    results.times(end+1) = test_time;
    fprintf('Result: ✓ PASSED (%.1f s)\n', test_time);
catch ME
    test_time = toc(start_time);
    results.tests{end+1} = 'Vector Parallel';
    results.passed(end+1) = false;
    results.errors(end+1) = 1;
    results.times(end+1) = test_time;
    fprintf('Result: ✗ FAILED (%.1f s)\n', test_time);
    fprintf('Error: %s\n', ME.message);
end
fprintf('\n');

%% Test 3: Matrix Parallel Operations
fprintf('════════════════════════════════════════════════════════\n');
fprintf('TEST 3/4: PARALLEL MATRIX OPERATIONS\n');
fprintf('════════════════════════════════════════════════════════\n');
start_time = tic;
try
    run('tests/stress_matrix_parallel.m');
    test_time = toc(start_time);
    results.tests{end+1} = 'Matrix Parallel';
    results.passed(end+1) = true;
    results.errors(end+1) = 0;
    results.times(end+1) = test_time;
    fprintf('Result: ✓ PASSED (%.1f s)\n', test_time);
catch ME
    test_time = toc(start_time);
    results.tests{end+1} = 'Matrix Parallel';
    results.passed(end+1) = false;
    results.errors(end+1) = 1;
    results.times(end+1) = test_time;
    fprintf('Result: ✗ FAILED (%.1f s)\n', test_time);
    fprintf('Error: %s\n', ME.message);
end
fprintf('\n');

%% Test 4: Linear Algebra Accuracy
fprintf('════════════════════════════════════════════════════════\n');
fprintf('TEST 4/4: LINEAR ALGEBRA ACCURACY\n');
fprintf('════════════════════════════════════════════════════════\n');
start_time = tic;
try
    run('tests/stress_linear_accuracy.m');
    test_time = toc(start_time);
    results.tests{end+1} = 'Linear Accuracy';
    results.passed(end+1) = true;
    results.errors(end+1) = 0;
    results.times(end+1) = test_time;
    fprintf('Result: ✓ PASSED (%.1f s)\n', test_time);
catch ME
    test_time = toc(start_time);
    results.tests{end+1} = 'Linear Accuracy';
    results.passed(end+1) = false;
    results.errors(end+1) = 1;
    results.times(end+1) = test_time;
    fprintf('Result: ✗ FAILED (%.1f s)\n', test_time);
    fprintf('Error: %s\n', ME.message);
end

total_time = toc(start_time_total);

%% Final Report
fprintf('\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('  FINAL REPORT\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('\n');

% Summary table
fprintf('Test Results:\n');
fprintf('%-25s %-10s %-10s\n', 'Test', 'Status', 'Time (s)');
fprintf('%-25s %-10s %-10s\n', '----', '------', '--------');
for i = 1:length(results.tests)
    status = 'PASS ✓';
    if ~results.passed(i)
        status = 'FAIL ✗';
    end
    fprintf('%-25s %-10s %-10.1f\n', results.tests{i}, status, results.times(i));
end
fprintf('\n');

% Statistics
num_tests = length(results.tests);
num_passed = sum(results.passed);
pass_rate = 100 * num_passed / num_tests;

fprintf('Statistics:\n');
fprintf('  Total tests:       %d\n', num_tests);
fprintf('  Passed:            %d\n', num_passed);
fprintf('  Failed:            %d\n', num_tests - num_passed);
fprintf('  Pass rate:         %.1f%%\n', pass_rate);
fprintf('  Total time:        %.1f seconds (%.1f minutes)\n', total_time, total_time/60);
fprintf('\n');

% Overall status
fprintf('Overall Status: ');
if num_passed == num_tests
    fprintf('✓ ALL TESTS PASSED\n');
    fprintf('\n🎉 GPU system is fully operational! 🎉\n');
elseif num_passed >= num_tests * 0.75
    fprintf('⚠ MOSTLY PASSED\n');
    fprintf('\n⚠ GPU system works but has some issues.\n');
else
    fprintf('✗ MULTIPLE FAILURES\n');
    fprintf('\n✗ GPU system needs debugging.\n');
end

fprintf('\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('  MatLabC++ v0.8.0.1 Beta - GPU Stress Test Complete\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('\n');

% Generate report file
report_file = 'GPU_STRESS_TEST_REPORT.txt';
fid = fopen(report_file, 'w');
fprintf(fid, 'MatLabC++ v0.8.0.1 Beta - GPU Stress Test Report\n');
fprintf(fid, '================================================\n\n');
fprintf(fid, 'Date: %s\n\n', datestr(now));
fprintf(fid, 'Test Results:\n');
for i = 1:length(results.tests)
    status = 'PASS';
    if ~results.passed(i)
        status = 'FAIL';
    end
    fprintf(fid, '  %s: %s (%.1f s)\n', results.tests{i}, status, results.times(i));
end
fprintf(fid, '\nPass rate: %.1f%%\n', pass_rate);
fprintf(fid, 'Total time: %.1f seconds\n', total_time);
fclose(fid);

fprintf('Report saved to: %s\n\n', report_file);
