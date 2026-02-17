---============================================================================
--- FFXI GearSwap Configuration - Warrior (WAR) - Modular Architecture
---============================================================================
--- Advanced Warrior job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file    Tetsouo_WAR.lua
--- @author  Tetsouo
--- @version 2.1.0 - States Externalized
--- @date    Created: 2025-09-29 | Updated: 2025-10-14
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Features:
---   • Modular architecture with specialized function modules
---   • Externalized configuration (states, keybinds, lockstyle, macros)
---   • Comprehensive equipment set organization
---   • Clean separation of concerns
---
--- Architecture Overview:
---   Main File (this) >> war_functions.lua >> Specialized Modules
---
--- Module Organization:
---   ├── functions/war_functions.lua    [Facade Loader]
---   ├── sets/war_sets.lua             [Equipment Sets]
---   ├── functions/WAR_*.lua           [11 Hook Modules]
---   └── config/war/*.lua              [Configuration Files]
---============================================================================
---============================================================================
--- INITIALIZATION & CONFIGURATION LOADING
---============================================================================

-- Load global configurations with fallbacks
local _, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,
    job_change_delay = 8.0,
    cooldown = 15.0
}

-- Load region configuration (must load before message system for color codes)
local _, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if RegionConfig then
    _G.RegionConfig = RegionConfig
end

-- Load core modules (cached for all functions)
local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'WAR')

---============================================================================
--- GEARSWAP HOOKS - INITIALIZATION
---============================================================================

--- Initialize GearSwap and load all WAR modules
--- Called once when GearSwap loads this job file
--- @return void

function get_sets()
    -- ═══════════════════════════════════════════════════════════════════
    -- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
    -- ═══════════════════════════════════════════════════════════════════
    local Profiler = require('shared/utils/debug/performance_profiler')
    Profiler.start('get_sets')
    -- ═══════════════════════════════════════════════════════════════════

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

    -- ============================================
    -- LOAD CONFIGS INTO GLOBAL NAMESPACE
    -- ============================================
    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig
    _G.RECAST_CONFIG = require('Tetsouo/config/RECAST_CONFIG')

    -- WAR-specific configs
    _G.WARTPConfig = require('Tetsouo/config/war/WAR_TP_CONFIG')
    Profiler.mark('After configs')

    -- Cancel pending operations from previous job
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/war/functions/war_functions.lua')
    Profiler.mark('After war_functions')

    -- Register WAR lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_war_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("WAR", cancel_war_lockstyle_operations)
    end

    -- ═══════════════════════════════════════════════════════════════════
    Profiler.finish()
    -- ═══════════════════════════════════════════════════════════════════
end

--- Load WAR equipment sets from external file
--- Called by Mote-Include during initialization
--- @return void
function init_gear_sets()
    include('sets/war_sets.lua')
end

---============================================================================
--- GEARSWAP HOOKS - JOB CHANGE HANDLING
---============================================================================

--- Handle sub job change events (called by Mote-Include)
--- Coordinates lockstyle, macros, keybinds, and UI reload
--- @param newSubjob string New subjob (e.g., "SAM", "NIN")
--- @param oldSubjob string Old subjob
--- @return void
function job_sub_job_change(newSubjob, oldSubjob)
    if not jcm_success or not JobChangeManager then
        return
    end

    -- Re-register WAR modules (ensures correct functions when switching back to WAR)
    if WARKeybinds and ui_success and KeybindUI then
        JobChangeManager.initialize({
            keybinds = WARKeybinds,
            ui = KeybindUI,
            lockstyle = select_default_lockstyle,
            macrobook = select_default_macro_book
        })
    end

    -- Let JobChangeManager handle the full reload sequence
    local main_job = player and player.main_job or "WAR"
    JobChangeManager.on_job_change(main_job, newSubjob)

    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end

---============================================================================
--- GEARSWAP HOOKS - USER SETUP
---============================================================================

--- Configure job-specific states, keybinds, UI, and initial setup
--- Called by Mote-Include after get_sets() completes
--- @return void
function user_setup()
    -- ==========================================================================
    -- STATES CONFIGURATION
    -- ==========================================================================
    local WARStates = require('Tetsouo/config/war/WAR_STATES')
    WARStates.configure()

    -- ==========================================================================
    -- KEYBINDS LOADING (Always executed after reload)
    -- ==========================================================================
    local kb_success, keybinds = pcall(require, 'Tetsouo/config/war/WAR_KEYBINDS')
    if kb_success and keybinds then
        WARKeybinds = keybinds
        WARKeybinds.bind_all()
    else
        show_keybind_error()
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    if ui_success and KeybindUI then
        KeybindUI.smart_init("WAR", UIConfig.init_delay)
    end

    -- ==========================================================================
    -- JOB CHANGE MANAGER INITIALIZATION (Always executed after reload)
    -- ==========================================================================
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
--- GEARSWAP HOOKS - CLEANUP
---============================================================================

--- Cleanup function called when GearSwap unloads this job file
--- Cancels pending operations and unbinds resources
--- Called by Mote-Include after state changes
--- Updates the UI to reflect current state values
function job_update(cmdParams, eventArgs)
    -- Update UI when states change (F9, F10, etc.)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

--- @return void
function file_unload()
    -- Cancel pending job change operations (debounce timer + lockstyles)
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if WARKeybinds and WARKeybinds.unbind_all then
        WARKeybinds.unbind_all()
    end
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Display keybind loading error message
--- @return void
function show_keybind_error()
    local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if msg_success and MessageFormatter then
        MessageFormatter.show_error("[WAR] Failed to load keybinds")
    end
    -- Silent fallback - MessageFormatter should always be available
end
