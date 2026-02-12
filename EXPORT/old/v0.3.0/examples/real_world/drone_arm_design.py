#!/usr/bin/env python3
"""
Real-World Scenario: Drone Arm Design
Complete material selection for racing drone
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'notebooks'))

import matlabcpp as ml

def main():
    print("=" * 70)
    print("RACING DRONE ARM DESIGN")
    print("=" * 70)
    print()
    
    print("Requirements:")
    print("  - Span: 250mm (from motor to center)")
    print("  - Load: Crash impact ~50g deceleration")
    print("  - Weight budget: <20g per arm (4 arms total)")
    print("  - Cost: <$10 per arm")
    print("  - Repairability: Preferred (crashes happen!)")
    print()
    
    # Calculate loads
    motor_mass = 0.035  # kg (35g motor + prop)
    decel_g = 50  # g-forces in crash
    force = motor_mass * 9.81 * decel_g
    
    print(f"Calculated crash load: {force:.1f} N")
    print()
    
    # Material candidates
    candidates = {
        'carbon_fiber': {
            'density': 1600,
            'strength': 600e6,
            'modulus': 230e9,
            'cost_per_kg': 40,
            'pros': ['Lightest', 'Stiffest', 'Best performance'],
            'cons': ['Brittle (shatters in crash)', 'Expensive', 'Hard to repair']
        },
        'aluminum_7075': {
            'density': 2810,
            'strength': 505e6,
            'modulus': 72e9,
            'cost_per_kg': 5,
            'pros': ['Repairable', 'Tough', 'Affordable'],
            'cons': ['Heavier', 'Can bend permanently']
        },
        'fiberglass': {
            'density': 1850,
            'strength': 300e6,
            'modulus': 25e9,
            'cost_per_kg': 15,
            'pros': ['Good balance', 'Some flex', 'Moderate cost'],
            'cons': ['Lower performance than carbon', 'Can delaminate']
        }
    }
    
    print("Material Analysis:")
    print()
    
    results = []
    
    for name, props in candidates.items():
        # Design tube: assume 10mm OD, optimize wall thickness
        OD = 0.010  # m
        length = 0.250  # m
        
        # Required wall thickness for strength (simplified)
        # Bending stress = M*c/I where M = F*L, c = OD/2, I = pi/64*(OD^4-(OD-2t)^4)
        # Solve for t (wall thickness)
        
        # Simplified: assume thin-walled tube
        safety_factor = 1.5
        max_stress = props['strength'] / safety_factor
        
        # Approximate thickness needed
        thickness = (force * length * (OD/2)) / (max_stress * (3.14159 * OD**3 / 32))
        
        # Volume and mass
        volume = 3.14159 * length * ((OD/2)**2 - ((OD/2) - thickness)**2)
        mass = volume * props['density']
        cost = mass * props['cost_per_kg']
        
        # Score
        weight_score = 20 / (mass * 1000)  # Target 20g
        cost_score = 10 / max(cost, 0.1)   # Target $10
        strength_score = (props['strength'] / 600e6) * 100
        
        total_score = (weight_score * 0.4) + (cost_score * 0.3) + (strength_score * 0.3)
        
        results.append({
            'name': name,
            'mass_g': mass * 1000,
            'cost': cost,
            'score': total_score,
            'pros': props['pros'],
            'cons': props['cons']
        })
        
        print(f"{name.upper().replace('_', ' ')}:")
        print(f"  Wall thickness: {thickness * 1000:.2f} mm")
        print(f"  Mass: {mass * 1000:.1f} g")
        print(f"  Cost: ${cost:.2f}")
        print(f"  Score: {total_score:.1f}/100")
        print(f"  Pros: {', '.join(props['pros'])}")
        print(f"  Cons: {', '.join(props['cons'])}")
        print()
    
    # Sort by score
    results.sort(key=lambda x: x['score'], reverse=True)
    
    print("=" * 70)
    print("RECOMMENDATION")
    print("=" * 70)
    print()
    
    best = results[0]
    print(f"✓ PRIMARY: {best['name'].upper().replace('_', ' ')}")
    print(f"  - Highest score ({best['score']:.1f}/100)")
    print(f"  - Mass: {best['mass_g']:.1f}g (within budget)")
    print(f"  - Cost: ${best['cost']:.2f}")
    print()
    
    print("USAGE RECOMMENDATIONS:")
    print()
    
    if best['name'] == 'carbon_fiber':
        print("  RACING: Carbon fiber for maximum performance")
        print("    - Use for competition where weight is critical")
        print("    - Keep spare arms (they will break)")
        print("    - Consider insurance against crashes")
        print()
        print("  LEARNING: Start with aluminum or fiberglass")
        print("    - More forgiving of crashes")
        print("    - Much cheaper to replace")
        print("    - Can practice without fear")
    
    print()
    print("REAL-WORLD DECISION:")
    print("  - Beginners → Aluminum (cheap, repairable)")
    print("  - Intermediate → Fiberglass (good balance)")
    print("  - Racing → Carbon fiber (performance)")
    print()
    
    print("Additional considerations:")
    print("  ✓ Motor mounting: Ensure compatibility")
    print("  ✓ Vibration damping: Add rubber grommets")
    print("  ✓ Aerodynamics: Streamline shape if weight allows")
    print("  ✓ Spare parts: Buy 2-3x arms (crashes inevitable)")
    print()

if __name__ == "__main__":
    main()
