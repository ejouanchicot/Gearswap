---============================================================================
--- FFXI GearSwap Configuration - Bard (BRD) - Modular Architecture
---============================================================================
--- Advanced Bard job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Typioni_BRD.lua
--- @author Typioni
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
---   Main File (this) → brd_functions.lua → Specialized Modules
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
-- Track if this is initial setup (prevents double init on sub job change)
local is_initial_setup = true

-- Load lockstyle timing configuration
local lockstyle_config_success, LockstyleConfig = pcall(require, 'Typioni/config/LOCKSTYLE_CONFIG')
if not lockstyle_config_success or not LockstyleConfig then
    -- Fallback defaults if config not found
    LockstyleConfig = {
        initial_load_delay = 8.0,
        job_change_delay = 8.0,
        cooldown = 15.0
    }
end

-- Load UI configuration
local ui_config_success, UIConfig = pcall(require, 'Typioni/config/UI_CONFIG')
if not ui_config_success or not UIConfig then
    -- Fallback defaults if config not found
    UIConfig = {
        init_delay = 5.0
    }
end

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
local char_name = 'Typioni'  -- Hardcoded (player doesn't exist at module load time)
local config_path = windower.windower_path .. 'addons/GearSwap/data/' .. char_name .. '/config/UI_CONFIG.lua'

local success, UIConfig = pcall(function()
    return dofile(config_path)
end)

if not success or not UIConfig then
    UIConfig = {
        init_delay = 5.0,
        default_position = { x = 1600, y = 300 },
        enabled = true,
        show_header = true,
        show_legend = true,
        show_column_headers = true,
        show_footer = true
    }
    add_to_chat(167, "[BRD] UIConfig load failed, using defaults")
else
end

-- Put in _G immediately (before get_sets)
_G.UIConfig = UIConfig
_G.ui_display_config = {
    show_header = (UIConfig.show_header == nil) and true or UIConfig.show_header,
    show_legend = (UIConfig.show_legend == nil) and true or UIConfig.show_legend,
    show_column_headers = (UIConfig.show_column_headers == nil) and true or UIConfig.show_column_headers,
    show_footer = (UIConfig.show_footer == nil) and true or UIConfig.show_footer,
    enabled = (UIConfig.enabled == nil) and true or UIConfig.enabled
}

function get_sets()
    mote_include_version = 2

    -- BRD-specific configs (BEFORE Mote-Include so they're available in user_setup)
    _G.LockstyleConfig = LockstyleConfig
    _G.RECAST_CONFIG = require('Typioni/config/RECAST_CONFIG')
    _G.BRDTPConfig = require('Typioni/config/brd/BRD_TP_CONFIG')
    _G.BRDSongConfig = require('Typioni/config/brd/BRD_SONG_CONFIG')
    _G.BRDTimingConfig = require('Typioni/config/brd/BRD_TIMING_CONFIG')

    -- Load BRD functions BEFORE Mote-Include (so _G.update_brd_song_slots exists in user_setup)
    include('../shared/jobs/brd/functions/brd_functions.lua')

    -- Now load Mote-Include (which calls user_setup and creates 'state')
    include('Mote-Include.lua')

    -- Load AutoMove AFTER Mote-Include (needs 'state' to exist)
    include('../shared/utils/movement/automove.lua')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Register BRD lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_brd_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("BRD", cancel_brd_lockstyle_operations)
    end

    -- Note: Macro/lockstyle are handled by JobChangeManager on job changes
    -- Initial load will be handled by JobChangeManager after initialization
end

---============================================================================
-- JOB CHANGE HANDLING
---============================================================================

--- Handle sub job change events (called by Mote-Include)
--- Coordinates lockstyle, macros, keybinds, and UI reload via JobChangeManager
--- @param newSubjob string New subjob
--- @param oldSubjob string Old subjob
function job_sub_job_change(newSubjob, oldSubjob)
    -- Note: Mote-Include already called user_setup() before this

    -- Re-initialize JobChangeManager with BRD-specific functions
    -- This ensures correct functions are used when switching back to BRD
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        -- Nil check: Only initialize if all required functions are loaded
        if BRDKeybinds and select_default_lockstyle and select_default_macro_book then
            local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
            local ui_ref = ui_success and KeybindUI or nil

            JobChangeManager.initialize({
                keybinds = BRDKeybinds,
                ui = ui_ref,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })

            -- Trigger job change sequence (handles lockstyle, macros, keybinds, UI)
            local main_job = player and player.main_job or "BRD"
            JobChangeManager.on_job_change(main_job, newSubjob)
        end
    end
end

---============================================================================
-- USER SETUP
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from BRD_STATES.lua)
    -- ==========================================================================

    local BRDStates = require('Typioni/config/brd/BRD_STATES')
    BRDStates.configure()

    if is_initial_setup then
        -- KEYBIND LOADING
        local success, keybinds = pcall(require, 'Typioni/config/brd/BRD_KEYBINDS')
        if success and keybinds then
            BRDKeybinds = keybinds
            BRDKeybinds.bind_all()
        else
            add_to_chat(167, '[BRD] Warning: Failed to load keybinds')
        end

        -- UI INITIALIZATION
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            KeybindUI.smart_init("BRD", UIConfig.init_delay)
        else
            add_to_chat(167, '[BRD] Warning: Failed to load UI')
        end

        -- JOB CHANGE MANAGER INITIALIZATION
        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            local ui_ref = ui_success and KeybindUI or nil
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = BRDKeybinds,
                    ui = ui_ref,
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
                            keybinds = BRDKeybinds,
                            ui = ui_ref,
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

    -- Initialize song slots AFTER UI is built (runs on every reload, not just initial setup)
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
-- GEAR SET INITIALIZATION
---============================================================================

function init_gear_sets()
    include('sets/brd_sets.lua')
end

---============================================================================
-- CLEANUP
---============================================================================

function file_unload()
    -- Cancel all pending operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds
    if BRDKeybinds then
        BRDKeybinds.unbind_all()
    end

    -- Destroy UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
