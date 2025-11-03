# Message System - Global Modular Architecture

**Version:** 2.0 - Global Refactor
**Date:** 2025-10-29
**Author:** Tetsouo

---

## 🎯 OBJECTIF

Refactorisation du système de messages pour éliminer la duplication de code entre jobs et créer une architecture modulaire organisée par **TYPE** (abilities, magic, buffs) plutôt que par **JOB** (brd, blm, war).

---

## 📐 ARCHITECTURE

### **Ancienne Architecture (Job-Based)**
```
messages/
├── message_brd.lua     (880 lines - MONOLITHIQUE)
├── message_blm.lua     (585 lines - MONOLITHIQUE)
├── message_rdm.lua     (352 lines)
├── message_dnc.lua     (194 lines - NON UTILISÉ)
└── ... (duplication massive)
```

**Problèmes:**
- ❌ Duplication: `show_soul_voice_activated()` (BRD) = même pattern que `show_berserk_activated()` (WAR)
- ❌ Monolithique: Fichiers > 800 lines
- ❌ Organisation par JOB au lieu de TYPE

### **Nouvelle Architecture (Type-Based)**
```
messages/
├── core/                          [Core utilities - inchangé]
│   ├── message_core.lua
│   └── message_colors.lua
│
├── abilities/                     [Job Abilities - GLOBAL]
│   └── message_ja_buffs.lua       ← NOUVEAU: Universal JA activation (ALL jobs)
│
├── magic/                         [Magic Spells - By spell type]
│   └── message_songs.lua          ← NOUVEAU: BRD songs (organized by TYPE not JOB)
│
├── buffs/                         [Buffs/Dances/Steps - By buff type]
│   └── message_dances.lua         ← DNC dances (from message_dnc.lua)
│
├── weaponskills/                  [Weaponskills - FUTURE]
│   └── message_ws.lua
│
├── utility/                       [Utility - Special systems]
│   └── roll_messages.lua          ← COR rolls (relocated)
│
└── [OLD - Backward Compatibility]
    ├── message_brd.lua            ← To be migrated progressively
    ├── message_blm.lua            ← To be migrated progressively
    ├── message_rdm.lua            ← To be migrated progressively
    └── ...
```

---

## 🚀 NOUVEAUX MODULES GLOBAUX

### **1. abilities/message_ja_buffs.lua** (GLOBAL - ALL JOBS)

**Fonctions Universelles:**

```lua
-- Pattern 1: JA Activated with Description
JABuffs.show_activated("Soul Voice", "Song power boost!")     -- BRD
JABuffs.show_activated("Berserk", "Attack boost!")            -- WAR
JABuffs.show_activated("Last Resort", "Attack boost, Defense down") -- DRK

-- Output: [BRD/WHM] Soul Voice activated! Song power boost!
-- Output: [WAR/SAM] Berserk activated! Attack boost!
-- Output: [DRK/SAM] Last Resort activated! Attack boost, Defense down

-- Pattern 2: JA Active (Status Check)
JABuffs.show_active("Nightingale")  -- BRD
JABuffs.show_active("Defender")     -- PLD

-- Output: [BRD/WHM] Nightingale active
-- Output: [PLD/WAR] Defender active

-- Pattern 3: JA Ended (Buff Wore Off)
JABuffs.show_ended("Soul Voice")    -- BRD
JABuffs.show_ended("Berserk")       -- WAR

-- Output: [BRD/WHM] Soul Voice ended
-- Output: [WAR/SAM] Berserk ended

-- Pattern 4: JA With Description (Colon Format)
JABuffs.show_with_description("Nightingale", "Casting Time reduced")  -- BRD
JABuffs.show_with_description("Defender", "Defense boost, Attack down") -- PLD

-- Output: [BRD/WHM] Nightingale: Casting Time reduced
-- Output: [PLD/WAR] Defender: Defense boost, Attack down

-- Pattern 5: JA Using (Pre-Action)
JABuffs.show_using("Marcato")       -- BRD
JABuffs.show_using("Provoke")       -- PLD

-- Output: [BRD/WHM] Using Marcato
-- Output: [PLD/WAR] Using Provoke
```

