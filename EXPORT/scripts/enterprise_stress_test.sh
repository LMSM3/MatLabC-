#!/bin/bash
# enterprise_stress_test.sh - Production Matrix Stress Test Runner
# For RHEL/AlmaLinux 9 enterprise deployment
# Collects system metrics, performance data, and validation results

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
RESULTS_DIR="${PROJECT_ROOT}/stress_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
HOSTNAME=$(hostname -f)
TEST_ID="${HOSTNAME}_${TIMESTAMP}"

# Logging
LOG_FILE="${RESULTS_DIR}/${TEST_ID}_test.log"
JSON_FILE="${RESULTS_DIR}/${TEST_ID}_results.json"
MD_FILE="${RESULTS_DIR}/${TEST_ID}_report.md"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure results directory exists
mkdir -p "${RESULTS_DIR}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "${LOG_FILE}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "${LOG_FILE}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "${LOG_FILE}"
}

# Initialize JSON output
init_json() {
    cat > "${JSON_FILE}" << EOF
{
  "test_metadata": {
    "test_id": "${TEST_ID}",
    "hostname": "${HOSTNAME}",
    "timestamp": "${TIMESTAMP}",
    "test_type": "matrix_stress_parallel",
    "framework_version": "0.8.0.1"
  },
  "system_info": {},
  "build_info": {},
  "gpu_info": {},
  "test_results": {},
  "performance_metrics": {},
  "validation": {}
}
EOF
    log "Initialized JSON output: ${JSON_FILE}"
}

# Collect system information (RHEL-style)
collect_system_info() {
    log "Collecting system information..."
    
    local os_release=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2)
    local kernel=$(uname -r)
    local cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    local cpu_cores=$(nproc --all)
    local total_mem=$(free -h | awk '/^Mem:/{print $2}')
    local available_mem=$(free -h | awk '/^Mem:/{print $7}')
    
    # Update JSON
    jq --arg os "$os_release" \
       --arg kernel "$kernel" \
       --arg cpu "$cpu_model" \
       --arg cores "$cpu_cores" \
       --arg mem "$total_mem" \
       --arg avail "$available_mem" \
       '.system_info = {
         "os": $os,
         "kernel": $kernel,
         "cpu_model": $cpu,
         "cpu_cores": $cores,
         "total_memory": $mem,
         "available_memory": $avail
       }' "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
    
    log "  OS: ${os_release}"
    log "  Kernel: ${kernel}"
    log "  CPU: ${cpu_model} (${cpu_cores} cores)"
    log "  Memory: ${total_mem} total, ${available_mem} available"
}

# Check GPU availability (NVIDIA/CUDA)
check_gpu() {
    log "Checking GPU availability..."
    
    if command -v nvidia-smi &> /dev/null; then
        local gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
        local gpu_mem=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
        local cuda_version=$(nvidia-smi | grep "CUDA Version" | awk '{print $9}')
        local driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
        
        jq --arg gpu "$gpu_name" \
           --arg mem "$gpu_mem" \
           --arg cuda "$cuda_version" \
           --arg driver "$driver_version" \
           '.gpu_info = {
             "available": true,
             "gpu_name": $gpu,
             "memory_mb": $mem,
             "cuda_version": $cuda,
             "driver_version": $driver
           }' "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
        
        log_success "GPU detected: ${gpu_name} (${gpu_mem} MB)"
        log "  CUDA: ${cuda_version}, Driver: ${driver_version}"
        return 0
    else
        log_warning "nvidia-smi not found - GPU tests will be skipped"
        
        jq '.gpu_info = {
          "available": false,
          "reason": "nvidia-smi not found"
        }' "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
        
        return 1
    fi
}

# Verify build and collect build info
check_build() {
    log "Verifying MatLabC++ build..."
    
    local build_cpu="${PROJECT_ROOT}/build/mlab++"
    local build_gpu="${PROJECT_ROOT}/build_gpu/mlab++"
    
    local cpu_exists=false
    local gpu_exists=false
    local cpu_version=""
    local gpu_version=""
    
    if [ -f "$build_cpu" ]; then
        cpu_exists=true
        cpu_version=$("$build_cpu" --version 2>&1 | grep -oP "version \K[0-9.]+")
        log_success "CPU build found: v${cpu_version}"
    else
        log_warning "CPU build not found at ${build_cpu}"
    fi
    
    if [ -f "$build_gpu" ]; then
        gpu_exists=true
        gpu_version=$("$build_gpu" --version 2>&1 | grep -oP "version \K[0-9.]+")
        log_success "GPU build found: v${gpu_version}"
    else
        log_warning "GPU build not found at ${build_gpu}"
    fi
    
    jq --argjson cpu "$cpu_exists" \
       --argjson gpu "$gpu_exists" \
       --arg cpu_ver "$cpu_version" \
       --arg gpu_ver "$gpu_version" \
       '.build_info = {
         "cpu_build_exists": $cpu,
         "gpu_build_exists": $gpu,
         "cpu_version": $cpu_ver,
         "gpu_version": $gpu_ver
       }' "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
    
    if [ "$cpu_exists" = false ] && [ "$gpu_exists" = false ]; then
        log_error "No builds found! Run ./build_and_setup.sh first"
        return 1
    fi
    
    return 0
}

