% test_math_accuracy.m
% Comprehensive Mathematical Accuracy Test Suite for MatLabC++
%
% Run with: mlab++ test_math_accuracy.m

disp('');
disp('╔════════════════════════════════════════════════════════════╗');
disp('║  MatLabC++ Mathematical Accuracy Test Suite               ║');
disp('╚════════════════════════════════════════════════════════════╝');
disp('');

passed = 0;
failed = 0;
test_num = 0;

% ========== TEST 1: Machine Epsilon ==========
test_num = test_num + 1;
fprintf('Test %d: Machine Epsilon\n', test_num);
fprintf('  Computing eps = smallest number where 1 + eps != 1\n');

eps_computed = 1.0;
while (1.0 + eps_computed/2.0) > 1.0
    eps_computed = eps_computed / 2.0;
end

eps_expected = 2.220446049250313e-16;  % IEEE 754 double precision
error = abs(eps_computed - eps_expected);

fprintf('  Expected: %.15e\n', eps_expected);
fprintf('  Got:      %.15e\n', eps_computed);
fprintf('  Error:    %.15e\n', error);

if error < 1e-20
    fprintf('  ✓ PASS\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL\n\n');
    failed = failed + 1;
end

% ========== TEST 2: Matrix Multiplication ==========
test_num = test_num + 1;
fprintf('Test %d: Matrix Multiplication Accuracy\n', test_num);

A = [1 2; 3 4];
B = [5 6; 7 8];
C = A * B;
expected = [19 22; 43 50];

fprintf('  A * B = \n');
disp(C);
fprintf('  Expected:\n');
disp(expected);

error_matrix = C - expected;
error = sqrt(sum(sum(error_matrix .* error_matrix)));  % Frobenius norm

fprintf('  Frobenius norm error: %.15e\n', error);

if error < 1e-12
    fprintf('  ✓ PASS\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL\n\n');
    failed = failed + 1;
end

% ========== TEST 3: Special Values (NaN, Inf) ==========
test_num = test_num + 1;
fprintf('Test %d: Special Values (NaN, Inf, -Inf)\n', test_num);

test_pass = 1;

% Test NaN
nan_val = 0 / 0;
if ~isnan(nan_val)
    fprintf('  ✗ FAIL: 0/0 should be NaN\n');
    test_pass = 0;
end

% Test Inf
inf_val = 1 / 0;
if ~isinf(inf_val) || inf_val < 0
    fprintf('  ✗ FAIL: 1/0 should be +Inf\n');
    test_pass = 0;
end

% Test -Inf
ninf_val = -1 / 0;
if ~isinf(ninf_val) || ninf_val > 0
    fprintf('  ✗ FAIL: -1/0 should be -Inf\n');
    test_pass = 0;
end

% Test NaN propagation
x = [1 2 NaN 4];
sum_val = sum(x);
if ~isnan(sum_val)
    fprintf('  ✗ FAIL: sum([1 2 NaN 4]) should be NaN\n');
    test_pass = 0;
end

fprintf('  0/0 = NaN:      %s\n', mat2str(isnan(nan_val)));
fprintf('  1/0 = +Inf:     %s\n', mat2str(isinf(inf_val) && inf_val > 0));
fprintf('  -1/0 = -Inf:    %s\n', mat2str(isinf(ninf_val) && ninf_val < 0));
fprintf('  NaN propagates: %s\n', mat2str(isnan(sum_val)));

if test_pass
    fprintf('  ✓ PASS\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL\n\n');
    failed = failed + 1;
end

% ========== TEST 4: Trigonometric Identity ==========
test_num = test_num + 1;
fprintf('Test %d: Trigonometric Identity (sin²(x) + cos²(x) = 1)\n', test_num);

x = 0.7;
sin_x = sin(x);
cos_x = cos(x);
identity = sin_x * sin_x + cos_x * cos_x;

fprintf('  x = %.15f\n', x);
fprintf('  sin(x) = %.15f\n', sin_x);
fprintf('  cos(x) = %.15f\n', cos_x);
fprintf('  sin²(x) + cos²(x) = %.15f\n', identity);
fprintf('  Error from 1.0: %.15e\n', abs(identity - 1.0));

if abs(identity - 1.0) < 1e-15
    fprintf('  ✓ PASS\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL\n\n');
    failed = failed + 1;
end

% ========== TEST 5: sin(π) ≈ 0 ==========
test_num = test_num + 1;
fprintf('Test %d: sin(π) ≈ 0\n', test_num);

pi_val = 3.141592653589793;
sin_pi = sin(pi_val);

fprintf('  π = %.15f\n', pi_val);
fprintf('  sin(π) = %.15e\n', sin_pi);
fprintf('  |sin(π)| = %.15e\n', abs(sin_pi));

if abs(sin_pi) < 1e-15
    fprintf('  ✓ PASS (close enough to 0)\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL (too far from 0)\n\n');
    failed = failed + 1;
end

% ========== TEST 6: Matrix Inversion Accuracy ==========
test_num = test_num + 1;
fprintf('Test %d: Matrix Inversion Accuracy\n', test_num);

