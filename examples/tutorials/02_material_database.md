# Tutorial 2: Material Database Basics

## Goal
Learn to query, compare, and identify materials.

## Part 1: Looking Up Materials

### Basic lookup
```
>>> material aluminum
```

Shows density, strength, conductivity, etc.

### Get specific property
```
>>> density aluminum
2700 kg/m³
```

### List all materials
```
>>> list materials
```

## Part 2: Material Identification

### Scenario: Found unknown metal sample

Measure density: 2700 kg/m³

```
>>> identify 2700
Best match: Aluminum
Confidence: 98%
```

The system tells you what it probably is!

### With multiple properties
```
>>> infer density=1240 melts_at=180
Best match: PLA
Confidence: 99%
```

More info = better confidence.

## Part 3: Comparing Materials

### Compare 3D printing options
```
>>> compare pla petg abs
```

Shows side-by-side table:
- Density
- Strength
- Temperature limits
- Cost

Winner highlighted for each category.

## Part 4: Finding Materials

### By constraints
```
>>> find material min_strength=400e6 max_density=5000
```

Returns only materials meeting BOTH constraints.

### By application
```
>>> recommend material application=heat_sink
```

System suggests based on thermal conductivity.

## Exercises

1. Find all plastics that melt above 200°C
2. Identify a mystery material with density 7850 kg/m³
3. Compare aluminum vs. steel for strength-to-weight
4. Find cheapest material with strength >300 MPa

## Key Concepts

**Confidence ratings** (1-5):
- 5 = Verified standard (NIST, ASTM)
- 4 = Manufacturer datasheet
- 3 = Engineering handbook
- 2 = Estimated

**Sources**: All data cited (click for details)

**Temperature dependence**: Properties vary with temp
```
>>> material aluminum --temp 200
```

## Next: Tutorial 3
Learn the inference system (smart property filling)
