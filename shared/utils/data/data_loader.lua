---============================================================================
--- FFXI Data Loader - Universal Data Access System
---============================================================================
--- Loads ALL game data (spells, abilities, weaponskills) into global table
--- accessible by ANY job, ANY subjob combination.
---
--- Features:
---   - Universal access: _G.FFXI_DATA.spells[name]
---   - All spells from all jobs (WHM, BLM, RDM, BRD, GEO, SCH, BLU, SMN, NIN)
---   - All job abilities from all jobs
---   - All weaponskills from all weapon types
---   - Lazy loading: Only loads when requested
---   - Safe pcall: Never crashes if file missing
---
--- Usage:
---   require('shared/utils/data/data_loader')
---   local spell = _G.FFXI_DATA.spells['Cure III']
---   print(spell.description)  -- "Restores HP (tier 3)."
---
--- Examples:
---   - WAR/BLU can access BLU spells for descriptions
---   - Any job can query weaponskill properties
---   - UI can display all available data without job restrictions
---
--- @file data_loader.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-01
---============================================================================

local DataLoader = {}

---============================================================================
--- GLOBAL DATA TABLE (Accessible everywhere via _G)
---============================================================================

if not _G.FFXI_DATA then
    _G.FFXI_DATA = {
        spells = {},
        abilities = {},
        weaponskills = {},
        loaded = {
            spells = false,
            abilities = false,
            weaponskills = false
        }
    }
end

---============================================================================
--- SPELL DATABASES (Aggregators - Already combine modular files)
---============================================================================

local SPELL_DATABASES = {
    -- Skill-based databases
    'shared/data/magic/DARK_MAGIC_DATABASE',
    'shared/data/magic/DIVINE_MAGIC_DATABASE',
    'shared/data/magic/ELEMENTAL_MAGIC_DATABASE',
    'shared/data/magic/ENFEEBLING_MAGIC_DATABASE',
    'shared/data/magic/ENHANCING_MAGIC_DATABASE',
    'shared/data/magic/HEALING_MAGIC_DATABASE',

    -- Job-based databases
    'shared/data/magic/BLM_SPELL_DATABASE',
    'shared/data/magic/RDM_SPELL_DATABASE',
    'shared/data/magic/WHM_SPELL_DATABASE',
    'shared/data/magic/GEO_SPELL_DATABASE',
    'shared/data/magic/BRD_SPELL_DATABASE',
    'shared/data/magic/SCH_SPELL_DATABASE',
    'shared/data/magic/BLU_SPELL_DATABASE',
    'shared/data/magic/SMN_SPELL_DATABASE',

    -- Ninjutsu
    'shared/data/magic/ninjutsu/NINJUTSU_DATABASE',
}

---============================================================================
--- JOB ABILITIES DATABASES (All jobs)
---============================================================================

local ABILITY_JOBS = {
    'blm', 'blu', 'brd', 'bst', 'cor', 'dnc', 'drg', 'drk', 'geo',
    'mnk', 'nin', 'pld', 'pup', 'rdm', 'rng', 'run', 'sam', 'sch',
    'thf', 'war', 'whm'
}

local ABILITY_TYPES = {
    'mainjob',
    'subjob',
    'sp',
}

---============================================================================
--- WEAPONSKILL DATABASES (All weapon types)
---============================================================================

local WEAPONSKILL_DATABASES = {
    'shared/data/weaponskills/SWORD_WS_DATABASE',
    'shared/data/weaponskills/GREATSWORD_WS_DATABASE',
    'shared/data/weaponskills/GREATKATANA_WS_DATABASE',
    'shared/data/weaponskills/KATANA_WS_DATABASE',
    'shared/data/weaponskills/AXE_WS_DATABASE',
    'shared/data/weaponskills/GREATAXE_WS_DATABASE',
    'shared/data/weaponskills/SCYTHE_WS_DATABASE',
    'shared/data/weaponskills/POLEARM_WS_DATABASE',
    'shared/data/weaponskills/CLUB_WS_DATABASE',
    'shared/data/weaponskills/STAFF_WS_DATABASE',
    'shared/data/weaponskills/DAGGER_WS_DATABASE',
    'shared/data/weaponskills/H2H_WS_DATABASE',
    'shared/data/weaponskills/ARCHERY_WS_DATABASE',
    'shared/data/weaponskills/UNIVERSAL_WS_DATABASE',
}

---============================================================================
--- LOAD SPELLS (From all databases)
---============================================================================

function DataLoader.load_spells()
    if _G.FFXI_DATA.loaded.spells then
        return true  -- Already loaded
    end

    local spell_count = 0

    for _, db_path in ipairs(SPELL_DATABASES) do
        local success, db = pcall(require, db_path)
        if success and db and db.spells then
            -- Merge all spells from this database
            for spell_name, spell_data in pairs(db.spells) do
                if not _G.FFXI_DATA.spells[spell_name] then
                    _G.FFXI_DATA.spells[spell_name] = spell_data
                    spell_count = spell_count + 1
                else
                    -- Spell already exists (possible in job-specific databases)
                    -- Keep existing (skill-based databases have priority)
                end
            end
        end
    end

    _G.FFXI_DATA.loaded.spells = true
    print(string.format('[DataLoader] Loaded %d spells', spell_count))
    return true
