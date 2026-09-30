---============================================================================
--- FFXI GearSwap Configuration - Geomancer (GEO) - Modular Architecture
---============================================================================
--- Advanced Geomancer job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file <Character>_GEO.lua
--- @author ejouanchicot
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-09
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Features:
---   - Modular architecture with specialized function modules
---   - Geomancy spell system (Indi/Geo bubble management)
---   - Luopan (pet) survival gear optimization
---   - Entrust ability support
---   - Handbell instrument management
---   - PetTP addon loaded on GEO, unloaded on file_unload
---
--- Architecture Overview:
---   Main File (this) >> geo_functions.lua >> Specialized Modules
---
--- Module Organization:
---   ├── functions/geo_functions.lua    [Facade Loader]
---   ├── sets/geo_sets.lua              [Equipment Sets]
---   └── functions/GEO_*.lua            [Specialized Modules]
---
--- Specialized Modules:
---   GEO_PRECAST | GEO_MIDCAST | GEO_AFTERCAST | GEO_STATUS | GEO_BUFFS
---   GEO_IDLE | GEO_ENGAGED | GEO_MACROBOOK | GEO_COMMANDS | GEO_LOCKSTYLE
---   GEO_MOVEMENT
---============================================================================

---============================================================================
-- INITIALIZATION
---============================================================================

-- Load lockstyle timing configuration
-- Where the character's files are (common/, <job>/, older config/ and sets/)
local CharPaths = require('shared/utils/core/char_paths')

local lockstyle_config_success, LockstyleConfig = pcall(require, CharPaths.module('common', 'LOCKSTYLE_CONFIG'))
if not lockstyle_config_success or not LockstyleConfig then
    -- Fallback defaults if config not found
    LockstyleConfig = {
        initial_load_delay = 8.0
    }
end

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config(CharPaths.name(), 'GEO')

-- Region configuration, set at file level: message_colors reads
-- _G.RegionConfig at each use, so it only has to be set before the first
-- message that uses the region colour.
local region_success, RegionConfig = pcall(require, CharPaths.module('common', 'REGION_CONFIG'))
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

--- GearSwap entry hook: loads Mote-Include, the shared systems and the GEO modules.
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
    _G.RECAST_CONFIG = require(CharPaths.module('common', 'RECAST_CONFIG'))

    -- GEO-specific configs
    _G.GEOTPConfig = require(CharPaths.module('job', 'GEO_TP_CONFIG', 'GEO'))

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/geo/functions/geo_functions.lua')
    Profiler.mark('After geo_functions')

    -- Register GEO lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_geo_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("GEO", cancel_geo_lockstyle_operations)
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
    -- Note: Mote-Include already called user_setup() before this
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        -- Trigger job change sequence (handles lockstyle, macros, keybinds, UI)
        local main_job = player and player.main_job or "GEO"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX IPC fires from user_setup() after the reload (covers main + subjob)
end

---============================================================================
-- USER SETUP
---============================================================================

--- Configure states, PetTP addon, keybinds, UI and the initial macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from GEO_STATES.lua)
    -- ==========================================================================

    local GEOStates = require(CharPaths.module('job', 'GEO_STATES', 'GEO'))
    GEOStates.configure()

    -- ==========================================================================
    -- ADDON LOADING - PetTP for Luopan management (Always executed after reload)
    -- ==========================================================================
    -- (pettp = false in _common/display/ADDONS_CONFIG.lua: left alone)
    require('shared/utils/core/job_addons').run('load', 'pettp')
    -- Silent load - PetTP addon handles its own messaging

    -- ==========================================================================
    -- KEYBIND LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, CharPaths.module('job', 'GEO_KEYBINDS', 'GEO'))
    if success and keybinds then
        GEOKeybinds = keybinds
        GEOKeybinds.bind_all()
    else
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            MessageFormatter.show_error('[GEO] Keybinds failed to load: ' .. tostring(keybinds))
        end
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.smart_init("GEO", UIConfig.init_delay)
    else
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            MessageFormatter.show_error('[GEO] Failed to load UI_MANAGER')
        end
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
-- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include after state changes (e.g., cycling MainIndi, MainGeo)
--- Updates the UI to reflect current state values. The Combat Mode lock is
--- shared/utils/core/combat_mode.lua's.
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    if _G.LagDebugger then _G.LagDebugger.on_job_update() end
    -- Refresh the HUD (every cycle/set/toggle command and gs c update land here)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

--- Load the GEO equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include(CharPaths.relative('sets', 'geo_sets.lua', 'GEO'))
end

---============================================================================
-- CLEANUP
---============================================================================

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Cancels pending job-change operations, unloads PetTP and unbinds the job keys.
--- @return void
function file_unload()
    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unload PetTP addon (external addon, must be unloaded manually)
    require('shared/utils/core/job_addons').run('unload', 'pettp')
    -- Silent unload - addon handles its own messaging

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if GEOKeybinds and GEOKeybinds.unbind_all then
        GEOKeybinds.unbind_all()
    end
end
