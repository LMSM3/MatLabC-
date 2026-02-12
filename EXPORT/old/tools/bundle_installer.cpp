// bundle_installer.cpp
// C++ installer for MatLabC++ examples
// Intent: Fast, portable, self-contained installation
// Replaces bash dependency with compiled binary

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdlib>
#include <cstring>
#include <sys/stat.h>
#include <sys/types.h>

#ifdef _WIN32
#include <windows.h>
#include <direct.h>
#define mkdir(path, mode) _mkdir(path)
#else
#include <unistd.h>
#include <sys/sysinfo.h>
#endif

// ========== ANSI COLORS ==========
#define BOLD    "\033[1m"
#define DIM     "\033[2m"
#define GREEN   "\033[32m"
#define RED     "\033[31m"
#define YELLOW  "\033[33m"
#define CYAN    "\033[36m"
#define NC      "\033[0m"

// ========== RAM MONITORING ==========
class RAMMonitor {
public:
    static size_t get_available_mb() {
#ifdef _WIN32
        MEMORYSTATUSEX mem_info;
        mem_info.dwLength = sizeof(MEMORYSTATUSEX);
        if (GlobalMemoryStatusEx(&mem_info)) {
            return static_cast<size_t>(mem_info.ullAvailPhys / (1024 * 1024));
        }
        return 0;
#elif __linux__
        struct sysinfo si;
        if (sysinfo(&si) == 0) {
            return (si.freeram * si.mem_unit) / (1024 * 1024);
        }
        return 0;
#elif __APPLE__
        // macOS: read from vm_stat
        FILE* fp = popen("vm_stat | awk '/Pages free/ {print $3}' | tr -d '.'", "r");
        if (fp) {
            char buf[64];
            if (fgets(buf, sizeof(buf), fp)) {
                size_t free_pages = std::stoull(buf);
                pclose(fp);
                return (free_pages * 4096) / (1024 * 1024);  // 4KB pages
            }
            pclose(fp);
        }
        return 0;
#else
        return 0;
#endif
    }
    
    static size_t get_total_mb() {
#ifdef _WIN32
        MEMORYSTATUSEX mem_info;
        mem_info.dwLength = sizeof(MEMORYSTATUSEX);
        if (GlobalMemoryStatusEx(&mem_info)) {
            return static_cast<size_t>(mem_info.ullTotalPhys / (1024 * 1024));
        }
        return 0;
#elif __linux__
        struct sysinfo si;
        if (sysinfo(&si) == 0) {
            return (si.totalram * si.mem_unit) / (1024 * 1024);
        }
        return 0;
#elif __APPLE__
        FILE* fp = popen("sysctl -n hw.memsize", "r");
        if (fp) {
            char buf[64];
            if (fgets(buf, sizeof(buf), fp)) {
                size_t total_bytes = std::stoull(buf);
                pclose(fp);
                return total_bytes / (1024 * 1024);
            }
            pclose(fp);
        }
        return 0;
#else
        return 0;
#endif
    }
    
    static void show_status() {
        size_t available = get_available_mb();
        size_t total = get_total_mb();
        
        if (total > 0) {
            size_t used = total - available;
            int percent = (used * 100) / total;
            std::cout << DIM << "[RAM] " << used << "MB/" << total 
                      << "MB used (" << percent << "%)" << NC << std::endl;
        }
    }
    
    static bool check_available(size_t required_mb) {
        size_t available = get_available_mb();
        if (available < required_mb) {
            std::cerr << RED << "Insufficient RAM: need " << required_mb 
                      << "MB, have " << available << "MB" << NC << std::endl;
            return false;
        }
        std::cout << GREEN << "✓" << NC << " " << required_mb 
                  << "MB buffer available" << std::endl;
        return true;
    }
};

// ========== FILE OPERATIONS ==========
class FileOps {
public:
    static bool directory_exists(const std::string& path) {
        struct stat info;
        if (stat(path.c_str(), &info) != 0) {
            return false;
        }
        return (info.st_mode & S_IFDIR) != 0;
    }
    
    static bool create_directory(const std::string& path) {
        return mkdir(path.c_str(), 0755) == 0 || directory_exists(path);
    }
    