**Backward Compatibility Wrappers:**
```lua
-- Old BRD functions still work via wrappers
JABuffs.show_soul_voice_activated()    -- Calls show_activated("Soul Voice", "Song power boost!")
JABuffs.show_nightingale_activated()   -- Calls show_with_description("Nightingale", "Casting Time reduced")
JABuffs.show_troubadour_activated()    -- Calls show_with_description("Troubadour", "Song duration extended")
JABuffs.show_marcato_used()            -- Calls show_using("Marcato")
```

---

### **2. magic/message_songs.lua** (BRD-Specific, TYPE-Organized)

**Fonctions BRD Songs:**

```lua
-- Song Rotation
SongMessages.show_songs_casting(4, "4-Song")
-- Output: [BRD/WHM] 4-Song Rotation: Phase 1 > Phase 2 (dummies) > Phase 3

-- Song Pack
SongMessages.show_song_pack("MELEE", {"March", "Madrigal", "Minuet", "Minuet"})
-- Output: [BRD/WHM] MELEE Pack: March > Madrigal > Minuet > Minuet

-- Honor March Protection
SongMessages.show_honor_march_locked()
SongMessages.show_honor_march_released()

-- Instrument Selection
SongMessages.show_daurdabla_dummy()
-- Output: [BRD/WHM] Dummy Song using Daurdabla to expand song slots

-- Pianissimo
SongMessages.show_pianissimo_used()
SongMessages.show_pianissimo_target("Kaories")
-- Output: [BRD/WHM] [Pianissimo] Targeting: Kaories

-- Marcato (Song-Related)
SongMessages.show_marcato_honor_march("Honor March")
SongMessages.show_marcato_skip_buffs()
SongMessages.show_marcato_skip_soul_voice()
```

---

### **3. buffs/message_dances.lua** (DNC-Specific, TYPE-Organized)

**Fonctions DNC Dances/Steps/Flourishes:**

```lua
-- Dance Activation
DanceMessages.show_dance_activation("Saber Dance")
-- Output: [DNC/NIN] Activating: Saber Dance

-- Step Execution
DanceMessages.show_step_execution("Quick Step", false)
DanceMessages.show_step_execution("Quick Step", true)  -- with Presto
-- Output: [DNC/NIN] Executing: Presto → Quick Step

-- Flourish Activation
DanceMessages.show_flourish_activation("Climactic Flourish", false)
DanceMessages.show_flourish_activation("Climactic Flourish", true)  -- auto-triggered
-- Output: [DNC/NIN] Auto-Triggered: Climactic Flourish

-- State Change
DanceMessages.show_state_change("Dance", "Saber Dance")
-- Output: [DNC/NIN] Dance → Saber Dance
```

---

### **4. utility/roll_messages.lua** (COR-Specific, Relocated)

**Fonctions COR Rolls (Inchangé, juste relocalisé):**

```lua
RollMessages.show_roll_result(roll_name, roll_value, lucky, unlucky)
RollMessages.show_roll_bust()
RollMessages.show_active_rolls()
-- Complex multi-line formatted messages with circled numbers
```

---

## 📖 UTILISATION - MIGRATION JOBS

### **AVANT (Job-Specific - message_brd.lua)**

```lua
-- Dans BRD_BUFFS.lua
local MessageFormatter = require('shared/utils/messages/message_formatter')

function job_buff_change(buff, gain)
    if buff == "Soul Voice" then
        if gain then
            MessageFormatter.show_soul_voice_activated()  -- OLD: Specific function
        else
            MessageFormatter.show_soul_voice_ended()       -- OLD: Specific function
        end
    end
end
```

### **APRÈS (Global System)**

```lua
-- Dans BRD_BUFFS.lua
local MessageFormatter = require('shared/utils/messages/message_formatter')

function job_buff_change(buff, gain)
    if buff == "Soul Voice" then
        if gain then
            MessageFormatter.show_ja_activated("Soul Voice", "Song power boost!")  -- NEW: Generic function
        else
            MessageFormatter.show_ja_ended("Soul Voice")                            -- NEW: Generic function
        end
    end
end
```

