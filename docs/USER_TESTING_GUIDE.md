# User Testing Guide (Debian & RHEL)

This guide walks through a clean end-to-end test of MatLabC++ on Debian-based and RHEL-based systems.

---

## 1) Debian / Ubuntu

### Prerequisites
```bash
sudo apt update
sudo apt install -y build-essential cmake git libcairo2-dev libfreetype6-dev
```

### Build
```bash
git clone https://github.com/LMSM3/MatLabC-
cd MatLabC-
cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_PLOTTING=ON -DWITH_CAIRO=ON
cmake --build build -j$(nproc)
```

### Run (Interactive)
```bash
./build/mlab++
```

### Run (Script)
```bash
./build/mlab++ projectile_motion_physics.m
```

### Publish Report
```bash
./build/mlab++ publish projectile_motion_physics.m
```

### Validate Output
- `projectile_motion_physics.html` is generated
- `projectile_motion_analysis.png` or `figure.png` output is present (if script calls `print`)

---

## 2) RHEL / CentOS / Rocky / AlmaLinux

### Prerequisites
```bash
sudo dnf install -y gcc gcc-c++ make cmake git cairo-devel freetype-devel
```

### Build
```bash
git clone https://github.com/LMSM3/MatLabC-
cd MatLabC-
cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_PLOTTING=ON -DWITH_CAIRO=ON
cmake --build build -j$(nproc)
```

### Run (Interactive)
```bash
./build/mlab++
```

### Run (Script)
```bash
./build/mlab++ projectile_motion_physics.m
```

### Publish Report
```bash
./build/mlab++ publish projectile_motion_physics.m
```

### Validate Output
- `projectile_motion_physics.html` is generated
- `projectile_motion_analysis.png` or `figure.png` output is present (if script calls `print`)

---

## Quick Functional Checks

Inside the REPL, run:
```
>> x = [1 2 3 4 5]
>> sum(x)
>> mean(x)
>> sin(pi/2)
```

Expected behavior:
- `sum(x)` returns `15`
- `mean(x)` returns `3`
- `sin(pi/2)` returns `1`

---

## Troubleshooting

- **CMake can’t find Cairo**: ensure `libcairo2-dev` (Debian) or `cairo-devel` (RHEL) is installed.
- **Fonts missing**: install `ttf-mscorefonts-installer` (Debian) or `msttcorefonts` via EPEL (RHEL).
- **Script path not found**: run from repo root or pass a full path.
