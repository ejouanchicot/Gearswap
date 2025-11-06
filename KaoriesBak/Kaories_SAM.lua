---============================================================================
--- FFXI GearSwap Configuration - Samurai (SAM) - Modular Architecture
---============================================================================
--- @file Kaories_SAM.lua
--- @author Kaories
--- @version 1.0.0 - Initial Release
--- @date Created: 2025-10-21
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================

local is_initial_setup = true

-- Load configs
local lockstyle_config_success, LockstyleConfig = pcall(require, 'Kaories/config/LOCKSTYLE_CONFIG')
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
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Kaories', 'SAM')

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

    -- ============================================
    -- LOAD CONFIGS INTO GLOBAL NAMESPACE
    -- ============================================
    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig

    -- Load region configuration (must load before message system for color codes)
    local region_success, RegionConfig = pcall(require, 'Kaories/config/REGION_CONFIG')
    if region_success and RegionConfig then
        _G.RegionConfig = RegionConfig
    end

    -- SAM-specific configs
    _G.SAMTPConfig = require('Kaories/config/sam/SAM_TP_CONFIG')

    -- Cancel any pending operations from previous job
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
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
    
    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end
end

function user_setup()
    -- STATE DEFINITIONS (Loaded from SAM_STATES.lua)
    -- All state configurations (HybridMode, MainWeapon, Buff tracking) managed by SAMStates module
    -- This ensures consistency with WAR/PLD/DNC/RDM/WHM architecture
    local SAMStates = require('Kaories/config/sam/SAM_STATES')
    SAMStates.configure()

    if is_initial_setup then
        -- KEYBIND LOADING
        local success, keybinds = pcall(require, 'Kaories/config/sam/SAM_KEYBINDS')
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
