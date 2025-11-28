---============================================================================
--- FFXI GearSwap Configuration - Beastmaster (PUP) - Modular Architecture
---============================================================================
--- Main file for Beastmaster job with dynamic ecosystem/species/ammoSet states.
--- CRITICAL: Uses dynamic state recreation for species and ammoSet.
---
--- @file Tetsouo_PUP.lua
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

local _, UIConfig = pcall(require, 'Tetsouo/config/UI_CONFIG')
UIConfig = UIConfig or {
    init_delay = 5.0
}

-- Load core modules (cached for all functions)
local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')

---============================================================================
--- GEARSWAP ENTRY POINT
---============================================================================

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'PUP')

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

    -- Load PUP-specific configs BEFORE Mote-Include (needed by user_setup)
    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig
    _G.RECAST_CONFIG = require('Tetsouo/config/RECAST_CONFIG')
    _G.PUPBeastPetData = require('Tetsouo/config/pup/PUP_PET_DATA')
    _G.PUPTPConfig = require('Tetsouo/config/pup/PUP_TP_CONFIG')

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
    include('../shared/jobs/pup/functions/pup_functions.lua')
    Profiler.mark('After pup_functions')

    -- Register PUP lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_pup_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("PUP", cancel_pup_lockstyle_operations)
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
    local PUPStates = require('Tetsouo/config/pup/PUP_STATES')
    PUPStates.configure()

    -- ==========================================================================
    -- DYNAMIC STATE INITIALIZATION (PUP-SPECIFIC)
    -- ==========================================================================
    -- CRITICAL: Initialize ecosystem BEFORE UI so species state exists
    local em_success, EcosystemManager = pcall(require, 'shared/jobs/pup/functions/logic/ecosystem_manager')
    if em_success and EcosystemManager then
        EcosystemManager.initialize()
    else
        add_to_chat(167, '[PUP] Failed to load EcosystemManager')
    end

    -- ==========================================================================
    -- KEYBINDS LOADING
    -- ==========================================================================
    local kb_success, keybinds = pcall(require, 'Tetsouo/config/pup/PUP_KEYBINDS')
    if kb_success and keybinds then
        PUPKeybinds = keybinds
        PUPKeybinds.bind_all()
    else
        add_to_chat(167, '[PUP] Failed to load keybinds config')
    end

    -- ==========================================================================
    -- UI INITIALIZATION
    -- ==========================================================================
    if ui_success and KeybindUI then
        KeybindUI.smart_init("PUP", UIConfig.init_delay)

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
                keybinds = PUPKeybinds,
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
                        keybinds = PUPKeybinds,
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
    include('sets/pup_sets.lua')
end

---============================================================================
--- SUBJOB CHANGE HANDLER
---============================================================================

function job_sub_job_change(newSubjob, oldSubjob)
    -- Let JobChangeManager handle the full reload sequence
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        local main_job = player and player.main_job or "PUP"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end

---============================================================================
--- PET MONITORING (TIME CHANGE EVENT)
---============================================================================
--- Monitor pet status and trigger auto-engage when conditions met
--- Runs every minute change in-game (FFXI time)
---============================================================================

windower.register_event('time change', function(new_time, old_time)
    -- Only monitor if player is engaged
    if player and player.status == 'Engaged' then
        coroutine.schedule(function()
            local PetManager = require('shared/jobs/pup/functions/logic/pet_manager')
            if PetManager then
                local pet = windower.ffxi.get_mob_by_target('pet')
                PetManager.check_and_engage_pet(pet)
            end
        end, 0.1)
    end

    -- Monitor pet status (update petEngaged state)
    coroutine.schedule(function()
        local PetManager = require('shared/jobs/pup/functions/logic/pet_manager')
        if PetManager then
            PetManager.monitor_pet_status()
        end
    end, 0.1)
end)

---============================================================================
--- CLEANUP ON UNLOAD
---============================================================================

function file_unload()
    -- Cancel pending job change operations (debounce timer + lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Note: Keybinds and UI are automatically cleaned by GearSwap reload
    -- No need to manually unbind/destroy (reload does it)
end
