%% Material Comparison in MATLAB
% Equivalent to MatLabC++ compare functionality
% Shows what MatLabC++ replaces with its smart material database

%% Comparison 1: 3D Printing Materials
% In MATLAB, you'd manually create data structures

function compare_3d_printing_materials()
    % Define materials manually (or load from database)
    materials = struct();
    
    % PLA properties
    materials.pla.name = 'PLA';
    materials.pla.density = 1240;      % kg/m³
    materials.pla.strength = 50;       % MPa
    materials.pla.youngs = 3.5;        % GPa
    materials.pla.melts_at = 180;      % °C
    materials.pla.glass_transition = 60;
    materials.pla.cost = 20;           % $/kg
    
    % PETG properties
    materials.petg.name = 'PETG';
    materials.petg.density = 1270;
    materials.petg.strength = 50;
    materials.petg.youngs = 2.1;
    materials.petg.melts_at = 250;
    materials.petg.glass_transition = 80;
    materials.petg.cost = 25;
    
    % ABS properties
    materials.abs.name = 'ABS';
    materials.abs.density = 1060;
    materials.abs.strength = 45;
    materials.abs.youngs = 2.3;
    materials.abs.melts_at = 205;
    materials.abs.glass_transition = 105;
    materials.abs.cost = 22;
    
    % Create comparison table
    mat_names = {'PLA', 'PETG', 'ABS'};
    densities = [materials.pla.density, materials.petg.density, materials.abs.density];
    strengths = [materials.pla.strength, materials.petg.strength, materials.abs.strength];
    youngs = [materials.pla.youngs, materials.petg.youngs, materials.abs.youngs];
    melts = [materials.pla.melts_at, materials.petg.melts_at, materials.abs.melts_at];
    glass_t = [materials.pla.glass_transition, materials.petg.glass_transition, materials.abs.glass_transition];
    costs = [materials.pla.cost, materials.petg.cost, materials.abs.cost];
    
    % Create MATLAB table for display
    T = table(densities', strengths', youngs', melts', glass_t', costs', ...
              'VariableNames', {'Density_kg_m3', 'Strength_MPa', 'Youngs_GPa', ...
                                'Melts_C', 'Glass_T_C', 'Cost_USD_kg'}, ...
              'RowNames', mat_names);
    
    disp('3D PRINTING MATERIAL COMPARISON');
    disp('================================');
    disp(T);
    
    % Find winners for each property
    [~, min_density_idx] = min(densities);
    [~, max_strength_idx] = max(strengths);
    [~, max_youngs_idx] = max(youngs);
    [~, max_temp_idx] = max(melts);
    [~, max_glass_idx] = max(glass_t);
    [~, min_cost_idx] = min(costs);
    
    fprintf('\nWinners:\n');
    fprintf('  Density (lightest): %s (%.0f kg/m³)\n', mat_names{min_density_idx}, densities(min_density_idx));
    fprintf('  Strength: %s (%.0f MPa)\n', mat_names{max_strength_idx}, strengths(max_strength_idx));
    fprintf('  Stiffness: %s (%.1f GPa)\n', mat_names{max_youngs_idx}, youngs(max_youngs_idx));
    fprintf('  Temperature: %s (%.0f°C)\n', mat_names{max_temp_idx}, melts(max_temp_idx));
    fprintf('  Cost: %s ($%.0f/kg)\n', mat_names{min_cost_idx}, costs(min_cost_idx));
    
    % Calculate specific strength
    spec_strength = strengths ./ (densities / 1000);  % MPa/(g/cm³)
    [~, best_spec_idx] = max(spec_strength);
    fprintf('\nStrength-to-weight winner: %s (%.1f MPa·m³/kg)\n', ...
            mat_names{best_spec_idx}, spec_strength(best_spec_idx));
    
    % Visualize comparison
    figure('Name', '3D Printing Materials Comparison');
    
    subplot(2,2,1);
    bar(densities);
    set(gca, 'XTickLabel', mat_names);
    ylabel('Density (kg/m³)');
    title('Density Comparison');
    grid on;
    
    subplot(2,2,2);
    bar(strengths);
    set(gca, 'XTickLabel', mat_names);
    ylabel('Strength (MPa)');
    title('Strength Comparison');
    grid on;
    
    subplot(2,2,3);
    bar(melts);
    set(gca, 'XTickLabel', mat_names);
    ylabel('Temperature (°C)');
    title('Max Temperature');
    grid on;
    
    subplot(2,2,4);
    bar(costs);
    set(gca, 'XTickLabel', mat_names);
    ylabel('Cost ($/kg)');
    title('Material Cost');
    grid on;
