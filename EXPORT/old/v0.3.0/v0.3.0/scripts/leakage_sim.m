% leakage_sim.m - Leaking tank dynamics
g = 9.81;
tankD = 1.0; holeD = 0.05;
h0 = 2.0; Qin = 0.01;
tspan = [0 100];

Atank = pi * (tankD/2)^2;
Ahole = pi * (holeD/2)^2;
tankODE = @(t,h) (Qin - Ahole * sqrt(2 * g * max(h,0))) / Atank;

[t,h] = ode45(tankODE, tspan, h0);

% Export results
fid = fopen('tank_data.csv', 'w');
fprintf(fid, '# time(s), water_level(m)\n');
for i = 1:length(t)
    fprintf(fid, '%.3f, %.6f\n', t(i), h(i));
end
fclose(fid);

disp('Tank simulation complete');
disp(['Final level: ' num2str(h(end)) ' m']);
disp('Data exported to tank_data.csv');
