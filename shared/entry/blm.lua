---============================================================================
--- FFXI GearSwap Configuration - Black Mage (BLM) - Modular Architecture
---============================================================================
--- Advanced Black Mage job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file shared/entry/blm.lua
--- @author ejouanchicot
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-15
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Features:
---   - Modular architecture with specialized function modules
---   - Fast Cast optimization (cap 80%)
---   - Magic Burst support (burst mode tracking)
---   - Manawall/Manafont management
---   - Hachirin-no-Obi on matching day/weather
---   - Death spell optimization
---   - Light/Dark elemental spell management
---   - AOE nuke support (tier III/II/I)
---
--- Architecture Overview:
---   Main File (this) >> blm_functions.lua >> Specialized Modules
---
--- Module Organization:
---   ├── functions/blm_functions.lua    [Facade Loader]
---   ├── <Character>/blm/sets/blm_sets.lua [Equipment Sets]
---   └── functions/BLM_*.lua            [Specialized Modules]
---
--- Specialized Modules:
---   BLM_PRECAST | BLM_MIDCAST | BLM_AFTERCAST | BLM_STATUS | BLM_BUFFS
---   BLM_IDLE | BLM_ENGAGED | BLM_MACROBOOK | BLM_COMMANDS | BLM_LOCKSTYLE
---   BLM_MOVEMENT
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
local UIConfig = ConfigLoader.load_ui_config(CharPaths.name(), 'BLM')

-- Region configuration, set at file level: message_colors reads
-- _G.RegionConfig at each use, so it only has to be set before the first
-- message that uses the region colour.
local region_success, RegionConfig = pcall(require, CharPaths.module('common', 'REGION_CONFIG'))
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

--- GearSwap entry hook: loads Mote-Include, the shared systems and the BLM modules.
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

    -- BLM-specific configs
    -- Note: BLM_TP_CONFIG.lua exports _G.BLMTPConfig automatically
    require(CharPaths.module('job', 'BLM_TP_CONFIG', 'BLM'))
    Profiler.mark('After configs')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/blm/functions/blm_functions.lua')
    Profiler.mark('After blm_functions')

    -- Register BLM lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_blm_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("BLM", cancel_blm_lockstyle_operations)
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
    EntryKit.sub_job_change('BLM', newSubjob)
end

---============================================================================
-- USER SETUP
---============================================================================

--- Configure states, keybinds, UI and the initial macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from BLM_STATES.lua)
    -- ==========================================================================
    local BLMStates = require(CharPaths.module('job', 'BLM_STATES', 'BLM'))
    BLMStates.configure()

    -- ==========================================================================
    -- KEYBIND LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, CharPaths.module('job', 'BLM_KEYBINDS', 'BLM'))
    if success and keybinds then
        BLMKeybinds = keybinds
        BLMKeybinds.bind_all()
    else
        EntryKit.keybind_error('BLM', keybinds)
    end

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.smart_init("BLM", UIConfig.init_delay)
    else
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            MessageFormatter.show_error('[BLM] Failed to load UI_MANAGER')
        end
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

--- Called by Mote-Include after state changes (e.g., cycling MainNuke, MagicBurstMode)
--- Updates the UI to reflect current state values
--- Note: Movement gear is handled passively via customize_idle_set() in BLM_IDLE.lua
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    EntryKit.update_hud('BLM')
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

--- Load the BLM equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include(CharPaths.relative('sets', 'blm_sets.lua', 'BLM'))
end

---============================================================================
-- CLEANUP
---============================================================================

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Cancels pending job-change operations and unbinds the job keys. The Combat
--- Mode lock is freed by the next job (shared/utils/core/combat_mode.lua).
--- @return void
function file_unload()
    EntryKit.unload(BLMKeybinds)
end