**Avantages:**
- ✅ Même fonction pour TOUS les jobs (WAR, PLD, DRK peuvent utiliser `show_ja_activated()`)
- ✅ Moins de duplication (1 fonction au lieu de 50)
- ✅ Maintenance centralisée

---

## 🔄 BACKWARD COMPATIBILITY

**Toutes les anciennes fonctions continuent de fonctionner** pendant la migration:

```lua
-- OLD (still works)
MessageFormatter.show_soul_voice_activated()     -- BRDMessages.show_soul_voice_activated()
MessageFormatter.show_nightingale_activated()    -- BRDMessages.show_nightingale_activated()

-- NEW (recommended)
MessageFormatter.show_ja_activated("Soul Voice", "Song power boost!")
MessageFormatter.show_ja_with_description("Nightingale", "Casting Time reduced")
```

**Wrappers disponibles** pour transition douce:
```lua
-- Dans message_formatter.lua
MessageFormatter.show_soul_voice_activated_new = JABuffs.show_soul_voice_activated
MessageFormatter.show_nightingale_activated_new = JABuffs.show_nightingale_activated
```

---

## 📊 BÉNÉFICES

### **Réduction Code**
- **message_brd.lua**: 880 lines → ~300 lines (après migration vers modules globaux)
- **message_blm.lua**: 585 lines → ~200 lines (après migration vers modules globaux)
- **Total estimé**: -1,500+ lines de code dupliqué éliminé

### **Maintenabilité**
- ✅ Modifier format JA activation messages → 1 fichier (message_ja_buffs.lua) au lieu de 10+
- ✅ Ajouter nouveau job → Réutilise fonctions existantes (pas besoin de créer nouvelles fonctions)
- ✅ Bug fix → Centralisé (1 fix = tous jobs corrigés)

### **Organisation**
- ✅ Modules par TYPE (abilities/, magic/, buffs/) = logique
- ✅ Fichiers < 300 lines chacun (vs 880 lines avant)
- ✅ Backward compatibility = migration progressive sans casser existant

---

## 🔨 PLAN DE MIGRATION

### **Phase 1: Infrastructure (COMPLETED ✅)**
- [x] Créer structure directories (abilities/, magic/, buffs/, utility/, weaponskills/)
- [x] Créer message_ja_buffs.lua (global)
- [x] Créer message_songs.lua (BRD songs)
- [x] Organiser message_dances.lua (DNC, from message_dnc.lua)
- [x] Déplacer roll_messages.lua → utility/
- [x] Mettre à jour message_formatter.lua (charger nouveaux modules)

### **Phase 2: Migration BRD (NEXT)**
- [ ] Migrer BRD_BUFFS.lua vers nouveau système
- [ ] Migrer BRD_PRECAST.lua vers nouveau système
- [ ] Tester in-game (Soul Voice, Nightingale, Troubadour, Marcato)
- [ ] Valider backward compatibility

### **Phase 3: Migration Autres Jobs**
- [ ] Migrer WAR (Berserk, Warcry, etc.) → show_ja_activated()
- [ ] Migrer PLD (Majesty, Sentinel, etc.) → show_ja_activated()
- [ ] Migrer DRK (Last Resort, Scarlet Delirium, etc.) → show_ja_activated()
- [ ] Migrer BLM (Elemental magic messages)
- [ ] Migrer RDM (Enhancing magic messages)

### **Phase 4: Cleanup**
- [ ] Supprimer anciens fichiers job-specific (message_brd.lua, message_blm.lua, etc.)
- [ ] Supprimer wrappers backward compatibility (une fois migration complète)
- [ ] Documentation finale

---

## 📝 EXAMPLES CONCRETS

### **Example 1: WAR Berserk (AVANT → APRÈS)**

