---============================================================================
--- GEO Messages Module - Geomancer Spell and Luopan Message Formatting
---============================================================================
--- Uses NEW message system with inline colors
--- Delegates to api/messages.lua for all formatting
---
--- @file utils/messages/message_geo.lua
--- @author Tetsouo
--- @version 2.0 (NEW SYSTEM)
--- @date Created: 2025-10-16 | Migrated: 2025-11-06
---============================================================================

local GEOMessages = {}

-- NEW message system
local M = require('shared/utils/messages/api/messages')

-- Load Geomancy databases for descriptions
local indi_module = require('shared/data/magic/geomancy/geomancy_indi')
local geo_module = require('shared/data/magic/geomancy/geomancy_geo')
local indi_db = indi_module.spells or indi_module
local geo_db = geo_module.spells or geo_module

-- Get job tag (for subjob support: GEO/WHM → "GEO/WHM")
local function get_job_tag()
    local main_job = player and player.main_job or 'GEO'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- INDI/GEO SPELL CASTING MESSAGES (NEW SYSTEM)
---============================================================================

--- Display Indi spell cast message
--- Format: [cyan][GEO/WHM] [white][Indi-Haste] [gray]-> Increases haste.
--- @param spell_name string Full spell name (e.g., "Indi-Haste")
function GEOMessages.show_indi_cast(spell_name)
    if not indi_db then
        M.error("Indi database not loaded")
        return
    end

    local spell_data = indi_db[spell_name]
    if not spell_data then
        M.error(string.format("Spell '%s' not found in Indi database", spell_name))
        return
    end

    -- Use NEW system with inline colors
    M.job('GEO', 'indi_cast', {
        job = get_job_tag(),
        spell = spell_name,
        description = spell_data.description or "Unknown effect"
    })
end

--- Display Geo spell cast message
--- Format: [cyan][GEO/WHM] [white][Geo-Refresh] [gray]-> Increases refresh rate.
--- @param spell_name string Full spell name (e.g., "Geo-Refresh")
function GEOMessages.show_geo_cast(spell_name)
    if not geo_db then
        M.error("Geo database not loaded")
        return
    end

    local spell_data = geo_db[spell_name]
    if not spell_data then
        M.error(string.format("Spell '%s' not found in Geo database", spell_name))
        return
    end

    -- Use NEW system with inline colors
    M.job('GEO', 'geo_cast', {
        job = get_job_tag(),
        spell = spell_name,
        description = spell_data.description or "Unknown effect"
    })
end

---============================================================================
--- SPELL REFINEMENT MESSAGES (NEW SYSTEM)
---============================================================================

--- Display spell refinement message (tier downgrade)
--- @param desired_spell string Original spell name requested
--- @param final_spell string Final spell name after refinement
function GEOMessages.show_spell_refined(desired_spell, final_spell)
    M.job('GEO', 'spell_refined', {
        desired = desired_spell,
        final = final_spell
    })
end

--- Display no tier available error
--- @param desired_spell string Spell name that was requested
function GEOMessages.show_no_tier_available(desired_spell)
    M.job('GEO', 'no_tier_available', {
        spell = desired_spell
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return GEOMessages
