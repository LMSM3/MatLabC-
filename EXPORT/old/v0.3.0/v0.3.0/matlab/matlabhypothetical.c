/*
 * matlabhypothetical.c (production diagnostics)
 * Numerical accuracy + round-off detection with optional verbose detail.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>
#include <time.h>
#include <string.h>

typedef enum {
    PRECISION_FLOAT,
    PRECISION_DOUBLE,
    PRECISION_LONG_DOUBLE
} PrecisionLevel;

typedef struct {
    PrecisionLevel level;
    double error_threshold;
    size_t storage_bytes;
    const char* name;
} PrecisionConfig;

static const PrecisionConfig precision_configs[] = {
    {PRECISION_FLOAT,       1e-6,  sizeof(float),       "float"},
    {PRECISION_DOUBLE,      1e-14, sizeof(double),      "double"},
    {PRECISION_LONG_DOUBLE, 1e-18, sizeof(long double), "long double"}
};

// ---------------- Summation ----------------
static double sum_double(int n, double inc) {
    double sum = 0.0;
    for(int i = 0; i < n; i++) sum += inc;
    return sum;
}

static float sum_float(int n, float inc) {
    float sum = 0.0f;
    for(int i = 0; i < n; i++) sum += inc;
    return sum;
}

static long double sum_long(int n, long double inc) {
    long double sum = 0.0L;
    for(int i = 0; i < n; i++) sum += inc;
    return sum;
}

// ---------------- Cancellation ----------------
static double cancellation_double(double x) {
    return (x + 1e-15) - x;
}

// ---------------- Matrix Multiplication ----------------
typedef struct { double* data; int rows; int cols; } Matrix;

static Matrix create_matrix(int rows, int cols) {
    Matrix m = {calloc(rows * cols, sizeof(double)), rows, cols};
    return m;
}

static void free_matrix(Matrix* m) { free(m->data); }

static void matmul_naive(Matrix* A, Matrix* B, Matrix* C) {
    for(int i = 0; i < A->rows; i++) {
        for(int j = 0; j < B->cols; j++) {
            double sum = 0.0;
            for(int k = 0; k < A->cols; k++) {
                sum += A->data[i * A->cols + k] * B->data[k * B->cols + j];
            }
            C->data[i * C->cols + j] = sum;
        }
    }
}

static void matmul_kahan(Matrix* A, Matrix* B, Matrix* C) {
    for(int i = 0; i < A->rows; i++) {
        for(int j = 0; j < B->cols; j++) {
            double sum = 0.0, c = 0.0;
            for(int k = 0; k < A->cols; k++) {
                double prod = A->data[i * A->cols + k] * B->data[k * B->cols + j];
                double y = prod - c;
                double t = sum + y;
                c = (t - sum) - y;
                sum = t;
            }
            C->data[i * C->cols + j] = sum;
        }
    }
}

// ---------------- ODE ----------------
static double ode_euler(double (*f)(double, double), double y0, double t0, double tf, int steps) {
    double y = y0, t = t0, h = (tf - t0) / steps;
    for(int i = 0; i < steps; i++) { y += h * f(t, y); t += h; }
    return y;
}

static double ode_rk4(double (*f)(double, double), double y0, double t0, double tf, int steps) {
    double y = y0, t = t0, h = (tf - t0) / steps;
    for(int i = 0; i < steps; i++) {
        double k1 = f(t, y);
        double k2 = f(t + h/2, y + h*k1/2);
        double k3 = f(t + h/2, y + h*k2/2);
        double k4 = f(t + h, y + h*k3);
        y += h/6 * (k1 + 2*k2 + 2*k3 + k4);
        t += h;
    }
    return y;
}

static double test_ode(double t, double y) { (void)t; return -y; }

// ---------------- Error Analysis ----------------
typedef struct {
    double relative_error;
    double absolute_error;
    int exceeded_threshold;
    PrecisionLevel recommended_level;
} ErrorAnalysis;

static ErrorAnalysis detect_error(double computed, double expected, PrecisionLevel level) {
    ErrorAnalysis a;
    a.absolute_error = fabs(computed - expected);
    a.relative_error = fabs((computed - expected) / expected);
    const PrecisionConfig* cfg = &precision_configs[level];
    a.exceeded_threshold = a.relative_error > cfg->error_threshold;
    a.recommended_level = a.exceeded_threshold && level < PRECISION_LONG_DOUBLE ? (level + 1) : level;
    return a;
}

// ---------------- Animation ----------------
static void spinner_tick(int step) {
    static const char frames[] = {'|', '/', '-', '\\'};
    fputc('\r', stdout);
    fputc(frames[step % 4], stdout);
    fputs(" running diagnostics...", stdout);
    fflush(stdout);
}

static void sleep_brief() { struct timespec ts = {0, 10000000}; nanosleep(&ts, NULL); }

static void maybe_spin(int animate, int step) { if(animate) { spinner_tick(step); sleep_brief(); } }

static void diagnostics_summary(int verbose, int animate) {
    const int n = 1000000;
    const double inc = 1e-10;
    const double expected_sum = n * inc;

    maybe_spin(animate, 0);
    float sf = sum_float(n, (float)inc);
    double sd = sum_double(n, inc);
    long double sld = sum_long(n, (long double)inc);

    ErrorAnalysis ef = detect_error(sf, expected_sum, PRECISION_FLOAT);
    ErrorAnalysis ed = detect_error(sd, expected_sum, PRECISION_DOUBLE);

    printf("\n[Summation] target=%.10f\n", expected_sum);
    printf("  float : error=%.2e%s\n", ef.relative_error, ef.exceeded_threshold ? " ↑" : "");
    printf("  double: error=%.2e\n", ed.relative_error);
    printf("  long  : error=%.2Le\n", fabsl(sld - expected_sum) / expected_sum);

    maybe_spin(animate, 1);
    double cancel = cancellation_double(1.0);
    printf("[Cancellation] (1+1e-15)-1 = %.3e (expected 1e-15)\n", cancel);

    Matrix A = create_matrix(64, 64), B = create_matrix(64, 64), Cn = create_matrix(64, 64), Ck = create_matrix(64, 64);
    for(int i = 0; i < 64*64; i++) { A.data[i] = 1e-8; B.data[i] = 1e-8; }
    clock_t tn0 = clock(); matmul_naive(&A, &B, &Cn); clock_t tn1 = clock();
    maybe_spin(animate, 2);
    clock_t tk0 = clock(); matmul_kahan(&A, &B, &Ck); clock_t tk1 = clock();
    double max_diff = 0.0; for(int i = 0; i < 64*64; i++) { double d = fabs(Cn.data[i] - Ck.data[i]); if(d > max_diff) max_diff = d; }
    printf("[Matmul] Kahan vs naive: max diff=%.2e, overhead=%.1f%%\n", max_diff,
           100.0 * (double)(tk1 - tk0 - (tn1 - tn0)) / (double)(tn1 - tn0));
    free_matrix(&A); free_matrix(&B); free_matrix(&Cn); free_matrix(&Ck);

    maybe_spin(animate, 3);
    const double exact = exp(-10.0);
    double euler = ode_euler(test_ode, 1.0, 0.0, 10.0, 1000);
    double rk4 = ode_rk4(test_ode, 1.0, 0.0, 10.0, 1000);
    printf("[ODE] Euler err=%.2e, RK4 err=%.2e\n", fabs(euler - exact), fabs(rk4 - exact));

    if(verbose) {
        maybe_spin(animate, 4);
        printf("[Perf vs Accuracy]\n");
        for(int lvl = PRECISION_FLOAT; lvl <= PRECISION_LONG_DOUBLE; lvl++) {
            clock_t t0 = clock();
            double err = 0.0;
            if(lvl == PRECISION_FLOAT) err = fabs(sum_float(n, (float)inc) - expected_sum);
            else if(lvl == PRECISION_DOUBLE) err = fabs(sum_double(n, inc) - expected_sum);
            else err = fabsl(sum_long(n, (long double)inc) - expected_sum);
            clock_t t1 = clock();
            double ms = 1000.0 * (t1 - t0) / CLOCKS_PER_SEC;
            printf("  %-11s time=%7.3f ms err=%11.2e mem=%zu bytes\n", precision_configs[lvl].name, ms, err, precision_configs[lvl].storage_bytes);
        }
    }
    if(animate) { fputc('\n', stdout); }
}

// ---------------- CLI ----------------
static void usage(const char* exe) {
    printf("Usage: %s [--verbose] [--animate]\n", exe);
    printf("  --verbose  Show detailed performance table\n");
    printf("  --animate  Show spinner while running tests\n");
}

int main(int argc, char* argv[]) {
    int verbose = 0, animate = 0;
    for(int i = 1; i < argc; i++) {
        if(strcmp(argv[i], "--verbose") == 0) verbose = 1;
        else if(strcmp(argv[i], "--animate") == 0) animate = 1;
        else { usage(argv[0]); return 1; }
    }

    printf("MatLabC++ Numerical Accuracy Diagnostics (production)\n");
    diagnostics_summary(verbose, animate);
    printf("\nRecommendation: use double by default; enable adaptive or long double when relative error > 1e-14.\n");
    return 0;
}
