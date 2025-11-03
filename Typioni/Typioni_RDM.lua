---============================================================================
--- FFXI GearSwap Configuration - Red Mage (RDM) - Modular Architecture
---============================================================================
--- Advanced Red Mage job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Typioni_RDM.lua
--- @author Typioni
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
---   Main File (this) → rdm_functions.lua → Specialized Modules
---
--- Module Organization:
---   ├── functions/rdm_functions.lua    [Facade Loader]
---   ├── sets/rdm_sets.lua              [Equipment Sets]
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
-- Track if this is initial setup (prevents double init on sub job change)
local is_initial_setup = true

-- Load lockstyle timing configuration
local lockstyle_config_success, LockstyleConfig = pcall(require, 'Typioni/config/LOCKSTYLE_CONFIG')
if not lockstyle_config_success or not LockstyleConfig then
    -- Fallback defaults if config not found
    LockstyleConfig = {
        initial_load_delay = 8.0,
        job_change_delay = 8.0,
        cooldown = 15.0
    }
end

-- Load UI configuration
local ui_config_success, UIConfig = pcall(require, 'Typioni/config/UI_CONFIG')
if not ui_config_success or not UIConfig then
    -- Fallback defaults if config not found
    UIConfig = {
        init_delay = 5.0
    }
end

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
    add_to_chat(167, "[RDM] UIConfig load failed, using defaults")
else
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

    -- RDM-specific configs
    _G.RDMTPCONFIG = require('Typioni/config/rdm/RDM_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load AutoMove first so RDM_MOVEMENT can register callbacks
    include('../shared/utils/movement/automove.lua')
    include('../shared/jobs/rdm/functions/rdm_functions.lua')

    -- Register RDM lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_rdm_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("RDM", cancel_rdm_lockstyle_operations)
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

    -- Create/destroy Storm state based on SCH subjob
    if newSubjob == 'SCH' and not state.Storm then
        -- Create Storm state when switching to SCH
        state.Storm = M {
            ['description'] = 'Storm',
            'Firestorm',
            'Hailstorm',
            'Windstorm',
            'Sandstorm',
            'Thunderstorm',
            'Rainstorm',
            'Aurorastorm',
            'Voidstorm'
        }
        state.Storm:set('Firestorm')
        add_to_chat(122, '[RDM] Storm spells enabled (SCH subjob)')
    elseif oldSubjob == 'SCH' and state.Storm then
        -- Destroy Storm state when leaving SCH
        state.Storm = nil
        add_to_chat(122, '[RDM] Storm spells disabled (no SCH subjob)')
    end

    -- Re-initialize JobChangeManager with RDM-specific functions
    -- This ensures correct functions are used when switching back to RDM
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        -- Re-register RDM modules to ensure they're used (not other job modules)
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')

        -- Nil check: Only initialize if all required functions are loaded
        if RDMKeybinds and ui_success and KeybindUI and select_default_lockstyle and select_default_macro_book then
            JobChangeManager.initialize({
                keybinds = RDMKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })

            -- Trigger job change sequence (handles lockstyle, macros, keybinds, UI)
            local main_job = player and player.main_job or "RDM"
            JobChangeManager.on_job_change(main_job, newSubjob)
        end
    end
end

---============================================================================
-- USER SETUP
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from RDM_STATES.lua)
    -- ==========================================================================

    local RDMStates = require('Typioni/config/rdm/RDM_STATES')
    RDMStates.configure()

    -- Note: Storm state is conditionally created in job_sub_job_change() for SCH subjob

    if is_initial_setup then
        -- KEYBIND LOADING
        local success, keybinds = pcall(require, 'Typioni/config/rdm/RDM_KEYBINDS')
        if success and keybinds then
            RDMKeybinds = keybinds
            RDMKeybinds.bind_all()
        else
            add_to_chat(167, '[RDM] Warning: Failed to load keybinds')
        end

        -- UI INITIALIZATION
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            add_to_chat(122, '[RDM] Initializing UI...')
            KeybindUI.smart_init("RDM", UIConfig.init_delay)
            add_to_chat(122, '[RDM] UI initialization complete')
        else
            add_to_chat(167, '[RDM] WARNING: Failed to load UI_MANAGER!')
        end

        -- JOB CHANGE MANAGER INITIALIZATION
        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = RDMKeybinds,
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
                            keybinds = RDMKeybinds,
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

---============================================================================
-- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include after state changes
--- Updates the UI to reflect current state values
function job_update(cmdParams, eventArgs)
    -- Handle Combat Mode weapon locking
    if state.CombatMode then
        if state.CombatMode.current == "On" then
            -- Lock weapon slots (main, sub, range only - ammo can still swap)
            disable('main', 'sub', 'range')
        else
            -- Unlock weapon slots
            enable('main', 'sub', 'range')
        end
    end

    -- Update UI when states change
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.update()
    end
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

function init_gear_sets()
    include('sets/rdm_sets.lua')
end

---============================================================================
-- CLEANUP
---============================================================================

function file_unload()
    -- Cancel all pending operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds
    if RDMKeybinds then
        RDMKeybinds.unbind_all()
    end

    -- Destroy UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
