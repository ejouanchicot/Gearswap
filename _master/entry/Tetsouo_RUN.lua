---============================================================================
--- FFXI GearSwap Configuration - Rune Fencer (RUN) - Modular Architecture
---============================================================================
--- Main coordinator for Rune Fencer job configuration.
--- Delegates all specialized logic to dedicated modules for maximum maintainability.
---
--- Features:
---   • Modular architecture (12 hooks + 4 logic modules)
---   • Tank/DD hybrid gear automation (Tank/DD/PDT/MDT modes)
---   • Ward spell rotation support (Vallation, Valiance, Pflug)
---   • Rune buff tracking (3-rune rotation management)
---   • Gambit/Rayke rune consumption logic
---   • Dark Magic optimization (Drain, Aspir, Stun)
---   • JobChangeManager integration (anti-collision)
---   • UI + Keybind system
---
--- Architecture:
---   Main File >> run_functions.lua (façade) >> 11 Hooks + 4 Logic Modules
---
--- Modules:
---   • 11 Hooks: PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS, BUFFS,
---               COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK
---   • 4 Logic: ward_manager, rune_buff_tracker, gambit_manager, set_builder
---
--- @file    Tetsouo_RUN.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-11-02
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================
---============================================================================
--- INITIALIZATION
---============================================================================

--- Load global configurations with fallbacks
local _, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
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
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'RUN')

-- Load region configuration (must load before message system for color codes)
local region_success, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

function get_sets()
    -- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
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

    -- RUN-specific configs (DISABLED FOR TESTING)
    --_G.RUNTPCONFIG = require('Tetsouo/config/run/RUN_TP_CONFIG')
    --_G.WardConfig = require('Tetsouo/config/run/RUN_WARD_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/run/functions/run_functions.lua')
    Profiler.mark('After run_functions')

    -- Register RUN lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_run_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("RUN", cancel_run_lockstyle_operations)
    end

    -- Note: Macro/lockstyle are handled by JobChangeManager on job changes
    -- Initial load will be handled by JobChangeManager after initialization

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
function job_sub_job_change(newSubjob, oldSubjob)
    -- Re-initialize JobChangeManager with RUN-specific functions
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if RUNKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = RUNKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Let JobChangeManager handle the full reload sequence
        local main_job = player and player.main_job or "RUN"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end

---============================================================================
--- SETUP FUNCTIONS
---============================================================================

function user_setup()
    -- RUN-specific states (defines all states including HybridMode)
    local RUNStates = require('Tetsouo/config/run/RUN_STATES')
    RUNStates.configure()

    -- ==========================================================================
    -- KEYBINDS LOADING (Always executed after reload, deferred)
    -- ==========================================================================
    coroutine.schedule(function()
        local success, keybinds = pcall(require, 'Tetsouo/config/run/RUN_KEYBINDS')
        if success and keybinds then
            RUNKeybinds = keybinds
            RUNKeybinds.bind_all()
        end
    end, 0.5)

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload, deferred)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.smart_init("RUN", UIConfig.init_delay)
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
    -- WARP SYSTEM INITIALIZATION (REMOVED - Redundant with full GearSwap reload)
    -- ==========================================================================
    -- WarpInit previously handled equipment locking during warp/teleport actions.
    -- With JobChangeManager's full reload strategy (windower.send_command('lua reload gearswap')),
    -- warp protection is no longer necessary as any state is cleared on reload.
    -- Removed for consistency across all 15 jobs (no job uses WarpInit anymore).
    --
    -- local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')
    -- if warp_success and WarpInit then
    --     WarpInit.init()
    -- end
end

---============================================================================
--- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include after state changes
--- Updates the UI to reflect current state values
function job_update(cmdParams, eventArgs)
    -- Update UI when states change (F9, F10, etc.)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

function init_gear_sets()
    include('sets/run_sets.lua')
end

function file_unload()
    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if RUNKeybinds and RUNKeybinds.unbind_all then
        RUNKeybinds.unbind_all()
    end
end
