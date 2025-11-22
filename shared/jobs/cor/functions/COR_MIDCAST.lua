---============================================================================
--- COR Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Corsair including Ranged Attack and subjob spells.
---
--- Features:
---   - Ranged Attack: Bullet flight time gear
---   - Healing Magic: Cure spells (from subjob)
---   - Enhancing Magic: Buff spells (from subjob)
---   - Elemental Magic: Nuking (if COR/RDM or COR/BLM)
---
--- Important Notes:
---   - Phantom Rolls/Quick Draw are instantaneous (PRECAST only, no midcast)
---
--- @file COR_MIDCAST.lua
--- @author Tetsouo
--- @version 3.1 - Added spell_family database support
--- @date Created: 2025-10-07 | Updated: 2025-11-05
---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local MidcastManager = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    MidcastManager = require('shared/utils/midcast/midcast_manager')

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    modules_loaded = true
end

function job_midcast(spell, action, spellMap, eventArgs)
    -- No COR-specific PRE-midcast logic
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first spell cast
    ensure_modules_loaded()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- ==========================================================================
    -- RANGED ATTACK (Bullet flight time)
    -- ==========================================================================
    if spell.type == 'Ranged Attack' then
        MidcastManager.select_set({
            skill = 'RA',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- HEALING MAGIC (from subjob)
    -- ==========================================================================
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- ENHANCING MAGIC (from subjob)
    -- ==========================================================================
    if spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })
        return
    end

    -- ==========================================================================
    -- ELEMENTAL MAGIC (from COR/RDM or COR/BLM)
    -- ==========================================================================
    if spell.skill == 'Elemental Magic' then
        MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- ENFEEBLING MAGIC (from subjob)
    -- ==========================================================================
    if spell.skill == 'Enfeebling Magic' then
        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell
        })
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

local COR_MIDCAST = {}
COR_MIDCAST.job_midcast = job_midcast
COR_MIDCAST.job_post_midcast = job_post_midcast

return COR_MIDCAST