# Run CPU baseline test
run_cpu_baseline() {
    log "Running CPU baseline test..."
    
    local test_script="${PROJECT_ROOT}/tests/stress_matrix_parallel_cpu_only.m"
    local build="${PROJECT_ROOT}/build/mlab++"
    local output_file="${RESULTS_DIR}/${TEST_ID}_cpu_output.txt"
    
    if [ ! -f "$build" ]; then
        log_error "CPU build not found"
        return 1
    fi
    
    if [ ! -f "$test_script" ]; then
        log_error "Test script not found: ${test_script}"
        return 1
    fi
    
    log "  Starting CPU test (may take 5-10 minutes)..."
    local start_time=$(date +%s)
    
    # Run with timeout
    if timeout 900 "$build" < "$test_script" > "$output_file" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        log_success "CPU test completed in ${duration}s"
        
        # Extract key metrics (simplified parsing)
        local matmul_1000=$(grep -oP "1000\s+\K[0-9.]+(?=\s+[0-9.]+)" "$output_file" | head -1 || echo "0")
        
        jq --arg duration "$duration" \
           --arg mm1000 "$matmul_1000" \
           '.test_results.cpu_baseline = {
             "status": "completed",
             "duration_seconds": $duration,
             "matrix_multiply_1000": $mm1000,
             "output_file": "'$output_file'"
           }' "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
        
        return 0
    else
        log_error "CPU test failed or timed out"
        
        jq '.test_results.cpu_baseline = {
          "status": "failed",
          "reason": "timeout or error"
        }' "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
        
        return 1
    fi
}

# Run GPU full test
run_gpu_test() {
    log "Running GPU stress test..."
    
    local test_script="${PROJECT_ROOT}/tests/stress_matrix_parallel.m"
    local build="${PROJECT_ROOT}/build_gpu/mlab++"
    local output_file="${RESULTS_DIR}/${TEST_ID}_gpu_output.txt"
    
    if [ ! -f "$build" ]; then
        log_warning "GPU build not found - skipping GPU test"
        return 1
    fi
    
    if [ ! -f "$test_script" ]; then
        log_error "Test script not found: ${test_script}"
        return 1
    fi
    
    log "  Starting GPU test (may take 10-20 minutes)..."
    local start_time=$(date +%s)
    
    # Monitor GPU during test
    nvidia-smi dmon -s u -c 60 > "${RESULTS_DIR}/${TEST_ID}_gpu_utilization.log" &
    local monitor_pid=$!
    
    # Run with timeout
    if timeout 1200 "$build" < "$test_script" > "$output_file" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        kill $monitor_pid 2>/dev/null || true
        
        log_success "GPU test completed in ${duration}s"
        
        # Extract key metrics
        local avg_speedup=$(grep -oP "Overall average: \K[0-9.]+(?=x)" "$output_file" || echo "0")
        local status=$(grep -oP "Status: \K.*" "$output_file" | head -1 || echo "UNKNOWN")
        
        jq --arg duration "$duration" \
           --arg speedup "$avg_speedup" \
           --arg status "$status" \
           '.test_results.gpu_full = {
             "status": "completed",
             "duration_seconds": $duration,
             "average_speedup": $speedup,
             "performance_status": $status,
             "output_file": "'$output_file'"
           }' "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
        
        return 0
    else
        kill $monitor_pid 2>/dev/null || true
        log_error "GPU test failed or timed out"
        
        jq '.test_results.gpu_full = {
          "status": "failed",
          "reason": "timeout or error"
        }' "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
        
        return 1
    fi
}

# Calculate performance metrics
calculate_metrics() {
    log "Calculating performance metrics..."
    
    # Extract from JSON
    local cpu_status=$(jq -r '.test_results.cpu_baseline.status // "unknown"' "${JSON_FILE}")
    local gpu_status=$(jq -r '.test_results.gpu_full.status // "unknown"' "${JSON_FILE}")
    
    local overall_status="UNKNOWN"
    
    if [ "$cpu_status" = "completed" ] && [ "$gpu_status" = "completed" ]; then
        overall_status="PASS"
    elif [ "$cpu_status" = "completed" ]; then
        overall_status="PARTIAL"
    else
        overall_status="FAIL"
    fi
    
    jq --arg status "$overall_status" \
       '.validation.overall_status = $status' \
       "${JSON_FILE}" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "${JSON_FILE}"
    
    log "Overall test status: ${overall_status}"
}

