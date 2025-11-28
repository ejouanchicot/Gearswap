---============================================================================
--- FFXI GearSwap Configuration - White Mage (WHM) - Modular Architecture
---============================================================================
--- Main coordinator for White Mage job configuration.
--- Delegates all specialized logic to dedicated modules for maximum maintainability.
---
--- Features:
---   • Modular architecture (12 hooks + optional logic modules)
---   • Healer-focused gear automation (Cure optimization)
---   • Afflatus Solace/Misery support
---   • Enhancing magic duration optimization
---   • Divine/Enfeebling magic support
---   • JobChangeManager integration (anti-collision)
---   • UI + Keybind system
---
--- Architecture:
---   Main File >> whm_functions.lua (façade) >> 12 Hooks + Optional Logic Modules
---
--- Modules:
---   • 12 Hooks: PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS, BUFFS,
---               COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK, SETUP
---   • Optional Logic: cure_optimizer, bar_element_manager (if needed)
---
--- @file    Tetsouo_WHM.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-21
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
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'WHM')

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

    -- WHM-specific configs
    _G.WHMTPConfig = require('Tetsouo/config/whm/WHM_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/whm/functions/whm_functions.lua')
    Profiler.mark('After whm_functions')
    -- Keybinds loaded via require() in user_setup() for better control

    -- Register WHM lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_whm_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("WHM", cancel_whm_lockstyle_operations)
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
    -- Re-initialize JobChangeManager with WHM-specific functions
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if WHMKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = WHMKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Let JobChangeManager handle the full reload sequence
        local main_job = player and player.main_job or "WHM"
        JobChangeManager.on_job_change(main_job, newSubjob)
    
    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end
end

---============================================================================
--- SETUP FUNCTIONS
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from WHM_STATES.lua)
    -- ==========================================================================

    local WHMStates = require('Tetsouo/config/whm/WHM_STATES')
    WHMStates.configure()

    -- ==========================================================================
    -- KEYBINDS LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, 'Tetsouo/config/whm/WHM_KEYBINDS')
    if success and keybinds then
        WHMKeybinds = keybinds
        WHMKeybinds.bind_all()
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("WHM", init_delay)
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
    include('sets/whm_sets.lua')
end

function file_unload()
    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Note: Keybinds and UI are automatically cleaned by GearSwap reload
    -- No need to manually unbind/destroy (reload does it)
end
