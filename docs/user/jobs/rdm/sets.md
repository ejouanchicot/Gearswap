# RDM - Equipment Sets Reference

**File**: `shared/jobs/rdm/sets/rdm_sets.lua`

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
    -- Target: 80% Fast Cast cap
    -- Includes: Fast Cast gear from all slots
    -- Example: Atrophy Chapeau +3, Leyline Gloves, etc.
}
```

**Purpose**: Reduce casting time
**Target**: 80% Fast Cast cap

### Job Abilities

```lua
sets.precast.JA['Convert'] = { ... }
sets.precast.JA['Chainspell'] = { ... }
sets.precast.JA['Saboteur'] = { ... }
sets.precast.JA['Composure'] = { ... }
```

**Special**: Saboteur set used when SaboteurMode = On

### Weaponskills

```lua
sets.precast.WS['Savage Blade'] = { ... }  -- Naegling WS
sets.precast.WS['Sanguine Blade'] = { ... }  -- Dark magic WS
sets.precast.WS['Red Lotus Blade'] = { ... }  -- Fire magic WS
sets.precast.WS['Seraph Blade'] = { ... }  -- Light magic WS
sets.precast.WS['Aeolian Edge'] = { ... }  -- AOE magic WS
```

---

## Midcast Sets

### Enfeebling Magic (Nested Structure)

**Triple Nested: Type >> Mode >> Target**

```lua
sets.midcast['Enfeebling Magic'] = {}

-- MND-based potency enfeebles (Slow, Paralyze, etc.)
sets.midcast['Enfeebling Magic'].mnd_potency = {}
sets.midcast['Enfeebling Magic'].mnd_potency.Potency = { ... }  -- Max MND
sets.midcast['Enfeebling Magic'].mnd_potency.Skill = { ... }    -- Enfeebling Skill+
sets.midcast['Enfeebling Magic'].mnd_potency.Duration = { ... } -- Duration+

-- INT-based potency enfeebles (Blind, Poison, etc.)
sets.midcast['Enfeebling Magic'].int_potency = {}
sets.midcast['Enfeebling Magic'].int_potency.Potency = { ... }  -- Max INT
sets.midcast['Enfeebling Magic'].int_potency.Skill = { ... }    -- Enfeebling Skill+
sets.midcast['Enfeebling Magic'].int_potency.Duration = { ... } -- Duration+

-- MND-based accuracy enfeebles (Gravity, Silence, etc.)
sets.midcast['Enfeebling Magic'].mnd_accuracy = {}
sets.midcast['Enfeebling Magic'].mnd_accuracy.Potency = { ... }  -- Max MND
sets.midcast['Enfeebling Magic'].mnd_accuracy.Skill = { ... }    -- Enfeebling Skill+
sets.midcast['Enfeebling Magic'].mnd_accuracy.Duration = { ... } -- Duration+

-- INT-based accuracy enfeebles (Bind, Sleep, etc.)
sets.midcast['Enfeebling Magic'].int_accuracy = {}
sets.midcast['Enfeebling Magic'].int_accuracy.Potency = { ... }  -- Max INT
sets.midcast['Enfeebling Magic'].int_accuracy.Skill = { ... }    -- Enfeebling Skill+
sets.midcast['Enfeebling Magic'].int_accuracy.Duration = { ... } -- Duration+
```

**MidcastManager Fallback Chain** (Enfeebling):

```
Priority 1: sets.midcast['Enfeebling Magic'].mnd_potency.Potency  (most specific)
Priority 2: sets.midcast['Enfeebling Magic'].mnd_potency          (type only)
Priority 3: sets.midcast['Enfeebling Magic'].Potency              (mode only)
Priority 4: sets.midcast['Enfeebling Magic']                      (guaranteed)
```

### Elemental Magic

**Double Nested: Mode**

```lua
sets.midcast['Elemental Magic'] = {}
sets.midcast['Elemental Magic'].FreeNuke = { ... }       -- High-tier nukes (V, VI)
sets.midcast['Elemental Magic']['Magic Burst'] = { ... } -- Magic Burst damage
```

**Usage**:

- NukeMode: FreeNuke >> uses FreeNuke set
- NukeMode: Magic Burst >> uses Magic Burst set

### Enhancing Magic

**Triple Nested: Target >> Duration**

```lua
sets.midcast['Enhancing Magic'] = {}

-- Self-only buffs (Phalanx, Enspells)
sets.midcast['Enhancing Magic'].self = {}
sets.midcast['Enhancing Magic'].self.Duration = { ... }  -- Duration+ gear

