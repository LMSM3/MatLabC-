#pragma once
#include <array>
#include <vector>
#include <functional>
#include <concepts>
#include <algorithm>
#include <cmath>
#include <numbers>
#include <stdexcept>

namespace matlabcpp {

using Matrix = std::vector<std::vector<double>>;
using Vector = std::vector<double>;

inline Matrix matmul(const Matrix& A, const Matrix& B) {
    if (A.empty() || B.empty()) throw std::invalid_argument("matmul: empty matrix");
    const std::size_t m = A.size();
    const std::size_t k = A[0].size();
    const std::size_t kB = B.size();
    if (k != kB) throw std::invalid_argument("matmul: dimension mismatch");
    const std::size_t n = B[0].size();
    Matrix C(m, std::vector<double>(n, 0.0));
    for (std::size_t i = 0; i < m; ++i) {
        if (A[i].size() != k) throw std::invalid_argument("matmul: ragged A");
        for (std::size_t p = 0; p < k; ++p) {
            double a = A[i][p];
            const auto& rowB = B[p];
            if (rowB.size() != n) throw std::invalid_argument("matmul: ragged B");
            for (std::size_t j = 0; j < n; ++j) C[i][j] += a * rowB[j];
        }
    }
    return C;
}

inline Vector matvec(const Matrix& A, const Vector& x) {
    if (A.empty()) throw std::invalid_argument("matvec: empty matrix");
    const std::size_t m = A.size();
    const std::size_t n = A[0].size();
    if (x.size() != n) throw std::invalid_argument("matvec: dimension mismatch");
    Vector y(m, 0.0);
    for (std::size_t i = 0; i < m; ++i) {
        if (A[i].size() != n) throw std::invalid_argument("matvec: ragged A");
        for (std::size_t j = 0; j < n; ++j) y[i] += A[i][j] * x[j];
    }
    return y;
}

inline Vector lu_solve(Matrix A, Vector b) {
    const std::size_t n = A.size();
    if (n == 0 || A[0].size() != n || b.size() != n) throw std::invalid_argument("lu_solve: dimension mismatch");
    // LU with partial pivot (in-place)
    for (std::size_t k = 0; k < n; ++k) {
        std::size_t piv = k;
        double maxv = std::abs(A[k][k]);
        for (std::size_t i = k + 1; i < n; ++i) {
            if (std::abs(A[i][k]) > maxv) { maxv = std::abs(A[i][k]); piv = i; }
        }
        if (maxv == 0.0) throw std::runtime_error("lu_solve: singular matrix");
        if (piv != k) { std::swap(A[piv], A[k]); std::swap(b[piv], b[k]); }
        for (std::size_t i = k + 1; i < n; ++i) {
            A[i][k] /= A[k][k];
            for (std::size_t j = k + 1; j < n; ++j) A[i][j] -= A[i][k] * A[k][j];
            b[i] -= A[i][k] * b[k];
        }
    }
    // Back substitution
    Vector x(n);
    for (int i = static_cast<int>(n) - 1; i >= 0; --i) {
        double sum = b[i];
        for (std::size_t j = i + 1; j < n; ++j) sum -= A[i][j] * x[j];
        x[i] = sum / A[i][i];
    }
    return x;
}

// ========== C++20 Concepts ==========
template<typename T>
concept Scalar = std::floating_point<T>;

// ========== SIMD-friendly Vec3 (aligned) ==========
struct alignas(32) Vec3 {
    double x, y, z, _pad;
    
    constexpr Vec3() noexcept : x(0), y(0), z(0), _pad(0) {}
    constexpr Vec3(double x_, double y_, double z_) noexcept : x(x_), y(y_), z(z_), _pad(0) {}
    
    [[nodiscard]] constexpr Vec3 operator+(Vec3 o) const noexcept { return {x + o.x, y + o.y, z + o.z}; }
    [[nodiscard]] constexpr Vec3 operator-(Vec3 o) const noexcept { return {x - o.x, y - o.y, z - o.z}; }
    [[nodiscard]] constexpr Vec3 operator*(double s) const noexcept { return {x * s, y * s, z * s}; }
    constexpr Vec3& operator+=(Vec3 o) noexcept { x += o.x; y += o.y; z += o.z; return *this; }
    