    static bool file_exists(const std::string& path) {
        struct stat info;
        return stat(path.c_str(), &info) == 0;
    }
    
    static size_t get_file_size(const std::string& path) {
        struct stat info;
        if (stat(path.c_str(), &info) == 0) {
            return info.st_size;
        }
        return 0;
    }
};

// ========== INSTALLER ==========
class BundleInstaller {
private:
    std::string install_dir;
    std::string examples_dir;
    size_t file_count;
    
    void show_banner() {
        std::cout << BOLD << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" << NC << std::endl;
        std::cout << BOLD << "MatLabC++ Examples Installer" << NC << std::endl;
        std::cout << DIM << "C++ Native Installer v0.3.0" << NC << std::endl;
        std::cout << BOLD << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" << NC << std::endl;
        std::cout << std::endl;
        RAMMonitor::show_status();
        std::cout << std::endl;
    }
    
    bool check_prerequisites() {
        std::cout << BOLD << "Step 1: Prerequisites" << NC << std::endl;
        
        // Check RAM
        if (!RAMMonitor::check_available(64)) {
            return false;
        }
        
        // Check for tar and base64
        bool has_tar = (system("which tar >/dev/null 2>&1") == 0);
        bool has_base64 = (system("which base64 >/dev/null 2>&1") == 0);
        
        if (!has_tar) {
            std::cerr << RED << "✗" << NC << " tar not found" << std::endl;
            return false;
        }
        std::cout << GREEN << "✓" << NC << " tar available" << std::endl;
        
        if (!has_base64) {
            std::cerr << RED << "✗" << NC << " base64 not found" << std::endl;
            return false;
        }
        std::cout << GREEN << "✓" << NC << " base64 available" << std::endl;
        
        std::cout << std::endl;
        return true;
    }
    
    bool create_directories() {
        std::cout << BOLD << "Step 2: Create Directories" << NC << std::endl;
        
        // Create install directory if needed
        if (!FileOps::directory_exists(install_dir)) {
            if (!FileOps::create_directory(install_dir)) {
                std::cerr << RED << "✗" << NC << " Failed to create: " 
                          << install_dir << std::endl;
                return false;
            }
        }
        std::cout << GREEN << "✓" << NC << " Install dir: " << install_dir << std::endl;
        
        // Create examples directory
        examples_dir = install_dir + "/examples";
        if (!FileOps::directory_exists(examples_dir)) {
            if (!FileOps::create_directory(examples_dir)) {
                std::cerr << RED << "✗" << NC << " Failed to create: " 
                          << examples_dir << std::endl;
                return false;
            }
        }
        std::cout << GREEN << "✓" << NC << " Examples dir: " << examples_dir << std::endl;
        
        std::cout << std::endl;
        return true;
    }
    
    bool extract_payload(const std::string& bundle_path) {
        std::cout << BOLD << "Step 3: Extract Payload" << NC << std::endl;
        
        // Extract payload from bundle script
        // Format: Everything after __PAYLOAD_BELOW__ is base64-encoded tar.gz
        
        std::ifstream bundle(bundle_path);
        if (!bundle.is_open()) {
            std::cerr << RED << "✗" << NC << " Cannot open bundle: " 
                      << bundle_path << std::endl;
            return false;
        }
        
        // Find payload marker
        std::string line;
        bool found_marker = false;
        while (std::getline(bundle, line)) {
            if (line == "__PAYLOAD_BELOW__") {
                found_marker = true;
                break;
            }
        }
        
        if (!found_marker) {
            std::cerr << RED << "✗" << NC << " Payload marker not found" << std::endl;
            return false;
        }
        std::cout << GREEN << "✓" << NC << " Payload marker found" << std::endl;
        
        // Create temp file for base64 payload
        std::string temp_b64 = "/tmp/matlabcpp_payload.b64";
        std::string temp_tar = "/tmp/matlabcpp_payload.tar.gz";
        
        std::ofstream temp(temp_b64);
        while (std::getline(bundle, line)) {
            temp << line << std::endl;
        }
        temp.close();
        bundle.close();
        
        // Decode base64
        std::string decode_cmd = "base64 -d " + temp_b64 + " > " + temp_tar;
        if (system(decode_cmd.c_str()) != 0) {
            std::cerr << RED << "✗" << NC << " Base64 decode failed" << std::endl;
            return false;
        }
        std::cout << GREEN << "✓" << NC << " Payload decoded" << std::endl;
        
        // Extract tar.gz
        std::string extract_cmd = "tar -xzf " + temp_tar + " -C " + examples_dir;
        if (system(extract_cmd.c_str()) != 0) {
            std::cerr << RED << "✗" << NC << " Extraction failed" << std::endl;
            return false;
        }
        std::cout << GREEN << "✓" << NC << " Files extracted" << std::endl;
        
        // Cleanup temp files
        std::remove(temp_b64.c_str());
        std::remove(temp_tar.c_str());
        
        std::cout << std::endl;
        return true;
    }
    
