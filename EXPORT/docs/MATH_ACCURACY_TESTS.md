# 🧮 Mathematical Accuracy Tests for Active Window

**Comprehensive test suite to ensure MatLabC++ matches MATLAB's numerical accuracy**

---

## 🎯 Core Test Categories

### 1. **Floating-Point Precision**
### 2. **Matrix Operations**
### 3. **Special Values (NaN, Inf, -0)**
### 4. **Numerical Stability**
### 5. **Edge Cases**
### 6. **Complex Numbers**
### 7. **Transcendental Functions**
### 8. **Linear Algebra**
### 9. **Statistical Accuracy**
### 10. **Numerical Integration/Differentiation**

---

## 📋 Test Suite

### Test 1: Floating-Point Precision

**What to test:**
```matlab
>> % Machine epsilon (smallest number where 1 + eps != 1)
>> eps
ans = 2.2204e-16

>> % Verify IEEE 754 double precision
>> realmax
ans = 1.7977e+308

>> realmin
ans = 2.2251e-308

>> % Test precision loss
>> x = 1e16;
>> y = 1;
>> x + y == x
ans = 1  (true - precision lost)

>> x = 1e15;
>> y = 1;
>> x + y == x
ans = 0  (false - precision retained)
```

**Why it matters:** MATLAB uses IEEE 754 double precision. Your implementation must match this exactly.

---

### Test 2: Matrix Operations Accuracy

**What to test:**
```matlab
>> % Matrix multiplication accuracy
>> A = [1 2; 3 4];
>> B = [5 6; 7 8];
>> C = A * B
C =
    19    22
    43    50

>> % Verify: C(1,1) = 1*5 + 2*7 = 19
>> % Verify: C(2,2) = 3*6 + 4*8 = 50

>> % Matrix inversion accuracy
>> A = [4 7; 2 6];
>> inv(A)
ans =
    0.6000   -0.7000
   -0.2000    0.4000

>> % Verify: A * inv(A) ≈ eye(2)
>> norm(A * inv(A) - eye(2))
ans = 2.2204e-16  (should be near machine epsilon)

>> % Ill-conditioned matrix (numerical instability test)
>> H = hilb(10);  % Hilbert matrix (notoriously ill-conditioned)
>> cond(H)
ans = 1.6025e+13  (very high condition number)

>> % Test if inv(inv(H)) ≈ H
>> norm(H - inv(inv(H))) / norm(H)
ans = should be < 1e-10
```

**Why it matters:** Matrix operations accumulate floating-point errors. MATLAB handles these carefully.

---

### Test 3: Special Values (NaN, Inf, -0)

**What to test:**
```matlab
>> % Division by zero
>> 1 / 0
ans = Inf

>> -1 / 0
ans = -Inf

>> 0 / 0
ans = NaN

>> % NaN propagation
>> x = [1 2 NaN 4];
>> sum(x)
ans = NaN  (NaN infects all operations)

>> mean(x)
ans = NaN

>> % Inf arithmetic
>> Inf + Inf
ans = Inf

>> Inf - Inf
ans = NaN  (indeterminate)

>> Inf * 0
ans = NaN

>> Inf / Inf
ans = NaN

>> % Negative zero
>> x = -0
>> x == 0
ans = 1  (true)

>> 1 / x
ans = -Inf  (but 1/0 = Inf)

>> % isnan, isinf, isfinite
>> isnan(NaN)
ans = 1

>> isinf(Inf)
ans = 1

>> isfinite(1e308)
ans = 1

>> isfinite(Inf)
ans = 0
```

**Why it matters:** Special values have precise IEEE 754 semantics. Must match MATLAB exactly.

---

### Test 4: Numerical Stability

**What to test:**
```matlab
>> % Catastrophic cancellation
>> x = 1e16;
>> y = 1e16 + 1;
>> z = 1e16 + 2;
>> (z - y) - (y - x)
ans = 0  (should be 0, loss of precision)

>> % Better: use compensated summation (Kahan's algorithm)

>> % Quadratic formula instability
>> % For x² - 1e8*x + 1 = 0
>> a = 1; b = -1e8; c = 1;
>> % Unstable way:
>> x1 = (-b + sqrt(b^2 - 4*a*c)) / (2*a)
>> x2 = (-b - sqrt(b^2 - 4*a*c)) / (2*a)
>> % x2 will have large relative error!

>> % Stable way:
>> x1 = (-b - sign(b)*sqrt(b^2 - 4*a*c)) / (2*a);
>> x2 = c / (a * x1);

>> % Verify roots
>> a*x1^2 + b*x1 + c
ans = should be ≈ 0

>> % Summation order matters
>> x = [1e16, 1, -1e16];
>> sum(x)  % Left-to-right: (1e16 + 1) - 1e16 = 1e16 - 1e16 = 0
ans = 0  (loses the 1!)

>> % Better: sort by magnitude first
>> sum(sort(abs(x)) .* sign(x))
ans = 1  (correct)
```

