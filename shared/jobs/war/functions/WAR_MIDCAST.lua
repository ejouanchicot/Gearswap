---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Warrior (primarily subjob spells).
---
---   **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Modules loaded on first spell cast
---
---   @file    WAR_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.1 - Lazy Loading for performance
---   @date    Created: 2025-09-29 | Updated: 2025-11-15
---  ═══════════════════════════════════════════════════════════════════════════

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
    -- No WAR-specific PRE-midcast logic
end

---   Post-midcast hook (MidcastManager routing and gear selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    MidcastManager, EnhancingSPELLS = MidcastDeps.load()

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

