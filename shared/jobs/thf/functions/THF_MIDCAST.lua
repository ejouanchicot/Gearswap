---  ═══════════════════════════════════════════════════════════════════════════
---   THF Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Thief (primarily subjob spells).
---
---   @file    THF_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.0 - Added spell_family database support
---   @date    Created: 2025-10-06 | Updated: 2025-11-05
---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')

local MidcastManager = nil
local EnhancingSPELLS = nil

---   Pre-midcast hook (Ranged Attack auto-lock handling)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- ══════════════════════════════════════════════════════════════════════════
    -- RANGED ATTACK AUTO-LOCK (during midcast)
    -- ══════════════════════════════════════════════════════════════════════════
    -- ALWAYS lock on Ranged Attack, regardless of previous state
    -- This creates an infinite cycle: /ra → lock+ON, bind → unlock+OFF, /ra → lock+ON, etc.
    if spell.action_type == 'Ranged Attack' and not spell.interrupted then
        -- Lock range/ammo slots (prevent future swaps)
        disable('range', 'ammo')

        -- Set RangeLock state to ON (even if it was OFF before)
        -- Use :set(true) to trigger state change callback
        if state and state.RangeLock then
            state.RangeLock:set(true)
        end
    end
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
