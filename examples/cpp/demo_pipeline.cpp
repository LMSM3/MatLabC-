#include <matlabcpp.hpp>
#include <fstream>
#include <random>
#include <string>

using namespace matlabcpp;

// Safe write: tmp then rename
static void safe_write(const std::string& path, const std::string& data) {
    const std::string tmp = path + ".tmp";
    std::ofstream ofs(tmp, std::ios::binary);
    ofs << data;
    ofs.close();
    std::remove(path.c_str());
    std::rename(tmp.c_str(), path.c_str());
}

int main() {
    // Deterministic seed
    std::mt19937 rng(12345);

    // 1) Numerical core: matmul + solve
    Matrix A{{4, 1, 0}, {1, 3, 1}, {0, 1, 2}};
    Matrix B{{1, 2}, {0, 1}, {1, 0}};
    Vector b{1, 2, 3};

    Matrix C = matmul(A, B);
    Vector x = lu_solve(A, b);

    // 2) Tiny molecule state: three atoms positions (deterministic jitter)
    struct Atom { std::string name; double x, y, z; };
    std::uniform_real_distribution<double> jitter(-0.05, 0.05);
    Atom atoms[] = {
        {"C", 0.0 + jitter(rng), 0.0 + jitter(rng), 0.0 + jitter(rng)},
        {"O", 1.2 + jitter(rng), 0.0 + jitter(rng), 0.0 + jitter(rng)},
        {"H",-0.6 + jitter(rng), 0.9 + jitter(rng), 0.0 + jitter(rng)}
    };

    // 3) Export CSV (crash-safe)
    std::string csv = "atom,x,y,z\n";
    for (auto& a : atoms) {
        csv += a.name + "," + std::to_string(a.x) + "," + std::to_string(a.y) + "," + std::to_string(a.z) + "\n";
    }
    safe_write("demo_atoms.csv", csv);

    // 4) Export JSON (crash-safe)
    std::string json = "{\n  \"matrix_C\": [\n";
    for (std::size_t i = 0; i < C.size(); ++i) {
        json += "    [";
        for (std::size_t j = 0; j < C[i].size(); ++j) {
            json += std::to_string(C[i][j]);
            if (j + 1 < C[i].size()) json += ", ";
        }
        json += "]";
        json += (i + 1 < C.size()) ? ",\n" : "\n";
    }
    json += "  ],\n  \"solve_x\": [";
    for (std::size_t i = 0; i < x.size(); ++i) {
        json += std::to_string(x[i]);
        if (i + 1 < x.size()) json += ", ";
    }
    json += "],\n  \"atoms\": [\n";
    for (int i = 0; i < 3; ++i) {
        json += "    {\"name\": \"" + atoms[i].name + "\", \"x\": " + std::to_string(atoms[i].x)
              + ", \"y\": " + std::to_string(atoms[i].y) + ", \"z\": " + std::to_string(atoms[i].z) + "}";
        json += (i + 1 < 3) ? ",\n" : "\n";
    }
    json += "  ]\n}\n";
    safe_write("demo_atoms.json", json);

    // 5) Console summary (overlay-ready)
    std::cout << "MatMul C = A*B -> C[0][0]=" << C[0][0] << "\n";
    std::cout << "Solve Ax=b -> x=[" << x[0] << ", " << x[1] << ", " << x[2] << "]\n";
    std::cout << "Exports: demo_atoms.csv, demo_atoms.json (deterministic seed=12345)\n";
    std::cout << "Ready for viewer overlay: 3 atoms positions in exports." << std::endl;
    return 0;
}
