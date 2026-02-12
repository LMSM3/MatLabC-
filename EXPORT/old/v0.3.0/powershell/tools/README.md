# Production Testing & Automation Tools

**Package Version:** 1.0  
**Self-extracting deployment package for production environments**

---

## 🎯 Quick Start

```bash
# Build all tools
./BUILD_ALL.sh

# Or build individually
gcc -O2 -o memleak memory_leak_detector.c
g++ -O2 -std=c++17 -o writebench write_speed_benchmark.cpp
g++ -O2 -std=c++17 -o codereader code_reader.cpp
gcc -O2 -o perfprof perf_profiler.c -lpthread
chmod +x *.sh
```

---

## 🛠️ Tools Overview

### 1. Memory Leak Detector (`memleak`)
**Language:** C  
**Purpose:** Track memory usage of running processes to detect leaks

```bash
# Monitor process PID 1234
./memleak 1234

# Monitor with 5-second intervals
./memleak 1234 5

# Output: memory_leak.log
```

**Features:**
- Real-time RSS/VMS monitoring
- Delta tracking between samples
- Automatic leak detection heuristics
- CSV log export for visualization

**Use Cases:**
- Long-running daemon monitoring
- Production memory leak detection
- Performance regression testing

---

### 2. Write Speed Benchmark (`writebench`)
**Language:** C++17  
**Purpose:** Benchmark disk I/O performance

```bash
# Default: 100MB sequential + random write tests
./writebench

# Custom size: 500MB with 128KB blocks
./writebench 500 128
```

**Features:**
- Sequential write throughput (MB/s)
- Random 4KB write IOPS
- Automatic performance classification (HDD/SSD/NVMe)
- Self-cleaning (auto-deletes test files)

**Use Cases:**
- Storage performance validation
- Regression testing after OS updates
- SAN/NAS performance monitoring

---

### 3. GPU Monitor (`gpu_monitor.sh`)
**Language:** Bash  
**Purpose:** Track GPU utilization, temperature, and memory

```bash
# Auto-detect GPU and monitor (default: 5s interval)
./gpu_monitor.sh

# Custom interval (10 seconds)
./gpu_monitor.sh 10

# Output: gpu_monitor.log
```

**Supported GPUs:**
- NVIDIA (via `nvidia-smi`)
- AMD (via `rocm-smi`)
- Intel (via `intel_gpu_top`)

**Features:**
- Real-time utilization tracking
- Temperature monitoring with alerts
- Memory usage tracking
- Power consumption logging

**Use Cases:**
- ML/AI training monitoring
- Gaming performance tracking
- Render farm monitoring

---

### 4. Code Deployer (`code_deployer.sh`)
**Language:** Bash  
**Purpose:** Automated deployment of code packages

```bash
# Deploy package
./code_deployer.sh deploy myapp.tar.gz

# Deploy with custom name
./code_deployer.sh deploy myapp.tar.gz production_app

# Rollback to previous version
./code_deployer.sh rollback production_app

# List deployed applications
./code_deployer.sh list
```

**Features:**
- Automatic backup before deployment
- Pre/post-deploy hooks support
- Dependency installation (pip, npm, make)
- Rollback capability
- Deployment logging

**Use Cases:**
- Production deployments
- CI/CD pipeline integration
- Blue-green deployment automation

---

### 5. Code Reader (`codereader`)
**Language:** C++17  
**Purpose:** Analyze source code and provide statistics

```bash
# Analyze source file
./codereader myfile.cpp

# Analyze Python script
./codereader script.py
```

**Features:**
- Line counting (code/comments/blank)
- Function and class detection
- Keyword frequency analysis
- Complexity assessment
- Multi-language support (C, C++, Python, JavaScript, Shell)

**Output:**
- Total/code/comment line percentages
- Include/function/class counts
- Keyword usage statistics
- Cyclomatic complexity estimate

**Use Cases:**
- Code review preparation
- Technical debt assessment
- Refactoring prioritization

---

### 6. Test Runner (`test_runner.sh`)
**Language:** Bash  
**Purpose:** Discover and execute test suites

```bash
# Run all tests in current directory
./test_runner.sh

# Run tests in specific directory
./test_runner.sh -d /path/to/tests

# Build C++ tests first, then run
./test_runner.sh -b -d ./tests

# Output: test_report.txt
```

**Features:**
- Auto-discovery of test files (test_*.cpp, test_*.py, test_*.sh)
- Parallel test execution support
- Pass/fail tracking with statistics
- Detailed HTML/text reports
- Build integration for C++ tests

**Use Cases:**
- CI/CD test execution
- Pre-deployment validation
- Regression testing

---

### 7. Performance Profiler (`perfprof`)
**Language:** C  
**Purpose:** Lightweight CPU and memory profiling

```bash
# Run test workload
./perfprof --test

# Instrument your own code:
# profiler_start("section_name");
# // ... your code ...
# profiler_end("section_name");
```

**Features:**
- Checkpoint-based profiling
- Time measurement (milliseconds)
- Memory usage tracking
- Coverage analysis
- Low overhead (<1%)

**Use Cases:**
- Production hotspot identification
- Optimization validation
- Performance regression detection

---

## 📦 Deployment

These tools are designed to be deployed as a **self-extracting package**:

### Create Deployment Package

