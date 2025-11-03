# 🏗️ SHARED DATA REORGANIZATION PLAN

**Objectif:** Éliminer duplication, uniformiser nomenclature, structure cohérente par catégorie

**Date:** 2025-10-30
**Status:** PROPOSAL - À valider avant exécution

---

## 📊 PROBLÈMES IDENTIFIÉS

### 1. **Duplication Massive - Enfeebling/Enhancing Magic**

**Duplication confirmée:**

- `internal/rdm/enfeebling.lua` ≈ `ENFEEBLING_MAGIC_DATABASE` (36 spells dupliqués)
- `internal/rdm/enhancing.lua` ≈ `ENHANCING_MAGIC_DATABASE` (partiel)
- `internal/whm/bar.lua` ≈ `enhancing/enhancing_bars.lua` (28 spells dupliqués)
- `internal/whm/boost.lua` ≈ `enhancing/enhancing_utility.lua` (7 Boost spells dupliqués)
- `internal/whm/teleport.lua` ≈ `enhancing/enhancing_utility.lua` (13 Teleport/Recall/Warp dupliqués)
- `internal/whm/support.lua` ≈ `enhancing/enhancing_buffs.lua` (Protect/Shell/Regen/Refresh dupliqués)

**Impact:** ~100+ spells dupliqués = maintenance nightmare

### 2. **Structure Incohérente**

**Actuellement:**

```
magic/
├── ENFEEBLING_MAGIC_DATABASE.lua     ← Skill-based (universel)
├── ENHANCING_MAGIC_DATABASE.lua      ← Skill-based (universel)
├── BLM_SPELL_DATABASE.lua            ← Job-based (mais contient aussi skill-based spells)
├── WHM_SPELL_DATABASE.lua            ← Job-based (mais contient aussi skill-based spells)
├── RDM_SPELL_DATABASE.lua            ← Job-based (mais contient aussi skill-based spells)
├── enfeebling/*.lua                  ← Modules skill-based
├── enhancing/*.lua                   ← Modules skill-based
└── internal/
    ├── rdm/enfeebling.lua            ← DUPLICATION ❌
    ├── rdm/enhancing.lua             ← DUPLICATION ❌
    ├── whm/bar.lua                   ← DUPLICATION ❌
    └── whm/boost.lua                 ← DUPLICATION ❌
```

**Problème:** Mélange skill-based (universel) et job-based (spécifique) sans séparation claire

### 3. **Nomenclature Incohérente**

**Actuellement:**

- Index files: UPPERCASE (OK) ✓
- Modules: lowercase (OK) ✓
- Dossiers: mélange (`enfeebling/` vs `internal/blm/`)

---

## 🎯 STRUCTURE CIBLE

