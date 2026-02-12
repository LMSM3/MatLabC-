% mlc_01_matlab_version_min.m
% Minimal: prints MATLAB version + release + basic platform info

v = ver('MATLAB'); % MATLAB product entry
fprintf("MATLAB %s (%s)\n", v.Version, v.Release);
fprintf("Version string: %s\n", version);
fprintf("Computer: %s\n", computer);
