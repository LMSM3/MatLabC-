% materials_optimization.m
% Advanced materials selection and optimization
%
% Demonstrates constraint-based material selection, multi-objective
% optimization, and temperature-dependent analysis for engineering design.
%
% Run with: mlab++ materials_optimization.m --visual --noerrorlogs

disp('MatLabC++ Materials Optimization Demo');
disp('======================================');
disp('');

% ========== DESIGN PROBLEM: DRONE FRAME ARM ==========
disp('Design Problem: Quadcopter Frame Arm');
disp('-------------------------------------');
disp('');

% Requirements
fprintf('Requirements:\n');
fprintf('  - Length: 250 mm\n');
fprintf('  - Max deflection: 2 mm under 5 N load\n');
fprintf('  - Operating temp: -20°C to 60°C\n');
fprintf('  - Max cost: $5 per arm\n');
fprintf('  - Minimize weight\n');
disp('');

% Design parameters
L = 0.25;  % Length (m)
F = 5;     % Load (N)
max_deflection = 0.002;  % Max deflection (m)

% Calculate required properties
% For a cantilever beam: δ = FL³/(3EI)
% Assume circular tube: I = π(d_o⁴ - d_i⁴)/64
% For initial sizing, assume d_o = 20 mm, d_i = 18 mm
d_o = 0.020;
d_i = 0.018;
I = pi * (d_o^4 - d_i^4) / 64;

% Required Young's modulus
E_required = (F * L^3) / (3 * I * max_deflection);
fprintf('Calculated Requirements:\n');
fprintf('  Min Young''s modulus: %.1f GPa\n', E_required / 1e9);
disp('');

% ========== CONSTRAINT-BASED MATERIAL SELECTION ==========
disp('1. Constraint-Based Material Selection');
disp('---------------------------------------');

% Define constraints
constraints = struct();
constraints.min_youngs_modulus = E_required;
constraints.max_density = 3000;  % For weight
constraints.min_working_temp = 253;  % -20°C in Kelvin
constraints.max_working_temp = 333;  % 60°C in Kelvin
constraints.category = 'metal';  % Structural requirement

% Find candidates
candidates = material_constrain_select(constraints, 'strength_to_weight');

fprintf('Found %d candidate materials:\n', length(candidates));
for i = 1:min(5, length(candidates))
    mat = candidates{i}.material;
    score = candidates{i}.score;
    
    fprintf('\n%d. %s\n', i, mat.name);
    fprintf('   Score: %.3f\n', score);
    fprintf('   Density: %.0f kg/m³\n', mat.density.value);
    fprintf('   Young''s modulus: %.1f GPa\n', mat.youngs_modulus.value / 1e9);
    fprintf('   Yield strength: %.0f MPa\n', mat.yield_strength.value / 1e6);
    
    % Calculate weight
    volume = pi * (d_o^2 - d_i^2) * L;
    weight = mat.density.value * volume * 1000;  % grams
    fprintf('   Estimated weight: %.1f g\n', weight);
    
    % Calculate cost (if available)
    if ~isempty(mat.cost_per_kg)
        cost = mat.cost_per_kg * (weight / 1000);
        fprintf('   Estimated cost: $%.2f\n', cost);
    end
end
disp('');

% ========== MULTI-OBJECTIVE OPTIMIZATION ==========
disp('2. Multi-Objective Optimization');
disp('--------------------------------');

% Objective: Minimize (weight + 0.5*cost)
% Subject to: strength, stiffness, temperature constraints

fprintf('Optimization criteria:\n');
fprintf('  Primary: Minimize weight\n');
fprintf('  Secondary: Minimize cost\n');
fprintf('  Constraint: Meet all performance requirements\n');
disp('');

% Score each candidate
scores = zeros(length(candidates), 1);
for i = 1:length(candidates)
    mat = candidates{i}.material;
    
    % Weight penalty
    volume = pi * (d_o^2 - d_i^2) * L;
    weight = mat.density.value * volume;
    weight_score = 1 / weight;  % Lower weight = higher score
    
    % Stiffness bonus
    E = mat.youngs_modulus.value;
    stiffness_score = E / E_required;  % Exceeding requirement is good
    
    % Strength bonus
    sigma_yield = mat.yield_strength.value;
    strength_score = sigma_yield / 200e6;  % Normalized to 200 MPa baseline
    
    % Cost penalty (if available)
    if ~isempty(mat.cost_per_kg)
        cost = mat.cost_per_kg * weight;
        cost_score = 1 / cost;
    else
        cost_score = 0.5;  % Neutral if cost unknown
    end
    
    % Combined score (weighted sum)
    scores(i) = 0.4 * weight_score + ...
                0.3 * stiffness_score + ...
                0.2 * strength_score + ...
                0.1 * cost_score;
end

% Find optimal
[max_score, opt_idx] = max(scores);
optimal_material = candidates{opt_idx}.material;

fprintf('Optimal Material: %s\n', optimal_material.name);
fprintf('  Score: %.3f\n', max_score);
volume = pi * (d_o^2 - d_i^2) * L;
opt_weight = optimal_material.density.value * volume * 1000;
fprintf('  Weight: %.1f g\n', opt_weight);
fprintf('  Young''s modulus: %.1f GPa\n', optimal_material.youngs_modulus.value / 1e9);
fprintf('  Yield strength: %.0f MPa\n', optimal_material.yield_strength.value / 1e6);
disp('');