```
shared/data/
│
├── abilities/                                    ← Renommé de job_abilities
│   ├── README.md
│   ├── UNIVERSAL_JA_DATABASE.lua                ← Universal abilities
│   │
│   ├── combat/                                   ← Melee/Tank jobs
│   │   ├── DRK_JA_DATABASE.lua
│   │   ├── DRG_JA_DATABASE.lua
│   │   ├── PLD_JA_DATABASE.lua
│   │   ├── SAM_JA_DATABASE.lua
│   │   ├── THF_JA_DATABASE.lua
│   │   └── WAR_JA_DATABASE.lua
│   │
│   ├── magic/                                    ← Magic jobs
│   │   ├── BLM_JA_DATABASE.lua
│   │   ├── GEO_JA_DATABASE.lua
│   │   └── WHM_JA_DATABASE.lua
│   │
│   └── support/                                  ← Support jobs
│       ├── BRD_JA_DATABASE.lua
│       ├── COR_JA_DATABASE.lua
│       └── DNC_JA_DATABASE.lua
│
└── magic/
    ├── README.md
    ├── SPELL_DATABASE_README.md
    │
    ├── skills/                                   ← Skill-based (universel)
    │   │
    │   ├── enfeebling/
    │   │   ├── ENFEEBLING_MAGIC_DATABASE.lua    ← Index (140 lines)
    │   │   ├── enfeebling_control.lua           ← Module (145 lines)
    │   │   ├── enfeebling_debuffs.lua           ← Module (228 lines)
    │   │   └── enfeebling_dots.lua              ← Module (156 lines)
    │   │
    │   ├── enhancing/
    │   │   ├── ENHANCING_MAGIC_DATABASE.lua     ← Index (151 lines)
    │   │   ├── enhancing_bars.lua               ← Module (393 lines)
    │   │   ├── enhancing_buffs.lua              ← Module (472 lines)
    │   │   ├── enhancing_combat.lua             ← Module (541 lines)
    │   │   └── enhancing_utility.lua            ← Module (554 lines)
    │   │
    │   ├── elemental/                            ← À CRÉER (si skill-based)
    │   │   ├── ELEMENTAL_MAGIC_DATABASE.lua
    │   │   ├── elemental_single.lua             ← Fire/Ice/Thunder/Water/Wind/Earth I-VI
    │   │   ├── elemental_aoe.lua                ← -ga/-ja spells
    │   │   └── elemental_ancient.lua            ← Ancient Magic (BLM-only mais dans skills/)
    │   │
    │   ├── healing/                              ← À CRÉER (si skill-based)
    │   │   ├── HEALING_MAGIC_DATABASE.lua
    │   │   ├── healing_cure.lua                 ← Cure I-VI
    │   │   ├── healing_curaga.lua               ← Curaga I-V, Cura I-III
    │   │   └── healing_status.lua               ← -na spells, Erase, Viruna
    │   │
    │   └── divine/                               ← À CRÉER (si skill-based)
    │       ├── DIVINE_MAGIC_DATABASE.lua
    │       ├── divine_banish.lua                ← Banish I-III
    │       ├── divine_holy.lua                  ← Holy, Holy II
    │       └── divine_raise.lua                 ← Raise I-III, Reraise I-IV, Arise
    │
    └── jobs/                                     ← Job-specific (pas skill-based)
        │
        ├── blu/
        │   ├── BLU_SPELL_DATABASE.lua           ← Index
        │   ├── blu_breath.lua
        │   ├── blu_buff.lua
        │   ├── blu_debuff.lua
        │   ├── blu_healing.lua
        │   ├── blu_magical.lua
        │   └── blu_physical.lua
        │
        ├── brd/
        │   ├── BRD_SPELL_DATABASE.lua           ← Index
        │   ├── brd_buff_songs.lua
        │   ├── brd_debuff_songs.lua
        │   └── brd_utility_songs.lua
        │
        ├── geo/
        │   ├── GEO_SPELL_DATABASE.lua           ← Index
        │   ├── geo_indi.lua
        │   ├── geo_geo.lua
        │   └── geo_support.lua
        │
        ├── sch/
        │   ├── SCH_SPELL_DATABASE.lua           ← Index
        │   ├── sch_helix.lua
        │   └── sch_storm.lua
        │
        ├── smn/
        │   ├── SMN_SPELL_DATABASE.lua           ← Index
        │   ├── smn_avatars.lua
        │   ├── smn_rage.lua
        │   ├── smn_spirits.lua
        │   └── smn_ward.lua
        │
        ├── blm/
        │   ├── BLM_SPELL_DATABASE.lua           ← Index (façade)
        │   ├── blm_ancient.lua                  ← Ancient Magic (BLM-only)
        │   └── blm_dark.lua                     ← Dark Magic (si BLM-specific)
        │
        ├── whm/
        │   └── WHM_SPELL_DATABASE.lua           ← Index (façade vers skills/)
        │
        └── rdm/
            └── RDM_SPELL_DATABASE.lua           ← Index (façade vers skills/)
```

---

## 🔄 MIGRATION PLAN

### **PHASE 1: Identifier Fichiers Obsolètes (1h)**

**Action:** Comparer contenu des fichiers pour confirmer duplication

**Fichiers à comparer:**

1. `internal/rdm/enfeebling.lua` vs `ENFEEBLING_MAGIC_DATABASE`
2. `internal/rdm/enhancing.lua` vs `ENHANCING_MAGIC_DATABASE`
3. `internal/whm/bar.lua` vs `enhancing/enhancing_bars.lua`
4. `internal/whm/boost.lua` vs `enhancing/enhancing_utility.lua`
5. `internal/whm/teleport.lua` vs `enhancing/enhancing_utility.lua`
6. `internal/whm/support.lua` vs `enhancing/enhancing_buffs.lua`