end

%% Comparison 2: Structural Metals

function compare_structural_metals()
    % Define metal properties
    steel.name = 'Mild Steel';
    steel.density = 7850;
    steel.yield = 250;
    steel.ultimate = 400;
    steel.youngs = 200;
    steel.thermal = 50;
    steel.cost = 0.80;
    
    aluminum.name = 'Al 6061-T6';
    aluminum.density = 2700;
    aluminum.yield = 276;
    aluminum.ultimate = 310;
    aluminum.youngs = 69;
    aluminum.thermal = 167;
    aluminum.cost = 2.50;
    
    titanium.name = 'Ti 6Al-4V';
    titanium.density = 4430;
    titanium.yield = 880;
    titanium.ultimate = 950;
    titanium.youngs = 114;
    titanium.thermal = 7;
    titanium.cost = 25.00;
    
    % Calculate specific strength
    steel.spec_strength = steel.yield / steel.density;
    aluminum.spec_strength = aluminum.yield / aluminum.density;
    titanium.spec_strength = titanium.yield / titanium.density;
    
    % Create comparison matrix
    mat_names = {steel.name, aluminum.name, titanium.name};
    densities = [steel.density, aluminum.density, titanium.density];
    yields = [steel.yield, aluminum.yield, titanium.yield];
    ultimates = [steel.ultimate, aluminum.ultimate, titanium.ultimate];
    youngs_vals = [steel.youngs, aluminum.youngs, titanium.youngs];
    thermals = [steel.thermal, aluminum.thermal, titanium.thermal];
    costs = [steel.cost, aluminum.cost, titanium.cost];
    spec_strengths = [steel.spec_strength, aluminum.spec_strength, titanium.spec_strength];
    
    % Display table
    T = table(densities', yields', ultimates', youngs_vals', thermals', ...
              costs', spec_strengths', ...
              'VariableNames', {'Density', 'Yield_MPa', 'Ultimate_MPa', ...
                                'Youngs_GPa', 'Thermal_W_mK', 'Cost_USD', ...
                                'Spec_Strength'}, ...
              'RowNames', mat_names);
    
    disp('STRUCTURAL METAL COMPARISON');
    disp('===========================');
    disp(T);
    
    % Ranking by specific strength
    [sorted_spec, idx] = sort(spec_strengths, 'descend');
    fprintf('\nRanking by strength-to-weight:\n');
    for i = 1:length(idx)
        stars = repmat('★', 1, 6-i);
        fprintf('  %d. %s: %.1f MPa·m³/kg %s\n', ...
                i, mat_names{idx(i)}, sorted_spec(i)*1000, stars);
    end
    
    % Application recommendations
    fprintf('\nApplication recommendations:\n');
    fprintf('  Budget/strength: %s (cheapest, strong enough)\n', steel.name);
    fprintf('  Weight critical: %s (best specific strength)\n', titanium.name);
    fprintf('  Heat dissipation: %s (best thermal conductivity)\n', aluminum.name);
    fprintf('  Stiffness: %s (highest Young''s modulus)\n', steel.name);
    
    % Radar chart comparison
    figure('Name', 'Metal Properties Comparison');
    
    % Normalize properties for radar chart (0-1 scale)
    norm_density = 1 - (densities / max(densities));  % Lower is better
    norm_strength = yields / max(yields);
    norm_youngs = youngs_vals / max(youngs_vals);
    norm_thermal = thermals / max(thermals);
    norm_cost = 1 - (costs / max(costs));  % Lower is better
    norm_spec = spec_strengths / max(spec_strengths);
    
    % Create radar data
    radar_data = [norm_spec; norm_strength; norm_youngs; ...
                  norm_thermal; norm_cost; norm_density]';
    
    % Plot grouped bar chart instead (radar chart requires toolbox)
    categories = {'Spec Strength', 'Yield', 'Stiffness', ...
                  'Thermal', 'Cost', 'Density'};
    
    figure;
    bar(radar_data);
    set(gca, 'XTickLabel', categories);
    ylabel('Normalized Score (0-1)');
    title('Normalized Metal Properties');
    legend(mat_names, 'Location', 'best');
    grid on;
end

%% Comparison 3: Optimization Example

