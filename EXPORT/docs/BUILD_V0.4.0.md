# BUILD v0.4.0 NOW

## What Changed
- Debug flags **ENABLED** by default
- Version bumped: 0.3.1 → **0.4.0**
- 6 new files created (value, parser, debug)

## Build Commands

```bash
cd /mnt/c/Users/Liam/Desktop/MatLabC++
rm -rf build
./build_and_setup.sh
./build/mlab++ --version
```

**Expected:** "MatLabC++ version 0.4.0"

## New Features Available

### Matrix Creation
```cpp
>>> A = [1 2 3; 4 5 6]
A = 
    1.0000    2.0000    3.0000
    4.0000    5.0000    6.0000
 -- #
```

### Visual Debugging (Now ON)
- `|` after vectors
- `--` after matrices
- `#` when variable created
- Red text for NaN/corrupt values
- Yellow text for Inf values

### Toggle Debug
```bash
echo "disabled" > debug.cfg  # Turn off
echo "enabled" > debug.cfg   # Turn on (default)
```

## That's It

Build, test, ship. 🚀
