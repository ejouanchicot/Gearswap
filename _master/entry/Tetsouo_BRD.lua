---============================================================================
--- FFXI GearSwap Configuration - Bard (BRD) - Modular Architecture
---============================================================================
--- Advanced Bard job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Tetsouo_BRD.lua
--- @author Tetsouo
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-13
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Features:
---   - Modular architecture with specialized function modules
---   - Song rotation management (4+ songs)
---   - Instrument swapping (Gjallarhorn, Daurdabla, Marsyas)
---   - Song duration tracking
---   - Pianissimo distance songs
---   - Party buff monitoring
---   - Honor March / Victory March optimization
---   - Madrigal, Minuet, Prelude support
---
--- Architecture Overview:
---   Main File (this) >> brd_functions.lua >> Specialized Modules
---
--- Module Organization:
---   ├── functions/brd_functions.lua    [Facade Loader]
---   ├── sets/brd_sets.lua              [Equipment Sets]
---   └── functions/BRD_*.lua            [Specialized Modules]
---
--- Specialized Modules:
---   BRD_PRECAST | BRD_MIDCAST | BRD_AFTERCAST | BRD_STATUS | BRD_BUFFS
---   BRD_IDLE | BRD_ENGAGED | BRD_MACROBOOK | BRD_COMMANDS | BRD_LOCKSTYLE
---   BRD_MOVEMENT
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
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'BRD')

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

    -- BRD-specific configs (BEFORE Mote-Include so they're available in user_setup)
    _G.LockstyleConfig = LockstyleConfig
    _G.RECAST_CONFIG = require('Tetsouo/config/RECAST_CONFIG')
    _G.BRDTPConfig = require('Tetsouo/config/brd/BRD_TP_CONFIG')
    _G.BRDSongConfig = require('Tetsouo/config/brd/BRD_SONG_CONFIG')
    _G.BRDTimingConfig = require('Tetsouo/config/brd/BRD_TIMING_CONFIG')

    -- Load Mote-Include first (calls user_setup and creates 'state')
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

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions
    include('../shared/jobs/brd/functions/brd_functions.lua')
    Profiler.mark('After brd_functions')

    -- Register BRD lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_brd_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("BRD", cancel_brd_lockstyle_operations)
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
    -- Let JobChangeManager handle the full reload sequence
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local main_job = player and player.main_job or "BRD"
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
    -- STATE DEFINITIONS (Loaded from BRD_STATES.lua)
    -- ==========================================================================

    local BRDStates = require('Tetsouo/config/brd/BRD_STATES')
    BRDStates.configure()

    -- ==========================================================================
    -- KEYBIND LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, 'Tetsouo/config/brd/BRD_KEYBINDS')
    if success and keybinds then
        BRDKeybinds = keybinds
        BRDKeybinds.bind_all()
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("BRD", init_delay)
    end

    -- ==========================================================================
    -- JOB CHANGE MANAGER INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        -- Initialize with current job state
        JobChangeManager.initialize()

        -- Trigger initial macrobook/lockstyle with delay
        -- Use schedule to ensure player is loaded before calling
        coroutine.schedule(function()
            if player and select_default_macro_book and select_default_lockstyle then
                select_default_macro_book()
                coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
            end
        end, 0.2)  -- Small delay to ensure player is ready
    end

    -- ==========================================================================
    -- SONG SLOTS INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    coroutine.schedule(function()
        if _G.update_brd_song_slots then
            _G.update_brd_song_slots()
        end
    end, UIConfig.init_delay + 0.5)
end

---============================================================================
-- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include after state changes
--- Updates the UI to reflect current state values
function job_update(cmdParams, eventArgs)
    -- Update song slots when SongMode changes (displays pack configuration)
    if _G.update_brd_song_slots then
        _G.update_brd_song_slots()
    end

    -- UI updates handled by UI_MANAGER (fixed stack overflow via state check)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

---============================================================================
-- COMBAT FORM UPDATE (FORCE GEAR UPDATE AFTER STATE CHANGE)
---============================================================================

--- Called by Mote-Include after state changes to force gear re-equip
--- This is CRITICAL for IdleMode/EngagedMode changes to take effect
function update_combat_form()
    -- Force gear update based on current player status
    if not player then return end

    -- Call handle_equipping_gear to force proper set selection
    if player.status == 'Idle' then
        handle_equipping_gear(player.status)
    elseif player.status == 'Engaged' then
        handle_equipping_gear(player.status)
    end
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

function init_gear_sets()
    include('sets/brd_sets.lua')
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
    if BRDKeybinds and BRDKeybinds.unbind_all then
        BRDKeybinds.unbind_all()
    end
end
