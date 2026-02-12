// Package Dependency Resolver - Topological sort with cycle detection
// src/package_manager/resolver.cpp

#include "matlabcpp/package_manager.hpp"
#include <algorithm>
#include <unordered_set>
#include <sstream>

namespace matlabcpp {
namespace pkg {

DependencyResolver::DependencyResolver(PackageDatabase& db, Repository& repo)
    : db_(db), repo_(repo) {}

DependencyResolver::Resolution DependencyResolver::resolve(const std::string& package_name) {
    return resolve_multiple({package_name});
}

DependencyResolver::Resolution DependencyResolver::resolve_multiple(
    const std::vector<std::string>& packages) {

    Resolution result;
    result.success = false;

    std::unordered_map<std::string, std::vector<std::string>> dep_graph;
    std::unordered_set<std::string> visited;
    std::unordered_set<std::string> visiting;
    std::vector<std::string> missing_deps;

    // Build dependency graph with cycle detection
    for (const auto& pkg : packages) {
        if (!build_dep_graph_recursive(pkg, dep_graph, visited, visiting, missing_deps)) {
            result.error = DependencyError{
                "Circular dependency detected or missing packages",
                missing_deps,
                {}
            };
            return result;
        }
    }

    // Check for missing dependencies
    if (!missing_deps.empty()) {
        result.error = DependencyError{
            "Missing required dependencies",
            missing_deps,
            {}
        };
        return result;
    }

    // Topological sort using DFS
    std::unordered_set<std::string> sorted_set;
    for (const auto& pkg : packages) {
        topological_sort(pkg, dep_graph, sorted_set, result.install_order);
    }

    result.success = true;
    return result;
}

bool DependencyResolver::build_dep_graph_recursive(
    const std::string& pkg,
    std::unordered_map<std::string, std::vector<std::string>>& graph,
    std::unordered_set<std::string>& visited,
    std::unordered_set<std::string>& visiting,
    std::vector<std::string>& missing) {

    // Already processed
    if (visited.count(pkg)) {
        return true;
    }

    // Cycle detected
    if (visiting.count(pkg)) {
        return false;
    }

    // Check if already installed
    if (db_.is_installed(pkg)) {
        visited.insert(pkg);
        return true;
    }

    // Find package in repository
    auto manifest_opt = repo_.find(pkg);
    if (!manifest_opt) {
        missing.push_back(pkg);
        return false;
    }

    visiting.insert(pkg);
    auto& manifest = *manifest_opt;

    // Process dependencies
    graph[pkg] = manifest.requires;
    for (const auto& dep : manifest.requires) {
        if (!build_dep_graph_recursive(dep, graph, visited, visiting, missing)) {
            return false;
        }
    }

    visiting.erase(pkg);
    visited.insert(pkg);
    return true;
}

void DependencyResolver::topological_sort(
    const std::string& pkg,
    const std::unordered_map<std::string, std::vector<std::string>>& graph,
    std::unordered_set<std::string>& visited,
    std::vector<std::string>& order) {

    if (visited.count(pkg)) {
        return;
    }

    visited.insert(pkg);

    // Visit dependencies first
    auto it = graph.find(pkg);
    if (it != graph.end()) {
        for (const auto& dep : it->second) {
            topological_sort(dep, graph, visited, order);
        }
    }

    // Add package after dependencies
    if (!db_.is_installed(pkg)) {
        order.push_back(pkg);
    }
}

} // namespace pkg
} // namespace matlabcpp

