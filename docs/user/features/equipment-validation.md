# Equipment Validation System

**Feature**: Equipment Set Validation
**Command**: `//gs c checksets`
**Status**: ✅ Production Ready
**Version**: 1.0
**Last Updated**: 2025-10-26

---

## 📋 Table of Contents

1. [What is Equipment Validation?](#what-is-equipment-validation)
2. [How to Use](#how-to-use)
3. [Understanding the Output](#understanding-the-output)
4. [Common Scenarios](#common-scenarios)
5. [Troubleshooting](#troubleshooting)
6. [Examples by Job](#examples-by-job)

---

## 🎯 What is Equipment Validation?

The Equipment Validation system checks **all your configured gear sets** and verifies which items you:

- ✅ **Own** (in inventory)
- 🗄️ **Have in storage** (mog house, sacks, wardrobes, etc.)
- ❌ **Don't own yet** (missing items)

**Purpose**:

- Identify missing equipment before you go into battle
- Find items stuck in storage that should be in inventory
- Track your upgrade path (see what you don't have yet)
- Validate after making set changes

---

## 🚀 How to Use

### Basic Usage

**Command**:

```
//gs c checksets
```

**When to use**:

- After installing a new job
- After modifying your gear sets
- When troubleshooting gear swap issues
- Before important content (to ensure you have all gear)

**What it does**:

1. Scans ALL your equipment sets (precast, midcast, idle, engaged)
2. Checks inventory for each item
3. Checks storage locations for items not in inventory
4. Reports results by category

---

## 📊 Understanding the Output

### Output Format

```
[JOB] Validating equipment sets...
[JOB] ✅ 156/160 items validated (97.5%)

--- STORAGE ITEMS (3) ---
[STORAGE] sets.precast.WS['Upheaval'].neck: "Fotia Gorget"
[STORAGE] sets.idle.PDT.body: "Sakpata's Plate"
[STORAGE] sets.midcast['Healing Magic'].hands: "Macabre Gauntlets +1"

--- MISSING ITEMS (1) ---
[MISSING] sets.precast.WS['Savage Blade'].ring1: "Epaminondas's Ring"

[JOB] Validation complete!
```

---

### Status Indicators

| Status | Symbol | Meaning | Action Needed |
|--------|--------|---------|---------------|
| **VALID** | ✅ | Item in inventory | None - ready to use |
| **STORAGE** | 🗄️ | Item in storage | Move to inventory if needed |
| **MISSING** | ❌ | Item not found anywhere | Acquire the item or update sets |

---

### Item Count Summary

```
✅ 156/160 items validated (97.5%)
```

**Breakdown**:

- **156**: Items found (inventory + storage)
- **160**: Total unique items in all sets
- **97.5%**: Percentage of items you own

**Note**: This counts **unique items** only. If "Sakpata's Helm" appears in 5 different sets, it's counted as 1 item.

---

## 🔍 Common Scenarios

### Scenario 1: All Items Valid ✅

```
[WAR] Validating equipment sets...
[WAR] ✅ 120/120 items validated (100%)
[WAR] Validation complete!
```

**Meaning**: All items are in inventory, ready to swap
**Action**: None needed - perfect setup!

---

### Scenario 2: Items in Storage 🗄️

```
[RDM] ✅ 145/150 items validated (96.7%)

--- STORAGE ITEMS (5) ---
[STORAGE] sets.midcast['Enhancing Magic'].Duration.head: "Telchine Cap"
[STORAGE] sets.midcast['Enhancing Magic'].Duration.body: "Telchine Chasuble"
[STORAGE] sets.idle.Normal.body: "Jhakri Robe +2"
```

**Meaning**: Items exist but are in mog house/sack/wardrobe
**Action**:

- Move items to inventory if you need them
- OR leave in storage if you don't use those sets often

**Why it happens**:

- You stored idle gear while doing content
- You have multiple job setups sharing storage
- You configured sets for gear you haven't moved yet

---

### Scenario 3: Missing Items ❌

```
[BLM] ✅ 128/135 items validated (94.8%)

--- MISSING ITEMS (7) ---
[MISSING] sets.precast.WS['Myrkr'].head: "Pixie Hairpin +1"
[MISSING] sets.midcast['Elemental Magic'].ears: "Malignance Earring"
[MISSING] sets.engaged.Normal.ring1: "Chirich Ring +1"
```

**Meaning**: Items not found in inventory or storage
**Action**:

1. **If you don't own**: This is your upgrade path - acquire these items
2. **If you DO own**: Check spelling in your sets file
3. **If not needed**: Remove from sets or use a substitute

**Common causes**:

- Upgrade items you haven't obtained yet
- Typo in item name
- Item name changed after update
- Placeholder from template you haven't customized

---

### Scenario 4: After Modifying Sets

**You changed**:

```lua
-- OLD
sets.midcast.Cure = {
    head = "Sakpata's Helm"
}

-- NEW
sets.midcast.Cure = {
    head = "Nyame Helm"  -- Changed to Nyame
}
```

**Validation**:

```
//lua reload gearswap
//gs c checksets

[WAR] ✅ 119/120 items validated (99.2%)

--- MISSING ITEMS (1) ---
[MISSING] sets.midcast.Cure.head: "Nyame Helm"
```

**Action**: Go acquire "Nyame Helm" or revert to "Sakpata's Helm"

---

## 🔧 Troubleshooting

### Issue: Item Shows MISSING but I Have It

**Possible causes**:

1. **Spelling mismatch**:

   ```lua
   -- In sets (WRONG spelling)
   head = "Sakpata Helm"  -- Missing apostrophe

   -- Correct
   head = "Sakpata's Helm"  -- Note the 's
   ```

2. **Item in temporary storage** (Porter Moogle, Delivery Box):
   - Validation only checks mog house, sacks, wardrobes
   - Move item to one of these locations

3. **Item name changed** (after game update):
   - Check current item name in-game
   - Update your sets file

**Solution**: Compare item name in sets vs. in-game inventory (case-sensitive, exact match required)

---

### Issue: Too Many STORAGE Items

**Situation**: You have 20+ items in storage, making swaps slow

**Solution**:

1. Identify which sets you use most:

   ```lua
   -- If you never use Duration mode:
   sets.midcast['Enhancing Magic'].Duration = {...}  -- Items can stay in storage

   -- If you use this constantly:
   sets.idle.Normal = {...}  -- Move items to inventory
   ```

2. Move frequently-used items to inventory
3. Keep situational gear in storage

**Priority**:

- **Inventory**: Idle, Engaged, main Midcast sets
- **Storage OK**: Alternate modes, WS sets for weapons you don't use

---

### Issue: Validation Shows 0% After Job Change

**Situation**:

```
[BLM] ✅ 0/135 items validated (0%)
```

**Cause**: Job just changed, sets haven't loaded yet

**Solution**:

```
//lua reload gearswap
//gs c checksets
```

Wait 2-3 seconds between commands for full initialization

---

### Issue: Circular Reference Detected

**Output**:

```
[ERROR] Circular reference detected in sets.midcast.Cure
```

**Cause**: A set references itself

```lua
-- WRONG
sets.midcast.Cure = sets.midcast.Cure  -- Circular!

-- Or nested
sets.midcast.Cure.SIRD = sets.midcast.Cure  -- References parent
```

**Solution**: Fix the circular reference

```lua
-- CORRECT
sets.midcast.Cure = {
    head = "...",
    -- ... actual gear
}

sets.midcast.Cure.SIRD = set_combine(sets.midcast.Cure, {
    body = "Different piece"
})
```

---

## 📚 Examples by Job

### WAR (Warrior) Example

```
[WAR] Validating equipment sets...
[WAR] ✅ 98/102 items validated (96.1%)

--- STORAGE ITEMS (2) ---
[STORAGE] sets.engaged.PDT.body: "Sakpata's Plate"
[STORAGE] sets.idle.PDT.legs: "Sakpata's Cuisses"

--- MISSING ITEMS (2) ---
[MISSING] sets.precast.WS['Upheaval'].neck: "Fotia Gorget"
[MISSING] sets.precast.WS['Ukko's Fury'].ring1: "Niqmaddu Ring"

[WAR] Validation complete!
```

**Interpretation**:

- ✅ 98 items ready (normal mode gear all in inventory)
- 🗄️ 2 PDT items in storage (move to inventory if tanking)
- ❌ 2 WS items missing (upgrade path - acquire these for min-max)

---

### WHM (White Mage) Example

```
[WHM] Validating equipment sets...
[WHM] ✅ 143/150 items validated (95.3%)

--- STORAGE ITEMS (4) ---
[STORAGE] sets.midcast.Cure.SIRD.hands: "Macabre Gauntlets +1"
[STORAGE] sets.midcast['Enhancing Magic'].Duration.head: "Telchine Cap"
[STORAGE] sets.midcast['Enhancing Magic'].Duration.body: "Telchine Chasuble"
[STORAGE] sets.midcast['Enhancing Magic'].Duration.legs: "Telchine Braconi"

--- MISSING ITEMS (3) ---
[MISSING] sets.midcast.Cure.body: "Kaykaus Bliaut +1"
[MISSING] sets.midcast['Enhancing Magic'].feet: "Theo. Pantaloons +3"
[MISSING] sets.precast.WS['Mystic Boon'].ring1: "Metamorph Ring +1"

[WHM] Validation complete!
```

**Interpretation**:

- ✅ Most cure gear ready
- 🗄️ SIRD + Duration gear in storage (retrieve if needed for specific content)
- ❌ 3 upgrade items missing (min-max gear)

---

### BLM (Black Mage) Example

```
[BLM] Validating equipment sets...
[BLM] ✅ 156/160 items validated (97.5%)

--- MISSING ITEMS (4) ---
[MISSING] sets.midcast['Elemental Magic'].ears: "Malignance Earring"
[MISSING] sets.precast.WS['Myrkr'].head: "Pixie Hairpin +1"
[MISSING] sets.engaged.Normal.ring1: "Chirich Ring +1"
[MISSING] sets.engaged.Normal.ring2: "Chirich Ring +1"

[BLM] Validation complete!
```

**Interpretation**:

- ✅ All nuke/MB gear ready
- ❌ 4 items missing (2 melee rings, 1 earring, 1 MP WS piece)
- **Note**: BLM rarely melees, so engaged set MISSING items are low priority

---

## 💡 Best Practices

### 1. Validate After Every Set Change

**Workflow**:

```lua
-- 1. Edit shared/jobs/[job]/sets/[job]_sets.lua
-- 2. Save file
-- 3. In-game:
//lua reload gearswap
//gs c checksets
```

**Catches**: Typos, missing items, incorrect item names immediately

---

### 2. Prioritize Inventory by Usage

**High priority** (keep in inventory):

- Idle sets (constantly swapping)
- Engaged sets (combat gear)
- Main midcast sets (your primary casting gear)
- Fast Cast sets (every spell)

**Low priority** (OK in storage):

- Alternate modes you rarely use
- WS sets for weapons you don't currently use
- Situational sets (specific boss mechanics)

---

### 3. Use MISSING as Upgrade Tracker

**Create a checklist**:

```
//gs c checksets > equipment_todo.txt

--- MISSING ITEMS ---
[ ] Fotia Gorget - Farm: Dynamis-Beaucedine
[ ] Niqmaddu Ring - Buy: 30M gil
[ ] Epaminondas's Ring - Farm: Omen
```

Track your progress as you acquire items

---

### 4. Check Before Important Content

**Before entering**:

- Dynamis
- Odyssey
- Omen
- High-tier battlefields

**Run**:

```
//gs c checksets
```

Ensure no critical gear is in storage

---

## 🔗 Related Features

- **Auto-Equip**: System only swaps items marked as VALID (in inventory)
- **Watchdog**: Detects when swaps fail (often due to STORAGE/MISSING items)
- **Lockstyle**: Visual appearance not affected by STORAGE/MISSING items

---

## 📝 Quick Reference

```
COMMAND:
//gs c checksets

OUTPUT SYMBOLS:
✅ VALID    = Item in inventory (ready to use)
🗄️ STORAGE  = Item in storage (retrieve if needed)
❌ MISSING  = Item not found (acquire or fix sets)

TYPICAL VALIDATION:
95%+ = Excellent (minor upgrades missing)
85-95% = Good (some storage + upgrades)
<85% = Review sets (many missing items)

PRIORITY:
1. Move STORAGE items to inventory (if frequently used)
2. Fix typos (items you own showing as MISSING)
3. Plan upgrades (items you don't own)
```

---

**Version**: 1.0
**Author**: Tetsouo GearSwap Project
**Last Updated**: 2025-10-26
**Status**: ✅ Production Ready

---

**Validate your gear, adventure with confidence!** ✨
