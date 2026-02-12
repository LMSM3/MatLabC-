# 🎯 Mathematical Accuracy - Quick Reference

**Essential tests to ensure MatLabC++ matches MATLAB's numerical accuracy**

---

## ✅ Quick Test Checklist

Run these in Active Window to verify mathematical correctness:

### 1. **Machine Epsilon** (IEEE 754 compliance)
```matlab
>> eps
ans = 2.2204e-16  % Must be exact
```

### 2. **Matrix Multiply**
```matlab
>> [1 2; 3 4] * [5 6; 7 8]
ans =
    19    22
    43    50
```

### 3. **Special Values**
```matlab
>> 0/0         % NaN
>> 1/0         % Inf
>> -1/0        % -Inf
>> isnan(0/0)  % 1 (true)
>> isinf(1/0)  % 1 (true)
```

### 4. **Trig Identity**
```matlab
>> x = 0.7;
>> sin(x)^2 + cos(x)^2
ans = 1.0000  % Error < eps
```

### 5. **sin(π) ≈ 0**
```matlab
>> sin(pi)
ans = 1.2246e-16  % Very close to 0
```

### 6. **Matrix Inversion**
```matlab
>> A = [4 7; 2 6];
>> norm(A * inv(A) - eye(2))
ans = 4.4409e-16  % Error ≈ eps
```

### 7. **Complex Numbers**
```matlab
>> z = 3 + 4i;
>> abs(z)
ans = 5.0000  % Exact

>> conj(z)
ans = 3.0000 - 4.0000i
```

### 8. **Euler's Formula**
```matlab
>> abs(exp(1i*pi) + 1)
ans = 1.2246e-16  % Essentially 0
```

### 9. **Exponential/Log**
```matlab
>> x = 5;
>> exp(log(x))
ans = 5.0000  % Exact

>> log(exp(x))
ans = 5.0000  % Exact
```

### 10. **Statistics**
```matlab
>> mean([1 2 3 4 5])
ans = 3

>> std([1 2 3 4 5])
ans = 1.5811
```

---

## 🚨 Critical Tolerances

| Test | Expected Error |
|------|----------------|
| Machine epsilon | Exact (0) |
| Matrix multiply | < 1e-14 |
| Matrix inversion | < 1e-14 |
| Trig identities | < eps |
| sin(π) | < 1e-15 |
| Complex abs | < 1e-14 |
| exp/log inverse | < 1e-14 |
| Euler formula | < 1e-14 |

---

## 📊 Run Full Test Suite

```matlab
>> test_math_accuracy

[10 tests run, all pass]
✓ ALL TESTS PASSED!
```

---

## 🎓 Why These Tests Matter

**Machine Epsilon:** Verifies IEEE 754 double precision  
**Matrix Ops:** Core of linear algebra (accumulates errors)  
**Special Values:** NaN/Inf must propagate correctly  
**Trig Functions:** Most numerical codes use these  
**Complex Numbers:** Signal processing, quantum mechanics  
**Inversion:** Numerical stability test  
**Euler Formula:** Complex exponentials everywhere  

---

## 📖 Full Documentation

- **MATH_ACCURACY_TESTS.md** - Complete test guide (200+ lines)
- **test_math_accuracy.m** - Runnable test script
- **Active Window** - Interactive testing environment

---

**Quick verification:** Run `test_math_accuracy` in Active Window! ✅
