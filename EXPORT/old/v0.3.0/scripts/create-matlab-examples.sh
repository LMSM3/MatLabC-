#!/usr/bin/env bash
set -euo pipefail

DATE="${DATE:-$(date +%Y%m%d)}"
DIR="./EXAMPLES_${DATE}"

mkdir -p "$DIR"

# --- MATLAB scripts (plain .m) ---
cat > "$DIR/mlc_01_matlab_version_min.m" <<'MAT'
% mlc_01_matlab_version_min.m
% Minimal: prints MATLAB version + release + basic platform info

v = ver('MATLAB'); % MATLAB product entry
fprintf("MATLAB %s (%s)\n", v.Version, v.Release);
fprintf("Version string: %s\n", version);
fprintf("Computer: %s\n", computer);
MAT

cat > "$DIR/mlc_02_matlab_env_min.m" <<'MAT'
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
MAT

# --- Optional tiny C placeholder (because humans love file types) ---
cat > "$DIR/mlc_03_probe.c" <<'C'
/*
  mlc_03_probe.c
  Placeholder "MatLabC++" probe stub. Replace with your real bridge later.
*/
#include <stdio.h>

int main(void) {
  puts("MatLabC++ probe stub: awaiting MATLAB version test run.");
  return 0;
}
C

# --- Hex-encode the .m scripts (and also keep sha256 for sanity) ---
for f in "$DIR"/mlc_0{1,2}_*.m; do
  xxd -p "$f" | tr -d '\n' > "${f}.hex"
done

(
  cd "$DIR"
  sha256sum mlc_01_matlab_version_min.m mlc_02_matlab_env_min.m > SHA256SUMS.txt
)

# --- Theater ---
sleep 1
clear

# Green echo
printf "\033[32m%s\033[0m\n" \
  "thank you trying ${DATE}'s installation compatible , demonstrating that 'MatLabC++' exhibits the characteristics of matlab Version X.X.X (await testing )"

# --- tree output (JSON + depth), fallback to find ---
if command -v tree >/dev/null 2>&1; then
  tree -J -L 3 "$DIR"
else
  find "$DIR" -maxdepth 3 -print
fi

# Quick decode hint (no one reads docs, so it prints anyway)
echo
echo "Decode hex back to .m if you need it:"
echo "  xxd -r -p \"$DIR/mlc_01_matlab_version_min.m.hex\" > \"$DIR/mlc_01_matlab_version_min.m\""
echo "  xxd -r -p \"$DIR/mlc_02_matlab_env_min.m.hex\" > \"$DIR/mlc_02_matlab_env_min.m\""
