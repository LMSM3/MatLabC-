// Package Manager Core - Like dnf, but for MatLabC++
// include/matlabcpp/package_manager.hpp

#pragma once

#include <string>
#include <vector>
#include <unordered_map>
#include <unordered_set>
#include <optional>
#include <functional>
#include <filesystem>

namespace matlabcpp {
namespace pkg {

namespace fs = std::filesystem;

// ========== PACKAGE METADATA ==========

struct Manifest {
    std::string name;
    std::string version;
    std::string arch;
    std::string description;
    std::string category;
    std::string license;
    
    std::vector<std::string> requires;
    std::vector<std::string> optional_requires;
    std::vector<std::string> provides;
    
    struct Backend {
        std::vector<std::string> available;
        std::string default_backend;
        std::unordered_map<std::string, int> priority;
    } backends;
    
    struct Files {
        std::vector<std::string> include;
        std::vector<std::string> lib;
        std::vector<std::string> demos;
        std::vector<std::string> docs;
        std::vector<std::string> kernels;
    } files;
    
    size_t size;
    std::string checksum;
    std::string url;
    
    // Parse from JSON
    static Manifest from_json(const std::string& json_path);
    std::string to_json() const;
};

// ========== PACKAGE DATABASE ==========

class PackageDatabase {
    fs::path db_path_;  // ~/.matlabcpp/index.json
    std::unordered_map<std::string, Manifest> installed_;
    
public:
    explicit PackageDatabase(fs::path db_path);
    
    // Query
    bool is_installed(const std::string& name) const;
    std::optional<Manifest> get(const std::string& name) const;
    std::vector<Manifest> list_all() const;
    std::vector<Manifest> search(const std::string& query) const;
    
    // Modify
    void register_package(const Manifest& manifest);
    void unregister_package(const std::string& name);
    
    // Persistence
    void load();
    void save();
};

// ========== REPOSITORY ==========

class Repository {
    std::string url_;
    fs::path cache_dir_;
    std::unordered_map<std::string, Manifest> available_;
    
public:
    Repository(std::string url, fs::path cache_dir);
    
    // Fetch repository index
    void update();
    
    // Query
    std::optional<Manifest> find(const std::string& name) const;
    std::vector<Manifest> search(const std::string& query) const;
    std::vector<Manifest> list_all() const;
    
    // Download
    fs::path download(const std::string& name, const std::string& version);
    bool verify_checksum(const fs::path& file, const std::string& expected);
};

// ========== DEPENDENCY RESOLVER ==========

struct DependencyError {
    std::string message;
    std::vector<std::string> missing;
    std::vector<std::string> conflicts;
};

class DependencyResolver {
    PackageDatabase& db_;
    Repository& repo_;
    
public:
    DependencyResolver(PackageDatabase& db, Repository& repo);
    
    // Resolve dependencies (topological sort)
    struct Resolution {
        std::vector<std::string> install_order;
        bool success;
        std::optional<DependencyError> error;
    };
    
    Resolution resolve(const std::string& package_name);
    Resolution resolve_multiple(const std::vector<std::string>& packages);

private:
    bool build_dep_graph_recursive(const std::string& pkg,
                                   std::unordered_map<std::string, std::vector<std::string>>& graph,
                                   std::unordered_set<std::string>& visited,
                                   std::unordered_set<std::string>& visiting,
                                   std::vector<std::string>& missing);

    void topological_sort(const std::string& pkg,
                         const std::unordered_map<std::string, std::vector<std::string>>& graph,
                         std::unordered_set<std::string>& visited,
                         std::vector<std::string>& order);
};

// ========== PACKAGE INSTALLER ==========

class PackageInstaller {
    fs::path install_root_;  // ~/.matlabcpp/modules/
    PackageDatabase& db_;
    
public:
    PackageInstaller(fs::path install_root, PackageDatabase& db);
    
    struct InstallResult {
        bool success;
        std::string message;
        fs::path install_path;
    };
    
    // Install from archive
    InstallResult install(const fs::path& archive, const Manifest& manifest);
    
    // Uninstall
    bool uninstall(const std::string& name);
    
private:
    void extract_archive(const fs::path& archive, const fs::path& dest);
    void run_post_install(const Manifest& manifest);
};

// ========== CAPABILITY REGISTRY ==========

// This is the key to making it NOT noob: capability-based resolution

class CapabilityRegistry {
    std::unordered_map<std::string, std::string> capabilities_;  // capability -> module
    
public:
    // Register capabilities from installed modules
    void register_module(const Manifest& manifest);
    void unregister_module(const std::string& module_name);
    
    // Resolve capability to module
    std::optional<std::string> resolve(const std::string& capability) const;
    
    // List all capabilities
    std::vector<std::string> list_capabilities() const;
};

// ========== BACKEND SELECTOR ==========

class BackendSelector {
public:
    enum class Backend {
        CPU,
        GPU,
        CUDA,
        OPENCL,
        FFTW,
        MATLAB
    };
    
    // Detect available backends
    static std::vector<Backend> detect_available();
    
    // Select best backend for capability
    static Backend select(const Manifest::Backend& backend_info);
    
    // Check if backend is available
    static bool is_available(Backend backend);
};

// ========== PACKAGE MANAGER (Main Interface) ==========

class PackageManager {
    fs::path root_;  // ~/.matlabcpp/
    PackageDatabase db_;
    Repository repo_;
    DependencyResolver resolver_;
    PackageInstaller installer_;
    CapabilityRegistry registry_;
    
public:
    explicit PackageManager(fs::path root = fs::path(std::getenv("HOME")) / ".matlabcpp");
    
    // ========== USER-FACING API ==========
    
    // Search
    struct SearchResult {
        std::string name;
        std::string description;
        std::string version;
        size_t size;
        bool installed;
    };
    std::vector<SearchResult> search(const std::string& query);
    
    // Info
    struct PackageInfo {
        Manifest manifest;
        bool installed;
        fs::path install_path;
        std::vector<std::string> dependencies;
        std::vector<std::string> provides;
    };
    std::optional<PackageInfo> info(const std::string& name);
    
    // Install
    struct InstallOptions {
        bool force = false;
        bool no_deps = false;
        bool local_file = false;
    };
    bool install(const std::string& name);
    bool install(const std::string& name, const InstallOptions& opts);
    bool install_file(const fs::path& archive);
    
    // Remove
    bool remove(const std::string& name, bool force = false);
    
    // List
    std::vector<PackageInfo> list_installed();
    std::vector<PackageInfo> list_available();
    
    // Update
    bool update();  // Update repository index
    bool upgrade(const std::string& name);  // Upgrade single package
    bool upgrade_all();  // Upgrade all packages
    
    // Capability resolution
    std::optional<std::string> resolve_capability(const std::string& capability);
};

// ========== CLI HELPER FUNCTIONS ==========

namespace cli {

// Progress bar
class ProgressBar {
    size_t total_;
    size_t current_;
    std::string prefix_;
    
public:
    ProgressBar(size_t total, std::string prefix);
    void update(size_t current);
    void finish();
};

// Colored output
void print_success(const std::string& msg);
void print_error(const std::string& msg);
void print_warning(const std::string& msg);
void print_info(const std::string& msg);

// Table printing
void print_table(const std::vector<std::string>& headers,
                 const std::vector<std::vector<std::string>>& rows);

} // namespace cli

} // namespace pkg
} // namespace matlabcpp
