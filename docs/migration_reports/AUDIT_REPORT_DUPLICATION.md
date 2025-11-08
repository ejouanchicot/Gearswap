# 📊 AUDIT REPORT - Spell Database Duplication Analysis

**Date:** 2025-10-30
**Scope:** Option A - Migration Minimale (Enfeebling/Enhancing only)
**Objective:** Éliminer duplication entre fichiers job-specific et skill databases

---

## 🎯 EXECUTIVE SUMMARY

**Total Duplicated Spells:** **169 spells** across 6 files
**Total Lines to Eliminate:** **~2,100 lines** de code dupliqué
**Files to Remove:** **6 obsolete files** (after migration)
**Zero Breaking Changes:** ✅ API externe identique

---

## 📋 DETAILED AUDIT RESULTS

### **1. RDM Enfeebling Duplication**

**File:** `internal/rdm/enfeebling.lua`
**Size:** 446 lines
**Total Spells:** 38 spells

| Category | Count | Status |
|----------|-------|--------|
| **Duplicated in ENFEEBLING_MAGIC_DATABASE** | 35 | ❌ Remove |
| **Unique to RDM** | 3 | ✅ Keep (Spike spells) |

**Duplicated Spells (35):**

```
Enfeebling (32):
- Dia, Dia II, Dia III, Diaga
- Bio, Bio II, Bio III
- Poison, Poison II, Poisonga
- Paralyze, Paralyze II
- Slow, Slow II
- Blind, Blind II
- Gravity, Gravity II
- Distract, Distract II, Distract III
- Frazzle, Frazzle II, Frazzle III
- Addle, Addle II
- Bind, Silence, Dispel
- Sleep, Sleep II, Sleepga, Sleepga II
- Break, Breakga
```

**Unique Spells (3) - NOT in skill database:**

```
Spike Spells (3):
- Blaze Spikes
- Ice Spikes
- Shock Spikes
```

**Action:** Move Spike spells to ENHANCING_MAGIC_DATABASE, delete rest

---

### **2. RDM Enhancing Duplication**

**File:** `internal/rdm/enhancing.lua`
**Size:** 776 lines
**Total Spells:** 79 spells

| Category | Count | Status |
|----------|-------|--------|
| **Duplicated in ENHANCING_MAGIC_DATABASE** | 72 | ❌ Remove |
| **Unique to RDM** | 7 | ✅ Keep (Healing spells) |

**Duplicated Spells (72):**

```
Defensive Buffs (10):
- Protect I-V
- Shell I-V

Party Buffs (10):
- Protectra I-V
- Shellra I-V

Recovery Buffs (5):
- Regen I-II
- Refresh I-III

Haste Buffs (4):
- Haste I-II
- Flurry I-II

Phalanx (2):
- Phalanx I-II

Bar Elemental (6):
- Barstone, Barwater, Baraero, Barfire, Barblizzard, Barthunder

Bar Status (8):
- Barsleep, Barpoison, Barparalyze, Barblind, Barsilence, Barvirus, Barpetrify, Baramnesia

Enspells (12):
- Enthunder, Enstone, Enaero, Enblizzard, Enfire, Enwater (I-II each)

Gain Spells (7):
- Gain-VIT, Gain-MND, Gain-CHR, Gain-AGI, Gain-STR, Gain-INT, Gain-DEX

Utility (8):
- Aquaveil, Sneak, Invisible, Blink, Stoneskin, Deodorize, Inundation, Temper I-II
```

**Unique Spells (7) - NOT in skill database:**

```
Healing Magic (7):
- Cure I, II, III, IV
- Raise I, II
- Inundation (unique Red Mage spell)
```

**Note:** Healing spells should eventually go in HEALING_MAGIC_DATABASE (Phase 3)

**Action:** Delete all but Cure/Raise/Inundation (move to internal/rdm/healing.lua later)

---

### **3. WHM Bar Duplication**

**File:** `internal/whm/bar.lua`
**Size:** 129 lines
**Total Spells:** 20 spells

