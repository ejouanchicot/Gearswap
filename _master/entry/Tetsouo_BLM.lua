---============================================================================
--- FFXI GearSwap Configuration - Black Mage (BLM) - Modular Architecture
---============================================================================
--- Advanced Black Mage job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Tetsouo_BLM.lua
--- @author Tetsouo
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-15
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Features:
---   - Modular architecture with specialized function modules
---   - Fast Cast optimization (cap 80%)
---   - Magic Burst support (burst mode tracking)
---   - Manawall/Manafont management
---   - Elemental Staff swapping system
---   - Death spell optimization
---   - Light/Dark elemental spell management
---   - AOE nuke support (tier III/II/I)
---
--- Architecture Overview:
---   Main File (this) >> blm_functions.lua >> Specialized Modules
---
--- Module Organization:
---   ├── functions/blm_functions.lua    [Facade Loader]
---   ├── sets/blm_sets.lua              [Equipment Sets]
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
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'BLM')

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

    -- ============================================
    -- UNIVERSAL WEAPONSKILL MESSAGES (All Jobs/Subjobs)
    -- ============================================
    include('../shared/hooks/init_ws_messages.lua')

    _G.LockstyleConfig = LockstyleConfig
    _G.RECAST_CONFIG = require('Tetsouo/config/RECAST_CONFIG')

    -- BLM-specific configs
    -- Note: BLM_TP_CONFIG.lua exports _G.BLMTPConfig automatically
    require('Tetsouo/config/blm/BLM_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/blm/functions/blm_functions.lua')

    -- Register BLM lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_blm_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("BLM", cancel_blm_lockstyle_operations)
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

    -- Re-initialize JobChangeManager with BLM-specific functions
    -- This ensures correct functions are used when switching back to BLM
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        -- Re-register BLM modules to ensure they're used (not other job modules)
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if BLMKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = BLMKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Trigger job change sequence (handles lockstyle, macros, keybinds, UI)
        local main_job = player and player.main_job or "BLM"
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
    -- STATE DEFINITIONS (Loaded from BLM_STATES.lua)
    -- ==========================================================================
    local BLMStates = require('Tetsouo/config/blm/BLM_STATES')
    BLMStates.configure()

    -- ==========================================================================
    -- KEYBIND LOADING (Always executed after reload)
    -- ==========================================================================
    local success, keybinds = pcall(require, 'Tetsouo/config/blm/BLM_KEYBINDS')
    if success and keybinds then
        BLMKeybinds = keybinds
        BLMKeybinds.bind_all()
    else
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            MessageFormatter.show_error('[BLM] Failed to load keybinds')
        end
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

--- Called by Mote-Include after state changes (e.g., cycling MainNuke, MagicBurstMode)
--- Updates the UI to reflect current state values
--- Note: Movement gear is handled passively via customize_idle_set() in BLM_IDLE.lua
function job_update(cmdParams, eventArgs)
    -- DEBUG: Track timing from AutoMove
    local debug_start = nil
    if _G.AUTOMOVE_DEBUG and _G.AUTOMOVE_DEBUG_START then
        debug_start = os.clock()
        add_to_chat(207, string.format('[job_update] ENTER | dt from AutoMove=%.3fms', (debug_start - _G.AUTOMOVE_DEBUG_START) * 1000))
    end

    -- Handle Combat Mode weapon locking
    if state.CombatMode then
        if state.CombatMode.current == "On" then
            -- Lock all weapon slots
            disable('main', 'sub', 'range', 'ammo')
        else
            -- Unlock all weapon slots
            enable('main', 'sub', 'range', 'ammo')
        end
    end

    -- Update UI when states change (F9, F10, etc.)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        if _G.AUTOMOVE_DEBUG then
            local t1 = os.clock()
            KeybindUI.update()
            add_to_chat(207, string.format('[job_update] UI.update took %.3fms', (os.clock() - t1) * 1000))
        else
            KeybindUI.update()
        end
    end

    -- DEBUG: Track total job_update time
    if _G.AUTOMOVE_DEBUG and debug_start then
        add_to_chat(207, string.format('[job_update] EXIT | total=%.3fms', (os.clock() - debug_start) * 1000))
    end
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

function init_gear_sets()
    include('sets/blm_sets.lua')
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
    if BLMKeybinds and BLMKeybinds.unbind_all then
        BLMKeybinds.unbind_all()
    end
end
