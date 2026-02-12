% BEAM_DEFLECTION_PUBLISH_DEMO.M
% Complete example showing publish() workflow
% This demonstrates the MATLAB experience: code + figures + report

%% Beam Deflection Analysis
% Professional structural analysis with automatic report generation
% 
% *Problem:* Simply supported beam with central point load
% 
% *Objective:* Calculate deflection and stress, generate PDF report

%% Section 1: Problem Setup
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║          BEAM DEFLECTION ANALYSIS                     ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

% Beam geometry
L = 5.0;            % Span length (m)
b = 0.2;            % Width (m)
h = 0.4;            % Height (m)

% Material properties
E = 200e9;          % Young's modulus (Pa) - Steel
sigma_y = 250e6;    % Yield strength (Pa)

% Loading
P = 50e3;           % Point load at center (N)
w = 10e3;           % Distributed load (N/m)

% Calculate section properties
I = (b * h^3) / 12; % Second moment of area (m^4)
S = (b * h^2) / 6;  % Section modulus (m^3)

fprintf('Beam Properties:\n');
fprintf('  Length:      %.2f m\n', L);
fprintf('  Width:       %.2f m\n', b);
fprintf('  Height:      %.2f m\n', h);
fprintf('  I:           %.2e m^4\n', I);
fprintf('  E:           %.0f GPa\n', E/1e9);
fprintf('\nLoading:\n');
fprintf('  Point load:  %.0f kN at center\n', P/1000);
fprintf('  Uniform:     %.0f kN/m\n\n', w/1000);

%% Section 2: Analytical Solution
% Position along beam
x = linspace(0, L, 200);

