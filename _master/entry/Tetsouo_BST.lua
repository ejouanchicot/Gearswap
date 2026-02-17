---============================================================================
--- FFXI GearSwap Configuration - Beastmaster (BST) - Modular Architecture
---============================================================================
--- Main file for Beastmaster job with dynamic ecosystem/species/ammoSet states.
--- CRITICAL: Uses dynamic state recreation for species and ammoSet.
---
--- @file Tetsouo_BST.lua
--- @author Tetsouo
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-17
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================

---============================================================================
--- CONFIGURATION LOADING
---============================================================================

-- Load global configurations with fallbacks
local _, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
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

    -- DISABLE AUTOMOVE FOR BST (performance optimization)
    -- BST has its own lightweight movement system in BST_IDLE.lua
    _G.DISABLE_AUTOMOVE = true

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
        -- Check if functions are loaded (they should be after get_sets completes)
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
    -- START SMART MONITORING (pet status + movement)
    -- ==========================================================================
    -- Start monitoring immediately on load (doesn't require pet)
    -- Will check pet status if pet exists, skip if no pet
    coroutine.schedule(function()
        start_pet_monitoring()
    end, 3.0)  -- Start after 3s delay (let UI/keybinds load first)
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
--- EQUIPMENT SETS LOADING
---============================================================================

function init_gear_sets()
    include('sets/bst_sets.lua')
end

---============================================================================
--- SUBJOB CHANGE HANDLER
---============================================================================

function job_sub_job_change(newSubjob, oldSubjob)
    -- Let JobChangeManager handle the full reload sequence
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        local main_job = player and player.main_job or "BST"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end

---============================================================================
--- PET MONITORING (SMART BACKGROUND MONITORING)
---============================================================================
--- Lightweight background monitoring that only runs when pet exists
--- Checks every 3 seconds (vs 2.4s time change event)
--- Stops automatically when no pet (vs constant polling)
---============================================================================

local pet_monitor_active = false
local last_monitor_check = 0

-- Movement tracking (lightweight - no distance calculation)
local last_position = {x = 0, y = 0, z = 0}

-- Dirty flag tracking (Option 2: only update if states changed)
local previous_states = {
    petEngaged = 'false',
    moving = 'false'
}

--- Smart pet monitoring loop - monitors pet status + movement
--- Always active (checks every 1 second), works with or without pet
local function smart_pet_monitor()
    if not pet_monitor_active then
        return  -- Monitoring stopped
    end

    -- DEBOUNCING: Prevent multiple simultaneous loops (strict 1 second minimum)
    local current_time = os.clock()
    if current_time - last_monitor_check < 1.0 then
        return  -- Too soon, skip this call
    end
    last_monitor_check = current_time

    -- ==========================================================================
    -- CHECK 1: Pet Status (Idle/Engaged) + Auto-Engage
    -- ==========================================================================
    local pet = _G.pet
    if pet and pet.id and pet.id ~= 0 then
        -- Pet exists - check status
        local success, PetManager = pcall(require, 'shared/jobs/bst/functions/logic/pet_manager')
        if success and PetManager then
            PetManager.monitor_pet_status()

            -- Auto-engage pet if conditions met (UNLESS rdymove sequence active)
            if not _G.bst_rdymove_active then
                PetManager.check_and_engage_pet(pet)
            end
        end
    else
        -- No pet - ensure petEngaged is false
        if state and state.petEngaged and state.petEngaged.value ~= "false" then
            state.petEngaged:set('false')
        end
    end

    -- ==========================================================================
    -- CHECK 2: Movement Detection (position tracking - checks every 1s)
    -- ==========================================================================
    if player and player.status == 'Idle' then
        -- Get REAL-TIME position from windower API (not cached player global)
        local player_mob = windower.ffxi.get_mob_by_target('me')
        local current_x = player_mob and player_mob.x or 0
        local current_y = player_mob and player_mob.y or 0
        local current_z = player_mob and player_mob.z or 0

        -- Check if position changed since last check
        local moved = (current_x ~= last_position.x or
                      current_y ~= last_position.y or
                      current_z ~= last_position.z)

        -- Update state.Moving if changed (silent)
        if moved and state.Moving and state.Moving.value ~= "true" then
            state.Moving:set('true')
        elseif not moved and state.Moving and state.Moving.value ~= "false" then
            state.Moving:set('false')
        end

        -- Save current position for next check
        last_position.x = current_x
        last_position.y = current_y
        last_position.z = current_z
    else
        -- Not idle - ensure Moving is false
        if state.Moving and state.Moving.value ~= "false" then
            state.Moving:set('false')
        end
    end

    -- ==========================================================================
    -- REFRESH GEAR (ONLY if states changed - dirty flag optimization)
    -- ==========================================================================
    local current_petEngaged = state.petEngaged and state.petEngaged.value or 'false'
    local current_moving = state.Moving and state.Moving.value or 'false'

    -- Check if any state changed
    local states_changed = (current_petEngaged ~= previous_states.petEngaged or
                           current_moving ~= previous_states.moving)

    if states_changed then
        -- States changed - force gear refresh (silent)
        windower.send_command('gs c update')

        -- Update previous states
        previous_states.petEngaged = current_petEngaged
        previous_states.moving = current_moving
    end

    -- Schedule next check (1 second - balanced performance)
    coroutine.schedule(smart_pet_monitor, 1.0)
end

--- Start pet monitoring (called when pet is summoned)
function start_pet_monitoring()
    if pet_monitor_active then
        return  -- Already running
    end

    pet_monitor_active = true
    coroutine.schedule(smart_pet_monitor, 1.0)
end

--- Stop pet monitoring (called on unload or pet release)
function stop_pet_monitoring()
    pet_monitor_active = false
end

-- Export for use in other modules
_G.start_pet_monitoring = start_pet_monitoring
_G.stop_pet_monitoring = stop_pet_monitoring

---============================================================================

---============================================================================
--- CLEANUP ON UNLOAD
---============================================================================

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