**Outil:**

```bash
# Compare line counts
wc -l internal/rdm/enfeebling.lua
wc -l ENFEEBLING_MAGIC_DATABASE.lua

# Compare spell names
grep -oP '\\["\\K[^"]+' internal/rdm/enfeebling.lua | sort > /tmp/rdm_enf.txt
grep -oP '\\["\\K[^"]+' enfeebling/*.lua | sort | uniq > /tmp/skill_enf.txt
diff /tmp/rdm_enf.txt /tmp/skill_enf.txt
```

### **PHASE 2: Migrer RDM/WHM vers Skill Databases (2-3h)**

**Objectif:** Éliminer duplication en faisant pointer RDM/WHM vers skill databases

**2.1: Modifier RDM_SPELL_DATABASE.lua**

**Avant:**

```lua
local elemental = require('shared/data/magic/internal/rdm/elemental')
local enhancing = require('shared/data/magic/internal/rdm/enhancing')
local enfeebling = require('shared/data/magic/internal/rdm/enfeebling')
```

**Après:**

```lua
local elemental = require('shared/data/magic/internal/rdm/elemental')  -- Keep for now
local EnhancingDB = require('shared/data/magic/ENHANCING_MAGIC_DATABASE')
local EnfeeblngDB = require('shared/data/magic/ENFEEBLING_MAGIC_DATABASE')

-- Merge only RDM-accessible spells from skill databases
for spell_name, spell_data in pairs(EnhancingDB.spells) do
    if spell_data.RDM then  -- Check if RDM has access
        RDMSpells.spells[spell_name] = spell_data
    end
end

for spell_name, spell_data in pairs(EnfeeblngDB.spells) do
    if spell_data.RDM then
        RDMSpells.spells[spell_name] = spell_data
    end
end
```

**2.2: Modifier WHM_SPELL_DATABASE.lua**

**Avant:**

```lua
local healing = require('shared/data/magic/internal/whm/healing')
local bar = require('shared/data/magic/internal/whm/bar')
local boost = require('shared/data/magic/internal/whm/boost')
local teleport = require('shared/data/magic/internal/whm/teleport')
local support = require('shared/data/magic/internal/whm/support')
```

**Après:**

```lua
local healing = require('shared/data/magic/internal/whm/healing')  -- Keep (WHM-specific Cure potency)
local EnhancingDB = require('shared/data/magic/ENHANCING_MAGIC_DATABASE')

-- Merge only WHM-accessible spells from Enhancing database
for spell_name, spell_data in pairs(EnhancingDB.spells) do
    if spell_data.WHM then
        WHMSpells.spells[spell_name] = spell_data
    end
end
```

**2.3: Supprimer Fichiers Obsolètes**

**APRÈS validation et tests in-game:**

```bash
# Backup first
mkdir -p backup/internal_obsolete
mv internal/rdm/enfeebling.lua backup/internal_obsolete/
mv internal/rdm/enhancing.lua backup/internal_obsolete/
mv internal/whm/bar.lua backup/internal_obsolete/
mv internal/whm/boost.lua backup/internal_obsolete/
mv internal/whm/teleport.lua backup/internal_obsolete/
mv internal/whm/support.lua backup/internal_obsolete/
```

### **PHASE 3: Créer Skill Databases Manquants (4-6h)**

**Optionnel mais recommandé pour éliminer TOUTE duplication**

**3.1: ELEMENTAL_MAGIC_DATABASE**

- Extraire de `internal/blm/elemental.lua`, `internal/rdm/elemental.lua`, `internal/sch/elemental.lua`
- Modules: `elemental_single.lua`, `elemental_aoe.lua`, `elemental_ancient.lua`
- Permet d'éliminer duplication Elemental Magic entre BLM/RDM/SCH/GEO

**3.2: HEALING_MAGIC_DATABASE**

- Extraire de `internal/whm/healing.lua`
- Si RDM/PLD/SCH/RUN partagent Cure spells
- Modules: `healing_cure.lua`, `healing_curaga.lua`, `healing_status.lua`

