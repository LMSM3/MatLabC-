// leakage_sim.c - Leaking tank dynamics simulation
#include <stdio.h>
#include <math.h>

double tankODE(double h, double Qin, double g, double Atank, double Ahole) {
    double Qout = Ahole * sqrt(2.0 * g * fmax(h, 0.0));
    return (Qin - Qout) / Atank;
}

int main() {
    // Parameters
    const double g = 9.81;
    const double tankD = 1.0, holeD = 0.05;
    const double h0 = 2.0, Qin = 0.01;
    const double tspan = 100.0;
    const int steps = 1000;
    
    const double Atank = M_PI * (tankD/2.0) * (tankD/2.0);
    const double Ahole = M_PI * (holeD/2.0) * (holeD/2.0);
    const double dt = tspan / steps;
    
    printf("# Leaking Tank Simulation\n");
    printf("# time(s), water_level(m)\n");
    
    double t = 0.0, h = h0;
    for (int i = 0; i <= steps; i++) {
        printf("%.3f, %.6f\n", t, h);
        
        // Simple Euler integration
        double dhdt = tankODE(h, Qin, g, Atank, Ahole);
        h += dhdt * dt;
        t += dt;
        
        if (h < 0) h = 0;
    }
    
    printf("\n# Simulation complete: tank drained or equilibrium reached\n");
    return 0;
}
