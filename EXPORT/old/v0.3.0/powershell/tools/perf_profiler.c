/*
 * Performance Profiler
 * Lightweight CPU and memory profiler for production code
 * Compile: gcc -O2 -o perfprof perf_profiler.c -lpthread
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>

#define MAX_CHECKPOINTS 100

typedef struct {
    char name[64];
    struct timeval start;
    struct timeval end;
    double elapsed_ms;
    size_t memory_kb;
} Checkpoint;

typedef struct {
    Checkpoint checkpoints[MAX_CHECKPOINTS];
    int count;
    struct timeval program_start;
} Profiler;

static Profiler global_profiler = {0};

void profiler_init() {
    memset(&global_profiler, 0, sizeof(Profiler));
    gettimeofday(&global_profiler.program_start, NULL);
    printf("╔═══════════════════════════════════════════════════╗\n");
    printf("║  Performance Profiler - Started                  ║\n");
    printf("╚═══════════════════════════════════════════════════╝\n\n");
}

size_t get_memory_usage_kb() {
    struct rusage usage;
    getrusage(RUSAGE_SELF, &usage);
    return usage.ru_maxrss;
}

void profiler_start(const char* name) {
    if (global_profiler.count >= MAX_CHECKPOINTS) {
        fprintf(stderr, "Warning: Max checkpoints reached\n");
        return;
    }
    
    Checkpoint* cp = &global_profiler.checkpoints[global_profiler.count];
    strncpy(cp->name, name, sizeof(cp->name) - 1);
    gettimeofday(&cp->start, NULL);
    cp->memory_kb = get_memory_usage_kb();
    
    global_profiler.count++;
}

void profiler_end(const char* name) {
    struct timeval end_time;
    gettimeofday(&end_time, NULL);
    
    // Find matching checkpoint
    for (int i = global_profiler.count - 1; i >= 0; i--) {
        Checkpoint* cp = &global_profiler.checkpoints[i];
        
        if (strcmp(cp->name, name) == 0 && cp->elapsed_ms == 0) {
            cp->end = end_time;
            
            // Calculate elapsed time in milliseconds
            double start_ms = cp->start.tv_sec * 1000.0 + cp->start.tv_usec / 1000.0;
            double end_ms = end_time.tv_sec * 1000.0 + end_time.tv_usec / 1000.0;
            cp->elapsed_ms = end_ms - start_ms;
            
            // Update memory
            cp->memory_kb = get_memory_usage_kb();
            
            return;
        }
    }
    
    fprintf(stderr, "Warning: No matching start for '%s'\n", name);
}

void profiler_report() {
    printf("\n╔═══════════════════════════════════════════════════╗\n");
    printf("║  Performance Profiling Report                     ║\n");
    printf("╚═══════════════════════════════════════════════════╝\n\n");
    
    printf("%-30s %12s %12s\n", "Checkpoint", "Time (ms)", "Memory (KB)");
    printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    
    double total_time = 0;
    
    for (int i = 0; i < global_profiler.count; i++) {
        Checkpoint* cp = &global_profiler.checkpoints[i];
        
        if (cp->elapsed_ms > 0) {
            printf("%-30s %12.3f %12zu\n", 
                   cp->name, cp->elapsed_ms, cp->memory_kb);
            total_time += cp->elapsed_ms;
        }
    }
    
    printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    printf("%-30s %12.3f\n", "Total Profiled Time:", total_time);
    
    // Calculate total program time
    struct timeval now;
    gettimeofday(&now, NULL);
    double start_ms = global_profiler.program_start.tv_sec * 1000.0 + 
                      global_profiler.program_start.tv_usec / 1000.0;
    double end_ms = now.tv_sec * 1000.0 + now.tv_usec / 1000.0;
    double program_time = end_ms - start_ms;
    
    printf("%-30s %12.3f\n", "Total Program Time:", program_time);
    printf("%-30s %12.1f%%\n", "Profiled Coverage:", 
           (program_time > 0 ? 100.0 * total_time / program_time : 0));
    
    // Performance summary
    printf("\nPerformance Summary:\n");
    if (total_time < 100) {
        printf("  ✓ Fast execution (< 100ms)\n");
    } else if (total_time < 1000) {
        printf("  ✓ Normal execution (< 1s)\n");
    } else {
        printf("  ⚠ Slow execution (> 1s) - consider optimization\n");
    }
    
    size_t peak_memory = 0;
    for (int i = 0; i < global_profiler.count; i++) {
        if (global_profiler.checkpoints[i].memory_kb > peak_memory) {
            peak_memory = global_profiler.checkpoints[i].memory_kb;
        }
    }
    
    printf("  Peak memory: %.2f MB\n", peak_memory / 1024.0);
    
    if (peak_memory < 10 * 1024) {
        printf("  ✓ Low memory usage (< 10 MB)\n");
    } else if (peak_memory < 100 * 1024) {
        printf("  ✓ Normal memory usage (< 100 MB)\n");
    } else {
        printf("  ⚠ High memory usage (> 100 MB)\n");
    }
}

// Example usage with test workload
void simulate_work(int ms) {
    struct timespec ts;
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000;
    nanosleep(&ts, NULL);
}

void example_workload() {
    profiler_start("Initialization");
    simulate_work(10);
    profiler_end("Initialization");
    
    profiler_start("Data Processing");
    
    // Allocate some memory
    char* buffer = malloc(1024 * 1024); // 1 MB
    memset(buffer, 0, 1024 * 1024);
    
    simulate_work(50);
    
    free(buffer);
    profiler_end("Data Processing");
    
    profiler_start("File I/O");
    FILE* fp = fopen("test_profile.tmp", "w");
    if (fp) {
        for (int i = 0; i < 1000; i++) {
            fprintf(fp, "Line %d\n", i);
        }
        fclose(fp);
    }
    profiler_end("File I/O");
    
    profiler_start("Cleanup");
    remove("test_profile.tmp");
    simulate_work(5);
    profiler_end("Cleanup");
}

int main(int argc, char* argv[]) {
    profiler_init();
    
    if (argc > 1 && strcmp(argv[1], "--test") == 0) {
        printf("Running test workload...\n\n");
        example_workload();
    } else {
        printf("Profiler ready. Instrument your code with:\n");
        printf("  profiler_start(\"section_name\");\n");
        printf("  // ... your code ...\n");
        printf("  profiler_end(\"section_name\");\n");
        printf("\nRun with --test to see example output\n");
        return 0;
    }
    
    profiler_report();
    
    return 0;
}
