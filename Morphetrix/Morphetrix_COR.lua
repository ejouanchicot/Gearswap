---============================================================================
--- FFXI GearSwap Configuration - Corsair (COR) - Modular Architecture
---============================================================================
--- Advanced Corsair job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Morphetrix_COR.lua
--- @author Morphetrix
--- @version 1.2.0 - Production Release
--- @date Created: 2025-10-07
--- @date Updated: 2025-10-09 - Party job detection via packet parsing (production-ready)
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+, packets library, resources library
---
--- Key Features:
---   - Modular architecture with specialized function modules
---   - Phantom Roll management with Lucky/Safe Number tracking
---   - Automatic party job detection via packet parsing (0xDD/0xDF) for accurate job bonuses
---   - Quick Draw elemental shot system
---   - Ranged and Melee combat optimization
---   - Comprehensive equipment set organization
---
--- Architecture Overview:
---   Main File (this) >> cor_functions.lua >> Specialized Modules
---
--- Module Organization:
---   ├── functions/cor_functions.lua    [Facade Loader]
---   ├── sets/cor_sets.lua             [Equipment Sets]
---   └── functions/COR_*.lua           [Specialized Modules]
---
--- Specialized Modules:
---   COR_PRECAST | COR_MIDCAST | COR_AFTERCAST | COR_STATUS | COR_BUFFS
---   COR_IDLE | COR_ENGAGED | COR_MACROBOOK | COR_COMMANDS | COR_LOCKSTYLE
---   COR_MOVEMENT
---
--- Packet Event Handlers:
---   - Action packets (category 6): Roll value detection for initial rolls and Double-Up
---   - Incoming chunk (0xDD/0xDF): Party member job detection for automatic job bonuses
---============================================================================

---============================================================================
-- INITIALIZATION
---============================================================================

-- Track if this is initial setup (prevents double init on sub job change)
local is_initial_setup = true

-- Load lockstyle timing configuration
local lockstyle_config_success, LockstyleConfig = pcall(require, 'Morphetrix/config/LOCKSTYLE_CONFIG')
if not lockstyle_config_success or not LockstyleConfig then
    -- Fallback defaults if config not found
    LockstyleConfig = {
        initial_load_delay = 8.0,
        job_change_delay = 8.0,
        cooldown = 15.0
    }
end

-- Load UI configuration
local ui_config_success, UIConfig = pcall(require, 'Morphetrix/config/UI_CONFIG')
if not ui_config_success or not UIConfig then
    -- Fallback defaults if config not found
    UIConfig = {
        init_delay = 5.0
    }
end

-- Load PartyTracker at module level (handles roll detection + party job detection)
local party_tracker_loaded, PartyTracker = pcall(require, 'shared/jobs/cor/functions/logic/party_tracker')
if not party_tracker_loaded or not PartyTracker then
    add_to_chat(167, '[COR] WARNING: Failed to load PartyTracker - roll/party detection disabled!')
    PartyTracker = nil
end

-- Lockstyle watchdog state (detects when DressUp is reloaded)
if not _G.cor_lockstyle_watchdog then
    _G.cor_lockstyle_watchdog = {
        lockstyle_applied = false,
        dressup_was_loaded = nil  -- nil = unknown, true = loaded, false = not loaded
    }