    bool verify_installation() {
        std::cout << BOLD << "Step 4: Verify Installation" << NC << std::endl;
        
        // Count installed .m files
        std::string count_cmd = "find " + examples_dir + " -name '*.m' -type f | wc -l";
        FILE* fp = popen(count_cmd.c_str(), "r");
        if (!fp) {
            std::cerr << RED << "✗" << NC << " Verification failed" << std::endl;
            return false;
        }
        
        char buf[64];
        if (fgets(buf, sizeof(buf), fp)) {
            file_count = std::stoul(buf);
        }
        pclose(fp);
        
        if (file_count == 0) {
            std::cerr << RED << "✗" << NC << " No files extracted" << std::endl;
            return false;
        }
        
        std::cout << GREEN << "✓" << NC << " " << file_count 
                  << " example files installed" << std::endl;
        std::cout << std::endl;
        
        return true;
    }
    
    void show_success() {
        std::cout << BOLD << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" << NC << std::endl;
        std::cout << GREEN << BOLD << "Installation complete" << NC << std::endl;
        std::cout << BOLD << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" << NC << std::endl;
        std::cout << std::endl;
        
        std::cout << BOLD << "Installed:" << NC << std::endl;
        std::cout << "  Location: " << YELLOW << examples_dir << NC << std::endl;
        std::cout << "  Files:    " << file_count << " examples" << std::endl;
        std::cout << std::endl;
        
        std::cout << BOLD << "Quick Start:" << NC << std::endl;
        std::cout << "  " << CYAN << "cd " << examples_dir << NC << std::endl;
        std::cout << "  " << CYAN << "mlab++ basic_demo.m" << NC << std::endl;
        std::cout << "  " << CYAN << "mlab++ test_math_accuracy.m" << NC << std::endl;
        std::cout << std::endl;
    }
    
public:
    BundleInstaller(const std::string& dir) 
        : install_dir(dir), file_count(0) {}
    
    bool install(const std::string& bundle_path) {
        show_banner();
        
        if (!check_prerequisites()) return false;
        if (!create_directories()) return false;
        if (!extract_payload(bundle_path)) return false;
        if (!verify_installation()) return false;
        
        show_success();
        return true;
    }
};

// ========== MAIN ==========
int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <bundle.sh> [install_dir]" << std::endl;
        std::cerr << std::endl;
        std::cerr << "Example:" << std::endl;
        std::cerr << "  " << argv[0] << " mlabpp_examples_bundle.sh" << std::endl;
        std::cerr << "  " << argv[0] << " mlabpp_examples_bundle.sh /opt/matlabcpp" << std::endl;
        return 1;
    }
    
    std::string bundle_path = argv[1];
    std::string install_dir = (argc >= 3) ? argv[2] : ".";
    
    // Check bundle exists
    if (!FileOps::file_exists(bundle_path)) {
        std::cerr << RED << "Error: Bundle not found: " << bundle_path << NC << std::endl;
        return 1;
    }
    
    // Run installer
    BundleInstaller installer(install_dir);
    
    try {
        if (!installer.install(bundle_path)) {
            std::cerr << RED << "Installation failed" << NC << std::endl;
            return 1;
        }
    } catch (const std::exception& e) {
        std::cerr << RED << "Exception: " << e.what() << NC << std::endl;
        return 1;
    }
    
    return 0;
}
