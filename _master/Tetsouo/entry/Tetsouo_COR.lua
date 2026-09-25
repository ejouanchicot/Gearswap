---============================================================================
--- FFXI GearSwap Configuration - Corsair (COR) - Modular Architecture
---============================================================================
--- Advanced Corsair job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Tetsouo/Tetsouo_COR.lua
--- @author Tetsouo
--- @version 1.2.0
--- @date Created: 2025-10-07
--- @date Updated: 2025-10-09 - Party job detection via packet parsing
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
---   ├── sets/cor/cor_sets.lua         [Equipment Sets - Modular]
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

-- PartyTracker is brought up from get_sets(), see init_party_tracking() below

-- Region configuration, set before anything loads message_colors: that
-- module reads _G.RegionConfig once each time it is loaded, to pick the
-- region's warning orange.
local region_success, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'COR')

--- Bring up party tracking and Phantom Roll detection.
---
--- Called from get_sets() and NOT from user_setup(): Mote-Include runs
--- user_setup() from inside init_include(), which is halfway through
--- include('Mote-Include.lua') - long before cor_functions.lua and
--- INIT_SYSTEMS.lua exist. Roll detection used to be the last thing
--- user_setup() registered, so anything that threw earlier in that function
--- took it down with it, and the only symptom was a Phantom Roll that
--- reported nothing at all.
local function init_party_tracking()
    local pt_ok, PartyTracker = pcall(require, 'shared/jobs/cor/functions/logic/party_tracker')
    if not pt_ok then PartyTracker = nil end

    local mf_ok, MF = pcall(require, 'shared/utils/messages/message_formatter')
    if not mf_ok then MF = nil end

    if not PartyTracker then
        if MF then
            MF.show_error('[COR] PartyTracker failed to load - no roll detection')
        end
        return
    end

    local init_ok, init_err = pcall(PartyTracker.init)
    if init_ok then
        return
    end

    if MF then
        MF.show_error('[COR] PartyTracker.init() failed: ' .. tostring(init_err))
    end

    -- init() unregisters the previous handler before it rebuilds anything, so a
    -- throw partway through leaves NO roll detection at all. The party job cache
    -- is a nicety - the roll report is the point - so re-arm the listener alone.
    local listener_ok, listener_err = pcall(PartyTracker.init_roll_listener)
    if not listener_ok and MF then
        MF.show_error('[COR] Roll detection unavailable: ' .. tostring(listener_err))
    end
end

--- GearSwap entry hook: cleans old COR event handlers, loads Mote-Include,
--- the shared systems, the COR modules and party/roll tracking.
--- Called by GearSwap each time this job file is loaded.
--- @return void
function get_sets()
    -- PERFORMANCE PROFILING (enable with: //gs c perf start)
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

    -- Party tracking + roll detection. Here, after cor_functions.lua, because
    -- every dependency it needs exists by this point in get_sets().
    init_party_tracking()

    -- Initial macrobook/lockstyle are triggered from user_setup();
    -- subjob changes go through JobChangeManager (job_sub_job_change).

    Profiler.finish()
end

---============================================================================
-- JOB CHANGE HANDLING
---============================================================================

--- Handle sub job change events (called by Mote-Include)
--- Coordinates lockstyle, macros, keybinds, and UI reload via JobChangeManager
--- @param newSubjob string New subjob
--- @param oldSubjob string Old subjob
--- @return void
function job_sub_job_change(newSubjob, oldSubjob)
    -- Let JobChangeManager handle the full reload sequence
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local main_job = player and player.main_job or "COR"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX IPC fires from user_setup() after the reload (covers main + subjob)
end

---============================================================================
-- USER SETUP
---============================================================================

--- Configure states, keybinds, UI and macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
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
    else
        -- Loudly, because the failure is otherwise silent: the job loads,
        -- //gs c answers, and only the keys are dead. Note that a failed
        -- pcall here does NOT mean the file is missing - in the sandbox
        -- require raises the same way for an error in any dependency, so
        -- the real message is the only useful thing to show.
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_error('[COR] Keybinds failed to load: ' .. tostring(keybinds))
        end
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
    -- DUALBOX IPC (covers main job change - job_sub_job_change is subjob-only)
    -- The require() triggers dualbox_manager auto-init which schedules the
    -- correct IPC call once per gs reload (request_alt_job for MAIN role,
    -- send_job_update for ALT role). Do NOT call them explicitly here.
    -- ==========================================================================
    pcall(require, 'shared/utils/dualbox/dualbox_manager')

    -- ==========================================================================
    -- MACROBOOK / LOCKSTYLE (Always executed after reload)
    -- ==========================================================================
    if player then
        -- Guarded: these globals come from the COR_MACROBOOK / COR_LOCKSTYLE
        -- wrappers, which exist only once something has required them. Today
        -- KeybindManager's show_intro() does, from bind_all() above; if the keybinds
        -- failed to load they are absent, and an unguarded call would raise and
        -- end user_setup() here.
        if select_default_macro_book then
            select_default_macro_book()
        end

        -- Schedule lockstyle after delay
        coroutine.schedule(function()
            if select_default_lockstyle then
                select_default_lockstyle()
            end
        end, LockstyleConfig.initial_load_delay)
    end
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
    -- Refresh the HUD (every cycle/set/toggle command and gs c update land here)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

--- Load the COR equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include('sets/cor/cor_sets.lua')
end

---============================================================================
-- CLEANUP
---============================================================================

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Removes roll/party tracking, reloads the rolltracker addon, cancels
--- pending job-change operations and unbinds keys.
--- @return void
function file_unload()
    -- Cleanup roll detection handler (registered by PartyTracker.init() from get_sets)
    if _G.cor_action_event_id then
        windower.unregister_event(_G.cor_action_event_id)
        _G.cor_action_event_id = nil
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
