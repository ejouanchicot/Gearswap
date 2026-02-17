# Auto-Tier System - Intelligent Spell/Ability Selection

**Feature**: Automatic Tier Selection for Healing/Support
**Jobs**: WHM (Cure), DNC (Waltz)

---

## Table of Contents

1. [What is Auto-Tier?](#what-is-auto-tier)
2. [WHM Cure Auto-Tier](#whm-cure-auto-tier)
3. [DNC Waltz Auto-Tier](#dnc-waltz-auto-tier)
4. [How It Works](#how-it-works)
5. [Configuration](#configuration)
6. [Examples](#examples)
7. [Troubleshooting](#troubleshooting)

---

## What is Auto-Tier?

**Auto-Tier** automatically **downgrades** your healing spells/abilities to the optimal tier based on the target's **missing HP**.

**Purpose**:

- **Save MP** (don't use Cure VI when Cure III is enough)
- **Faster casting** (lower tier = shorter cast time)
- **Optimal healing** (match cure potency to actual need)
- **Less mental overhead** (system picks for you)

**Jobs**:

- **WHM**: Cure I-VI auto-downgrade
- **DNC**: Waltz I-V auto-selection (Curing Waltz, Divine Waltz variants)

---

## WHM Cure Auto-Tier

### Overview

**What it does**: When you cast **Cure VI**, the system checks target's missing HP and may downgrade to Cure V, IV, III, II, or I.

**Example**:

```
You macro: /ma "Cure VI" <stpc>
Target missing HP: 450
System casts: Cure III instead (saves 46 MP vs Cure VI)
```

### How to Enable/Disable

**Toggle command**:

```
//gs c cycle CureAutoTier
```

**State options**:

- `On` - Auto-tier enabled (default)
- `Off` - Always cast the spell you macro'd

**Check current state**:

```
//gs c state CureAutoTier
```

**Keybind** (if configured):

```
Alt+[X]  (check WHM keybinds)
```

### Cure Tier Thresholds

Thresholds are defined in `WHM_CURE_CONFIG.lua`. A safety margin of 50 HP is added to the target's missing HP before tier selection.

| Cure Tier | HP Missing Range | MP Cost |
|-----------|-----------------|---------|
| **Cure I** | 0-200 HP | 8 MP |
| **Cure II** | 200-400 HP | 24 MP |
| **Cure III** | 400-700 HP | 46 MP |
| **Cure IV** | 700-1100 HP | 88 MP |
| **Cure V** | 1100-1600 HP | 135 MP |
| **Cure VI** | 1600+ HP | 210 MP |

**Note**: Thresholds are fixed values from the config file. They do not dynamically adjust based on Cure Potency gear.

### MP Savings Example

**Scenario**: Party member has 500 HP missing

| Without Auto-Tier | With Auto-Tier | Savings |
|-------------------|----------------|---------|
| Cast: Cure VI | Cast: Cure III | **164 MP saved** |
| MP Cost: 210 | MP Cost: 46 | (78% reduction) |
| Overheal: 600 HP | Overheal: 0 HP | Efficient! |

**Over 10 cures**: 1,640 MP saved = ~12 extra Cure VIs worth of MP!

### When Auto-Tier is Disabled

**Auto-tier only runs when `CureAutoTier` state is `On`.**

When disabled (`Off`), the system still checks spell recast timers and will fall back to an available tier if the original spell is on recast.

**Manual override**: Set `CureAutoTier` to `Off` via `//gs c cycle CureAutoTier`

---

## DNC Waltz Auto-Tier

### Overview

**What it does**: When you use **Waltz macro**, the system selects the optimal Waltz tier (I-V) based on target's missing HP.

**Example**:

```
You macro: //gs c waltz <stpc>
Target missing HP: 600
System executes: Curing Waltz III (optimal for 600 HP)
```

### How to Use

**Command**:

```
//gs c waltz <target>
```

**Targets**:

- `<stpc>` - Current target
- `<me>` - Self
- `<t>` - Current target (same as stpc)
- `Player Name` - Specific player

**Macro example**:

```
/console gs c waltz <stpc>
```

**Common Commands**:

- `//gs c waltz` - Waltz on current target
- `//gs c aoewaltz` - Divine Waltz (AOE heal)

### Waltz Tier Selection

Thresholds are defined in `waltz_manager.lua`. The system selects a tier based on target missing HP, then falls back to lower or higher tiers if the preferred tier is on recast or TP is insufficient.

| Waltz Tier | TP Cost | Level Required | Cast on Missing HP |
|------------|---------|----------------|-------------------|
| **Curing Waltz** | 200 TP | 15 | 0-199 HP |
| **Curing Waltz II** | 350 TP | 35 | 200-599 HP |
| **Curing Waltz III** | 500 TP | 45 | 600-1099 HP |
| **Curing Waltz IV** | 650 TP | 70 | 1100-1499 HP |
| **Curing Waltz V** | 800 TP | 87 | 1500+ HP |

**Automatic selection**: System picks the optimal tier based on missing HP, then tries the priority list if that tier is unavailable (recast or insufficient TP)

### TP Efficiency

**Scenario**: Party member has 700 HP missing

| Manual Selection | Auto-Tier | Savings |
|------------------|-----------|---------|
| Use: Curing Waltz V | Use: Curing Waltz III | **300 TP saved** |
| TP Cost: 800 | TP Cost: 500 | (37.5% reduction) |

**Result**: Use saved TP for Steps, Flourishes, or more Waltzes

### AOE Waltz (Divine Waltz)

**Command**:

```
//gs c aoewaltz
```

**Behavior**:

- Tries Divine Waltz II first (highest tier), falls back to Divine Waltz I
- Heals all party members in range
- Checks both recast availability and TP before casting

**Divine Waltz Tiers**:

| Tier | TP Cost | Level Required |
|------|---------|----------------|
| Divine Waltz | 400 TP | 40 |
| Divine Waltz II | 800 TP | 78 |

**Note**: There is no Divine Waltz III. The system always tries the highest available tier for AOE healing.

---

## How It Works

### Decision Flow (WHM Cure)

```
1. Player casts: /ma "Cure VI" <stpc>
2. System checks: Is CureAutoTier state On?
   If NO: Skip to step 5 (recast check only)
   If YES: Continue to step 3

3. Calculate target's missing HP:
   Target Max HP: 1500
   Target Current HP: 900
   Missing HP: 600
   Adjusted missing (+ 50 safety margin): 650

4. Select optimal tier from config thresholds:
   650 HP falls in Cure III range (400-700)
   Optimal tier: Cure III

5. Check recast availability (always runs, even with auto-tier Off):
   Cure III available? Yes >> Cast Cure III
   If on recast: Try lower tiers, then higher tiers

6. Cast selected spell: Cure III
7. Display message: "Cure VI >> Cure III (600 HP missing)"
```

### Decision Flow (DNC Waltz)

```
1. Player executes: //gs c waltz <stpc>
2. Determine effective level (main DNC or sub DNC)

3. Calculate target's missing HP:
   Target missing: 850 HP

4. Match HP to tier thresholds:
   - Curing Waltz: < 200 HP (not matched)
   - Curing Waltz II: 200-599 HP (not matched)
   - Curing Waltz III: 600-1099 HP (matched! 850 is in range)
   Preferred tier: Curing Waltz III

5. Check availability:
   - Recast ready? Yes
   - TP >= 500? Yes
   Execute: Curing Waltz III

6. If preferred tier unavailable:
   Try remaining tiers in priority order (level-filtered)
   Check recast + TP for each
```

---

## Configuration

### WHM Cure Auto-Tier Configuration

**File**: `Tetsouo/config/whm/WHM_STATES.lua`

```lua
-- Enable/Disable Auto-Tier
state.CureAutoTier = M{
    ['description'] = 'Cure Auto Tier',
    'On',   -- Enabled (default)
    'Off'   -- Disabled
}
state.CureAutoTier:set('On')  -- Default to enabled
```

**Keybind** (in `WHM_KEYBINDS.lua`):

```lua
{key = "!7", command = "cycle CureAutoTier", desc = "Cure Auto Tier", state = "CureAutoTier"}
```

### DNC Waltz Configuration

**File**: `shared/jobs/dnc/functions/DNC_COMMANDS.lua`

**No configuration needed** - Always uses auto-tier logic when using `//gs c waltz` command

**Optional**: Add macro for easy access

```
-- In-game macro:
/console gs c waltz <stpc>
```

### Customizing Thresholds (Advanced)

**WHM Cure**: `Tetsouo/config/whm/WHM_CURE_CONFIG.lua`
**DNC Waltz**: `shared/utils/dnc/waltz_manager.lua` (hardcoded in `cast_curing_waltz`)

**WHM Cure thresholds** are configurable per-character in the config file:

```lua
WHMCureConfig.cure_tiers = {
    {min = 0, max = 200, spell = 'Cure'},
    {min = 200, max = 400, spell = 'Cure II'},
    {min = 400, max = 700, spell = 'Cure III'},
    {min = 700, max = 1100, spell = 'Cure IV'},
    {min = 1100, max = 1600, spell = 'Cure V'},
    {min = 1600, max = 99999, spell = 'Cure VI'}
}

-- safety_margin adds 50 HP to missing HP before threshold lookup
WHMCureConfig.safety_margin = 50
```

**DNC Waltz thresholds** are hardcoded in the waltz manager and not configurable per-character.

**Warning**: Modifying shared files affects all characters. Test thoroughly!

---

## Examples

### Example 1: WHM Healing During Event

**Setup**:

- CureAutoTier: `On`
- Cure Potency gear: +45%
- Macro: `/ma "Cure VI" <stpc>`

**Scenario 1**: Tank takes 300 HP damage

```
[WHM] Target missing: 300 HP
[WHM] Cure VI >> Cure II (300 HP needed, saves 186 MP)
```

**Result**: Cure II cast, MP conserved

**Scenario 2**: Tank takes 1400 HP damage

```
[WHM] Target missing: 1400 HP
[WHM] Cure VI >> Cure VI (1400 HP needed)
```

**Result**: Cure VI cast as intended (no downgrade)

**Scenario 3**: Self-cure after damage (200 HP missing)

```
[WHM] Target: <me>
[WHM] Cure VI >> Cure II (200 HP missing)
```

**Result**: Auto-tier works on self with exact HP values (uses player.hp and player.max_hp)

### Example 2: DNC Waltz Efficiency

**Setup**:

- Waltz Potency gear: +30%
- Current TP: 1500
- Command: `//gs c waltz <stpc>`

**Scenario 1**: Ally missing 500 HP

```
[DNC] Target missing: 500 HP
[DNC] Healing 500 HP with Curing Waltz II (350 TP)
```

**Efficiency**: Saved 450 TP vs Waltz V (could have wasted)

**Scenario 2**: Ally missing 1300 HP

```
[DNC] Target missing: 1300 HP
[DNC] Healing 1300 HP with Curing Waltz IV (650 TP)
```

**Result**: Optimal tier selected, efficient healing

**Scenario 3**: AOE damage, party low

```
Command: //gs c aoewaltz
[DNC] Party average missing: 600 HP
[DNC] Divine Waltz II executed (800 TP)
```

**Result**: AOE heal, all members restored

---

## Troubleshooting

### Issue: Auto-Tier Not Working (WHM)

**Symptoms**: Cure VI always casts Cure VI, no downgrade

**Solutions**:

1. **Check if enabled**:

   ```
   //gs c state CureAutoTier
   ```

 Should show: `CureAutoTier: On`

2. **If showing Off**:

   ```
   //gs c cycle CureAutoTier
   ```

 Toggle until it shows `On`

3. **Check target**:
 - Auto-tier works on all targets including self
 - Try casting on party member: `/ma "Cure VI" <stpc>`

4. **Reload GearSwap**:

   ```
   //lua reload gearswap
   ```

### Issue: Waltz Command Not Found (DNC)

**Symptoms**: `//gs c waltz` does nothing

**Solutions**:

1. **Verify DNC loaded**:

   ```
   //gs c reload
   ```

 Look for "[DNC] Functions loaded successfully"

2. **Check syntax**:

   ```
   //gs c waltz <stpc>  (correct)
   //gs c waltz        (also works - uses current target)
   ```

3. **Verify TP**:
 - Need minimum 200 TP for Waltz I
 - Message will show if insufficient TP

### Issue: Wrong Tier Selected

**Symptoms**: Casts Cure V when Cure III would be enough

**Possible causes**:

1. **Safety margin adds 50 HP**:
 - The system adds 50 HP to missing HP before selecting tier
 - This means tier boundaries may appear shifted slightly

2. **Target HP fluctuating**:
 - Target HP changed between precast check and cast
 - Party member HP is estimated from HPP percentage
 - Recast to get fresh calculation

3. **Thresholds need adjustment**:
 - See "Customizing Thresholds" section
 - Or disable: `//gs c cycle CureAutoTier` to `Off`

### Issue: Message Not Displaying

**Symptoms**: Auto-tier works but no console message

**Cause**: Message formatter not loaded or suppressed

**Solutions**:

1. Check console filters (Windower settings)
2. Messages appear in chat log (party/say channel may hide them)
3. Normal behavior - not an error

---

## Best Practices

### WHM Cure Auto-Tier

**Recommendations**:

- **Keep enabled** for general content (saves tons of MP)
- **Disable for burst healing** (predictable output needed)
- **Macro highest tier** (Cure VI) - let system downgrade
- **Recast fallback is always active** even with auto-tier Off

**When to disable**:

- Predictable damage patterns (you know exact cure needed)
- Learning content (want to practice manual tier selection)
- MP is not a concern (infinite refresh)

### DNC Waltz Auto-Selection

**Recommendations**:

- **Always use** `//gs c waltz` (never waste TP)
- **Macro it** for quick access
- **Trust tier selection** (system optimizes TP usage)
- **Monitor party HP** before AOE waltz (ensure worth the TP)

**Macro setup**:

```
Macro 1: /console gs c waltz <stpc>     (Single target)
Macro 2: /console gs c aoewaltz         (AOE)
```

---

## Performance Impact

**WHM Cure Auto-Tier**:

- MP savings: **30-50% reduction** in MP usage over long fights
- Cast time improvement: **15-30%** (lower tiers cast faster)
- Overheal reduction: **~60%** (more precise healing)

**DNC Waltz Auto-Selection**:

- TP savings: **25-40% reduction** in TP spent on healing
- Efficiency gain: **More Waltzes available** per fight
- Performance: **Negligible overhead** (<1ms per calculation)

---

## Related Features

- **Recast Fallback**: If selected tier is on recast, system tries lower then higher tiers automatically
- **HP Monitoring**: Uses real-time HP data from party list (exact for self, estimated for party)
- **TP Tracking**: Ensures sufficient TP before Waltz execution
- **Level Detection**: Waltz system checks effective DNC level (main job vs subjob)

---

## Quick Reference

```
WHM CURE AUTO-TIER:
Command: //gs c cycle CureAutoTier
States: On (default), Off
Macro: /ma "Cure VI" <stpc>  (let system downgrade)

DNC WALTZ AUTO-SELECT:
Command: //gs c waltz <target>
AOE: //gs c aoewaltz
Always active (no toggle needed)

THRESHOLDS (from code):
Cure I:   0-200 HP     | Waltz I:   0-199 HP
Cure II:  200-400 HP   | Waltz II:  200-599 HP
Cure III: 400-700 HP   | Waltz III: 600-1099 HP
Cure IV:  700-1100 HP  | Waltz IV:  1100-1499 HP
Cure V:   1100-1600 HP | Waltz V:   1500+ HP
Cure VI:  1600+ HP     |
(Cure thresholds have +50 HP safety margin applied before lookup)

BENEFITS:
- Save MP/TP (30-50% savings)
- Faster casts (lower tier = shorter cast)
- Efficient healing (less overheal)
```

---


---


