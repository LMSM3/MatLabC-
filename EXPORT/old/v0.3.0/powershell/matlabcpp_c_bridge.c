/*
 * MatLabC++ C Bridge for P/Invoke
 * Exposes C-compatible API for .NET interop
 * 
 * Build: gcc -shared -fPIC -O2 -o libmatlabcpp_c_bridge.so matlabcpp_c_bridge.c -I../include -lm
 *        cl /LD /O2 matlabcpp_c_bridge.c /I..\include (Windows)
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

#ifdef _WIN32
    #define EXPORT __declspec(dllexport)
#else
    #define EXPORT __attribute__((visibility("default")))
#endif

// Material data structure (C-compatible)
typedef struct {
    char name[64];
    double density;              // kg/m³
    double youngs_modulus;       // Pa
    double yield_strength;       // Pa
    double thermal_conductivity; // W/(m·K)
    double specific_heat;        // J/(kg·K)
    double melting_point;        // K
} MaterialResult;

// Integration sample
typedef struct {
    double time;
    double position_x;
    double position_y;
    double position_z;
    double velocity_z;
} IntegrationSample;

// Simple material database (hardcoded for demo)
static const MaterialResult materials[] = {
    {
        .name = "aluminum_6061",
        .density = 2700,
        .youngs_modulus = 69e9,
        .yield_strength = 276e6,
        .thermal_conductivity = 167,
        .specific_heat = 896,
        .melting_point = 855 + 273.15
    },
    {
        .name = "steel",
        .density = 7850,
        .youngs_modulus = 200e9,
        .yield_strength = 250e6,
        .thermal_conductivity = 50,
        .specific_heat = 490,
        .melting_point = 1673 + 273.15
    },
    {
        .name = "peek",
        .density = 1320,
        .youngs_modulus = 3.6e9,
        .yield_strength = 90e6,
        .thermal_conductivity = 0.25,
        .specific_heat = 1340,
        .melting_point = 616
    },
    {
        .name = "pla",
        .density = 1240,
        .youngs_modulus = 3.5e9,
        .yield_strength = 50e6,
        .thermal_conductivity = 0.13,
        .specific_heat = 1800,
        .melting_point = 433
    }
};

static const int material_count = sizeof(materials) / sizeof(materials[0]);

// Physical constants
typedef struct {
    const char* name;
    double value;
} Constant;

static const Constant constants[] = {
    { "g", 9.80665 },
    { "G", 6.67430e-11 },
    { "c", 299792458 },
    { "h", 6.62607015e-34 },
    { "k_B", 1.380649e-23 },
    { "N_A", 6.02214076e23 },
    { "R", 8.314462618 },
    { "pi", 3.14159265358979323846 },
    { "e", 2.71828182845904523536 }
};

static const int constant_count = sizeof(constants) / sizeof(constants[0]);

// ========== Material Functions ==========

EXPORT MaterialResult* get_material_by_name(const char* name) {
    for (int i = 0; i < material_count; i++) {
        if (strcmp(materials[i].name, name) == 0) {
            MaterialResult* result = (MaterialResult*)malloc(sizeof(MaterialResult));
            memcpy(result, &materials[i], sizeof(MaterialResult));
            return result;
        }
    }
    return NULL;
}

EXPORT MaterialResult* identify_material_by_density(double density, double tolerance) {
    for (int i = 0; i < material_count; i++) {
        if (fabs(materials[i].density - density) <= tolerance) {
            MaterialResult* result = (MaterialResult*)malloc(sizeof(MaterialResult));
            memcpy(result, &materials[i], sizeof(MaterialResult));
            return result;
        }
    }
    return NULL;
}

EXPORT void free_material_result(MaterialResult* ptr) {
    free(ptr);
}

// ========== Constant Functions ==========

EXPORT double get_constant_by_name(const char* name) {
    for (int i = 0; i < constant_count; i++) {
        if (strcmp(constants[i].name, name) == 0) {
            return constants[i].value;
        }
    }
    return 0.0; // Not found
}

EXPORT int constant_exists(const char* name) {
    for (int i = 0; i < constant_count; i++) {
        if (strcmp(constants[i].name, name) == 0) {
            return 1;
        }
    }
    return 0;
}

// ========== ODE Integration ==========

EXPORT IntegrationSample* integrate_simple_drop(
    double height,
    double mass,
    double drag_coefficient,
    int* sample_count
) {
    const double g = 9.80665;
    const double rho_air = 1.225;
    const double radius = 0.01; // 1 cm sphere
    const double area = 3.14159265358979 * radius * radius;
    const double dt = 0.01; // 10 ms timestep
    
    // Estimate sample count
    double t_fall = sqrt(2 * height / g) * 1.5; // rough estimate with safety
    int max_samples = (int)(t_fall / dt) + 100;
    
    IntegrationSample* samples = (IntegrationSample*)malloc(
        max_samples * sizeof(IntegrationSample)
    );
    
    // Initial conditions
    double z = height;
    double vz = 0.0;
    double t = 0.0;
    int count = 0;
    
    // Euler integration
    while (z > 0 && count < max_samples) {
        // Record sample
        samples[count].time = t;
        samples[count].position_x = 0;
        samples[count].position_y = 0;
        samples[count].position_z = z;
        samples[count].velocity_z = vz;
        count++;
        
        // Drag force: F_drag = 0.5 * rho * v^2 * Cd * A
        double drag = 0.5 * rho_air * vz * fabs(vz) * drag_coefficient * area;
        double sign = (vz < 0) ? -1 : 1;
        
        // Net acceleration: a = g - (F_drag / m)
        double az = -g + sign * drag / mass;
        
        // Update
        vz += az * dt;
        z += vz * dt;
        t += dt;
    }
    
    *sample_count = count;
    return samples;
}

EXPORT void free_integration_result(IntegrationSample* ptr) {
    free(ptr);
}

// ========== Matrix Operations ==========

EXPORT double* matrix_multiply(
    const double* A, int rows_A, int cols_A,
    const double* B, int rows_B, int cols_B,
    int* rows_out, int* cols_out
) {
    if (cols_A != rows_B) {
        return NULL; // Dimension mismatch
    }
    
    int rows = rows_A;
    int cols = cols_B;
    int k = cols_A;
    
    double* C = (double*)calloc(rows * cols, sizeof(double));
    
    // Matrix multiply: C = A * B
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            double sum = 0;
            for (int p = 0; p < k; p++) {
                sum += A[i * cols_A + p] * B[p * cols_B + j];
            }
            C[i * cols + j] = sum;
        }
    }
    
    *rows_out = rows;
    *cols_out = cols;
    return C;
}

EXPORT double* solve_linear_system(
    const double* A_in, int n,
    const double* b_in,
    int* success
) {
    // LU decomposition with partial pivoting
    // Allocate working copies
    double* A = (double*)malloc(n * n * sizeof(double));
    double* b = (double*)malloc(n * sizeof(double));
    memcpy(A, A_in, n * n * sizeof(double));
    memcpy(b, b_in, n * sizeof(double));
    
    int* piv = (int*)malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) piv[i] = i;
    
    // Forward elimination with partial pivoting
    for (int k = 0; k < n - 1; k++) {
        // Find pivot
        int pivot = k;
        double max_val = fabs(A[piv[k] * n + k]);
        for (int i = k + 1; i < n; i++) {
            double val = fabs(A[piv[i] * n + k]);
            if (val > max_val) {
                max_val = val;
                pivot = i;
            }
        }
        
        // Swap pivot rows
        if (pivot != k) {
            int tmp = piv[k];
            piv[k] = piv[pivot];
            piv[pivot] = tmp;
        }
        
        // Eliminate
        for (int i = k + 1; i < n; i++) {
            double factor = A[piv[i] * n + k] / A[piv[k] * n + k];
            for (int j = k; j < n; j++) {
                A[piv[i] * n + j] -= factor * A[piv[k] * n + j];
            }
            b[piv[i]] -= factor * b[piv[k]];
        }
    }
    
    // Back substitution
    double* x = (double*)malloc(n * sizeof(double));
    for (int i = n - 1; i >= 0; i--) {
        double sum = b[piv[i]];
        for (int j = i + 1; j < n; j++) {
            sum -= A[piv[i] * n + j] * x[j];
        }
        x[i] = sum / A[piv[i] * n + i];
    }
    
    free(A);
    free(b);
    free(piv);
    
    *success = 1;
    return x;
}

EXPORT void free_matrix(double* ptr) {
    free(ptr);
}

// ========== Initialization ==========

EXPORT void initialize_library() {
    // No-op for now, but could initialize global state
}

EXPORT const char* get_version() {
    return "0.3.0";
}
