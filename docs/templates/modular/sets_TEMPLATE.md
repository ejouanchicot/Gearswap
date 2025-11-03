# [JOB] - Equipment Sets Reference

**File**: `shared/jobs/[job]/sets/[job]_sets.lua`

---

## 📊 Set Categories

```lua
sets.precast = {}        -- Fast Cast, JA, WS
sets.midcast = {}        -- Spell/ability midcast
sets.idle = {}           -- Idle (not fighting)
sets.engaged = {}        -- Engaged (fighting)
```

---

## ⚡ Precast Sets

### Fast Cast

```lua
sets.precast.FC = [FC_DETAILS]
```

**Purpose**: Reduce casting time
**Target**: 80% Fast Cast cap

### Job Abilities

[JA_SETS]

### Weaponskills

[WS_SETS]

---

## 🎭 Midcast Sets

[MIDCAST_SETS]

**MidcastManager Fallback Chain**:

```
Priority 1: sets.midcast['Skill'].Type.Mode  (most specific)
Priority 2: sets.midcast['Skill'].Type
Priority 3: sets.midcast['Skill'].Mode
Priority 4: sets.midcast['Skill']            (guaranteed)
```

---

## 🛡️ Idle Sets

```lua
sets.idle.Normal = { ... }  -- Refresh, Regen
sets.idle.PDT = { ... }     -- Physical Damage Taken -
```

---

## ⚔️ Engaged Sets

[ENGAGED_SETS]

---

## ✅ Validating Sets

```
//gs c checksets

→ Output:
[JOB] ✅ 156/160 items validated (97.5%)

--- STORAGE ITEMS (3) ---
[STORAGE] sets.idle.PDT.body: "Item Name"

--- MISSING ITEMS (1) ---
[MISSING] sets.precast.WS['WS'].ring1: "Item Name"
```

**Status meanings**:

- ✅ VALID: In inventory
- 🗄️ STORAGE: In mog house/sack
- ❌ MISSING: Not found
