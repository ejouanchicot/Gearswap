---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Samurai (primarily subjob spells).
---
---   @file    SAM_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.0 - Added spell_family database support
---   @date    Updated: 2025-11-05
---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')

local MidcastManager = nil
local EnhancingSPELLS = nil

---   Pre-midcast hook (job-specific logic before set selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- No SAM-specific PRE-midcast logic
end

---   Post-midcast hook (MidcastManager routing and gear selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    MidcastManager, EnhancingSPELLS = MidcastDeps.load()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
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
            database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })
        return
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
}
