---============================================================================
--- RUN Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Rune Fencer with specialized Cure and enmity optimization.
---
--- Features:
---   - Cure III/IV: Dynamic CureSelf/CureOther via CureSetBuilder
---   - Enmity spells: Flash, Enlight
---   - Phalanx: XP mode (SIRD vs Potency)
---   - Enhancing Magic: Database-driven spell_family routing
---   - Divine Magic, Blue Magic support (RUN/BLU subjob)
---
--- @file RUN_MIDCAST.lua
--- @author Tetsouo
--- @version 5.0 - Added spell_family database support
--- @date Created: 2025-10-03 | Updated: 2025-11-05
--- @requires shared/jobs/run/functions/logic/cure_set_builder
---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local MidcastManager = nil
local CureSetBuilder = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    MidcastManager = require('shared/utils/midcast/midcast_manager')
    CureSetBuilder = require('shared/jobs/run/functions/logic/cure_set_builder')

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    modules_loaded = true
end

function job_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first midcast
    ensure_modules_loaded()

    -- ==========================================================================
    -- CURE III/IV: DYNAMIC TARGET-BASED SETS (CureSetBuilder)
    -- ==========================================================================
    -- These spells use CureSetBuilder logic module for optimal gear selection
    -- Must be handled in job_midcast BEFORE MidcastManager
    if spell.name == 'Cure III' or spell.name == 'Cure IV' then
        local target_type = spell.target.type == 'SELF' and 'SELF' or 'OTHER'
        local cure_set = CureSetBuilder.generate(spell, target_type)
        if cure_set then
            equip(cure_set)
        end
        eventArgs.handled = true
        return
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Skip if already handled (Cure III/IV)
    if eventArgs.handled then
        return
    end

    -- ==========================================================================
    -- HEALING MAGIC (Other Cure spells)
    -- ==========================================================================
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell,
            target_func = function(sp)
                return sp.target.type == 'SELF' and 'Self' or 'Other'
            end
        })
        return
    end

    -- ==========================================================================
    -- ENMITY SPELLS (Flash, Enlight)
    -- ==========================================================================
    if spell.name == 'Flash' then
        MidcastManager.select_set({
            skill = 'Flash',
            spell = spell
        })
        return
    end

    if spell.name == 'Enlight' or spell.name == 'Enlight II' then
        MidcastManager.select_set({
            skill = 'Enmity',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- ENHANCING MAGIC
    -- ==========================================================================
    if spell.skill == 'Enhancing Magic' then
        -- Phalanx: RUN always uses SIRD (tank priority: prevent interruption)
        if spell.name == 'Phalanx' then
            MidcastManager.select_set({
                skill = 'Enhancing Magic',
                spell = spell
            })
            return
        end

        -- Other Enhancing Magic (database-driven spell_family routing)
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })
        return
    end

    -- ==========================================================================
    -- DIVINE MAGIC
    -- ==========================================================================
    if spell.skill == 'Divine Magic' then
        MidcastManager.select_set({
            skill = 'Divine Magic',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- BLUE MAGIC (RUN/BLU SUBJOB)
    -- ==========================================================================
    if spell.skill == 'Blue Magic' then
        -- All Blue Magic spells use the same set (no distinction)
        MidcastManager.select_set({
            skill = 'Blue Magic',
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

local RUN_MIDCAST = {}
RUN_MIDCAST.job_midcast = job_midcast
RUN_MIDCAST.job_post_midcast = job_post_midcast

return RUN_MIDCAST
