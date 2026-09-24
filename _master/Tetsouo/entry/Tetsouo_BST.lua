---============================================================================
--- FFXI GearSwap Configuration - Beastmaster (BST) - Modular Architecture
---============================================================================
--- Main file for Beastmaster job with dynamic ecosystem/species/ammoSet states.
--- CRITICAL: Uses dynamic state recreation for species and ammoSet.
---
--- @file Tetsouo/Tetsouo_BST.lua
--- @author Tetsouo
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-17
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================

---============================================================================
--- CONFIGURATION LOADING
---============================================================================

-- Load global configurations with fallbacks
local LockstyleConfig_ok, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
if not LockstyleConfig_ok then LockstyleConfig = nil end
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,
    job_change_delay = 8.0,
    cooldown = 15.0
}

-- Load core modules (cached for all functions)
local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'BST')

---============================================================================
--- GEARSWAP ENTRY POINT
---============================================================================

-- Load region configuration. message_colors captures _G.RegionConfig once,
-- when it is first required - ConfigLoader above already required it, so
-- this assignment comes too late for the region warning color.
local region_success, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

--- GearSwap entry hook: loads the BST configs, Mote-Include, the shared systems
--- and the BST modules. Called by GearSwap each time this job file is loaded.
--- @return void
function get_sets()
    -- PERFORMANCE PROFILING (enable with: //gs c perf start)
    local Profiler = require('shared/utils/debug/performance_profiler')
    Profiler.start('get_sets')

    mote_include_version = 2

    -- AutoMove ENABLED for BST: movement-speed feet (sets.MoveSpeed) are applied
    -- by SetBuilder.build_idle_set via state.Moving, which ONLY AutoMove maintains.
    -- Disabling it left no replacement, so movement feet never equipped.

    -- Load BST-specific configs BEFORE Mote-Include (needed by user_setup)
    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig
    _G.RECAST_CONFIG = require('Tetsouo/config/RECAST_CONFIG')
    _G.BSTBeastPetData = require('Tetsouo/config/bst/BST_PET_DATA')
    _G.BSTTPConfig = require('Tetsouo/config/bst/BST_TP_CONFIG')

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

    -- Cancel pending operations from previous job
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/bst/functions/bst_functions.lua')
    Profiler.mark('After bst_functions')

    -- Register BST lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_bst_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("BST", cancel_bst_lockstyle_operations)
    end

    Profiler.finish()
end

---============================================================================
--- USER SETUP (STATE DEFINITIONS + INITIALIZATION)
---============================================================================

--- Configure states, ecosystem, keybinds, UI, BST HUD and pet monitoring.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
function user_setup()
    -- ==========================================================================
    -- STATES CONFIGURATION
    -- ==========================================================================
    local BSTStates = require('Tetsouo/config/bst/BST_STATES')
    BSTStates.configure()

    -- ==========================================================================
    -- DYNAMIC STATE INITIALIZATION (BST-SPECIFIC)
    -- ==========================================================================
    -- CRITICAL: Initialize ecosystem BEFORE UI so species state exists
    local em_success, EcosystemManager = pcall(require, 'shared/jobs/bst/functions/logic/ecosystem_manager')
    if em_success and EcosystemManager then
        EcosystemManager.initialize()
    else
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            MessageFormatter.show_error('[BST] Failed to load EcosystemManager')
        end
    end

    -- ==========================================================================
    -- KEYBINDS LOADING
    -- ==========================================================================
    local kb_success, keybinds = pcall(require, 'Tetsouo/config/bst/BST_KEYBINDS')
    if kb_success and keybinds then
        BSTKeybinds = keybinds
        BSTKeybinds.bind_all()
    else
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            MessageFormatter.show_error('[BST] Failed to load keybinds')
        end
    end

    -- ==========================================================================
    -- UI INITIALIZATION
    -- ==========================================================================
    if ui_success and KeybindUI then
        KeybindUI.smart_init("BST", UIConfig.init_delay)

        -- Export to _G for ecosystem_manager access
        _G.KeybindUI = KeybindUI
    end

    -- ==========================================================================
    -- JOB CHANGE MANAGER INITIALIZATION
    -- ==========================================================================
    if jcm_success and JobChangeManager then
        -- bst_functions.lua is not included yet when Mote runs user_setup();
        -- these globals exist only because BSTKeybinds.bind_all() above
        -- (KeybindManager show_intro) required BST_MACROBOOK / BST_LOCKSTYLE.
        if select_default_lockstyle and select_default_macro_book then
            JobChangeManager.initialize({
                keybinds = BSTKeybinds,
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
                        keybinds = BSTKeybinds,
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

    -- ==========================================================================
    -- LOAD BST HUD ADDON (triple-guarded: counter + job check + unload-first)
    -- ==========================================================================
    _G.bst_hud_load_id = (_G.bst_hud_load_id or 0) + 1
    local my_hud_id = _G.bst_hud_load_id

    coroutine.schedule(function()
        -- Guard 1: Counter (invalidated by newer reload or file_unload)
        if _G.bst_hud_load_id ~= my_hud_id then return end
        -- Guard 2: Only load if still on BST (handles main job change)
        if player and player.main_job ~= 'BST' then return end
        -- Guard 3: Always unload first, then load after delay
        windower.send_command('lua unload bst-hud')
        coroutine.schedule(function()
            if _G.bst_hud_load_id ~= my_hud_id then return end
            if player and player.main_job ~= 'BST' then return end
            windower.send_command('lua load bst-hud')
        end, 1.5)
    end, 2.0)

    -- ==========================================================================
    -- START PET MONITORING (pet engaged status + auto-engage)
    -- ==========================================================================
    -- Runs with or without a pet; the monitor skips the pet checks when none.
    coroutine.schedule(function()
        if player and player.main_job ~= 'BST' then return end
        if not _G.start_pet_monitoring then return end
        start_pet_monitoring()
    end, 3.0)  -- Start after 3s delay (let UI/keybinds load first)

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
    if _G.LagDebugger then _G.LagDebugger.on_job_update() end
    -- Refresh the HUD (every cycle/set/toggle command and gs c update land here)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

---============================================================================
--- EQUIPMENT SETS LOADING
---============================================================================

--- Load the BST equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include('sets/bst/bst_sets.lua')
end

---============================================================================
--- SUBJOB CHANGE HANDLER
---============================================================================

--- Handle sub job change events (called by Mote-Include after user_setup())
--- Hands the reload sequence to JobChangeManager.
--- @param newSubjob string New subjob
--- @param oldSubjob string Old subjob
--- @return void
function job_sub_job_change(newSubjob, oldSubjob)
    -- Let JobChangeManager handle the full reload sequence
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        local main_job = player and player.main_job or "BST"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX IPC fires from user_setup() after the reload (covers main + subjob)
end

---============================================================================
--- PET MONITORING (prerender event - 1s throttle)
---============================================================================
--- Uses windower prerender event (fires every frame, throttled to 1s).
--- Tracks: pet engaged status + auto-engage only.
--- Movement gear handled by AutoMove (shared system, 0.12s polling).
--- Prerender events cannot die like coroutine.schedule chains.
---============================================================================

local monitor_event_id = nil
local last_check = 0
local prev_pet_eng = 'false'

-- Upvalues for hot path (prerender fires ~60fps)
local os_clock = os.clock
local get_mob = windower.ffxi.get_mob_by_target
local get_player = windower.ffxi.get_player

--- Register the prerender monitor (no-op if already registered).
--- Called through _G.start_pet_monitoring from user_setup() (after 3s)
--- and from BST_AFTERCAST.lua.
--- @return void
local function start_pet_monitoring()
    if monitor_event_id then return end

    monitor_event_id = windower.raw_register_event('prerender', function()
        local now = os_clock()
        if now - last_check < 1.0 then return end
        last_check = now

        local ok, err = pcall(function()
            local pet = get_mob('pet')
            local pet_eng_val = 'false'

            if pet and pet.id and pet.id ~= 0 then
                local pet_fighting = (pet.status == 1)
                pet_eng_val = pet_fighting and 'true' or 'false'

                -- Auto-engage: player fighting + pet idle + auto on
                if not pet_fighting
                    and not _G.bst_rdymove_active
                    and state.AutoPetEngage
                    and state.AutoPetEngage.value == 'On'
                then
                    local lp = get_player()
                    if lp and lp.status == 1 then
                        windower.send_command('input /pet "Fight" <t>')
                    end
                end
            end

            -- Update petEngaged state + gear refresh (only on change)
            if state.PetEngaged and state.PetEngaged.value ~= pet_eng_val then
                state.PetEngaged:set(pet_eng_val)
            end
            local sent_update = pet_eng_val ~= prev_pet_eng
            if sent_update then
                if _G.LagDebugger then _G.LagDebugger.on_prerender_check(pet_eng_val, prev_pet_eng, true) end
                windower.send_command('gs c update')
                prev_pet_eng = pet_eng_val
            end
        end)

        if not ok then
            print('[BST] Monitor error: ' .. tostring(err))
        end
    end)
end

--- Unregister the prerender monitor. Called from file_unload().
--- @return void
local function stop_pet_monitoring()
    if monitor_event_id then
        windower.unregister_event(monitor_event_id)
        monitor_event_id = nil
    end
end

_G.start_pet_monitoring = start_pet_monitoring
_G.stop_pet_monitoring = stop_pet_monitoring

---============================================================================
--- CLEANUP ON UNLOAD
---============================================================================

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Stops pet monitoring, unloads the BST HUD, cancels pending job-change
--- operations, clears exported globals and unbinds the job keys.
--- @return void
function file_unload()
    -- Stop pet monitoring
    stop_pet_monitoring()

    -- Invalidate any pending BST-HUD load coroutines (prevents double-load)
    _G.bst_hud_load_id = (_G.bst_hud_load_id or 0) + 1

    -- Unload BST HUD addon
    windower.send_command('lua unload bst-hud')

    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Clear exported globals
    _G.KeybindUI = nil
    _G.start_pet_monitoring = nil
    _G.stop_pet_monitoring = nil

    -- Unbind all keybinds (Windower binds persist across gs reload)
    if BSTKeybinds and BSTKeybinds.unbind_all then
        BSTKeybinds.unbind_all()
    end
end