| Category | Count | Status |
|----------|-------|--------|
| **Duplicated in enhancing/enhancing_bars.lua** | 20 | ❌ Remove |
| **Unique to WHM** | 0 | N/A |

**Duplicated Spells (20):**

```
Bar Elemental (6):
- Barstone, Barwater, Baraero, Barfire, Barblizzard, Barthunder

Bar Elemental AoE (6):
- Barstonra, Barwatera, Baraera, Barfira, Barblizzara, Barthundra

Bar Status AoE (8):
- Barsleepra, Barpoisonra, Barparalyzra, Barblindra, Barsilencera, Barvira, Barpetra, Baramnesra
```

**Action:** Delete entire file (100% duplication)

---

### **4. WHM Boost Duplication**

**File:** `internal/whm/boost.lua`
**Size:** ~100 lines (estimate)
**Total Spells:** 7 spells

| Category | Count | Status |
|----------|-------|--------|
| **Duplicated in enhancing/enhancing_utility.lua** | 7 | ❌ Remove |
| **Unique to WHM** | 0 | N/A |

**Duplicated Spells (7):**

```
Boost Spells (7):
- Boost-VIT
- Boost-MND
- Boost-CHR
- Boost-AGI
- Boost-STR
- Boost-INT
- Boost-DEX
```

**Action:** Delete entire file (100% duplication)

---

### **5. WHM Teleport Duplication**

**File:** `internal/whm/teleport.lua`
**Size:** ~150 lines (estimate)
**Total Spells:** 9 spells

| Category | Count | Status |
|----------|-------|--------|
| **Duplicated in enhancing/enhancing_utility.lua** | 9 | ❌ Remove |
| **Unique to WHM** | 0 | N/A |

**Duplicated Spells (9):**

```
Teleport Spells (6):
- Teleport-Altep
- Teleport-Dem
- Teleport-Holla
- Teleport-Mea
- Teleport-Vahzl
- Teleport-Yhoat

Recall Spells (3):
- Recall-Jugner
- Recall-Meriph
- Recall-Pashh
```

