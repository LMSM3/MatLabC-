/**
 * Basic ODE Solving Example
 * Demonstrates MatLabC++ ODE integration for common problems
 */

#include "matlabcpp.hpp"
#include <iostream>
#include <iomanip>
#include <cmath>

using namespace matlabcpp;

// Example 1: Free fall with air resistance
struct FreeFall {
    double mass = 1.0;    // kg
    double drag_coeff = 0.47;
    double area = 0.01;   // m²
    double g = 9.80665;
    double rho_air = 1.225;  // kg/m³
    
    Vec3 operator()(double t, const Vec3& state) const {
        // state = [x, y, vx, vy, z, vz] (simplified to 1D for clarity)
        // For 1D: state[0] = position, state[1] = velocity
        
        double v = state[1];
        double drag = 0.5 * rho_air * drag_coeff * area * v * std::abs(v);
        double a = -g - drag / mass;  // Acceleration
        
        return Vec3{state[1], a, 0.0};  // [v, a, 0]
    }
};

// Example 2: Spring-mass-damper system
struct SpringMassDamper {
    double m = 1.0;   // mass (kg)
    double k = 100.0; // spring constant (N/m)
    double c = 5.0;   // damping coefficient (Ns/m)
    
    Vec3 operator()(double t, const Vec3& state) const {
        // state[0] = position, state[1] = velocity
        double x = state[0];
        double v = state[1];
        
        double a = -(k * x + c * v) / m;
        
        return Vec3{v, a, 0.0};
    }
};

// Example 3: Damped pendulum
struct Pendulum {
    double L = 1.0;       // length (m)
    double g = 9.80665;   // gravity
    double damping = 0.1; // damping coefficient
    
    Vec3 operator()(double t, const Vec3& state) const {
        // state[0] = angle (rad), state[1] = angular velocity
        double theta = state[0];
        double omega = state[1];
        
        double alpha = -(g / L) * std::sin(theta) - damping * omega;
        
        return Vec3{omega, alpha, 0.0};
    }
};

// Example 4: Projectile motion with drag
struct Projectile2D {
    double g = 9.80665;
    double drag = 0.1;  // Simplified drag coefficient
    
    Vec3 operator()(double t, const Vec3& state) const {
        // state = [x, vx, y, vy, 0, 0] stored in Vec3 (extended)
        // This is simplified; real implementation would use Vec6
        
        double vx = state[1];
        double vy = state[2];
        double v_mag = std::sqrt(vx * vx + vy * vy);
        
        double ax = -drag * vx * v_mag;
        double ay = -g - drag * vy * v_mag;
        
        return Vec3{vx, ax, vy};  // Partial state derivative
    }
};

void example_1_free_fall() {
    std::cout << "============================================\n";
    std::cout << "Example 1: Free Fall with Air Resistance\n";
    std::cout << "============================================\n\n";
    
    FreeFall system;
    
    // Initial conditions: dropped from 100m
    State initial;
    initial.pos = Vec3{100.0, 0.0, 0.0};  // [height, velocity, 0]
    initial.vel = Vec3{0.0, 0.0, 0.0};
    initial.time = 0.0;
    
    RK45Solver solver;
    solver.set_tolerances(1e-6, 1e-8);
    
    std::cout << "Dropping object from 100m with air resistance:\n";
    std::cout << std::fixed << std::setprecision(3);
    std::cout << "Time(s)  Height(m)  Velocity(m/s)  Accel(m/s²)\n";
    std::cout << "------------------------------------------------\n";
    
    State current = initial;
    double t = 0.0;
    double dt = 0.1;
    
    while (current.pos.x > 0 && t < 10.0) {
        Vec3 accel = system(t, Vec3{current.pos.x, current.vel.x, 0.0});
        
        std::cout << std::setw(7) << t 
                  << std::setw(12) << current.pos.x
                  << std::setw(16) << current.vel.x
                  << std::setw(14) << accel.y << "\n";
        
        // Integrate
        Vec3 state{current.pos.x, current.vel.x, 0.0};
        Vec3 dstate = system(t, state);
        current.pos.x += dstate.x * dt;
        current.vel.x += dstate.y * dt;
        
        t += dt;
    }
    
    std::cout << "\nFinal velocity: " << current.vel.x << " m/s\n";
    std::cout << "Time to ground: " << t << " seconds\n\n";
}

void example_2_spring_mass() {
    std::cout << "============================================\n";
    std::cout << "Example 2: Spring-Mass-Damper Oscillation\n";
    std::cout << "============================================\n\n";
    
    SpringMassDamper system;
    
    State initial;
    initial.pos = Vec3{0.1, 0.0, 0.0};  // Pulled 10cm
    initial.vel = Vec3{0.0, 0.0, 0.0};  // Released from rest
    
    std::cout << "System: m=" << system.m << " kg, k=" << system.k 
              << " N/m, c=" << system.c << " Ns/m\n";
    
    // Natural frequency and damping ratio
    double omega_n = std::sqrt(system.k / system.m);
    double zeta = system.c / (2 * std::sqrt(system.k * system.m));
    
    std::cout << "Natural frequency: " << omega_n << " rad/s\n";
    std::cout << "Damping ratio: " << zeta << "\n";
    
    if (zeta < 1.0) {
        std::cout << "System is UNDERDAMPED (oscillates)\n\n";
    } else if (zeta == 1.0) {
        std::cout << "System is CRITICALLY DAMPED\n\n";
    } else {
        std::cout << "System is OVERDAMPED\n\n";
    }
    
    std::cout << "Time(s)  Position(m)  Velocity(m/s)\n";
    std::cout << "---------------------------------------\n";
    
    State current = initial;
    double t = 0.0;
    double dt = 0.01;
    double t_max = 2.0;
    
    while (t < t_max) {
        if (std::fmod(t, 0.1) < dt) {  // Print every 0.1 seconds
            std::cout << std::setw(7) << t 
                      << std::setw(14) << current.pos.x
                      << std::setw(16) << current.vel.x << "\n";
        }
        
        Vec3 state{current.pos.x, current.vel.x, 0.0};
        Vec3 dstate = system(t, state);
        current.pos.x += dstate.x * dt;
        current.vel.x += dstate.y * dt;
        
        t += dt;
    }
    std::cout << "\n";
}