**Why it matters:** Real numerical codes must avoid catastrophic cancellation and precision loss.

---

### Test 5: Edge Cases

**What to test:**
```matlab
>> % Empty matrix
>> A = [];
>> size(A)
ans = 0 0

>> sum([])
ans = 0

>> mean([])
ans = NaN

>> % Single element
>> A = 5;
>> std(A)
ans = 0

>> % Very large matrices
>> A = rand(1000, 1000);
>> tic; C = A * A; toc
Elapsed time: should be reasonable (< 1 second on modern CPU)

>> % Rank-deficient matrices
>> A = [1 2 3; 2 4 6; 3 6 9];  % rank 1
>> rank(A)
ans = 1

>> det(A)
ans = 0 (or very close to 0)

>> % Singular matrix inversion (should error or warn)
>> inv(A)
Warning: Matrix is singular to working precision.
ans = Inf (or NaN matrix)
```

**Why it matters:** Edge cases reveal bugs and numerical instabilities.

---

### Test 6: Complex Numbers

**What to test:**
```matlab
>> % Complex arithmetic
>> z = 3 + 4i
z = 3.0000 + 4.0000i

>> abs(z)
ans = 5  (sqrt(3² + 4²))

>> angle(z)
ans = 0.9273  (atan2(4, 3))

>> conj(z)
ans = 3.0000 - 4.0000i

>> real(z)
ans = 3

>> imag(z)
ans = 4

>> % Complex matrix operations
>> A = [1+i, 2-i; 3+2i, 4-3i];
>> A'  % Hermitian transpose (conjugate transpose)
ans =
   1.0000 - 1.0000i   3.0000 - 2.0000i
   2.0000 + 1.0000i   4.0000 + 3.0000i

>> % Complex eigenvalues
>> A = [0 -1; 1 0];  % 90-degree rotation matrix
>> eig(A)
ans =
   0.0000 + 1.0000i
   0.0000 - 1.0000i

>> % Euler's formula: e^(iπ) + 1 = 0
>> exp(1i * pi) + 1
ans = 0.0000 + 0.0000i  (should be ≈ 0)
```

**Why it matters:** MATLAB handles complex numbers natively. Essential for signal processing, quantum mechanics, etc.

---

### Test 7: Transcendental Functions

**What to test:**
```matlab
>> % Trigonometric accuracy
>> sin(pi)
ans = 1.2246e-16  (should be ≈ 0, but not exactly due to floating-point)

>> cos(pi/2)
ans = 6.1232e-17  (should be ≈ 0)

>> sin(pi/6)
ans = 0.5000  (exact)

>> cos(pi/3)
ans = 0.5000  (exact)

>> % Verify identity: sin²(x) + cos²(x) = 1
>> x = 0.7;
>> sin(x)^2 + cos(x)^2
ans = 1.0000  (should be exactly 1 within machine epsilon)

>> % Exponential and logarithm
>> exp(1)
ans = 2.7183  (e)

>> log(exp(1))
ans = 1.0000  (should be exactly 1)

>> log10(1000)
ans = 3.0000

>> % Hyperbolic functions
>> sinh(1)
ans = 1.1752

>> cosh(1)^2 - sinh(1)^2
ans = 1.0000  (identity)

>> % Inverse functions
>> asin(sin(0.5))
ans = 0.5000

>> atan(tan(0.5))
ans = 0.5000

>> % Edge cases
>> sin(1e10)  % Large argument reduction
ans = -0.1677

>> exp(1000)  % Overflow
ans = Inf

>> log(0)  % Domain error
ans = -Inf

>> asin(2)  % Outside domain
ans = 1.5708 + 1.3170i  (complex result)
```

**Why it matters:** Transcendental functions use Taylor series, CORDIC, or range reduction. Accuracy varies by algorithm.

---

### Test 8: Linear Algebra Accuracy

**What to test:**
```matlab
>> % Eigenvalue accuracy
>> A = magic(5);  % 5x5 magic square
>> [V, D] = eig(A);
>> % Verify: A*V = V*D
>> norm(A*V - V*D, 'fro')
ans = should be < 1e-12

>> % Singular Value Decomposition
>> A = rand(5, 3);
>> [U, S, V] = svd(A);
>> % Verify: A = U*S*V'
>> norm(A - U*S*V', 'fro')
ans = should be < 1e-14

>> % QR decomposition
>> A = rand(5, 5);
>> [Q, R] = qr(A);
>> % Verify: Q is orthogonal
>> norm(Q'*Q - eye(5), 'fro')
ans = should be < 1e-15

>> % Verify: A = Q*R
>> norm(A - Q*R, 'fro')
ans = should be < 1e-14

>> % Cholesky decomposition (positive definite)
>> A = rand(5); A = A*A';  % Make positive definite
>> L = chol(A, 'lower');
>> norm(A - L*L', 'fro')
ans = should be < 1e-13

>> % LU decomposition
>> A = rand(5, 5);
>> [L, U, P] = lu(A);
>> norm(P*A - L*U, 'fro')
ans = should be < 1e-14
```

