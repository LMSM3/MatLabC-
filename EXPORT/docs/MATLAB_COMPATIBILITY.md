# MATLAB Compatibility Contract

## Purpose

This document defines MatLabC++'s compatibility goals with MATLAB and establishes measurable criteria for "99% similarity" claims.

## Compatibility Philosophy

**Goal:** Enable MATLAB users to run their numeric computation scripts in MatLabC++ with minimal or no changes, while preserving C++'s performance and type safety advantages.

**Non-Goal:** Perfect MATLAB clone. Toolboxes, Simulink, GUI components, and esoteric features are out of scope.

## Compatibility Tiers

### Tier 1: Syntax Compatibility
Scripts that use supported features must parse and execute.

**Measurement:** Percentage of MATLAB core syntax constructs that parse correctly.

**Target:**
- v0.3.x: 20% (expressions, variables, basic functions)
- v0.5.x: 50% (arrays, indexing, operators)
- v1.0: 90% (control flow, functions, core operations)

### Tier 2: Semantic Compatibility
Same inputs produce same outputs within tolerance.

**Measurement:** Percentage of test cases that match MATLAB output.

**Tolerance:**
- Floating-point: abs(result - expected) < 1e-10 OR rel_error < 1e-12
- Integers: exact match
- Strings: exact match
- Booleans: exact match

**Target:**
- v0.3.x: 95% for implemented features
- v1.0: 99% for all core features

### Tier 3: Ecosystem Compatibility
Integration with MATLAB toolboxes, file formats, external interfaces.

**Target:** Not in scope for v1.0

## The Sacred Array Model

When arrays are implemented, these are non-negotiable for MATLAB compatibility:

### Storage Model
```
MATLAB: Column-major
MatLabC++: Column-major (REQUIRED)

Rationale: Linear indexing behavior must match.
Implication: Memory layout A(i,j) stored as A[j*rows + i]
```

### Indexing Model
```
MATLAB: 1-based
MatLabC++: 1-based (REQUIRED)

Rationale: A(1) must be first element, not A(0).
Implication: Internal C++ uses 0-based, user-facing is 1-based.
```

### Linear Indexing
```
MATLAB: A(k) accesses element k in column-major order
MatLabC++: Must match exactly

Example:
A = [1 2 3; 4 5 6]
A(1) = 1, A(2) = 4, A(3) = 2, A(4) = 5, A(5) = 3, A(6) = 6
```

### The Colon Operator
```
A(:)     - all elements as column vector
A(:,j)   - column j
A(i,:)   - row i
A(i:j,k) - rows i through j, column k
```

### The end Keyword
```
A(end)     - last element
A(end-1)   - second to last
A(1:end,2) - all rows, column 2
```

## Operator Semantics (Load-Bearing)

These operator meanings are fundamental and cannot be changed:

### Matrix vs Elementwise
```
*   - Matrix multiply (2D), scalar multiply (scalars)
.*  - Elementwise multiply
/   - Right matrix division (A/B means A*inv(B))
./  - Elementwise division
\   - Left matrix division (A\B means inv(A)*B)
.\  - Elementwise left division
^   - Matrix power
.^  - Elementwise power
```

### Dimension Rules
```
A * B    - Inner dimensions must match: (m x n) * (n x p) = (m x p)
A .* B   - Dimensions must match OR broadcast: (m x n) .* (1 x n) = (m x n)
```

### Special Cases
```
scalar * array   - Elementwise multiply (broadcasts)
array + scalar   - Elementwise add (broadcasts)
array1 + array2  - Elementwise if same size, error if incompatible
```

## Function Behavior Contract

### Elementwise Functions
Math functions apply elementwise to arrays:
```
sin(scalar) -> scalar
sin(array)  -> array (same shape, elementwise)

Example:
sin([0 pi/2]) = [0 1]
```

### Reduction Functions
Aggregate functions reduce dimensions:
```
sum(A)      - Sum columns, return row vector
sum(A, 1)   - Sum along dim 1 (columns), return row vector
sum(A, 2)   - Sum along dim 2 (rows), return column vector
sum(A(:))   - Sum all elements, return scalar
```

### Shape-Preserving Functions
Some functions maintain shape:
```
abs(A)   - Same shape as A
sqrt(A)  - Same shape as A
-A       - Same shape as A
```

## Data Type Hierarchy

### Current (v0.3.1)
```
double only (IEEE 754 double precision)
```

### Future (v0.4.0+)
```
double   - Default numeric type
int64    - Integer type (for indexing, counters)
bool     - Logical type (for indexing, conditions)
complex  - Complex numbers (a + bi)
```

### Type Promotion Rules
Match MATLAB's implicit conversions:
```
int + double  -> double
bool + double -> double
real + complex -> complex
```

## Special Values

### NaN (Not-a-Number)
```
Propagates through computations: sin(NaN) = NaN
Comparisons with NaN are always false: NaN == NaN is false
Use isnan(x) to test
```

### Inf (Infinity)
```
1/0 = Inf
-1/0 = -Inf
Inf + Inf = Inf
Inf - Inf = NaN
sin(Inf) = NaN
```

### Empty Arrays
```
[]     - 0x0 array
zeros(0,5) - 0x5 array (valid but empty)
Operations on empty: sum([]) = 0, mean([]) = NaN
```

## Error Handling Philosophy

### MATLAB-Like Errors
When features are unsupported, error messages must:
1. Clearly state the feature is not implemented
2. Suggest alternatives if available
3. Use professional error formatting

