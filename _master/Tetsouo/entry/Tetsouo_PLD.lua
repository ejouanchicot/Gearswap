---============================================================================
--- FFXI GearSwap Configuration - Paladin (PLD) - Modular Architecture
---============================================================================
--- Main coordinator for Paladin job configuration.
--- Delegates all specialized logic to dedicated modules for maximum maintainability.
---
--- Features:
---   • Modular architecture (11 hooks + 5 logic modules)
---   • Tank-focused gear automation (PDT/MDT modes)
---   • Blu Magic spell rotation support
---   • Rune management (RUN subjob)
---   • Cure set automation with potency optimization
---   • AOE spell management
---   • JobChangeManager integration (anti-collision)
---   • UI + Keybind system
---
--- Architecture:
---   Main File >> pld_functions.lua (facade) >> 11 Hooks + 5 Logic Modules
---
--- Modules:
---   • 11 Hooks: PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS, BUFFS,
---               COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK
---   • 5 Logic: aoe_manager, cure_set_builder, enmity_override, rune_manager, set_builder
---
--- @file    Tetsouo/Tetsouo_PLD.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-03
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================
---============================================================================
--- INITIALIZATION
---============================================================================

--- Load global configurations with fallbacks
local LockstyleConfig_ok, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
if not LockstyleConfig_ok then LockstyleConfig = nil end
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,
    job_change_delay = 8.0,
    cooldown = 15.0
}

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'PLD')

-- Load region configuration. message_colors captures _G.RegionConfig once,
-- when it is first required - ConfigLoader above already required it, so
-- this assignment comes too late for the region warning color.
local region_success, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

--- GearSwap entry hook: loads Mote-Include, the shared systems and the PLD modules.
--- Called by GearSwap each time this job file is loaded.
--- @return void
function get_sets()
    -- PERFORMANCE PROFILING (enable with: //gs c perf start)
    local Profiler = require('shared/utils/debug/performance_profiler')
    Profiler.start('get_sets')

    mote_include_version = 2
    include('Mote-Include.lua')
    Profiler.mark('After Mote-Include')
    include('../shared/utils/core/INIT_SYSTEMS.lua')
    Profiler.mark('After INIT_SYSTEMS')

    -- ============================================
    -- UNIVERSAL DATA ACCESS (All Spells/Abilities/Weaponskills)
    -- ============================================
    require('shared/utils/data/data_loader')
    Profiler.mark('After data_loader')

    -- ============================================
    -- UNIVERSAL SPELL MESSAGES (All Jobs/Subjobs)
    -- ============================================
    include('../shared/hooks/init_spell_messages.lua')
    Profiler.mark('After spell messages')

    -- ============================================
    -- UNIVERSAL ABILITY MESSAGES (All Jobs/Subjobs)
    -- ============================================
    include('../shared/hooks/init_ability_messages.lua')
    Profiler.mark('After ability messages')

    -- ============================================
    -- UNIVERSAL WEAPONSKILL MESSAGES (All Jobs/Subjobs)
    -- ============================================
    include('../shared/hooks/init_ws_messages.lua')
    Profiler.mark('After WS messages')

    _G.LockstyleConfig = LockstyleConfig
    _G.RECAST_CONFIG = require('Tetsouo/config/RECAST_CONFIG')

    -- PLD-specific configs
    -- Note: PLD_TP_CONFIG.lua exports _G.PLDTPConfig automatically
    require('Tetsouo/config/pld/PLD_TP_CONFIG')
    _G.BluMagicConfig = require('Tetsouo/config/pld/PLD_BLU_MAGIC')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/pld/functions/pld_functions.lua')
    Profiler.mark('After pld_functions')

    -- Refresh the slots now set_builder can be loaded: PLDStates created them
    -- during user_setup (the HUD needs them by then) with whatever weapon it
    -- could resolve that early.
    if _G.pld_rebuild_ws_slots then
        _G.pld_rebuild_ws_slots()
    end
    -- Keybinds loaded via require() in user_setup() for better control

    -- Register PLD lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_pld_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("PLD", cancel_pld_lockstyle_operations)
    end

    -- Initial macrobook/lockstyle are triggered from user_setup();
    -- subjob changes go through JobChangeManager (job_sub_job_change).

    Profiler.finish()
end

---============================================================================
--- JOB CHANGE HANDLING
---============================================================================

--- Handle subjob change events
--- Coordinates lockstyle, macros, keybinds, and UI reload via JobChangeManager.
---
--- @param newSubjob string New subjob code
--- @param oldSubjob string Old subjob code
--- @return void
function job_sub_job_change(newSubjob, oldSubjob)
    -- Re-initialize JobChangeManager with PLD-specific functions
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if PLDKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = PLDKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Let JobChangeManager handle the full reload sequence
        local main_job = player and player.main_job or "PLD"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX IPC fires from user_setup() after the reload (covers main + subjob)
end

---============================================================================
--- SETUP FUNCTIONS
---============================================================================

--- Configure states, keybinds, UI and the initial macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from PLD_STATES.lua)
    -- ==========================================================================

    _G.PLDWSConfig = require('Tetsouo/config/pld/PLD_WS_CONFIG')

    local PLDStates = require('Tetsouo/config/pld/PLD_STATES')
    PLDStates.configure()

    -- Fill state.WS1/WS2 for the weapon in hand. Reached on a subjob change,
    -- which re-runs user_setup() in a sandbox where the job modules are
    -- already loaded; on a cold load the function does not exist yet and
    -- get_sets() does it instead, right after including them.
    if _G.pld_rebuild_ws_slots then
        _G.pld_rebuild_ws_slots()
    end

    -- configure() has just put HybridMode back to its default, so any ammo
    -- lock still held by the sandbox belongs to a stance that is no longer
    -- selected. GearSwap slot locks outlive the job file; nothing else would
    -- ever give the slot back.
    local al_ok, AmpullaLock = pcall(require, 'shared/utils/equipment/ampulla_lock')
    if al_ok and AmpullaLock then
        AmpullaLock.apply(state.HybridMode and state.HybridMode.value)
    end

    -- ==========================================================================
    -- KEYBINDS LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, 'Tetsouo/config/pld/PLD_KEYBINDS')
    if success and keybinds then
        PLDKeybinds = keybinds
        PLDKeybinds.bind_all()
    else
        -- Loudly, because the failure is otherwise invisible: the job loads,
        -- //gs c commands answer, and only the keys are dead. Chased for a
        -- long time before it was worth a line.
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_error('[PLD] Keybinds failed to load: ' .. tostring(keybinds))
        end
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("PLD", init_delay)
    end

    -- ==========================================================================
    -- JOB CHANGE MANAGER INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        -- Initialize with current job state
        JobChangeManager.initialize()

        -- Trigger initial macrobook/lockstyle with delay
        if player and select_default_macro_book and select_default_lockstyle then
            select_default_macro_book()
            coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
        end
    end

    -- ==========================================================================
    -- DUALBOX IPC (covers main job change - job_sub_job_change is subjob-only)
    -- The require() triggers dualbox_manager auto-init which schedules the
    -- correct IPC call once per gs reload (request_alt_job for MAIN role,
    -- send_job_update for ALT role). Do NOT call them explicitly here.
    -- ==========================================================================
    pcall(require, 'shared/utils/dualbox/dualbox_manager')
