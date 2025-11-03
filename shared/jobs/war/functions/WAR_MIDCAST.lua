---============================================================================
--- WAR Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Warrior (primarily subjob spells).
---
--- @file WAR_MIDCAST.lua
--- @author Tetsouo
--- @version 2.0 - Migrated to MidcastManager
--- @date Created: 2025-09-29 | Updated: 2025-10-25
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')

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
            target_func = MidcastManager.get_enhancing_target
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
