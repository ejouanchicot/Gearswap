---============================================================================
--- FFXI GearSwap Configuration - Corsair (COR) - Modular Architecture
---============================================================================
--- Advanced Corsair job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Tetsouo_COR.lua
--- @author Tetsouo
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

-- PartyTracker loaded in user_setup() for reliable initialization after GearSwap is fully ready

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
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'COR')

function get_sets()
    -- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
    local Profiler = require('shared/utils/debug/performance_profiler')
    Profiler.start('get_sets')

    -- ============================================
    -- CLEANUP OLD COR EVENTS (CRITICAL FIX)
    -- ============================================
    -- MUST cleanup old event handlers BEFORE loading new ones
    -- This prevents duplicate event registration when switching jobs without reload
    -- (e.g., WAR → COR → WAR → COR causes double messages without this)
    if _G.cor_action_event_id then
        windower.unregister_event(_G.cor_action_event_id)
        _G.cor_action_event_id = nil
    end
    if _G.cor_party_event_id then
        windower.unregister_event(_G.cor_party_event_id)
        _G.cor_party_event_id = nil
    end
    -- Clear pending roll state
    _G.cor_pending_roll_value = nil

    -- ============================================
    -- CLEANUP OLD COR ROLLTRACKER STATE
    -- ============================================
    -- Clear RollTracker state in case we're reloading COR after playing another job
    -- This ensures clean slate for roll tracking
    local rt_success, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
    if rt_success and RollTracker and RollTracker.cleanup then
        RollTracker.cleanup()
    end

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

    -- Load region configuration (must load before message system for color codes)
    local region_success, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
    if region_success and RegionConfig then
        _G.RegionConfig = RegionConfig
    end

    -- COR-specific configs
    _G.CORTPConfig = require('Tetsouo/config/cor/COR_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unload external rolltracker addon (prevents conflict with integrated roll tracker)
    -- Will be reloaded automatically in file_unload() when changing away from COR
    send_command('lua unload rolltracker')

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/cor/functions/cor_functions.lua')
    Profiler.mark('After cor_functions')

    -- Register COR lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_cor_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("COR", cancel_cor_lockstyle_operations)
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
        local main_job = player and player.main_job or "COR"
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
    -- STATE DEFINITIONS (Loaded from COR_STATES.lua)
    -- ==========================================================================
    local CORStates = require('Tetsouo/config/cor/COR_STATES')
    CORStates.configure()

    -- ==========================================================================
    -- KEYBIND LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, 'Tetsouo/config/cor/COR_KEYBINDS')
    if success and keybinds then
        CORKeybinds = keybinds
        CORKeybinds.bind_all()
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("COR", init_delay)
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
    -- PARTY TRACKER INITIALIZATION (Always executed after reload)
    -- Loaded here (not module level) to ensure GearSwap is fully initialized
    -- ==========================================================================
    local pt_ok, PartyTracker = pcall(require, 'shared/jobs/cor/functions/logic/party_tracker')
    if pt_ok and PartyTracker then
        local init_ok, init_err = pcall(PartyTracker.init)
        if init_ok then
            local mf_ok, MF = pcall(require, 'shared/utils/messages/message_formatter')
            if mf_ok and MF then
                -- PartyTracker initialized (silent)
            end
        else
            local mf_ok, MF = pcall(require, 'shared/utils/messages/message_formatter')
            if mf_ok and MF then
                MF.show_error('[COR] PartyTracker.init() failed: ' .. tostring(init_err))
            end
        end
    else
        local mf_ok, MF = pcall(require, 'shared/utils/messages/message_formatter')
        if mf_ok and MF then
            MF.show_error('[COR] Failed to load PartyTracker: ' .. tostring(PartyTracker))
        end
    end

    -- ==========================================================================
    -- ROLL DETECTION (registered fresh on every gs reload - no cache issues)
    -- Uses raw_register_event('action') which passes a parsed table in GearSwap
    -- ==========================================================================
    if _G.cor_action_event_id then
        windower.unregister_event(_G.cor_action_event_id)
        _G.cor_action_event_id = nil
    end

    _G.cor_action_event_id = windower.raw_register_event('action', function(act)
        if not act or type(act) ~= 'table' then return end
        if not player or not player.id then return end
        if player.main_job ~= 'COR' then return end
        if act.category ~= 6 then return end
        if act.actor_id ~= player.id then return end
        if act.param == 195 then return end  -- Exclude Fold

        -- Check if Phantom Roll
        local is_phantom_roll = false
        pcall(function()
            local r = require('resources')
            if r and r.job_abilities and r.job_abilities[act.param] then
                if r.job_abilities[act.param].type == 'CorsairRoll' then
                    is_phantom_roll = true
                end
            end
        end)
        if not is_phantom_roll and act.param >= 98 and act.param <= 192 then
            is_phantom_roll = true
        end
        if not is_phantom_roll then return end

        -- Extract roll value from action targets
        local roll_value = act.targets and act.targets[1] and act.targets[1].actions
            and act.targets[1].actions[1] and act.targets[1].actions[1].param
        if not roll_value or roll_value < 1 or roll_value > 12 then return end

        -- Get roll name from ability ID
        local roll_name = nil
        pcall(function()
            local r = require('resources')
            if r and r.job_abilities and r.job_abilities[act.param] then
                roll_name = r.job_abilities[act.param].en
            end
        end)
        if not roll_name then return end

        -- Send to RollTracker
        local rt_ok, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
        if rt_ok and RollTracker and RollTracker.on_roll_cast then
            local call_ok, call_err = pcall(RollTracker.on_roll_cast, roll_name, roll_value)
            if not call_ok then
                local mf_ok, MF = pcall(require, 'shared/utils/messages/message_formatter')
                if mf_ok and MF then
                    MF.show_error('[COR] RollTracker error: ' .. tostring(call_err))
                end
            end
        end
    end)

    -- ==========================================================================
    -- LOCKSTYLE WATCHDOG (Always executed after reload)
    -- ==========================================================================
    -- This ensures lockstyle reapplies after //gs reload or dressup reload
    if player then
        select_default_macro_book()

        -- Schedule lockstyle after delay
        coroutine.schedule(function()
            select_default_lockstyle()
            _G.cor_lockstyle_watchdog.lockstyle_applied = true
        end, LockstyleConfig.initial_load_delay)

        -- Start lockstyle watchdog (detects DressUp reload and auto-reapplies lockstyle)
        if not _G.cor_lockstyle_watchdog_active then
            _G.cor_lockstyle_watchdog_active = true

            local function lockstyle_watchdog_check()
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

                    -- Detect state change: DressUp was reloaded
                    if _G.cor_lockstyle_watchdog.dressup_was_loaded == false and dressup_loaded == true then
                        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
                        if msg_success and MessageFormatter then
                            MessageFormatter.show_info('[COR] DressUp reloaded - reapplying lockstyle')
                        end
                        if select_default_lockstyle then
                            coroutine.schedule(function()
                                select_default_lockstyle()
                            end, 2)
                        end
                    end

                    _G.cor_lockstyle_watchdog.dressup_was_loaded = dressup_loaded
                end

                coroutine.schedule(lockstyle_watchdog_check, 10)
            end

            coroutine.schedule(lockstyle_watchdog_check, 15)
        end
    end

    -- ==========================================================================
    -- FORCE GEAR RE-EQUIP (Always executed after reload)
    -- ==========================================================================
    -- COR weapon behavior changes based on subjob:
    --   COR/DNC or COR/NIN: Dual wield (main+sub)
    --   COR/SCH or other: Single weapon (main only)
    coroutine.schedule(function()
        if player and player.status then
            status_change(player.status, player.status)
        end
    end, 0.5)
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
    -- Cleanup roll detection handler (registered in user_setup)
    if _G.cor_action_event_id then
        windower.unregister_event(_G.cor_action_event_id)
        _G.cor_action_event_id = nil
    end

    -- Stop lockstyle watchdog
    if _G.cor_lockstyle_watchdog_active then
        _G.cor_lockstyle_watchdog_active = false
    end

    -- Cleanup RollTracker (clear all roll state and globals)
    local rt_success, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
    if rt_success and RollTracker and RollTracker.cleanup then
        RollTracker.cleanup()
    end

    -- Cleanup PartyTracker (unregister event handlers and clear state)
    local pt_ok, PartyTracker = pcall(require, 'shared/jobs/cor/functions/logic/party_tracker')
    if pt_ok and PartyTracker and PartyTracker.cleanup then
        PartyTracker.cleanup()
    end

    -- Reload external rolltracker addon when changing away from COR
    -- (COR unloads it on load to prevent conflicts with integrated tracker)
    -- If the user doesn't have rolltracker, this will fail silently
    send_command('lua load rolltracker')

    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if CORKeybinds and CORKeybinds.unbind_all then
        CORKeybinds.unbind_all()
    end
end