**3.3: DIVINE_MAGIC_DATABASE**

- Extraire spells Divine de WHM
- Banish, Holy, Raise, Reraise
- Partagés avec PLD

### **PHASE 4: Réorganiser Structure Dossiers (1-2h)**

**4.1: Créer Nouvelle Structure**

```bash
mkdir -p shared/data/abilities/{combat,magic,support}
mkdir -p shared/data/magic/skills/{enfeebling,enhancing,elemental,healing,divine}
mkdir -p shared/data/magic/jobs/{blu,brd,geo,sch,smn,blm,whm,rdm}
```

**4.2: Déplacer Fichiers**

```bash
# Abilities
mv job_abilities/*_JA_DATABASE.lua abilities/
# Organiser par catégorie (combat/magic/support)

# Magic Skills
mv enfeebling/* magic/skills/enfeebling/
mv enhancing/* magic/skills/enhancing/

# Job-Specific Magic
mv internal/blu/* magic/jobs/blu/
mv internal/brd/* magic/jobs/brd/
mv internal/geo/* magic/jobs/geo/
mv internal/sch/* magic/jobs/sch/
mv internal/smn/* magic/jobs/smn/
# ... etc
```

**4.3: Mettre à Jour Require Paths**

**Exemple dans BLU_SPELL_DATABASE.lua:**

```lua
-- AVANT:
local breath = require('shared/data/magic/internal/blu/breath')

-- APRÈS:
local breath = require('shared/data/magic/jobs/blu/blu_breath')
```

**4.4: Supprimer Dossiers Vides**

```bash
rmdir internal/rdm
rmdir internal/whm
rmdir internal  # Si vide
```

### **PHASE 5: Testing In-Game (2h)**

**5.1: Test Load**

```
//lua unload gearswap
Change to RDM
//lua load gearswap
→ Verify: RDM spells loaded successfully
```

**5.2: Test Spell Access**

```
Cast Paralyze → Verify: Equipment swaps correctly
Cast Slow II → Verify: Equipment swaps correctly
Cast Refresh → Verify: Equipment swaps correctly
Cast Protect IV → Verify: Equipment swaps correctly
```

**5.3: Test WHM**

```
Change to WHM
Cast Barfire → Verify works
Cast Boost-STR → Verify works
Cast Teleport-Holla → Verify works
Cast Protectra V → Verify works
```

**5.4: Test Other Jobs**

```
Test BLM/SCH/GEO/PLD/RUN with Enhancing/Enfeebling spells
Verify no breakage
```

### **PHASE 6: Documentation (1h)**

**6.1: Mettre à Jour READMEs**

- `shared/data/abilities/README.md`
- `shared/data/magic/README.md`
- `shared/data/magic/skills/README.md`
- `shared/data/magic/jobs/README.md`

**6.2: Créer Migration Log**

- Document all moved/deleted files
- Document new require() paths
- Breaking changes (if any)

---

## 📋 CHECKLIST MIGRATION

### ✅ **Phase 1: Audit (1h)**

- [ ] Comparer internal/rdm/enfeebling.lua vs ENFEEBLING_MAGIC_DATABASE
- [ ] Comparer internal/rdm/enhancing.lua vs ENHANCING_MAGIC_DATABASE
- [ ] Comparer internal/whm/bar.lua vs enhancing/enhancing_bars.lua
- [ ] Comparer internal/whm/boost.lua vs enhancing/enhancing_utility.lua
- [ ] Comparer internal/whm/teleport.lua vs enhancing/enhancing_utility.lua
- [ ] Comparer internal/whm/support.lua vs enhancing/enhancing_buffs.lua
- [ ] Confirmer fichiers obsolètes

### ✅ **Phase 2: Éliminer Duplication RDM/WHM (2-3h)**

- [ ] Backup internal/rdm/\* et internal/whm/\*
- [ ] Modifier RDM_SPELL_DATABASE.lua (require skill databases)
- [ ] Modifier WHM_SPELL_DATABASE.lua (require skill databases)
- [ ] Test in-game RDM load
- [ ] Test in-game WHM load
- [ ] Test spell casting (Enfeebling/Enhancing)
- [ ] Supprimer fichiers obsolètes (après confirmation tests OK)