**Why it matters:** Linear algebra is the foundation of numerical computing. These must be stable and accurate.

---

### Test 9: Statistical Accuracy

**What to test:**
```matlab
>> % Mean
>> x = [1 2 3 4 5];
>> mean(x)
ans = 3.0000

>> % Variance (unbiased estimator)
>> var(x)
ans = 2.5000  (sum((x - mean(x)).^2) / (n-1))

>> % Standard deviation
>> std(x)
ans = 1.5811  (sqrt(var(x)))

>> % Correlation
>> x = [1 2 3 4 5];
>> y = [2 4 6 8 10];
>> corrcoef(x, y)
ans =
    1.0000    1.0000
    1.0000    1.0000
(perfect correlation)

>> % Covariance
>> cov(x, y)
ans = should match var(x) for diagonal

>> % Percentiles
>> x = 1:100;
>> prctile(x, 50)
ans = 50.5  (median)

>> prctile(x, [25 50 75])
ans = 25.5  50.5  75.5  (quartiles)

>> % Median vs mean with outliers
>> x = [1 2 3 4 5 1000];
>> mean(x)
ans = 169.17  (affected by outlier)

>> median(x)
ans = 3.5  (robust to outlier)
```

**Why it matters:** Statistical functions must handle numerical stability, especially with large datasets.

---

### Test 10: Numerical Integration & Differentiation

**What to test:**
```matlab
>> % Numerical integration (trapezoid rule)
>> x = 0:0.01:pi;
>> y = sin(x);
>> integral = trapz(x, y)
ans = 2.0001  (should be ≈ 2.0, analytical: ∫sin(x)dx from 0 to π = 2)

>> % Cumulative integration
>> cumtrapz(x, y)(end)
ans = 2.0001

>> % Numerical differentiation
>> x = 0:0.01:2*pi;
>> y = sin(x);
>> dy = diff(y) ./ diff(x);  % Approximate derivative
>> % Compare to analytical: cos(x)
>> x_mid = (x(1:end-1) + x(2:end)) / 2;
>> analytical = cos(x_mid);
>> max(abs(dy - analytical))
ans = should be < 0.01  (depends on step size)

>> % Second derivative
>> d2y = diff(dy) ./ diff(x_mid);
>> % Should approximate -sin(x)

>> % Integration error vs step size
>> for h = [0.1, 0.01, 0.001]
>>     x = 0:h:pi;
>>     y = sin(x);
>>     I = trapz(x, y);
>>     error = abs(I - 2.0);
>>     fprintf('h = %.4f, error = %.6f\n', h, error);
>> end
% Error should decrease with h²
```

**Why it matters:** Numerical integration/differentiation accuracy depends on algorithm and step size.

---

## 🧪 Automated Test Suite

Here's a complete test script for Active Window:

