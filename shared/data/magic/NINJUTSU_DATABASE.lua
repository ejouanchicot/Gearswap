---============================================================================
--- NINJUTSU DATABASE - Index & Helper Functions
---============================================================================
--- Central repository for ALL player-castable Ninjutsu in FFXI.
--- Data source: bg-wiki.com (individual spell pages).
---
--- Features:
---   - 37 complete Ninjutsu (loaded from 3 modules)
---   - NIN-exclusive access (main job or /NIN subjob, capped at Lv.49)
---   - Accurate elements, levels, tiers from bg-wiki
---   - Helper functions for spell lookups
---   - Compatible with spell_message_handler.lua
---
--- Architecture:
---   - Modular: 3 sub-modules
---   - Skill-based (Ninjutsu) for zero duplication
---
--- Module Structure:
---   - ninjutsu/ninjutsu_buffs.lua   (11 spells): Tonko, Utsusemi, Monomi, etc.
---   - ninjutsu/ninjutsu_debuffs.lua (8 spells):  Kurayami, Hojo, Dokumori, etc.
---   - ninjutsu/ninjutsu_nukes.lua   (18 spells): Katon/Suiton/Raiton/Doton/Huton/Hyoton x3
---
--- Conventions (aligned with other magic databases):
---   - category   = "Ninjutsu" (always)
---   - magic_type = "Ninjutsu" (always)
---   - element    = real FFXI element; wiki "Thunder" is stored as "Lightning"
---   - main_job_only = true when required level > 49 (the /NIN subjob cap)
---   - tier = "I" (Ichi) / "II" (Ni) / "III" (San) for tiered families
---   - Nukes carry v (base value) and m (dINT multiplier) + `weakens` element
---
--- @file shared/data/magic/NINJUTSU_DATABASE.lua
--- @author Tetsouo
--- @version 2.0 - Modular Architecture (3 files)
--- @date Created: 2026-06-07
--- @source https://www.bg-wiki.com/ffxi/Category:Ninjutsu
---============================================================================

local NINJUTSU_DATABASE = {}

---============================================================================
--- LOAD SUB-MODULES
---============================================================================

local BUFFS = require('shared/data/magic/ninjutsu/ninjutsu_buffs')
local DEBUFFS = require('shared/data/magic/ninjutsu/ninjutsu_debuffs')
local NUKES = require('shared/data/magic/ninjutsu/ninjutsu_nukes')

---============================================================================
--- MERGE ALL SPELL MODULES
---============================================================================

NINJUTSU_DATABASE.spells = {}

-- Merge Buffs (11 spells)
for spell_name, spell_data in pairs(BUFFS.spells) do
    NINJUTSU_DATABASE.spells[spell_name] = spell_data
end

-- Merge Debuffs (8 spells)
for spell_name, spell_data in pairs(DEBUFFS.spells) do
    NINJUTSU_DATABASE.spells[spell_name] = spell_data
end

-- Merge Nukes (18 spells)
for spell_name, spell_data in pairs(NUKES.spells) do
    NINJUTSU_DATABASE.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get spell description
--- @param spell_name string Name of spell
--- @return string|nil description
function NINJUTSU_DATABASE.get_description(spell_name)
    local spell_data = NINJUTSU_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.description
    end
    return nil
end

--- Get spell element (real FFXI element; "Lightning" for Raiton)
--- @param spell_name string Name of spell
--- @return string|nil element
function NINJUTSU_DATABASE.get_element(spell_name)
    local spell_data = NINJUTSU_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.element
    end
    return nil
end

--- Get spell tier ("I" Ichi / "II" Ni / "III" San, or nil)
--- @param spell_name string Name of spell
--- @return string|nil tier
function NINJUTSU_DATABASE.get_tier(spell_name)
    local spell_data = NINJUTSU_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.tier
    end
    return nil
end

--- Check whether NIN can cast a spell at a given level / job role
--- @param spell_name string Name of spell
--- @param level number Current NIN level
--- @param is_main_job boolean True if NIN is the main job
--- @return boolean True if castable
function NINJUTSU_DATABASE.can_cast(spell_name, level, is_main_job)
    local spell_data = NINJUTSU_DATABASE.spells[spell_name]
    if not spell_data or not spell_data.NIN then
        return false
    end
    if spell_data.main_job_only and not is_main_job then
        return false
    end
    return level >= spell_data.NIN
end

---============================================================================
--- SPELL COUNT SUMMARY
---============================================================================
--- Total: 37 Ninjutsu
---   - Buffs: 11 (Tonko, Utsusemi, Monomi, Myoshu, Migawari, Gekka, Yain, Kakka)
---   - Debuffs: 8 (Kurayami, Hojo, Dokumori, Jubaku, Aisha, Yurin)
---   - Nukes: 18 (Katon/Suiton/Raiton/Doton/Huton/Hyoton x Ichi/Ni/San)
---============================================================================

return NINJUTSU_DATABASE
