# MatLabC++ for Normal Engineers

## You Just Want to Do Some Calculations

Not much required. Not a MATLAB license, just your windows(prefered) or mac or linux PC.

---

## The Absolute Basics

### What is this?
A free calculator that knows physics, materials, and can solve equations. Think "MATLAB lite" but actually works on your laptop.

### Why should I care?
- Use MatLab regularly or somewhat regularly
- You have homework/work that needs ODEs solved
- You need quick access to reliable material properties (density, melting point, etc.)
- You want quick physics calculations
- Your laptop has <16 GB RAM (MATLAB won't work)
- You're not paying $2,150 for software ? 

---

## Install (Seriously Just 3 Commands)

```bash
# 1. Download this project (you probably did this already)

# 2. Build it (takes 10 seconds)
./scripts/build_cpp.sh

# 3. Run it
cd build
./matlabcpp
```

That's it. No "activate license", no "create account", no nothing.

---

## Your First 5 Minutes

### Try These Commands

```
>>> help
(Shows what you can do)

>>> examples
(Shows real examples)

>>> constant g
9.80665 m/s²

>>> material pla
PLA - 3D printing plastic
Density: 1240 kg/m³
Melts at: 180°C

>>> drop 100
Dropping from 100m...
Time: 4.52 seconds
Velocity: 44.3 m/s

>>> identify 2700
Best match: Aluminum
Confidence: 98%
```

See? Not scary.

---

## Common Tasks (Copy-Paste Ready)

### "I need to know if this material melts"
```
>>> material peek
Melts at: 343°C
```
If your process is <343°C, you're good.

### "How fast does something fall?"
```
>>> drop 50
Time to ground: 3.19 s
```

### "What's the density of aluminum?"
```
>>> density aluminum
2700 kg/m³
```

### "I have a material with density 1240, what is it?"
```
>>> identify 1240
PLA (3D printing)
```

---

## For Jupyter Users (Even Easier)

Open `notebooks/QuickStart.ipynb` and run:

```python
import matlabcpp as ml

# Get values
g = ml.constant('g')
pi = ml.constant('pi')

# Check material
pla = ml.material('pla')
print(f"PLA density: {pla['density']} kg/m³")

# Run simulation  
result = ml.drop(100)
print(f"Falls in {result['time']} seconds")

# Quick physics
v_terminal = ml.terminal_velocity(mass=70)
print(f"Skydiver terminal velocity: {v_terminal} m/s")
```

No CLI needed. Just code cells.

---

## "What Can I Actually Do With This?"

### Homework Problems
- Solve ODEs (differential equations)
- Calculate trajectories
- Check physics answers
- Look up constants

### Material Selection
- Compare plastics for 3D printing
- Check temperature limits
- Find density/strength values
- Identify unknown materials

### Quick Engineering
- Estimate fall times
- Calculate forces
- Check Reynolds numbers
- Thermal calculations

### Real Example: "Can I Use PLA Outside?"
```python
import matlabcpp as ml

pla = ml.material('pla')
outdoor_summer_temp = 70  # Celsius

if outdoor_summer_temp < pla['melts_at'] - 30:  # 30°C safety margin
    print("PLA is safe")
else:
    print(f"Use PETG instead (melts at {ml.material('petg')['melts_at']}°C)")
```

Done. No guessing.

---

## Troubleshooting

### "I get an error when building"
Make sure you have:
- A C++ compiler (g++, clang, or MSVC)
- CMake installed

On Ubuntu: `sudo apt install build-essential cmake`  
On Mac: `brew install cmake`  
On Windows: Install Visual Studio

### "Command not found"
You're probably not in the build directory:
```bash
cd build
./matlabcpp
```

### "Python import doesn't work"
Make sure you're in the notebooks directory:
```bash
cd notebooks
jupyter notebook QuickStart.ipynb
```

---

## FAQ for People Who Just Want Answers

**Q: Is this legal to use for work/school?**  
A: Yes. MIT license = use anywhere.

**Q: Will this break my computer?**  
A: No. It's just a calculator. Uses <50 MB RAM.

**Q: Do I need to learn C++?**  
A: No. Just use the commands or Python interface.

**Q: Can I add my own materials?**  
A: Yes, but that requires editing a file. Ask if you need help.

**Q: Why is MATLAB better?**  
A: MATLAB has more features (signal processing, control toolboxes, Simulink). But for basic numerical work? This is fine and free.

**Q: Can I make graphs?**  
A: Not built-in, but use Python/matplotlib (see QuickStart notebook).

**Q: How do I cite this?**  
A: See README.md for citation format.

---

## Next Steps

### If you liked this:
1. Read `QUICKREF.md` for full command list
2. Open `notebooks/QuickStart.ipynb` for interactive examples
3. Try solving your actual problem

### If you want more:
- Check out the advanced notebooks (GPU computing, error estimation)
- Extend it with your own materials/constants
- Read the technical papers included

### If you're stuck:
- Type `help` in the tool
- Look at `examples`
- Check GitHub discussions

---

## The Point

You have a laptop. You have calculations to do. You don't have $2,150 or 18 GB of disk space for MATLAB.

This tool exists for you.

**No excuses. No barriers. Just engineering.**

---

Questions? Just type what you want to know:
- "What is pi?"
- "density of aluminum?"  
- "material peek"
- "drop 100"

The tool figures it out.

**Welcome to numerical computing that actually works on your laptop.**