end

---============================================================================
--- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include after state changes
--- Updates the UI to reflect current state values
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    -- DEBUG: Trace gs c update reception
    if _G.UPDATE_DEBUG then
        local now = os.clock()
        local delta = _G._update_sent_time and (now - _G._update_sent_time) or 0
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_debug('PLD', string.format('[UPDATE_DEBUG] 2. job_update RECEIVED | t=%.3f | delta=%.3fms', now, delta * 1000))
    end

    -- Refresh the HUD (every cycle/set/toggle command and gs c update land here)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        if _G.UPDATE_DEBUG then
            local before = os.clock()
            KeybindUI.update()
            local after = os.clock()
            local MessageFormatter = require('shared/utils/messages/message_formatter')
            MessageFormatter.show_debug('PLD', string.format('[UPDATE_DEBUG] 3. UI.update DONE | took=%.3fms', (after - before) * 1000))
        else
            KeybindUI.update()
        end
    end
end

--- Load the PLD equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include('sets/pld/pld_sets.lua')
end

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Releases the Ampulla ammo lock, cancels pending job-change operations
--- and unbinds the job keys.
--- @return void
function file_unload()
    -- Give the ammo slot back before the next job file loads: a GearSwap slot
    -- lock survives a job change, and nothing on the other side knows it.
    -- First, before anything else in here can throw: GearSwap wraps the whole
    -- of file_unload in a single pcall (engine flow.lua:339-348), so an error
    -- in the cleanup below would skip this and leak the slot lock into the
    -- next job, which has no way to know it exists.
    local al_ok, AmpullaLock = pcall(require, 'shared/utils/equipment/ampulla_lock')
    if al_ok and AmpullaLock then
        AmpullaLock.release()
    end

    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if PLDKeybinds and PLDKeybinds.unbind_all then
        PLDKeybinds.unbind_all()
    end
end
