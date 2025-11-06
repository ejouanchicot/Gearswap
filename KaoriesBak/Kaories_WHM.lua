---============================================================================
--- FFXI GearSwap Configuration - White Mage (WHM) - Modular Architecture
---============================================================================
--- Main coordinator for White Mage job configuration.
--- Delegates all specialized logic to dedicated modules for maximum maintainability.
---
--- Features:
---   • Modular architecture (12 hooks + optional logic modules)
---   • Healer-focused gear automation (Cure optimization)
---   • Afflatus Solace/Misery support
---   • Enhancing magic duration optimization
---   • Divine/Enfeebling magic support
---   • JobChangeManager integration (anti-collision)
---   • UI + Keybind system
---
--- Architecture:
---   Main File → whm_functions.lua (façade) → 12 Hooks + Optional Logic Modules
---
--- Modules:
---   • 12 Hooks: PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS, BUFFS,
---               COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK, SETUP
---   • Optional Logic: cure_optimizer, bar_element_manager (if needed)
---
--- @file    Kaories_WHM.lua
--- @author  Kaories
--- @version 1.0.0
--- @date    Created: 2025-10-21
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================
---============================================================================
--- INITIALIZATION
---============================================================================
--- Track if this is initial setup (prevents double init on subjob change)
local is_initial_setup = true

--- Load global configurations with fallbacks
local _, LockstyleConfig = pcall(require, 'Kaories/config/LOCKSTYLE_CONFIG')
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
local UIConfig = ConfigLoader.load_ui_config('Kaories', 'WHM')

-- Load region configuration (must load before message system for color codes)
local region_success, RegionConfig = pcall(require, 'Kaories/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

function get_sets()
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

    _G.LockstyleConfig = LockstyleConfig
    _G.RECAST_CONFIG = require('Kaories/config/RECAST_CONFIG')

    -- WHM-specific configs
    _G.WHMTPConfig = require('Kaories/config/whm/WHM_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/whm/functions/whm_functions.lua')
    -- Keybinds loaded via require() in user_setup() for better control

    -- Register WHM lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_whm_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("WHM", cancel_whm_lockstyle_operations)
    end

    -- Note: Macro/lockstyle are handled by JobChangeManager on job changes
    -- Initial load will be handled by JobChangeManager after initialization
end

---============================================================================
--- JOB CHANGE HANDLING
---============================================================================

--- Handle subjob change events
--- Coordinates lockstyle, macros, keybinds, and UI reload via JobChangeManager.
---
--- @param newSubjob string New subjob code
--- @param oldSubjob string Old subjob code
function job_sub_job_change(newSubjob, oldSubjob)
    -- Re-initialize JobChangeManager with WHM-specific functions
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if WHMKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = WHMKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Let JobChangeManager handle the full reload sequence
        local main_job = player and player.main_job or "WHM"
        JobChangeManager.on_job_change(main_job, newSubjob)
    
    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end
end

---============================================================================
--- SETUP FUNCTIONS
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from WHM_STATES.lua)
    -- ==========================================================================

    local WHMStates = require('Kaories/config/whm/WHM_STATES')
    WHMStates.configure()

    -- ==========================================================================
    -- INITIAL SETUP ONLY
    -- ==========================================================================

    if is_initial_setup then
        -- Load keybinds
        local success, keybinds = pcall(require, 'Kaories/config/whm/WHM_KEYBINDS')
        if success and keybinds then
            WHMKeybinds = keybinds
            WHMKeybinds.bind_all()
        end

        -- Initialize UI
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
            KeybindUI.smart_init("WHM", init_delay)
        end

        -- Initialize JobChangeManager
        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = WHMKeybinds,
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
                            keybinds = WHMKeybinds,
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
end

function init_gear_sets()
    include('sets/whm_sets.lua')
end

function file_unload()
    -- Cancel pending operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind keybinds
    if WHMKeybinds then
        WHMKeybinds.unbind_all()
    end

    -- Cleanup UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
