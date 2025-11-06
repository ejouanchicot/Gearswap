---============================================================================
--- FFXI GearSwap Configuration - Beastmaster (BST) - Modular Architecture
---============================================================================
--- Main file for Beastmaster job with dynamic ecosystem/species/ammoSet states.
--- CRITICAL: Uses dynamic state recreation for species and ammoSet.
---
--- @file Kaories_BST.lua
--- @author Kaories
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-17
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================

local is_initial_setup = true

---============================================================================
--- CONFIGURATION LOADING
---============================================================================

-- Load global configurations with fallbacks
local _, LockstyleConfig = pcall(require, 'Kaories/config/LOCKSTYLE_CONFIG')
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,
    job_change_delay = 8.0,
    cooldown = 15.0
}

local _, UIConfig = pcall(require, 'Kaories/config/UI_CONFIG')
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
local UIConfig = ConfigLoader.load_ui_config('Kaories', 'BST')

-- Load region configuration (must load before message system for color codes)
local region_success, RegionConfig = pcall(require, 'Kaories/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

_G.ui_display_config = {
    show_header = (UIConfig.show_header == nil) and true or UIConfig.show_header,
    show_legend = (UIConfig.show_legend == nil) and true or UIConfig.show_legend,
    show_column_headers = (UIConfig.show_column_headers == nil) and true or UIConfig.show_column_headers,
    show_footer = (UIConfig.show_footer == nil) and true or UIConfig.show_footer,
    enabled = (UIConfig.enabled == nil) and true or UIConfig.enabled
}

function get_sets()
    mote_include_version = 2

    -- Load BST-specific configs BEFORE Mote-Include (needed by user_setup)
    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig
    _G.RECAST_CONFIG = require('Kaories/config/RECAST_CONFIG')
    _G.BSTBeastPetData = require('Kaories/config/bst/BST_PET_DATA')
    _G.BSTTPConfig = require('Kaories/config/bst/BST_TP_CONFIG')

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

    -- Cancel pending operations from previous job
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/bst/functions/bst_functions.lua')

    -- Register BST lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_bst_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("BST", cancel_bst_lockstyle_operations)
    end
end

---============================================================================
--- USER SETUP (STATE DEFINITIONS + INITIALIZATION)
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATES CONFIGURATION
    -- ==========================================================================
    local BSTStates = require('Kaories/config/bst/BST_STATES')
    BSTStates.configure()

    -- Skip additional initialization on subjob change (JobChangeManager handles it)
    if not is_initial_setup then
        return
    end

    -- ==========================================================================
    -- DYNAMIC STATE INITIALIZATION (BST-SPECIFIC)
    -- ==========================================================================
    -- CRITICAL: Initialize ecosystem BEFORE UI so species state exists
    local em_success, EcosystemManager = pcall(require, 'shared/jobs/bst/functions/logic/ecosystem_manager')
    if em_success and EcosystemManager then
        EcosystemManager.initialize()
    else
        add_to_chat(167, '[BST] Failed to load EcosystemManager')
    end

    -- ==========================================================================
    -- KEYBINDS LOADING
    -- ==========================================================================
    local kb_success, keybinds = pcall(require, 'Kaories/config/bst/BST_KEYBINDS')
    if kb_success and keybinds then
        BSTKeybinds = keybinds
        BSTKeybinds.bind_all()
    else
        add_to_chat(167, '[BST] Failed to load keybinds config')
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

    is_initial_setup = false
end

---============================================================================
--- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include after state changes
--- Updates the UI to reflect current state values
function job_update(cmdParams, eventArgs)
    -- Update UI when states change
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
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
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if not jcm_success or not JobChangeManager then
        return
    end

    -- Re-register BST modules (ensures correct functions when switching back to BST)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if BSTKeybinds and ui_success and KeybindUI then
        JobChangeManager.initialize({
            keybinds = BSTKeybinds,
            ui = KeybindUI,
            lockstyle = select_default_lockstyle,
            macrobook = select_default_macro_book
        })
    end

    -- Let JobChangeManager handle the full reload sequence
    local main_job = player and player.main_job or "BST"
    JobChangeManager.on_job_change(main_job, newSubjob)

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
            local PetManager = require('shared/jobs/bst/functions/logic/pet_manager')
            if PetManager then
                local pet = windower.ffxi.get_mob_by_target('pet')
                PetManager.check_and_engage_pet(pet)
            end
        end, 0.1)
    end

    -- Monitor pet status (update petEngaged state)
    coroutine.schedule(function()
        local PetManager = require('shared/jobs/bst/functions/logic/pet_manager')
        if PetManager then
            PetManager.monitor_pet_status()
        end
    end, 0.1)
end)

---============================================================================
--- CLEANUP ON UNLOAD
---============================================================================

function file_unload()
    -- Cancel all JobChangeManager operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds
    if BSTKeybinds then
        BSTKeybinds.unbind_all()
    end

    -- Destroy UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
