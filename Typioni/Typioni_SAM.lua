---============================================================================
--- FFXI GearSwap Configuration - Samurai (SAM) - Modular Architecture
---============================================================================
--- @file Typioni_SAM.lua
--- @author Typioni
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-21
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================

local is_initial_setup = true

-- Load configs
local lockstyle_config_success, LockstyleConfig = pcall(require, 'Typioni/config/LOCKSTYLE_CONFIG')
if not lockstyle_config_success or not LockstyleConfig then
    LockstyleConfig = {
        initial_load_delay = 8.0,
        job_change_delay = 8.0,
        cooldown = 15.0
    }
end

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
local char_name = 'Typioni' -- Hardcoded (player doesn't exist at module load time)
local config_path = windower.windower_path .. 'addons/GearSwap/data/' .. char_name .. '/config/UI_CONFIG.lua'

local success, UIConfig =
    pcall(
    function()
        return dofile(config_path)
    end
)

if not success or not UIConfig then
    UIConfig = {
        init_delay = 5.0,
        default_position = {x = 1600, y = 300},
        enabled = true,
        show_header = true,
        show_legend = true,
        show_column_headers = true,
        show_footer = true
    }
    add_to_chat(167, '[SAM] UIConfig load failed, using defaults')
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

    -- ============================================
    -- LOAD CONFIGS INTO GLOBAL NAMESPACE
    -- ============================================
    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig

    -- SAM-specific configs
    _G.SAMTPConfig = require('Typioni/config/sam/SAM_TP_CONFIG')

    -- Cancel any pending operations from previous job
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load AutoMove first (so MOVEMENT can register callbacks)
    include('../shared/utils/movement/automove.lua')
    include('../shared/jobs/sam/functions/sam_functions.lua')

    -- Register SAM lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_sam_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel('SAM', cancel_sam_lockstyle_operations)
    end
end

function job_sub_job_change(newSubjob, oldSubjob)
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if SAMKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize(
                {
                    keybinds = SAMKeybinds,
                    ui = KeybindUI,
                    lockstyle = select_default_lockstyle,
                    macrobook = select_default_macro_book
                }
            )
        end

        local main_job = player and player.main_job or 'SAM'
        JobChangeManager.on_job_change(main_job, newSubjob)
    end
end

function user_setup()
    -- STATE DEFINITIONS (Loaded from SAM_STATES.lua)
    -- All state configurations (HybridMode, MainWeapon, Buff tracking) managed by SAMStates module
    -- This ensures consistency with WAR/PLD/DNC/RDM/WHM architecture
    local SAMStates = require('Typioni/config/sam/SAM_STATES')
    SAMStates.configure()

    if is_initial_setup then
        -- KEYBIND LOADING
        local success, keybinds = pcall(require, 'Typioni/config/sam/SAM_KEYBINDS')
        if success and keybinds then
            SAMKeybinds = keybinds
            SAMKeybinds.bind_all()
        end

        -- UI INITIALIZATION
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            KeybindUI.smart_init('SAM', UIConfig.init_delay)
        end

        -- JOB CHANGE MANAGER INITIALIZATION
        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize(
                    {
                        keybinds = SAMKeybinds,
                        ui = KeybindUI,
                        lockstyle = select_default_lockstyle,
                        macrobook = select_default_macro_book
                    }
                )

                if player then
                    select_default_macro_book()
                    coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
                end
            else
                -- Functions not loaded yet, schedule for later
                coroutine.schedule(
                    function()
                        if select_default_lockstyle and select_default_macro_book then
                            JobChangeManager.initialize(
                                {
                                    keybinds = SAMKeybinds,
                                    ui = KeybindUI,
                                    lockstyle = select_default_lockstyle,
                                    macrobook = select_default_macro_book
                                }
                            )
                            if player then
                                select_default_macro_book()
                                coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
                            end
                        end
                    end,
                    0.2
                )
            end
        end

        is_initial_setup = false
    end
end

function init_gear_sets()
    include('sets/sam_sets.lua')
end

function file_unload()
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    if SAMKeybinds then
        SAMKeybinds.unbind_all()
    end

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
