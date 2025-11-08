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

-- Get job tag (for subjob support: GEO/WHM >> "GEO/WHM")
local function get_job_tag()
    local main_job = player and player.main_job or 'GEO'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- ELEMENT COLOR MAPPING
---============================================================================

--- Element-specific color codes for Geomancy spells (inline FFXI color codes)
--- IMPORTANT: Two spell types for GEO:
--- 1. Indi-/Geo- spells: Element in database field (e.g., "Indi-Acumen" has element="Ice")
--- 2. -ra spells: Element in spell name (e.g., "Fira", "Blizzara", "Thundara")
--- @type table<string, string>
local ELEMENT_COLORS = {
    -- Database element field (Indi-/Geo- spells)
    ['Fire']    = string.char(0x1F, 2),    -- Fire (code 002)
    ['Ice']     = string.char(0x1F, 30),   -- Ice (code 030)
    ['Wind']    = string.char(0x1F, 14),   -- Wind (code 014)
    ['Earth']   = string.char(0x1F, 37),   -- Earth (code 037)
    ['Thunder'] = string.char(0x1F, 16),   -- Thunder (code 016)
    ['Water']   = string.char(0x1F, 219),  -- Water (code 219)
    ['Light']   = string.char(0x1F, 187),  -- Light (code 187)
    ['Dark']    = string.char(0x1F, 200),  -- Dark (code 200)

    -- Spell name patterns (-ra AOE spells: Fira, Blizzara, etc.)
    ['Fira']     = string.char(0x1F, 2),    -- Fire (matches "Fira", "Fira II", "Fira III")
    ['Blizzara'] = string.char(0x1F, 30),   -- Ice
    ['Aerora']   = string.char(0x1F, 14),   -- Wind
    ['Stonera']  = string.char(0x1F, 37),   -- Earth
    ['Thundara'] = string.char(0x1F, 16),   -- Thunder
    ['Watera']   = string.char(0x1F, 219),  -- Water
}

--- Get element color from spell database (Indi-/Geo- spells)
--- @param spell_data table Spell data from database
--- @return string|nil element_color Inline color code or nil
local function get_element_color_from_data(spell_data)
    if not spell_data or not spell_data.element then
        return nil
    end
    return ELEMENT_COLORS[spell_data.element]
end

--- Get element color from spell name (-ra AOE spells: Fira, Blizzara, etc.)
--- @param spell_name string Spell name
--- @return string|nil element_color Inline color code or nil
local function get_element_color_from_name(spell_name)
    -- Check if spell name contains -ra spell pattern
    for pattern, color in pairs(ELEMENT_COLORS) do
        if spell_name:match(pattern) then
            return color
        end
    end
    return nil
end

---============================================================================
--- INDI/GEO SPELL CASTING MESSAGES (NEW SYSTEM)
---============================================================================

--- Display Indi spell cast message
--- Format: [cyan][GEO/WHM] [ELEMENT_COLOR][Indi-Acumen] [gray]>> Boosts magic atk. (Ice element)
--- @param spell_name string Full spell name (e.g., "Indi-Acumen")
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

    -- Try to get element color from spell database first (Indi-/Geo- spells)
    -- Then try from spell name (-ra AOE spells)
    local element_color = get_element_color_from_data(spell_data) or get_element_color_from_name(spell_name)
    local gray_code = string.char(0x1F, 160)

    -- Add element color to spell name if spell has an element
    local colored_spell = spell_name
    if element_color then
        colored_spell = element_color .. spell_name .. gray_code
    end

    -- Use NEW system with inline colors
    M.job('GEO', 'indi_cast', {
        job = get_job_tag(),
        spell = colored_spell,
        description = spell_data.description or "Unknown effect"
    })
end

--- Display Geo spell cast message (includes -ra AOE spells like Fira, Blizzara)
--- Format: [cyan][GEO/WHM] [ELEMENT_COLOR][Geo-Fury] [gray]>> Boosts attack. (Fire element)
--- Format: [cyan][GEO/WHM] [FIRE_COLOR][Fira II] [gray]>> Deals AOE dmg.
--- @param spell_name string Full spell name (e.g., "Geo-Fury", "Fira II")
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

    -- Try to get element color from spell database first (Indi-/Geo- spells)
    -- Then try from spell name (-ra AOE spells)
    local element_color = get_element_color_from_data(spell_data) or get_element_color_from_name(spell_name)
    local gray_code = string.char(0x1F, 160)

    -- Add element color to spell name if spell has an element
    local colored_spell = spell_name
    if element_color then
        colored_spell = element_color .. spell_name .. gray_code
    end

    -- Use NEW system with inline colors
    M.job('GEO', 'geo_cast', {
        job = get_job_tag(),
        spell = colored_spell,
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
