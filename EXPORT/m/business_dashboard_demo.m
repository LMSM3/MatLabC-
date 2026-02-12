% business_dashboard_demo.m
% Demonstrates business-style plotting for presentations
%
% Run with: mlab++ business_dashboard_demo.m --visual --theme business

disp('MatLabC++ Business Dashboard Demo');
disp('==================================');
disp('');

% ========== SAMPLE BUSINESS DATA ==========
quarters = {'Q1 2023', 'Q2 2023', 'Q3 2023', 'Q4 2023'};
months = 1:12;
month_names = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

% Revenue data (millions)
revenue = [4.2, 4.5, 4.8, 5.1, 5.3, 5.6, 5.8, 6.1, 6.3, 6.6, 6.9, 7.2];
revenue_quarterly = [13.5, 16.0, 18.2, 20.7];

% Customer acquisition
customers = [12500, 13200, 14100, 15300, 16800, 18500, ...
             20400, 22500, 24800, 27200, 29800, 32500];

% Cost breakdown
labor_costs = [1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9];
material_costs = [1.2, 1.3, 1.3, 1.4, 1.4, 1.5, 1.5, 1.6, 1.6, 1.7, 1.7, 1.8];
overhead = [0.8, 0.8, 0.9, 0.9, 0.9, 1.0, 1.0, 1.1, 1.1, 1.1, 1.2, 1.2];

% Profit margin
margin = ((revenue - labor_costs - material_costs - overhead) ./ revenue) * 100;

% ========== EXECUTIVE DASHBOARD ==========
disp('1. Creating Executive Dashboard');
disp('-------------------------------');

figure('Position', [100, 100, 1400, 900]);
set(gcf, 'Theme', 'business');
set(gcf, 'Color', 'white');

% Create tiled layout (2x2 dashboard)
tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'normal');

