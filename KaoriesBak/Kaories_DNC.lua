---============================================================================
--- FFXI GearSwap Configuration - Dancer (DNC) - Modular Architecture
---============================================================================
--- Advanced Dancer job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file    Kaories_DNC.lua
--- @author  Kaories
--- @version 1.0.0 - Initial Release
--- @date    Created: 2025-10-04
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Features:
---   • Modular architecture (12 hooks + 6 logic modules)
---   • DPS-focused gear automation with survival modes (PDT/Normal)
---   • Step management system (Quick Step, Box Step rotation)
---   • Climactic Flourish auto-trigger for weaponskills
---   • Jump auto-trigger (DRG subjob support)
---   • Waltz healing system with HP-based tier selection
---   • TP bonus optimization (Moonshade Earring automation)
---   • Weapon management (Mpu Gandring, Demersal Degen)
---   • JobChangeManager integration (anti-collision on job switches)
---   • Keybind system with subjob filtering
---   • UI display with real-time state tracking
---   • Smart lockstyle/macrobook per subjob
---
--- Architecture Overview:
---   Main File (this) → dnc_functions.lua → 11 Hooks + 6 Logic Modules
---
--- Module Organization:
---   ├── functions/dnc_functions.lua        [Façade Loader]
---   ├── sets/dnc_sets.lua                  [Equipment Sets]
---   ├── functions/DNC_*.lua                [11 Hook Modules]
---   └── functions/logic/*.lua              [6 Logic Modules]
---
--- Hook Modules (11):
---   DNC_PRECAST | DNC_MIDCAST | DNC_AFTERCAST | DNC_IDLE | DNC_ENGAGED
---   DNC_STATUS | DNC_BUFFS | DNC_COMMANDS | DNC_MOVEMENT
---   DNC_LOCKSTYLE | DNC_MACROBOOK
---
--- Logic Modules (6):
---   climactic_manager | jump_manager | set_builder | smartbuff_manager
---   step_manager | ws_variant_selector
---============================================================================

---============================================================================
-- INITIALIZATION
---============================================================================

-- Track if this is initial setup (prevents double init on sub job change)
local is_initial_setup = true

-- Load lockstyle timing configuration with fallback defaults
local _, LockstyleConfig = pcall(require, 'Kaories/config/LOCKSTYLE_CONFIG')
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,  -- Initial lockstyle delay on job load (FFXI cooldown)
    job_change_delay   = 8.0,  -- Lockstyle delay on job/subjob change
    cooldown           = 15.0  -- Minimum time between lockstyle commands
}

-- Load UI configuration with fallback defaults
local _, UIConfig = pcall(require, 'Kaories/config/UI_CONFIG')
UIConfig = UIConfig or {
    init_delay = 5.0  -- UI initialization delay (seconds)
}

-- ============================================
-- LOAD UICONFIG AT MODULE LEVEL (executed on EVERY reload)
-- ============================================
-- Centralized loading via config_loader to eliminate duplication
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Kaories', 'DNC')

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
    -- Shared code in shared/ uses _G to access these configs

    -- Global configs (loaded above, now put in _G)
    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig

    -- Additional global configs
    _G.RECAST_CONFIG = require('Kaories/config/RECAST_CONFIG')


    -- DNC-specific configs
    _G.DNCTPConfig = require('Kaories/config/dnc/DNC_TP_CONFIG')
    _G.DNCWSConfig = require('Kaories/config/dnc/DNC_WS_CONFIG')

    -- Override Mote's cancel_conflicting_buffs to disable native cooldown checks
    -- Must be done AFTER Mote-Include loads but BEFORE any actions
    -- Our CooldownChecker handles all cooldown messages with better formatting
    _G.cancel_conflicting_buffs = function(spell, action, spellMap, eventArgs)
        -- Do nothing - disable Mote's "Abort: Ability waiting on recast." message
        -- Let our CooldownChecker in job_precast handle everything
    end

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/dnc/functions/dnc_functions.lua')
    -- Keybinds loaded via require() in user_setup() for better control

    -- Register DNC lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_dnc_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("DNC", cancel_dnc_lockstyle_operations)
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

    -- Re-initialize JobChangeManager with DNC-specific functions
    -- This ensures correct functions are used when switching back to DNC
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        -- Re-register DNC modules to ensure they're used (not WAR/PLD/other job modules)
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if DNCKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = DNCKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Let JobChangeManager handle the full reload sequence
        local main_job = player and player.main_job or "DNC"
        JobChangeManager.on_job_change(main_job, newSubjob)
    
    -- DUALBOX: Send job update to MAIN character after subjob change
    local db_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if db_success and DualBoxManager then
        DualBoxManager.send_job_update()
    end
end
end

---============================================================================
-- SETUP FUNCTIONS
---============================================================================

function user_setup()
    -- ========================================
    -- STATE DEFINITIONS (Loaded from DNC_STATES.lua)
    -- ========================================

    local DNCStates = require('Kaories/config/dnc/DNC_STATES')
    DNCStates.configure()

    -- ========================================
    -- DISABLE MOTE NATIVE COOLDOWN CHECKS
    -- ========================================
    -- Let our CooldownChecker handle all cooldown messages
    state.CancelAbilityRecasts = M(false)
    state.CancelSpellRecasts = M(false)

    -- ========================================
    -- INITIAL SETUP ONLY
    -- ========================================
    -- Skip keybinds/UI init on subjob change (JobChangeManager handles it)

    if is_initial_setup then
        -- ========================================
        -- KEYBIND LOADING
        -- ========================================

        local success, keybinds = pcall(require, 'Kaories/config/dnc/DNC_KEYBINDS')
        if success and keybinds then
            DNCKeybinds = keybinds
            DNCKeybinds.bind_all()
        else
            local success_fmt, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
            if success_fmt and MessageFormatter then
                MessageFormatter.show_error("Failed to load DNC keybinds")
            else
                add_to_chat(167, "Error: Failed to load DNC keybinds")
            end
        end

        -- ========================================
        -- UI INITIALIZATION
        -- ========================================

        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            KeybindUI.smart_init("DNC", UIConfig.init_delay)
        end

        -- ========================================
        -- JOB CHANGE MANAGER INITIALIZATION
        -- ========================================

        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = DNCKeybinds,
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
                            keybinds = DNCKeybinds,
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
    include('sets/dnc_sets.lua')
end

function file_unload()
    -- Cancel any pending job change operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    if DNCKeybinds then
        DNCKeybinds.unbind_all()
    end

    -- Cleanup UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
