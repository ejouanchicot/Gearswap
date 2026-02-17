# WHM - Equipment Sets Reference

**File**: `shared/jobs/whm/sets/whm_sets.lua`

---

## Set Categories

```lua
sets.precast = {}        -- Fast Cast, JA, WS
sets.midcast = {}        -- Spell/ability midcast
sets.idle = {}           -- Idle (not fighting)
sets.engaged = {}        -- Engaged (fighting)
```

---

## Precast Sets

### Fast Cast

```lua
sets.precast.FC = {
    -- Fast Cast gear (target: 80% cap)
}
```

### Job Abilities

```lua
-- Job-specific abilities
```

### Weaponskills

```lua
-- Weaponskill sets
```

---

## Midcast Sets

**MidcastManager Fallback Chain**:

```
Priority 1: sets.midcast['Skill'].Type.Mode  (most specific)
Priority 2: sets.midcast['Skill'].Type
Priority 3: sets.midcast['Skill'].Mode
Priority 4: sets.midcast['Skill']            (guaranteed)
```

---

## Idle Sets

```lua
sets.idle.Normal = { ... }
sets.idle.PDT = { ... }
```

---

## Engaged Sets

```lua
sets.engaged.Normal = { ... }
sets.engaged.PDT = { ... }
```

---

## Validating Sets

```
//gs c checksets

>> Output:
[WHM] 156/160 items validated (97.5%)
```

**Status meanings**:

- VALID: In inventory
- STORAGE: In mog house/sack
- MISSING: Not found
