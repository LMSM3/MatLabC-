#include <cmath>
#include <iostream>
#include <iomanip>

struct Params {
    double g;    // gravity
    double rho;  // air density
    double Cd;   // drag coefficient
    double A;    // area
    double m;    // mass
};

struct State {
    double h; // height
    double v; // velocity
};

static inline State f(double /*t*/, const State& y, const Params& p) {
    const double k = (p.rho * p.Cd * p.A) / (2.0 * p.m);
    const double drag = k * y.v * std::abs(y.v);
    return State{ y.v, p.g - drag }; // dh/dt = v, dv/dt = g - k*v|v|
}

static inline State add(const State& a, const State& b, double s) {
    return State{ a.h + s*b.h, a.v + s*b.v };
}

static inline State rk4_step(double t, const State& y, double dt, const Params& p) {
    const State k1 = f(t,           y,                p);
    const State k2 = f(t + dt*0.5,   add(y, k1, dt*0.5), p);
    const State k3 = f(t + dt*0.5,   add(y, k2, dt*0.5), p);
    const State k4 = f(t + dt,       add(y, k3, dt),     p);

    State out;
    out.h = y.h + (dt/6.0)*(k1.h + 2.0*k2.h + 2.0*k3.h + k4.h);
    out.v = y.v + (dt/6.0)*(k1.v + 2.0*k2.v + 2.0*k3.v + k4.v);
    return out;
}

// Find t_hit within [t, t+dt] where h(t_hit)=0 using bisection on the step.
static inline double find_ground_time(double t, const State& y0, double dt, const Params& p) {
    double lo = 0.0, hi = dt;
    double h_lo = y0.h;
    for (int i = 0; i < 60; ++i) { // plenty for double precision
        double mid = 0.5*(lo + hi);
        State ym = rk4_step(t, y0, mid, p);
        if ((h_lo > 0.0 && ym.h > 0.0) || (h_lo < 0.0 && ym.h < 0.0)) {
            lo = mid;  // still same side
            h_lo = ym.h;
        } else {
            hi = mid;  // crossed
        }
    }
    return t + 0.5*(lo + hi);
}

int main() {
    Params p{ 9.81, 1.225, 0.47, 0.0314159, 68.1 }; // example
    double t = 0.0;
    double dt = 0.01;

    State y{ 100.0, 0.0 }; // start at 100m, v=0
    std::cout << std::fixed << std::setprecision(6);

    while (t < 60.0) {
        State y_next = rk4_step(t, y, dt, p);

        // Event: hit ground (h crosses 0)
        if (y.h > 0.0 && y_next.h <= 0.0) {
            double t_hit = find_ground_time(t, y, dt, p);
            State y_hit = rk4_step(t, y, t_hit - t, p);
            double a_hit = f(t_hit, y_hit, p).v;

            std::cout << "HIT ground at t=" << t_hit
                      << "  v=" << y_hit.v
                      << "  a=" << a_hit
                      << "\n";
            break;
        }

        // sample outputs
        double a = f(t, y, p).v;
        std::cout << t << "  h=" << y.h << "  v=" << y.v << "  a=" << a << "\n";

        t += dt;
        y = y_next;
    }
}
