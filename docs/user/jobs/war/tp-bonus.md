# TP Bonus Reference

The WSPrecastHandler automatically calculates and equips TP bonus gear before weapon skills. It selects the minimum pieces needed to reach the next TP threshold (2000 or 3000), capped at 3000.

---

## Universal

| Item | Slot | Bonus | Jobs |
|------|------|-------|------|
| Moonshade Earring | ear1 | +250 | All 15 |

---

## Weapons

| Job | Weapon | Bonus |
|-----|--------|-------|
| WAR | Chango | +500 |
| PLD | Sequence | +500 |
| THF | Aeneas | +500 |
| THF | Centovente | +1000 |
| DNC | Aeneas | +500 |
| DNC | Centovente | +1000 |
| BRD | Aeneas | +500 |
| BRD | Centovente | +1000 |
| DRK | Anguta | +500 |
| SAM | Dojikiri Yasutsuna | +500 |
| RUN | Lionheart | +500 |
| COR | Fomalhaut | +500 |
| COR | Anarchy +2 | +1000 |

Shared weapons: Aeneas (THF/DNC/BRD), Sequence (PLD), Fomalhaut (COR).

---

## Armor

| Job | Item | Slot | Bonus |
|-----|------|------|-------|
| WAR | Boii Cuisses +3 | legs | +100 |
| SAM | Mpaca's Cap | head | +200 |

---

## Buff-based TP bonus

| Job | Source | Base | Max (with JP/merits) |
|-----|--------|------|----------------------|
| WAR | Fencer | 630 | 860 (20/20 JP Gifts) |
| WAR | Warcry | 500 | 700 (5/5 merits + Agoge Mask) |
| BST | Fencer | 200 | 630 (4 JP Gift ranks) |
| SAM | Hagakure | 1000 | 1200 (20/20 JP Gifts) |

---

## Implementation status

**14/15 jobs** have TP config files. PUP is the only job without one (uses empty fallback).

All 15 jobs call `WSPrecastHandler.handle()` in precast. The handler uses `TPBonusCalculator` to select optimal gear.

### Config files

Per-job: `config/[job]/[JOB]_TP_CONFIG.lua`

Centralized logic:
- `shared/utils/precast/ws_precast_handler.lua`
- `shared/utils/precast/tp_bonus_handler.lua`
- `shared/utils/weaponskill/tp_bonus_calculator.lua`

### Jobs with minimal configs (Moonshade only)

BLM, GEO, RDM, WHM -- these jobs rarely melee, so only Moonshade Earring is configured.
