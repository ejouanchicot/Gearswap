---
paths:
  - "**/*_sets.lua"
  - "**/sets/*.lua"
---

# Equipment Sets - Editing Rules

## Structure
```lua
-- 1. Equipment definitions (reusable lookups)
local SouvHead = {name="Souveran Schaller +1", augments={...}, priority=15}
local Cichol = {}
Cichol.da = {name="Cichol's Mantle", augments={'"Dbl.Atk."+10',...}}
Cichol.stp = {name="Cichol's Mantle", augments={'"Store TP"+10',...}}

-- 2. Set definitions using those lookups
sets.idle = { head=SouvHead, body=SouvBody, ... }
sets.engaged = set_combine(sets.idle, { ring1=MoonlightRing1 })
```

## Naming Conventions
- Equipment vars: `CamelCase` + slot hint (`SouvHead`, `JumalikBody`)
- Variant tables: `VarName.variant` (`Cichol.da`, `Rudianos.tank`)
- Wardrobe items: `bag = 'wardrobe N'` for multi-wardrobe slots
- Moonlight rings: `MoonlightRing1`, `MoonlightRing2` (separate wardrobe slots)

## Rules
- Define equipment ONCE as local variable, reference in multiple sets
- Use `set_combine()` for inheritance (never copy-paste full sets)
- Include `priority` for items that conflict in the same slot
- Always specify `augments` for augmented items (exact match required)
- AF/Relic should be +3, Empyrean should be +2 (max tier for endgame)

## FFXI Item Names
- Case-sensitive and exact: `"Souveran Schaller +1"` not `"souveran schaller +1"`
- Apostrophes matter: `"Piety Cap +3"` not `"Piety Cap+3"`
- Japanese items use exact romanization from game data

## Anti-patterns
- Inline equipment definitions in sets (define once, reference many)
- Missing augments on augmented items (causes wrong item equipped)
- Duplicate slot assignments in same set (last one wins silently)
- Using +1/+2 when +3 exists for AF/Relic pieces
