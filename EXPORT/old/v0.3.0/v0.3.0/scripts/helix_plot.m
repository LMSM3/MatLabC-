% helix_plot.m - 3D helix visualization
t = 0:pi/50:10*pi;
x = sin(t); 
y = cos(t); 
z = t;

% Generate data file
fid = fopen('helix_data.csv', 'w');
fprintf(fid, '# t, x, y, z\n');
for i = 1:length(t)
    fprintf(fid, '%.6f, %.6f, %.6f, %.6f\n', t(i), x(i), y(i), z(i));
end
fclose(fid);

disp('Helix data exported to helix_data.csv');
disp(['Points: ' num2str(length(t))]);