**AVANT:**
```lua
-- Dans message_war.lua (n'existe pas encore, mais si on le créait)
function WARMessages.show_berserk_activated()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s activated! %sAttack boost!",
        job_color, job_tag,
        ability_color, "Berserk",
        success_color,
        action_color
    )
    add_to_chat(001, formatted_message)
end
```

**APRÈS:**
```lua
-- Dans WAR_BUFFS.lua
local MessageFormatter = require('shared/utils/messages/message_formatter')

function job_buff_change(buff, gain)
    if buff == "Berserk" and gain then
        MessageFormatter.show_ja_activated("Berserk", "Attack boost!")
    end
end
```

**Résultat:**
- ✅ -15 lines de code
- ✅ Réutilise fonction globale
- ✅ Même output visuel

---

### **Example 2: DNC Climactic Flourish (AVANT → APRÈS)**

**AVANT:**
```lua
-- Dans DNC_PRECAST.lua (before)
if flourish_name == "Climactic Flourish" then
    add_to_chat(158, "[DNC] Using Climactic Flourish before WS")
end
```

**APRÈS:**
```lua
-- Dans DNC_PRECAST.lua (after)
local MessageFormatter = require('shared/utils/messages/message_formatter')

if flourish_name == "Climactic Flourish" then
    MessageFormatter.show_dance_activating("Climactic Flourish", true)  -- auto-triggered
end
```

**Résultat:**
- ✅ Format professionnel multi-color (au lieu de simple chat 158)
- ✅ Cohérent avec autres messages du système

---

## 🎓 STANDARDS DE CODE

### **Naming Conventions**

```lua
-- Module names
message_ja_buffs.lua         -- Global modules: lowercase + underscore
message_songs.lua            -- Type-based: lowercase + underscore

-- Function names
show_ja_activated()          -- Global functions: snake_case
show_song_rotation()         -- Type-specific: snake_case

-- Variables
local job_tag                -- Variables: snake_case
local Colors                 -- Module references: PascalCase
```

### **File Organization**

```lua
---============================================================================
--- [Module Name] - [Short Description]
---============================================================================
--- [Longer description]
---
--- Usage Examples:
---   Function.call(params)
---
--- @file path/to/file.lua
--- @author Tetsouo
--- @version X.Y
--- @date Created: YYYY-MM-DD
---============================================================================

local ModuleName = {}

-- Load dependencies
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

---============================================================================
--- SECTION 1
---============================================================================

--- Function description
--- @param param1 type Description
--- @return type Description
function ModuleName.function_name(param1)
    -- Implementation
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return ModuleName
```

---

## 🔍 DEBUGGING

### **Test Message Colors**

```lua
//gs c colortest
-- Shows all color codes for US vs EU regions
```

### **Test New Functions In-Game**

```lua
-- In jobs/brd/functions/BRD_BUFFS.lua (temporary test)
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Test global JA activation
MessageFormatter.show_ja_activated("Soul Voice", "Song power boost!")
MessageFormatter.show_ja_active("Nightingale")
MessageFormatter.show_ja_ended("Soul Voice")

-- Test song messages
MessageFormatter.show_song_rotation(4, "4-Song")
MessageFormatter.show_song_pack("MELEE", {"March", "Madrigal", "Minuet", "Minuet"})
```

---

## 📚 RÉFÉRENCES

**Fichiers Clés:**
- `message_formatter.lua` - Façade principale (charge tous modules)
- `message_core.lua` - Fonctions core (color codes, job tags)
- `message_colors.lua` - Configuration couleurs (US/EU region support)
- `abilities/message_ja_buffs.lua` - JA activation messages (GLOBAL)
- `magic/message_songs.lua` - BRD song messages
- `buffs/message_dances.lua` - DNC dance messages

**Documentation:**
- `.claude/MIDCAST_STANDARD.md` - MidcastManager standard (système similaire)
- `.claude/standards.md` - Standards généraux projet Tetsouo
- `CLAUDE.md` - Guide complet développement Tetsouo

---

**FIN - Message System v2.0 Global Refactor**
