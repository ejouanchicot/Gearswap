---============================================================================
--- FFXI GearSwap Configuration - Rune Fencer (RUN) - Modular Architecture
---============================================================================
--- Main coordinator for Rune Fencer job configuration.
--- Delegates all specialized logic to dedicated modules for maximum maintainability.
---
--- Features:
---   • Modular architecture (11 hook modules + 4 logic modules)
---   • Tank gear automation (HybridMode PDT/MDT)
---   • Rune selection from state.RuneMode (rune_manager)
---   • Blue Magic AOE spell rotation (RUN/BLU, aoe_manager)
---   • Cure set selection by target (cure_set_builder)
---   • JobChangeManager integration (anti-collision)
---   • UI + Keybind system
---
--- Architecture:
---   Main File >> run_functions.lua (facade) >> 11 Hooks + 4 Logic Modules
---
--- Modules:
---   • 11 Hooks: PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS, BUFFS,
---               COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK
---   • 4 Logic: aoe_manager, cure_set_builder, rune_manager, set_builder
---
--- @file    Tetsouo_RUN.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-11-02
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================

---============================================================================
--- INITIALIZATION
---============================================================================

-- Load global configurations with fallbacks
local LockstyleConfig_ok, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
if not LockstyleConfig_ok then LockstyleConfig = nil end
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,
    job_change_delay = 8.0,
    cooldown = 15.0
}

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'RUN')

-- Load region configuration. message_colors captures _G.RegionConfig once,
-- when it is first required - ConfigLoader above already required it, so
-- this assignment comes too late for the region warning color.
local region_success, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

--- GearSwap entry hook: loads Mote-Include, the shared systems and the RUN modules.
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

    -- RUN-specific configs
    -- aoe_manager reads _G.BluMagicConfig when first required (//gs c aoe)
    _G.BluMagicConfig = require('Tetsouo/config/run/RUN_BLU_MAGIC')

    -- Disabled: RUN_PRECAST therefore gets an empty RUNTPConfig. Note the
    -- global name below does not match the one RUN_PRECAST reads (RUNTPConfig);
    -- RUN_TP_CONFIG.lua sets _G.RUNTPConfig itself when required.
    --_G.RUNTPCONFIG = require('Tetsouo/config/run/RUN_TP_CONFIG')
    --_G.WardConfig = require('Tetsouo/config/run/RUN_WARD_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/run/functions/run_functions.lua')
    Profiler.mark('After run_functions')

    -- Register RUN lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_run_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("RUN", cancel_run_lockstyle_operations)
    end

    Profiler.finish()
end

---============================================================================
--- JOB CHANGE HANDLING
---============================================================================

--- Handle subjob change events
--- Coordinates lockstyle, macros, keybinds, and UI reload via JobChangeManager.
---
--- @param newSubjob string New subjob code
--- @param oldSubjob string Old subjob code
--- @return void
function job_sub_job_change(newSubjob, oldSubjob)
    -- Re-initialize JobChangeManager with RUN-specific functions
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if RUNKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = RUNKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Let JobChangeManager handle the full reload sequence
        local main_job = player and player.main_job or "RUN"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX IPC fires from user_setup() after the reload (covers main + subjob)
end

---============================================================================
--- SETUP FUNCTIONS
---============================================================================

--- Configure states, keybinds (deferred 0.5s), UI and the initial macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
function user_setup()
    -- RUN-specific states (defines all states including HybridMode)
    local RUNStates = require('Tetsouo/config/run/RUN_STATES')
    RUNStates.configure()

    -- ==========================================================================
    -- KEYBINDS LOADING (Always executed after reload, deferred)
    -- ==========================================================================
    coroutine.schedule(function()
        local success, keybinds = pcall(require, 'Tetsouo/config/run/RUN_KEYBINDS')
        if success and keybinds then
            RUNKeybinds = keybinds
            RUNKeybinds.bind_all()
        else
            -- Loudly, because the failure is otherwise silent: the job loads,
            -- //gs c answers, and only the keys are dead. Note that a failed
            -- pcall here does NOT mean the file is missing - in the sandbox
            -- require raises the same way for an error in any dependency, so
            -- the real message is the only useful thing to show.
            local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
            if ok and MessageFormatter then
                MessageFormatter.show_error('[RUN] Keybinds failed to load: ' .. tostring(keybinds))
            end
        end
    end, 0.5)

    -- ==========================================================================
    -- UI INITIALIZATION (Always executed after reload, deferred)
    -- ==========================================================================
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.smart_init("RUN", UIConfig.init_delay)
    end

    -- ==========================================================================
    -- JOB CHANGE MANAGER INITIALIZATION (Always executed after reload)
    -- ==========================================================================
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        -- Initialize with current job state
        JobChangeManager.initialize()

        -- Trigger initial macrobook/lockstyle with delay.
        -- user_setup() runs inside include('Mote-Include.lua'), before the
        -- facade defines select_default_macro_book / select_default_lockstyle,
        -- and RUN's keybinds (whose intro loads them early in other jobs) are
        -- deferred 0.5s: check once get_sets() has finished (same pattern as BRD).
        coroutine.schedule(function()
            if player and select_default_macro_book and select_default_lockstyle then
                select_default_macro_book()
                coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
            end
        end, 0.2)
    end

    -- ==========================================================================
    -- DUALBOX IPC (covers main job change - job_sub_job_change is subjob-only)
    -- The require() triggers dualbox_manager auto-init which schedules the
    -- correct IPC call once per gs reload (request_alt_job for MAIN role,
    -- send_job_update for ALT role). Do NOT call them explicitly here.
    -- ==========================================================================
    pcall(require, 'shared/utils/dualbox/dualbox_manager')

    -- ==========================================================================
    -- WARP SYSTEM INITIALIZATION (not needed here)
    -- ==========================================================================
    -- WarpInit.init() is called for every job by INIT_SYSTEMS.lua; no entry
    -- file calls it directly any more. The old job-level call is kept below,
    -- commented out.
    --
    -- local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')
    -- if warp_success and WarpInit then
    --     WarpInit.init()
    -- end
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

--- Load the RUN equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include('sets/run_sets.lua')
end

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Cancels pending job-change operations and unbinds the job keys.
--- @return void
function file_unload()
    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if RUNKeybinds and RUNKeybinds.unbind_all then
        RUNKeybinds.unbind_all()
    end
end
