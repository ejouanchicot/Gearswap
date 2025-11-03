---============================================================================
--- FFXI GearSwap Configuration - Dark Knight (DRK) - Modular Architecture
---============================================================================
--- Main coordinator for Dark Knight job configuration.
--- Delegates all specialized logic to dedicated modules for maximum maintainability.
---
--- Features:
---   • Modular architecture (12 hooks + logic modules)
---   • DPS-focused gear automation (PDT/Normal modes)
---   • Last Resort management
---   • Weapon Bash support
---   • Souleater management
---   • Weaponskill automation with TP bonus
---   • JobChangeManager integration (anti-collision)
---   • UI + Keybind system
---
--- Architecture:
---   Main File → drk_functions.lua (façade) → 11 Hooks + Logic Modules
---
--- Modules:
---   • 11 Hooks: PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS, BUFFS,
---               COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK
---   • Logic: To be added as needed
---
--- @file    Typioni_DRK.lua
--- @author  Typioni
--- @version 1.0.0
--- @date    Created: 2025-10-23
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================
---============================================================================
--- INITIALIZATION
---============================================================================
--- Track if this is initial setup (prevents double init on subjob change)
local is_initial_setup = true

--- Load global configurations with fallbacks
local _, LockstyleConfig = pcall(require, 'Typioni/config/LOCKSTYLE_CONFIG')
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,
    job_change_delay = 8.0,
    cooldown = 15.0
}

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
local char_name = 'Typioni'  -- Hardcoded (player doesn't exist at module load time)
local config_path = windower.windower_path .. 'addons/GearSwap/data/' .. char_name .. '/config/UI_CONFIG.lua'

local success, UIConfig = pcall(function()
    return dofile(config_path)
end)

if not success or not UIConfig then
    UIConfig = {
        init_delay = 5.0,
        default_position = { x = 1600, y = 300 },
        enabled = true,
        show_header = true,
        show_legend = true,
        show_column_headers = true,
        show_footer = true
    }
end

-- Put in _G immediately (before get_sets)
_G.UIConfig = UIConfig
_G.ui_display_config = {
    show_header = (UIConfig.show_header == nil) and true or UIConfig.show_header,
    show_legend = (UIConfig.show_legend == nil) and true or UIConfig.show_legend,
    show_column_headers = (UIConfig.show_column_headers == nil) and true or UIConfig.show_column_headers,
    show_footer = (UIConfig.show_footer == nil) and true or UIConfig.show_footer,
    enabled = (UIConfig.enabled == nil) and true or UIConfig.enabled
}

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')

    _G.LockstyleConfig = LockstyleConfig
    _G.RECAST_CONFIG = require('Typioni/config/RECAST_CONFIG')

    -- DRK-specific configs
    _G.DRKTPCONFIG = require('Typioni/config/drk/DRK_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load AutoMove first so DRK_MOVEMENT can register callbacks
    include('../shared/utils/movement/automove.lua')
    include('../shared/jobs/drk/functions/drk_functions.lua')
    -- Keybinds loaded via require() in user_setup() for better control

    -- Register DRK lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_drk_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("DRK", cancel_drk_lockstyle_operations)
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
    -- Re-initialize JobChangeManager with DRK-specific functions
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if DRKKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = DRKKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Let JobChangeManager handle the full reload sequence
        local main_job = player and player.main_job or "DRK"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end
end

---============================================================================
--- SETUP FUNCTIONS
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from DRK_STATES.lua)
    -- ==========================================================================

    local DRKStates = require('Typioni/config/drk/DRK_STATES')
    DRKStates.configure()

    -- ==========================================================================
    -- INITIAL SETUP ONLY
    -- ==========================================================================

    if is_initial_setup then
        -- Load keybinds
        local success, keybinds = pcall(require, 'Typioni/config/drk/DRK_KEYBINDS')
        if success and keybinds then
            DRKKeybinds = keybinds
            DRKKeybinds.bind_all()
        end

        -- Initialize UI
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
            KeybindUI.smart_init("DRK", init_delay)
        end

        -- Initialize JobChangeManager
        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = DRKKeybinds,
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
                            keybinds = DRKKeybinds,
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
    include('sets/drk_sets.lua')
end

function file_unload()
    -- Cancel pending operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind keybinds
    if DRKKeybinds then
        DRKKeybinds.unbind_all()
    end

    -- Cleanup UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
