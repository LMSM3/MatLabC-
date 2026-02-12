#pragma once
#include <string>
#include <iostream>
#include <chrono>
#include <cstring>

#ifdef _WIN32
#include <windows.h>
#include <intrin.h>
#else
#include <unistd.h>
#include <cpuid.h>
#endif

namespace matlabcpp::system {

struct CPUInfo {
    std::string vendor;
    int logical_cores;
    bool has_avx2 = false;
};

inline CPUInfo detect_cpu() noexcept {
    CPUInfo cpu{};
    cpu.vendor = "Unknown";
    cpu.logical_cores = 4;
    return cpu;
}

inline void print_motd() {
    std::cout << "\n";
    std::cout << "==============================================================\n";
    std::cout << "           MatLabC++ v0.2.0 - Universal Script Engine          \n";
    std::cout << "      .m and .c files | High-Performance Computing            \n";
    std::cout << "==============================================================\n\n";
}

class Timer {
    std::chrono::high_resolution_clock::time_point start_;
public:
    Timer() : start_(std::chrono::high_resolution_clock::now()) {}
    
    [[nodiscard]] double elapsed_ms() const {
        auto end = std::chrono::high_resolution_clock::now();
        return std::chrono::duration<double, std::milli>(end - start_).count();
    }
};

} // namespace matlabcpp::system