    [[nodiscard]] constexpr double norm() const noexcept { return std::sqrt(x*x + y*y + z*z); }
    [[nodiscard]] constexpr double norm_sq() const noexcept { return x*x + y*y + z*z; }
    [[nodiscard]] constexpr double dot(Vec3 o) const noexcept { return x*o.x + y*o.y + z*o.z; }
};

// ========== State (cache-line aligned) ==========
struct alignas(64) State {
    Vec3 position, velocity;
    double temperature, _pad[5];
    
    constexpr State() noexcept : position(), velocity(), temperature(300.0), _pad{} {}
    constexpr State(Vec3 x, Vec3 v, double T) noexcept : position(x), velocity(v), temperature(T), _pad{} {}
};

struct alignas(64) DState {
    Vec3 dposition, dvelocity;
    double dtemperature, _pad[5];
    
    constexpr DState() noexcept : dposition(), dvelocity(), dtemperature(0), _pad{} {}
    constexpr DState(Vec3 dx, Vec3 dv, double dT) noexcept : dposition(dx), dvelocity(dv), dtemperature(dT), _pad{} {}
};

[[nodiscard]] constexpr State operator+(const State& s, const DState& ds) noexcept {
    return State(s.position + ds.dposition, s.velocity + ds.dvelocity, s.temperature + ds.dtemperature);
}

[[nodiscard]] constexpr DState operator*(double h, const DState& ds) noexcept {
    return DState(ds.dposition * h, ds.dvelocity * h, ds.dtemperature * h);
}

[[nodiscard]] constexpr DState operator+(const DState& a, const DState& b) noexcept {
    return DState(a.dposition + b.dposition, a.dvelocity + b.dvelocity, a.dtemperature + b.dtemperature);
}

// ========== Sample ==========
struct Sample {
    double time;
    State state;
};

// ========== RK45 Options ==========
struct RK45Options {
    double reltol = 1e-6;
    double abstol = 1e-9;
    double h_init = 1e-2;
    double h_min = 1e-10;
    double h_max = 0.5;
    std::size_t max_steps = 1'000'000;
    std::size_t reserve_samples = 1024;
};

// ========== RK45 Stepper (Dormand-Prince 5(4)) ==========
template<typename F>
[[nodiscard]] inline std::pair<State, DState> rk45_step(F&& f, double t, const State& s, double h) noexcept {
    constexpr double c2 = 0.2, c3 = 0.3, c4 = 0.8, c5 = 8.0/9.0;
    
    DState k1 = f(t, s);
    DState k2 = f(t + c2*h, s + h*0.2*k1);
    DState k3 = f(t + c3*h, s + h*(3.0/40.0)*k1 + h*(9.0/40.0)*k2);
    DState k4 = f(t + c4*h, s + h*(44.0/45.0)*k1 + h*(-56.0/15.0)*k2 + h*(32.0/9.0)*k3);
    DState k5 = f(t + c5*h, s + h*(19372.0/6561.0)*k1 + h*(-25360.0/2187.0)*k2 
                              + h*(64448.0/6561.0)*k3 + h*(-212.0/729.0)*k4);
    DState k6 = f(t + h, s + h*(9017.0/3168.0)*k1 + h*(-355.0/33.0)*k2 
                           + h*(46732.0/5247.0)*k3 + h*(49.0/176.0)*k4 
                           + h*(-5103.0/18656.0)*k5);
    
    State s5 = s + h*(35.0/384.0)*k1 + h*(500.0/1113.0)*k3 
                 + h*(125.0/192.0)*k4 + h*(-2187.0/6784.0)*k5 
                 + h*(11.0/84.0)*k6;
    
    DState k7 = f(t + h, s5);
    
    State s4 = s + h*(5179.0/57600.0)*k1 + h*(7571.0/16695.0)*k3 
                 + h*(393.0/640.0)*k4 + h*(-92097.0/339200.0)*k5 
                 + h*(187.0/2100.0)*k6 + h*(1.0/40.0)*k7;
    
    DState err(s5.position - s4.position, s5.velocity - s4.velocity, s5.temperature - s4.temperature);
    return {s5, err};
}

// ========== Error Norm ==========
[[nodiscard]] inline double error_norm(const DState& err, const State& s, const State& s_next, const RK45Options& opt) noexcept {
    auto comp_err = [&](double e, double y, double yn) -> double {
        double scale = opt.abstol + opt.reltol * std::max(std::abs(y), std::abs(yn));
        return std::abs(e) / scale;
    };
    
    double ex = std::max({comp_err(err.dposition.x, s.position.x, s_next.position.x),
                          comp_err(err.dposition.y, s.position.y, s_next.position.y),
                          comp_err(err.dposition.z, s.position.z, s_next.position.z)});
    double ev = std::max({comp_err(err.dvelocity.x, s.velocity.x, s_next.velocity.x),
                          comp_err(err.dvelocity.y, s.velocity.y, s_next.velocity.y),
                          comp_err(err.dvelocity.z, s.velocity.z, s_next.velocity.z)});
    double eT = comp_err(err.dtemperature, s.temperature, s_next.temperature);
    
    return std::max({ex, ev, eT});
}

// ========== Adaptive RK45 Integrator ==========
template<typename F>
[[nodiscard]] std::vector<Sample> integrate_rk45(F&& f, double t0, double t1, const State& s0, const RK45Options& opt = {}) {
    std::vector<Sample> samples;
    samples.reserve(opt.reserve_samples);
    samples.push_back({t0, s0});
    
    double t = t0;
    State s = s0;
    double h = std::clamp(opt.h_init, opt.h_min, opt.h_max);
    std::size_t steps = 0;
    
    while (t < t1 && steps < opt.max_steps) {
        if (t + h > t1) h = t1 - t;
        
        auto [s_next, err] = rk45_step(f, t, s, h);
        double err_norm_val = error_norm(err, s, s_next, opt);
        
        if (err_norm_val <= 1.0) {
            t += h;
            s = s_next;
            samples.push_back({t, s});
            
            constexpr double safety = 0.9;
            double factor = (err_norm_val > 0) ? safety * std::pow(1.0 / err_norm_val, 0.2) : 2.0;
            h = std::clamp(h * std::clamp(factor, 0.2, 5.0), opt.h_min, opt.h_max);
        } else {
            constexpr double safety = 0.9;
            double factor = safety * std::pow(1.0 / err_norm_val, 0.2);
            h = std::clamp(h * factor, opt.h_min, opt.h_max);
            
            if (h <= opt.h_min) throw std::runtime_error("Step size underflow");
        }
        ++steps;
    }
    
    if (steps >= opt.max_steps) throw std::runtime_error("Max steps exceeded");
    return samples;
}

// ========== Physics Models ==========
class SimpleDrop {
    double m_, rho_, Cd_, A_, h_, cp_, T_env_;
    
public:
    SimpleDrop(double m, double rho, double Cd, double A, double h, double cp, double T_env)
        : m_(m), rho_(rho), Cd_(Cd), A_(A), h_(h), cp_(cp), T_env_(T_env) {}
    
    [[nodiscard]] DState operator()(double, const State& s) const noexcept {
        constexpr double g = 9.81;
        
        double v_mag = s.velocity.norm();
        double k = (rho_ * Cd_ * A_) / (2.0 * m_);
        Vec3 a_drag = (v_mag > 1e-12) ? s.velocity * (-k * v_mag) : Vec3{};
        Vec3 a = Vec3{0, 0, -g} + a_drag;
        
        double dT = -h_ * A_ * (s.temperature - T_env_) / (m_ * cp_);
        
        return DState{s.velocity, a, dT};
    }
};

} // namespace matlabcpp