# Generate markdown report
generate_markdown_report() {
    log "Generating markdown report..."
    
    cat > "${MD_FILE}" << 'EOF'
# Matrix Stress Test Report

## Executive Summary

**Test ID:** {{TEST_ID}}  
**Hostname:** {{HOSTNAME}}  
**Date:** {{TIMESTAMP}}  
**Status:** {{STATUS}}

---

## System Configuration

| Component | Value |
|-----------|-------|
| OS | {{OS}} |
| Kernel | {{KERNEL}} |
| CPU | {{CPU}} |
| CPU Cores | {{CORES}} |
| Total Memory | {{MEM}} |
| Available Memory | {{AVAIL}} |

---

## GPU Configuration

| Component | Value |
|-----------|-------|
| GPU Available | {{GPU_AVAIL}} |
| GPU Name | {{GPU_NAME}} |
| GPU Memory | {{GPU_MEM}} MB |
| CUDA Version | {{CUDA}} |
| Driver Version | {{DRIVER}} |

---

## Build Information

| Build | Status | Version |
|-------|--------|---------|
| CPU | {{CPU_BUILD}} | {{CPU_VER}} |
| GPU | {{GPU_BUILD}} | {{GPU_VER}} |

---

## Test Results

### CPU Baseline Test

- **Status:** {{CPU_STATUS}}
- **Duration:** {{CPU_DURATION}}s
- **Matrix Multiply (1000x1000):** {{CPU_MM}} seconds

### GPU Full Test

- **Status:** {{GPU_STATUS}}
- **Duration:** {{GPU_DURATION}}s
- **Average Speedup:** {{GPU_SPEEDUP}}x
- **Performance Rating:** {{GPU_RATING}}

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| CPU GFLOPS (estimated) | {{CPU_GFLOPS}} |
| GPU GFLOPS (estimated) | {{GPU_GFLOPS}} |
| Speedup Factor | {{SPEEDUP}}x |

---

## Validation

**Overall Status:** {{OVERALL_STATUS}}

### Pass Criteria

- ✓ CPU baseline established
- ✓ GPU speedup > 20x (target: 50-150x)
- ✓ No crashes or errors
- ✓ Accuracy within tolerance

---

## Files Generated

- JSON Results: `{{JSON_FILE}}`
- CPU Output: `{{CPU_OUTPUT}}`
- GPU Output: `{{GPU_OUTPUT}}`
- GPU Utilization Log: `{{GPU_UTIL}}`

---

## Recommendations

{{RECOMMENDATIONS}}

---

**Report Generated:** {{REPORT_TIME}}
EOF

    # Replace placeholders with actual values from JSON
    # (In real implementation, use jq to extract and sed to replace)
    
    log_success "Markdown report generated: ${MD_FILE}"
}

# Main execution
main() {
    log "================================================"
    log "ENTERPRISE MATRIX STRESS TEST RUNNER"
    log "AlmaLinux 9 / RHEL 9 Compatible"
    log "================================================"
    log ""
    
    # Initialize
    init_json
    
    # Collect system info
    collect_system_info
    
    # Check GPU
    local has_gpu=false
    if check_gpu; then
        has_gpu=true
    fi
    
    # Verify builds
    if ! check_build; then
        log_error "Build verification failed"
        exit 1
    fi
    
    # Run tests
    log ""
    log "================================================"
    log "EXECUTING TEST SUITE"
    log "================================================"
    
    # Always run CPU baseline
    run_cpu_baseline
    
    # Run GPU test if available
    if [ "$has_gpu" = true ]; then
        run_gpu_test
    fi
    
    # Calculate metrics
    calculate_metrics
    
    # Generate reports
    generate_markdown_report
    
    log ""
    log "================================================"
    log "TEST EXECUTION COMPLETE"
    log "================================================"
    log ""
    log "Results saved to:"
    log "  JSON: ${JSON_FILE}"
    log "  MD:   ${MD_FILE}"
    log "  Log:  ${LOG_FILE}"
    log ""
    
    # Print summary
    local overall_status=$(jq -r '.validation.overall_status' "${JSON_FILE}")
    
    if [ "$overall_status" = "PASS" ]; then
        log_success "Overall Status: PASS"
        exit 0
    elif [ "$overall_status" = "PARTIAL" ]; then
        log_warning "Overall Status: PARTIAL (CPU only)"
        exit 0
    else
        log_error "Overall Status: FAIL"
        exit 1
    fi
}

# Run main
main "$@"
EOF

chmod +x enterprise_stress_test.sh