-- Others buffs (Haste, Refresh)
sets.midcast['Enhancing Magic'].others = {}
sets.midcast['Enhancing Magic'].others.Duration = { ... }  -- Duration+ gear
```

**Special Sets**:

```lua
sets.midcast.Phalanx = { ... }         -- Specific Phalanx set
sets.midcast.Refresh = { ... }         -- Specific Refresh set
sets.midcast['Enspell'] = { ... }      -- Enspell potency
sets.midcast['Stoneskin'] = { ... }    -- Stoneskin HP+
sets.midcast['Aquaveil'] = { ... }     -- Aquaveil interrupt reduction
```

### Healing Magic

```lua
sets.midcast['Healing Magic'] = { ... }  -- Cure potency, MND
```

### Dark Magic

```lua
sets.midcast['Dark Magic'] = { ... }    -- Dark magic accuracy, skill
sets.midcast.Drain = { ... }            -- Drain potency
sets.midcast.Aspir = { ... }            -- Aspir potency
```

---

## Idle Sets

```lua
sets.idle = {}

sets.idle.Refresh = {
    -- MP Refresh gear (Refresh+, Regen)
    -- Example: Malignance set, Refresh+ earrings
}

sets.idle.DT = {
    -- Damage Taken reduction
    -- Example: PDT/MDT gear
}
```

**State**: Controlled by `state.IdleMode` (Alt+4)

---

## Engaged Sets

```lua
sets.engaged = {}

sets.engaged.Normal = {
    -- Maximum DPS (Store TP, Dual Wield, Attack, Accuracy)
}

sets.engaged.PDT = {
    -- Physical Damage Taken reduction while engaged
}

-- EngagedMode specific sets:
sets.engaged.DT = {
    -- Damage Taken reduction (PDT + MDT)
}

sets.engaged.Acc = {
    -- Accuracy focus (vs high-evasion targets)
}

sets.engaged.TP = {
    -- TP gain focus (Store TP, Dual Wield)
}

sets.engaged.Enspell = {
    -- Enspell damage focus (Enspell Damage+, Magic Accuracy)
}
```

**State**: Controlled by `state.EngagedMode` (Alt+3)

---

## Weapon Sets

**Weapons are controlled by states**, not swapped via sets:

```lua
-- Defined in RDM_ENGAGED.lua module
if state.MainWeapon.value == 'Naegling' then
    equip({main = "Naegling"})
elseif state.MainWeapon.value == 'Colada' then
    equip({main = "Colada"})
elseif state.MainWeapon.value == 'Daybreak' then
    equip({main = "Daybreak"})
end

if state.SubWeapon.value == 'Ammurapi' then
    equip({sub = "Ammurapi Shield"})
elseif state.SubWeapon.value == 'Genmei' then
    equip({sub = "Genmei Shield"})
end
```

**Control**: Alt+1 (MainWeapon), Alt+2 (SubWeapon)

---

## Validating Sets

```
//gs c checksets

>> Output:
[RDM] 156/160 items validated (97.5%)

--- VALID ITEMS (156) ---
All items found in inventory

--- STORAGE ITEMS (3) ---
[STORAGE] sets.idle.DT.body: "Malignance Tabard"
[STORAGE] sets.engaged.PDT.legs: "Malignance Tights"
[STORAGE] sets.midcast.Phalanx.head: "Atrophy Chapeau +3"

--- MISSING ITEMS (1) ---
[MISSING] sets.precast.WS['Savage Blade'].ring1: "Epaminondas's Ring"
```

**Status meanings**:

- **VALID**: Item in inventory/equipped
- **STORAGE**: Item in mog house/sack/etc.
- **MISSING**: Item not found anywhere

**Action**:

- STORAGE items: Retrieve from storage before using
- MISSING items: Acquire or remove from sets

---

## Debug Set Selection

**Enable midcast debug**:

```
//gs c debugmidcast
```

**Cast a spell**:

```
/ma "Gravity" <t>
```

**Console output**:

```
[MIDCAST] Skill: Enfeebling Magic
[MIDCAST] Type: mnd_accuracy (from RDM_SPELL_DATABASE)
[MIDCAST] Mode: Potency (from state.EnfeebleMode)
[MIDCAST] Selected: sets.midcast['Enfeebling Magic'].mnd_accuracy.Potency
```

**This shows**:

1. Which skill was detected
2. Which type was selected (from database)
3. Which mode was active (from state)
4. Which set was equipped

---

## Adding New Sets

**Example: Add a new Enfeeble mode (Macc)**

1. **Add state** (in `RDM_STATES.lua`):

```lua
state.EnfeebleMode = M{'Potency', 'Skill', 'Duration', 'Macc'}
```

2. **Add sets** (in `rdm_sets.lua`):

```lua
sets.midcast['Enfeebling Magic'].mnd_potency.Macc = {
    -- Magic Accuracy gear
}
sets.midcast['Enfeebling Magic'].int_potency.Macc = {
    -- Magic Accuracy gear
}
-- ... etc.
```

3. **Add keybind** (in `RDM_KEYBINDS.lua`):

```lua
-- Already exists: Alt+5 cycles through all EnfeebleMode options
```

4. **Test**:

```
Alt+5 (cycle to Macc)
/ma "Slow II" <t>
>> Should use sets.midcast['Enfeebling Magic'].mnd_potency.Macc
```