% ------ Panel 1: Quarterly Revenue (Bar Chart) ------
nexttile;
bar(revenue_quarterly, 'FaceColor', '#0072BD', 'EdgeColor', 'none', 'BarWidth', 0.6);
set(gca, 'XTickLabel', quarters);
ylabel('Revenue ($M)', 'FontSize', 11);
title('Quarterly Revenue Growth', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
ylim([0, 25]);

% Add value labels on bars
for i = 1:length(revenue_quarterly)
    text(i, revenue_quarterly(i) + 0.5, sprintf('$%.1fM', revenue_quarterly(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

% ------ Panel 2: Customer Acquisition (Line Chart) ------
nexttile;
plot(months, customers / 1000, 'LineWidth', 3, 'Color', '#77AC30', 'Marker', 'o', ...
     'MarkerSize', 6, 'MarkerFaceColor', '#77AC30');
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', month_names);
ylabel('Customers (thousands)', 'FontSize', 11);
title('Customer Base Growth', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
ylim([0, 35]);

% Highlight growth rate
growth_rate = ((customers(end) - customers(1)) / customers(1)) * 100;
text(6, 30, sprintf('Growth: +%.0f%%', growth_rate), ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', '#77AC30', ...
     'HorizontalAlignment', 'center');

% ------ Panel 3: Cost Structure (Stacked Area) ------
nexttile;
area(months, [labor_costs', material_costs', overhead'], ...
     'FaceAlpha', 0.7, 'EdgeColor', 'none');
colororder(['#D95319'; '#EDB120'; '#7E2F8E']);
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', month_names);
ylabel('Costs ($M)', 'FontSize', 11);
title('Operating Cost Breakdown', 'FontSize', 12, 'FontWeight', 'bold');
legend('Labor', 'Materials', 'Overhead', 'Location', 'northwest', 'FontSize', 10);
grid on;

% ------ Panel 4: Profit Margin (%) ------
nexttile;
plot(months, margin, 'LineWidth', 3, 'Color', '#0072BD', 'Marker', 's', ...
     'MarkerSize', 6, 'MarkerFaceColor', '#0072BD');
hold on;
plot([1, 12], [25, 25], 'k--', 'LineWidth', 1.5);
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', month_names);
ylabel('Profit Margin (%)', 'FontSize', 11);
title('Profitability Trend', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
ylim([0, 35]);

text(6, 27, 'Target: 25%', 'FontSize', 10, 'HorizontalAlignment', 'center');

% Export dashboard
fprintf('Exporting business_dashboard.png (150 DPI)...\n');
exportgraphics(gcf, 'business_dashboard.png', 'Resolution', 150);

disp('✓ Executive dashboard exported');
disp('');

% ========== SINGLE CHART: REVENUE FORECAST ==========
disp('2. Creating Revenue Forecast Chart');
disp('-----------------------------------');

figure('Position', [150, 150, 900, 600]);
set(gcf, 'Theme', 'business');

% Historical + forecast
forecast_months = 13:18;
forecast_revenue = [7.5, 7.8, 8.1, 8.4, 8.7, 9.0];
all_months = 1:18;

% Plot historical
plot(months, revenue, 'LineWidth', 3, 'Color', '#0072BD', 'Marker', 'o', ...
     'MarkerSize', 8, 'MarkerFaceColor', '#0072BD');
hold on;

% Plot forecast with different style
plot(forecast_months, forecast_revenue, 'LineWidth', 3, 'Color', '#D95319', ...
     'LineStyle', '--', 'Marker', 's', 'MarkerSize', 8, 'MarkerFaceColor', '#D95319');

% Confidence interval
upper = forecast_revenue + 0.5;
lower = forecast_revenue - 0.5;
fill([forecast_months, fliplr(forecast_months)], [upper, fliplr(lower)], ...
     '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none');

% Labels
xlabel('Month', 'FontSize', 11);
ylabel('Revenue ($M)', 'FontSize', 11);
title('Revenue Performance and 6-Month Forecast', 'FontSize', 12, 'FontWeight', 'bold');

% Legend
legend('Historical', 'Forecast', 'Confidence Interval', ...
       'Location', 'northwest', 'FontSize', 10);

% Grid
grid on;
set(gca, 'XTick', [1, 3, 6, 9, 12, 15, 18]);
set(gca, 'XTickLabel', {'Jan ''23', 'Mar', 'Jun', 'Sep', 'Dec', 'Mar ''24', 'Jun'});
xlim([0, 19]);
ylim([0, 10]);

% Export
fprintf('Exporting revenue_forecast.png (150 DPI)...\n');
exportgraphics(gcf, 'revenue_forecast.png', 'Resolution', 150);
exportgraphics(gcf, 'revenue_forecast.svg', 'ContentType', 'vector');

disp('✓ Revenue forecast chart exported');
disp('');

% ========== PIE CHART: MARKET SHARE ==========
disp('3. Creating Market Share Visualization');
disp('---------------------------------------');

figure('Position', [200, 200, 800, 600]);
set(gcf, 'Theme', 'business');

% Market share data
companies = {'Our Company', 'Competitor A', 'Competitor B', 'Competitor C', 'Others'};
share = [28, 24, 18, 15, 15];
colors = ['#0072BD'; '#D95319'; '#EDB120'; '#7E2F8E'; '#A2142F'];

% Pie chart
pie(share);
colormap(colors);
title('Market Share Q4 2023', 'FontSize', 12, 'FontWeight', 'bold');

% Custom legend
legend(companies, 'Location', 'eastoutside', 'FontSize', 10);

% Export
fprintf('Exporting market_share.png (150 DPI)...\n');
exportgraphics(gcf, 'market_share.png', 'Resolution', 150);

disp('✓ Market share visualization exported');
disp('');

% ========== SCATTER: CUSTOMER LIFETIME VALUE ==========
disp('4. Creating Customer Analysis Scatter Plot');
disp('------------------------------------------');

figure('Position', [250, 250, 800, 600]);
set(gcf, 'Theme', 'business');

% Sample customer data
n_customers = 100;
acquisition_cost = 50 + 150 * rand(n_customers, 1);
lifetime_value = 200 + 800 * rand(n_customers, 1);
segment = randi([1, 3], n_customers, 1);  % Customer segments

% Scatter plot with different colors for segments
colors_seg = ['#0072BD'; '#77AC30'; '#D95319'];
hold on;
for i = 1:3
    idx = segment == i;
    scatter(acquisition_cost(idx), lifetime_value(idx), 100, colors_seg(i, :), ...
            'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.7);
end

% Break-even line
plot([0, 200], [0, 200], 'k--', 'LineWidth', 2);

% Labels
xlabel('Customer Acquisition Cost ($)', 'FontSize', 11);
ylabel('Lifetime Value ($)', 'FontSize', 11);
title('Customer Value Analysis', 'FontSize', 12, 'FontWeight', 'bold');
legend('Enterprise', 'Mid-Market', 'SMB', 'Break-even', ...
       'Location', 'northwest', 'FontSize', 10);
grid on;

% Export
fprintf('Exporting customer_analysis.png (150 DPI)...\n');
exportgraphics(gcf, 'customer_analysis.png', 'Resolution', 150);

disp('✓ Customer analysis scatter plot exported');
disp('');

% ========== SUMMARY ==========
disp('Business Dashboard Demo Complete');
disp('=================================');
disp('');
disp('Generated files:');
disp('  1. business_dashboard.png (4-panel executive view)');
disp('  2. revenue_forecast.png (with confidence interval)');
disp('  3. revenue_forecast.svg (vector for presentations)');
disp('  4. market_share.png (pie chart)');
disp('  5. customer_analysis.png (scatter plot)');
disp('');
disp('Business theme features used:');
disp('  ✓ Clean Arial font (presentation standard)');
disp('  ✓ 150 DPI export (screen/presentation quality)');
disp('  ✓ Lighter grid (less visual noise)');
disp('  ✓ Corporate color scheme');
disp('  ✓ Value labels on charts');
disp('  ✓ Tiled dashboard layout');
disp('  ✓ Confidence intervals');
disp('  ✓ Clear legends and titles');
disp('');
disp('Ready for:');
disp('  • PowerPoint presentations');
disp('  • Executive reports');
disp('  • Quarterly reviews');
disp('  • Investor decks');
disp('');
