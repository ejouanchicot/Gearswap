---============================================================================
--- WAR Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Warrior (primarily subjob spells).
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Modules loaded on first spell cast (saves ~15ms at startup)
---
--- @file WAR_MIDCAST.lua
--- @author Tetsouo
--- @version 3.1 - Lazy Loading for performance
--- @date Created: 2025-09-29 | Updated: 2025-11-15
---============================================================================

-- Lazy loading: Modules loaded on first spell cast
local MidcastManager = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false
local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then
        return
    end

    MidcastManager = require('shared/utils/midcast/midcast_manager')

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    modules_loaded = true
end

function job_midcast(spell, action, spellMap, eventArgs)
    -- No WAR-specific PRE-midcast logic
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first spell cast
    ensure_modules_loaded()

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
