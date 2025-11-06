---============================================================================
--- WAR Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Warrior (primarily subjob spells).
---
--- @file WAR_MIDCAST.lua
--- @author Tetsouo
--- @version 3.0 - Added spell_family database support
--- @date Created: 2025-09-29 | Updated: 2025-11-05
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')

-- Load ENHANCING_MAGIC_DATABASE for spell_family routing
local EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

function job_midcast(spell, action, spellMap, eventArgs)
    -- No WAR-specific PRE-midcast logic
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Healing Magic (from subjob /WHM, /RDM)
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell
        })
        return
    end

    -- Enhancing Magic (from subjob /RDM, /WHM)
    if spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

local WAR_MIDCAST = {}
WAR_MIDCAST.job_midcast = job_midcast
WAR_MIDCAST.job_post_midcast = job_post_midcast

return WAR_MIDCAST
