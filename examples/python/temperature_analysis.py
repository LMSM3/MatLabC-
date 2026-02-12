#!/usr/bin/env python3
"""
Temperature-Dependent Material Analysis
Demonstrates thermal property calculations and temperature effects
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'notebooks'))

import matlabcpp as ml
import math

def analyze_thermal_expansion():
    """Calculate thermal expansion for different materials"""
    print("=" * 70)
    print("ANALYSIS 1: Thermal Expansion")
    print("=" * 70)
    print()
    
    print("Scenario: 1m aluminum rod heated from 20°C to 120°C")
    print()
    
    # Thermal expansion coefficients (1/K)
    materials = {
        'aluminum': 23e-6,
        'steel': 12e-6,
        'copper': 17e-6,
        'invar': 1.2e-6,  # Special low-expansion alloy
        'carbon_fiber': -0.5e-6  # Negative expansion!
    }
    
    L0 = 1.0  # Initial length (m)
    T0 = 20   # Initial temp (°C)
    T1 = 120  # Final temp (°C)
    delta_T = T1 - T0
    
    print(f"Temperature change: {delta_T}°C")
    print(f"Initial length: {L0 * 1000:.1f} mm")
    print()
    
    results = []
    for name, alpha in materials.items():
        delta_L = alpha * L0 * delta_T
        delta_L_mm = delta_L * 1000
        results.append((delta_L_mm, name))
        
        print(f"{name.upper()}:")
        print(f"  α = {alpha * 1e6:.2f} × 10⁻⁶ /K")
        print(f"  ΔL = {delta_L_mm:.3f} mm")
        print()
    
    results.sort()
    print(f"✓ Least expansion: {results[0][1].upper()} ({results[0][0]:.3f} mm)")
    print(f"✗ Most expansion:  {results[-1][1].upper()} ({results[-1][0]:.3f} mm)")
    print()
    
    print("Design implications:")
    print("  - Use Invar for precision instruments (6-20x less expansion)")
    print("  - Aluminum expands 2x more than steel (consider joint design)")
    print("  - Carbon fiber: negative expansion (contracts when heated!)")
    print()

def analyze_heat_transfer():
    """Calculate heat transfer rates"""
    print("=" * 70)
    print("ANALYSIS 2: Heat Transfer Through Materials")
    print("=" * 70)
    print()
    
    print("Scenario: 10cm × 10cm plate, 1cm thick, 100°C temperature difference")
    print()
    
    # Thermal conductivities (W/m·K)
    materials = {
        'copper': 385,
        'aluminum': 205,
        'steel': 50,
        'glass': 1.0,
        'wood': 0.15,
        'air': 0.025
    }
    
    A = 0.1 * 0.1  # Area (m²)
    thickness = 0.01  # 1 cm
    delta_T = 100  # K
    
    print(f"Area: {A * 1e4:.0f} cm²")
    print(f"Thickness: {thickness * 100:.1f} cm")
    print(f"ΔT: {delta_T}°C")
    print()
    
    results = []
    for name, k in materials.items():
        # Heat flux: Q = k * A * ΔT / thickness
        Q = k * A * delta_T / thickness
        
        results.append((Q, name))
        
        print(f"{name.upper()}:")
        print(f"  k = {k:.3f} W/(m·K)")
        print(f"  Heat transfer rate: {Q:.1f} W")
        
        # Time to transfer 1000 J
        time_1kJ = 1000 / Q if Q > 0 else float('inf')
        print(f"  Time for 1 kJ: {time_1kJ:.2f} seconds")
        print()
    
    results.sort(reverse=True)
    best = results[0]
    worst = results[-1]
    
    print(f"✓ Best conductor: {best[1].upper()} ({best[0]:.0f} W)")
    print(f"✗ Best insulator: {worst[1].upper()} ({worst[0]:.3f} W)")
    print()
    
    print(f"Copper conducts {best[0] / worst[0]:.0f}x better than air!")
    print()

def analyze_heat_capacity():
    """Calculate energy needed to heat materials"""
    print("=" * 70)
    print("ANALYSIS 3: Heating Energy Requirements")
    print("=" * 70)
    print()
    
    print("Scenario: Heat 1 kg of material from 20°C to 100°C")
    print()
    
    # Specific heat capacities (J/kg·K)
    materials = {
        'water': {'cp': 4186, 'rho': 1000},
        'aluminum': {'cp': 900, 'rho': 2700},
        'steel': {'cp': 450, 'rho': 7850},
        'copper': {'cp': 385, 'rho': 8960},
        'glass': {'cp': 840, 'rho': 2500},
        'oil': {'cp': 2000, 'rho': 900}
    }
    
    mass = 1.0  # kg
    delta_T = 80  # K
    
    print(f"Mass: {mass} kg")
    print(f"ΔT: {delta_T}°C")
    print()
    
    results = []
    for name, props in materials.items():
        # Energy: Q = m * cp * ΔT
        Q = mass * props['cp'] * delta_T
        
        # Volume
        volume = mass / props['rho']
        
        results.append((Q, name))
        
        print(f"{name.upper()}:")
        print(f"  Specific heat: {props['cp']} J/(kg·K)")
        print(f"  Energy needed: {Q / 1000:.1f} kJ")
        print(f"  Time (1000W): {Q / 1000:.1f} seconds")
        print(f"  Volume: {volume * 1e6:.1f} cm³")
        print()
    
    results.sort(reverse=True)
    
    print(f"Most energy: {results[0][1].upper()} ({results[0][0] / 1000:.1f} kJ)")
    print(f"Least energy: {results[-1][1].upper()} ({results[-1][0] / 1000:.1f} kJ)")
    print()
    
    water_energy = [r for r in results if r[1] == 'water'][0][0]
    copper_energy = [r for r in results if r[1] == 'copper'][0][0]
    
    print(f"Water needs {water_energy / copper_energy:.1f}x more energy than copper!")
    print("(This is why water is used for cooling - high heat capacity)")
    print()

def analyze_steady_state_temp():
    """Calculate steady-state temperature distribution"""
    print("=" * 70)
    print("ANALYSIS 4: CPU Heat Sink Analysis")
    print("=" * 70)
    print()
    
    print("Scenario: 100W CPU with heat sink, 25°C ambient")
    print()
    
    # Heat sink materials
    materials = {
        'copper': {'k': 385, 'rho': 8960, 'cost': 6},
        'aluminum': {'k': 205, 'rho': 2700, 'cost': 2.5}
    }
    
    Q = 100  # Watts
    T_ambient = 25  # °C
    
    # Simplified heat sink model
    # Thermal resistance = L / (k * A)
    # Assume 2cm height, 50 cm² base area
    
    L = 0.02  # m
    A = 50e-4  # m²
    
    print("Heat sink geometry:")
    print(f"  Height: {L * 100:.0f} cm")
    print(f"  Base area: {A * 1e4:.0f} cm²")
    print(f"  CPU power: {Q} W")
    print()
    
    for name, props in materials.items():
        # Thermal resistance (conduction only, simplified)
        R_cond = L / (props['k'] * A)
        
        # Temperature rise
        delta_T_cond = Q * R_cond
        
        # Assume convection resistance ~0.5 K/W (typical for decent airflow)
        R_conv = 0.5
        delta_T_conv = Q * R_conv
        
        # Total temperature
        T_cpu = T_ambient + delta_T_cond + delta_T_conv
        
        # Mass
        volume = A * L  # Simplified
        mass = volume * props['rho']
        cost = mass * props['cost']
        
        print(f"{name.upper()} HEAT SINK:")
        print(f"  Thermal conductivity: {props['k']} W/(m·K)")
        print(f"  Conduction resistance: {R_cond:.4f} K/W")
        print(f"  Temperature rise (conduction): {delta_T_cond:.2f}°C")
        print(f"  Temperature rise (convection): {delta_T_conv:.2f}°C")
        print(f"  CPU temperature: {T_cpu:.1f}°C")
        print(f"  Mass: {mass * 1000:.1f} g")
        print(f"  Cost: ${cost:.2f}")
        print()
        
        if T_cpu > 85:
            print(f"  ✗ TOO HOT (>{85}°C limit)")
        else:
            print(f"  ✓ Safe temperature")
        print()
    
    print("Conclusion:")
    print("  - Copper: 2°C cooler but 3.3x heavier and 2.4x more expensive")
    print("  - Aluminum: Good enough for most CPUs, lighter, cheaper")
    print("  - Real-world: Copper base plate + aluminum fins (hybrid)")
    print()

def analyze_transient_heating():
    """Time to reach temperature"""
    print("=" * 70)
    print("ANALYSIS 5: Transient Heating (Time to Temperature)")
    print("=" * 70)
    print()
    
    print("Scenario: Heating aluminum block with 500W heater")
    print()
    
    # Aluminum properties
    rho = 2700  # kg/m³
    cp = 900    # J/(kg·K)
    
    # Block size: 10cm cube
    volume = 0.1 ** 3  # m³
    mass = rho * volume
    
    print(f"Aluminum block: 10cm × 10cm × 10cm")
    print(f"Volume: {volume * 1e6:.0f} cm³")
    print(f"Mass: {mass:.2f} kg")
    print()
    
    # Heating scenarios
    scenarios = [
        {'name': 'Room to warm', 'T0': 20, 'T1': 40, 'power': 500},
        {'name': 'Room to hot', 'T0': 20, 'T1': 100, 'power': 500},
        {'name': 'Room to hot (1000W)', 'T0': 20, 'T1': 100, 'power': 1000}
    ]
    
    for scenario in scenarios:
        delta_T = scenario['T1'] - scenario['T0']
        Q_total = mass * cp * delta_T
        time = Q_total / scenario['power']
        
        print(f"{scenario['name'].upper()}:")
        print(f"  From {scenario['T0']}°C to {scenario['T1']}°C")
        print(f"  Power: {scenario['power']} W")
        print(f"  Energy needed: {Q_total / 1000:.1f} kJ")
        print(f"  Time required: {time:.1f} seconds ({time / 60:.2f} minutes)")
        print()
    
    print("Key insight:")
    print("  - Doubling power halves heating time (if no heat loss)")
    print("  - In reality: heat loss to environment limits max temp")
    print("  - Need insulation or active cooling control")
    print()

def analyze_thermal_shock():
    """Thermal shock resistance"""
    print("=" * 70)
    print("ANALYSIS 6: Thermal Shock Resistance")
    print("=" * 70)
    print()
    
    print("Scenario: Rapid temperature change (quenching)")
    print()
    
    # Materials with properties relevant to thermal shock
    materials = {
        'glass': {
            'alpha': 9e-6,  # Thermal expansion
            'E': 70e9,      # Young's modulus
            'strength': 50e6,
            'toughness': 0.7e6  # Fracture toughness (Pa√m)
        },
        'steel': {
            'alpha': 12e-6,
            'E': 200e9,
            'strength': 400e6,
            'toughness': 50e6
        },
        'ceramic': {
            'alpha': 8e-6,
            'E': 300e9,
            'strength': 300e6,
            'toughness': 4e6
        }
    }
    
    print("Thermal shock parameter = (strength × toughness) / (E × α)")
    print("Higher value = better thermal shock resistance")
    print()
    
    delta_T = 100  # K (typical quench)
    
    results = []
    for name, props in materials.items():
        # Thermal stress (simplified)
        stress = props['alpha'] * props['E'] * delta_T
        
        # Thermal shock resistance parameter
        tsr = (props['strength'] * props['toughness']) / (props['E'] * props['alpha'])
        
        results.append((tsr, name))
        
        print(f"{name.upper()}:")
        print(f"  Thermal expansion: {props['alpha'] * 1e6:.1f} × 10⁻⁶ /K")
        print(f"  Young's modulus: {props['E'] / 1e9:.0f} GPa")
        print(f"  Thermal stress ({delta_T}°C): {stress / 1e6:.0f} MPa")
        print(f"  TSR parameter: {tsr:.3e}")
        
        if stress > props['strength']:
            print(f"  ✗ FAILS ({stress / 1e6:.0f} > {props['strength'] / 1e6:.0f} MPa)")
        else:
            print(f"  ✓ Survives ({stress / 1e6:.0f} < {props['strength'] / 1e6:.0f} MPa)")
        print()
    
    results.sort(reverse=True)
    print(f"Best thermal shock resistance: {results[0][1].upper()}")
    print()
    
    print("Design rules:")
    print("  - Low α (expansion) helps")
    print("  - High toughness helps (absorbs stress)")
    print("  - Low E (modulus) helps (less stress)")
    print("  - Glass fails thermal shock easily (brittle, high E)")
    print("  - Metals good (high toughness)")
    print("  - Ceramics: depends on type (advanced ceramics better)")
    print()

def main():
    """Run all thermal analyses"""
    print()
    print("╔" + "=" * 68 + "╗")
    print("║" + "  Temperature-Dependent Material Analysis".center(68) + "║")
    print("║" + "  Thermal properties and effects".center(68) + "║")
    print("╚" + "=" * 68 + "╝")
    print()
    
    analyze_thermal_expansion()
    analyze_heat_transfer()
    analyze_heat_capacity()
    analyze_steady_state_temp()
    analyze_transient_heating()
    analyze_thermal_shock()
    
    print("=" * 70)
    print("Summary:")
    print("  1. Thermal expansion matters in precision (use Invar)")
    print("  2. High conductivity for heat transfer (copper, aluminum)")
    print("  3. High heat capacity for thermal mass (water)")
    print("  4. Heat sinks: aluminum good balance (cost/weight/performance)")
    print("  5. Heating time ∝ (mass × cp × ΔT) / power")
    print("  6. Thermal shock: low α, high toughness, low E")
    print("=" * 70)
    print()

if __name__ == "__main__":
    main()
