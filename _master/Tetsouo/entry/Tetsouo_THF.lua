---============================================================================
--- FFXI GearSwap Configuration - Thief (THF) - Modular Architecture
---============================================================================
--- Advanced Thief job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Tetsouo/Tetsouo_THF.lua
--- @author Tetsouo
--- @version 1.0.0 - Initial Release (Architecture v2.4)
--- @date Created: 2025-10-06
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Features:
---   - Modular architecture with Hooks vs Logic separation
---   - Comprehensive equipment set organization
---   - Clean separation of concerns
---
--- Architecture Overview:
---   Main File (this) >> thf_functions.lua >> Hooks >> Logic Modules
---
--- Module Organization:
---   ├── functions/thf_functions.lua    [Facade Loader]
---   ├── functions/logic/               [Business Logic]
---   ├── sets/thf/thf_sets.lua         [Equipment Sets - modular]
---   └── functions/THF_*.lua           [Hooks Modules]
---
--- Hooks Modules:
---   THF_PRECAST | THF_MIDCAST | THF_AFTERCAST | THF_STATUS | THF_BUFFS
---   THF_IDLE | THF_ENGAGED | THF_MACROBOOK | THF_COMMANDS | THF_MOVEMENT
---   THF_LOCKSTYLE
---
--- Logic Modules:
---   logic/treasure_hunter.lua  - TH tracking and management
---   logic/sa_ta_manager.lua    - Sneak Attack/Trick Attack logic
---   logic/set_builder.lua      - Set construction (idle/engaged)
---   logic/smartbuff_manager.lua - Subjob buff automation
---   logic/range_lock.lua       - Range/ammo slot lock (RangeLock state)
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
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'THF')

-- Region configuration, set at file level: message_colors reads
-- _G.RegionConfig once each time it is loaded, so this has to run before
-- INIT_SYSTEMS loads it in get_sets().
local region_success, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

--- GearSwap entry hook: loads Mote-Include, the shared systems and the THF modules.
--- Called by GearSwap each time this job file is loaded.
--- @return void
function get_sets()
    -- PERFORMANCE PROFILING (enable with: //gs c perf start)
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

    -- THF-specific configs
    _G.THFTPConfig = require('Tetsouo/config/thf/THF_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/thf/functions/thf_functions.lua')
    Profiler.mark('After thf_functions')
    -- Keybinds loaded via require() in user_setup() for better control

    -- Register THF lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_thf_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("THF", cancel_thf_lockstyle_operations)
    end

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
        local main_job = player and player.main_job or "THF"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX IPC fires from user_setup() after the reload (covers main + subjob)
end

---============================================================================
-- SETUP FUNCTIONS
---============================================================================

--- Configure states, keybinds, UI and the initial macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from THF_STATES.lua)
    -- ==========================================================================
    local THFStates = require('Tetsouo/config/thf/THF_STATES')
    THFStates.configure()

    -- A subjob change re-runs this in the same sandbox: keep RangeLock On
    -- while the range/ammo lock is still in place.
    local rl_ok, RangeLock = pcall(require, 'shared/jobs/thf/functions/logic/range_lock')
    if rl_ok and RangeLock then
        RangeLock.sync_state()
    end

    -- ==========================================================================
    -- KEYBIND LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, 'Tetsouo/config/thf/THF_KEYBINDS')
    if success and keybinds then
        THFKeybinds = keybinds
        THFKeybinds.bind_all()
    else
        -- Loudly, because the failure is otherwise silent: the job loads,
        -- //gs c answers, and only the keys are dead. Note that a failed
        -- pcall here does NOT mean the file is missing - in the sandbox
        -- require raises the same way for an error in any dependency, so
        -- the real message is the only useful thing to show.
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_error('[THF] Keybinds failed to load: ' .. tostring(keybinds))
        end
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("THF", init_delay)
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

--- Load the THF equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include('sets/thf/thf_sets.lua')
end

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Releases the range/ammo lock, cancels pending job-change operations
--- and unbinds the job keys.
--- @return void
function file_unload()
    -- Release the range/ammo lock: GearSwap keeps slot locks across job files
    -- while RangeLock starts Off in the next one.
    -- First, before anything else in here can throw: GearSwap wraps the whole
    -- of file_unload in a single pcall (engine flow.lua:339-348), so an error
    -- in the cleanup below would skip this and leak the slot lock into the
    -- next job, which has no way to know it exists.
    local rl_ok, RangeLock = pcall(require, 'shared/jobs/thf/functions/logic/range_lock')
    if rl_ok and RangeLock then
        RangeLock.release()
    end

    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if THFKeybinds and THFKeybinds.unbind_all then
        THFKeybinds.unbind_all()
    end
end
