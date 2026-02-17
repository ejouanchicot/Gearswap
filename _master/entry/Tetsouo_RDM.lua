---============================================================================
--- FFXI GearSwap Configuration - Red Mage (RDM) - Modular Architecture
---============================================================================
--- Advanced Red Mage job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Tetsouo_RDM.lua
--- @author Tetsouo
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-12
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Features:
---   - Modular architecture with specialized function modules
---   - Fast Cast optimization (cap 80%)
---   - Convert HP/MP management
---   - Chainspell burst mode support
---   - Enspell weapon enhancement
---   - Dualwield support (NIN subjob)
---   - Hybrid white/black magic
---   - Light/Dark elemental spell management
---
--- Architecture Overview:
---   Main File (this) >> rdm_functions.lua >> Specialized Modules
---
--- Module Organization:
---   ├── functions/rdm_functions.lua    [Facade Loader]
---   ├── sets/rdm_sets.lua              [Equipment Sets]
---   └── functions/RDM_*.lua            [Specialized Modules]
---
--- Specialized Modules:
---   RDM_PRECAST | RDM_MIDCAST | RDM_AFTERCAST | RDM_STATUS | RDM_BUFFS
---   RDM_IDLE | RDM_ENGAGED | RDM_MACROBOOK | RDM_COMMANDS | RDM_LOCKSTYLE
---   RDM_MOVEMENT
---============================================================================
---============================================================================
-- INITIALIZATION
---============================================================================

-- Load lockstyle timing configuration
local lockstyle_config_success, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
if not lockstyle_config_success or not LockstyleConfig then
    -- Fallback defaults if config not found
    LockstyleConfig = {
        initial_load_delay = 8.0,
        job_change_delay = 8.0,
        cooldown = 15.0
    }
end

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'RDM')

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

    -- RDM-specific configs
    -- Note: RDM_TP_CONFIG.lua exports _G.RDMTPConfig automatically
    require('Tetsouo/config/rdm/RDM_TP_CONFIG')

    -- Load RDM Saboteur configuration
    local saboteur_config_success, RDMSaboteurConfig = pcall(require, 'Tetsouo/config/rdm/RDM_SABOTEUR_CONFIG')
    if saboteur_config_success and RDMSaboteurConfig then
        _G.RDMSaboteurConfig = RDMSaboteurConfig
    else
        -- Fallback if config not found
        _G.RDMSaboteurConfig = {
            auto_trigger_spells = {},
            wait_time = 2
        }
    end

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/rdm/functions/rdm_functions.lua')
    Profiler.mark('After rdm_functions')

    -- Register RDM lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_rdm_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("RDM", cancel_rdm_lockstyle_operations)
    end

    -- Note: Macro/lockstyle are handled by JobChangeManager on job changes
    -- Initial load will be handled by JobChangeManager after initialization

    Profiler.finish()
end

---============================================================================
-- JOB CHANGE HANDLING
---============================================================================

--- Handle sub job change events (called by Mote-Include)
--- Coordinates lockstyle, macros, keybinds, and UI reload via JobChangeManager
--- @param newSubjob string New subjob
--- @param oldSubjob string Old subjob
function job_sub_job_change(newSubjob, oldSubjob)
    -- Create/destroy Storm state based on SCH subjob (handled in RDM_STATES.lua)
    local RDMStates = require('Tetsouo/config/rdm/RDM_STATES')
    if RDMStates and RDMStates.configure_storm then
        local had_storm = state.Storm ~= nil
        RDMStates.configure_storm()
        local has_storm = state.Storm ~= nil

        -- Display messages only when state changes
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            if has_storm and not had_storm then
                MessageFormatter.show_info('[RDM] Storm spells enabled (SCH subjob)')
            elseif not has_storm and had_storm then
                MessageFormatter.show_info('[RDM] Storm spells disabled (no SCH subjob)')
            end
        end
    end

    -- Re-apply weapon locking after subjob change (CombatMode)
    if state.CombatMode and state.CombatMode.current == "On" then
        disable('main', 'sub', 'range')
    else
        enable('main', 'sub', 'range')
    end

    -- Let JobChangeManager handle the full reload sequence
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local main_job = player and player.main_job or "RDM"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end

---============================================================================
-- USER SETUP
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from RDM_STATES.lua)
    -- ==========================================================================

    local RDMStates = require('Tetsouo/config/rdm/RDM_STATES')
    RDMStates.configure()

    -- Note: Storm state is conditionally created in job_sub_job_change() for SCH subjob

    -- ==========================================================================
    -- INITIAL WEAPON LOCKING (CombatMode)
    -- ==========================================================================
    -- ==========================================================================
    -- WEAPON LOCK (Always executed after reload)
    -- ==========================================================================
    -- Apply weapon lock IMMEDIATELY if CombatMode is On at load
    if state.CombatMode and state.CombatMode.current == "On" then
        disable('main', 'sub', 'range')
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            MessageFormatter.show_info('[RDM] CombatMode: Weapons locked')
        end
    end

    -- ==========================================================================
    -- KEYBIND LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, 'Tetsouo/config/rdm/RDM_KEYBINDS')
    if success and keybinds then
        RDMKeybinds = keybinds
        RDMKeybinds.bind_all()
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("RDM", init_delay)
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
-- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include after state changes
--- Updates the UI to reflect current state values
function job_update(cmdParams, eventArgs)
    -- Handle Combat Mode weapon locking
    if state.CombatMode then
        if state.CombatMode.current == "On" then
            -- Lock weapon slots (main, sub, range only - ammo can still swap)
            disable('main', 'sub', 'range')
        else
            -- Unlock weapon slots
            enable('main', 'sub', 'range')
        end
    end

    -- Update UI when states change (F9, F10, etc.)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

function init_gear_sets()
    include('sets/rdm_sets.lua')
end

---============================================================================
-- CLEANUP
---============================================================================

function file_unload()
    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if RDMKeybinds and RDMKeybinds.unbind_all then
        RDMKeybinds.unbind_all()
    end
end