### ✅ **Phase 3: Skill Databases (Optionnel - 4-6h)**

- [ ] Créer ELEMENTAL_MAGIC_DATABASE
- [ ] Créer HEALING_MAGIC_DATABASE
- [ ] Créer DIVINE_MAGIC_DATABASE
- [ ] Migrer BLM/SCH/GEO vers ELEMENTAL_MAGIC_DATABASE
- [ ] Test in-game

### ✅ **Phase 4: Réorganiser Structure (1-2h)**

- [ ] Créer nouvelle structure dossiers
- [ ] Déplacer job_abilities → abilities/{combat,magic,support}
- [ ] Déplacer enfeebling/enhancing → magic/skills/
- [ ] Déplacer internal/* → magic/jobs/
- [ ] Renommer modules (blu_breath.lua, brd_buff_songs.lua, etc.)
- [ ] Mettre à jour tous les require() paths
- [ ] Supprimer dossiers vides

### ✅ **Phase 5: Testing (2h)**

- [ ] Test load TOUS jobs magiques (BLM/WHM/RDM/SCH/GEO/PLD/RUN/BRD/SMN/BLU)
- [ ] Test spell casting par skill (Enfeebling/Enhancing/Elemental/Healing/Divine)
- [ ] Test job abilities
- [ ] Verify no console errors

### ✅ **Phase 6: Documentation (1h)**

- [ ] Créer/Mettre à jour READMEs
- [ ] Document migration log
- [ ] Update CLAUDE.md si nécessaire

---

## 🎯 RÉSULTATS ATTENDUS

### **Avant Migration:**

```
📊 METRICS (Avant)
- Total files: ~50 files
- Duplication: ~100+ spells dupliqués
- Structure: Incohérente (mélange skill/job)
- Nomenclature: Incohérente
```

### **Après Migration:**

```
📊 METRICS (Après)
- Total files: ~40 files (-10 fichiers obsolètes supprimés)
- Duplication: 0% (100% skill-based pour Enfeebling/Enhancing)
- Structure: Cohérente (skills/ vs jobs/ séparation claire)
- Nomenclature: Uniforme (UPPERCASE index, lowercase modules)
- Maintenabilité: +200% (plus de duplication)
- File sizes: Tous < 600 lines ✓
```

### **Zero Breaking Changes:**

- ✅ API externe identique (BLM/WHM/RDM/SCH/GEO_SPELL_DATABASE publics)
- ✅ Job files ne changent pas (require paths identiques)
- ✅ MidcastManager compatible (skill databases déjà supportés)
- ✅ spell_message_handler.lua compatible

---

## ⚠️ RISQUES & MITIGATION

### **Risque 1: Casser Spell Access pour RDM/WHM**

**Mitigation:** Test exhaustif in-game avant de supprimer fichiers obsolètes

### **Risque 2: Performance (Multiple requires)**

**Mitigation:** Lua caching via `require()` = pas d'impact performance

### **Risque 3: Oublier Mettre à Jour require() Path**

**Mitigation:** Grep exhaustif + tests in-game tous jobs

---

## 📝 NEXT STEPS

### **Option A: Migration Minimale (Recommandé - 3-5h)**

1. ✅ Phase 1: Audit (1h)
2. ✅ Phase 2: Éliminer duplication RDM/WHM (2-3h)
3. ✅ Phase 5: Testing (2h)
4. ❌ Skip Phase 3 (Skill databases optionnels)
5. ❌ Skip Phase 4 (Réorganisation structure)

**Résultat:** Zéro duplication Enfeebling/Enhancing, structure reste as-is

### **Option B: Migration Complète (Recommandé Long-Terme - 10-15h)**

1. ✅ Phase 1: Audit (1h)
2. ✅ Phase 2: Éliminer duplication RDM/WHM (2-3h)
3. ✅ Phase 3: Créer skill databases (4-6h)
4. ✅ Phase 4: Réorganiser structure (1-2h)
5. ✅ Phase 5: Testing (2h)
6. ✅ Phase 6: Documentation (1h)

**Résultat:** Architecture world-class, zéro duplication, structure parfaite

---

**FIN DU PLAN DE RÉORGANISATION**
