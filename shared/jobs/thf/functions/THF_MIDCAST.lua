---============================================================================
--- THF Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Thief (primarily subjob spells).
---
--- @file THF_MIDCAST.lua
--- @author Tetsouo
--- @version 3.0 - Added spell_family database support
--- @date Created: 2025-10-06 | Updated: 2025-11-05
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')

-- Load ENHANCING_MAGIC_DATABASE for spell_family routing
local EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

function job_midcast(spell, action, spellMap, eventArgs)
    -- No THF-specific PRE-midcast logic
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Ninjutsu (Utsusemi from /NIN subjob)
    if spell.skill == 'Ninjutsu' then
        MidcastManager.select_set({
            skill = 'Ninjutsu',
            spell = spell
        })
        return
    end

    -- Healing Magic (from subjob)
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell
        })
        return
    end

    -- Enhancing Magic (from subjob)
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

local THF_MIDCAST = {}
THF_MIDCAST.job_midcast = job_midcast
THF_MIDCAST.job_post_midcast = job_post_midcast

return THF_MIDCAST
