% engineering_report_demo.m
% Demonstrates engineering-style plotting with proper formatting
%
% Run with: mlab++ engineering_report_demo.m --visual --theme engineering

disp('MatLabC++ Engineering Report Demo');
disp('==================================');
disp('');

% ========== STRESS-STRAIN COMPARISON ==========
disp('1. Generating Stress-Strain Plot');
disp('---------------------------------');

% Material properties
strain = linspace(0, 5, 100);  % Strain in %

% Aluminum 6061-T6: E = 68.9 GPa, yield = 276 MPa
E_al = 68.9e9;  % Pa
stress_al = E_al * (strain / 100);  % Convert to Pa
stress_al_MPa = stress_al / 1e6;    % Convert to MPa

% Steel 316L: E = 200 GPa, yield = 290 MPa
E_st = 200e9;
stress_st = E_st * (strain / 100);
stress_st_MPa = stress_st / 1e6;

% PEEK polymer: E = 3.6 GPa, yield = 90 MPa
E_peek = 3.6e9;
stress_peek = E_peek * (strain / 100);
stress_peek_MPa = stress_peek / 1e6;

% Create figure with engineering theme
figure('Position', [100, 100, 1000, 750]);
set(gcf, 'Theme', 'engineering');
set(gcf, 'Color', 'white');

% Plot data
plot(strain, stress_al_MPa, 'LineWidth', 2, 'Color', '#0072BD', ...
     'Marker', 'o', 'MarkerSize', 8, 'MarkerIndices', 1:10:100);
hold on;
plot(strain, stress_st_MPa, 'LineWidth', 2, 'Color', '#D95319', ...
     'Marker', 's', 'MarkerSize', 8, 'MarkerIndices', 1:10:100);
plot(strain, stress_peek_MPa, 'LineWidth', 2, 'Color', '#77AC30', ...
     'Marker', '^', 'MarkerSize', 8, 'MarkerIndices', 1:10:100);

