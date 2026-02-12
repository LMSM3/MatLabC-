"""
MatLabC++ Python Wrapper
Easy access to C++ numerical engine from Python/Jupyter

Perfect for engineers who:
- Don't want to install MATLAB (18GB+)
- Need quick calculations in notebooks
- Want a lightweight solution (<50 MB)
- Work on laptops with limited RAM
"""

import subprocess
import json
from pathlib import Path

class MatLabCPP:
    """Simple Python interface to MatLabC++ CLI"""
    
    def __init__(self, exe_path="build/matlabcpp"):
        self.exe = Path(exe_path)
        if not self.exe.exists():
            self.exe = Path("../build/matlabcpp")
        if not self.exe.exists():
            raise FileNotFoundError(
                "MatLabC++ executable not found. Run: ./scripts/build_cpp.sh"
            )
    
    def _run(self, *args):
        """Run command and return output"""
        result = subprocess.run(
            [str(self.exe)] + list(args),
            capture_output=True,
            text=True
        )
        return result.stdout.strip()
    
    def constant(self, name):
        """Get physical constant value"""
        output = self._run("constant", name)
        try:
            # Parse "name = value" format
            value_str = output.split("=")[1].strip()
            return float(value_str)
        except:
            return None
    
    def material(self, name):
        """Get material properties as dict"""
        output = self._run("material", name)
        lines = output.split('\n')
        
        props = {}
        for line in lines:
            if ':' in line:
                key, val = line.split(':', 1)
                key = key.strip().lower().replace(' ', '_')
                val = val.strip().split()[0]  # Take first number
                try:
                    props[key] = float(val)
                except:
                    props[key] = val
        
        return props if props else None
    
    def drop(self, height):
        """Simulate object drop, return time and velocity"""
        output = self._run("drop", str(height))
        
        time = None
        velocity = None
        
        for line in output.split('\n'):
            if 'Time to ground' in line:
                time = float(line.split(':')[1].strip().split()[0])
            if 'Final velocity' in line:
                velocity = float(line.split(':')[1].strip().split()[0])
        
        return {'time': time, 'velocity': velocity}
    
    def identify(self, density):
        """Identify material from density"""
        output = self._run("identify", str(density))
        
        material = None
        confidence = None
        
        for line in output.split('\n'):
            if 'Best match' in line:
                material = line.split(':')[1].strip()
            if 'Confidence' in line:
                confidence = float(line.split(':')[1].strip().rstrip('%'))
        
        return {'material': material, 'confidence': confidence}

# Convenience functions for Jupyter
_mlab = None

def init():
    """Initialize MatLabC++ (call once)"""
    global _mlab
    _mlab = MatLabCPP()
    return _mlab

def constant(name):
    """Get constant: constant('g') -> 9.80665"""
    if _mlab is None:
        init()
    return _mlab.constant(name)

def material(name):
    """Get material: material('peek') -> {...}"""
    if _mlab is None:
        init()
    return _mlab.material(name)

def drop(height):
    """Drop simulation: drop(100) -> {'time': 4.52, 'velocity': 44.3}"""
    if _mlab is None:
        init()
    return _mlab.drop(height)

def identify(density):
    """Identify material: identify(2700) -> {'material': 'aluminum', 'confidence': 98}"""
    if _mlab is None:
        init()
    return _mlab.identify(density)

# Physics constants (cached)
class Constants:
    """Quick access to constants"""
    g = 9.80665
    G = 6.67430e-11
    pi = 3.141592653589793
    e = 2.718281828459045
    c = 299792458.0
    k_B = 1.380649e-23
    N_A = 6.02214076e23
    R = 8.314462618

# Quick calculations
def terminal_velocity(mass, area=0.5, Cd=1.0, rho=1.225):
    """Calculate terminal velocity
    
    Args:
        mass: kg
        area: m² (default 0.5 m² - human)
        Cd: drag coefficient (default 1.0)
        rho: air density kg/m³ (default 1.225)
    
    Returns:
        velocity in m/s
    """
    g = 9.81
    return (2 * mass * g / (rho * Cd * area)) ** 0.5

def reynolds_number(velocity, length, nu=1.5e-5):
    """Calculate Reynolds number
    
    Args:
        velocity: m/s
        length: m (characteristic length)
        nu: kinematic viscosity m²/s (default air at 20°C)
    
    Returns:
        Reynolds number (dimensionless)
    """
    return velocity * length / nu

def heat_time(mass, cp, T_initial, T_final, h=10, area=0.1, T_env=293):
    """Estimate cooling/heating time
    
    Args:
        mass: kg
        cp: specific heat J/(kg·K)
        T_initial: K
        T_final: K
        h: heat transfer coefficient W/(m²·K)
        area: surface area m²
        T_env: environment temperature K
    
    Returns:
        time in seconds
    """
    import math
    tau = mass * cp / (h * area)
    return -tau * math.log((T_final - T_env) / (T_initial - T_env))

# Example usage for notebooks
def demo():
    """Show example usage"""
    print("MatLabC++ Python Interface Demo")
    print("=" * 50)
    
    print("\n1. Physical constants:")
    print(f"   g = {constant('g')} m/s²")
    print(f"   ? = {constant('pi')}")
    
    print("\n2. Material properties:")
    peek = material('peek')
    if peek:
        print(f"   PEEK density: {peek.get('density', 'N/A')} kg/m³")
    
    print("\n3. Drop simulation:")
    result = drop(100)
    print(f"   Drop from 100m: {result['time']:.2f}s, {result['velocity']:.1f} m/s")
    
    print("\n4. Material identification:")
    match = identify(2700)
    print(f"   Density 2700 kg/m³: {match['material']} ({match['confidence']:.0f}% confidence)")
    
    print("\n5. Quick calculations:")
    print(f"   Terminal velocity (70kg person): {terminal_velocity(70):.1f} m/s")
    print(f"   Reynolds number (car at 30 m/s): {reynolds_number(30, 2):.0f}")

if __name__ == "__main__":
    demo()
