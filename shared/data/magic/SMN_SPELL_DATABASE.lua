---============================================================================
--- SMN Spell Database - Complete Summoner Avatar & Blood Pact Data (Façade)
---============================================================================
--- Contains all SMN avatars/spirits and blood pacts (Rage/Ward)
--- Data extracted from FFXI SMN ability list.
---
--- @file config/magic/SMN_SPELL_DATABASE.lua
--- @author Tetsouo
--- @version 2.0 - Façade Architecture
--- @date Created: 2025-10-12
--- @date Refactored: 2025-10-12
---
--- NOTES:
--- - SMN uses Avatar system (summon avatars to fight)
--- - Spirits: Low-level elemental avatars (level 1-30)
--- - Avatars: Full avatars requiring quests (Ifrit, Shiva, etc.)
--- - Blood Pact: Rage = Offensive abilities
--- - Blood Pact: Ward = Support/Buff abilities
--- - Two-Hour abilities require Astral Flow
--- - Perpetuation Cost: Avatars drain MP/tick while summoned
--- - Restrictions: subjob, subjob_master_only, main_job_only, two_hour
---
--- ARCHITECTURE:
--- - This file is a FAÇADE that loads internal modules
--- - Internal modules: spirits, avatars, rage, ward
--- - All helper functions remain in this façade file
--- - Public API remains 100% unchanged for backward compatibility
---============================================================================

local SMNSpells = {}

---============================================================================
--- LOAD MODULAR FILES (NEW ARCHITECTURE - 12 files organized by avatar)
---============================================================================

-- Load all avatar files from summoning/ directory
local carbuncle = require('shared/data/magic/summoning/carbuncle')
local cait_sith = require('shared/data/magic/summoning/cait_sith')
local diabolos = require('shared/data/magic/summoning/diabolos')
local fenrir = require('shared/data/magic/summoning/fenrir')
local garuda = require('shared/data/magic/summoning/garuda')
local ifrit = require('shared/data/magic/summoning/ifrit')
local leviathan = require('shared/data/magic/summoning/leviathan')
local ramuh = require('shared/data/magic/summoning/ramuh')
local shiva = require('shared/data/magic/summoning/shiva')
local siren = require('shared/data/magic/summoning/siren')
local spirits = require('shared/data/magic/summoning/spirits')
local titan = require('shared/data/magic/summoning/titan')

---============================================================================
--- MERGE SPELL DATA (136 total SMN spells from 12 files)
---============================================================================

-- Create unified .spells table for spell_message_handler compatibility
SMNSpells.spells = {}

