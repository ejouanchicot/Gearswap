---============================================================================
--- FFXI GearSwap Configuration - Warrior (WAR) - Modular Architecture
---============================================================================
--- Advanced Warrior job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file    Morphetrix_WAR.lua
--- @author  Morphetrix
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
---   Main File (this) → war_functions.lua → Specialized Modules
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
-- State management
local is_initial_setup = true

-- Load global configurations with fallbacks
local _, LockstyleConfig = pcall(require, 'Morphetrix/config/LOCKSTYLE_CONFIG')
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,
    job_change_delay = 8.0,
    cooldown = 15.0
}

local _, UIConfig = pcall(require, 'Morphetrix/config/UI_CONFIG')
UIConfig = UIConfig or {
    init_delay = 5.0
}

-- Load region configuration (must load before message system for color codes)
local _, RegionConfig = pcall(require, 'Morphetrix/config/REGION_CONFIG')
if RegionConfig then
    _G.RegionConfig = RegionConfig
end

-- Load core modules (cached for all functions)
local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')

---============================================================================
--- GEARSWAP HOOKS - INITIALIZATION
---============================================================================

--- Initialize GearSwap and load all WAR modules
--- Called once when GearSwap loads this job file
--- @return void
-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Morphetrix', 'WAR')

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    include('../shared/utils/core/INIT_SYSTEMS.lua')

    -- ============================================
    -- UNIVERSAL DATA ACCESS (All Spells/Abilities/Weaponskills)
    -- ============================================
    require('shared/utils/data/data_loader')

    -- ============================================
    -- UNIVERSAL SPELL MESSAGES (All Jobs/Subjobs)
    -- ============================================
    include('../shared/hooks/init_spell_messages.lua')

    -- ============================================
    -- UNIVERSAL ABILITY MESSAGES (All Jobs/Subjobs)
    -- ============================================
    include('../shared/hooks/init_ability_messages.lua')

    -- ============================================
    -- LOAD CONFIGS INTO GLOBAL NAMESPACE
    -- ============================================
    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig
    _G.RECAST_CONFIG = require('Morphetrix/config/RECAST_CONFIG')


    -- WAR-specific configs
    _G.WARTPConfig = require('Morphetrix/config/war/WAR_TP_CONFIG')

    -- Cancel pending operations from previous job
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/war/functions/war_functions.lua')

    -- Register WAR lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_war_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("WAR", cancel_war_lockstyle_operations)
    end
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
    local WARStates = require('Morphetrix/config/war/WAR_STATES')
    WARStates.configure()

    -- Skip additional initialization on subjob change (JobChangeManager handles it)
    if not is_initial_setup then
        return
    end

    -- ==========================================================================
    -- KEYBINDS LOADING
    -- ==========================================================================
    local kb_success, keybinds = pcall(require, 'Morphetrix/config/war/WAR_KEYBINDS')
    if kb_success and keybinds then
        WARKeybinds = keybinds
        WARKeybinds.bind_all()
    else
        show_keybind_error()
    end

    -- ==========================================================================
    -- UI INITIALIZATION
    -- ==========================================================================
    if ui_success and KeybindUI then
        KeybindUI.smart_init("WAR", UIConfig.init_delay)
    end

    -- ==========================================================================
    -- JOB CHANGE MANAGER INITIALIZATION
    -- ==========================================================================
    if jcm_success and JobChangeManager then
        -- Check if functions are loaded (they should be after get_sets completes)
        if select_default_lockstyle and select_default_macro_book then
            JobChangeManager.initialize({
                keybinds = WARKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })

            -- Trigger initial macrobook/lockstyle with delay
            if player then
                select_default_macro_book()
                coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
            end
        else
            -- Functions not loaded yet, schedule for later
            coroutine.schedule(function()
                if select_default_lockstyle and select_default_macro_book then
                    JobChangeManager.initialize({
                        keybinds = WARKeybinds,
                        ui = KeybindUI,
                        lockstyle = select_default_lockstyle,
                        macrobook = select_default_macro_book
                    })
                    if player then
                        select_default_macro_book()
                        coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
                    end
                end
            end, 0.2)
        end
    end

    is_initial_setup = false
end

---============================================================================
--- GEARSWAP HOOKS - CLEANUP
---============================================================================

--- Cleanup function called when GearSwap unloads this job file
--- Cancels pending operations and unbinds resources
--- @return void
function file_unload()
    -- Cancel pending job change operations
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind keybinds
    if WARKeybinds then
        WARKeybinds.unbind_all()
    end

    -- Destroy UI
    if ui_success and KeybindUI then
        KeybindUI.destroy()
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
        MessageFormatter.show_error("Failed to load WAR_KEYBINDS")
    else
        add_to_chat(167, "[WAR] Error: Failed to load keybinds")
    end
end