function optimize_material_selection()
    % Design problem: beam with constraints
    % Min strength: 400 MPa
    % Max density: 5000 kg/m³
    % Max cost: $10/kg
    
    disp('MATERIAL SELECTION WITH CONSTRAINTS');
    disp('===================================');
    fprintf('Requirements:\n');
    fprintf('  Min yield strength: 400 MPa\n');
    fprintf('  Max density: 5000 kg/m³\n');
    fprintf('  Max cost: $10/kg\n\n');
    
    % Define materials database
    materials = {};
    
    materials{1} = struct('name', 'Aluminum 7075', ...
                         'strength', 505, 'density', 2810, 'cost', 5);
    materials{2} = struct('name', 'Steel 4340', ...
                         'strength', 860, 'density', 7850, 'cost', 3);
    materials{3} = struct('name', 'Titanium 6Al-4V', ...
                         'strength', 880, 'density', 4430, 'cost', 25);
    materials{4} = struct('name', 'Aluminum 6061', ...
                         'strength', 276, 'density', 2700, 'cost', 2.5);
    materials{5} = struct('name', 'Magnesium AZ31', ...
                         'strength', 220, 'density', 1740, 'cost', 7);
    
    % Apply constraints
    min_strength = 400;
    max_density = 5000;
    max_cost = 10;
    
    feasible = [];
    
    for i = 1:length(materials)
        mat = materials{i};
        
        passes = (mat.strength >= min_strength) && ...
                (mat.density <= max_density) && ...
                (mat.cost <= max_cost);
        
        if passes
            mat.spec_strength = mat.strength / mat.density;
            feasible = [feasible; mat];
            fprintf('✓ PASS: %-20s (%.0f MPa, %.0f kg/m³, $%.2f/kg)\n', ...
                    mat.name, mat.strength, mat.density, mat.cost);
        else
            fprintf('✗ FAIL: %-20s ', mat.name);
            if mat.strength < min_strength
                fprintf('[strength too low] ');
            end
            if mat.density > max_density
                fprintf('[too heavy] ');
            end
            if mat.cost > max_cost
                fprintf('[too expensive]');
            end
            fprintf('\n');
        end
    end
    
    if ~isempty(feasible)
        fprintf('\n%d materials meet all constraints\n\n', length(feasible));
        
        % Rank by specific strength
        [~, idx] = sort([feasible.spec_strength], 'descend');
        
        fprintf('Ranking by strength-to-weight:\n');
        for i = 1:length(idx)
            mat = feasible(idx(i));
            fprintf('  %d. %-20s (%.1f MPa·m³/kg)\n', ...
                    i, mat.name, mat.spec_strength * 1000);
        end
        
        best = feasible(idx(1));
        fprintf('\n✓ RECOMMENDATION: %s\n', best.name);
        fprintf('  Best strength-to-weight ratio\n');
        fprintf('  Meets all constraints\n');
    else
        fprintf('\n✗ No materials meet all constraints!\n');
        fprintf('  Consider relaxing requirements\n');
    end
end

%% Multi-Criteria Decision Matrix

function ashby_plot()
    % Create Ashby-style material selection chart
    % Strength vs. Density
    
    % Material data
    names = {'Steel', 'Al 6061', 'Al 7075', 'Ti 6-4', 'Mg AZ31', ...
             'PLA', 'ABS', 'PEEK', 'CF Woven'};
    
    densities = [7850, 2700, 2810, 4430, 1740, ...
                1240, 1060, 1320, 1600];
    
    strengths = [250, 276, 505, 880, 220, ...
                 50, 45, 90, 600];
    
    costs = [0.8, 2.5, 5, 25, 7, ...
             20, 22, 100, 40];
    
    categories = [1 1 1 1 1 2 2 2 2];  % 1=metal, 2=plastic
    
    figure('Name', 'Ashby Chart: Strength vs. Density');
    
    % Plot metals
    metal_idx = (categories == 1);
    scatter(densities(metal_idx), strengths(metal_idx), 100, 'b', 'filled');
    hold on;
    
    % Plot plastics
    plastic_idx = (categories == 2);
    scatter(densities(plastic_idx), strengths(plastic_idx), 100, 'r', 'filled');
    
    % Add labels
    for i = 1:length(names)
        text(densities(i)*1.05, strengths(i), names{i}, 'FontSize', 9);
    end
    
    % Draw constant specific strength lines
    rho_range = [500, 10000];
    spec_strengths = [0.05, 0.1, 0.2, 0.4];  % MPa/(kg/m³)
    
    for s = spec_strengths
        strength_line = s * rho_range;
        plot(rho_range, strength_line, 'k--', 'LineWidth', 0.5);
        text(rho_range(2)*0.9, strength_line(2)*1.1, ...
             sprintf('%.2f', s), 'FontSize', 8, 'Color', [0.5 0.5 0.5]);
    end
    
    xlabel('Density (kg/m³)');
    ylabel('Yield Strength (MPa)');
    title('Material Selection: Strength vs. Density');
    legend({'Metals', 'Plastics'}, 'Location', 'northwest');
    grid on;
    set(gca, 'XScale', 'log', 'YScale', 'log');
    
    % Cost vs. Performance plot
    figure('Name', 'Cost vs. Performance');
    
    spec_strengths = strengths ./ densities * 1000;  % Specific strength
    
    scatter(costs, spec_strengths, 100, densities, 'filled');
    colorbar;
    colormap(jet);
    
    for i = 1:length(names)
        text(costs(i)*1.1, spec_strengths(i), names{i}, 'FontSize', 9);
    end
    
    xlabel('Cost ($/kg)');
    ylabel('Specific Strength (MPa·m³/kg)');
    title('Cost vs. Performance Trade-off');
    grid on;
    set(gca, 'XScale', 'log', 'YScale', 'log');
