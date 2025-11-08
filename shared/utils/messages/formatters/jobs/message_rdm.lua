---============================================================================
--- RDM Messages Module - Red Mage Job Ability and Spell Message Formatting
---============================================================================
--- Uses NEW message system with inline colors
--- Delegates to api/messages.lua for all formatting
---
--- @file utils/messages/message_rdm.lua
--- @author Tetsouo
--- @version 2.0 (NEW SYSTEM)
--- @date Created: 2025-10-16 | Migrated: 2025-11-06
---============================================================================

local RDMMessages = {}

-- NEW message system
local M = require('shared/utils/messages/api/messages')

-- Get job tag (for subjob support: RDM/WHM >> "RDM/WHM")
local function get_job_tag()
    local main_job = player and player.main_job or 'RDM'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- DEBUFF WARNING MESSAGES (NEW SYSTEM)
---============================================================================

--- Display DOOM warning message
function RDMMessages.show_doom_warning()
    M.job('RDM', 'doom_warning', {
        job = get_job_tag()
    })
end

--- Display Doom removed message
function RDMMessages.show_doom_removed()
    M.job('RDM', 'doom_removed', {
        job = get_job_tag()
    })
end

---============================================================================
--- SPELL CASTING MESSAGES (NEW SYSTEM)
---============================================================================

--- Display spell casting message
--- @param spell_name string Name of the spell being cast
function RDMMessages.show_spell_casting(spell_name)
    M.job('RDM', 'spell_casting', {
        job = get_job_tag(),
        spell = spell_name
    })
end

--- Display element list help message
function RDMMessages.show_element_list()
    M.job('RDM', 'element_list', {
        job = get_job_tag()
    })
end

---============================================================================
--- STATE DISPLAY MESSAGES (NEW SYSTEM)
---============================================================================

--- Display current Enspell state
--- @param enspell_value string Current enspell value
function RDMMessages.show_enspell_current(enspell_value)
    M.job('RDM', 'enspell_current', {
        job = get_job_tag(),
        value = enspell_value
    })
end

--- Display current Storm state
--- @param storm_value string Current storm value
function RDMMessages.show_storm_current(storm_value)
    M.job('RDM', 'storm_current', {
        job = get_job_tag(),
        value = storm_value
    })
end

---============================================================================
--- ERROR MESSAGES (NEW SYSTEM)
---============================================================================

--- Display no Enspell selected error
function RDMMessages.show_no_enspell_selected()
    M.job('RDM', 'no_enspell_selected', {
        job = get_job_tag()
    })
end

--- Display Gain spell not configured error
function RDMMessages.show_gain_spell_not_configured()
    M.job('RDM', 'gain_spell_not_configured', {
        job = get_job_tag()
    })
end

--- Display Bar Element not configured error
function RDMMessages.show_bar_element_not_configured()
    M.job('RDM', 'bar_element_not_configured', {
        job = get_job_tag()
    })
end

--- Display Bar Ailment not configured error
function RDMMessages.show_bar_ailment_not_configured()
    M.job('RDM', 'bar_ailment_not_configured', {
        job = get_job_tag()
    })
end

--- Display Spike not configured error
function RDMMessages.show_spike_not_configured()
    M.job('RDM', 'spike_not_configured', {
        job = get_job_tag()
    })
end

--- Display Storm requires SCH subjob error
function RDMMessages.show_storm_requires_sch()
    M.job('RDM', 'storm_requires_sch', {
        job = get_job_tag()
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return RDMMessages