% ========== TEMPERATURE-DEPENDENT ANALYSIS ==========
disp('3. Temperature-Dependent Performance');
disp('------------------------------------');

temps_C = [-20, 0, 20, 40, 60];
fprintf('Analyzing %s across operating range:\n\n', optimal_material.name);

fprintf('Temp (°C) | E (GPa) | σ_y (MPa) | Deflection (mm)\n');
fprintf('----------|---------|-----------|----------------\n');

for i = 1:length(temps_C)
    T_K = temps_C(i) + 273.15;
    
    % Get temperature-dependent properties
    E_T = material_prop_at_temp(optimal_material, 'youngs_modulus', T_K);
    sigma_y_T = material_prop_at_temp(optimal_material, 'yield_strength', T_K);
    
    % Calculate deflection at this temperature
    deflection_T = (F * L^3) / (3 * E_T * I);
    
    fprintf('%9d | %7.1f | %9.0f | %14.2f\n', ...
            temps_C(i), E_T/1e9, sigma_y_T/1e6, deflection_T*1000);
end
disp('');

% Check if deflection constraint is met across temperature range
max_deflection_found = 0;
for i = 1:length(temps_C)
    T_K = temps_C(i) + 273.15;
    E_T = material_prop_at_temp(optimal_material, 'youngs_modulus', T_K);
    deflection_T = (F * L^3) / (3 * E_T * I);
    max_deflection_found = max(max_deflection_found, deflection_T);
end

if max_deflection_found < max_deflection
    fprintf('✓ Deflection constraint satisfied across temperature range\n');
    fprintf('  Max deflection: %.2f mm (limit: %.2f mm)\n', ...
            max_deflection_found*1000, max_deflection*1000);
else
    fprintf('✗ Deflection constraint violated at extreme temperatures\n');
    fprintf('  Max deflection: %.2f mm (limit: %.2f mm)\n', ...
            max_deflection_found*1000, max_deflection*1000);
    fprintf('  Recommendation: Increase tube diameter or choose stiffer material\n');
end
disp('');

% ========== SAFETY FACTOR ANALYSIS ==========
disp('4. Safety Factor Analysis');
disp('-------------------------');

% Calculate stress at maximum load
M_max = F * L;  % Bending moment (N⋅m)
c = d_o / 2;    % Outer radius
sigma_max = M_max * c / I;

fprintf('Maximum stress: %.1f MPa\n', sigma_max / 1e6);
fprintf('Yield strength: %.1f MPa (at 20°C)\n', ...
        optimal_material.yield_strength.value / 1e6);

safety_factor = optimal_material.yield_strength.value / sigma_max;
fprintf('Safety factor: %.2f\n', safety_factor);

if safety_factor > 2
    fprintf('✓ Adequate safety factor (> 2.0)\n');
elseif safety_factor > 1.5
    fprintf('⚠ Marginal safety factor (1.5-2.0)\n');
else
    fprintf('✗ Insufficient safety factor (< 1.5)\n');
    fprintf('  Recommendation: Increase tube diameter or choose stronger material\n');
end
disp('');

% ========== ALTERNATIVE MATERIALS COMPARISON ==========
disp('5. Alternative Materials Comparison');
disp('-----------------------------------');

if length(candidates) >= 3
    compare_names = cell(1, min(3, length(candidates)));
    for i = 1:min(3, length(candidates))
        compare_names{i} = candidates{i}.material.name;
    end
    
    comparison = material_compare(compare_names);
    
    fprintf('Comparing top 3 candidates:\n');
    fprintf('  Materials: %s\n', strjoin(comparison.materials, ', '));
    fprintf('  Winner: %s\n', comparison.winner);
    fprintf('  Reasoning: %s\n', comparison.reasoning);
    disp('');
    
    % Print properties table
    fprintf('Property            | ');
    for i = 1:length(comparison.materials)
        fprintf('%15s | ', comparison.materials{i});
    end
    fprintf('\n');
    fprintf(repmat('-', 1, 20 + 18*length(comparison.materials)));
    fprintf('\n');
    
    props = fieldnames(comparison.properties);
    for i = 1:length(props)
        prop = props{i};
        fprintf('%-20s| ', prop);
        vals = comparison.properties.(prop);
        for j = 1:length(vals)
            fprintf('%15.2e | ', vals(j));
        end
        fprintf('\n');
    end
end
disp('');

% ========== DESIGN SUMMARY ==========
disp('Design Summary');
disp('==============');
fprintf('Selected Material: %s\n', optimal_material.name);
fprintf('Tube dimensions: OD=%.1f mm, ID=%.1f mm, L=%.1f mm\n', ...
        d_o*1000, d_i*1000, L*1000);
fprintf('Weight: %.1f g\n', opt_weight);
fprintf('Safety factor: %.2f\n', safety_factor);
fprintf('Max deflection: %.2f mm (across -20°C to 60°C)\n', max_deflection_found*1000);
fprintf('Source confidence: %d/5 (%s)\n', ...
        optimal_material.density.confidence, optimal_material.density.source);
disp('');

disp('✓ Demo complete! Materials optimization features:');
disp('  • Constraint-based material selection');
disp('  • Multi-objective optimization');
disp('  • Temperature-dependent analysis');
disp('  • Safety factor calculation');
disp('  • Comparative material analysis');
disp('  • Real engineering design workflow');
