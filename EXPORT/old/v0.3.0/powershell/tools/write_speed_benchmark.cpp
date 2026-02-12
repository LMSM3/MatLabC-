/*
 * Write Speed Benchmark
 * Tests disk I/O performance for production validation
 * Compile: g++ -O2 -std=c++17 -o writebench write_speed_benchmark.cpp
 */

#include <iostream>
#include <fstream>
#include <chrono>
#include <vector>
#include <cstring>
#include <iomanip>
#include <random>

class WriteBenchmark {
private:
    std::string filename;
    size_t file_size_mb;
    size_t block_size_kb;
    
    std::vector<char> generate_block(size_t size) {
        std::vector<char> block(size);
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> dis(0, 255);
        
        for (size_t i = 0; i < size; i++) {
            block[i] = static_cast<char>(dis(gen));
        }
        return block;
    }
    
public:
    WriteBenchmark(const std::string& fname, size_t size_mb, size_t block_kb)
        : filename(fname), file_size_mb(size_mb), block_size_kb(block_kb) {}
    
    void run_sequential_write() {
        std::cout << "\n╔══════════════════════════════════════════════════╗\n";
        std::cout << "║  Sequential Write Benchmark                      ║\n";
        std::cout << "╚══════════════════════════════════════════════════╝\n\n";
        
        std::cout << "File:       " << filename << "\n";
        std::cout << "Size:       " << file_size_mb << " MB\n";
        std::cout << "Block size: " << block_size_kb << " KB\n";
        std::cout << "Writing...  ";
        std::cout.flush();
        
        size_t block_bytes = block_size_kb * 1024;
        size_t total_bytes = file_size_mb * 1024 * 1024;
        size_t num_blocks = total_bytes / block_bytes;
        
        auto block = generate_block(block_bytes);
        
        auto start = std::chrono::high_resolution_clock::now();
        
        std::ofstream file(filename, std::ios::binary);
        if (!file) {
            std::cerr << "Error: Cannot open file for writing\n";
            return;
        }
        
        for (size_t i = 0; i < num_blocks; i++) {
            file.write(block.data(), block_bytes);
            if (i % 100 == 0) {
                std::cout << "." << std::flush;
            }
        }
        
        file.close();
        
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        
        double seconds = duration.count() / 1000.0;
        double mb_per_sec = file_size_mb / seconds;
        
        std::cout << " Done!\n\n";
        std::cout << "Results:\n";
        std::cout << "  Time:       " << std::fixed << std::setprecision(2) << seconds << " s\n";
        std::cout << "  Throughput: " << std::fixed << std::setprecision(2) << mb_per_sec << " MB/s\n";
        
        if (mb_per_sec < 50) {
            std::cout << "  Status:     ⚠️  SLOW - check disk health\n";
        } else if (mb_per_sec < 200) {
            std::cout << "  Status:     ✓ Normal HDD speed\n";
        } else {
            std::cout << "  Status:     ✓ Good SSD speed\n";
        }
        
        // Cleanup
        std::remove(filename.c_str());
    }
    
    void run_random_write() {
        std::cout << "\n╔══════════════════════════════════════════════════╗\n";
        std::cout << "║  Random Write Benchmark (4KB blocks)             ║\n";
        std::cout << "╚══════════════════════════════════════════════════╝\n\n";
        
        const size_t small_block = 4096;
        const size_t num_ops = 10000;
        
        std::cout << "Operations: " << num_ops << " random 4KB writes\n";
        std::cout << "Testing...  ";
        std::cout.flush();
        
        auto block = generate_block(small_block);
        
        std::ofstream file(filename, std::ios::binary);
        if (!file) {
            std::cerr << "Error: Cannot open file for writing\n";
            return;
        }
        
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> dis(0, file_size_mb * 1024 - 4);
        
        auto start = std::chrono::high_resolution_clock::now();
        
        for (size_t i = 0; i < num_ops; i++) {
            size_t offset = dis(gen) * 1024;
            file.seekp(offset);
            file.write(block.data(), small_block);
            
            if (i % 1000 == 0) {
                std::cout << "." << std::flush;
            }
        }
        
        file.close();
        
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        
        double seconds = duration.count() / 1000.0;
        double iops = num_ops / seconds;
        
        std::cout << " Done!\n\n";
        std::cout << "Results:\n";
        std::cout << "  Time:  " << std::fixed << std::setprecision(2) << seconds << " s\n";
        std::cout << "  IOPS:  " << std::fixed << std::setprecision(0) << iops << " ops/s\n";
        
        if (iops < 100) {
            std::cout << "  Status: ⚠️  SLOW - typical HDD performance\n";
        } else if (iops < 1000) {
            std::cout << "  Status: ✓ Normal HDD with cache\n";
        } else if (iops < 10000) {
            std::cout << "  Status: ✓ Good SSD performance\n";
        } else {
            std::cout << "  Status: ✓ Excellent NVMe performance\n";
        }
        
        // Cleanup
        std::remove(filename.c_str());
    }
};

int main(int argc, char* argv[]) {
    size_t size_mb = (argc > 1) ? std::atoi(argv[1]) : 100;
    size_t block_kb = (argc > 2) ? std::atoi(argv[2]) : 64;
    
    std::cout << "\n╔════════════════════════════════════════════════════════╗\n";
    std::cout << "║  Disk Write Speed Benchmark - Production Testing      ║\n";
    std::cout << "╚════════════════════════════════════════════════════════╝\n";
    
    WriteBenchmark bench("test_write_bench.tmp", size_mb, block_kb);
    
    bench.run_sequential_write();
    bench.run_random_write();
    
    std::cout << "\n✓ Benchmark complete!\n\n";
    
    return 0;
}
