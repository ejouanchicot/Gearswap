# Auto-Tier System

Automatically downgrades healing spells and abilities to the optimal tier based on target's missing HP. Saves MP (WHM) and TP (DNC).

---

## WHM Cure Auto-Tier

Macro Cure VI and the system downgrades to the right tier.

**Toggle**: `//gs c cycle CureAutoTier` (On / Off)

### Thresholds

Defined in `config/whm/WHM_CURE_CONFIG.lua`. A 50 HP safety margin is added to the target's missing HP before lookup.

| Tier | HP missing range | MP cost |
|------|-----------------|---------|
| Cure I | 0-200 | 8 |
| Cure II | 200-400 | 24 |
| Cure III | 400-700 | 46 |
| Cure IV | 700-1100 | 88 |
| Cure V | 1100-1600 | 135 |
| Cure VI | 1600+ | 210 |

Thresholds are fixed values from the config file. They do not adjust based on Cure Potency gear.

When auto-tier is Off, recast fallback still works: if the spell you macro'd is on recast, the system tries lower tiers then higher tiers.

---

## DNC Waltz Auto-Tier

Always active when using `//gs c waltz`. No toggle needed.

**Commands**:
- `//gs c waltz <target>` -- single-target heal (auto-selects tier I-V)
- `//gs c aoewaltz` -- Divine Waltz (tries II first, falls back to I)

### Thresholds

Defined in `shared/utils/dnc/waltz_manager.lua`. Falls back to other tiers if the preferred one is on recast or TP is insufficient.

| Tier | TP cost | HP missing range |
|------|---------|-----------------|
| Curing Waltz | 200 | 0-199 |
| Curing Waltz II | 350 | 200-599 |
| Curing Waltz III | 500 | 600-1099 |
| Curing Waltz IV | 650 | 1100-1499 |
| Curing Waltz V | 800 | 1500+ |

| AOE tier | TP cost |
|----------|---------|
| Divine Waltz | 400 |
| Divine Waltz II | 800 |

---

## Troubleshooting

**Cure always casts the spell you macro'd**: Check `//gs c state CureAutoTier` shows On. Toggle with `//gs c cycle CureAutoTier`.

**Wrong tier selected**: The 50 HP safety margin shifts thresholds slightly upward. Party member HP is estimated from HPP percentage (exact for self). Recast to get a fresh calculation.

**Waltz command does nothing**: Verify DNC is loaded (`//gs c reload`). Check TP (minimum 200 for Waltz I). Check syntax: `//gs c waltz <stpc>`.
