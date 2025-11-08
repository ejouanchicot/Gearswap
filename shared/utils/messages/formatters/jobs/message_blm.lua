---============================================================================
--- BLM Messages Module - Black Mage Element and Spell Message Formatting
---============================================================================
--- Uses NEW message system with inline colors
--- Delegates to api/messages.lua for all formatting
---
--- @file utils/messages/message_blm.lua
--- @author Tetsouo
--- @version 2.0 (NEW SYSTEM)
--- @date Created: 2025-10-15 | Migrated: 2025-11-06
---============================================================================

local BLMMessages = {}

-- NEW message system
local M = require('shared/utils/messages/api/messages')

-- Get job tag (for subjob support: BLM/WHM >> "BLM/WHM")
local function get_job_tag()
    local main_job = player and player.main_job or 'BLM'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- ELEMENT COLOR MAPPING
---============================================================================

--- Element-specific color codes for visual feedback (inline FFXI color codes)
--- @type table<string, string>
local ELEMENT_COLORS = {
    -- Main Elements (spell names)
    ['Fire'] = string.char(0x1F, 2),        -- Fire (code 002)
    ['Blizzard'] = string.char(0x1F, 30),   -- Ice (code 030)
    ['Aero'] = string.char(0x1F, 14),       -- Wind (code 014)
    ['Stone'] = string.char(0x1F, 37),      -- Earth (code 037)
    ['Thunder'] = string.char(0x1F, 16),    -- Thunder (code 016)
    ['Water'] = string.char(0x1F, 219),     -- Water (code 219)

    -- Aja Spells
    ['Firaja'] = string.char(0x1F, 2),      -- Fire
    ['Blizzaja'] = string.char(0x1F, 30),   -- Ice
    ['Aeroja'] = string.char(0x1F, 14),     -- Wind
    ['Stoneja'] = string.char(0x1F, 37),    -- Earth
    ['Thundaja'] = string.char(0x1F, 16),   -- Thunder
    ['Waterja'] = string.char(0x1F, 219),   -- Water

    -- Storm Spells
    ['Firestorm'] = string.char(0x1F, 2),       -- Fire
    ['Hailstorm'] = string.char(0x1F, 30),      -- Ice
    ['Windstorm'] = string.char(0x1F, 14),      -- Wind
    ['Sandstorm'] = string.char(0x1F, 37),      -- Earth
    ['Thunderstorm'] = string.char(0x1F, 16),   -- Thunder
    ['Rainstorm'] = string.char(0x1F, 219),     -- Water
    ['Voidstorm'] = string.char(0x1F, 200),     -- Void (code 200)
    ['Aurorastorm'] = string.char(0x1F, 187),   -- Light (code 187)
}

---============================================================================
--- ELEMENT CYCLE MESSAGES (NEW SYSTEM)
---============================================================================

--- Display element cycle message with colored element name
--- @param state_type string Type of state (e.g., 'MainLight', 'SubDark')
--- @param element_name string Name of the element
function BLMMessages.show_element_cycle(state_type, element_name)
    local element_color = ELEMENT_COLORS[element_name] or string.char(0x1F, 13)  -- Cyan fallback
    M.job('BLM', 'element_cycle', {
        job = get_job_tag(),
        state_type = state_type,
        element_color = element_color,
        element = element_name
    })
end

---============================================================================
--- SPELL CYCLE MESSAGES (NEW SYSTEM)
---============================================================================

--- Display Aja spell cycle message
--- @param aja_name string Name of the Aja spell
function BLMMessages.show_aja_cycle(aja_name)
    local element_color = ELEMENT_COLORS[aja_name] or string.char(0x1F, 13)  -- Cyan fallback
    M.job('BLM', 'aja_cycle', {
        job = get_job_tag(),
        element_color = element_color,
        aja = aja_name
    })
end

--- Display Storm spell cycle message
--- @param storm_name string Name of the Storm spell
function BLMMessages.show_storm_cycle(storm_name)
    local element_color = ELEMENT_COLORS[storm_name] or string.char(0x1F, 13)  -- Cyan fallback
    M.job('BLM', 'storm_cycle', {
        job = get_job_tag(),
        element_color = element_color,
        storm = storm_name
    })
end

--- Display tier cycle message
--- @param tier_value string Tier value (6, 5, 4, 3, 2, or base)
function BLMMessages.show_tier_cycle(tier_value)
    M.job('BLM', 'tier_cycle', {
        job = get_job_tag(),
        tier = tier_value
    })
end

---============================================================================
--- BUFF MESSAGES (NEW SYSTEM)
---============================================================================

--- Display self-buff activation message
function BLMMessages.show_buff_activated()
    M.job('BLM', 'buff_activated', {
        job = get_job_tag()
    })
end

--- Display individual buff cast message
--- @param buff_name string Name of the buff spell
function BLMMessages.show_buff_cast(buff_name)
    M.job('BLM', 'buff_cast', {
        job = get_job_tag(),
        buff = buff_name
    })
end

---============================================================================
--- CASTING MODE MESSAGES (NEW SYSTEM)
---============================================================================

--- Display Magic Burst mode activation
function BLMMessages.show_magic_burst_on()
    M.job('BLM', 'magic_burst_on', {
        job = get_job_tag()
    })
end

--- Display Magic Burst mode deactivation
function BLMMessages.show_magic_burst_off()
    M.job('BLM', 'magic_burst_off', {
        job = get_job_tag()
    })
end

--- Display Free Nuke mode activation
function BLMMessages.show_free_nuke_on()
    M.job('BLM', 'free_nuke_on', {
        job = get_job_tag()
    })
end

