# Enterprise Stress Test Runner - Usage Guide

**For:** RHEL 9 / AlmaLinux 9 / Rocky Linux 9  
**Purpose:** Production-grade matrix stress testing with data collection

---

## Quick Start (Enterprise User)

```bash
# As regular user (recommended)
cd /opt/matlabcpp  # or your installation directory
./enterprise_stress_test.sh

# With sudo for system metrics (optional)
sudo ./enterprise_stress_test.sh
```

**Time:** 15-30 minutes depending on GPU availability

---

## Prerequisites (Enterprise Linux)

### Install Base Requirements

```bash
# AlmaLinux 9 / RHEL 9
sudo dnf groupinstall "Development Tools"
sudo dnf install cmake gcc-c++ jq

# Optional: GPU support
sudo dnf install nvidia-driver nvidia-settings cuda-toolkit
```

### Verify System

```bash
# Check OS
cat /etc/os-release

# Check resources
lscpu
free -h
df -h

# Check GPU (if available)
nvidia-smi
```

---

## What It Does

### 1. System Discovery
- OS version (RHEL/Alma/Rocky)
- CPU model and cores
- Memory (total/available)
- GPU detection (NVIDIA)
- CUDA version

### 2. Build Verification
- Checks `./build/mlab++` (CPU)
- Checks `./build_gpu/mlab++` (GPU)
- Validates versions

### 3. Test Execution
- CPU baseline (5-10 min)
- GPU stress test (10-20 min if available)
- GPU utilization monitoring

### 4. Data Collection
- JSON (machine-readable)
- Markdown (human-readable)
- Raw logs (troubleshooting)

---

## Output Files

All stored in `stress_results/` directory:

```
stress_results/
├── hostname_20250123_143052_test.log          # Execution log
├── hostname_20250123_143052_results.json      # Structured data
├── hostname_20250123_143052_report.md         # Summary report
├── hostname_20250123_143052_cpu_output.txt    # CPU test output
├── hostname_20250123_143052_gpu_output.txt    # GPU test output (if available)
└── hostname_20250123_143052_gpu_util.log      # GPU utilization (if available)
```

---

## JSON Output Format

```json
{
  "test_metadata": {
    "test_id": "server01.example.com_20250123_143052",
    "hostname": "server01.example.com",
    "timestamp": "20250123_143052",
    "test_type": "matrix_stress_parallel",
    "framework_version": "0.8.0.1"
  },
  "system_info": {
    "os": "AlmaLinux 9.3 (Shamrock Pampas Cat)",
    "kernel": "5.14.0-362.8.1.el9_3.x86_64",
    "cpu_model": "Intel(R) Xeon(R) Gold 6248R CPU @ 3.00GHz",
    "cpu_cores": "96",
    "total_memory": "377Gi",
    "available_memory": "350Gi"
  },
  "gpu_info": {
    "available": true,
    "gpu_name": "NVIDIA A100-PCIE-40GB",
    "memory_mb": "40960",
    "cuda_version": "12.3",
    "driver_version": "545.23.08"
  },
  "build_info": {
    "cpu_build_exists": true,
    "gpu_build_exists": true,
    "cpu_version": "0.4.0",
    "gpu_version": "0.8.0.1"
  },
  "test_results": {
    "cpu_baseline": {
      "status": "completed",
      "duration_seconds": "287",
      "matrix_multiply_1000": "0.523",
      "output_file": "./stress_results/hostname_cpu_output.txt"
    },
    "gpu_full": {
      "status": "completed",
      "duration_seconds": "542",
      "average_speedup": "87.3",
      "performance_status": "GOOD GPU PERFORMANCE",
      "output_file": "./stress_results/hostname_gpu_output.txt"
    }
  },
  "performance_metrics": {
    "cpu_gflops": "38.2",
    "gpu_gflops": "3336.5",
    "speedup_factor": "87.3"
  },
  "validation": {
    "overall_status": "PASS"
  }
}
```

---

## Integration with Enterprise Tools

### 1. Jenkins/GitLab CI

```groovy
// Jenkinsfile
stage('Matrix Stress Test') {
    steps {
        sh './enterprise_stress_test.sh'
        archiveArtifacts artifacts: 'stress_results/*.json', fingerprint: true
        junit 'stress_results/*_results.json'  // with parser plugin
    }
}
```

### 2. Ansible Playbook

```yaml
- name: Run MatLabC++ stress tests
  hosts: compute_nodes
  tasks:
    - name: Execute stress test
      command: /opt/matlabcpp/enterprise_stress_test.sh
      register: test_result
      
    - name: Collect results
      fetch:
        src: /opt/matlabcpp/stress_results/{{ ansible_hostname }}_*_results.json
        dest: ./test_results/
        flat: yes
```

### 3. Prometheus Metrics Export

```bash
# Extract metrics from JSON for Prometheus
jq -r '.performance_metrics | to_entries | .[] | "matlabcpp_\(.key) \(.value)"' \
  stress_results/*_results.json > /var/lib/node_exporter/textfile_collector/matlabcpp.prom
```

### 4. Splunk/ELK Log Ingestion

```bash
# Ship JSON to logging infrastructure
cat stress_results/*_results.json | \
  curl -X POST -H "Content-Type: application/json" \
       -d @- http://logserver:8088/services/collector/event
```

---

## Enterprise Use Cases

### 1. Hardware Acceptance Testing

```bash
# Run on new hardware before production
./enterprise_stress_test.sh
# Verify GPU speedup > 50x
jq '.test_results.gpu_full.average_speedup' stress_results/*_results.json
```

### 2. Performance Regression Testing

```bash
# After system updates
sudo dnf update -y
reboot
./enterprise_stress_test.sh

# Compare with baseline
jq '.performance_metrics.speedup_factor' stress_results/baseline_results.json
jq '.performance_metrics.speedup_factor' stress_results/latest_results.json
```

### 3. Capacity Planning

```bash
# Test with different problem sizes
# Edit test scripts to modify matrix sizes
# Run on different hardware tiers
# Compare cost/performance
```

### 4. Multi-Node Benchmarking

```bash
# Run across cluster
pdsh -w compute[01-10] "cd /opt/matlabcpp && ./enterprise_stress_test.sh"

# Aggregate results
cat /opt/matlabcpp/stress_results/*.json | jq -s '.'
```

---

## Troubleshooting (RHEL/Alma)

### Issue: GPU not detected

```bash
# Check driver
lsmod | grep nvidia

# Reinstall if needed
sudo dnf reinstall nvidia-driver kmod-nvidia-latest-dkms

# Verify
nvidia-smi
```

### Issue: Out of memory

```bash
# Check available
free -h

# Check swap
swapon -s

# Adjust test size
# Edit tests/stress_matrix_parallel.m
# Reduce sizes array: [500, 1000] instead of [500, 1000, 2000, 4000]
```

### Issue: Permission denied

```bash
# Fix ownership
sudo chown -R $USER:$USER /opt/matlabcpp

# Or run with sudo (not recommended for tests)
sudo -E ./enterprise_stress_test.sh
```

---

## Monitoring During Test

### Terminal 1: Run test
```bash
./enterprise_stress_test.sh
```

### Terminal 2: Monitor GPU
```bash
watch -n 1 nvidia-smi
```

### Terminal 3: Monitor CPU/Memory
```bash
htop
```

### Terminal 4: Monitor logs
```bash
tail -f stress_results/*_test.log
```

---

## Data Analysis (Enterprise)

### Extract key metrics

```bash
# All speedups across tests
jq '.test_results.gpu_full.average_speedup' stress_results/*.json

# CPU performance baseline
jq '.test_results.cpu_baseline.matrix_multiply_1000' stress_results/*.json

# System configurations
jq '.system_info.cpu_model' stress_results/*.json | sort -u
```

### Generate summary report

```bash
# Aggregate multiple runs
jq -s 'group_by(.system_info.hostname) | 
       map({hostname: .[0].system_info.hostname, 
            avg_speedup: (map(.test_results.gpu_full.average_speedup | tonumber) | 
                         add / length)})' stress_results/*.json
```

---

## Exit Codes

- `0` - All tests passed (PASS)
- `0` - CPU only completed (PARTIAL)
- `1` - Tests failed (FAIL)

```bash
# Use in scripts
if ./enterprise_stress_test.sh; then
    echo "Tests passed, deploying to production"
else
    echo "Tests failed, investigating"
fi
```

---

## Security Considerations

### Run as non-root user
```bash
# Create dedicated user
sudo useradd -m -s /bin/bash matlabcpp_test

# Grant GPU access
sudo usermod -a -G video matlabcpp_test

# Run as that user
sudo -u matlabcpp_test ./enterprise_stress_test.sh
```

### SELinux compatibility

```bash
# Check status
getenforce

# If enforcing and issues occur:
sudo setenforce 0  # Temporary
# OR create custom policy (recommended)
```

---

**Status:** ✅ Ready for enterprise deployment  
**Support:** See main project documentation  
**License:** Same as MatLabC++ project
