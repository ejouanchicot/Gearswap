---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Midcast Module - Spell Skill Dispatcher
---  ═══════════════════════════════════════════════════════════════════════════
---   Routes spells to the appropriate handler in midcast_router.lua. The actual
---   gear logic (dummy songs, debuff songs, instrument lock, MidcastManager
---   subjob calls) lives in the router so this file stays small and focused
---   on orchestration.
---
---   Architecture:
---     BRD_MIDCAST (dispatcher) -> midcast_router.lua (handlers)
---                              -> MidcastManager (universal set selection)
---                              -> SongRotationManager (instrument detection)
---
---   @file    shared/jobs/brd/functions/BRD_MIDCAST.lua
---   @author  Tetsouo
---   @version 4.0 - Extracted handlers to logic/midcast_router.lua
---   @date    Created: 2025-10-13 | Refactored: 2026-05-09
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = nil
local MidcastRouter = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false
local BRDSpells = nil
local BRDSpells_success = false

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    -- Router (loads MidcastManager internally)
    local _, mr = pcall(require, 'shared/jobs/brd/functions/logic/midcast_router')
    MidcastRouter = mr

    -- MessageFormatter (passed to router via ctx)
    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    -- Expose SongRotationManager globally for MidcastManager.get_song_instrument()
    -- (used during Singing set selection inside MidcastManager.select_set)
    local _, srm = pcall(require, 'shared/jobs/brd/functions/logic/song_rotation_manager')
    if srm then _G.SongRotationManager = srm end

    -- ENHANCING_MAGIC_DATABASE for spell_family routing (Enhancing Magic subjob)
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    -- BRD_SPELL_DATABASE for song descriptions / elements
    BRDSpells_success, BRDSpells = pcall(require, 'shared/data/magic/BRD_SPELL_DATABASE')

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook (no BRD-specific PRE-midcast logic).
function job_midcast(spell, action, spellMap, eventArgs)
    -- Handled by MidcastRouter in job_post_midcast
end

--- Mote-Include customization hook (passthrough - kept for future use).
function job_customize_midcast_set(midcastSet, spell)
    return midcastSet
end

--- Post-midcast dispatcher: route spell to the appropriate router handler.
function job_post_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Build context passed to each handler
    local ctx = {
        debug_enabled      = _G.MidcastManagerDebugState == true,
        message_formatter  = MessageFormatter,
        brd_spells         = BRDSpells,
        brd_spells_loaded  = BRDSpells_success,
        enhancing_database = EnhancingSPELLS_success and EnhancingSPELLS
                             and EnhancingSPELLS.get_spell_family or nil,
    }

    -- Skill-based dispatch
    if spell.skill == 'Singing' then
        MidcastRouter.handle_singing(spell, ctx)
        return
    end

    if spell.skill == 'Healing Magic' then
        MidcastRouter.handle_healing(spell, ctx)
        return
    end

    if spell.skill == 'Enhancing Magic' then
        MidcastRouter.handle_enhancing(spell, ctx)
        return
    end

    if spell.skill == 'Enfeebling Magic' then
        MidcastRouter.handle_enfeebling(spell, ctx)
        return
    end

    if spell.skill == 'Elemental Magic' then
        MidcastRouter.handle_elemental(spell, ctx)
        return
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_customize_midcast_set = job_customize_midcast_set
_G.job_post_midcast = job_post_midcast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_midcast = job_midcast,
    job_customize_midcast_set = job_customize_midcast_set,
    job_post_midcast = job_post_midcast,
}