% Deflection from point load (Macaulay's method)
a = L/2;  % Load position (center)
delta_P = zeros(size(x));

for i = 1:length(x)
    if x(i) <= a
        delta_P(i) = (P * x(i) * (L^2 - x(i)^2 - (L-a)^2)) / (6*E*I*L);
    else
        x_val = x(i);
        delta_P(i) = (P * a * (3*L*x_val - 3*x_val^2 - a^2)) / (6*E*I);
    end
end

% Deflection from distributed load
delta_w = (w * x .* (L^3 - 2*L*x.^2 + x.^3)) / (24*E*I);

% Total deflection
delta_total = delta_P + delta_w;

% Maximum deflection
[delta_max, idx_max] = max(abs(delta_total));
x_max = x(idx_max);

fprintf('Deflection Results:\n');
fprintf('  Max deflection: %.2f mm at x = %.2f m\n', delta_max*1000, x_max);
fprintf('  L/delta ratio:  %.0f\n', L/delta_max);

if L/delta_max < 250
    fprintf('  ⚠ WARNING: Deflection exceeds L/250 limit\n');
else
    fprintf('  ✓ Deflection within L/250 limit\n');
end
fprintf('\n');

%% Section 3: Stress Analysis
% Bending moment from point load
M_P = zeros(size(x));
for i = 1:length(x)
    if x(i) <= a
        M_P(i) = (P/2) * x(i);
    else
        M_P(i) = (P/2) * (L - x(i));
    end
end

% Bending moment from distributed load
M_w = (w/2) * x .* (L - x);

% Total moment
M_total = M_P + M_w;

% Maximum stress (at extreme fiber, c = h/2)
c = h/2;
sigma = M_total * c / I;

[sigma_max, idx_sigma] = max(sigma);
x_sigma = x(idx_sigma);

fprintf('Stress Results:\n');
fprintf('  Max stress:     %.1f MPa at x = %.2f m\n', sigma_max/1e6, x_sigma);
fprintf('  Yield stress:   %.0f MPa\n', sigma_y/1e6);
fprintf('  Safety factor:  %.2f\n', sigma_y/sigma_max);

if sigma_max > sigma_y
    fprintf('  ⚠ FAILURE: Stress exceeds yield strength!\n');
elseif sigma_y/sigma_max < 1.5
    fprintf('  ⚠ WARNING: Insufficient safety factor\n');
else
    fprintf('  ✓ Design is safe\n');
end
fprintf('\n');

%% Section 4: Deflection Visualization
figure(1)
set(gcf, 'Position', [100, 100, 1200, 500]);

% Deflected shape
subplot(1, 2, 1)
plot(x, zeros(size(x)), 'k--', 'LineWidth', 1);
hold on
plot(x, delta_total*1000, 'b-', 'LineWidth', 2.5);
plot(x_max, delta_max*1000, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot([a a], [0 -5], 'rv', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
grid on
xlabel('Position along beam (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Deflection (mm)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Beam Deflection Profile', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Undeflected', 'Deflected shape', 'Maximum', 'Applied load', ...
       'Location', 'south', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
ylim([min(delta_total*1000)*1.2, 2]);

% Deflection components
subplot(1, 2, 2)
plot(x, delta_P*1000, 'r-', 'LineWidth', 2);
hold on
plot(x, delta_w*1000, 'g-', 'LineWidth', 2);
plot(x, delta_total*1000, 'b-', 'LineWidth', 2.5);
grid on
xlabel('Position along beam (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Deflection (mm)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Deflection Components', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Point load', 'Distributed load', 'Total', ...
       'Location', 'south', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% Section 5: Stress Visualization
figure(2)
set(gcf, 'Position', [100, 100, 1200, 500]);

% Bending moment diagram
subplot(1, 2, 1)
plot(x, M_total/1000, 'b-', 'LineWidth', 2.5);
hold on
plot(x_sigma, M_total(idx_sigma)/1000, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot([0 L], [0 0], 'k--', 'LineWidth', 1);
grid on
xlabel('Position along beam (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Bending Moment (kN·m)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Bending Moment Diagram', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Moment', 'Maximum', 'Location', 'north', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

% Stress distribution
subplot(1, 2, 2)
plot(x, sigma/1e6, 'r-', 'LineWidth', 2.5);
hold on
plot(x_sigma, sigma_max/1e6, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot([0 L], [sigma_y/1e6 sigma_y/1e6], 'k--', 'LineWidth', 2);
grid on
xlabel('Position along beam (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Bending Stress (MPa)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Stress Distribution', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Stress', 'Maximum', 'Yield strength', ...
       'Location', 'north', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% Section 6: Design Summary
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║              DESIGN SUMMARY                           ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

fprintf('Beam: %.1fx%.1f m section, L=%.1f m\n', b, h, L);
fprintf('Material: Steel (E=%.0f GPa, σ_y=%.0f MPa)\n\n', E/1e9, sigma_y/1e6);

fprintf('Loading:\n');
fprintf('  Point:       %.0f kN at center\n', P/1000);
fprintf('  Distributed: %.0f kN/m\n\n', w/1000);

fprintf('Results:\n');
fprintf('  δ_max = %.2f mm (%.1f%% of L/250 limit)\n', ...
        delta_max*1000, delta_max/(L/250)*100);
fprintf('  σ_max = %.1f MPa (%.1f%% of yield)\n', ...
        sigma_max/1e6, sigma_max/sigma_y*100);
fprintf('  SF    = %.2f\n\n', sigma_y/sigma_max);

if sigma_max < sigma_y/1.5 && delta_max < L/250
    fprintf('✓ DESIGN ACCEPTABLE\n');
    fprintf('  - Stress within limits\n');
    fprintf('  - Deflection within limits\n');
elseif sigma_max >= sigma_y
    fprintf('✗ DESIGN REJECTED - Stress failure\n');
elseif sigma_y/sigma_max < 1.5
    fprintf('⚠ MARGINAL - Low safety factor\n');
elseif delta_max >= L/250
    fprintf('⚠ MARGINAL - Excessive deflection\n');
end

fprintf('\n');

%% Section 7: Generate PDF Report
% Publish this file to PDF
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║              GENERATING PDF REPORT                    ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

fprintf('To generate PDF report, run:\n');
fprintf('  publish(''beam_deflection_publish_demo.m'', ''pdf'')\n\n');

fprintf('Report will contain:\n');
fprintf('  ✓ This code with syntax highlighting\n');
fprintf('  ✓ All console output (fprintf)\n');
fprintf('  ✓ Figure 1: Deflection plots (2 subplots)\n');
fprintf('  ✓ Figure 2: Stress plots (2 subplots)\n');
fprintf('  ✓ Professional formatting\n');
fprintf('  ✓ Section headers\n\n');

fprintf('Output file: beam_deflection_publish_demo.pdf\n\n');

%% THE END
% This demonstrates the complete MATLAB workflow:
%   1. Write analysis script with sections (%%)
%   2. Execute to see results in console
%   3. View figures interactively
%   4. Publish to PDF for sharing/archiving
%
% publish() is what makes MATLAB special for scientific computing!
