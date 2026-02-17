% PUBLISH_STYLING_DEMO.M - Interactive Publish System Demo
% Demonstrates all styling features of MatLabC++ publish() command
%
% Run: mlab++ publish publish_styling_demo.m
% Custom: mlab++ publish publish_styling_demo.m --style custom

%% Introduction
% This demo showcases the **MatLabC++ publish() system**, which generates
% HTML reports from .m scripts with syntax highlighting, output capture,
% and professional formatting.
%
% Key features:
%   - Section headers from %% comments
%   - Code blocks with syntax highlighting
%   - Console output capture
%   - Multiple styling themes
%   - LaTeX-style math notation (basic)

%% Basic Mathematics
% MATLAB-style computations with formatted output.

a = 5;
b = 3;
c = a + b;

fprintf('Addition: %d + %d = %d\n', a, b, c);
fprintf('Multiplication: %d × %d = %d\n', a, b, a*b);
fprintf('Division: %d ÷ %d = %.2f\n', a, b, a/b);

%% Vector Operations
% Demonstrating vector creation and operations.

x = [1, 2, 3, 4, 5];
y = [2, 4, 6, 8, 10];

fprintf('Vector x: [');
fprintf(' %d', x);
fprintf(' ]\n');

fprintf('Sum: %d\n', sum(x));
fprintf('Mean: %.2f\n', mean(x));
fprintf('Max: %d\n', max(x));

%% Trigonometric Functions
% Computing sine, cosine, and tangent values.

angles = [0, 30, 45, 60, 90];
fprintf('Angle (deg)  sin       cos       tan\n');
fprintf('───────────────────────────────────────\n');

for angle = angles
    rad = angle * pi / 180;
    s = sin(rad);
    c = cos(rad);
    t = tan(rad);
    fprintf('%3d°         %6.4f    %6.4f    %6.4f\n', angle, s, c, t);
end

%% Loop Demonstration
% A simple for loop with output.

fprintf('\nCounting with a for loop:\n');
for i = 1:5
    fprintf('  Iteration %d: value = %d\n', i, i^2);
end

%% Conditional Logic
% Demonstrating if/else statements.

temperature = 25;
fprintf('Current temperature: %d°C\n', temperature);

if temperature < 0
    fprintf('Status: Freezing\n');
elseif temperature < 20
    fprintf('Status: Cold\n');
elseif temperature < 30
    fprintf('Status: Comfortable\n');
else
    fprintf('Status: Hot\n');
end

%% Matrix Operations
% Creating and manipulating matrices.

A = [1, 2; 3, 4];
B = [5, 6; 7, 8];

fprintf('Matrix A:\n');
disp(A);

fprintf('Matrix B:\n');
disp(B);

fprintf('A + B:\n');
disp(A + B);

fprintf('A * B (matrix multiplication):\n');
disp(A * B);

%% Physical Constants
% Demonstrating built-in constants and scientific notation.

fprintf('Mathematical Constants:\n');
fprintf('  π = %.6f\n', pi);
fprintf('  e = %.6f\n', exp(1));

fprintf('\nPhysical Constants:\n');
fprintf('  Speed of light: c = 2.998e8 m/s\n');
fprintf('  Gravitational constant: G = 6.674e-11 m³/(kg·s²)\n');
fprintf('  Planck constant: h = 6.626e-34 J·s\n');

%% Formatted Tables
% Creating nicely formatted output tables.

fprintf('\n╔═══════════════════════════════════════╗\n');
fprintf('║     Projectile Motion Summary         ║\n');
fprintf('╚═══════════════════════════════════════╝\n\n');

fprintf('Parameter              Value\n');
fprintf('─────────────────────  ──────────\n');
fprintf('Initial velocity       45 m/s\n');
fprintf('Launch angle           45°\n');
fprintf('Maximum height         51.7 m\n');
fprintf('Range (ideal)          206.4 m\n');
fprintf('Range (with drag)      162.8 m\n');
fprintf('Range reduction        21.1%%\n');

%% Energy Calculations
% Kinetic and potential energy formulas.

m = 0.145;  % Mass (kg) - baseball
v = 45;     % Velocity (m/s)
h = 50;     % Height (m)
g = 9.81;   % Gravity (m/s²)

KE = 0.5 * m * v^2;
PE = m * g * h;
E_total = KE + PE;

fprintf('\nEnergy Analysis:\n');
fprintf('  Mass:               %.3f kg\n', m);
fprintf('  Velocity:           %.1f m/s\n', v);
fprintf('  Height:             %.1f m\n', h);
fprintf('  Kinetic Energy:     %.2f J\n', KE);
fprintf('  Potential Energy:   %.2f J\n', PE);
fprintf('  Total Energy:       %.2f J\n', E_total);

%% LaTeX-Style Math Notation
% Demonstrating subscripts and mathematical symbols.
%
% Formulas (rendered in HTML):
%   - Kinetic Energy: KE = ½mv²
%   - Potential Energy: PE = mgh
%   - Drag Force: F_D = ½C_D ρ A v²
%   - Quadratic Formula: x = (-b ± √(b²-4ac)) / 2a

fprintf('Mathematical expressions are styled in the HTML output.\n');
fprintf('Check the published report for formatted equations.\n');

%% Code Highlighting Demo
% All MATLAB keywords, functions, and operators are syntax-highlighted.

% Keywords: for, while, if, else, end, function, return
% Functions: sin, cos, sqrt, disp, fprintf, plot
% Operators: +, -, *, /, ^, ==, ~=, <, >
% Numbers: 42, 3.14159, 2.998e8
% Strings: 'hello', "world"
% Comments: % This is highlighted differently

x = linspace(0, 2*pi, 100);
y = sin(x);
fprintf('Generated %d points for sine wave\n', length(x));

%% Data Analysis Summary
% Final statistics and summary.

data = [10, 25, 30, 45, 50, 55, 60, 75, 80, 90];

fprintf('\n╔══════════════════════════════════════════════╗\n');
fprintf('║          Data Analysis Summary               ║\n');
fprintf('╚══════════════════════════════════════════════╝\n\n');

fprintf('Sample size:        %d\n', length(data));
fprintf('Minimum:            %d\n', min(data));
fprintf('Maximum:            %d\n', max(data));
fprintf('Mean:               %.2f\n', mean(data));
fprintf('Standard deviation: %.2f\n', std(data));

%% Conclusion
% This demo has shown:
%   1. Section headers with %% comments
%   2. Syntax-highlighted code blocks
%   3. Captured console output with box-drawing characters
%   4. Formatted tables and scientific notation
%   5. Multiple styling themes (use --style flag)
%
% To customize styling:
%   mlab++ publish script.m --style custom
%   mlab++ publish script.m --theme dark
%   mlab++ publish script.m --font Arial --fontsize 14
%
% For more information, see docs/PLOTTING_PUBLICATION_QUALITY.md

fprintf('\n╔══════════════════════════════════════════════╗\n');
fprintf('║            Demo Complete!                    ║\n');
fprintf('╚══════════════════════════════════════════════╝\n');
fprintf('Published HTML report shows professional formatting.\n');
