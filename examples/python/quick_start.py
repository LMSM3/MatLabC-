#!/usr/bin/env python3
"""
MatLabC++ Quick Start Examples
Demonstrates basic functionality for new users
"""

import sys
import os

# Add parent directory to path to import matlabcpp
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'notebooks'))

import matlabcpp as ml

def example_1_constants():
    """Get physical constants"""
    print("=" * 60)
    print("Example 1: Physical Constants")
    print("=" * 60)
    
    g = ml.constant('g')
    pi = ml.constant('pi')
    c = ml.constant('c')
    
    print(f"Gravity:        {g:.6f} m/s²")
    print(f"Pi:             {pi:.6f}")
    print(f"Speed of light: {c:.3e} m/s")
    print()

def example_2_materials():
    """Look up material properties"""
    print("=" * 60)
    print("Example 2: Material Properties")
    print("=" * 60)
    
    # Get PLA properties
    pla = ml.material('pla')
    print(f"PLA Properties:")
    print(f"  Density:  {pla['density']} kg/m³")
    print(f"  Melts at: {pla['melts_at']}°C")
    print(f"  Category: {pla['category']}")
    print()
    
    # Compare with PETG
    petg = ml.material('petg')
    print(f"PETG Properties:")
    print(f"  Density:  {petg['density']} kg/m³")
    print(f"  Melts at: {petg['melts_at']}°C")
    print()
    
    # Decision
    outdoor_temp = 70  # Celsius
    if outdoor_temp < pla['melts_at'] - 30:
        print(f"✓ PLA is safe for outdoor use at {outdoor_temp}°C")
    else:
        print(f"✗ PLA will soften at {outdoor_temp}°C")
        print(f"✓ Use PETG instead (melts at {petg['melts_at']}°C)")
    print()

def example_3_identification():
    """Identify unknown materials from density"""
    print("=" * 60)
    print("Example 3: Material Identification")
    print("=" * 60)
    
    # Found an unknown sample with density 2700 kg/m³
    unknown_density = 2700
    result = ml.identify(unknown_density)
    
    print(f"Unknown sample density: {unknown_density} kg/m³")
    print(f"Best match: {result['material']}")
    print(f"Confidence: {result['confidence']}%")
    print()
    
    # Another sample
    mystery_plastic = 1240
    result2 = ml.identify(mystery_plastic)
    print(f"Mystery plastic density: {mystery_plastic} kg/m³")
    print(f"Identified as: {result2['material']}")
    print()

def example_4_physics():
    """Quick physics calculations"""
    print("=" * 60)
    print("Example 4: Physics Calculations")
    print("=" * 60)
    
    # Dropping object
    height = 100  # meters
    result = ml.drop(height)
    print(f"Dropping object from {height}m:")
    print(f"  Time to ground: {result['time']:.2f} seconds")
    print(f"  Final velocity: {result['velocity']:.1f} m/s")
    print()
    
    # Terminal velocity
    mass = 70  # kg (human)
    v_term = ml.terminal_velocity(mass)
    print(f"Skydiver ({mass} kg):")
    print(f"  Terminal velocity: {v_term:.1f} m/s")
    print(f"  (≈ {v_term * 3.6:.0f} km/h)")
    print()

def example_5_reynolds():
    """Calculate Reynolds numbers"""
    print("=" * 60)
    print("Example 5: Reynolds Number")
    print("=" * 60)
    
    # Water pipe flow
    velocity = 2.0  # m/s
    diameter = 0.05  # m (5 cm pipe)
    Re = ml.reynolds_number(velocity, diameter)
    
    print(f"Water flowing at {velocity} m/s in {diameter*100} cm pipe:")
    print(f"  Reynolds number: {Re:.0f}")
    
    if Re < 2300:
        print("  Flow regime: Laminar")
    elif Re < 4000:
        print("  Flow regime: Transitional")
    else:
        print("  Flow regime: Turbulent")
    print()

def example_6_heat_time():
    """Estimate heating/cooling times"""
    print("=" * 60)
    print("Example 6: Thermal Analysis")
    print("=" * 60)
    
    # How long to heat aluminum block?
    material = 'aluminum'
    mass = 1.0  # kg
    temp_delta = 100  # K (room temp to 100°C above)
    
    time = ml.heat_time(material, mass, temp_delta)
    
    print(f"Heating {mass} kg of {material} by {temp_delta}°C:")
    print(f"  Energy required: {time['energy']:.0f} J")
    print(f"  Time (1000W heater): {time['time_1kW']:.1f} seconds")
    print()

def example_7_material_selection():
    """Select material for application"""
    print("=" * 60)
    print("Example 7: Material Selection")
    print("=" * 60)
    
    print("Need material for 3D printed part:")
    print("  - Operating temperature: 80°C")
    print("  - Outdoor use (sun exposure)")
    print("  - Must be tough (not brittle)")
    print()
    
    # Check candidates
    candidates = ['pla', 'petg', 'abs']
    
    for mat_name in candidates:
        mat = ml.material(mat_name)
        suitable = True
        reasons = []
        
        # Check temperature
        if 'glass_transition' in mat:
            if mat['glass_transition'] < 80:
                suitable = False
                reasons.append(f"glass transition at {mat['glass_transition']}°C")
        
        if mat['melts_at'] < 120:  # 80°C + safety margin
            suitable = False
            reasons.append(f"low melting point ({mat['melts_at']}°C)")
        
        # Check outdoor use
        if mat_name == 'pla':
            suitable = False
            reasons.append("degrades in UV/moisture")
        
        status = "✓ Suitable" if suitable else "✗ Not suitable"
        print(f"{mat_name.upper()}: {status}")
        if reasons:
            print(f"  Reasons: {', '.join(reasons)}")
    
    print()
    print("Recommendation: PETG (best for outdoor high-temp use)")
    print()

def example_8_compare_materials():
    """Compare multiple materials"""
    print("=" * 60)
    print("Example 8: Material Comparison")
    print("=" * 60)
    
    materials = ['pla', 'abs', 'petg']
    print(f"Comparing: {', '.join(materials)}")
    print()
    
    print(f"{'Material':<8} {'Density':>10} {'Melts at':>10} {'Glass Tg':>10}")
    print("-" * 60)
    
    for mat_name in materials:
        mat = ml.material(mat_name)
        tg = mat.get('glass_transition', 'N/A')
        print(f"{mat_name.upper():<8} {mat['density']:>10} {mat['melts_at']:>10}°C {str(tg):>9}°C")
    
    print()

def main():
    """Run all examples"""
    print()
    print("╔" + "=" * 58 + "╗")
    print("║" + " " * 58 + "║")
    print("║" + "  MatLabC++ Quick Start Examples".center(58) + "║")
    print("║" + "  Python Interface Demonstration".center(58) + "║")
    print("║" + " " * 58 + "║")
    print("╚" + "=" * 58 + "╝")
    print()
    
    try:
        example_1_constants()
        example_2_materials()
        example_3_identification()
        example_4_physics()
        example_5_reynolds()
        example_6_heat_time()
        example_7_material_selection()
        example_8_compare_materials()
        
        print("=" * 60)
        print("All examples completed successfully!")
        print()
        print("Next steps:")
        print("  - Try modifying the examples above")
        print("  - See material_selection.py for real-world scenarios")
        print("  - Check temperature_analysis.py for thermal problems")
        print("  - Explore constraint_solving.py for design optimization")
        print("=" * 60)
        print()
        
    except Exception as e:
        print(f"\n✗ Error running examples: {e}")
        print("\nMake sure MatLabC++ is built and accessible:")
        print("  cd build && ./matlabcpp")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
