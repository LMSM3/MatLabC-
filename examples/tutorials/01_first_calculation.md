# Tutorial 1: Your First Calculation

## Goal
Get MatLabC++ running and perform your first calculation in under 5 minutes.

## Steps

### 1. Build the project
```bash
./scripts/build_cpp.sh
```

Wait ~10 seconds. You should see "Build successful".

### 2. Run the program
```bash
cd build
./matlabcpp
```

You'll see a welcome banner.

### 3. Try your first command
Type:
```
constant pi
```

Result:
```
pi = 3.141593
```

### 4. Get a material property
```
material pla
```

Result:
```
PLA - 3D printing plastic
Density: 1240 kg/m³
Melts at: 180°C
```

### 5. Do a physics calculation
```
drop 100
```

Result:
```
Dropping from 100m...
Time: 4.52 seconds
Velocity: 44.3 m/s
```

## Done!

You just:
- ✓ Got a physical constant
- ✓ Looked up material properties
- ✓ Solved a physics problem

No MATLAB license. No 18 GB install. Just worked.

## Next Steps
- Try `help` to see all commands
- Type `examples` for more
- Open Tutorial 2 to learn the material database

## Troubleshooting

**"Command not found"**
- Make sure you're in the `build` directory
- Try `./matlabcpp` with the `./` prefix

**"Build failed"**
- Install g++ or clang: `sudo apt install build-essential`
- Or on Mac: `brew install cmake`

**"Material not found"**
- Type `list materials` to see what's available
- Material names are lowercase: `pla` not `PLA`
