// helix_plot.c - 3D helix data generator
#include <stdio.h>
#include <math.h>

int main() {
    const double pi = 3.14159265358979323846;
    const int n = 100;
    
    printf("# 3D Helix Plot Data\n");
    printf("# t, x, y, z\n");
    
    for (int i = 0; i < n; i++) {
        double t = (i / (double)n) * 10 * pi;
        double x = sin(t);
        double y = cos(t);
        double z = t;
        printf("%.6f, %.6f, %.6f, %.6f\n", t, x, y, z);
    }
    
    printf("\n# Export complete: helix_plot.csv\n");
    return 0;
}
