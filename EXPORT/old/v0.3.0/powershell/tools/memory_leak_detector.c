/*
 * Memory Leak Detector
 * Tracks allocations and detections in production code
 * Compile: gcc -O2 -o memleak memory_leak_detector.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>

#ifdef __linux__
#include <sys/resource.h>
#endif

typedef struct {
    pid_t pid;
    size_t rss_kb;
    size_t vms_kb;
    double cpu_percent;
    char name[256];
} ProcessStats;

int read_process_stats(pid_t pid, ProcessStats* stats) {
#ifdef __linux__
    char path[256];
    FILE* fp;
    
    // Read /proc/[pid]/status
    snprintf(path, sizeof(path), "/proc/%d/status", pid);
    fp = fopen(path, "r");
    if (!fp) return -1;
    
    stats->pid = pid;
    stats->rss_kb = 0;
    stats->vms_kb = 0;
    
    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        if (strncmp(line, "Name:", 5) == 0) {
            sscanf(line + 5, "%s", stats->name);
        } else if (strncmp(line, "VmRSS:", 6) == 0) {
            sscanf(line + 6, "%zu", &stats->rss_kb);
        } else if (strncmp(line, "VmSize:", 7) == 0) {
            sscanf(line + 7, "%zu", &stats->vms_kb);
        }
    }
    fclose(fp);
    return 0;
#else
    return -1; // Not implemented for non-Linux
#endif
}

void print_stats(ProcessStats* stats) {
    printf("\n╔═══════════════════════════════════════════════════╗\n");
    printf("║  Memory Leak Detector - Process Monitor          ║\n");
    printf("╚═══════════════════════════════════════════════════╝\n\n");
    
    printf("Process: %s (PID: %d)\n", stats->name, stats->pid);
    printf("RSS:     %.2f MB\n", stats->rss_kb / 1024.0);
    printf("VMS:     %.2f MB\n", stats->vms_kb / 1024.0);
    
    // Calculate leak indicator (simple heuristic)
    if (stats->vms_kb > stats->rss_kb * 2) {
        printf("⚠️  WARNING: High virtual memory usage (possible leak)\n");
    } else {
        printf("✓ Memory usage looks normal\n");
    }
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Usage: %s <pid> [interval_seconds]\n", argv[0]);
        printf("\nMonitor memory usage of a process to detect leaks\n");
        printf("Example: %s 1234 5  # Monitor PID 1234 every 5 seconds\n", argv[0]);
        return 1;
    }
    
    pid_t pid = atoi(argv[1]);
    int interval = (argc > 2) ? atoi(argv[2]) : 0;
    
    ProcessStats current, previous;
    memset(&previous, 0, sizeof(ProcessStats));
    
    if (read_process_stats(pid, &current) != 0) {
        fprintf(stderr, "Error: Cannot read stats for PID %d\n", pid);
        return 1;
    }
    
    print_stats(&current);
    
    if (interval > 0) {
        printf("\nMonitoring every %d seconds (Ctrl+C to stop)...\n\n", interval);
        
        FILE* logfile = fopen("memory_leak.log", "w");
        fprintf(logfile, "Timestamp,RSS_MB,VMS_MB,RSS_Delta_MB,VMS_Delta_MB\n");
        
        previous = current;
        int samples = 0;
        
        while (1) {
            sleep(interval);
            
            if (read_process_stats(pid, &current) != 0) {
                fprintf(stderr, "Process %d no longer exists\n", pid);
                break;
            }
            
            double rss_mb = current.rss_kb / 1024.0;
            double vms_mb = current.vms_kb / 1024.0;
            double rss_delta = (current.rss_kb - previous.rss_kb) / 1024.0;
            double vms_delta = (current.vms_kb - previous.vms_kb) / 1024.0;
            
            time_t now = time(NULL);
            char timestamp[64];
            strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", localtime(&now));
            
            printf("[%s] RSS: %.2f MB (%+.2f MB)  VMS: %.2f MB (%+.2f MB)\n",
                   timestamp, rss_mb, rss_delta, vms_mb, vms_delta);
            
            fprintf(logfile, "%s,%.2f,%.2f,%.2f,%.2f\n",
                    timestamp, rss_mb, vms_mb, rss_delta, vms_delta);
            fflush(logfile);
            
            // Leak detection heuristics
            if (rss_delta > 10.0 && samples > 3) {
                printf("⚠️  ALERT: RSS increased by %.2f MB - possible memory leak!\n", rss_delta);
            }
            
            previous = current;
            samples++;
        }
        
        fclose(logfile);
        printf("\n✓ Log saved to memory_leak.log\n");
    }
    
    return 0;
}