end

---============================================================================
--- LOAD JOB ABILITIES (From all jobs)
---============================================================================

function DataLoader.load_abilities()
    if _G.FFXI_DATA.loaded.abilities then
        return true  -- Already loaded
    end

    local ability_count = 0

    for _, job in ipairs(ABILITY_JOBS) do
        for _, type in ipairs(ABILITY_TYPES) do
            local path = string.format('shared/data/job_abilities/%s/%s_%s', job, job, type)
            local success, db = pcall(require, path)

            if success and db and db.abilities then
                -- Merge abilities
                for ability_name, ability_data in pairs(db.abilities) do
                    if not _G.FFXI_DATA.abilities[ability_name] then
                        _G.FFXI_DATA.abilities[ability_name] = ability_data
                        ability_count = ability_count + 1
                    end
                end
            end
        end

        -- Special cases: Pet commands, Rolls, Steps, etc.
        local special_patterns = {
            string.format('shared/data/job_abilities/%s/%s_pet_commands_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_pet_commands_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_rolls_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_rolls_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_waltzes_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_waltzes_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_steps_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_steps_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_flourishes1_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_flourishes2_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_flourishes2_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_flourishes3_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_sambas_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_sambas_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_jigs_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_jigs_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_black_grimoire_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_black_grimoire_subjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_white_grimoire_mainjob', job, job),
            string.format('shared/data/job_abilities/%s/%s_white_grimoire_subjob', job, job),
        }

        for _, path in ipairs(special_patterns) do
            local success, db = pcall(require, path)
            if success and db and db.abilities then
                for ability_name, ability_data in pairs(db.abilities) do
                    if not _G.FFXI_DATA.abilities[ability_name] then
                        _G.FFXI_DATA.abilities[ability_name] = ability_data
                        ability_count = ability_count + 1
                    end
                end
            end
        end
    end

    _G.FFXI_DATA.loaded.abilities = true
    print(string.format('[DataLoader] Loaded %d job abilities', ability_count))
    return true
end

---============================================================================
--- LOAD WEAPONSKILLS (From all weapon types)
---============================================================================

function DataLoader.load_weaponskills()
    if _G.FFXI_DATA.loaded.weaponskills then
        return true  -- Already loaded
    end

    local ws_count = 0

    for _, db_path in ipairs(WEAPONSKILL_DATABASES) do
        local success, db = pcall(require, db_path)
        if success and db and db.weaponskills then
            -- Merge all weaponskills
            for ws_name, ws_data in pairs(db.weaponskills) do
                if not _G.FFXI_DATA.weaponskills[ws_name] then
                    _G.FFXI_DATA.weaponskills[ws_name] = ws_data
                    ws_count = ws_count + 1
                end
            end
        end
    end

    _G.FFXI_DATA.loaded.weaponskills = true
    print(string.format('[DataLoader] Loaded %d weaponskills', ws_count))
    return true
end

---============================================================================
--- LOAD ALL DATA (Convenience function)
---============================================================================

function DataLoader.load_all()
    DataLoader.load_spells()
    DataLoader.load_abilities()
    DataLoader.load_weaponskills()
    return true
end

---============================================================================
--- QUERY FUNCTIONS
---============================================================================

--- Get spell data by name
--- @param spell_name string
--- @return table|nil
function DataLoader.get_spell(spell_name)
    if not _G.FFXI_DATA.loaded.spells then
        DataLoader.load_spells()
    end
    return _G.FFXI_DATA.spells[spell_name]
end

--- Get ability data by name
--- @param ability_name string
--- @return table|nil
function DataLoader.get_ability(ability_name)
    if not _G.FFXI_DATA.loaded.abilities then
        DataLoader.load_abilities()
    end
    return _G.FFXI_DATA.abilities[ability_name]
end

--- Get weaponskill data by name
--- @param ws_name string
--- @return table|nil
function DataLoader.get_weaponskill(ws_name)
    if not _G.FFXI_DATA.loaded.weaponskills then
        DataLoader.load_weaponskills()
    end
    return _G.FFXI_DATA.weaponskills[ws_name]
end

---============================================================================
--- AUTO-LOAD ON REQUIRE
---============================================================================

-- DISABLED: Auto-load spells (causes 100-300ms lag at startup)
-- Spells now load on-demand via get_spell() when first requested
-- (Abilities and weaponskills also load on-demand to save memory)
-- DataLoader.load_spells()  -- Commented out for performance

---============================================================================
--- MODULE EXPORT
---============================================================================

return DataLoader