A = [4 7; 2 6];
A_inv = inv(A);
I_approx = A * A_inv;
I_exact = [1 0; 0 1];

fprintf('  A = \n');
disp(A);
fprintf('  inv(A) = \n');
disp(A_inv);
fprintf('  A * inv(A) = \n');
disp(I_approx);

error_matrix = I_approx - I_exact;
error = sqrt(sum(sum(error_matrix .* error_matrix)));

fprintf('  Error from identity: %.15e\n', error);

if error < 1e-14
    fprintf('  ✓ PASS\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL\n\n');
    failed = failed + 1;
end

% ========== TEST 7: Vector Mean and Std Dev ==========
test_num = test_num + 1;
fprintf('Test %d: Statistical Functions (mean, std)\n', test_num);

x = [1 2 3 4 5];
mean_x = mean(x);
std_x = std(x);

mean_expected = 3.0;
std_expected = sqrt(2.5);  % 1.5811...

fprintf('  x = [1 2 3 4 5]\n');
fprintf('  mean(x) = %.15f (expected: %.15f)\n', mean_x, mean_expected);
fprintf('  std(x) = %.15f (expected: %.15f)\n', std_x, std_expected);

mean_error = abs(mean_x - mean_expected);
std_error = abs(std_x - std_expected);

fprintf('  Mean error: %.15e\n', mean_error);
fprintf('  Std error:  %.15e\n', std_error);

if mean_error < 1e-14 && std_error < 1e-14
    fprintf('  ✓ PASS\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL\n\n');
    failed = failed + 1;
end

% ========== TEST 8: Exponential and Logarithm ==========
test_num = test_num + 1;
fprintf('Test %d: Exponential and Logarithm Inverses\n', test_num);

x = 5.0;
exp_log = exp(log(x));
log_exp = log(exp(x));

fprintf('  x = %.15f\n', x);
fprintf('  exp(log(x)) = %.15f\n', exp_log);
fprintf('  log(exp(x)) = %.15f\n', log_exp);

error_exp_log = abs(exp_log - x);
error_log_exp = abs(log_exp - x);

fprintf('  Error exp(log(x)): %.15e\n', error_exp_log);
fprintf('  Error log(exp(x)): %.15e\n', error_log_exp);

if error_exp_log < 1e-14 && error_log_exp < 1e-14
    fprintf('  ✓ PASS\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL\n\n');
    failed = failed + 1;
end

% ========== TEST 9: Complex Numbers ==========
test_num = test_num + 1;
fprintf('Test %d: Complex Number Operations\n', test_num);

z = 3 + 4i;
abs_z = abs(z);
abs_expected = 5.0;  % sqrt(3² + 4²)

conj_z = conj(z);
conj_expected = 3 - 4i;

fprintf('  z = %.1f + %.1fi\n', real(z), imag(z));
fprintf('  |z| = %.15f (expected: %.1f)\n', abs_z, abs_expected);
fprintf('  conj(z) = %.1f - %.1fi\n', real(conj_z), abs(imag(conj_z)));

abs_error = abs(abs_z - abs_expected);
conj_error = abs(conj_z - conj_expected);

fprintf('  |z| error: %.15e\n', abs_error);
fprintf('  conj error: %.15e\n', abs(conj_error));

if abs_error < 1e-14 && abs(conj_error) < 1e-14
    fprintf('  ✓ PASS\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL\n\n');
    failed = failed + 1;
end

% ========== TEST 10: Euler's Formula (e^(iπ) + 1 = 0) ==========
test_num = test_num + 1;
fprintf('Test %d: Euler''s Formula (e^(iπ) + 1 = 0)\n', test_num);

pi_val = 3.141592653589793;
result = exp(1i * pi_val) + 1;

fprintf('  e^(iπ) + 1 = %.15e + %.15ei\n', real(result), imag(result));
fprintf('  |e^(iπ) + 1| = %.15e\n', abs(result));

if abs(result) < 1e-14
    fprintf('  ✓ PASS (essentially zero)\n\n');
    passed = passed + 1;
else
    fprintf('  ✗ FAIL (too far from zero)\n\n');
    failed = failed + 1;
end

% ========== SUMMARY ==========
disp('═══════════════════════════════════════════════════════════');
disp('  Test Summary');
disp('═══════════════════════════════════════════════════════════');
fprintf('  Tests Run:    %d\n', test_num);
fprintf('  Tests Passed: %d\n', passed);
fprintf('  Tests Failed: %d\n', failed);
fprintf('  Success Rate: %.1f%%\n', 100.0 * passed / test_num);
disp('═══════════════════════════════════════════════════════════');

if failed == 0
    disp('  ✓ ALL TESTS PASSED!');
    disp('  MatLabC++ mathematical accuracy matches MATLAB!');
else
    fprintf('  ✗ %d TEST(S) FAILED!\n', failed);
    disp('  Please review failed tests and fix numerical accuracy.');
end

disp('═══════════════════════════════════════════════════════════');
disp('');
