// MatLabC++ Package Manager CLI
// tools/mlab_pkg.cpp
//
// Usage:
//   mlab++ pkg search materials
//   mlab++ pkg install materials_smart
//   mlab++ pkg remove materials_smart
//   mlab++ pkg list
//   mlab++ pkg info materials_smart
//   mlab++ pkg update

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include "matlabcpp/package_manager.hpp"

using namespace matlabcpp::pkg;

// ========== COMMAND HANDLERS ==========

void cmd_search(PackageManager& pm, const std::vector<std::string>& args) {
    if (args.empty()) {
        std::cerr << "Error: search requires a query\n";
        std::cerr << "Usage: mlab++ pkg search <query>\n";
        return;
    }
    
    std::string query = args[0];
    auto results = pm.search(query);
    
    if (results.empty()) {
        std::cout << "No packages found matching '" << query << "'\n";
        return;
    }
    
    std::cout << "Found " << results.size() << " package(s):\n\n";
    
    // Print table
    std::vector<std::string> headers = {"Name", "Version", "Size", "Description", "Status"};
    std::vector<std::vector<std::string>> rows;
    
    for (const auto& pkg : results) {
        std::string size_str = std::to_string(pkg.size / 1024) + " KB";
        std::string status = pkg.installed ? "[Installed]" : "";
        rows.push_back({pkg.name, pkg.version, size_str, pkg.description, status});
    }
    
    cli::print_table(headers, rows);
}

void cmd_info(PackageManager& pm, const std::vector<std::string>& args) {
    if (args.empty()) {
        std::cerr << "Error: info requires a package name\n";
        std::cerr << "Usage: mlab++ pkg info <package>\n";
        return;
    }
    
    std::string name = args[0];
    auto info = pm.info(name);
    
    if (!info) {
        cli::print_error("Package not found: " + name);
        return;
    }
    
    const auto& m = info->manifest;
    
    std::cout << "Package: " << m.name << "\n";
    std::cout << "Version: " << m.version << "\n";
    std::cout << "Description: " << m.description << "\n";
    std::cout << "Category: " << m.category << "\n";
    std::cout << "License: " << m.license << "\n";
    std::cout << "Size: " << (m.size / 1024) << " KB\n";
    std::cout << "Status: " << (info->installed ? "Installed" : "Not installed") << "\n";
    
    if (info->installed) {
        std::cout << "Install path: " << info->install_path << "\n";
    }
    
    if (!m.requires.empty()) {
        std::cout << "\nRequires:\n";
        for (const auto& dep : m.requires) {
            std::cout << "  - " << dep << "\n";
        }
    }
    
    if (!m.provides.empty()) {
        std::cout << "\nProvides:\n";
        for (const auto& cap : m.provides) {
            std::cout << "  - " << cap << "\n";
        }
    }
    
    if (!m.backends.available.empty()) {
        std::cout << "\nBackends: ";
        for (size_t i = 0; i < m.backends.available.size(); ++i) {
            std::cout << m.backends.available[i];
            if (i < m.backends.available.size() - 1) std::cout << ", ";
        }
        std::cout << "\n";
    }
}

void cmd_install(PackageManager& pm, const std::vector<std::string>& args) {
    if (args.empty()) {
        std::cerr << "Error: install requires a package name\n";
        std::cerr << "Usage: mlab++ pkg install <package>\n";
        return;
    }
    
    std::string name = args[0];
    
    std::cout << "Resolving dependencies...\n";
    
    PackageManager::InstallOptions opts;
    bool success = pm.install(name, opts);
    
    if (success) {
        cli::print_success("Package installed: " + name);
        std::cout << "\nRun demos:\n";
        std::cout << "  cd ~/.matlabcpp/modules/" << name << "/*/demos/\n";
        std::cout << "  mlab++ <demo>.m --visual\n";
    } else {
        cli::print_error("Installation failed: " + name);
    }
}

void cmd_remove(PackageManager& pm, const std::vector<std::string>& args) {
    if (args.empty()) {
        std::cerr << "Error: remove requires a package name\n";
        std::cerr << "Usage: mlab++ pkg remove <package>\n";
        return;
    }
    
    std::string name = args[0];
    
    std::cout << "Removing: " << name << "\n";
    bool success = pm.remove(name);
    
    if (success) {
        cli::print_success("Package removed: " + name);
    } else {
        cli::print_error("Removal failed: " + name);
    }
}

void cmd_list(PackageManager& pm, const std::vector<std::string>& args) {
    auto packages = pm.list_installed();
    
    if (packages.empty()) {
        std::cout << "No packages installed\n";
        return;
    }
    
    std::cout << "Installed packages:\n\n";
    
    std::vector<std::string> headers = {"Name", "Version", "Size", "Provides"};
    std::vector<std::vector<std::string>> rows;
    
    for (const auto& pkg : packages) {
        const auto& m = pkg.manifest;
        std::string size_str = std::to_string(m.size / 1024) + " KB";
        std::string provides_str = std::to_string(m.provides.size()) + " capabilities";
        rows.push_back({m.name, m.version, size_str, provides_str});
    }
    
    cli::print_table(headers, rows);
}

void cmd_update(PackageManager& pm, const std::vector<std::string>& args) {
    std::cout << "Updating package repository...\n";
    
    bool success = pm.update();
    
    if (success) {
        cli::print_success("Repository index updated");
    } else {
        cli::print_error("Failed to update repository");
    }
}

void print_usage() {
    std::cout << "MatLabC++ Package Manager\n";
    std::cout << "========================\n\n";
    std::cout << "Usage: mlab++ pkg <command> [arguments]\n\n";
    std::cout << "Commands:\n";
    std::cout << "  search <query>    Search for packages\n";
    std::cout << "  info <package>    Show package information\n";
    std::cout << "  install <package> Install a package\n";
    std::cout << "  remove <package>  Remove a package\n";
    std::cout << "  list              List installed packages\n";
    std::cout << "  update            Update repository index\n\n";
    std::cout << "Examples:\n";
    std::cout << "  mlab++ pkg search materials\n";
    std::cout << "  mlab++ pkg install materials_smart\n";
    std::cout << "  mlab++ pkg list\n";
}

// ========== MAIN ==========

int main(int argc, char** argv) {
    if (argc < 2) {
        print_usage();
        return 1;
    }
    
    std::string command = argv[1];
    std::vector<std::string> args;
    
    for (int i = 2; i < argc; ++i) {
        args.push_back(argv[i]);
    }
    
    try {
        PackageManager pm;
        
        if (command == "search") {
            cmd_search(pm, args);
        } else if (command == "info") {
            cmd_info(pm, args);
        } else if (command == "install") {
            cmd_install(pm, args);
        } else if (command == "remove") {
            cmd_remove(pm, args);
        } else if (command == "list") {
            cmd_list(pm, args);
        } else if (command == "update") {
            cmd_update(pm, args);
        } else {
            std::cerr << "Error: Unknown command '" << command << "'\n\n";
            print_usage();
            return 1;
        }
        
    } catch (const std::exception& e) {
        cli::print_error(std::string("Fatal error: ") + e.what());
        return 1;
    }
    
    return 0;
}
