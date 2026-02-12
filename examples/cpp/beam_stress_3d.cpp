/*
 * 3D Beam Stress Visualization
 * 
 * Simulates a cantilever beam under load with material properties
 * Outputs 3D mesh data for visualization in external tools
 * 
 * Build: g++ -std=c++20 -I../../include beam_stress_3d.cpp -o beam_stress_3d
 * Run:   ./beam_stress_3d
 * View:  Use gnuplot, ParaView, or Python matplotlib for 3D visualization
 */

#include <matlabcpp.hpp>
#include <iostream>
#include <fstream>
#include <cmath>
#include <vector>
#include <iomanip>

using namespace matlabcpp;

struct Point3D {
    double x, y, z;
    double stress;  // von Mises stress (Pa)
    double displacement;  // meters
};

struct BeamMesh {
    std::vector<Point3D> points;
    int nx, ny, nz;  // Grid dimensions
};

// Cantilever beam stress calculation
// Beam fixed at x=0, loaded at x=L
BeamMesh generate_beam_mesh(
    const Material& material,
    double length,      // m
    double width,       // m  
    double height,      // m
    double load,        // N (downward force at tip)
    int resolution = 20
) {
    BeamMesh mesh;
    mesh.nx = resolution;
    mesh.ny = resolution / 4;
    mesh.nz = resolution / 4;
    
    // Material properties
    double E = material.mechanical.youngs_modulus;  // Pa
    double I = (width * std::pow(height, 3)) / 12.0;  // Second moment of area
    
    std::cout << "\nBeam Analysis:\n";
    std::cout << "  Material: " << material.name << "\n";
    std::cout << "  E = " << E/1e9 << " GPa\n";
    std::cout << "  I = " << I*1e12 << " cm^4\n";
    std::cout << "  Load: " << load << " N\n\n";
    
    // Generate 3D mesh grid
    for (int iz = 0; iz < mesh.nz; iz++) {
        for (int iy = 0; iy < mesh.ny; iy++) {
            for (int ix = 0; ix < mesh.nx; ix++) {
                Point3D p;
                
                // Position
                p.x = (ix / double(mesh.nx - 1)) * length;
                p.y = ((iy / double(mesh.ny - 1)) - 0.5) * width;
                p.z = ((iz / double(mesh.nz - 1)) - 0.5) * height;
                
                // Beam theory: maximum stress at outer fiber
                // σ = M*c/I where M = F*(L-x), c = distance from neutral axis
                double moment = load * (length - p.x);  // Bending moment at x
                double c = std::abs(p.z);  // Distance from neutral axis
                
                // Bending stress (simplified - ignores shear)
                p.stress = (moment * c) / I;
                
                // Displacement (beam deflection)
                // v(x) = (F*x^2)/(6*E*I) * (3*L - x)
                double x = p.x;
                double L = length;
                p.displacement = (load * x * x) / (6.0 * E * I) * (3*L - x);
                
                // Add to mesh
                mesh.points.push_back(p);
            }
        }
    }
    
    // Find max stress for reporting
    double max_stress = 0;
    double max_displacement = 0;
    for (const auto& p : mesh.points) {
        if (std::abs(p.stress) > max_stress) max_stress = std::abs(p.stress);
        if (std::abs(p.displacement) > max_displacement) max_displacement = std::abs(p.displacement);
    }
    
    std::cout << "Results:\n";
    std::cout << "  Max stress: " << max_stress/1e6 << " MPa\n";
    std::cout << "  Max displacement: " << max_displacement*1000 << " mm\n";
    std::cout << "  Yield strength: " << material.mechanical.yield_strength/1e6 << " MPa\n";
    
    // Safety factor
    double safety_factor = material.mechanical.yield_strength / max_stress;
    std::cout << "  Safety factor: " << std::fixed << std::setprecision(2) << safety_factor << "\n";
    
    if (safety_factor < 1.0) {
        std::cout << "  ⚠️  WARNING: Beam will FAIL (stress exceeds yield)\n";
    } else if (safety_factor < 2.0) {
        std::cout << "  ⚠️  CAUTION: Low safety factor\n";
    } else {
        std::cout << "  ✓ SAFE: Adequate safety margin\n";
    }
    
    return mesh;
}