-- Merge all avatar files into .spells table
for spell_name, spell_data in pairs(carbuncle.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(cait_sith.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(diabolos.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(fenrir.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(garuda.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(ifrit.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(leviathan.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(ramuh.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(shiva.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(siren.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(spirits.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(titan.spells) do
    SMNSpells.spells[spell_name] = spell_data
end

-- Merge all blood pacts from avatar files into .spells table
for pact_name, pact_data in pairs(carbuncle.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(cait_sith.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(diabolos.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(fenrir.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(garuda.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(ifrit.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(leviathan.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(ramuh.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(shiva.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(siren.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

for pact_name, pact_data in pairs(titan.blood_pacts or {}) do
    SMNSpells.spells[pact_name] = pact_data
end

-- Create legacy compatibility tables (for existing code that uses these)
SMNSpells.spirits = {}
SMNSpells.avatars = {}
SMNSpells.blood_pacts_rage = {}
SMNSpells.blood_pacts_ward = {}

-- Populate legacy tables by category
for spell_name, spell_data in pairs(SMNSpells.spells) do
    if spell_data.category == "Spirit Summon" then
        SMNSpells.spirits[spell_name] = spell_data
    elseif spell_data.category == "Avatar Summon" then
        SMNSpells.avatars[spell_name] = spell_data
    elseif spell_data.category == "Blood Pact: Rage" then
        SMNSpells.blood_pacts_rage[spell_name] = spell_data
    elseif spell_data.category == "Blood Pact: Ward" then
        SMNSpells.blood_pacts_ward[spell_name] = spell_data
    end
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if player can summon spirit/avatar at level
--- @param summon_name string Summon name
--- @param job_code string Job code (SMN, etc.)
--- @param level number Player level
--- @param is_main_job boolean Is this main job (not subjob)
--- @return boolean True if player can summon
function SMNSpells.can_summon(summon_name, job_code, level, is_main_job)
    local summon = SMNSpells.spirits[summon_name] or SMNSpells.avatars[summon_name]
    if not summon then
        return false
    end

    local required_level = summon[job_code]
    if not required_level then
        return false
    end

    if level < required_level then
        return false
    end

    -- Check main job restriction
    if summon.restriction == "main_job_only" and not is_main_job then
        return false
    end

    return true
end

--- Check if player can use blood pact at level
--- @param pact_name string Blood pact name
--- @param job_code string Job code (SMN, etc.)
--- @param level number Player level
--- @param is_main_job boolean Is this main job (not subjob)
--- @return boolean True if player can use pact
function SMNSpells.can_use_pact(pact_name, job_code, level, is_main_job)
    local pact = SMNSpells.blood_pacts_rage[pact_name] or SMNSpells.blood_pacts_ward[pact_name]
    if not pact then
        return false
    end

    local required_level = pact[job_code]
    if not required_level then
        return false
    end

    if level < required_level then
        return false
    end

    -- Check restrictions
    if pact.restriction == "main_job_only" and not is_main_job then
        return false
    end

    if pact.restriction == "subjob_master_only" and (not is_main_job or level < 96) then
        return false
    end

    return true
end

--- Get all blood pacts for an avatar
--- @param avatar_name string Avatar name (Ifrit, Shiva, etc.)
--- @param pact_type string "rage" or "ward" or nil (both)
--- @return table List of blood pact names
function SMNSpells.get_avatar_pacts(avatar_name, pact_type)
    local pacts = {}

    if not pact_type or pact_type == "rage" then
        for pact_name, pact_data in pairs(SMNSpells.blood_pacts_rage) do
            if pact_data.avatar == avatar_name then
                table.insert(pacts, pact_name)
            end
        end
    end

    if not pact_type or pact_type == "ward" then
        for pact_name, pact_data in pairs(SMNSpells.blood_pacts_ward) do
            if pact_data.avatar == avatar_name then
                table.insert(pacts, pact_name)
            end
        end
    end

    return pacts
end

--- Get all blood pacts by element
--- @param element string Element (Fire, Ice, Wind, Earth, Thunder, Water, Light, Dark)
--- @param pact_type string "rage" or "ward" or nil (both)
--- @return table List of blood pact names
function SMNSpells.get_pacts_by_element(element, pact_type)
    local pacts = {}

    if not pact_type or pact_type == "rage" then
        for pact_name, pact_data in pairs(SMNSpells.blood_pacts_rage) do
            if pact_data.element == element then
                table.insert(pacts, pact_name)
            end
        end
    end

    if not pact_type or pact_type == "ward" then
        for pact_name, pact_data in pairs(SMNSpells.blood_pacts_ward) do
            if pact_data.element == element then
                table.insert(pacts, pact_name)
            end
        end
    end

    return pacts
end

--- Get all rage pacts by damage type
--- @param damage_type string Damage type ("Physical", "Magical", "Hybrid", "Breath")
--- @return table List of blood pact rage names
function SMNSpells.get_rage_by_damage_type(damage_type)
    local pacts = {}

    for pact_name, pact_data in pairs(SMNSpells.blood_pacts_rage) do
        if pact_data.damage_type == damage_type then
            table.insert(pacts, pact_name)
        end
    end

    return pacts
end

--- Get skillchain property for a rage pact
--- @param pact_name string Blood pact rage name
--- @return string|nil Skillchain property or nil
function SMNSpells.get_skillchain_property(pact_name)
    local pact = SMNSpells.blood_pacts_rage[pact_name]
    if not pact then
        return nil
    end

    return pact.property
end

--- Get avatar element
--- @param avatar_name string Avatar name
--- @return string|nil Element or nil
function SMNSpells.get_avatar_element(avatar_name)
    local avatar = SMNSpells.avatars[avatar_name]
    if not avatar then
        -- Try spirits
        avatar = SMNSpells.spirits[avatar_name]
    end

    if not avatar then
        return nil
    end

    return avatar.element
end

--- Get all two-hour abilities (Astral Flow)
--- @param pact_type string "rage" or "ward" or nil (both)
--- @return table List of two-hour pact names
function SMNSpells.get_two_hour_pacts(pact_type)
    local pacts = {}

    if not pact_type or pact_type == "rage" then
        for pact_name, pact_data in pairs(SMNSpells.blood_pacts_rage) do
            if pact_data.restriction == "two_hour" then
                table.insert(pacts, pact_name)
            end
        end
    end

    if not pact_type or pact_type == "ward" then
        for pact_name, pact_data in pairs(SMNSpells.blood_pacts_ward) do
            if pact_data.restriction == "two_hour" then
                table.insert(pacts, pact_name)
            end
        end
    end

    return pacts
end

--- Get all spirits
--- @return table List of spirit names
function SMNSpells.get_all_spirits()
    local spirits = {}
    for spirit_name, _ in pairs(SMNSpells.spirits) do
        table.insert(spirits, spirit_name)
    end
    return spirits
end

--- Get all avatars
--- @param include_restricted boolean Include main job only avatars (default: true)
--- @return table List of avatar names
function SMNSpells.get_all_avatars(include_restricted)
    if include_restricted == nil then
        include_restricted = true
    end

    local avatars = {}
    for avatar_name, avatar_data in pairs(SMNSpells.avatars) do
        if include_restricted or not avatar_data.restriction then
            table.insert(avatars, avatar_name)
        end
    end
    return avatars
end

--- Get blood pact data
--- @param pact_name string Blood pact name
--- @return table|nil Pact data or nil
function SMNSpells.get_pact_data(pact_name)
    return SMNSpells.blood_pacts_rage[pact_name] or SMNSpells.blood_pacts_ward[pact_name]
end

return SMNSpells