**Good:**
```
Error: Array indexing not yet implemented in v0.3.1.
Use scalar values only.
Planned for v0.6.0.
```

**Bad:**
```
segmentation fault (core dumped)
```

### Error Categories
```
TypeError    - Wrong type for operation
ValueError   - Valid type, invalid value (e.g., log(-1))
IndexError   - Array index out of bounds
SyntaxError  - Parse error
RuntimeError - General runtime error
NotImplementedError - Feature not yet available
```

## Testing Contract

### Test Coverage Requirements
Each implemented feature must have:
1. Unit test (C++ level)
2. Integration test (REPL level)
3. Comparison test (MATLAB vs MatLabC++)

### Test Vectors
Standard test set for numeric functions:
```
Special values: 0, -0, Inf, -Inf, NaN
Typical values: 1, -1, 0.5, -0.5, 10, -10
Edge cases: 1e-308 (tiny), 1e308 (huge)
Arrays: empty [], scalar [1], vector [1 2 3], matrix [1 2; 3 4]
```

## Current Implementation Status

### v0.3.1 Supported Features

**Data Types:**
- Scalar (double only)
- Vector (std::vector<double>)
- Matrix (std::vector<std::vector<double>>)

**Operators:**
- Arithmetic: +, -, *, / (scalar only)
- Comparison: None yet
- Logical: None yet

**Functions (Scalar Input Only):**
- Display: disp(x)
- Statistics: sum(x), mean(x), min(x), max(x)
- Array info: size(x), length(x)
- Math: sqrt(x), abs(x)
- Trig: sin(x), cos(x), tan(x)
- Exponential: exp(x), log(x), log10(x)

**Commands:**
- workspace, clear, who, help, version, quit

### v0.3.1 Known Limitations

**Not Implemented:**
- Array indexing: A(1,2), A(:,2)
- Array operators: .*, .^, matrix multiply
- Control flow: if, for, while
- Function definitions
- Complex numbers
- Strings
- Cell arrays, structs

**Bugs/Issues:**
- log(0) returns -Inf (should it error?)
- sqrt(-1) returns NaN (MATLAB returns complex)
- Trig functions don't support arrays yet
- No domain checking on log/sqrt

## Versioned Compatibility Goals

### v0.3.2 (Next)
- [ ] Complete trig family (asin, acos, atan, atan2, sinh, cosh, tanh, asinh, acosh, atanh)
- [ ] Constants: pi, eps, inf, nan
- [ ] deg2rad, rad2deg helpers
- [ ] Domain validation for log/sqrt

### v0.4.0
- [ ] Array support for all math functions
- [ ] Elementwise operators: .*, ./, .^
- [ ] Broadcasting: scalar + array

### v0.5.0
- [ ] Matrix operators: *, ^, \, /
- [ ] Comparison operators: ==, ~=, <, >, <=, >=
- [ ] Logical operators: &, |, ~

### v0.6.0
- [ ] Array indexing: A(i,j), A(i,:), A(:,j)
- [ ] Linear indexing: A(k)
- [ ] end keyword

### v0.7.0
- [ ] Control flow: if, elseif, else, end
- [ ] Loops: for, while, break, continue

### v0.8.0
- [ ] Function definitions
- [ ] Local functions
- [ ] Anonymous functions

### v1.0.0
- [ ] All core features complete
- [ ] 99% semantic compatibility for supported features
- [ ] Comprehensive test suite
- [ ] Production-ready documentation

## C++ Strengths We Preserve

While maintaining MATLAB compatibility, we leverage C++ advantages:

**Performance:**
- Zero-copy semantics via move semantics
- Compile-time optimizations
- Template specialization
- No interpreter overhead

**Type Safety:**
- Compile-time type checking for library users
- Memory safety via RAII
- No hidden type conversions that surprise users

**Integration:**
- Call from C++ applications directly
- Link against C++ libraries
- Standard debugger support
- Standard profiling tools

**Debugging:**
- Valgrind for memory leaks
- AddressSanitizer for memory errors
- GDB/LLDB for debugging
- Deterministic behavior (no JIT surprises)

## Compatibility is Not Cloning

**We match:** Syntax, semantics, numeric results, error behaviors
**We don't match:** Implementation details, performance characteristics, undocumented behaviors

**Example:**
- MATLAB may use LAPACK for matrix multiply
- MatLabC++ may use Eigen or custom SIMD code
- Result: Same answer, potentially different performance or precision

## Measurement and Validation

### Automated Compatibility Testing
```bash
# Run MATLAB reference tests
matlab -batch "run_tests"

# Run MatLabC++ tests
./test_runner

# Compare outputs
./compare_results matlab_output.txt matlabcpp_output.txt
```

### Compatibility Score
```
Score = (Passing tests / Total tests) * 100%

Current (v0.3.1): ~15% (only scalar operations)
Target (v1.0): 99% (core features)
```

### Public Compatibility Matrix
Maintain a public matrix showing which MATLAB features are supported:
```
Feature                    Status      Version
==============================================
Scalar arithmetic          FULL        v0.3.0
Variable assignment        FULL        v0.3.0
Basic trig (scalar)        FULL        v0.3.1
Array indexing             PLANNED     v0.6.0
Matrix multiply            PLANNED     v0.5.0
Control flow               PLANNED     v0.7.0
Plotting                   NOT_PLANNED -
Simulink                   NOT_PLANNED -
```

## Conclusion

This contract ensures MatLabC++ remains "99% MATLAB-compatible" in a measurable, testable way while preserving the performance and safety benefits of C++.

All new features must be validated against this contract before release.