% Labels with units (engineering requirement)
xlabel('Strain (\epsilon) [%]', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Stress (\sigma) [MPa]', 'FontSize', 12, 'FontWeight', 'bold');
title('Material Stress-Strain Comparison', 'FontSize', 14, 'FontWeight', 'bold');

% Legend
legend('Aluminum 6061-T6 (E=68.9 GPa)', ...
       'Steel 316L (E=200 GPa)', ...
       'PEEK (E=3.6 GPa)', ...
       'Location', 'northwest', 'FontSize', 11);

% Grid
grid on;
grid minor;
box on;

% Set axes properties
set(gca, 'FontSize', 11);
set(gca, 'LineWidth', 1.5);
xlim([0, 5]);
ylim([0, 400]);

% Annotations
text(2.5, 300, 'Linear elastic region', ...
     'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
annotation('arrow', [0.4, 0.5], [0.7, 0.65]);

% Export high-DPI for publication
fprintf('Exporting stress_strain.png (300 DPI)...\n');
exportgraphics(gcf, 'stress_strain.png', 'Resolution', 300);
exportgraphics(gcf, 'stress_strain.pdf', 'ContentType', 'vector');

disp('✓ Stress-strain plot exported');
disp('  • stress_strain.png (300 DPI raster)');
disp('  • stress_strain.pdf (vector, publication quality)');
disp('');

% ========== TEMPERATURE DISTRIBUTION (3D) ==========
disp('2. Generating 3D Temperature Distribution');
disp('------------------------------------------');

% Heat conduction simulation results
[X, Y] = meshgrid(0:0.5:20, 0:0.5:20);

% Temperature field (heat source at center)
R = sqrt((X - 10).^2 + (Y - 10).^2);
T = 100 * exp(-R.^2 / 25) + 20;  % Temperature in °C

% Create 3D figure
figure('Position', [150, 150, 1000, 800]);
set(gcf, 'Theme', 'engineering');

% Surface plot
surf(X, Y, T);

% Labels with units
xlabel('X Position [mm]', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Y Position [mm]', 'FontSize', 12, 'FontWeight', 'bold');
zlabel('Temperature [°C]', 'FontSize', 12, 'FontWeight', 'bold');
title('Steady-State Temperature Distribution', 'FontSize', 14, 'FontWeight', 'bold');

% Colormap and colorbar
colormap('jet');
c = colorbar;
c.Label.String = 'Temperature [°C]';
c.Label.FontSize = 11;
c.Label.FontWeight = 'bold';

% 3D view settings (engineering requirement)
view(45, 30);
camlight('headlight');
lighting gouraud;
shading interp;
axis equal;
axis tight;

% Grid
grid on;
set(gca, 'FontSize', 11);
set(gca, 'LineWidth', 1.5);

% Export
fprintf('Exporting temperature_dist_3d.png (300 DPI)...\n');
exportgraphics(gcf, 'temperature_dist_3d.png', 'Resolution', 300);

disp('✓ 3D temperature distribution exported');
disp('');

% ========== MULTI-PANEL COMPARISON ==========
disp('3. Generating Multi-Panel Comparison');
disp('-------------------------------------');

figure('Position', [200, 200, 1400, 900]);
set(gcf, 'Theme', 'engineering');

% Tiled layout
tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

% Panel 1: Stress-Strain
nexttile;
plot(strain, stress_al_MPa, 'LineWidth', 2);
xlabel('Strain [%]');
ylabel('Stress [MPa]');
title('(a) Aluminum 6061-T6');
grid on;
grid minor;

% Panel 2: Fatigue Life
nexttile;
cycles = logspace(3, 7, 50);
stress_range = 400 * (cycles / 1e6).^(-0.1);
loglog(cycles, stress_range, 'LineWidth', 2, 'Color', '#D95319');
xlabel('Cycles to Failure [N]');
ylabel('Stress Range [\Delta\sigma, MPa]');
title('(b) S-N Curve (Fatigue)');
grid on;

% Panel 3: Temperature vs Strength
nexttile;
temp = linspace(20, 200, 50);
strength_ratio = 1 - 0.002 * (temp - 20);
plot(temp, strength_ratio * 276, 'LineWidth', 2, 'Color', '#77AC30');
xlabel('Temperature [°C]');
ylabel('Yield Strength [MPa]');
title('(c) Temperature Dependence');
grid on;
grid minor;

% Panel 4: Safety Factor vs Load
nexttile;
load_ratio = linspace(0, 1, 50);
safety_factor = 276 ./ (load_ratio * 276 + 1e-6);
plot(load_ratio * 100, safety_factor, 'LineWidth', 2, 'Color', '#A2142F');
xlabel('Load [% of Yield]');
ylabel('Safety Factor');
title('(d) Design Safety Margin');
grid on;
ylim([0, 10]);
hold on;
plot([0, 100], [2, 2], 'k--', 'LineWidth', 1.5);
text(50, 2.5, 'Minimum SF = 2.0', 'FontSize', 10);

% Export multi-panel
fprintf('Exporting engineering_report.png (300 DPI)...\n');
exportgraphics(gcf, 'engineering_report.png', 'Resolution', 300);

disp('✓ Multi-panel engineering report exported');
disp('');

% ========== SUMMARY ==========
disp('Engineering Report Demo Complete');
disp('================================');
disp('');
disp('Generated files:');
disp('  1. stress_strain.png (300 DPI)');
disp('  2. stress_strain.pdf (vector)');
disp('  3. temperature_dist_3d.png (300 DPI)');
disp('  4. engineering_report.png (300 DPI)');
disp('');
disp('Engineering theme features used:');
disp('  ✓ Bold axis labels with units');
disp('  ✓ 300 DPI export (publication quality)');
disp('  ✓ Grid with minor ticks');
disp('  ✓ Proper legend placement');
disp('  ✓ 3D lighting and camera setup');
disp('  ✓ Multi-panel layout with labels');
disp('  ✓ Times New Roman font (engineering standard)');
disp('  ✓ Thicker lines (1.5-2 pt)');
disp('');
