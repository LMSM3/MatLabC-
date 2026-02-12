#!/usr/bin/env python3
"""
Material Selection for Real-World Applications
Demonstrates constraint-based material selection with practical scenarios
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'notebooks'))

import matlabcpp as ml

def scenario_1_drone_arm():
    """Select material for racing drone arm"""
    print("=" * 70)
    print("SCENARIO 1: Racing Drone Arm Design")
    print("=" * 70)
    print()
    
    print("Requirements:")
    print("  - Lightweight (critical for flight time)")
    print("  - High strength-to-weight ratio")
    print("  - Moderate cost (<$50/kg)")
    print("  - Survives crashes (some toughness)")
    print()
    
    candidates = {
        'carbon_fiber': {
            'density': 1600,
            'strength': 600,
            'cost': 40,
            'toughness': 'brittle'
        },
        'aluminum_7075': {
            'density': 2810,
            'strength': 505,
            'cost': 5,
            'toughness': 'moderate'
        },
        'fiberglass': {
            'density': 1850,
            'strength': 300,
            'cost': 15,
            'toughness': 'good'
        }
    }
    
    print("Candidate Analysis:")
    print()
    
    best_score = 0
    best_material = None
    
    for name, props in candidates.items():
        # Calculate specific strength (strength/density)
        spec_strength = (props['strength'] * 1e6) / props['density']
        
        # Score: specific strength (70%) + toughness (20%) + cost (10%)
        strength_score = spec_strength / 400000  # Normalize
        cost_score = (50 - props['cost']) / 50
        
        toughness_score = {'brittle': 0.5, 'moderate': 0.7, 'good': 1.0}[props['toughness']]
        
        total_score = (strength_score * 0.7) + (toughness_score * 0.2) + (cost_score * 0.1)
        
        print(f"{name.upper()}:")
        print(f"  Specific strength: {spec_strength:.1f} Pa·m³/kg")
        print(f"  Cost:              ${props['cost']}/kg")
        print(f"  Toughness:         {props['toughness']}")
        print(f"  Score:             {total_score:.2f}")
        print()
        
        if total_score > best_score:
            best_score = total_score
            best_material = name
    
    print(f"✓ RECOMMENDATION: {best_material.upper()}")
    print("  Best balance of strength-to-weight and cost")
    print()
    print("Alternative: Aluminum 7075 for budget builds")
    print()

def scenario_2_heat_sink():
    """Select material for LED heat sink"""
    print("=" * 70)
    print("SCENARIO 2: High-Power LED Heat Sink")
    print("=" * 70)
    print()
    
    print("Requirements:")
    print("  - Excellent thermal conductivity")
    print("  - Reasonable weight (<500g for 100cm² sink)")
    print("  - Good machinability")
    print("  - Cost-effective for production")
    print()
    
    # Get materials
    aluminum = {'name': 'aluminum_6061', 'k': 167, 'rho': 2700, 'cost': 2.5, 'machine': 'easy'}
    copper = {'name': 'copper_pure', 'k': 385, 'rho': 8960, 'cost': 6, 'machine': 'hard'}
    
    volume = 100e-4 * 0.02  # 100 cm² × 2cm thick = 200 cm³
    
    print("Analysis:")
    print()
    
    for mat in [aluminum, copper]:
        mass = mat['rho'] * volume
        thermal_resistance = 0.02 / (mat['k'] * 100e-4)  # Simplified
        
        print(f"{mat['name'].upper()}:")
        print(f"  Thermal conductivity: {mat['k']} W/(m·K)")
        print(f"  Mass:                 {mass * 1000:.0f} g")
        print(f"  Thermal resistance:   {thermal_resistance:.4f} K/W")
        print(f"  Cost:                 ${mat['cost'] * mass:.2f}")
        print(f"  Machinability:        {mat['machine']}")
        print()
        
        # Check weight constraint
        if mass > 0.5:
            print(f"  ✗ FAILS weight requirement ({mass:.1f} kg > 0.5 kg)")
        else:
            print(f"  ✓ Meets weight requirement")
        print()
    
    print("✓ RECOMMENDATION: Aluminum 6061")
    print("  Reasons:")
    print("    - Good thermal conductivity (80% of copper)")
    print("    - 3.3x lighter than copper")
    print("    - Easy to machine (faster production)")
    print("    - 2.4x cheaper per heat sink")
    print()
    print("  Use copper only if:")
    print("    - Space is extremely limited (need smaller sink)")
    print("    - Cooling is absolutely critical")
    print()

def scenario_3_3d_print_outdoor():
    """Select 3D printing material for outdoor enclosure"""
    print("=" * 70)
    print("SCENARIO 3: Outdoor Electronics Enclosure")
    print("=" * 70)
    print()
    
    print("Requirements:")
    print("  - Outdoor use (UV, rain, temperature swings)")
    print("  - Operating range: -20°C to +70°C")
    print("  - 3D printable")
    print("  - Good layer adhesion (waterproof)")
    print("  - Affordable")
    print()
    
    candidates = ['pla', 'petg', 'abs', 'asa']
    
    print("Candidate Evaluation:")
    print()
    
    # Criteria scores (0-10)
    scores = {
        'pla': {
            'uv_resistance': 2,  # Degrades
            'water_resistance': 4,
            'temp_range': 3,  # Softens at 60°C
            'layer_adhesion': 5,
            'cost': 10,
            'printability': 10
        },
        'petg': {
            'uv_resistance': 5,
            'water_resistance': 8,
            'temp_range': 7,  # Good to 80°C
            'layer_adhesion': 9,
            'cost': 8,
            'printability': 8
        },
        'abs': {
            'uv_resistance': 3,  # Yellows
            'water_resistance': 7,
            'temp_range': 8,
            'layer_adhesion': 6,
            'cost': 9,
            'printability': 5  # Warps, fumes
        },
        'asa': {
            'uv_resistance': 9,  # Excellent
            'water_resistance': 8,
            'temp_range': 8,
            'layer_adhesion': 7,
            'cost': 7,
            'printability': 6
        }
    }
    
    # Weighted scores (outdoor = UV + water critical)
    weights = {
        'uv_resistance': 0.25,
        'water_resistance': 0.25,
        'temp_range': 0.20,
        'layer_adhesion': 0.15,
        'cost': 0.05,
        'printability': 0.10
    }
    
    results = []
    for material, criteria in scores.items():
        total = sum(criteria[k] * weights[k] for k in criteria)
        results.append((total, material, criteria))
    
    results.sort(reverse=True)
    
    for score, material, criteria in results:
        print(f"{material.upper()}: {score:.2f}/10")
        print(f"  UV resistance:    {criteria['uv_resistance']}/10")
        print(f"  Water resistance: {criteria['water_resistance']}/10")
        print(f"  Temp range:       {criteria['temp_range']}/10")
        print(f"  Layer adhesion:   {criteria['layer_adhesion']}/10")
        print()
    
    winner = results[0][1]
    print(f"✓ RECOMMENDATION: {winner.upper()}")
    
    if winner == 'petg':
        print("  Reasons:")
        print("    - Excellent water/chemical resistance")
        print("    - Good UV resistance (not best, but acceptable)")
        print("    - Best layer adhesion (waterproof)")
        print("    - Easy to print (no warping like ABS)")
        print("    - Affordable")
        print()
        print("  Alternative: ASA if maximum UV resistance needed")
        print("               (but harder to print)")
    
    print()

def scenario_4_structural_beam():
    """Select material for structural beam (cost vs. performance)"""
    print("=" * 70)
    print("SCENARIO 4: Structural Beam (Cost Optimization)")
    print("=" * 70)
    print()
    
    print("Application: Support beam for 10 kN load, 2m span")
    print("Goal: Minimize cost while meeting strength requirement")
    print()
    
    # Simplified beam analysis (bending)
    load = 10000  # N
    span = 2.0  # m
    max_stress = (load * span) / 4  # Simplified: M/S (assume S=1)
    
    candidates = [
        {'name': 'mild_steel', 'yield': 250e6, 'rho': 7850, 'cost': 0.80},
        {'name': 'aluminum_6061', 'yield': 276e6, 'rho': 2700, 'cost': 2.50},
        {'name': 'high_strength_steel', 'yield': 860e6, 'rho': 7850, 'cost': 3.00},
    ]
    
    print("Analysis (assuming I-beam geometry):")
    print()
    
    # Required section modulus
    safety_factor = 2.0
    
    results = []
    for mat in candidates:
        # Required section modulus
        S_required = (max_stress * safety_factor) / mat['yield']
        
        # Estimate mass (proportional to section modulus and length)
        # For I-beam: A ≈ sqrt(S * h) (simplified)
        estimated_mass = S_required * span * mat['rho'] * 0.1  # Rough estimate
        
        material_cost = estimated_mass * mat['cost']
        
        results.append({
            'name': mat['name'],
            'mass': estimated_mass,
            'cost': material_cost,
            'yield': mat['yield'] / 1e6
        })
    
    # Sort by cost
    results.sort(key=lambda x: x['cost'])
    
    for r in results:
        print(f"{r['name'].upper()}:")
        print(f"  Yield strength: {r['yield']:.0f} MPa")
        print(f"  Estimated mass: {r['mass']:.1f} kg")
        print(f"  Material cost:  ${r['cost']:.2f}")
        print()
    
    best = results[0]
    print(f"✓ RECOMMENDATION: {best['name'].upper()}")
    print(f"  Lowest cost (${best['cost']:.2f}) while meeting requirements")
    print()
    print("  Trade-offs:")
    print(f"    - Mild steel:    Cheapest, heavy, sufficient strength")
    print(f"    - Al 6061:       Lighter, but 3x cost for minimal benefit")
    print(f"    - HS steel:      Overkill strength, expensive, no advantage")
    print()

def scenario_5_gear():
    """Select material for mechanical gear"""
    print("=" * 70)
    print("SCENARIO 5: Mechanical Gear (Wear Application)")
    print("=" * 70)
    print()
    
    print("Requirements:")
    print("  - Wear resistance (long life)")
    print("  - Moderate strength (light loads)")
    print("  - Low friction")
    print("  - Self-lubricating preferred")
    print("  - Quiet operation")
    print()
    
    candidates = {
        'steel_hardened': {
            'wear': 10, 'strength': 10, 'friction': 6,
            'noise': 4, 'cost': 8, 'machine': 'hard'
        },
        'bronze': {
            'wear': 8, 'strength': 6, 'friction': 7,
            'noise': 7, 'cost': 5, 'machine': 'easy'
        },
        'nylon': {
            'wear': 6, 'strength': 4, 'friction': 9,
            'noise': 9, 'cost': 9, 'machine': 'easy'
        },
        'acetal': {
            'wear': 7, 'strength': 5, 'friction': 8,
            'noise': 9, 'cost': 8, 'machine': 'easy'
        }
    }
    
    print("Light-load application analysis:")
    print()
    
    # Weights for light load (noise and friction matter more)
    weights = {
        'wear': 0.25, 'strength': 0.10, 'friction': 0.25,
        'noise': 0.20, 'cost': 0.10, 'machine': 0.10
    }
    
    results = []
    for name, props in candidates.items():
        score = sum(props[k] * weights[k] for k in weights)
        results.append((score, name, props))
    
    results.sort(reverse=True)
    
    for score, name, props in results:
        print(f"{name.upper()}: {score:.2f}/10")
        print(f"  Wear resistance: {props['wear']}/10")
        print(f"  Strength:        {props['strength']}/10")
        print(f"  Low friction:    {props['friction']}/10")
        print(f"  Quiet:           {props['noise']}/10")
        print()
    
    winner = results[0][1]
    print(f"✓ RECOMMENDATION: {winner.upper()}")
    print("  Best for light-load, quiet operation")
    print()
    print("  Usage guide:")
    print("    - Light loads (<100W): Nylon or Acetal")
    print("    - Medium loads:        Bronze")
    print("    - Heavy loads:         Hardened steel")
    print()

def main():
    """Run all scenarios"""
    print()
    print("╔" + "=" * 68 + "╗")
    print("║" + "  Real-World Material Selection Scenarios".center(68) + "║")
    print("║" + "  Practical decision-making with trade-offs".center(68) + "║")
    print("╚" + "=" * 68 + "╝")
    print()
    
    scenario_1_drone_arm()
    scenario_2_heat_sink()
    scenario_3_3d_print_outdoor()
    scenario_4_structural_beam()
    scenario_5_gear()
    
    print("=" * 70)
    print("Key Lessons:")
    print("  1. No 'best' material - only best for YOUR application")
    print("  2. Trade-offs: cost vs. performance vs. manufacturability")
    print("  3. Weight constraints often dominate (drones, automotive)")
    print("  4. Environment matters (UV, temperature, chemicals)")
    print("  5. Overkill is expensive - match material to actual need")
    print("=" * 70)
    print()

if __name__ == "__main__":
    main()
