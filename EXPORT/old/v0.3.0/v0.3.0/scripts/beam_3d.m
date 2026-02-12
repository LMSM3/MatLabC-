% 3D Beam Stress Visualization (MATLAB/Octave)
% MatLabC++ v0.2.0 - Script Format Demo
% 
% Run: ./matlabcpp run beam_3d.m
% Or:  octave beam_3d.m

fprintf('╔═══════════════════════════════════════════╗\n');
fprintf('║  3D Beam Stress - MatLabC++ v0.2.0        ║\n');
fprintf('║  MATLAB Script Version                    ║\n');
fprintf('╚═══════════════════════════════════════════╝\n\n');

% Material properties (Aluminum 6061-T6)
material.name = 'Aluminum 6061-T6';
material.density = 2700;           % kg/m³
material.E = 69e9;                 % Pa (69 GPa)
material.yield = 276e6;            % Pa (276 MPa)

% Beam geometry
L = 1.0;        % Length: 1 meter
w = 0.05;       % Width: 5 cm
h = 0.10;       % Height: 10 cm
F = 500;        % Load: 500 N

fprintf('Material: %s\n', material.name);
fprintf('E = %.1f GPa\n', material.E/1e9);
fprintf('Yield = %.1f MPa\n\n', material.yield/1e6);

fprintf('Beam Geometry:\n');
fprintf('  Length: %.0f cm\n', L*100);
fprintf('  Width: %.0f cm\n', w*100);
fprintf('  Height: %.0f cm\n', h*100);
fprintf('  Load: %.0f N\n\n', F);

% Second moment of area
I = (w * h^3) / 12;

fprintf('Analysis:\n');
fprintf('  I = %.6e m^4\n', I);

% Generate 3D mesh
resolution = 20;
[X, Y, Z] = meshgrid(...
    linspace(0, L, resolution*2), ...      % x: along length
    linspace(-w/2, w/2, resolution/2), ... % y: width
    linspace(-h/2, h/2, resolution) ...    % z: height
);

% Flatten for calculations
x = X(:);
y = Y(:);
z = Z(:);

% Calculate stress at each point
% Bending moment: M(x) = F * (L - x)
M = F * (L - x);

% Distance from neutral axis
c = abs(z);

% Bending stress: σ = M*c/I
stress = (M .* c) / I;

% Displacement: v(x) = (F*x²)/(6*E*I) * (3*L - x)
displacement = (F * x.^2) ./ (6 * material.E * I) .* (3*L - x);

% Results
max_stress = max(abs(stress));
max_displacement = max(abs(displacement));

fprintf('  Max stress: %.2f MPa\n', max_stress/1e6);
fprintf('  Max displacement: %.3f mm\n', max_displacement*1000);

% Safety factor
safety_factor = material.yield / max_stress;
fprintf('  Safety factor: %.2f\n', safety_factor);

if safety_factor < 1.0
    fprintf('  ⚠️  WARNING: FAILURE - stress exceeds yield!\n');
elseif safety_factor < 2.0
    fprintf('  ⚠️  CAUTION: Low safety factor\n');
else
    fprintf('  ✓ SAFE: Adequate margin\n');
end

% Export data
data = [x, y, z, stress/1e6, displacement*1000];
csvwrite('beam_3d_matlab.csv', data);

% Write header separately
fid = fopen('beam_3d_matlab.csv', 'w');
fprintf(fid, 'x,y,z,stress_MPa,displacement_mm\n');
fclose(fid);

% Append data
dlmwrite('beam_3d_matlab.csv', data, '-append');

fprintf('\n✓ Data saved: beam_3d_matlab.csv\n');
fprintf('  Total points: %d\n', length(x));

% Create visualization if running in GUI mode
if ~isempty(getenv('DISPLAY')) || ispc()
    fprintf('\nGenerating 3D visualization...\n');
    
    figure('Position', [100, 100, 1200, 500]);
    
    % Plot 1: Stress
    subplot(1, 2, 1);
    scatter3(x, y, z, 10, stress/1e6, 'filled');
    colormap(jet);
    colorbar;
    xlabel('Length (m)');
    ylabel('Width (m)');
    zlabel('Height (m)');
    title('Von Mises Stress (MPa)');
    view(45, 30);
    grid on;
    
    % Plot 2: Displacement
    subplot(1, 2, 2);
    scatter3(x, y, z, 10, displacement*1000, 'filled');
    colormap(jet);
    colorbar;
    xlabel('Length (m)');
    ylabel('Width (m)');
    zlabel('Height (m)');
    title('Displacement (mm)');
    view(45, 30);
    grid on;
    
    % Save figure
    print('beam_3d_matlab.png', '-dpng', '-r150');
    fprintf('✓ Visualization saved: beam_3d_matlab.png\n\n');
else
    fprintf('\nNo display detected - data only mode\n');
    fprintf('View CSV in external tool or run in GUI environment\n\n');
end

fprintf('Done!\n');
