# RDM - States & Modes

**Total States**: 20 configurable modes

---

## 📊 What are States?

States = Configuration options you cycle through with keybinds.

**Example**:

```lua
state.EnfeebleMode = M{'Potency', 'Skill', 'Duration'}  -- 3 options
-- Press Alt+5 to cycle: Potency → Skill → Duration → Potency
```

---

## 📋 All RDM States

| State | Options | Default | Keybind | Description |
|-------|---------|---------|---------|-------------|
| **HybridMode** | PDT, Normal | Normal | (Mote default) | Combat defense mode |
| **EngagedMode** | DT, Acc, TP, Enspell | DT | Alt+3 | Melee combat focus |
| **IdleMode** | Refresh, DT | Refresh | Alt+4 | Idle gear focus |
| **MainWeapon** | Naegling, Colada, Daybreak | Naegling | Alt+1 | Main weapon |
| **SubWeapon** | Ammurapi, Genmei | Genmei | Alt+2 | Sub weapon |
| **CombatMode** | Off, On | Off | Alt+0 | Weapon slot locking |
| **EnfeebleMode** | Potency, Skill, Duration | Potency | Alt+5 | Enfeebling magic focus |
| **NukeMode** | FreeNuke, Magic Burst | FreeNuke | Alt+6 | Elemental magic focus |
| **MainLightSpell** | Fire, Aero, Thunder | Fire | Alt+8 | Primary light element |
| **SubLightSpell** | Fire, Aero, Thunder | Thunder | Alt+9 | Secondary light element |
| **MainDarkSpell** | Blizzard, Stone, Water | Blizzard | Alt+- | Primary dark element |
| **SubDarkSpell** | Blizzard, Stone, Water | Stone | Alt+= | Secondary dark element |
| **NukeTier** | V, VI, IV, III, II, I | V | Ctrl+= | Nuke tier selection |
| **Enspell** | Enfire, Enblizzard, Enaero, Enstone, Enthunder, Enwater | Enfire | Alt+7 | Weapon enchantment |
| **GainSpell** | Gain-STR, Gain-DEX, Gain-VIT, Gain-AGI, Gain-INT, Gain-MND, Gain-CHR | Gain-STR | F1 | Stat buff |
| **Barspell** | Barfira, Barblizzara, Baraera, Barstonra, Barthundra, Barwatera | Barfira | F2 | Elemental resist |
| **BarAilment** | Baramnesia, Barparalysis, Barsilence, Barpetrify, Barpoison, Barblind, Barsleep, Barvirus | Baramnesia | F3 | Ailment resist |
| **Spike** | Blaze Spikes, Ice Spikes, Shock Spikes | Blaze Spikes | F4 | Damage reflection |
| **SaboteurMode** | Off, On | Off | Alt+P | Auto-Saboteur before enfeebles |
| **Storm** | Firestorm, Hailstorm, Windstorm, Sandstorm, Thunderstorm, Rainstorm, Aurorastorm, Voidstorm | Firestorm | F5 | SCH subjob only (conditional) |

---

## ⚙️ How States Affect Gear

### HybridMode

```
HybridMode: PDT
→ Uses: sets.engaged.PDT (50% physical damage reduction)

HybridMode: Normal
→ Uses: sets.engaged.Normal (maximum DPS)
```

### EngagedMode

```
EngagedMode: DT
→ Uses: sets.engaged.DT (damage taken reduction)

EngagedMode: Acc
→ Uses: sets.engaged.Acc (accuracy focus)

EngagedMode: TP
→ Uses: sets.engaged.TP (TP gain focus - Store TP, Dual Wield)

EngagedMode: Enspell
→ Uses: sets.engaged.Enspell (enspell damage focus)
```

### IdleMode

```
IdleMode: Refresh
→ Uses: sets.idle.Refresh (MP refresh gear - Refresh+, Regen)

IdleMode: DT
→ Uses: sets.idle.DT (damage taken reduction when idle)
```

### EnfeebleMode

```
EnfeebleMode: Potency
→ Uses: sets.midcast['Enfeebling Magic'].mnd_potency.Potency (MND/INT focus)

EnfeebleMode: Skill
→ Uses: sets.midcast['Enfeebling Magic'].mnd_potency.Skill (Enfeebling Skill+)

EnfeebleMode: Duration
→ Uses: sets.midcast['Enfeebling Magic'].mnd_potency.Duration (Duration+ gear)
```

### NukeMode

```
NukeMode: FreeNuke
→ Uses: sets.midcast['Elemental Magic'].FreeNuke (high-tier nukes)

NukeMode: Magic Burst
→ Uses: sets.midcast['Elemental Magic']['Magic Burst'] (magic burst damage)
```

### MainWeapon / SubWeapon

```
MainWeapon: Naegling
→ Equips: Naegling (Savage Blade weapon)

MainWeapon: Colada
→ Equips: Colada (Enspell shield)

MainWeapon: Daybreak
→ Equips: Daybreak (Magic nuke weapon)

SubWeapon: Ammurapi / Genmei
→ Equips: Ammurapi or Genmei (Enfeebling swords)
```

### CombatMode

```
CombatMode: Off
→ Weapons can swap freely during combat

CombatMode: On
→ Weapons locked (main, sub, range slots disabled from swapping)
```

**Use case**: Turn ON when you don't want weapons swapping during nukes/enfeebles.

---

## 🎯 State Combinations

RDM uses **nested set logic** for maximum flexibility:

**Example 1: Enfeebling Magic**

```
EnfeebleMode: Potency
Spell: Gravity (MND-based potency)

→ Selects: sets.midcast['Enfeebling Magic'].mnd_potency.Potency
```

**Example 2: Elemental Magic**

```
NukeMode: FreeNuke
Spell: Fire VI

→ Selects: sets.midcast['Elemental Magic'].FreeNuke
```

---

## 🔍 Checking Current State

**Method 1**: UI overlay (if enabled)

```
//gs c ui
→ Shows all states with current values
```

**Method 2**: Console command:

```
//gs c state EnfeebleMode
→ Shows: "EnfeebleMode: Potency"
```

**Method 3**: Watch gear swap

```
Enable debugmidcast:
//gs c debugmidcast

Cast spell:
/ma "Gravity" <t>

→ Console shows which set was selected
```

---

## 🔧 State Management Tips

**Tip 1**: Set states BEFORE casting

```
Alt+5 (cycle EnfeebleMode to Duration)
/ma "Slow II" <t>
→ Casts with Duration+ gear
```

**Tip 2**: Use CombatMode to lock weapons

```
Alt+0 (turn CombatMode ON)
→ Weapons won't swap during spells
→ Prevents accidental weapon swaps
```

**Tip 3**: Pre-select elements for quick nuking

```
Alt+8 (set MainLightSpell to Thunder)
Ctrl+= (set NukeTier to VI)
→ Now Ctrl+8 always casts Thunder VI
```

**Tip 4**: SCH subjob Storm management

```
// With SCH subjob:
F5 (cycle Storm to Firestorm)
//gs c caststorm
→ Casts Firestorm

// Without SCH subjob:
F5 (does nothing - state doesn't exist)
```
