---============================================================================
--- DNC Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Dancer (including NIN subjob Utsusemi management).
---
--- Features:
---   - Utsusemi: Ichi shadow management (auto-cancel)
---   - Waltz healing gear (handled in precast)
---   - Step/Samba duration (handled in precast)
---
--- @file DNC_MIDCAST.lua
--- @author Tetsouo
--- @version 3.0 - Added spell_family database support
--- @date Created: 2025-10-04 | Updated: 2025-11-05
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')

-- Load ENHANCING_MAGIC_DATABASE for spell_family routing
local EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

function job_midcast(spell, action, spellMap, eventArgs)
    -- Utsusemi: Ichi shadow management
    -- Cancel existing shadows mid-cast (2.3 sec delay) before Ichi finishes casting
    if spell.english == 'Utsusemi: Ichi' then
        send_command('wait 2.3; cancel 66')   -- Copy Image
        send_command('wait 2.3; cancel 444')  -- Copy Image (2)
        send_command('wait 2.3; cancel 445')  -- Copy Image (3)
        send_command('wait 2.3; cancel 446')  -- Copy Image (4+)
    end
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

local DNC_MIDCAST = {}
DNC_MIDCAST.job_midcast = job_midcast
DNC_MIDCAST.job_post_midcast = job_post_midcast

return DNC_MIDCAST
