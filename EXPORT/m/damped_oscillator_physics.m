% DAMPED_OSCILLATOR_PHYSICS.M - Advanced Harmonic Motion Analysis
% Multiple damping regimes, phase space, energy decay
% 6 subplots with publication-quality formatting

clear all
close all
clc

fprintf('\n╔════════════════════════════════════════════════════════╗\n');
fprintf('║        DAMPED HARMONIC OSCILLATOR ANALYSIS            ║\n');
fprintf('║      Underdamped, Critical, Overdamped Regimes        ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

%% ========== SYSTEM PARAMETERS ==========
fprintf('Setting up oscillator parameters...\n');

% Physical parameters
m = 1.0;            % Mass (kg)
k = 100;            % Spring constant (N/m)
omega0 = sqrt(k/m); % Natural frequency (rad/s)

% Damping coefficients for different regimes
c_under = 5;        % Underdamped: c < 2*sqrt(k*m)
c_crit = 2*sqrt(k*m); % Critical damping
c_over = 30;        % Overdamped: c > 2*sqrt(k*m)

% Initial conditions
x0 = 1.0;           % Initial displacement (m)
v0 = 0.0;           % Initial velocity (m/s)

% Time parameters
t = linspace(0, 5, 1000);

fprintf('  Mass:                 %.2f kg\n', m);
fprintf('  Spring constant:      %.1f N/m\n', k);
fprintf('  Natural frequency:    %.2f rad/s\n', omega0);
fprintf('  Underdamped c:        %.2f\n', c_under);
fprintf('  Critical c:           %.2f\n', c_crit);
fprintf('  Overdamped c:         %.2f\n', c_over);
fprintf('\n');

%% ========== SOLVE EQUATIONS OF MOTION ==========
fprintf('Computing solutions for three damping regimes...\n');

% UNDERDAMPED
gamma_under = c_under / (2*m);
omega_d = sqrt(omega0^2 - gamma_under^2);
A_under = x0;
B_under = (v0 + gamma_under*x0) / omega_d;
x_under = exp(-gamma_under*t) .* (A_under*cos(omega_d*t) + B_under*sin(omega_d*t));
v_under = exp(-gamma_under*t) .* ...
          ((-gamma_under*A_under + omega_d*B_under)*cos(omega_d*t) + ...
           (-gamma_under*B_under - omega_d*A_under)*sin(omega_d*t));

% CRITICAL DAMPING
gamma_crit = c_crit / (2*m);
x_crit = (x0 + (v0 + gamma_crit*x0)*t) .* exp(-gamma_crit*t);
v_crit = ((v0 + gamma_crit*x0) - gamma_crit*(x0 + (v0 + gamma_crit*x0)*t)) .* exp(-gamma_crit*t);

% OVERDAMPED
gamma_over = c_over / (2*m);
omega_over = sqrt(gamma_over^2 - omega0^2);
r1 = -gamma_over + omega_over;
r2 = -gamma_over - omega_over;
C1 = (v0 - r2*x0) / (r1 - r2);
C2 = (r1*x0 - v0) / (r1 - r2);
x_over = C1*exp(r1*t) + C2*exp(r2*t);
v_over = C1*r1*exp(r1*t) + C2*r2*exp(r2*t);

fprintf('  ✓ Underdamped solution computed\n');
fprintf('  ✓ Critical damping solution computed\n');
fprintf('  ✓ Overdamped solution computed\n');
fprintf('\n');

%% ========== ENERGY CALCULATIONS ==========
% Total mechanical energy for each case
E_under = 0.5*m*v_under.^2 + 0.5*k*x_under.^2;
E_crit = 0.5*m*v_crit.^2 + 0.5*k*x_crit.^2;
E_over = 0.5*m*v_over.^2 + 0.5*k*x_over.^2;
E0 = 0.5*k*x0^2 + 0.5*m*v0^2;

%% ========== CREATE FIGURE WITH 6 SUBPLOTS ==========
fprintf('Generating publication-quality graphs...\n\n');

figure('Position', [50, 50, 1600, 1000]);
set(gcf, 'Color', 'w');

%% SUBPLOT 1: POSITION vs TIME (All three cases)
subplot(2, 3, 1)
plot(t, x_under, 'b-', 'LineWidth', 2);
hold on
plot(t, x_crit, 'r-', 'LineWidth', 2);
plot(t, x_over, 'g-', 'LineWidth', 2);
plot([0, max(t)], [0, 0], 'k--', 'LineWidth', 1);
grid on
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Position (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Position vs Time: Damping Comparison', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Underdamped', 'Critical', 'Overdamped', 'Equilibrium', ...
       'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 2: VELOCITY vs TIME
subplot(2, 3, 2)
plot(t, v_under, 'b-', 'LineWidth', 2);
hold on
plot(t, v_crit, 'r-', 'LineWidth', 2);
plot(t, v_over, 'g-', 'LineWidth', 2);
plot([0, max(t)], [0, 0], 'k--', 'LineWidth', 1);
grid on
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Velocity (m/s)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Velocity vs Time', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Underdamped', 'Critical', 'Overdamped', ...
       'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 3: PHASE SPACE (Position vs Velocity)
subplot(2, 3, 3)
plot(x_under, v_under, 'b-', 'LineWidth', 2);
hold on
plot(x_crit, v_crit, 'r-', 'LineWidth', 2);
plot(x_over, v_over, 'g-', 'LineWidth', 2);
plot(x0, v0, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
plot(0, 0, 'k*', 'MarkerSize', 12);
grid on
xlabel('Position (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Velocity (m/s)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Phase Space Portrait', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Underdamped', 'Critical', 'Overdamped', 'Initial', 'Equilibrium', ...
       'Location', 'best', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 4: ENERGY vs TIME
subplot(2, 3, 4)
plot(t, E_under/E0, 'b-', 'LineWidth', 2);
hold on
plot(t, E_crit/E0, 'r-', 'LineWidth', 2);
plot(t, E_over/E0, 'g-', 'LineWidth', 2);
grid on
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Normalized Energy E/E_0', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Energy Dissipation', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Underdamped', 'Critical', 'Overdamped', ...
       'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 5: ENVELOPE DECAY (Underdamped only)
subplot(2, 3, 5)
envelope = x0 * exp(-gamma_under*t);
plot(t, x_under, 'b-', 'LineWidth', 1.5);
hold on
plot(t, envelope, 'r--', 'LineWidth', 2);
plot(t, -envelope, 'r--', 'LineWidth', 2);
grid on
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Position (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Underdamped: Exponential Envelope', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Oscillation', 'Envelope: x_0 e^{-\gammat}', ...
       'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 6: FORCE ANALYSIS (Underdamped)
F_spring = -k * x_under;
F_damping = -c_under * v_under;
F_total = F_spring + F_damping;
F_accel = m * gradient(v_under, t(2)-t(1));

subplot(2, 3, 6)
plot(t, F_spring, 'b-', 'LineWidth', 2);
hold on
plot(t, F_damping, 'r-', 'LineWidth', 2);
plot(t, F_total, 'k--', 'LineWidth', 2);
plot([0, max(t)], [0, 0], 'k:', 'LineWidth', 1);
grid on
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Force (N)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Force Components (Underdamped)', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Spring Force', 'Damping Force', 'Total Force', ...
       'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% ========== ADD MAIN TITLE ==========
sgtitle('Damped Harmonic Oscillator: Complete Analysis', ...
        'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');

%% ========== SAVE FIGURE ==========
fprintf('Saving figures...\n');
print('damped_oscillator_analysis', '-dpng', '-r300');
savefig('damped_oscillator_analysis.fig');

fprintf('  Saved: damped_oscillator_analysis.png (300 DPI)\n');
fprintf('  Saved: damped_oscillator_analysis.fig\n');
fprintf('\n');

%% ========== NUMERICAL RESULTS ==========
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║              NUMERICAL RESULTS                        ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

% Find time to 1% of initial amplitude
idx_under = find(abs(x_under) < 0.01*x0, 1);
idx_crit = find(abs(x_crit) < 0.01*x0, 1);
idx_over = find(abs(x_over) < 0.01*x0, 1);

fprintf('Underdamped (ζ = %.3f):\n', gamma_under/omega0);
fprintf('  Damped frequency: %.2f rad/s\n', omega_d);
fprintf('  Period:           %.3f s\n', 2*pi/omega_d);
fprintf('  Time to 1%% amp:   %.3f s\n', t(idx_under));
fprintf('  Energy at 5s:     %.2f%% of E0\n', 100*E_under(end)/E0);
fprintf('\n');

fprintf('Critical Damping (ζ = %.3f):\n', gamma_crit/omega0);
fprintf('  Time to 1%% amp:   %.3f s\n', t(idx_crit));
fprintf('  Energy at 5s:     %.2f%% of E0\n', 100*E_crit(end)/E0);
fprintf('\n');

fprintf('Overdamped (ζ = %.3f):\n', gamma_over/omega0);
fprintf('  Time to 1%% amp:   %.3f s\n', t(idx_over));
fprintf('  Energy at 5s:     %.2f%% of E0\n', 100*E_over(end)/E0);
fprintf('\n');

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║            SIMULATION COMPLETE                        ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

fprintf('Display: 6 graphs showing complete damped oscillator physics\n');
fprintf('Features: Professional fonts, grids, legends, phase space\n');
fprintf('Physics: Energy dissipation, exponential decay, force analysis\n\n');