// Export to VTK format (for ParaView, VisIt, etc.)
void export_vtk(const BeamMesh& mesh, const std::string& filename) {
    std::ofstream f(filename);
    
    f << "# vtk DataFile Version 3.0\n";
    f << "Beam stress visualization\n";
    f << "ASCII\n";
    f << "DATASET STRUCTURED_GRID\n";
    f << "DIMENSIONS " << mesh.nx << " " << mesh.ny << " " << mesh.nz << "\n";
    f << "POINTS " << mesh.points.size() << " float\n";
    
    // Write points
    for (const auto& p : mesh.points) {
        f << p.x << " " << p.y << " " << p.z << "\n";
    }
    
    // Write stress data
    f << "\nPOINT_DATA " << mesh.points.size() << "\n";
    f << "SCALARS stress float 1\n";
    f << "LOOKUP_TABLE default\n";
    for (const auto& p : mesh.points) {
        f << p.stress / 1e6 << "\n";  // MPa
    }
    
    // Write displacement data
    f << "\nSCALARS displacement float 1\n";
    f << "LOOKUP_TABLE default\n";
    for (const auto& p : mesh.points) {
        f << p.displacement * 1000 << "\n";  // mm
    }
    
    f.close();
    std::cout << "\n✓ VTK file saved: " << filename << "\n";
    std::cout << "  View in ParaView, VisIt, or similar\n";
}

// Export to CSV for Python/MATLAB plotting
void export_csv(const BeamMesh& mesh, const std::string& filename) {
    std::ofstream f(filename);
    
    f << "x,y,z,stress_MPa,displacement_mm\n";
    f << std::scientific << std::setprecision(6);
    
    for (const auto& p : mesh.points) {
        f << p.x << "," 
          << p.y << "," 
          << p.z << "," 
          << p.stress/1e6 << "," 
          << p.displacement*1000 << "\n";
    }
    
    f.close();
    std::cout << "✓ CSV file saved: " << filename << "\n";
}

