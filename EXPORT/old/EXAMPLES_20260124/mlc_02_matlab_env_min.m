% mlc_02_matlab_env_min.m
% Minimal: hints about environment + desktop/headless + product count + license

fprintf("Release: %s\n", version('-release'));
fprintf("Full: %s\n", version);

fprintf("UseDesktop: %d\n", usejava('desktop'));

p = ver;
fprintf("Products detected: %d\n", numel(p));

try
    fprintf("License: %s\n", license('inuse'));
catch
    fprintf("License: (unavailable)\n");
end