end

%% Temperature-Dependent Properties

function thermal_analysis()
    % Temperature-dependent thermal conductivity
    % Example: Aluminum
    
    T_range = 20:20:200;  % Temperature in °C
    T_kelvin = T_range + 273.15;
    
    % Approximate temperature dependence
    % k(T) = k0 + alpha*T (linear approximation)
    k0_aluminum = 237;  % W/(m·K) at 293K
    alpha_aluminum = 0.1;  % Approximate coefficient
    
    k_aluminum = k0_aluminum + alpha_aluminum * (T_kelvin - 293);
    
    % For steel
    k0_steel = 50;
    alpha_steel = -0.02;
    k_steel = k0_steel + alpha_steel * (T_kelvin - 293);
    
    % For copper
    k0_copper = 385;
    alpha_copper = -0.05;
    k_copper = k0_copper + alpha_copper * (T_kelvin - 293);
    
    % Plot
    figure('Name', 'Temperature-Dependent Thermal Conductivity');
    
    plot(T_range, k_aluminum, 'b-o', 'LineWidth', 2, 'DisplayName', 'Aluminum');
    hold on;
    plot(T_range, k_steel, 'r-s', 'LineWidth', 2, 'DisplayName', 'Steel');
    plot(T_range, k_copper, 'g-^', 'LineWidth', 2, 'DisplayName', 'Copper');
    
    xlabel('Temperature (°C)');
    ylabel('Thermal Conductivity (W/m·K)');
    title('Temperature-Dependent Properties');
    legend('Location', 'best');
    grid on;
    
    % Create table
    T_table = table(T_range', k_aluminum', k_steel', k_copper', ...
                   'VariableNames', {'Temp_C', 'Al_W_mK', 'Steel_W_mK', 'Cu_W_mK'});
    
    disp('TEMPERATURE-DEPENDENT CONDUCTIVITY');
    disp('==================================');
    disp(T_table);
end

%% Main execution

function main()
    % Run all comparison examples
    
    fprintf('\n');
    fprintf('============================================\n');
    fprintf('MATLAB Material Comparison Examples\n');
    fprintf('Equivalent to MatLabC++ functionality\n');
    fprintf('============================================\n\n');
    
    % Example 1: 3D Printing
    compare_3d_printing_materials();
    fprintf('\nPress Enter to continue...\n');
    pause;
    
    % Example 2: Structural Metals
    compare_structural_metals();
    fprintf('\nPress Enter to continue...\n');
    pause;
    
    % Example 3: Constraint Optimization
    optimize_material_selection();
    fprintf('\nPress Enter to continue...\n');
    pause;
    
    % Example 4: Ashby Charts
    ashby_plot();
    fprintf('\nPress Enter to continue...\n');
    pause;
    
    % Example 5: Temperature Effects
    thermal_analysis();
    
    fprintf('\n');
    fprintf('============================================\n');
    fprintf('All MATLAB examples completed!\n');
    fprintf('============================================\n\n');
    
    fprintf('Key differences MatLabC++ vs. MATLAB:\n');
    fprintf('  - MatLabC++ has built-in material database\n');
    fprintf('  - MATLAB requires manual data entry\n');
    fprintf('  - MatLabC++ includes inference engine\n');
    fprintf('  - MATLAB needs custom comparison functions\n');
    fprintf('  - MatLabC++ is ~500MB, MATLAB is ~18GB\n');
    fprintf('  - MatLabC++ is free, MATLAB is $2,150/year\n\n');
end

% Run main function
main();
