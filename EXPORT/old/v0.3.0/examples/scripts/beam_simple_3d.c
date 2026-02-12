/*
 * Simple 3D Stress Visualization (C version)
 * 
 * Generates 3D cantilever beam mesh with color-coded stress
 * Can be run as a script via MatLabC++ v0.2.0
 * 
 * Run: ./matlabcpp run beam_simple_3d.c
 * Or:  gcc -std=c99 -O2 -lm beam_simple_3d.c -o beam && ./beam
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define PI 3.14159265358979323846

// Material properties (Aluminum 6061-T6)
typedef struct {
    const char* name;
    double density;           // kg/m³
    double youngs_modulus;    // Pa
    double yield_strength;    // Pa
} Material;

typedef struct {
    double x, y, z;
    double stress;  // Pa
} Point3D;

void generate_beam_mesh_3d(
    Material mat,
    double length,
    double width,
    double height,
    double load,
    int resolution,
    const char* output_file
) {
    // Calculate second moment of area
    double I = (width * pow(height, 3)) / 12.0;
    double E = mat.youngs_modulus;
    
    printf("\n3D Beam Stress Analysis\n");
    printf("========================\n");
    printf("Material: %s\n", mat.name);
    printf("E = %.1f GPa\n", E/1e9);
    printf("Yield = %.1f MPa\n", mat.yield_strength/1e6);
    printf("Load = %.0f N\n\n", load);
    
    // Open output file
    FILE* fp = fopen(output_file, "w");
    if (!fp) {
        fprintf(stderr, "Error: Cannot open %s\n", output_file);
        return;
    }
    
    // Write header
    fprintf(fp, "x,y,z,stress_MPa,displacement_mm,color\n");
    
    double max_stress = 0;
    double max_displacement = 0;
    int total_points = 0;
    
    // Generate 3D mesh
    for (int iz = 0; iz < resolution; iz++) {
        for (int iy = 0; iy < resolution/2; iy++) {
            for (int ix = 0; ix < resolution*2; ix++) {
                Point3D p;
                
                // Position
                p.x = (ix / (double)(resolution*2 - 1)) * length;
                p.y = ((iy / (double)(resolution/2 - 1)) - 0.5) * width;
                p.z = ((iz / (double)(resolution - 1)) - 0.5) * height;
                
                // Bending moment at position x
                double moment = load * (length - p.x);
                
                // Distance from neutral axis
                double c = fabs(p.z);
                
                // Bending stress: σ = M*c/I
                p.stress = (moment * c) / I;
                
                // Displacement: v(x) = (F*x²)/(6*E*I) * (3*L - x)
                double x = p.x;
                double L = length;
                double displacement = (load * x * x) / (6.0 * E * I) * (3*L - x);
                
                // Track maximums
                if (fabs(p.stress) > max_stress) {
                    max_stress = fabs(p.stress);
                }
                if (fabs(displacement) > max_displacement) {
                    max_displacement = fabs(displacement);
                }
                
                // Color mapping (0-255 RGB for stress level)
                // Blue (low) -> Cyan -> Green -> Yellow -> Red (high)
                double stress_normalized = fabs(p.stress) / (mat.yield_strength * 0.5);
                if (stress_normalized > 1.0) stress_normalized = 1.0;
                
                int color = (int)(stress_normalized * 255);
                
                // Write to file
                fprintf(fp, "%.6f,%.6f,%.6f,%.3f,%.6f,%d\n",
                       p.x, p.y, p.z,
                       p.stress/1e6,
                       displacement*1000,
                       color);
                
                total_points++;
            }
        }
    }
    
    fclose(fp);
    
    // Results
    printf("Results:\n");
    printf("  Total points: %d\n", total_points);
    printf("  Max stress: %.2f MPa\n", max_stress/1e6);
    printf("  Max displacement: %.3f mm\n", max_displacement*1000);
    
    // Safety factor
    double safety_factor = mat.yield_strength / max_stress;
    printf("  Safety factor: %.2f\n", safety_factor);
    
    if (safety_factor < 1.0) {
        printf("  ⚠️  WARNING: FAILURE - stress exceeds yield!\n");
    } else if (safety_factor < 2.0) {
        printf("  ⚠️  CAUTION: Low safety factor\n");
    } else {
        printf("  ✓ SAFE: Adequate margin\n");
    }
    
    printf("\n✓ 3D data saved: %s\n", output_file);
    printf("  View with: python3 view_3d.py\n\n");
}

// Generate Python viewer
void create_python_viewer(const char* csv_file) {
    FILE* fp = fopen("view_3d.py", "w");
    if (!fp) return;
    
    fprintf(fp, "#!/usr/bin/env python3\n");
    fprintf(fp, "import numpy as np\n");
    fprintf(fp, "import matplotlib.pyplot as plt\n");
    fprintf(fp, "from mpl_toolkits.mplot3d import Axes3D\n\n");
    fprintf(fp, "data = np.loadtxt('%s', delimiter=',', skiprows=1)\n", csv_file);
    fprintf(fp, "x, y, z = data[:, 0], data[:, 1], data[:, 2]\n");
    fprintf(fp, "stress = data[:, 3]\n\n");
    fprintf(fp, "fig = plt.figure(figsize=(12, 8))\n");
    fprintf(fp, "ax = fig.add_subplot(111, projection='3d')\n");
    fprintf(fp, "scatter = ax.scatter(x, y, z, c=stress, cmap='jet', s=5)\n");
    fprintf(fp, "ax.set_xlabel('Length (m)')\n");
    fprintf(fp, "ax.set_ylabel('Width (m)')\n");
    fprintf(fp, "ax.set_zlabel('Height (m)')\n");
    fprintf(fp, "ax.set_title('3D Beam Stress (MPa)')\n");
    fprintf(fp, "plt.colorbar(scatter, label='Stress (MPa)')\n");
    fprintf(fp, "plt.savefig('beam_3d.png', dpi=150)\n");
    fprintf(fp, "print('Saved: beam_3d.png')\n");
    fprintf(fp, "plt.show()\n");
    
    fclose(fp);
    
    #ifndef _WIN32
    system("chmod +x view_3d.py");
    #endif
    
    printf("✓ Python viewer created: view_3d.py\n");
}

int main() {
    printf("╔═══════════════════════════════════════════╗\n");
    printf("║  3D Beam Stress - MatLabC++ v0.2.0        ║\n");
    printf("║  C Script Version                         ║\n");
    printf("╚═══════════════════════════════════════════╝\n");
    
    // Material: Aluminum 6061-T6
    Material aluminum = {
        .name = "Aluminum 6061-T6",
        .density = 2700,
        .youngs_modulus = 69e9,     // 69 GPa
        .yield_strength = 276e6     // 276 MPa
    };
    
    // Beam dimensions
    double length = 1.0;    // 1 meter
    double width = 0.05;    // 5 cm
    double height = 0.10;   // 10 cm
    double load = 500.0;    // 500 N
    
    printf("\nBeam Geometry:\n");
    printf("  Length: %.0f cm\n", length*100);
    printf("  Width: %.0f cm\n", width*100);
    printf("  Height: %.0f cm\n", height*100);
    
    // Generate 3D mesh
    generate_beam_mesh_3d(
        aluminum,
        length, width, height,
        load,
        20,  // resolution
        "beam_3d.csv"
    );
    
    // Create visualization script
    create_python_viewer("beam_3d.csv");
    
    printf("\nQuick view commands:\n");
    printf("  1. python3 view_3d.py\n");
    printf("  2. gnuplot -e \"splot 'beam_3d.csv' using 1:2:3:4 with points palette\"\n");
    printf("  3. head -20 beam_3d.csv  # Inspect raw data\n\n");
    
    return 0;
}
