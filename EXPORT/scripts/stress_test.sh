#!/bin/bash
# MatLabC++ v0.4.0 Stress Test Suite

echo "========================================="
echo "MatLabC++ v0.4.0 STRESS TEST"
echo "========================================="
echo ""

MLAB="./build/mlab++"
PASS=0
FAIL=0
ERRORS=""

# Helper function
test_cmd() {
    local desc="$1"
    local cmd="$2"
    local expected="$3"
    
    echo -n "Testing: $desc... "
    
    result=$(echo "$cmd" | $MLAB 2>&1 | grep -v ">>>" | grep -v "MatLabC++" | grep -v "Type" | grep -v "Thank you" | tail -1)
    
    if [[ "$result" == *"$expected"* ]]; then
        echo "✓ PASS"
        ((PASS++))
    else
        echo "✗ FAIL"
        echo "  Expected: $expected"
        echo "  Got: $result"
        ERRORS="${ERRORS}\n${desc}: Expected '${expected}', got '${result}'"
        ((FAIL++))
    fi
}

# ========== BASIC MATH ==========
echo "=== BASIC MATH ==="
test_cmd "Addition" "2 + 2" "4"
test_cmd "Subtraction" "10 - 3" "7"
test_cmd "Multiplication" "5 * 6" "30"
test_cmd "Division" "20 / 4" "5"

# ========== FUNCTIONS ==========
echo ""
echo "=== SCALAR FUNCTIONS ==="
test_cmd "sin(0)" "sin(0)" "0"
test_cmd "cos(0)" "cos(0)" "1"
test_cmd "sqrt(4)" "sqrt(4)" "2"
test_cmd "exp(0)" "exp(0)" "1"
test_cmd "log(1)" "log(1)" "0"
test_cmd "abs(-5)" "abs(-5)" "5"

# ========== SPECIAL VALUES ==========
echo ""
echo "=== SPECIAL VALUES ==="
test_cmd "log(0)" "log(0)" "Inf"
test_cmd "sqrt(-1)" "sqrt(-1)" "NaN"
test_cmd "1/0" "1/0" "Inf"

# ========== NESTED CALLS ==========
echo ""
echo "=== NESTED CALLS ==="
test_cmd "sin(cos(0))" "sin(cos(0))" "0.84"  # sin(1) ≈ 0.8415
test_cmd "sqrt(abs(-16))" "sqrt(abs(-16))" "4"

# ========== MATRIX OPERATIONS (NEW!) ==========
echo ""
echo "=== MATRIX OPERATIONS (v0.4.0) ==="

# Test matrix creation
echo -n "Testing: Matrix creation... "
result=$(echo "A = [1 2; 3 4]
quit" | $MLAB 2>&1 | grep "1.0000")
if [[ -n "$result" ]]; then
    echo "✓ PASS"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
    ERRORS="${ERRORS}\nMatrix creation failed"
fi

# ========== LARGE VALUE STRESS ==========
echo ""
echo "=== LARGE VALUE STRESS ==="
test_cmd "exp(10)" "exp(10)" "22026"
test_cmd "log(1000)" "log(1000)" "6.9"
test_cmd "sqrt(1000000)" "sqrt(1000000)" "1000"

# ========== RAPID FIRE (100 operations) ==========
echo ""
echo "=== RAPID FIRE TEST (100 operations) ==="
start_time=$(date +%s%N)

for i in {1..100}; do
    echo "sin($i) + cos($i)" | $MLAB > /dev/null 2>&1
done

end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))  # Convert to ms

echo "Completed 100 operations in ${duration}ms"
if [ $duration -lt 10000 ]; then
    echo "✓ PASS (< 10 seconds)"
    ((PASS++))
else
    echo "✗ FAIL (too slow)"
    ((FAIL++))
fi

# ========== MEMORY STRESS ==========
echo ""
echo "=== MEMORY STRESS (1000 variables) ==="
mem_test="quit"
for i in {1..1000}; do
    mem_test="x$i = $i
$mem_test"
done

start_mem=$(free -m | awk 'NR==2{print $3}')
echo "$mem_test" | $MLAB > /dev/null 2>&1
end_mem=$(free -m | awk 'NR==2{print $3}')
mem_used=$((end_mem - start_mem))

echo "Memory used: ${mem_used}MB"
if [ $mem_used -lt 100 ]; then
    echo "✓ PASS (< 100MB)"
    ((PASS++))
else
    echo "✗ FAIL (excessive memory)"
    ((FAIL++))
fi

# ========== WORKSPACE STRESS ==========
echo ""
echo "=== WORKSPACE STRESS ==="
test_cmd "Variable assignment" "x = 42" "42"
test_cmd "Variable retrieval" "x = 5
x" "5"

# ========== EDGE CASE CRASH TEST ==========
echo ""
echo "=== CRASH RESISTANCE ==="

# These should NOT crash
crash_tests=(
    "log(0)"
    "log(-1)"
    "sqrt(-1)"
    "1/0"
    "0/0"
    "sin(1e308)"
    "exp(1000)"
)

for test in "${crash_tests[@]}"; do
    echo -n "  $test... "
    if echo "$test" | timeout 2 $MLAB > /dev/null 2>&1; then
        echo "✓ No crash"
        ((PASS++))
    else
        echo "✗ CRASHED"
        ((FAIL++))
        ERRORS="${ERRORS}\nCRASH: $test"
    fi
done

# ========== RESULTS ==========
echo ""
echo "========================================="
echo "STRESS TEST COMPLETE"
echo "========================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Total:  $((PASS + FAIL))"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "🎉 ALL TESTS PASSED! 🎉"
    echo "v0.4.0 is ROCK SOLID!"
    exit 0
else
    echo ""
    echo "⚠️  FAILURES DETECTED"
    echo -e "$ERRORS"
    exit 1
fi
