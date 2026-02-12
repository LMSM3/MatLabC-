%% ODE Solving Examples in MATLAB
% Equivalent to MatLabC++ ODE functionality
% Shows what MatLabC++ basic_ode.cpp replaces

%% Example 1: Free Fall with Air Resistance

function free_fall_matlab()
    % Free fall with quadratic drag
    
    % Parameters
    m = 1.0;           % mass (kg)
    g = 9.80665;       % gravity (m/s²)
    Cd = 0.47;         % drag coefficient
    A = 0.01;          % cross-sectional area (m²)
    rho = 1.225;       % air density (kg/m³)
    
    % Initial conditions: [position, velocity]
    y0 = [100; 0];     % 100m high, 0 velocity
    
    % Time span
    tspan = [0 10];
    
    % Define ODE: dy/dt = [v, a]
    % where a = -g - (0.5*rho*Cd*A/m)*v*|v|
    ode_func = @(t, y) [
        y(2);                                      % dy/dt = v
        -g - (0.5*rho*Cd*A/m) * y(2) * abs(y(2))  % dv/dt = a
    ];
    
    % Solve using ode45 (similar to RK45)
    [t, y] = ode45(ode_func, tspan, y0);
    
    % Find when it hits ground
    ground_idx = find(y(:,1) <= 0, 1);
    if ~isempty(ground_idx)
        t_ground = t(ground_idx);
        v_ground = y(ground_idx, 2);
    else
        t_ground = t(end);
        v_ground = y(end, 2);
    end
    
    % Display results
    disp('FREE FALL WITH AIR RESISTANCE');
    disp('==============================');
    fprintf('Initial height: %.1f m\n', y0(1));
    fprintf('Time to ground: %.2f s\n', t_ground);
    fprintf('Final velocity: %.1f m/s\n', abs(v_ground));
    fprintf('\n');
    
    % Display trajectory
    fprintf('Time(s)  Height(m)  Velocity(m/s)\n');
    fprintf('-----------------------------------\n');
    for i = 1:min(length(t), 10)
        fprintf('%6.2f   %8.2f   %12.2f\n', t(i), y(i,1), y(i,2));
    end
    fprintf('...\n');
    
    % Plot results
    figure('Name', 'Free Fall Analysis');
    
    subplot(1,2,1);
    plot(t, y(:,1), 'b-', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Height (m)');
    title('Height vs. Time');
    grid on;
    
    subplot(1,2,2);
    plot(t, y(:,2), 'r-', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Velocity (m/s)');
    title('Velocity vs. Time');
    grid on;
end

%% Example 2: Spring-Mass-Damper System

function spring_mass_damper()
    % Parameters
    m = 1.0;           % mass (kg)
    k = 100.0;         % spring constant (N/m)
    c = 5.0;           % damping coefficient (Ns/m)
    
    % Calculate system properties
    omega_n = sqrt(k/m);           % Natural frequency
    zeta = c / (2*sqrt(k*m));      % Damping ratio
    
    disp('SPRING-MASS-DAMPER SYSTEM');
    disp('=========================');
    fprintf('Mass: %.1f kg\n', m);
    fprintf('Spring: %.1f N/m\n', k);
    fprintf('Damping: %.1f Ns/m\n', c);
    fprintf('Natural frequency: %.2f rad/s\n', omega_n);
    fprintf('Damping ratio: %.3f\n', zeta);
    
    if zeta < 1.0
        fprintf('System: UNDERDAMPED (oscillates)\n\n');
    elseif zeta == 1.0
        fprintf('System: CRITICALLY DAMPED\n\n');
    else
        fprintf('System: OVERDAMPED\n\n');
    end
    
    % Initial conditions: [position, velocity]
    y0 = [0.1; 0];     % Pulled 10cm, released
    
    % Time span
    tspan = [0 2];
    
    % Define ODE: [x, v]' = [v, -(k*x + c*v)/m]'
    ode_func = @(t, y) [
        y(2);                      % dx/dt = v
        -(k*y(1) + c*y(2))/m      % dv/dt = a
    ];
    
    % Solve
    [t, y] = ode45(ode_func, tspan, y0);
    
    % Display sample points
    fprintf('Time(s)  Position(m)  Velocity(m/s)\n');
    fprintf('--------------------------------------\n');
    sample_idx = 1:round(length(t)/20):length(t);
    for i = sample_idx
        fprintf('%6.2f   %10.4f   %12.4f\n', t(i), y(i,1), y(i,2));
    end
    fprintf('\n');
    
    % Plot phase portrait
    figure('Name', 'Spring-Mass-Damper');
    
    subplot(2,2,1);
    plot(t, y(:,1), 'b-', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Position (m)');
    title('Displacement vs. Time');
    grid on;
    
    subplot(2,2,2);
    plot(t, y(:,2), 'r-', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Velocity (m/s)');
    title('Velocity vs. Time');
    grid on;
    
    subplot(2,2,3);
    plot(y(:,1), y(:,2), 'g-', 'LineWidth', 2);
    xlabel('Position (m)');
    ylabel('Velocity (m/s)');
    title('Phase Portrait');
    grid on;
    axis equal;
    
    subplot(2,2,4);
    % Energy analysis
    KE = 0.5 * m * y(:,2).^2;
    PE = 0.5 * k * y(:,1).^2;
    E_total = KE + PE;
    
    plot(t, KE, 'b-', t, PE, 'r-', t, E_total, 'k-', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Energy (J)');
    title('Energy vs. Time');
    legend('Kinetic', 'Potential', 'Total', 'Location', 'best');
    grid on;
end

%% Example 3: Pendulum

function pendulum_simulation()
    % Parameters
    L = 1.0;           % length (m)
    g = 9.80665;       % gravity (m/s²)
    damping = 0.1;     % damping coefficient
    
    % Initial conditions: [angle, angular_velocity]
    theta0 = 45 * pi/180;  % 45 degrees
    y0 = [theta0; 0];
    
    disp('DAMPED PENDULUM');
    disp('===============');
    fprintf('Length: %.1f m\n', L);
    fprintf('Damping: %.2f\n', damping);
    fprintf('Initial angle: %.1f degrees\n\n', theta0 * 180/pi);
    
    % Time span
    tspan = [0 10];
    
    % Define ODE: [theta, omega]' = [omega, -(g/L)*sin(theta) - damping*omega]'
    ode_func = @(t, y) [
        y(2);                              % dtheta/dt = omega
        -(g/L)*sin(y(1)) - damping*y(2)   % domega/dt = alpha
    ];
    
    % Solve
    [t, y] = ode45(ode_func, tspan, y0);
    
    % Convert to degrees for display
    theta_deg = y(:,1) * 180/pi;
    
    % Display sample points
    fprintf('Time(s)  Angle(deg)  Angular Vel(rad/s)\n');
    fprintf('------------------------------------------\n');
    sample_idx = 1:round(length(t)/20):length(t);
    for i = sample_idx
        fprintf('%6.2f   %9.2f   %18.4f\n', t(i), theta_deg(i), y(i,2));
    end
    fprintf('\n');
    
    % Plot results
    figure('Name', 'Pendulum Motion');
    
    subplot(2,2,1);
    plot(t, theta_deg, 'b-', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Angle (degrees)');
    title('Angle vs. Time');
    grid on;
    
    subplot(2,2,2);
    plot(t, y(:,2), 'r-', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Angular Velocity (rad/s)');
    title('Angular Velocity vs. Time');
    grid on;
    
    subplot(2,2,3);
    plot(y(:,1), y(:,2), 'g-', 'LineWidth', 2);
    xlabel('Angle (rad)');
    ylabel('Angular Velocity (rad/s)');
    title('Phase Portrait');
    grid on;
    
    subplot(2,2,4);
    % Animate pendulum
    % Calculate pendulum bob position
    x_bob = L * sin(y(:,1));
    y_bob = -L * cos(y(:,1));
    
    % Plot final position and trajectory
    plot(x_bob, y_bob, 'b-', 'LineWidth', 1);
    hold on;
    plot([0 x_bob(end)], [0 y_bob(end)], 'r-', 'LineWidth', 2);
    plot(x_bob(end), y_bob(end), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    hold off;
    axis equal;
    xlim([-L*1.2 L*1.2]);
    ylim([-L*1.2 L*0.2]);
    title('Pendulum Trajectory');
    grid on;
end

%% Example 4: Stiff Chemical Reaction

function stiff_chemical_reaction()
    % Chemical kinetics: A -> B -> C
    % Fast reaction: A -> B (k1 = 1000)
    % Slow reaction: B -> C (k2 = 1)
    
    k1 = 1000;  % Fast rate constant
    k2 = 1;     % Slow rate constant
    
    disp('STIFF CHEMICAL REACTION');
    disp('=======================');
    fprintf('A -> B -> C\n');
    fprintf('k1 (A->B): %.0f (fast)\n', k1);
    fprintf('k2 (B->C): %.0f (slow)\n\n', k2);
    
    % Initial conditions: [A, B, C]
    y0 = [1.0; 0; 0];  % All A initially
    
    % Time span
    tspan = [0 5];
    
    % Define ODE system
    ode_func = @(t, y) [
        -k1 * y(1);          % dA/dt
        k1*y(1) - k2*y(2);   % dB/dt
        k2 * y(2)            % dC/dt
    ];
    
    % Use stiff solver (ode15s instead of ode45)
    % This is critical for stiff systems!
    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
    [t, y] = ode15s(ode_func, tspan, y0, options);
    
    % Display results
    fprintf('Time(s)      [A]        [B]        [C]\n');
    fprintf('--------------------------------------------\n');
    sample_idx = 1:round(length(t)/20):length(t);
    for i = sample_idx
        fprintf('%7.3f   %8.5f   %8.5f   %8.5f\n', t(i), y(i,1), y(i,2), y(i,3));
    end
    fprintf('\n');
    
    fprintf('Note: This is a STIFF system!\n');
    fprintf('  - ode45 would struggle (very small time steps)\n');
    fprintf('  - ode15s (stiff solver) handles it efficiently\n');
    fprintf('  - MatLabC++ RK45 adapts automatically\n\n');
    
    % Plot concentration profiles
    figure('Name', 'Chemical Reaction Kinetics');
    
    subplot(1,2,1);
    plot(t, y(:,1), 'b-', 'LineWidth', 2, 'DisplayName', '[A]');
    hold on;
    plot(t, y(:,2), 'r-', 'LineWidth', 2, 'DisplayName', '[B]');
    plot(t, y(:,3), 'g-', 'LineWidth', 2, 'DisplayName', '[C]');
    hold off;
    xlabel('Time (s)');
    ylabel('Concentration (M)');
    title('Species Concentrations vs. Time');
    legend('Location', 'best');
    grid on;
    
    subplot(1,2,2);
    % Verify mass balance
    total = y(:,1) + y(:,2) + y(:,3);
    plot(t, total, 'k-', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Total Concentration');
    title('Mass Balance (should be constant)');
    grid on;
    ylim([0.99 1.01]);
end

%% Example 5: Projectile Motion with Drag

function projectile_2d()
    % 2D projectile with air resistance
    
    % Parameters
    m = 0.145;         % mass (kg) - baseball
    g = 9.80665;       % gravity (m/s²)
    Cd = 0.47;         % drag coefficient
    A = 0.0042;        % cross-sectional area (m²) - baseball
    rho = 1.225;       % air density (kg/m³)
    
    % Launch conditions
    v0 = 40;           % initial velocity (m/s)
    angle = 30;        % launch angle (degrees)
    
    % Initial conditions: [x, vx, y, vy]
    angle_rad = angle * pi/180;
    y0 = [
        0;                      % x position
        v0 * cos(angle_rad);   % x velocity
        0;                      % y position
        v0 * sin(angle_rad)    % y velocity
    ];
    
    disp('PROJECTILE MOTION WITH DRAG');
    disp('============================');
    fprintf('Mass: %.3f kg\n', m);
    fprintf('Launch velocity: %.1f m/s\n', v0);
    fprintf('Launch angle: %.1f degrees\n\n', angle);
    
    % Time span
    tspan = [0 5];
    
    % Define ODE system
    ode_func = @(t, y) [
        y(2);                                                    % dx/dt = vx
        -(0.5*rho*Cd*A/m) * y(2) * sqrt(y(2)^2 + y(4)^2);     % dvx/dt
        y(4);                                                    % dy/dt = vy
        -g - (0.5*rho*Cd*A/m) * y(4) * sqrt(y(2)^2 + y(4)^2)  % dvy/dt
    ];
    
    % Event function to stop at ground
    events = @(t, y) deal(y(3), 1, 0);  % Stop when y=0
    options = odeset('Events', events);
    
    % Solve
    [t, y] = ode45(ode_func, tspan, y0, options);
    
    % Find landing point
    range = y(end, 1);
    flight_time = t(end);
    
    fprintf('Range: %.2f m\n', range);
    fprintf('Flight time: %.2f s\n', flight_time);
    fprintf('Max height: %.2f m\n\n', max(y(:,3)));
    
    % Compare to ideal (no drag)
    v0x = v0 * cos(angle_rad);
    v0y = v0 * sin(angle_rad);
    t_ideal = 2 * v0y / g;
    range_ideal = v0x * t_ideal;
    
    fprintf('Without air resistance:\n');
    fprintf('  Range: %.2f m\n', range_ideal);
    fprintf('  Difference: %.2f m (%.1f%% reduction)\n\n', ...
            range_ideal - range, (1 - range/range_ideal)*100);
    
    % Plot trajectory
    figure('Name', 'Projectile Motion');
    
    % With drag
    plot(y(:,1), y(:,3), 'b-', 'LineWidth', 2, 'DisplayName', 'With drag');
    hold on;
    
    % Without drag (ideal)
    t_ideal_vec = linspace(0, t_ideal, 100);
    x_ideal = v0x * t_ideal_vec;
    y_ideal = v0y * t_ideal_vec - 0.5 * g * t_ideal_vec.^2;
    plot(x_ideal, y_ideal, 'r--', 'LineWidth', 2, 'DisplayName', 'No drag');
    
    hold off;
    xlabel('Horizontal Distance (m)');
    ylabel('Height (m)');
    title(sprintf('Projectile Trajectory (%.1f m/s at %.1f°)', v0, angle));
    legend('Location', 'best');
    grid on;
    axis equal;
    xlim([0 max([range, range_ideal])*1.1]);
end

%% Main Function

function main_ode_examples()
    fprintf('\n');
    fprintf('============================================\n');
    fprintf('MATLAB ODE Solving Examples\n');
    fprintf('Equivalent to MatLabC++ basic_ode.cpp\n');
    fprintf('============================================\n\n');
    
    % Run all examples
    free_fall_matlab();
    fprintf('Press Enter to continue...\n');
    pause;
    
    spring_mass_damper();
    fprintf('Press Enter to continue...\n');
    pause;
    
    pendulum_simulation();
    fprintf('Press Enter to continue...\n');
    pause;
    
    stiff_chemical_reaction();
    fprintf('Press Enter to continue...\n');
    pause;
    
    projectile_2d();
    
    fprintf('\n');
    fprintf('============================================\n');
    fprintf('All MATLAB ODE examples completed!\n');
    fprintf('============================================\n\n');
    
    fprintf('MATLAB Solvers Used:\n');
    fprintf('  ode45:  Runge-Kutta (4,5) - general purpose\n');
    fprintf('  ode15s: Stiff solver - for fast/slow dynamics\n\n');
    
    fprintf('MatLabC++ Equivalent:\n');
    fprintf('  RK45Solver: Adaptive RK45 (similar to ode45)\n');
    fprintf('  Automatically handles stiff systems\n');
    fprintf('  Built into core library\n\n');
    
    fprintf('Key Differences:\n');
    fprintf('  - MATLAB: Built-in, mature, extensive toolboxes\n');
    fprintf('  - MatLabC++: Lightweight, C++ speed, free\n');
    fprintf('  - MATLAB: 18GB install, $2,150/year\n');
    fprintf('  - MatLabC++: 500MB, open source, MIT license\n\n');
end

% Run all examples
main_ode_examples();
