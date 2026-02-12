#!/bin/bash
# BETA_TEST_00 - Variable assignment and sine function test
# Test: A = 5, sin(A) repeated 10 times

TEST_ID="beta_test_00"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="test_results/${TEST_ID}_${TIMESTAMP}.md"

mkdir -p test_results

echo "================================================"
echo "BETA_TEST_00: Variable + Sin Function"
echo "================================================"
echo "Test: A = 5, sin(A) × 10 iterations"
echo "Expected: sin(5) ≈ -0.9589"
echo ""

# Initialize results file
cat > "${RESULTS_FILE}" << EOF
# Beta Test 00 - Results

**Test ID:** ${TEST_ID}  
**Timestamp:** ${TIMESTAMP}  
**Test:** Variable assignment + sine function  
**Iterations:** 10

---

## Test Configuration

\`\`\`
A = 5
sin(A)
\`\`\`

**Expected Result:** sin(5) ≈ -0.9589242747

---

## Results

EOF

# Run 10 iterations
pass_count=0
fail_count=0

for i in {1..10}; do
    echo "Iteration $i..."

    # Run test and capture exit code
    result=$(echo -e "A = 5\nsin(A)\nquit" | ./build/mlab++ 2>&1)
    exit_code=$?

    # Check for crash
    if [ $exit_code -ne 0 ]; then
        echo "  ✗ FAIL (program crashed with exit code $exit_code)"
        cat >> "${RESULTS_FILE}" << EOF
### Iteration $i
\`\`\`
Status: ✗ FAIL (program crashed)
Exit code: $exit_code
\`\`\`

EOF
        ((fail_count++))
        continue
    fi

    # Extract answer (look for numeric result)
    answer=$(echo "$result" | grep -oP "ans =\s*\K-?[0-9]+\.?[0-9]*" | tail -1)
    
    # Log to file
    cat >> "${RESULTS_FILE}" << EOF
### Iteration $i
\`\`\`
Result: $answer
EOF
    
    # Check if result is close to expected (-0.9589)
    if [ ! -z "$answer" ]; then
        # Use bc -l for floating point comparison (critical!)
        # Calculate absolute difference
        diff=$(echo "scale=10; d = $answer + 0.9589242747; if (d < 0) -d else d" | bc -l)
        is_close=$(echo "scale=10; $diff < 0.001" | bc -l)

        # Debug: Check if degrees mode (sin(5°) ≈ 0.0871)
        is_degrees=$(echo "scale=10; d = $answer - 0.0871; if (d < 0) -d else d; d < 0.01" | bc -l)

        if [ "$is_close" -eq 1 ]; then
            echo "  ✓ PASS (result: $answer, diff: $diff)"
            cat >> "${RESULTS_FILE}" << EOF
Status: ✓ PASS
Result: $answer
Difference from expected: $diff
EOF
            ((pass_count++))
        elif [ "$is_degrees" -eq 1 ]; then
            echo "  ✗ FAIL (degrees mode detected: $answer)"
            cat >> "${RESULTS_FILE}" << EOF
Status: ✗ FAIL (calculator in degrees mode, not radians)
Result: $answer (expected -0.9589 in radians, got ~0.0871 degrees)
EOF
            ((fail_count++))
        else
            echo "  ✗ FAIL (result: $answer, expected: -0.9589, diff: $diff)"
            cat >> "${RESULTS_FILE}" << EOF
Status: ✗ FAIL (unexpected value)
Result: $answer
Expected: -0.9589242747
Difference: $diff
EOF
            ((fail_count++))
        fi
    else
        echo "  ✗ FAIL (no result)"
        cat >> "${RESULTS_FILE}" << EOF
Status: ✗ FAIL (no result returned)
EOF
        ((fail_count++))
    fi
    
    echo "\`\`\`" >> "${RESULTS_FILE}"
    echo "" >> "${RESULTS_FILE}"
done

# Summary
cat >> "${RESULTS_FILE}" << EOF

---

## Summary

| Metric | Value |
|--------|-------|
| Total Iterations | 10 |
| Passed | $pass_count |
| Failed | $fail_count |
| Pass Rate | $((pass_count * 10))% |

EOF

if [ $pass_count -eq 10 ]; then
    cat >> "${RESULTS_FILE}" << EOF
**Overall Status:** ✅ ALL TESTS PASSED

The variable assignment and sin() function work correctly across all 10 iterations.
EOF
    echo ""
    echo "================================================"
    echo "✅ ALL 10 TESTS PASSED"
    echo "================================================"
elif [ $pass_count -ge 7 ]; then
    cat >> "${RESULTS_FILE}" << EOF
**Overall Status:** PARTIAL PASS ($pass_count/10)

Most tests passed, but some inconsistencies detected.
EOF
    echo ""
    echo "================================================"
    echo "⚠️ MOSTLY PASSED ($pass_count/10)"
    echo "================================================"
else
    cat >> "${RESULTS_FILE}" << EOF
**Overall Status:** ❌ FAILED ($pass_count/10 passed)

Multiple test failures detected. Investigation required.
EOF
    echo ""
    echo "================================================"
    echo "❌ FAILED ($pass_count/10 passed)"
    echo "================================================"
fi

echo ""
echo "Results saved to: ${RESULTS_FILE}"
echo ""

# Display summary
cat << EOF

Test Details:
  Pass: $pass_count
  Fail: $fail_count
  Rate: $((pass_count * 10))%

EOF

exit $fail_count
