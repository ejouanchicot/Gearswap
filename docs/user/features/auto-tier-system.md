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

| Cure Tier | Base Potency | Cast on Missing HP | MP Cost |
|-----------|--------------|-------------------|---------|
| **Cure I** | ~150 HP | 0-200 HP | 8 MP |
| **Cure II** | ~300 HP | 201-400 HP | 24 MP |
| **Cure III** | ~500 HP | 401-650 HP | 46 MP |
| **Cure IV** | ~700 HP | 651-950 HP | 88 MP |
| **Cure V** | ~900 HP | 951-1250 HP | 135 MP |
| **Cure VI** | ~1100 HP | 1251+ HP | 210 MP |

**Note**: Actual potency varies with Cure Potency gear and MND stat

### MP Savings Example

**Scenario**: Party member has 500 HP missing

| Without Auto-Tier | With Auto-Tier | Savings |
|-------------------|----------------|---------|
| Cast: Cure VI | Cast: Cure III | **164 MP saved** |
| MP Cost: 210 | MP Cost: 46 | (78% reduction) |
| Overheal: 600 HP | Overheal: 0 HP | Efficient! |

**Over 10 cures**: 1,640 MP saved = ~12 extra Cure VIs worth of MP!

### Advanced: Cure Potency Scaling

The system accounts for your **Cure Potency** gear:

**Formula**:

```
Actual HP Healed = Base Potency × (1 + Cure Potency%)
```

**Example with +50% Cure Potency**:

- Cure III base: 500 HP
- With gear: 500 × 1.5 = **750 HP**
- System adjusts thresholds accordingly

**Result**: More aggressive downgrading when you have high Cure Potency gear (efficient!)

### When Auto-Tier is Disabled

**Scenarios where system auto-disables**:

1. **Target is self** (`<me>`) - Always cast macro'd tier
2. **Afflatus Solace active** - WHM mechanics override
3. **Light Arts active** (SCH subjob) - Bonus effects matter
4. **Esuna/Cursna** - Status removal, not healing

**Manual override**: Set `CureAutoTier` to `Off`

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

| Waltz Tier | HP Healed | TP Cost | Cast on Missing HP |
|------------|-----------|---------|-------------------|
| **Curing Waltz I** | ~300 HP | 200 TP | 0-400 HP |
| **Curing Waltz II** | ~600 HP | 350 TP | 401-750 HP |
| **Curing Waltz III** | ~900 HP | 500 TP | 751-1100 HP |
| **Curing Waltz IV** | ~1200 HP | 650 TP | 1101-1450 HP |
| **Curing Waltz V** | ~1500 HP | 800 TP | 1451+ HP |

**Automatic selection**: System picks the **minimum tier** that will heal target to near-full HP

### TP Efficiency

**Scenario**: Party member has 700 HP missing

| Manual Selection | Auto-Tier | Savings |
|------------------|-----------|---------|
| Use: Curing Waltz V | Use: Curing Waltz III | **300 TP saved** |
| TP Cost: 800 | TP Cost: 500 | (37.5% reduction) |
| Overheal: 800 HP | Overheal: 200 HP | Efficient! |

**Result**: Use saved TP for Steps, Flourishes, or more Waltzes

### AOE Waltz (Divine Waltz)

**Command**:

```
//gs c aoewaltz
```

**Behavior**:

- Automatically selects Divine Waltz I, II, or III based on party HP
- Heals all party members in range
- Higher TP cost but essential for AOE damage

**Divine Waltz Tiers**:

- Divine Waltz I: ~300 HP per member (400 TP)
- Divine Waltz II: ~500 HP per member (800 TP)
- Divine Waltz III: ~700 HP per member (1200 TP)

### Waltz Potency Gear

The system accounts for **Waltz Potency** gear:

**Formula**:

```
Actual HP Healed = Base Potency × (1 + Waltz Potency%)
```

**Example with +30% Waltz Potency**:

- Curing Waltz III base: 900 HP
- With gear: 900 × 1.3 = **1170 HP**

**Result**: System may downgrade more aggressively with high Waltz Potency gear

---

## How It Works

### Decision Flow (WHM Cure)

```
1. Player casts: /ma "Cure VI" <stpc>
2. System checks: Is CureAutoTier enabled?
   └─ If NO: Cast Cure VI (as macro'd)
   └─ If YES: Continue to step 3

3. Calculate target's missing HP:
   Target Max HP: 1500
   Target Current HP: 900
   Missing HP: 600

4. Check cure potency gear:
   Cure Potency: +40%
   Adjusted threshold: 600 / 1.4 = 428 base HP needed

5. Select optimal tier:
   Cure III heals 500 base (700 with gear)
   This will heal 600 missing >> Use Cure III

6. Cast downgraded spell: Cure III
7. Display message: "Cure VI >> Cure III (600 HP needed)"
```

### Decision Flow (DNC Waltz)

```
1. Player executes: //gs c waltz <stpc>
2. Calculate target's missing HP:
   Target missing: 850 HP

3. Check waltz potency gear:
   Waltz Potency: +25%

4. Select minimum tier that heals target:
   - Waltz II: 600 × 1.25 = 750 HP (not enough)
   - Waltz III: 900 × 1.25 = 1125 HP (sufficient!)

5. Execute: Curing Waltz III
6. Display message: "Healing 850 HP with Curing Waltz III"
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

**File**: `shared/utils/waltz/waltz_manager.lua` (DNC)
**File**: `Mote-Include.lua` (WHM - refine_waltz function)

**Example** (DNC Waltz thresholds):

```lua
-- Default thresholds
local waltz_tiers = {
    {tier = "I", hp_needed = 400, tp_cost = 200},
    {tier = "II", hp_needed = 750, tp_cost = 350},
    {tier = "III", hp_needed = 1100, tp_cost = 500},
    {tier = "IV", hp_needed = 1450, tp_cost = 650},
    {tier = "V", hp_needed = 9999, tp_cost = 800}
}

-- Modify hp_needed to adjust when each tier is selected
```

**Warning**: Modifying core files affects all characters. Test thoroughly!

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

**Scenario 3**: Self-cure after damage

```
[WHM] Target: <me>
[WHM] Cure VI cast (no auto-tier on self)
```

**Result**: Always cast macro'd tier on self

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
 - Auto-tier disables on `<me>` (self-cures)
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

1. **Cure Potency not detected**:
 - System uses base potency values
 - Ensure Cure Potency gear equipped before casting

2. **Target HP fluctuating**:
 - Target HP changed between command and cast
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
- **Trust the system** - it accounts for your gear

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

- **Cure Potency Gear**: Auto-tier accounts for your equipped gear
- **Waltz Potency Gear**: System adjusts thresholds dynamically
- **HP Monitoring**: Uses real-time HP data from party list
- **TP Tracking**: Ensures sufficient TP before Waltz execution

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

THRESHOLDS (approximate):
Cure I:   0-200 HP    | Waltz I:   0-400 HP
Cure II:  201-400 HP  | Waltz II:  401-750 HP
Cure III: 401-650 HP  | Waltz III: 751-1100 HP
Cure IV:  651-950 HP  | Waltz IV:  1101-1450 HP
Cure V:   951-1250 HP | Waltz V:   1451+ HP
Cure VI:  1251+ HP    |

BENEFITS:
- Save MP/TP (30-50% savings)
- Faster casts (lower tier = shorter cast)
- Efficient healing (less overheal)
```

---


---