end

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Morphetrix', 'COR')

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

    _G.LockstyleConfig = LockstyleConfig
    _G.RECAST_CONFIG = require('Morphetrix/config/RECAST_CONFIG')

    -- Load region configuration (must load before message system for color codes)
    local region_success, RegionConfig = pcall(require, 'Morphetrix/config/REGION_CONFIG')
    if region_success and RegionConfig then
        _G.RegionConfig = RegionConfig
    end

    -- COR-specific configs
    _G.CORTPCONFIG = require('Morphetrix/config/cor/COR_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unload external rolltracker addon (prevents conflict with integrated roll tracker)
    send_command('lua unload rolltracker')

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/cor/functions/cor_functions.lua')

    -- Register COR lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_cor_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("COR", cancel_cor_lockstyle_operations)
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

    -- Re-initialize JobChangeManager with COR-specific functions
    -- This ensures correct functions are used when switching back to COR
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        -- Re-register COR modules to ensure they're used (not WAR/PLD/other job modules)
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if CORKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = CORKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Trigger job change sequence (handles lockstyle, macros, keybinds, UI)
        local main_job = player and player.main_job or "COR"
        JobChangeManager.on_job_change(main_job, newSubjob)
    
    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end

end

---============================================================================
-- USER SETUP
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from COR_STATES.lua)
    -- ==========================================================================

    local CORStates = require('Morphetrix/config/cor/COR_STATES')
    CORStates.configure()

    if is_initial_setup then
        -- KEYBIND LOADING
        local success, keybinds = pcall(require, 'Morphetrix/config/cor/COR_KEYBINDS')
        if success and keybinds then
            CORKeybinds = keybinds
            CORKeybinds.bind_all()
        else
            add_to_chat(167, '[COR] Warning: Failed to load keybinds')
        end

        -- UI INITIALIZATION
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            KeybindUI.smart_init("COR", UIConfig.init_delay)
        end

        -- JOB CHANGE MANAGER INITIALIZATION
        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = CORKeybinds,
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
                            keybinds = CORKeybinds,
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

    -- Initialize PartyTracker (roll detection + party job detection)
    if PartyTracker then
        PartyTracker.init()
    end

    -- ALWAYS apply lockstyle and macrobook on ANY user_setup call (initial or reload)
    -- This ensures lockstyle reapplies after //gs reload or dressup reload
    if player then
        select_default_macro_book()

        -- Schedule lockstyle after delay
        coroutine.schedule(function()
            select_default_lockstyle()
            _G.cor_lockstyle_watchdog.lockstyle_applied = true
        end, LockstyleConfig.initial_load_delay)

        -- Start lockstyle watchdog (detects DressUp reload and auto-reapplies lockstyle)
        -- Checks every 10 seconds if DressUp state changed
        if not _G.cor_lockstyle_watchdog_active then
            _G.cor_lockstyle_watchdog_active = true

            local function lockstyle_watchdog_check()
                -- Only run if still active and player is COR
                if not _G.cor_lockstyle_watchdog_active then
                    return
                end

                if player and player.main_job == 'COR' and _G.cor_lockstyle_watchdog.lockstyle_applied then
                    -- Check if DressUp addon is loaded
                    local dressup_loaded = false
                    if windower and windower.ffxi and windower.ffxi.get_addons then
                        local addons = windower.ffxi.get_addons()
                        for _, addon in ipairs(addons) do
                            if addon.name and addon.name:lower() == 'dressup' then
                                dressup_loaded = true
                                break
                            end
                        end
                    end

                    -- Detect state change: DressUp was reloaded (went from false to true)
                    if _G.cor_lockstyle_watchdog.dressup_was_loaded == false and dressup_loaded == true then
                        add_to_chat(158, '[COR] DressUp reloaded detected - reapplying lockstyle...')
                        if select_default_lockstyle then
                            -- Delay by 2 seconds to let DressUp initialize
                            coroutine.schedule(function()
                                select_default_lockstyle()
                            end, 2)
                        end
                    end

                    -- Update state
                    _G.cor_lockstyle_watchdog.dressup_was_loaded = dressup_loaded
                end

                -- Reschedule next check in 10 seconds (recursive)
                coroutine.schedule(lockstyle_watchdog_check, 10)
            end

            -- Start watchdog after 15 seconds
            coroutine.schedule(lockstyle_watchdog_check, 15)
        end
    end

    if not is_initial_setup then
        -- SUBJOB CHANGE: Force gear re-equip after states are initialized
        -- This is NECESSARY because COR weapon behavior changes based on subjob:
        --   COR/DNC or COR/NIN: Dual wield (main+sub)
        --   COR/SCH or other: Single weapon (main only)
        -- SetBuilder checks player.sub_job to apply correct weapon configuration
        coroutine.schedule(function()
            if player and player.status then
                -- Trigger status_change which forces complete set rebuild
                status_change(player.status, player.status)
            end
        end, 0.5)
    end
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

function init_gear_sets()
    include('sets/cor_sets.lua')
end

---============================================================================
-- CLEANUP
---============================================================================

function file_unload()
    -- Stop lockstyle watchdog
    if _G.cor_lockstyle_watchdog_active then
        _G.cor_lockstyle_watchdog_active = false
    end

    -- Cleanup PartyTracker (unregister event handlers and clear state)
    if PartyTracker then
        PartyTracker.cleanup()
    end

    -- Cancel all pending operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds
    if CORKeybinds then
        CORKeybinds.unbind_all()
    end

    -- Destroy UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