// Generate Python visualization script
void export_python_viewer(const std::string& csv_filename) {
    std::ofstream f("view_beam_3d.py");
    
    f << R"(#!/usr/bin/env python3
"""
3D Beam Stress Visualization
Auto-generated by beam_stress_3d.cpp
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Load data
data = np.loadtxt(')" << csv_filename << R"(', delimiter=',', skiprows=1)
x = data[:, 0]
y = data[:, 1]
z = data[:, 2]
stress = data[:, 3]  # MPa
displacement = data[:, 4]  # mm

# Create 3D visualization
fig = plt.figure(figsize=(14, 6))

# Plot 1: Stress distribution
ax1 = fig.add_subplot(121, projection='3d')
scatter1 = ax1.scatter(x, y, z, c=stress, cmap='jet', s=10)
ax1.set_xlabel('Length (m)')
ax1.set_ylabel('Width (m)')
ax1.set_zlabel('Height (m)')
ax1.set_title('Von Mises Stress (MPa)')
plt.colorbar(scatter1, ax=ax1, label='Stress (MPa)')

# Plot 2: Displacement
ax2 = fig.add_subplot(122, projection='3d')
scatter2 = ax2.scatter(x, y, z, c=displacement, cmap='viridis', s=10)
ax2.set_xlabel('Length (m)')
ax2.set_ylabel('Width (m)')
ax2.set_zlabel('Height (m)')
ax2.set_title('Displacement (mm)')
plt.colorbar(scatter2, ax=ax2, label='Displacement (mm)')

plt.tight_layout()
plt.savefig('beam_stress_3d.png', dpi=150)
print('✓ Visualization saved: beam_stress_3d.png')
plt.show()
)";
    
    f.close();
    
    // Make executable on Unix
    #ifndef _WIN32
    system("chmod +x view_beam_3d.py");
    #endif
    
    std::cout << "✓ Python viewer saved: view_beam_3d.py\n";
    std::cout << "  Run: python3 view_beam_3d.py\n";
}

// Generate gnuplot script
void export_gnuplot_viewer(const std::string& csv_filename) {
    std::ofstream f("view_beam_3d.gp");
    
    f << R"(#!/usr/bin/gnuplot
# 3D Beam Stress Visualization
# Auto-generated by beam_stress_3d.cpp

set terminal pngcairo size 1400,600 enhanced font 'Arial,10'
set output 'beam_stress_3d.png'

set multiplot layout 1,2

# Plot 1: Stress
set title 'Von Mises Stress (MPa)'
set xlabel 'Length (m)'
set ylabel 'Width (m)'
set zlabel 'Height (m)'
set view 60,30
set palette defined (0 'blue', 1 'cyan', 2 'yellow', 3 'red')
set cblabel 'Stress (MPa)'
splot ')" << csv_filename << R"(' using 1:2:3:4 with points palette pt 7 ps 0.5 title ''

# Plot 2: Displacement
set title 'Displacement (mm)'
set cblabel 'Displacement (mm)'
set palette defined (0 'blue', 1 'green', 2 'yellow')
splot ')" << csv_filename << R"(' using 1:2:3:5 with points palette pt 7 ps 0.5 title ''

unset multiplot
print 'Visualization saved: beam_stress_3d.png'
)";
    
    f.close();
    
    #ifndef _WIN32
    system("chmod +x view_beam_3d.gp");
    #endif
    
    std::cout << "✓ Gnuplot script saved: view_beam_3d.gp\n";
    std::cout << "  Run: gnuplot view_beam_3d.gp\n";
}

int main() {
    std::cout << "╔══════════════════════════════════════════════════════╗\n";
    std::cout << "║  3D Beam Stress Visualization - MatLabC++ v0.2.0    ║\n";
    std::cout << "║  Material Database Integration Demo                 ║\n";
    std::cout << "╚══════════════════════════════════════════════════════╝\n";
    
    // Initialize system
    system().initialize();
    
    // Get material from database
    auto mat = get_material("aluminum_6061");
    if (!mat) {
        std::cerr << "Error: Material not found\n";
        return 1;
    }
    
    std::cout << "\nMaterial Properties:\n";
    std::cout << "  Name: " << mat->name << "\n";
    std::cout << "  Density: " << mat->thermal.density << " kg/m³\n";
    std::cout << "  Young's Modulus: " << mat->mechanical.youngs_modulus/1e9 << " GPa\n";
    std::cout << "  Yield Strength: " << mat->mechanical.yield_strength/1e6 << " MPa\n";
    
    // Beam geometry
    double length = 1.0;   // 1 meter
    double width = 0.05;   // 5 cm
    double height = 0.10;  // 10 cm
    double load = 1000.0;  // 1000 N (≈ 100 kg)
    
    std::cout << "\nBeam Geometry:\n";
    std::cout << "  Length: " << length*100 << " cm\n";
    std::cout << "  Width: " << width*100 << " cm\n";
    std::cout << "  Height: " << height*100 << " cm\n";
    std::cout << "  Load: " << load << " N (at free end)\n";
    
    // Generate 3D mesh with stress analysis
    std::cout << "\n" << std::string(60, '=') << "\n";
    auto mesh = generate_beam_mesh(*mat, length, width, height, load, 30);
    std::cout << std::string(60, '=') << "\n";
    
    std::cout << "\nMesh Statistics:\n";
    std::cout << "  Points: " << mesh.points.size() << "\n";
    std::cout << "  Resolution: " << mesh.nx << " x " << mesh.ny << " x " << mesh.nz << "\n";
    
    // Export in multiple formats
    std::cout << "\n" << std::string(60, '=') << "\n";
    std::cout << "EXPORTING 3D VISUALIZATION DATA\n";
    std::cout << std::string(60, '=') << "\n";
    
    export_csv(mesh, "beam_stress_3d.csv");
    export_vtk(mesh, "beam_stress_3d.vtk");
    export_python_viewer("beam_stress_3d.csv");
    export_gnuplot_viewer("beam_stress_3d.csv");
    
    // Summary
    std::cout << "\n" << std::string(60, '=') << "\n";
    std::cout << "VISUALIZATION OPTIONS\n";
    std::cout << std::string(60, '=') << "\n";
    std::cout << "\n1. Python (matplotlib - recommended):\n";
    std::cout << "   python3 view_beam_3d.py\n";
    std::cout << "\n2. Gnuplot:\n";
    std::cout << "   gnuplot view_beam_3d.gp\n";
    std::cout << "\n3. ParaView (professional):\n";
    std::cout << "   paraview beam_stress_3d.vtk\n";
    std::cout << "\n4. MATLAB/Octave:\n";
    std::cout << "   data = csvread('beam_stress_3d.csv', 1, 0);\n";
    std::cout << "   scatter3(data(:,1), data(:,2), data(:,3), 10, data(:,4));\n";
    std::cout << "\n5. Raw data inspection:\n";
    std::cout << "   head beam_stress_3d.csv\n";
    
    std::cout << "\n✓ Complete! Run any visualization command above.\n\n";
    
    return 0;
}