```bash
# Create package
tar -czf prodtools.tar.gz tools/

# Add self-extractor (optional)
cat > deploy_tools.sh << 'EOF'
#!/bin/bash
ARCHIVE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0)
tail -n+$ARCHIVE $0 | tar xzv -C /opt/
cd /opt/tools && ./BUILD_ALL.sh
rm $0  # Self-delete after extraction
exit 0
__ARCHIVE_BELOW__
EOF

cat prodtools.tar.gz >> deploy_tools.sh
chmod +x deploy_tools.sh
```

### Deploy

```bash
# One-liner deployment (extracts, builds, self-deletes)
./deploy_tools.sh
```

---

## 🔧 Integration Examples

### CI/CD Pipeline (GitHub Actions)

```yaml
name: Production Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build tools
        run: |
          cd tools
          ./BUILD_ALL.sh
      
      - name: Run memory leak check
        run: |
          ./my_app &
          APP_PID=$!
          tools/memleak $APP_PID 10 &
          sleep 60
          kill $APP_PID
      
      - name: Run performance benchmark
        run: tools/writebench 100
      
      - name: Run tests
        run: tools/test_runner.sh -d tests/
      
      - name: Upload reports
        uses: actions/upload-artifact@v2
        with:
          name: test-reports
          path: |
            test_report.txt
            memory_leak.log
```

### Docker Health Check

```dockerfile
FROM ubuntu:22.04

COPY tools/ /opt/tools/
RUN cd /opt/tools && ./BUILD_ALL.sh

HEALTHCHECK --interval=30s --timeout=10s \
  CMD /opt/tools/memleak 1 0 || exit 1
```

### Kubernetes CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: disk-benchmark
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: benchmark
            image: prodtools:latest
            command: ["/opt/tools/writebench", "1000"]
          restartPolicy: OnFailure
```

---

## 📊 Typical Production Workflow

### 1. Initial Deployment
```bash
# Extract and build
./deploy_tools.sh

# Verify installation
/opt/tools/BUILD_ALL.sh
```

### 2. Daily Monitoring
```bash
# GPU monitoring (if applicable)
nohup /opt/tools/gpu_monitor.sh 60 > /dev/null 2>&1 &

# Memory leak watch on critical process
nohup /opt/tools/memleak $(pidof myapp) 300 > /dev/null 2>&1 &
```

### 3. Pre-Deployment Testing
```bash
# Run test suite
/opt/tools/test_runner.sh -d /app/tests

# Benchmark new code
/opt/tools/perfprof --test

# Verify disk performance
/opt/tools/writebench
```

### 4. Code Deployment
```bash
# Deploy new version
/opt/tools/code_deployer.sh deploy app_v2.0.tar.gz production_app

# If issues arise, rollback
/opt/tools/code_deployer.sh rollback production_app
```

---

## 🎓 Advanced Usage

### Automated Memory Leak Detection

```bash
#!/bin/bash
# watch_for_leaks.sh
APP_NAME="myapp"
THRESHOLD_MB=500

while true; do
    PID=$(pidof $APP_NAME)
    if [ -n "$PID" ]; then
        RSS=$(ps -o rss= -p $PID)
        RSS_MB=$((RSS / 1024))
        
        if [ $RSS_MB -gt $THRESHOLD_MB ]; then
            echo "ALERT: $APP_NAME memory exceeded ${THRESHOLD_MB}MB"
            # Restart app
            systemctl restart $APP_NAME
        fi
    fi
    sleep 60
done
```

### Performance Regression Detection

```bash
#!/bin/bash
# regression_check.sh

# Baseline
./writebench 100 > baseline.txt
BASELINE_MBPS=$(grep "Throughput:" baseline.txt | awk '{print $2}')

# Current
./writebench 100 > current.txt
CURRENT_MBPS=$(grep "Throughput:" current.txt | awk '{print $2}')

# Compare
REGRESSION=$(echo "scale=2; ($BASELINE_MBPS - $CURRENT_MBPS) / $BASELINE_MBPS * 100" | bc)

if (( $(echo "$REGRESSION > 10" | bc -l) )); then
    echo "⚠️ Performance regression detected: -${REGRESSION}%"
    exit 1
fi
```

---

## 🐛 Troubleshooting

### Tool won't compile
```bash
# Install build tools
sudo apt install build-essential  # Ubuntu/Debian
sudo yum groupinstall "Development Tools"  # RHEL/CentOS

# Check compiler versions
gcc --version  # Need GCC 9+
g++ --version  # Need G++ 9+ with C++17
```

### GPU monitor shows "No GPU found"
```bash
# Install GPU tools
sudo apt install nvidia-utils  # NVIDIA
sudo apt install rocm-smi  # AMD

# Verify GPU detection
lspci | grep VGA
```

### Memory leak detector permission denied
```bash
# Some /proc files need root
sudo ./memleak <pid>

# Or add capability
sudo setcap cap_sys_ptrace=eip ./memleak
```

---

## 📝 License

MIT License - Free for production use

---

## 🚀 Next Steps

1. Build tools: `./BUILD_ALL.sh`
2. Test individual tools
3. Integrate into your CI/CD pipeline
4. Set up monitoring cron jobs
5. Create deployment packages

**Production-Ready Testing Suite v1.0** ✓
