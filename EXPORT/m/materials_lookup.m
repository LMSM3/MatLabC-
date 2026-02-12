% materials_lookup.m
% Materials Database Smart Query Demo
%
% Demonstrates the intelligent materials database system
% Run with: mlab++ materials_lookup.m --visual

disp('MatLabC++ Materials Database Demo');
disp('==================================');
disp('');

% ========== BASIC LOOKUP ==========
disp('1. Basic Material Lookup');
disp('------------------------');

% Get aluminum 6061 properties
material = material_get('aluminum_6061');
fprintf('Material: %s\n', material.name);
fprintf('Density: %.0f kg/m³\n', material.density.value);
fprintf('Young''s Modulus: %.1f GPa\n', material.youngs_modulus.value / 1e9);
fprintf('Yield Strength: %.0f MPa\n', material.yield_strength.value / 1e6);
fprintf('Source: %s\n', material.density.source);
disp('');

% ========== SMART INFERENCE ==========
disp('2. Smart Inference from Density');
disp('--------------------------------');

% "I only know the density is ~2700 kg/m³"
result = material_infer_density(2700, 100);
fprintf('Inferred material: %s\n', result.material.name);
fprintf('Confidence: %.1f%%\n', result.confidence * 100);
fprintf('Reasoning: %s\n', result.reasoning);
disp('');

% ========== MATERIAL SELECTION ==========
disp('3. Optimized Material Selection');
disp('--------------------------------');

% Find best material for drone frame
criteria = struct();
criteria.min_yield_strength = 200e6;  % 200 MPa
criteria.max_density = 3000;          % 3000 kg/m³
criteria.category = 'metal';

candidates = material_select(criteria, 'strength_to_weight');
fprintf('Found %d suitable materials:\n', length(candidates));
for i = 1:min(3, length(candidates))
    mat = candidates{i}.material;
    score = candidates{i}.score;
    fprintf('  %d. %s (score: %.3f)\n', i, mat.name, score);
    fprintf('     Density: %.0f kg/m³, Yield: %.0f MPa\n', ...
            mat.density.value, mat.yield_strength.value / 1e6);
end
disp('');

% ========== MATERIAL COMPARISON ==========
disp('4. Material Comparison');
disp('----------------------');

comparison = material_compare({'aluminum_6061', 'steel', 'peek'});
fprintf('Comparing %d materials\n', length(comparison.materials));
fprintf('Winner: %s\n', comparison.winner);
fprintf('Reasoning: %s\n', comparison.reasoning);
disp('');

% Print comparison table
props = {'density', 'youngs_modulus', 'yield_strength'};
for i = 1:length(props)
    prop = props{i};
    fprintf('%s: ', prop);
    vals = comparison.properties.(prop);
    fprintf('%.2e ', vals);
    fprintf('\n');
end
disp('');

% ========== APPLICATION RECOMMENDATION ==========
disp('5. Application-Specific Recommendation');
disp('---------------------------------------');

recommendation = material_recommend('3d_printing', 'cost_effective');
fprintf('Best material for 3D printing: %s\n', recommendation.material.name);
fprintf('Reasoning: %s\n', recommendation.reasoning);
if ~isempty(recommendation.alternatives)
    fprintf('Alternatives: %s\n', strjoin(recommendation.alternatives, ', '));
end
disp('');

% ========== TEMPERATURE-DEPENDENT PROPERTIES ==========
disp('6. Temperature-Dependent Properties');
disp('------------------------------------');

aluminum = material_get('aluminum_6061');
temps = [20, 100, 200];  % °C
fprintf('Aluminum 6061 thermal conductivity:\n');
for i = 1:length(temps)
    T_K = temps(i) + 273.15;
    k = material_prop_at_temp(aluminum, 'thermal_conductivity', T_K);
    fprintf('  %d°C: %.1f W/(m·K)\n', temps(i), k);
end
disp('');

% ========== DATABASE STATISTICS ==========
disp('7. Database Statistics');
disp('----------------------');

stats = material_db_stats();
fprintf('Total materials: %d\n', stats.count);
fprintf('Categories: %s\n', strjoin(stats.categories, ', '));
fprintf('Average confidence: %.1f/5\n', stats.avg_confidence);
disp('');

disp('Demo complete! Materials database features:');
disp('  ✓ Smart inference from partial data');
disp('  ✓ Optimized material selection');
disp('  ✓ Multi-criteria comparison');
disp('  ✓ Application recommendations');
disp('  ✓ Temperature-dependent properties');
disp('  ✓ Source-verified data (NIST, ASM, ASTM)');
