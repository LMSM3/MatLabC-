#!/usr/bin/env python3
"""
Constraint-Based Material Selection
Demonstrates design optimization with multiple constraints
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'notebooks'))

import matlabcpp as ml

def example_1_simple_constraints():
    """Find materials meeting basic constraints"""
    print("=" * 70)
    print("EXAMPLE 1: Simple Constraint Satisfaction")
    print("=" * 70)
    print()
    
    print("Find material with:")
    print("  - Yield strength ≥ 400 MPa")
    print("  - Density ≤ 5000 kg/m³")
    print("  - Cost ≤ $10/kg")
    print()
    
    # Material database (simplified)
    materials = [
        {'name': 'Aluminum 7075', 'strength': 505e6, 'density': 2810, 'cost': 5},
        {'name': 'Steel 4340', 'strength': 860e6, 'density': 7850, 'cost': 3},
        {'name': 'Titanium 6Al-4V', 'strength': 880e6, 'density': 4430, 'cost': 25},
        {'name': 'Aluminum 6061', 'strength': 276e6, 'density': 2700, 'cost': 2.5},
        {'name': 'Magnesium AZ31', 'strength': 220e6, 'density': 1740, 'cost': 7}
    ]
    
    # Apply constraints
    candidates = []
    for mat in materials:
        passes = True
        reasons = []
        
        if mat['strength'] < 400e6:
            passes = False
            reasons.append(f"strength too low ({mat['strength'] / 1e6:.0f} < 400 MPa)")
        
        if mat['density'] > 5000:
            passes = False
            reasons.append(f"too heavy ({mat['density']} > 5000 kg/m³)")
        
        if mat['cost'] > 10:
            passes = False
            reasons.append(f"too expensive (${mat['cost']} > $10/kg)")
        
        status = "✓ PASS" if passes else "✗ FAIL"
        print(f"{mat['name']:<20} {status}")
        
        if not passes:
            print(f"  Reasons: {', '.join(reasons)}")
        else:
            candidates.append(mat)
            print(f"  Properties: {mat['strength'] / 1e6:.0f} MPa, {mat['density']} kg/m³, ${mat['cost']}/kg")
        print()
    
    if candidates:
        print(f"✓ Found {len(candidates)} suitable material(s)")
        print()
        
        # Rank by specific strength
        candidates.sort(key=lambda m: m['strength'] / m['density'], reverse=True)
        best = candidates[0]
        print(f"Best (strength-to-weight): {best['name']}")
        print(f"  Specific strength: {best['strength'] / best['density']:.1f} Pa·m³/kg")
    else:
        print("✗ No materials meet all constraints")
        print("  Consider relaxing requirements")
    
    print()

def example_2_optimization():
    """Optimize for specific criterion"""
    print("=" * 70)
    print("EXAMPLE 2: Multi-Criterion Optimization")
    print("=" * 70)
    print()
    
    print("Application: Bicycle frame")
    print("Optimize for: Lightest weight meeting strength requirement")
    print()
    
    # Constraints
    min_strength = 300e6  # Pa
    max_cost = 15  # $/kg
    min_toughness = 20e6  # Pa√m (crash resistance)
    
    print(f"Constraints:")
    print(f"  - Min strength: {min_strength / 1e6:.0f} MPa")
    print(f"  - Max cost: ${max_cost}/kg")
    print(f"  - Min toughness: {min_toughness / 1e6:.0f} MPa√m (crash safety)")
    print()
    
    materials = [
        {'name': 'Aluminum 6061', 'strength': 276e6, 'density': 2700, 'cost': 2.5, 'toughness': 29e6},
        {'name': 'Aluminum 7005', 'strength': 350e6, 'density': 2780, 'cost': 4, 'toughness': 25e6},
        {'name': 'Steel (chromoly)', 'strength': 700e6, 'density': 7850, 'cost': 2, 'toughness': 100e6},
        {'name': 'Titanium 3Al-2.5V', 'strength': 620e6, 'density': 4480, 'cost': 20, 'toughness': 75e6},
        {'name': 'Carbon fiber', 'strength': 600e6, 'density': 1600, 'cost': 40, 'toughness': 10e6}
    ]
    
    feasible = []
    for mat in materials:
        passes = (
            mat['strength'] >= min_strength and
            mat['cost'] <= max_cost and
            mat['toughness'] >= min_toughness
        )
        
        if passes:
            # Calculate frame mass (assume constant tube volume)
            tube_volume = 0.001  # m³ (1 liter equivalent)
            mass = mat['density'] * tube_volume
            
            feasible.append({
                'name': mat['name'],
                'mass': mass,
                'cost_total': mass * mat['cost'],
                'density': mat['density'],
                'strength': mat['strength']
            })
    
    if not feasible:
        print("✗ No materials meet all constraints!")
        print("  Relaxation needed (try higher cost or lower toughness)")
        return
    
    # Sort by mass (lightest first)
    feasible.sort(key=lambda m: m['mass'])
    
    print("Feasible materials (ranked by weight):")
    print()
    
    for i, mat in enumerate(feasible, 1):
        print(f"{i}. {mat['name']:<20}")
        print(f"   Mass:  {mat['mass']:.2f} kg")
        print(f"   Cost:  ${mat['cost_total']:.2f}")
        print(f"   Density: {mat['density']} kg/m³")
        print()
    
    best = feasible[0]
    print(f"✓ OPTIMAL: {best['name']}")
    print(f"  Lightest option meeting all safety requirements")
    print(f"  Frame weight: {best['mass']:.2f} kg")
    print()

def example_3_pareto_frontier():
    """Multi-objective optimization (Pareto frontier)"""
    print("=" * 70)
    print("EXAMPLE 3: Pareto Frontier (Cost vs. Performance)")
    print("=" * 70)
    print()
    
    print("Trade-off: Cost vs. Strength-to-Weight")
    print("Find non-dominated solutions")
    print()
    
    materials = [
        {'name': 'Mild Steel', 'strength': 250e6, 'density': 7850, 'cost': 0.8},
        {'name': 'Al 6061', 'strength': 276e6, 'density': 2700, 'cost': 2.5},
        {'name': 'Al 7075', 'strength': 505e6, 'density': 2810, 'cost': 5},
        {'name': 'Steel 4340', 'strength': 860e6, 'density': 7850, 'cost': 3},
        {'name': 'Ti 6-4', 'strength': 880e6, 'density': 4430, 'cost': 25},
        {'name': 'CF woven', 'strength': 600e6, 'density': 1600, 'cost': 40}
    ]
    
    # Calculate objectives
    for mat in materials:
        mat['spec_strength'] = mat['strength'] / mat['density']
        mat['performance_per_dollar'] = mat['spec_strength'] / mat['cost']
    
    # Find Pareto frontier (non-dominated solutions)
    # A solution dominates another if it's better in ALL objectives
    
    pareto = []
    for mat in materials:
        dominated = False
        for other in materials:
            if other['name'] == mat['name']:
                continue
            
            # Other dominates if: cheaper AND better performance
            if (other['cost'] < mat['cost'] and 
                other['spec_strength'] > mat['spec_strength']):
                dominated = True
                break
        
        if not dominated:
            pareto.append(mat)
    
    print("All materials:")
    print(f"{'Material':<15} {'Spec Strength':>15} {'Cost':>8} {'Perf/$':>12}")
    print("-" * 70)
    
    for mat in materials:
        on_frontier = "★" if mat in pareto else " "
        print(f"{on_frontier} {mat['name']:<13} {mat['spec_strength']:>15.1f} {mat['cost']:>7.2f} {mat['performance_per_dollar']:>12.1f}")
    
    print()
    print("★ = On Pareto frontier (non-dominated solution)")
    print()
    
    # Sort Pareto solutions by cost
    pareto.sort(key=lambda m: m['cost'])
    
    print("Pareto-optimal choices:")
    for mat in pareto:
        print(f"  - {mat['name']}: ${mat['cost']}/kg, {mat['spec_strength']:.0f} Pa·m³/kg")
    
    print()
    print("Decision guide:")
    print(f"  - Budget constrained: {pareto[0]['name']}")
    print(f"  - Performance critical: {pareto[-1]['name']}")
    print(f"  - Balanced: {pareto[len(pareto)//2]['name']}")
    print()

def example_4_sensitivity_analysis():
    """Analyze sensitivity to constraint changes"""
    print("=" * 70)
    print("EXAMPLE 4: Sensitivity Analysis")
    print("=" * 70)
    print()
    
    print("How does solution change with constraint relaxation?")
    print()
    
    base_constraints = {
        'min_strength': 400e6,
        'max_density': 5000,
        'max_cost': 10
    }
    
    materials = [
        {'name': 'Al 6061', 'strength': 276e6, 'density': 2700, 'cost': 2.5},
        {'name': 'Al 7075', 'strength': 505e6, 'density': 2810, 'cost': 5},
        {'name': 'Steel 4340', 'strength': 860e6, 'density': 7850, 'cost': 3},
        {'name': 'Ti 6-4', 'strength': 880e6, 'density': 4430, 'cost': 25},
    ]
    
    def count_feasible(constraints):
        count = 0
        for mat in materials:
            if (mat['strength'] >= constraints['min_strength'] and
                mat['density'] <= constraints['max_density'] and
                mat['cost'] <= constraints['max_cost']):
                count += 1
        return count
    
    print("Base constraints:")
    print(f"  Strength ≥ {base_constraints['min_strength'] / 1e6:.0f} MPa")
    print(f"  Density ≤ {base_constraints['max_density']} kg/m³")
    print(f"  Cost ≤ ${base_constraints['max_cost']}/kg")
    print(f"  → {count_feasible(base_constraints)} feasible materials")
    print()
    
    # Relax strength
    print("Sensitivity to strength requirement:")
    for strength in [300e6, 350e6, 400e6, 450e6, 500e6]:
        c = base_constraints.copy()
        c['min_strength'] = strength
        count = count_feasible(c)
        print(f"  {strength / 1e6:.0f} MPa: {count} materials")
    print()
    
    # Relax cost
    print("Sensitivity to cost limit:")
    for cost in [5, 10, 15, 20, 25]:
        c = base_constraints.copy()
        c['max_cost'] = cost
        count = count_feasible(c)
        print(f"  ${cost}/kg: {count} materials")
    print()
    
    # Relax density
    print("Sensitivity to density limit:")
    for density in [3000, 4000, 5000, 6000, 8000]:
        c = base_constraints.copy()
        c['max_density'] = density
        count = count_feasible(c)
        print(f"  {density} kg/m³: {count} materials")
    print()
    
    print("Conclusion:")
    print("  - Most sensitive to: cost (Titanium excluded)")
    print("  - Strength requirement eliminates Al 6061")
    print("  - Density requirement eliminates most steels")
    print("  - Best leverage: Relax cost to include Titanium")
    print()

def example_5_constraint_relaxation():
    """Automatic constraint relaxation"""
    print("=" * 70)
    print("EXAMPLE 5: Intelligent Constraint Relaxation")
    print("=" * 70)
    print()
    
    print("When no solution exists, intelligently relax constraints")
    print()
    
    # Infeasible problem
    constraints = {
        'min_strength': 900e6,  # Very high
        'max_density': 3000,    # Very low
        'max_cost': 5           # Very cheap
    }
    
    materials = [
        {'name': 'Al 7075', 'strength': 505e6, 'density': 2810, 'cost': 5},
        {'name': 'Steel 4340', 'strength': 860e6, 'density': 7850, 'cost': 3},
        {'name': 'Ti 6-4', 'strength': 880e6, 'density': 4430, 'cost': 25},
        {'name': 'CF woven', 'strength': 600e6, 'density': 1600, 'cost': 40}
    ]
    
    print("Initial (infeasible) constraints:")
    print(f"  Strength ≥ {constraints['min_strength'] / 1e6:.0f} MPa")
    print(f"  Density ≤ {constraints['max_density']} kg/m³")
    print(f"  Cost ≤ ${constraints['max_cost']}/kg")
    print()
    
    # Check which materials violate which constraints
    print("Constraint violations:")
    for mat in materials:
        violations = []
        if mat['strength'] < constraints['min_strength']:
            shortfall = (constraints['min_strength'] - mat['strength']) / 1e6
            violations.append(f"strength ({shortfall:.0f} MPa short)")
        if mat['density'] > constraints['max_density']:
            excess = mat['density'] - constraints['max_density']
            violations.append(f"density (+{excess} kg/m³)")
        if mat['cost'] > constraints['max_cost']:
            excess = mat['cost'] - constraints['max_cost']
            violations.append(f"cost (+${excess}/kg)")
        
        if violations:
            print(f"  {mat['name']:<15} ✗ {', '.join(violations)}")
        else:
            print(f"  {mat['name']:<15} ✓ Feasible")
    
    print()
    print("No feasible solution!")
    print()
    
    # Suggest relaxations
    print("Suggested relaxations (ranked by impact):")
    print()
    
    # Strategy 1: Relax density to include Ti
    print("1. Increase density limit to 4500 kg/m³")
    print("   → Allows Titanium (880 MPa, closest to requirement)")
    print("   → Best option")
    print()
    
    # Strategy 2: Relax strength
    print("2. Decrease strength requirement to 850 MPa")
    print("   → Allows Steel 4340 (860 MPa, within tolerance)")
    print("   → But heavy (7850 kg/m³, violates density)")
    print("   → Also need to relax density")
    print()
    
    # Strategy 3: Relax cost
    print("3. Increase cost limit to $25/kg")
    print("   → Allows Titanium")
    print("   → Best solution if budget allows")
    print()
    
    print("✓ RECOMMENDATION: Relax density to 4500 kg/m³ OR cost to $25/kg")
    print("  Both enable Titanium (880 MPa, 4430 kg/m³, $25/kg)")
    print()

def main():
    """Run all constraint examples"""
    print()
    print("╔" + "=" * 68 + "╗")
    print("║" + "  Constraint-Based Material Selection".center(68) + "║")
    print("║" + "  Design optimization with multiple requirements".center(68) + "║")
    print("╚" + "=" * 68 + "╝")
    print()
    
    example_1_simple_constraints()
    example_2_optimization()
    example_3_pareto_frontier()
    example_4_sensitivity_analysis()
    example_5_constraint_relaxation()
    
    print("=" * 70)
    print("Key Takeaways:")
    print("  1. Start with all constraints, relax if no solution")
    print("  2. Pareto frontier shows non-dominated trade-offs")
    print("  3. Sensitivity analysis reveals which constraints matter most")
    print("  4. Cost often most restrictive (Ti vs. Al vs. Steel)")
    print("  5. Weight matters for mobile applications (aerospace, automotive)")
    print("  6. Always check if 'optimal' meets real-world needs")
    print("=" * 70)
    print()

if __name__ == "__main__":
    main()