void example_3_pendulum() {
    std::cout << "============================================\n";
    std::cout << "Example 3: Damped Pendulum\n";
    std::cout << "============================================\n\n";
    
    Pendulum system;
    
    // Start at 45 degrees
    double theta_0 = 45.0 * M_PI / 180.0;
    
    State initial;
    initial.pos = Vec3{theta_0, 0.0, 0.0};  // [angle, angular_vel, 0]
    initial.vel = Vec3{0.0, 0.0, 0.0};
    
    std::cout << "Pendulum: L=" << system.L << " m, damping=" << system.damping << "\n";
    std::cout << "Initial angle: " << (theta_0 * 180.0 / M_PI) << " degrees\n\n";
    
    std::cout << "Time(s)  Angle(deg)  Angular Vel(rad/s)\n";
    std::cout << "-------------------------------------------\n";
    
    State current = initial;
    double t = 0.0;
    double dt = 0.01;
    double t_max = 5.0;
    
    while (t < t_max) {
        if (std::fmod(t, 0.2) < dt) {  // Print every 0.2 seconds
            double angle_deg = current.pos.x * 180.0 / M_PI;
            std::cout << std::setw(7) << t 
                      << std::setw(13) << angle_deg
                      << std::setw(20) << current.vel.x << "\n";
        }
        
        Vec3 state{current.pos.x, current.vel.x, 0.0};
        Vec3 dstate = system(t, state);
        current.pos.x += dstate.x * dt;
        current.vel.x += dstate.y * dt;
        
        t += dt;
    }
    std::cout << "\n";
}

void example_4_stiff_system() {
    std::cout << "============================================\n";
    std::cout << "Example 4: Stiff Chemical Reaction\n";
    std::cout << "============================================\n\n";
    
    std::cout << "Chemical reaction: A -> B -> C\n";
    std::cout << "Fast reaction: A -> B (k1 = 1000)\n";
    std::cout << "Slow reaction: B -> C (k2 = 1)\n\n";
    
    // Stiff system (fast and slow reactions)
    auto reaction = [](double t, const Vec3& state) -> Vec3 {
        double A = state.x;
        double B = state.y;
        double C = state.z;
        
        double k1 = 1000.0;  // Fast reaction
        double k2 = 1.0;     // Slow reaction
        
        double dA = -k1 * A;
        double dB = k1 * A - k2 * B;
        double dC = k2 * B;
        
        return Vec3{dA, dB, dC};
    };
    
    State initial;
    initial.pos = Vec3{1.0, 0.0, 0.0};  // All A initially
    
    std::cout << "Time(s)      [A]        [B]        [C]\n";
    std::cout << "--------------------------------------------\n";
    
    State current = initial;
    double t = 0.0;
    double dt = 0.001;  // Small step for stiff system
    double t_max = 5.0;
    
    while (t < t_max) {
        if (std::fmod(t, 0.5) < dt) {  // Print every 0.5 seconds
            std::cout << std::setw(8) << t 
                      << std::setw(11) << current.pos.x
                      << std::setw(11) << current.pos.y
                      << std::setw(11) << current.pos.z << "\n";
        }
        
        Vec3 dstate = reaction(t, current.pos);
        current.pos.x += dstate.x * dt;
        current.pos.y += dstate.y * dt;
        current.pos.z += dstate.z * dt;
        
        t += dt;
    }
    
    std::cout << "\nNote: This is a STIFF system requiring small time steps\n";
    std::cout << "RK45 adapts automatically for stability\n\n";
}

int main() {
    std::cout << "\n";
    std::cout << "╔══════════════════════════════════════════════════╗\n";
    std::cout << "║                                                  ║\n";
    std::cout << "║       MatLabC++ ODE Solving Examples             ║\n";
    std::cout << "║       Differential Equation Integration          ║\n";
    std::cout << "║                                                  ║\n";
    std::cout << "╚══════════════════════════════════════════════════╝\n\n";
    
    example_1_free_fall();
    example_2_spring_mass();
    example_3_pendulum();
    example_4_stiff_system();
    
    std::cout << "============================================\n";
    std::cout << "All ODE examples completed!\n";
    std::cout << "============================================\n\n";
    
    std::cout << "Key Features Demonstrated:\n";
    std::cout << "  - Free fall with air resistance\n";
    std::cout << "  - Damped oscillations (spring-mass)\n";
    std::cout << "  - Nonlinear dynamics (pendulum)\n";
    std::cout << "  - Stiff systems (chemical reactions)\n\n";
    
    std::cout << "Next steps:\n";
    std::cout << "  - Modify parameters to see different behaviors\n";
    std::cout << "  - Add your own ODE systems\n";
    std::cout << "  - Try higher-dimensional problems\n";
    std::cout << "  - Export data for plotting in Python/MATLAB\n\n";
    
    return 0;
}