**Note:** Warp/Warp II are in skill database but not in WHM teleport.lua (WHM doesn't have Warp)

**Action:** Delete entire file (100% duplication)

---

### **6. WHM Support Partial Duplication**

**File:** `internal/whm/support.lua`
**Size:** ~600 lines (estimate)
**Total Spells:** 58 spells

| Category | Count | Status |
|----------|-------|--------|
| **Duplicated in enhancing/enhancing_buffs.lua** | 26 | ❌ Remove |
| **Unique to WHM** | 32 | ✅ Keep (Healing/Divine/Enfeebling) |

**Duplicated Spells (26):**

```
Defensive Buffs (10):
- Protect I-V
- Shell I-V

Party Buffs (10):
- Protectra I-V
- Shellra I-V

Recovery Buffs (4):
- Regen I-IV

Utility Buffs (2):
- Aquaveil
- Auspice
```

**Unique Spells (32) - NOT in enhancing database:**

```
Healing Magic (multiple):
- Cure I-VI, Curaga I-V, Cura I-III
- Raise I-III, Reraise I-IV, Arise
- Status removal: Poisona, Paralyna, Blindna, Silena, Stona, Viruna, Cursna, Erase, Esuna

Divine Magic (7):
- Banish I-III, Banishga I-II
- Holy I-II

Enfeebling Magic (7):
- Dia I-II, Diaga
- Paralyze, Slow, Silence, Addle

Utility (misc):
- Flash, Repose, Sacrifice
- Haste, Blink, Stoneskin, Sneak, Invisible, Deodorize
```

**Note:** Unique spells should eventually go in HEALING_MAGIC_DATABASE and DIVINE_MAGIC_DATABASE (Phase 3)

**Action:** Keep internal/whm/support.lua for now (contains Healing/Divine), remove only duplicated Enhancing spells

---

## 📈 STATISTICS SUMMARY

### **Files to Modify (2)**

| File | Action | Duplicated Spells | Lines Saved |
|------|--------|-------------------|-------------|
| `RDM_SPELL_DATABASE.lua` | Modify (require skill databases) | 107 | ~1,000 |
| `WHM_SPELL_DATABASE.lua` | Modify (require skill databases) | 62 | ~500 |

### **Files to Delete (3 complete, 3 partial)**

| File | Duplication % | Spells | Lines | Action |
|------|---------------|--------|-------|--------|
| `internal/rdm/enfeebling.lua` | 92% (35/38) | 38 | 446 | Migrate Spike spells >> Delete |
| `internal/rdm/enhancing.lua` | 91% (72/79) | 79 | 776 | Keep Healing >> Delete rest |
| `internal/whm/bar.lua` | 100% (20/20) | 20 | 129 | **DELETE ENTIRE FILE** |
| `internal/whm/boost.lua` | 100% (7/7) | 7 | ~100 | **DELETE ENTIRE FILE** |
| `internal/whm/teleport.lua` | 100% (9/9) | 9 | ~150 | **DELETE ENTIRE FILE** |
| `internal/whm/support.lua` | 45% (26/58) | 58 | ~600 | Partial deletion |

**Total Lines to Eliminate:** ~2,100 lines

### **Spell Migration Summary**

| Database | Duplicated Spells | Unique Spells | Action |
|----------|-------------------|---------------|--------|
| ENFEEBLING_MAGIC_DATABASE | 35 | 3 Spikes | Add Spikes to ENHANCING |
| ENHANCING_MAGIC_DATABASE | 134 | 0 | Already complete ✅ |
| **TOTAL** | **169** | **3** | Migrate 3 Spikes |

---

## 🔧 MIGRATION ACTIONS REQUIRED

### **Phase 2A: Migrate Spike Spells (15 min)**

**Action:** Add 3 Spike spells to `enhancing/enhancing_combat.lua`

**Spells to add:**

```lua
["Blaze Spikes"] = {
    description = "Fire damage retaliation",
    element = "Fire",
    category = "Enhancing",
    magic_type = "Black",
    tier = nil,
    type = nil,
    main_job_only = false,
    subjob_master_only = false,
    BLM = 10,
    RDM = 20,
    RUN = 45,
    SCH = 30,
},
["Ice Spikes"] = {
    description = "Ice damage retaliation + Paralyze",
    element = "Ice",
    category = "Enhancing",
    magic_type = "Black",
    tier = nil,
    type = nil,
    main_job_only = false,
    subjob_master_only = false,
    BLM = 20,
    RDM = 40,
    RUN = 65,
    SCH = 50,
},
["Shock Spikes"] = {
    description = "Thunder damage retaliation + Stun",
    element = "Thunder",
    category = "Enhancing",
    magic_type = "Black",
    tier = nil,
    type = nil,
    main_job_only = false,
    subjob_master_only = false,
    BLM = 30,
    RDM = 60,
    RUN = 85,
    SCH = 70,
},
```

**Update:** `ENHANCING_MAGIC_DATABASE.lua` spell count (136 >> 139)

---

### **Phase 2B: Modify RDM_SPELL_DATABASE.lua (30 min)**

**Before:**

```lua
local elemental = require('shared/data/magic/internal/rdm/elemental')
local enhancing = require('shared/data/magic/internal/rdm/enhancing')
local enfeebling = require('shared/data/magic/internal/rdm/enfeebling')
```

**After:**

```lua
local elemental = require('shared/data/magic/internal/rdm/elemental')

-- Load skill databases (universal)
local EnhancingDB = require('shared/data/magic/ENHANCING_MAGIC_DATABASE')
local EnfeeblngDB = require('shared/data/magic/ENFEEBLING_MAGIC_DATABASE')

-- Load RDM-specific healing spells
local healing = require('shared/data/magic/internal/rdm/healing')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

RDMSpells.spells = {}

-- Merge elemental spells (keep for now - until ELEMENTAL_MAGIC_DATABASE exists)
for spell_name, spell_data in pairs(elemental.spells) do
    RDMSpells.spells[spell_name] = spell_data
end

-- Merge RDM-accessible Enhancing spells from skill database
for spell_name, spell_data in pairs(EnhancingDB.spells) do
    if spell_data.RDM then  -- Only if RDM has access
        RDMSpells.spells[spell_name] = spell_data
    end
end

-- Merge RDM-accessible Enfeebling spells from skill database
for spell_name, spell_data in pairs(EnfeeblngDB.spells) do
    if spell_data.RDM then
        RDMSpells.spells[spell_name] = spell_data
    end
end

-- Merge RDM-specific healing spells (Cure I-IV, Raise I-II, Inundation)
for spell_name, spell_data in pairs(healing.spells) do
    RDMSpells.spells[spell_name] = spell_data
end
```

**New File:** Create `internal/rdm/healing.lua` with 7 spells (Cure I-IV, Raise I-II, Inundation)

---

### **Phase 2C: Modify WHM_SPELL_DATABASE.lua (30 min)**

**Before:**

```lua
local healing = require('shared/data/magic/internal/whm/healing')
local bar = require('shared/data/magic/internal/whm/bar')
local boost = require('shared/data/magic/internal/whm/boost')
local teleport = require('shared/data/magic/internal/whm/teleport')
local support = require('shared/data/magic/internal/whm/support')
```

**After:**

```lua
local healing = require('shared/data/magic/internal/whm/healing')  -- Keep (WHM-specific Cure potency)
local support = require('shared/data/magic/internal/whm/support')  -- Keep (Healing/Divine/unique spells)

-- Load skill databases (universal)
local EnhancingDB = require('shared/data/magic/ENHANCING_MAGIC_DATABASE')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

WHMSpells.spells = {}

-- Merge healing spells (Cure, Curaga, Cura, -na spells, etc.)
for spell_name, spell_data in pairs(healing.spells) do
    WHMSpells.spells[spell_name] = spell_data
end

-- Merge support spells (Divine, unique Enfeebling, utility)
for spell_name, spell_data in pairs(support.spells) do
    WHMSpells.spells[spell_name] = spell_data
end

-- Merge WHM-accessible Enhancing spells from skill database
for spell_name, spell_data in pairs(EnhancingDB.spells) do
    if spell_data.WHM then  -- Only if WHM has access
        WHMSpells.spells[spell_name] = spell_data
    end
end
```

**Files Deleted:**

- `internal/whm/bar.lua` ❌ (100% duplication)
- `internal/whm/boost.lua` ❌ (100% duplication)
- `internal/whm/teleport.lua` ❌ (100% duplication)

**Files Modified:**

- `internal/whm/support.lua` - Remove duplicated Enhancing spells (keep Healing/Divine only)

---

### **Phase 2D: Testing Checklist**

#### **RDM Testing:**

- [ ] Load RDM job in-game
- [ ] Verify spell list shows all spells (107 total expected)
- [ ] Test Enfeebling spell: Cast Paralyze >> Equipment swaps correctly
- [ ] Test Enfeebling spell: Cast Slow II >> Equipment swaps correctly
- [ ] Test Enhancing spell: Cast Refresh >> Equipment swaps correctly
- [ ] Test Enhancing spell: Cast Phalanx >> Equipment swaps correctly
- [ ] Test Bar spell: Cast Barfire >> Equipment swaps correctly
- [ ] Test Spike spell: Cast Ice Spikes >> Equipment swaps correctly
- [ ] Test Cure spell: Cast Cure III >> Equipment swaps correctly
- [ ] Test Gain spell: Cast Gain-STR >> Equipment swaps correctly

#### **WHM Testing:**

- [ ] Load WHM job in-game
- [ ] Verify spell list shows all spells (~100 total expected)
- [ ] Test Bar spell: Cast Barfire >> Equipment swaps correctly
- [ ] Test Boost spell: Cast Boost-STR >> Equipment swaps correctly
- [ ] Test Teleport spell: Cast Teleport-Holla >> Equipment swaps correctly
- [ ] Test Protect spell: Cast Protectra V >> Equipment swaps correctly
- [ ] Test Regen spell: Cast Regen IV >> Equipment swaps correctly
- [ ] Test Cure spell: Cast Curaga IV >> Equipment swaps correctly
- [ ] Test Divine spell: Cast Banish II >> Equipment swaps correctly

---

## ⚠️ RISKS & MITIGATION

### **Risk 1: Missing Spells After Migration**

**Symptom:** RDM/WHM missing some spells after migration

**Cause:** Job field missing in skill database (e.g., spell has `RUN = 10` but not `RDM = X`)

**Mitigation:**

1. Compare spell counts before/after migration
2. Test in-game spell list completeness
3. Rollback if critical spells missing

### **Risk 2: Equipment Not Swapping**

**Symptom:** Spell casts but equipment doesn't change

**Cause:** spell_message_handler.lua Priority 1 not finding spell in databases

**Mitigation:**

1. Verify spell exists in skill database with correct job field
2. Check console for error messages
3. Test with `//gs c debugmidcast` for verbose logging

### **Risk 3: Performance Degradation**

**Symptom:** Noticeable lag when casting spells

**Cause:** Multiple `require()` calls or nested loops

**Mitigation:**

1. Lua caches `require()` results automatically (no performance issue expected)
2. Benchmark spell cast times before/after migration
3. Monitor CPU usage during heavy spell casting

---

## 📊 EXPECTED RESULTS

### **Before Migration:**

```
Total Files: 50 files
Total Lines: ~15,000 lines
Duplication: 169 spells duplicated (11%)
Maintenance: Difficult (must update 2-3 places per spell)
```

### **After Migration:**

```
Total Files: 44 files (-6 files)
Total Lines: ~12,900 lines (-2,100 lines / -14%)
Duplication: 0 Enfeebling/Enhancing duplicates (0%)
Maintenance: Easy (update once in skill database)
```

### **Benefits:**

✅ **-14% code size** (-2,100 lines eliminated)
✅ **Zero duplication** for Enfeebling/Enhancing skills
✅ **Single source of truth** for spell metadata
✅ **Faster updates** (change once vs 2-3 places)
✅ **Zero breaking changes** (API externe identique)

---

## 🎯 NEXT STEPS

### **✅ Phase 1: Audit (COMPLETE - 1h)**

- [x] Compare RDM enfeebling vs ENFEEBLING_MAGIC_DATABASE
- [x] Compare RDM enhancing vs ENHANCING_MAGIC_DATABASE
- [x] Compare WHM bar vs enhancing_bars
- [x] Compare WHM boost vs enhancing_utility
- [x] Compare WHM teleport vs enhancing_utility
- [x] Compare WHM support vs enhancing_buffs
- [x] Create audit report with statistics

### **⏳ Phase 2: Migration (2-3h)**

- [ ] 2A: Migrate Spike spells to ENHANCING_MAGIC_DATABASE (15 min)
- [ ] 2B: Modify RDM_SPELL_DATABASE.lua (30 min)
- [ ] 2C: Modify WHM_SPELL_DATABASE.lua (30 min)
- [ ] 2D: Test in-game RDM spell loading and casting (30 min)
- [ ] 2E: Test in-game WHM spell loading and casting (30 min)
- [ ] 2F: Backup obsolete files (5 min)
- [ ] 2G: Delete obsolete files after confirmation (5 min)

### **⏸️ Phase 3: Future Enhancements (Optional - 4-6h)**

- [ ] Create HEALING_MAGIC_DATABASE (Cure, Raise, -na spells)
- [ ] Create DIVINE_MAGIC_DATABASE (Banish, Holy)
- [ ] Create ELEMENTAL_MAGIC_DATABASE (Fire I-VI, -ga, -ja)
- [ ] Eliminate ALL remaining duplication

---

**END OF AUDIT REPORT**
