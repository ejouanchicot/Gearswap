---============================================================================
--- FFXI GearSwap Configuration - Thief (THF) - Modular Architecture
---============================================================================
--- Advanced Thief job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Typioni_THF.lua
--- @author Typioni
--- @version 1.0.0 - Initial Release (Architecture v2.4)
--- @date Created: 2025-10-06
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Features:
---   - Modular architecture with Hooks vs Logic separation
---   - Comprehensive equipment set organization
---   - Clean separation of concerns
---   - Scalable for team development
---
--- Architecture Overview:
---   Main File (this) → thf_functions.lua → Hooks → Logic Modules
---
--- Module Organization:
---   ├── functions/thf_functions.lua    [Facade Loader]
---   ├── functions/logic/               [Business Logic]
---   ├── sets/thf_sets.lua             [Equipment Sets]
---   └── functions/THF_*.lua           [Hooks Modules]
---
--- Hooks Modules:
---   THF_PRECAST | THF_MIDCAST | THF_AFTERCAST | THF_STATUS | THF_BUFFS
---   THF_IDLE | THF_ENGAGED | THF_MACROBOOK | THF_COMMANDS | THF_MOVEMENT
---   THF_LOCKSTYLE
---
--- Logic Modules:
---   logic/treasure_hunter.lua  - TH tracking and management
---   logic/sa_ta_manager.lua    - Sneak Attack/Trick Attack logic
---   logic/set_builder.lua      - Set construction (idle/engaged)
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
    add_to_chat(167, "[THF] UIConfig load failed, using defaults")
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

    -- THF-specific configs
    _G.THFTPCONFIG = require('Typioni/config/thf/THF_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load AutoMove first so THF_MOVEMENT can register callbacks
    include('../shared/utils/movement/automove.lua')
    include('../shared/jobs/thf/functions/thf_functions.lua')
    -- Keybinds loaded via require() in user_setup() for better control

    -- Register THF lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_thf_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("THF", cancel_thf_lockstyle_operations)
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

    -- Re-initialize JobChangeManager with THF-specific functions
    -- This ensures correct functions are used when switching back to THF
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        -- Re-register THF modules to ensure they're used (not WAR/PLD/other job modules)
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if THFKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = THFKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Let JobChangeManager handle the full reload sequence
        local main_job = player and player.main_job or "THF"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end
end

---============================================================================
-- SETUP FUNCTIONS
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from THF_STATES.lua)
    -- ==========================================================================

    local THFStates = require('Typioni/config/thf/THF_STATES')
    THFStates.configure()

    -- ========================================
    -- INITIAL SETUP ONLY
    -- ========================================
    -- Skip keybinds/UI init on sub job change (JobChangeManager handles it)

    if is_initial_setup then
        -- ========================================
        -- KEYBIND LOADING
        -- ========================================

        local success, keybinds = pcall(require, 'Typioni/config/thf/THF_KEYBINDS')
        if success and keybinds then
            THFKeybinds = keybinds
            THFKeybinds.bind_all()
        else
            local success_fmt, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
            if success_fmt and MessageFormatter then
                MessageFormatter.show_error("Failed to load THF keybinds")
            else
                add_to_chat(167, "Error: Failed to load THF keybinds")
            end
        end

        -- ========================================
        -- UI INITIALIZATION
        -- ========================================

        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            KeybindUI.smart_init("THF", UIConfig.init_delay)
        end

        -- ========================================
        -- JOB CHANGE MANAGER INITIALIZATION
        -- ========================================

        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = THFKeybinds,
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
                            keybinds = THFKeybinds,
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
    include('sets/thf_sets.lua')
end

function file_unload()
    -- Cancel any pending job change operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    if THFKeybinds then
        THFKeybinds.unbind_all()
    end

    -- Cleanup UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
