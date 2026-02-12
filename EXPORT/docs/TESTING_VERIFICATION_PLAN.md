# MatLabC++ v0.3.1 Testing and Verification Plan

## Current State Assessment

Version 0.3.1 implements basic trig functions (sin, cos, tan) but lacks:
- Comprehensive testing
- Special value handling (NaN, Inf, edge cases)
- Array support for trig functions
- Complete trig family (inverse, hyperbolic)
- Formal compatibility contract with MATLAB

## Phase 1: Verify Existing v0.3.1 Implementation (IMMEDIATE)

### A. Create Test Suite for Current Functions

File: `tests/test_trig_basic.cpp`

Test vectors for sin/cos/tan:
- Zero: 0
- Special angles: pi/6, pi/4, pi/3, pi/2, pi, 2*pi
- Negative angles: -pi/4, -pi/2
- Large values: 1e12, 1e308
- Special floats: NaN, Inf, -Inf
- Subnormal: 1e-308

Expected behavior:
- Match std::sin/cos/tan output (we're delegating to libm)
- No crashes on special values
- Consistent error messages

### B. Test Current Scalar-Only Limitation

Verify these produce clear errors (not crashes):
```
sin([0 pi/2])  # Should error: "sin() only supports scalar arguments for now"
sin(zeros(3,3)) # Should error clearly
```

### C. Domain Validation

Functions that need domain checking:
- log(x): x > 0 (currently no check - will produce -Inf for 0, NaN for negative)
- log10(x): x > 0
- sqrt(x): x >= 0 (negative produces NaN, which may be acceptable)

Decision needed: MATLAB returns complex for sqrt(-1), you return NaN. Document this.

### D. Accuracy Validation

Test mathematical identities within tolerance:
```
sin(x)^2 + cos(x)^2 = 1.0  (within 1e-15)
tan(x) = sin(x)/cos(x)     (away from pi/2, 3*pi/2, etc.)
sin(-x) = -sin(x)
cos(-x) = cos(x)
```

## Phase 2: Define MATLAB Compatibility Contract (DOCUMENTATION)

### File: `docs/MATLAB_COMPATIBILITY.md`

#### Compatibility Tiers

**Tier 1: Syntax Compatibility (Goal: 90% for v1.0)**
- Scripts that use supported features parse and run
- Clear error messages for unsupported features

**Tier 2: Semantic Compatibility (Goal: 99% for v1.0)**
- Same numerical results within floating-point tolerance
- Same edge case behavior (NaN, Inf, empty arrays)

**Tier 3: Ecosystem Compatibility (Goal: Not in scope for v1.0)**
- Toolboxes, file formats (.mat), MEX, plotting

#### Supported vs Unsupported Lists

**Currently Supported (v0.3.1):**
- Scalar arithmetic: +, -, *, /
- Variable assignment
- Workspace commands: workspace, clear, who
- Basic functions: disp, sum, mean, min, max, size, length
- Math functions (scalar only): sqrt, abs, sin, cos, tan, exp, log, log10

**Explicitly Unsupported (v0.3.1):**
- Array indexing: A(1,2), A(1,:), A(end)
- Matrix operations: *, ^, \, /
- Elementwise operations: .*, .^, ./, .\
- Complex numbers
- Cell arrays, structs
- String operations
- Control flow: if, for, while, switch
- Function definitions
- Plotting

**Error Behavior:**
When unsupported features are used, error messages must be MATLAB-like:
- Use MATLAB error identifiers where possible
- Format: "Error: <description>. Feature not yet implemented."
- Example: "Error: Array indexing not yet implemented. Use scalar values only."

### The Array Model Contract

When arrays are fully implemented (v0.4.0+), must match:

**Storage:**
- Column-major (affects linear indexing)
- Contiguous memory where possible (for performance)

**Indexing:**
- 1-based (A(1) is first element)
- Linear indexing: A(5) for 2D array works
- Colon operator: A(:,2) is second column
- end keyword: A(end) is last element

**Operators:**
- * is matrix multiply for 2D
- .* is elementwise multiply
- ^ is matrix power
- .^ is elementwise power
- / is right division (solve)
- \ is left division (solve)

**Functions:**
- Elementwise by default for math functions: sin([0 pi/2]) = [0 1]
- Reduction functions take dim argument: sum(A,1) vs sum(A,2)

## Phase 3: Expand Trig Function Family (v0.3.2)

### Core Trig (already in v0.3.1)
- [x] sin, cos, tan

### Inverse Trig (add in v0.3.2)
- [ ] asin, acos, atan
- [ ] atan2(y, x)  # Two-argument form

### Hyperbolic (add in v0.3.2)
- [ ] sinh, cosh, tanh

### Inverse Hyperbolic (add in v0.3.2)
- [ ] asinh, acosh, atanh

### Degree Variants (decision needed)
Either implement OR provide clear error message:
- [ ] sind, cosd, tand (trig with degrees)
- [ ] asind, acosd, atand, atan2d
- [ ] deg2rad, rad2deg helpers

Recommendation: Add deg2rad/rad2deg, skip sind/cosd (user can write sin(deg2rad(x)))

### Constants (add in v0.3.2)
- [ ] pi (as built-in constant, not function)
- [ ] eps (floating-point epsilon)
- [ ] inf (infinity)
- [ ] nan (not-a-number)

## Phase 4: Array Support for Math Functions (v0.4.0)

### Elementwise Application
All math functions must work on arrays:
```
sin(scalar) -> scalar
sin(vector) -> vector (same shape)
sin(matrix) -> matrix (same shape)
sin(3D array) -> 3D array (same shape)
```

### Implementation Pattern
```cpp
if (var.is_scalar()) {
    return Variable(std::sin(var.as_scalar()));
} else if (var.is_vector()) {
    std::vector<double> result;
    result.reserve(var.as_vector().size());
    for (double v : var.as_vector()) {
        result.push_back(std::sin(v));
    }
    return Variable(result);
} else if (var.is_matrix()) {
    // Apply to each element, preserve shape
}
```

## Phase 5: Parser and Evaluator Improvements

### Function Call Parsing
Test and fix:
- [x] sin(x) - basic call
- [x] sin(cos(x)) - nested
- [ ] atan2(y,x) - two arguments
- [ ] sin(x)^2 - operator precedence
- [ ] -sin(x) vs sin(-x)
- [ ] sin([0 pi/2]) - array literal argument

### Operator Precedence
Ensure correct precedence:
1. Function calls (highest)
2. Unary minus
3. Power (^)
4. Multiply/divide
5. Add/subtract (lowest)

### Expression Evaluation
- [ ] sin(x+1) where x is variable
- [ ] sin(A) where A is array (when arrays implemented)
- [ ] sin(x)*cos(x)
- [ ] Broadcasting: sin(A + 1) where A is array

## Testing Strategy

### Unit Tests (C++)
File: `tests/test_functions.cpp`

Use a lightweight testing framework or simple assertions:
```cpp
void test_sin_zero() {
    assert(std::abs(std::sin(0.0) - 0.0) < 1e-15);
}

void test_sin_pi_half() {
    assert(std::abs(std::sin(M_PI/2.0) - 1.0) < 1e-15);
}

void test_sin_identity() {
    double x = 0.5;
    double s = std::sin(x);
    double c = std::cos(x);
    assert(std::abs(s*s + c*c - 1.0) < 1e-15);
}
```

### Integration Tests (MATLAB Scripts)
File: `tests/test_trig.m`

Write MATLAB scripts that run in both MATLAB and MatLabC++:
```matlab
% test_trig.m
x = 0;
assert(sin(x) == 0);

x = pi/2;
result = sin(x);
assert(abs(result - 1.0) < 1e-10);
```

Run in MATLAB: Expected to pass
Run in MatLabC++: Should pass if compatible

### Regression Tests
Every bug fix gets a test case to prevent regression.

## Immediate Action Items for v0.3.1

### 1. Test Current Implementation
- [ ] Build v0.3.1 with latest changes
- [ ] Manual testing of all 15+ functions
- [ ] Document any crashes or incorrect behavior

### 2. Fix Critical Issues
- [ ] Add domain checking to log/log10 (produce error or -Inf/NaN with warning)
- [ ] Verify NaN/Inf handling doesn't crash
- [ ] Test very large values (1e308) don't crash

### 3. Documentation
- [ ] Create MATLAB_COMPATIBILITY.md
- [ ] Document current limitations clearly
- [ ] Update help text to show "scalar only" for trig functions

### 4. Test Script
File: `tests/manual_test_v0.3.1.txt`

```
# Copy-paste into mlab++ REPL

# Test basic trig
sin(0)
sin(1.5708)
cos(0)
cos(3.14159)
tan(0.7854)

# Test identities
x = 0.5
s = sin(x)
c = cos(x)
s*s + c*c

# Test special values
sin(0)
log(1)
log(2.71828)
log10(10)
log10(100)
sqrt(4)
sqrt(2)
abs(-5)

# Test error cases
sin()
sin(1,2)
log(-1)
log(0)
sqrt(-1)

# Test with expressions
x = 3.14159/2
sin(x)
sin(x/2)
sin(2*x)

# Test functions
disp(sin(1))
sum([1 2 3])
mean([1 2 3 4 5])
```

## Success Criteria for v0.3.1

- [ ] All 15 functions work correctly for scalar inputs
- [ ] No crashes on special values (NaN, Inf)
- [ ] Clear error messages for unsupported features
- [ ] MATLAB_COMPATIBILITY.md written and reviewed
- [ ] Manual test script passes without crashes
- [ ] CHANGELOG.md updated with limitations and known issues

## Roadmap Summary

- v0.3.1 (Current): Scalar functions, tested and verified
- v0.3.2: Complete trig family, constants (pi, eps)
- v0.4.0: Array support for all math functions
- v0.5.0: Matrix operations (*, ^, \, /)
- v0.6.0: Array indexing
- v0.7.0: Control flow (if, for, while)
- v0.8.0: Function definitions
- v1.0.0: Production-ready MATLAB-compatible core

## Notes on C++ Strengths to Preserve

While maintaining MATLAB compatibility:

**Performance:**
- Keep zero-copy semantics where possible
- Use move semantics for large arrays
- Compile-time optimizations MATLAB can't do

**Type Safety:**
- C++ strong typing prevents many runtime errors
- Template specialization for performance
- Optional static type checking for user code

**Integration:**
- Easy to call from C++ applications
- Can link against C++ libraries directly
- No JVM or interpreter overhead

**Debugging:**
- Standard C++ debuggers work
- Valgrind, sanitizers for memory issues
- Profiling with standard tools

MATLAB compatibility is about the user interface, not sacrificing C++ advantages.
