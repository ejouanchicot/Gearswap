# MIDCAST STANDARD - Base Obligatoire pour TOUS les Jobs

**Version:** 1.0
**Date:** 2025-10-25
**Statut:** OBLIGATOIRE pour tous les jobs

---

## 🎯 RÈGLE ABSOLUE

**MidcastManager est OBLIGATOIRE pour TOUS les jobs**, même ceux sans nested sets complexes.

✅ **Comme LockstyleManager** - Factory obligatoire pour lockstyle
✅ **Comme MacrobookManager** - Factory obligatoire pour macrobook
✅ **MidcastManager** - **BASE OBLIGATOIRE** pour midcast

**Raison**: Consistency, maintenabilité, zéro duplication.

---

## 📋 TEMPLATE OBLIGATOIRE - [JOB]_MIDCAST.lua

**TOUS les jobs doivent suivre ce template EXACTEMENT:**

```lua
---============================================================================
--- [JOB] Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast gear selection using centralized MidcastManager.
---
--- @file [JOB]_MIDCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: [DATE]
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')

-- Optional: Load job-specific databases
-- local [JOB]Spells = require('shared/data/magic/[JOB]_SPELL_DATABASE')

---============================================================================
--- MIDCAST HOOKS
---============================================================================

--- Pre-midcast hook (optional job-specific logic)
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- Optional: Job-specific PRE-midcast logic
    -- Example: Auto-trigger abilities, buff checks, etc.
end

--- Post-midcast hook (MidcastManager routing)
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- ==========================================================================
    -- MAGIC SKILL 1 - Example: Enfeebling Magic
    -- ==========================================================================
    if spell.skill == 'Enfeebling Magic' then
        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell,
            mode_state = state.EnfeebleMode,  -- Optional: nil if no mode
            database_func = nil,  -- Optional: [JOB]Spells.get_enfeebling_type
            target_func = nil     -- Optional: MidcastManager.get_enhancing_target
        })

        -- Optional: Job-specific overrides AFTER MidcastManager
        -- Example: Saboteur hands override for RDM
        -- if buffactive['Saboteur'] then
        --     equip({hands = 'Lethargy Gants +3'})
        -- end

        return
    end

    -- ==========================================================================
    -- MAGIC SKILL 2 - Example: Enhancing Magic
    -- ==========================================================================
    if spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            mode_state = state.EnhancingMode,  -- Optional
            target_func = MidcastManager.get_enhancing_target  -- self vs others
        })
        return
    end

    -- ==========================================================================
    -- MAGIC SKILL 3 - Example: Elemental Magic
    -- ==========================================================================
    if spell.skill == 'Elemental Magic' then
        MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell,
            mode_state = state.NukeMode  -- Optional: FreeNuke, MB, etc.
        })
        return
    end

    -- ==========================================================================
    -- MAGIC SKILL 4 - Example: Healing Magic
    -- ==========================================================================
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell,
            mode_state = state.CureMode  -- Optional
        })
        return
    end

    -- Add more skills as needed...
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export to global scope (for Mote-Include)
_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Export module
local [JOB]_MIDCAST = {}
[JOB]_MIDCAST.job_midcast = job_midcast
[JOB]_MIDCAST.job_post_midcast = job_post_midcast

return [JOB]_MIDCAST
```

---

## 🔧 CONFIGURATIONS REQUISES PAR TYPE DE JOB

### **JOB TYPE 1: Mages (RDM, BLM, WHM, GEO, BRD, COR)**

**Skills communs:**
- Enfeebling Magic
- Enhancing Magic
- Elemental Magic
- Healing Magic
- Divine Magic
- Dark Magic
- Singing (BRD only)
- Ninjutsu (if /NIN)
- Blue Magic (if /BLU)

**Template:**
```lua
if spell.skill == 'Enfeebling Magic' then
    MidcastManager.select_set({
        skill = 'Enfeebling Magic',
        spell = spell,
        mode_state = state.EnfeebleMode,
        database_func = [JOB]Spells.get_enfeebling_type  -- Optional
    })
    return
end

if spell.skill == 'Enhancing Magic' then
    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        mode_state = state.EnhancingMode,
        target_func = MidcastManager.get_enhancing_target
    })
    return
end

if spell.skill == 'Elemental Magic' then
    MidcastManager.select_set({
        skill = 'Elemental Magic',
        spell = spell,
        mode_state = state.NukeMode
    })
    return
end

if spell.skill == 'Healing Magic' then
    MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell,
        mode_state = state.CureMode
    })
    return
end
```

---

### **JOB TYPE 2: Tanks/Paladins (PLD, RUN)**

**Skills communs:**
- Healing Magic
- Enhancing Magic
- Divine Magic
- Blue Magic (PLD can use /BLU)

**Template:**
```lua
if spell.skill == 'Healing Magic' then
    MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell,
        mode_state = state.CureMode
    })
    return
end

if spell.skill == 'Blue Magic' then
    MidcastManager.select_set({
        skill = 'Blue Magic',
        spell = spell
        -- Usually no mode/database for Blue Magic (AOE detection manual)
    })
    return
end
```

---

### **JOB TYPE 3: Melee avec Magic Subjob (WAR/RDM, SAM/WHM, etc.)**

**Skills communs (via subjob):**
- Healing Magic
- Enhancing Magic
- Elemental Magic (si /BLM, /RDM)

**Template:**
```lua
if spell.skill == 'Healing Magic' then
    MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell
        -- Usually no mode for subjob cures
    })
    return
end

if spell.skill == 'Enhancing Magic' then
    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        target_func = MidcastManager.get_enhancing_target
    })
    return
end
```

---

### **JOB TYPE 4: Pure Melee (MNK, DRG, etc.)**

**Si AUCUN spell:**
```lua
function job_midcast(spell, action, spellMap, eventArgs)
    -- No magic skills - empty (but file must exist)
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- No magic skills - empty (but file must exist)
end
```

**IMPORTANT:** Même si le job n'utilise PAS de magic, le fichier `[JOB]_MIDCAST.lua` **DOIT EXISTER** avec les fonctions vides.

---

## 📊 EXEMPLES RÉELS PAR JOB

### **RDM (Complete)**
```lua
-- Enfeebling Magic
if spell.skill == 'Enfeebling Magic' then
    MidcastManager.select_set({
        skill = 'Enfeebling Magic',
        spell = spell,
        mode_state = state.EnfeebleMode,
        database_func = RDMSpells.get_enfeebling_type
    })

    -- Saboteur override
    if buffactive['Saboteur'] then
        equip({hands = 'Lethargy Gants +3'})
    end
    return
end

-- Enhancing Magic
if spell.skill == 'Enhancing Magic' then
    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        mode_state = state.EnhancingMode,
        target_func = MidcastManager.get_enhancing_target
    })
    return
end

-- Elemental Magic
if spell.skill == 'Elemental Magic' then
    MidcastManager.select_set({
        skill = 'Elemental Magic',
        spell = spell,
        mode_state = state.NukeMode
    })
    return
end
```

---

### **BLM (Simplifié)**
```lua
-- Elemental Magic
if spell.skill == 'Elemental Magic' then
    MidcastManager.select_set({
        skill = 'Elemental Magic',
        spell = spell,
        mode_state = state.NukeMode  -- FreeNuke, MB, etc.
    })
    return
end

-- Dark Magic
if spell.skill == 'Dark Magic' then
    MidcastManager.select_set({
        skill = 'Dark Magic',
        spell = spell,
        mode_state = state.DarkMode  -- Optional
    })
    return
end
```

---

### **WHM (Simplifié)**
```lua
-- Healing Magic
if spell.skill == 'Healing Magic' then
    MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell,
        mode_state = state.CureMode
    })
    return
end

-- Enhancing Magic
if spell.skill == 'Enhancing Magic' then
    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        target_func = MidcastManager.get_enhancing_target
    })
    return
end

-- Divine Magic
if spell.skill == 'Divine Magic' then
    MidcastManager.select_set({
        skill = 'Divine Magic',
        spell = spell
    })
    return
end
```

---

### **PLD (Avec Blue Magic)**
```lua
-- Healing Magic
if spell.skill == 'Healing Magic' then
    MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell
    })
    return
end

-- Blue Magic (AOE detection)
if spell.skill == 'Blue Magic' then
    MidcastManager.select_set({
        skill = 'Blue Magic',
        spell = spell
        -- AOE detection handled in sets structure
    })
    return
end
```

---

### **WAR (Minimal - Subjob Magic Only)**
```lua
-- Healing Magic (from /WHM, /RDM subjob)
if spell.skill == 'Healing Magic' then
    MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell
    })
    return
end
```

---

## ❌ ANTI-PATTERNS - NE JAMAIS FAIRE

### **MAUVAIS: Logique manuelle de fallback**
```lua
-- ❌ INCORRECT - Ne PAS coder fallback manuellement
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Enfeebling Magic' then
        local set_to_equip = sets.midcast['Enfeebling Magic']

        if state.EnfeebleMode.value == 'Potency' then
            set_to_equip = sets.midcast['Enfeebling Magic'].Potency or set_to_equip
        end

        if RDMSpells.get_enfeebling_type(spell.english) == 'mnd_potency' then
            set_to_equip = sets.midcast['Enfeebling Magic'].mnd_potency or set_to_equip
        end

        equip(set_to_equip)
    end
end
```

### **BON: MidcastManager**
```lua
-- ✅ CORRECT - Utiliser MidcastManager
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Enfeebling Magic' then
        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell,
            mode_state = state.EnfeebleMode,
            database_func = RDMSpells.get_enfeebling_type
        })
    end
end
```

---

## 🔍 DEBUG MODE

**Activer debug pour TOUS les jobs:**
```lua
//gs c debugmidcast
```

**Désactiver debug:**
```lua
//gs c debugmidcast  (toggle)
```

**Note:** Debug state persiste via `_G.MidcastManagerDebugState` et survit aux reloads.

---

## 📋 CHECKLIST MIGRATION JOB

Pour migrer un job existant vers MidcastManager:

### **Étape 1: Backup**
```bash
copy "[JOB]_MIDCAST.lua" "[JOB]_MIDCAST_OLD.lua"
```

### **Étape 2: Identifier Skills**
Lister tous les `spell.skill` utilisés dans le job:
- Enfeebling Magic
- Enhancing Magic
- Elemental Magic
- Healing Magic
- Divine Magic
- Dark Magic
- Blue Magic
- Singing
- Ninjutsu
- etc.

### **Étape 3: Remplacer Code**
Pour chaque skill, remplacer la logique manuelle par:
```lua
if spell.skill == 'Skill Name' then
    MidcastManager.select_set({
        skill = 'Skill Name',
        spell = spell,
        mode_state = state.SomeMode,  -- Optional
        database_func = nil,  -- Optional
        target_func = nil     -- Optional
    })
    return
end
```

### **Étape 4: Tester In-Game**
```lua
//lua unload gearswap
//lua load gearswap
//gs c debugmidcast  (activer debug)
Cast spells de chaque skill
Vérifier console output
//gs c debugmidcast  (désactiver debug)
```

### **Étape 5: Valider Equipment**
```lua
//gs c checksets
```

### **Étape 6: Delete OLD File**
```bash
del "[JOB]_MIDCAST_OLD.lua"
```

---

## 📊 STATUT MIGRATION PAR JOB

| Job | Status | Lines Before | Lines After | Reduction |
|-----|--------|-------------|-------------|-----------|
| **RDM** | ✅ COMPLETE | 192 | 123 | -36% |
| **BLM** | ⏳ TODO | ~180 | ~100 | -44% |
| **WHM** | ⏳ TODO | ~170 | ~100 | -41% |
| **GEO** | ⏳ TODO | ~160 | ~90 | -44% |
| **PLD** | ⏳ TODO | ~150 | ~80 | -47% |
| **DRK** | ⏳ TODO | ~140 | ~80 | -43% |
| **BRD** | ⏳ TODO | ~200 | ~120 | -40% |
| **COR** | ⏳ TODO | ~160 | ~90 | -44% |
| **BST** | ⏳ TODO | ~120 | ~60 | -50% |
| **WAR** | ⏳ TODO | ~80 | ~40 | -50% |
| **SAM** | ⏳ TODO | ~80 | ~40 | -50% |
| **DNC** | ⏳ TODO | ~60 | ~30 | -50% |
| **THF** | ⏳ TODO | ~60 | ~30 | -50% |

**Total Projection:** ~2,000 lignes → ~1,000 lignes (**-50% code duplication**)

---

## 🎯 RÈGLES FINALES

1. ✅ **MidcastManager OBLIGATOIRE** - Comme factories (Lockstyle/Macrobook)
2. ✅ **Fichier [JOB]_MIDCAST.lua OBLIGATOIRE** - Même si job n'utilise pas magic
3. ✅ **Template standard** - Copier template, adapter skills
4. ✅ **Debug activable** - `//gs c debugmidcast` pour TOUS les jobs
5. ✅ **Pas de logique fallback manuelle** - MidcastManager handle tout
6. ✅ **Overrides APRÈS MidcastManager** - OK de faire `equip()` après si besoin job-specific

---

**Version:** 1.0
**Date:** 2025-10-25
**Auteur:** Tetsouo
**Statut:** STANDARD OBLIGATOIRE - Production Ready

---

**FIN DU STANDARD MIDCAST** ✅