---============================================================================
--- SPELL REFINEMENT MESSAGES (NEW SYSTEM)
---============================================================================

--- Display spell refinement (tier downgrade) message
--- @param original string Original spell name
--- @param downgrade string Downgraded spell name
--- @param recast_seconds number Recast time remaining
function BLMMessages.show_spell_refinement(original, downgrade, recast_seconds)
    M.job('BLM', 'spell_refinement', {
        job = get_job_tag(),
        original = original,
        downgrade = downgrade,
        recast = string.format("%.1f", recast_seconds)
    })
end

--- Display spell refinement failed (no downgrade available)
--- @param spell_name string Spell name
--- @param recast_seconds number Recast time remaining
function BLMMessages.show_spell_refinement_failed(spell_name, recast_seconds)
    M.job('BLM', 'spell_refinement_failed', {
        job = get_job_tag(),
        spell = spell_name,
        recast = string.format("%.1f", recast_seconds)
    })
end

---============================================================================
--- MP CONSERVATION MESSAGES (NEW SYSTEM)
---============================================================================

--- Display MP conservation gear switch message
--- @param mp_status string 'Low' or 'High'
function BLMMessages.show_mp_conservation(mp_status)
    local mp_color = mp_status == 'Low' and '{orange}' or '{green}'
    local gear_type = mp_status == 'Low' and 'Conservation' or 'Full Potency'

    M.job('BLM', 'mp_conservation', {
        job = get_job_tag(),
        mp_color = mp_color,
        status = mp_status,
        gear_type = gear_type
    })
end

---============================================================================
--- DARK ARTS MESSAGES (SCH SUBJOB) (NEW SYSTEM)
---============================================================================

--- Display Dark Arts activation message
--- @param spell_name string Name of the spell being cast
function BLMMessages.show_dark_arts_activated(spell_name)
    M.job('BLM', 'dark_arts_activated', {
        job = get_job_tag(),
        spell = spell_name
    })
end

--- Display Arts already active message
--- @param arts_status string Status description (e.g., "Light Arts + Addendum: White")
function BLMMessages.show_arts_already_active(arts_status)
    M.job('BLM', 'arts_already_active', {
        job = get_job_tag(),
        arts = arts_status
    })
end

--- Display Stratagem no charges available message
--- @param stratagem_name string Name of the stratagem (e.g., "Addendum: Black")
--- @param recast_minutes number Recast time in minutes
function BLMMessages.show_stratagem_no_charges(stratagem_name, recast_minutes)
    M.job('BLM', 'stratagem_no_charges', {
        job = get_job_tag(),
        stratagem = stratagem_name,
        recast = string.format("%.1f", recast_minutes)
    })
end

---============================================================================
--- ERROR MESSAGES (NEW SYSTEM)
---============================================================================

--- Display error message for missing BuffSelf function
function BLMMessages.show_buffself_error()
    M.job('BLM', 'buffself_error', {
        job = get_job_tag()
    })
end

--- Display error for invalid spell replacement parameters
function BLMMessages.show_spell_replacement_error()
    M.job('BLM', 'spell_replacement_error', {
        job = get_job_tag()
    })
end

--- Display error for invalid spell refinement parameters
function BLMMessages.show_spell_refinement_error()
    M.job('BLM', 'spell_refinement_error', {
        job = get_job_tag()
    })
end

--- Display error for failed spell recasts retrieval
function BLMMessages.show_spell_recasts_error()
    M.job('BLM', 'spell_recasts_error', {
        job = get_job_tag()
    })
end

--- Display insufficient MP error
--- @param player_mp number Current player MP
function BLMMessages.show_insufficient_mp_error(player_mp)
    M.job('BLM', 'insufficient_mp_error', {
        job = get_job_tag(),
        mp = tostring(player_mp)
    })
end

--- Display Breakga replacement blocked message (lag protection)
function BLMMessages.show_breakga_blocked()
    M.job('BLM', 'breakga_blocked', {
        job = get_job_tag()
    })
end

--- Display error for failed spell recasts in BuffSelf
function BLMMessages.show_buffself_recasts_error()
    M.job('BLM', 'buffself_recasts_error', {
        job = get_job_tag()
    })
end

--- Display error for failed resources loading in BuffSelf
function BLMMessages.show_buffself_resources_error()
    M.job('BLM', 'buffself_resources_error', {
        job = get_job_tag()
    })
end

--- Display buff casting message
--- @param spell_name string Name of the buff spell
--- @param delay number Delay in seconds before casting (unused, kept for compatibility)
function BLMMessages.show_buff_casting(spell_name, delay)
    M.job('BLM', 'buff_casting', {
        job = get_job_tag(),
        spell = spell_name
    })
end

--- Display buff status (active or recast)
--- @param status_string string Complete status string with all buffs
function BLMMessages.show_buff_status(status_string)
    M.job('BLM', 'buff_status', {
        job = get_job_tag(),
        status = status_string
    })
end

--- Display error for unknown buff spell
--- @param spell_name string Name of the unknown spell
function BLMMessages.show_unknown_buff_error(spell_name)
    M.job('BLM', 'unknown_buff_error', {
        job = get_job_tag(),
        spell = spell_name
    })
end

--- Display buff already active message
--- @param spell_name string Name of the buff spell
function BLMMessages.show_buff_already_active(spell_name)
    M.job('BLM', 'buff_already_active', {
        job = get_job_tag(),
        spell = spell_name
    })
end

--- Display manual buff cast message
--- @param spell_name string Name of the buff spell
function BLMMessages.show_manual_buff_cast(spell_name)
    M.job('BLM', 'manual_buff_cast', {
        job = get_job_tag(),
        spell = spell_name
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLMMessages
