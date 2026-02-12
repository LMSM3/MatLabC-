% PROJECTILE_MOTION_PHYSICS.M - Complete Physics Simulation
% Projectile motion with air resistance, multiple graphs, publication quality
%
% Physics: Trajectory analysis with drag force
% Graphs: 6 subplots with professional formatting

clear all
close all
clc

fprintf('\n╔════════════════════════════════════════════════════════╗\n');
fprintf('║     PROJECTILE MOTION WITH AIR RESISTANCE             ║\n');
fprintf('║          Advanced Physics Simulation                  ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

%% ========== PHYSICAL PARAMETERS ==========
fprintf('Setting up physical parameters...\n');

% Projectile properties
m = 0.145;          % Mass (kg) - baseball
d = 0.074;          % Diameter (m)
A = pi*(d/2)^2;     % Cross-sectional area (m²)
Cd = 0.47;          % Drag coefficient (sphere)

% Initial conditions
v0 = 45;            % Initial velocity (m/s)
theta0 = 45;        % Launch angle (degrees)
h0 = 2;             % Initial height (m)

% Environment
g = 9.81;           % Gravity (m/s²)
rho_air = 1.225;    % Air density (kg/m³)
k = 0.5*Cd*rho_air*A; % Drag constant

% Time parameters
dt = 0.01;          % Time step (s)
t_max = 10;         % Maximum time (s)

fprintf('  Mass:           %.3f kg\n', m);
fprintf('  Diameter:       %.3f m\n', d);
fprintf('  Initial v:      %.1f m/s\n', v0);
fprintf('  Launch angle:   %.1f°\n', theta0);
fprintf('  Drag coeff:     %.2f\n', Cd);
fprintf('\n');

%% ========== INITIAL CONDITIONS ==========
fprintf('Computing trajectories...\n');

% Convert angle to radians
theta = theta0 * pi/180;

% Initial velocity components
vx0 = v0 * cos(theta);
vy0 = v0 * sin(theta);

% Time vector
t = 0:dt:t_max;
n = length(t);

%% ========== TRAJECTORY WITH AIR RESISTANCE ==========
% Initialize arrays
x_drag = zeros(1, n);
y_drag = zeros(1, n);
vx_drag = zeros(1, n);
vy_drag = zeros(1, n);
v_drag = zeros(1, n);
E_drag = zeros(1, n);

% Set initial conditions
x_drag(1) = 0;
y_drag(1) = h0;
vx_drag(1) = vx0;
vy_drag(1) = vy0;
v_drag(1) = v0;
E_drag(1) = 0.5*m*v0^2 + m*g*h0;

% Numerical integration (Euler method)
for i = 2:n
    % Current velocity magnitude
    v_mag = sqrt(vx_drag(i-1)^2 + vy_drag(i-1)^2);
    
    % Drag force components
    Fx_drag = -k * v_mag * vx_drag(i-1);
    Fy_drag = -k * v_mag * vy_drag(i-1);
    
    % Accelerations
    ax = Fx_drag / m;
    ay = -g + Fy_drag / m;
    
    % Update velocities
    vx_drag(i) = vx_drag(i-1) + ax*dt;
    vy_drag(i) = vy_drag(i-1) + ay*dt;
    v_drag(i) = sqrt(vx_drag(i)^2 + vy_drag(i)^2);
    
    % Update positions
    x_drag(i) = x_drag(i-1) + vx_drag(i)*dt;
    y_drag(i) = y_drag(i-1) + vy_drag(i)*dt;
    
    % Energy
    KE = 0.5*m*v_drag(i)^2;
    PE = m*g*y_drag(i);
    E_drag(i) = KE + PE;
    
    % Stop if hits ground
    if y_drag(i) < 0
        x_drag = x_drag(1:i);
        y_drag = y_drag(1:i);
        vx_drag = vx_drag(1:i);
        vy_drag = vy_drag(1:i);
        v_drag = v_drag(1:i);
        E_drag = E_drag(1:i);
        t = t(1:i);
        break;
    end
end

%% ========== TRAJECTORY WITHOUT AIR RESISTANCE (IDEAL) ==========
% Analytical solution
t_ideal = t;
x_ideal = vx0 * t_ideal;
y_ideal = h0 + vy0*t_ideal - 0.5*g*t_ideal.^2;

% Stop at ground
idx_ground = find(y_ideal < 0, 1);
if ~isempty(idx_ground)
    x_ideal = x_ideal(1:idx_ground);
    y_ideal = y_ideal(1:idx_ground);
    t_ideal = t_ideal(1:idx_ground);
end

vx_ideal = vx0 * ones(size(t_ideal));
vy_ideal = vy0 - g*t_ideal;
v_ideal = sqrt(vx_ideal.^2 + vy_ideal.^2);
E_ideal = 0.5*m*v0^2 + m*g*h0 * ones(size(t_ideal));

fprintf('  With drag:    Range = %.2f m, Time = %.2f s\n', max(x_drag), max(t));
fprintf('  Without drag: Range = %.2f m, Time = %.2f s\n', max(x_ideal), max(t_ideal));
fprintf('  Range loss:   %.1f%%\n', 100*(1 - max(x_drag)/max(x_ideal)));
fprintf('\n');

%% ========== CREATE FIGURE WITH MULTIPLE SUBPLOTS ==========
fprintf('Generating publication-quality graphs...\n\n');

figure('Position', [100, 100, 1400, 900]);
set(gcf, 'Color', 'w');

%% SUBPLOT 1: TRAJECTORY COMPARISON
subplot(2, 3, 1)
plot(x_ideal, y_ideal, 'b-', 'LineWidth', 2);
hold on
plot(x_drag, y_drag, 'r--', 'LineWidth', 2);
grid on
xlabel('Horizontal Distance (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Height (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Trajectory Comparison', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('No Air Resistance', 'With Air Resistance', ...
       'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
xlim([0, max(x_ideal)*1.1]);
ylim([0, max(max(y_ideal), max(y_drag))*1.2]);

%% SUBPLOT 2: VELOCITY MAGNITUDE vs TIME
subplot(2, 3, 2)
plot(t_ideal, v_ideal, 'b-', 'LineWidth', 2);
hold on
plot(t, v_drag, 'r--', 'LineWidth', 2);
grid on
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Velocity Magnitude (m/s)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Velocity vs Time', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('No Air Resistance', 'With Air Resistance', ...
       'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 3: VELOCITY COMPONENTS
subplot(2, 3, 3)
plot(t, vx_drag, 'b-', 'LineWidth', 2);
hold on
plot(t, vy_drag, 'r-', 'LineWidth', 2);
plot(t, v_drag, 'k--', 'LineWidth', 2);
grid on
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Velocity (m/s)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Velocity Components (With Drag)', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('v_x', 'v_y', '|v|', 'Location', 'northeast', ...
       'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 4: ENERGY CONSERVATION
subplot(2, 3, 4)
% Calculate energy components for drag case
KE_drag = 0.5*m*v_drag.^2;
PE_drag = m*g*y_drag;

plot(t, E_ideal(1:length(t)), 'b-', 'LineWidth', 2);
hold on
plot(t, E_drag, 'r-', 'LineWidth', 2);
plot(t, KE_drag, 'g--', 'LineWidth', 1.5);
plot(t, PE_drag, 'm--', 'LineWidth', 1.5);
grid on
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Energy (J)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Energy Analysis', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('E_{total} (ideal)', 'E_{total} (drag)', 'KE (drag)', 'PE (drag)', ...
       'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 5: HEIGHT vs HORIZONTAL DISTANCE (PHASE SPACE)
subplot(2, 3, 5)
plot(x_drag, v_drag, 'r-', 'LineWidth', 2);
hold on
plot(x_drag(1), v_drag(1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(x_drag(end), v_drag(end), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
grid on
xlabel('Horizontal Distance (m)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Speed (m/s)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Phase Space: Distance vs Speed', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('Trajectory', 'Launch', 'Impact', 'Location', 'northeast', ...
       'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% SUBPLOT 6: DRAG FORCE vs VELOCITY
v_plot = linspace(0, v0, 100);
F_drag = k * v_plot.^2;

subplot(2, 3, 6)
plot(v_plot, F_drag, 'b-', 'LineWidth', 2);
hold on
plot(v_drag, k*v_drag.^2, 'r.', 'MarkerSize', 8);
grid on
xlabel('Velocity (m/s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Drag Force (N)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('Drag Force vs Velocity', 'FontName', 'Times New Roman', 'FontSize', 16, 'FontWeight', 'bold');
legend('F_D = \frac{1}{2} C_D \rho A v^2', 'Simulation Points', ...
       'Location', 'northwest', 'FontName', 'Times New Roman', 'FontSize', 12);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%% ========== ADD MAIN TITLE ==========
sgtitle('Projectile Motion: Complete Physics Analysis', ...
        'FontName', 'Times New Roman', 'FontSize', 18, 'FontWeight', 'bold');

%% ========== SAVE FIGURE ==========
fprintf('Saving figure...\n');
print('projectile_motion_analysis', '-dpng', '-r300');
savefig('projectile_motion_analysis.fig');

fprintf('  Saved: projectile_motion_analysis.png (300 DPI)\n');
fprintf('  Saved: projectile_motion_analysis.fig (MATLAB figure)\n');
fprintf('\n');

%% ========== RESULTS SUMMARY ==========
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║              SIMULATION RESULTS                       ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

fprintf('Ideal Trajectory (No Drag):\n');
fprintf('  Maximum range:    %.2f m\n', max(x_ideal));
fprintf('  Maximum height:   %.2f m\n', max(y_ideal));
fprintf('  Flight time:      %.2f s\n', max(t_ideal));
fprintf('  Impact velocity:  %.2f m/s\n', v_ideal(end));
fprintf('\n');

fprintf('Real Trajectory (With Drag):\n');
fprintf('  Maximum range:    %.2f m\n', max(x_drag));
fprintf('  Maximum height:   %.2f m\n', max(y_drag));
fprintf('  Flight time:      %.2f s\n', max(t));
fprintf('  Impact velocity:  %.2f m/s\n', v_drag(end));
fprintf('\n');

fprintf('Drag Effects:\n');
fprintf('  Range reduction:  %.2f m (%.1f%%)\n', ...
        max(x_ideal) - max(x_drag), ...
        100*(1 - max(x_drag)/max(x_ideal)));
fprintf('  Time reduction:   %.2f s (%.1f%%)\n', ...
        max(t_ideal) - max(t), ...
        100*(1 - max(t)/max(t_ideal)));
fprintf('  Energy lost:      %.2f J (%.1f%%)\n', ...
        E_ideal(1) - E_drag(end), ...
        100*(E_ideal(1) - E_drag(end))/E_ideal(1));
fprintf('\n');

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║            SIMULATION COMPLETE                        ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

% Clean up
fprintf('Figure window: Check display for 6 publication-quality graphs\n');
fprintf('Commands used: hold on, grid on, FontName, FontSize\n');
fprintf('Physics modeled: Drag force, energy dissipation, trajectory\n\n');
