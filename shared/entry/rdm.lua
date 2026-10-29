---============================================================================
--- FFXI GearSwap Configuration - Red Mage (RDM) - Modular Architecture
---============================================================================
--- Advanced Red Mage job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file shared/entry/rdm.lua
--- @author ejouanchicot
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
---   ├── <Character>/rdm/sets/rdm_sets.lua [Equipment Sets]
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
-- Where the character's files are (_common/, <job>/, saved/; older config/ and sets/)
local CharPaths = require('shared/utils/core/char_paths')
-- The hooks every entry shares (job_update, subjob change, unload, keybind error)
local EntryKit = require('shared/utils/core/entry_kit')

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
local UIConfig = ConfigLoader.load_ui_config(CharPaths.name(), 'RDM')

-- Region configuration, set at file level: message_colors reads
-- _G.RegionConfig at each use, so it only has to be set before the first
-- message that uses the region colour.
local region_success, RegionConfig = pcall(require, CharPaths.module('common', 'REGION_CONFIG'))
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

--- GearSwap entry hook: loads Mote-Include, the shared systems and the RDM modules.
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

    -- RDM-specific configs
    -- Note: RDM_TP_CONFIG.lua exports _G.RDMTPConfig automatically
    require(CharPaths.module('job', 'RDM_TP_CONFIG', 'RDM'))

    -- Load RDM Saboteur configuration
    local saboteur_config_success, RDMSaboteurConfig = pcall(require, CharPaths.module('job', 'RDM_SABOTEUR_CONFIG', 'RDM'))
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
    -- No Storm state work here: Mote runs user_setup() before this hook
    -- (libs/Mote-Include.lua), and RDMStates.configure() there has already
    -- created or removed state.Storm for the new subjob (configure_storm).
    EntryKit.sub_job_change('RDM', newSubjob)
end

---============================================================================
-- USER SETUP
---============================================================================

--- Configure states, keybinds, UI and the initial
--- macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from RDM_STATES.lua)
    -- ==========================================================================

    local RDMStates = require(CharPaths.module('job', 'RDM_STATES', 'RDM'))
    RDMStates.configure()

    -- Note: configure() also creates the Storm state when the subjob is SCH
    -- (configure_storm), on every load and every subjob change.

    -- Cure Auto-Tier mode (state.CureAutoTier), when the character has a RDM_CURE_CONFIG.lua (<Char>/rdm/combat/):
    -- made in shared/utils/whm/cure_manager.lua setup_state, before the keybinds so the HUD shows it
    local cure_ok, CureManager = pcall(require, 'shared/utils/whm/cure_manager')
    if cure_ok and CureManager then
        CureManager.setup_state()
    end

    -- ==========================================================================
    -- KEYBIND LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, CharPaths.module('job', 'RDM_KEYBINDS', 'RDM'))
    if success and keybinds then
        RDMKeybinds = keybinds
        RDMKeybinds.bind_all()
    else
        EntryKit.keybind_error('RDM', keybinds)
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

        EntryKit.macro_and_lockstyle(LockstyleConfig.initial_load_delay)
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

--- Called by Mote-Include after state changes
--- Updates the UI. The Combat Mode lock is shared/utils/core/combat_mode.lua's.
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    EntryKit.update_hud('RDM')
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

--- Load the RDM equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include(CharPaths.relative('sets', 'rdm_sets.lua', 'RDM'))
end

---============================================================================
-- CLEANUP
---============================================================================

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Cancels pending job-change operations and unbinds the job keys.
--- @return void
function file_unload()
    EntryKit.unload(RDMKeybinds)
end
