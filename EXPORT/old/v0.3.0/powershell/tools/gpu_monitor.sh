#!/usr/bin/env bash
# GPU Usage Monitor
# Tracks GPU utilization, temperature, and memory for production systems

set -euo pipefail

LOG_FILE="gpu_monitor.log"
INTERVAL=5

print_header() {
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║  GPU Monitor - Production Tracking                ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
}

check_nvidia() {
    if command -v nvidia-smi &> /dev/null; then
        echo "NVIDIA GPU detected"
        return 0
    fi
    return 1
}

check_amd() {
    if command -v rocm-smi &> /dev/null; then
        echo "AMD GPU detected"
        return 0
    fi
    return 1
}

check_intel() {
    if command -v intel_gpu_top &> /dev/null; then
        echo "Intel GPU detected"
        return 0
    fi
    return 1
}

monitor_nvidia() {
    echo "Timestamp,GPU_ID,Utilization_%,Memory_Used_MB,Memory_Total_MB,Temp_C,Power_W" > "$LOG_FILE"
    
    echo "Monitoring NVIDIA GPU (Ctrl+C to stop)..."
    echo ""
    
    while true; do
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Get GPU stats
        nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw \
                   --format=csv,noheader,nounits 2>/dev/null | while IFS=',' read -r gpu_id util mem_used mem_total temp power; do
            
            # Trim whitespace
            gpu_id=$(echo "$gpu_id" | xargs)
            util=$(echo "$util" | xargs)
            mem_used=$(echo "$mem_used" | xargs)
            mem_total=$(echo "$mem_total" | xargs)
            temp=$(echo "$temp" | xargs)
            power=$(echo "$power" | xargs)
            
            # Log to file
            echo "$timestamp,$gpu_id,$util,$mem_used,$mem_total,$temp,$power" >> "$LOG_FILE"
            
            # Print to console
            printf "[%s] GPU %s: %3s%% util | %5s/%5s MB mem | %3s°C | %6s W\n" \
                   "$timestamp" "$gpu_id" "$util" "$mem_used" "$mem_total" "$temp" "$power"
            
            # Alert on high usage
            if (( $(echo "$util > 90" | bc -l 2>/dev/null || echo 0) )); then
                echo "  ⚠️  WARNING: GPU $gpu_id running at ${util}% utilization"
            fi
            
            if (( $(echo "$temp > 80" | bc -l 2>/dev/null || echo 0) )); then
                echo "  🔥 WARNING: GPU $gpu_id temperature at ${temp}°C"
            fi
        done
        
        sleep "$INTERVAL"
    done
}

monitor_amd() {
    echo "Monitoring AMD GPU (Ctrl+C to stop)..."
    echo ""
    
    while true; do
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        rocm-smi --showuse --showtemp --showmeminfo vram 2>/dev/null | grep -E "GPU|Temperature|Memory" | \
        while read -r line; do
            echo "[$timestamp] $line"
        done
        
        sleep "$INTERVAL"
    done
}

monitor_intel() {
    echo "Monitoring Intel GPU (requires root)..."
    echo ""
    
    sudo intel_gpu_top -l 2>/dev/null | while read -r line; do
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] $line"
    done
}

monitor_generic() {
    echo "No GPU monitoring tool found. Checking /sys..."
    echo ""
    
    # Try to find GPU info in /sys
    if [ -d "/sys/class/drm" ]; then
        while true; do
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "[$timestamp] GPU devices in /sys/class/drm:"
            ls -1 /sys/class/drm | grep card
            sleep "$INTERVAL"
        done
    else
        echo "No GPU information available"
        exit 1
    fi
}

main() {
    print_header
    
    if [ $# -gt 0 ]; then
        INTERVAL=$1
    fi
    
    echo "Interval: ${INTERVAL}s"
    echo "Log file: $LOG_FILE"
    echo ""
    
    if check_nvidia; then
        monitor_nvidia
    elif check_amd; then
        monitor_amd
    elif check_intel; then
        monitor_intel
    else
        echo "No GPU monitoring tool found. Install nvidia-smi, rocm-smi, or intel_gpu_top"
        monitor_generic
    fi
}

# Trap Ctrl+C
trap 'echo ""; echo "✓ Monitoring stopped. Log saved to $LOG_FILE"; exit 0' INT

main "$@"