```matlab
% test_math_accuracy.m
% Comprehensive mathematical accuracy tests

disp('MatLabC++ Mathematical Accuracy Test Suite');
disp('===========================================');
disp('');

passed = 0;
failed = 0;

% Test 1: Machine Epsilon
disp('Test 1: Machine Epsilon');
eps_val = eps;
if abs(eps_val - 2.2204e-16) < 1e-20
    disp('  ✓ PASS');
    passed = passed + 1;
else
    disp('  ✗ FAIL');
    failed = failed + 1;
end

% Test 2: Matrix Multiplication
disp('Test 2: Matrix Multiplication');
A = [1 2; 3 4];
B = [5 6; 7 8];
C = A * B;
expected = [19 22; 43 50];
if norm(C - expected, 'fro') < 1e-12
    disp('  ✓ PASS');
    passed = passed + 1;
else
    disp('  ✗ FAIL');
    failed = failed + 1;
end

% Test 3: Special Values
disp('Test 3: Special Values');
test_nan = isnan(0/0);
test_inf = isinf(1/0);
test_ninf = isinf(-1/0);
if test_nan && test_inf && test_ninf
    disp('  ✓ PASS');
    passed = passed + 1;
else
    disp('  ✗ FAIL');
    failed = failed + 1;
end

% Test 4: Trigonometric Identity
disp('Test 4: sin²(x) + cos²(x) = 1');
x = 0.7;
identity = sin(x)^2 + cos(x)^2;
if abs(identity - 1.0) < eps
    disp('  ✓ PASS');
    passed = passed + 1;
else
    disp('  ✗ FAIL');
    failed = failed + 1;
end

% Test 5: Eigenvalue Decomposition
disp('Test 5: Eigenvalue Decomposition');
A = [4 1; 2 3];
[V, D] = eig(A);
error = norm(A*V - V*D, 'fro');
if error < 1e-12
    disp('  ✓ PASS');
    passed = passed + 1;
else
    disp('  ✗ FAIL');
    failed = failed + 1;
end

% Test 6: SVD Accuracy
disp('Test 6: SVD Decomposition');
A = rand(3, 2);
[U, S, V] = svd(A);
error = norm(A - U*S*V', 'fro');
if error < 1e-14
    disp('  ✓ PASS');
    passed = passed + 1;
else
    disp('  ✗ FAIL');
    failed = failed + 1;
end

% Test 7: Integration Accuracy
disp('Test 7: Numerical Integration');
x = 0:0.001:pi;
y = sin(x);
integral = trapz(x, y);
error = abs(integral - 2.0);
if error < 0.01
    disp('  ✓ PASS');
    passed = passed + 1;
else
    disp('  ✗ FAIL');
    failed = failed + 1;
end

% Test 8: Complex Numbers
disp('Test 8: Euler Formula');
result = exp(1i * pi) + 1;
if abs(result) < 1e-14
    disp('  ✓ PASS');
    passed = passed + 1;
else
    disp('  ✗ FAIL');
    failed = failed + 1;
end

% Summary
disp('');
disp('===========================================');
fprintf('Tests Passed: %d/%d\n', passed, passed + failed);
fprintf('Tests Failed: %d/%d\n', failed, passed + failed);
disp('===========================================');

if failed == 0
    disp('All tests PASSED! ✓');
else
    disp('Some tests FAILED! ✗');
end
```

---

## 🎯 Critical Accuracy Benchmarks

**Your MatLabC++ must match MATLAB to these tolerances:**

| Test | MATLAB Result | Tolerance |
|------|---------------|-----------|
| `eps` | 2.2204e-16 | Exact |
| `sin(pi)` | ~0 | < 1e-15 |
| `A*inv(A)` | eye(n) | < 1e-14 |
| `sin²(x) + cos²(x)` | 1.0 | < eps |
| `exp(log(x))` | x | < 1e-14 |
| `[U,S,V]=svd(A)` | A = U*S*V' | < 1e-13 |
| `trapz(sin)` from 0 to π | 2.0 | < 0.001 |
| `e^(iπ) + 1` | 0 | < 1e-14 |

---

## 📊 Performance vs Accuracy Tradeoffs

**When implementing functions, consider:**

### Fast but Less Accurate
- Table lookup + interpolation
- Low-order Taylor series
- Single iteration methods

### Slow but More Accurate
- High-order Taylor series
- Iterative refinement
- Kahan summation
- Compensated algorithms

**MATLAB chooses:** Accuracy over speed (usually). Match this philosophy.

---

## 🚨 Common Pitfalls

### 1. **Naive Summation**
```matlab
% Bad (loses precision)
sum = 0;
for i = 1:n
    sum = sum + x(i);
end

% Good (Kahan summation)
sum = 0; c = 0;
for i = 1:n
    y = x(i) - c;
    t = sum + y;
    c = (t - sum) - y;
    sum = t;
end
```

### 2. **Quadratic Formula**
```matlab
% Bad (cancellation)
x = (-b + sqrt(b^2 - 4*a*c)) / (2*a);

% Good (stable)
x = -b - sign(b)*sqrt(b^2 - 4*a*c);
x = x / (2*a);
```

### 3. **Matrix Inversion**
```matlab
% Bad (numerically unstable)
x = inv(A) * b;

% Good (more stable)
x = A \ b;
```

---

## ✅ Checklist

Before releasing MatLabC++, ensure:

- [ ] All IEEE 754 special values handled correctly
- [ ] Matrix operations accurate to < 1e-14 relative error
- [ ] Eigenvalue decomposition stable
- [ ] SVD accurate and doesn't fail on edge cases
- [ ] Trigonometric functions accurate to < eps
- [ ] Integration/differentiation accurate to documented tolerance
- [ ] Complex arithmetic matches MATLAB
- [ ] No crashes on singular matrices
- [ ] NaN propagation correct
- [ ] Statistical functions match R/MATLAB

---

## 📖 References

**Read these for numerical accuracy:**

1. **"Numerical Recipes"** - Press et al. (classic algorithms)
2. **"Accuracy and Stability of Numerical Algorithms"** - Higham
3. **IEEE 754 Standard** - Floating-point arithmetic spec
4. **LAPACK Documentation** - Industry-standard linear algebra
5. **MATLAB Documentation** - Algorithm notes for each function

---

**Run this test suite in your Active Window to ensure mathematical correctness!** 🧮✅
