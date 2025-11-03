---============================================================================
--- FFXI GearSwap Configuration - Corsair (COR) - Modular Architecture
---============================================================================
--- Advanced Corsair job configuration built on modular architecture principles.
--- This file serves as the main coordinator, delegating all specialized logic
--- to dedicated modules for maximum maintainability and scalability.
---
--- @file Typioni_COR.lua
--- @author Typioni
--- @version 1.2.0 - Production Release
--- @date Created: 2025-10-07
--- @date Updated: 2025-10-09 - Party job detection via packet parsing (production-ready)
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+, packets library, resources library
---
--- Key Features:
---   - Modular architecture with specialized function modules
---   - Phantom Roll management with Lucky/Safe Number tracking
---   - Automatic party job detection via packet parsing (0xDD/0xDF) for accurate job bonuses
---   - Quick Draw elemental shot system
---   - Ranged and Melee combat optimization
---   - Comprehensive equipment set organization
---
--- Architecture Overview:
---   Main File (this) → cor_functions.lua → Specialized Modules
---
--- Module Organization:
---   ├── functions/cor_functions.lua    [Facade Loader]
---   ├── sets/cor_sets.lua             [Equipment Sets]
---   └── functions/COR_*.lua           [Specialized Modules]
---
--- Specialized Modules:
---   COR_PRECAST | COR_MIDCAST | COR_AFTERCAST | COR_STATUS | COR_BUFFS
---   COR_IDLE | COR_ENGAGED | COR_MACROBOOK | COR_COMMANDS | COR_LOCKSTYLE
---   COR_MOVEMENT
---
--- Packet Event Handlers:
---   - Action packets (category 6): Roll value detection for initial rolls and Double-Up
---   - Incoming chunk (0xDD/0xDF): Party member job detection for automatic job bonuses
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

-- Load RollTracker at module level (not inside packet handler)
-- This ensures it's always loaded when lua loads, not on-demand
local roll_tracker_loaded, RollTracker = pcall(require, 'shared/jobs/cor/functions/logic/roll_tracker')
if not roll_tracker_loaded or not RollTracker then
    add_to_chat(167, '[COR] WARNING: Failed to load RollTracker - roll detection disabled!')
    RollTracker = nil
end

-- Lockstyle watchdog state (detects when DressUp is reloaded)
if not _G.cor_lockstyle_watchdog then
    _G.cor_lockstyle_watchdog = {
        lockstyle_applied = false,
        dressup_was_loaded = nil  -- nil = unknown, true = loaded, false = not loaded
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
    add_to_chat(167, "[COR] UIConfig load failed, using defaults")
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

    -- COR-specific configs
    _G.CORTPCONFIG = require('Typioni/config/cor/COR_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unload external rolltracker addon (prevents conflict with integrated roll tracker)
    send_command('lua unload rolltracker')

    -- Load AutoMove first so COR_MOVEMENT can register callbacks
    include('../shared/utils/movement/automove.lua')
    include('../shared/jobs/cor/functions/cor_functions.lua')

    -- Register COR lockstyle cancel function
    if jcm_success and JobChangeManager and cancel_cor_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("COR", cancel_cor_lockstyle_operations)
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

    -- Re-initialize JobChangeManager with COR-specific functions
    -- This ensures correct functions are used when switching back to COR
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        -- Re-register COR modules to ensure they're used (not WAR/PLD/other job modules)
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if CORKeybinds and ui_success and KeybindUI then
            JobChangeManager.initialize({
                keybinds = CORKeybinds,
                ui = KeybindUI,
                lockstyle = select_default_lockstyle,
                macrobook = select_default_macro_book
            })
        end

        -- Trigger job change sequence (handles lockstyle, macros, keybinds, UI)
        local main_job = player and player.main_job or "COR"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end

end

---============================================================================
-- USER SETUP
---============================================================================

function user_setup()
    -- ==========================================================================
    -- STATE DEFINITIONS (Loaded from COR_STATES.lua)
    -- ==========================================================================

    local CORStates = require('Typioni/config/cor/COR_STATES')
    CORStates.configure()

    if is_initial_setup then
        -- KEYBIND LOADING
        local success, keybinds = pcall(require, 'Typioni/config/cor/COR_KEYBINDS')
        if success and keybinds then
            CORKeybinds = keybinds
            CORKeybinds.bind_all()
        else
            add_to_chat(167, '[COR] Warning: Failed to load keybinds')
        end

        -- UI INITIALIZATION
        local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ui_success and KeybindUI then
            KeybindUI.smart_init("COR", UIConfig.init_delay)
        end

        -- JOB CHANGE MANAGER INITIALIZATION
        local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
        if jcm_success and JobChangeManager then
            -- Check if functions are loaded (they should be after get_sets completes)
            if select_default_lockstyle and select_default_macro_book then
                JobChangeManager.initialize({
                    keybinds = CORKeybinds,
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
                            keybinds = CORKeybinds,
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

    -- ALWAYS apply lockstyle and macrobook on ANY user_setup call (initial or reload)
    -- This ensures lockstyle reapplies after //gs reload or dressup reload
    if player then
        select_default_macro_book()

        -- Schedule lockstyle after delay
        coroutine.schedule(function()
            select_default_lockstyle()
            _G.cor_lockstyle_watchdog.lockstyle_applied = true
        end, LockstyleConfig.initial_load_delay)

        -- Start lockstyle watchdog (detects DressUp reload and auto-reapplies lockstyle)
        -- Checks every 10 seconds if DressUp state changed
        if not _G.cor_lockstyle_watchdog_active then
            _G.cor_lockstyle_watchdog_active = true

            local function lockstyle_watchdog_check()
                -- Only run if still active and player is COR
                if not _G.cor_lockstyle_watchdog_active then
                    return
                end

                if player and player.main_job == 'COR' and _G.cor_lockstyle_watchdog.lockstyle_applied then
                    -- Check if DressUp addon is loaded
                    local dressup_loaded = false
                    if windower and windower.ffxi and windower.ffxi.get_addons then
                        local addons = windower.ffxi.get_addons()
                        for _, addon in ipairs(addons) do
                            if addon.name and addon.name:lower() == 'dressup' then
                                dressup_loaded = true
                                break
                            end
                        end
                    end

                    -- Detect state change: DressUp was reloaded (went from false to true)
                    if _G.cor_lockstyle_watchdog.dressup_was_loaded == false and dressup_loaded == true then
                        add_to_chat(158, '[COR] DressUp reloaded detected - reapplying lockstyle...')
                        if select_default_lockstyle then
                            -- Delay by 2 seconds to let DressUp initialize
                            coroutine.schedule(function()
                                select_default_lockstyle()
                            end, 2)
                        end
                    end

                    -- Update state
                    _G.cor_lockstyle_watchdog.dressup_was_loaded = dressup_loaded
                end

                -- Reschedule next check in 10 seconds (recursive)
                coroutine.schedule(lockstyle_watchdog_check, 10)
            end

            -- Start watchdog after 15 seconds
            coroutine.schedule(lockstyle_watchdog_check, 15)
        end
    end

    if not is_initial_setup then
        -- SUBJOB CHANGE: Force gear re-equip after states are initialized
        -- This is NECESSARY because COR weapon behavior changes based on subjob:
        --   COR/DNC or COR/NIN: Dual wield (main+sub)
        --   COR/SCH or other: Single weapon (main only)
        -- SetBuilder checks player.sub_job to apply correct weapon configuration
        coroutine.schedule(function()
            if player and player.status then
                -- Trigger status_change which forces complete set rebuild
                status_change(player.status, player.status)
            end
        end, 0.5)
    end
end

---============================================================================
-- GEAR SET INITIALIZATION
---============================================================================

function init_gear_sets()
    include('sets/cor_sets.lua')
end

---============================================================================
-- PHANTOM ROLL DETECTION (Action Packet Parser)
---============================================================================

-- Use raw_register_event which works in GearSwap context
-- This must be called at module level, not inside a function
-- Store event ID in _G for cleanup in file_unload
_G.cor_action_event_id = windower.raw_register_event('action', function(act)
    -- CRITICAL: Exit immediately if player not available (prevents crash on reload)
    if not player or not player.id then
        return
    end

    -- Only process if COR job
    if not player.main_job or player.main_job ~= 'COR' then
        return
    end

    -- Category 6 = Job Ability used
    if act.category ~= 6 then
        return
    end

    -- Check if actor is the player
    if act.actor_id ~= player.id then
        return
    end

    -- RollTracker is loaded at module level - just check if it exists
    if not RollTracker then
        return
    end

    -- Exclude Fold only (Fold = 195)
    if act.param == 195 then
        return  -- Not a roll action
    end

    -- Check if it's a Phantom Roll using Windower resources
    -- Phantom Rolls have type 'CorsairRoll' in res.job_abilities
    local is_phantom_roll = false

    -- Try using Windower resources (cleanest method)
    local res_success = pcall(function()
        if res and res.job_abilities and res.job_abilities[act.param] then
            local ability = res.job_abilities[act.param]
            if ability.type == 'CorsairRoll' then
                is_phantom_roll = true
            end
        end
    end)

    -- Fallback: Range check (Phantom Roll IDs are 98-192)
    if not res_success or not is_phantom_roll then
        if act.param >= 98 and act.param <= 192 then
            is_phantom_roll = true
        end
    end

    if not is_phantom_roll then
        return  -- Not a Phantom Roll
    end

    -- Extract roll value from packet
    -- The packet doesn't contain the roll TYPE (Chaos, Sam, etc)
    -- Only the VALUE (1-12)
    local roll_value = act.targets and act.targets[1] and act.targets[1].actions and act.targets[1].actions[1] and act.targets[1].actions[1].param

    if roll_value and roll_value >= 1 and roll_value <= 12 then
        -- Get roll name from ability ID using Windower resources
        local roll_name = nil

        -- Load resources library inside event handler
        local res_success, res = pcall(require, 'resources')
        if res_success and res and res.job_abilities and res.job_abilities[act.param] then
            roll_name = res.job_abilities[act.param].en  -- English name
        end

        -- Check if this is a Double-Up (last roll still active)
        -- Double-Up uses the SAME ability ID as the previous roll
        local is_double_up = false

        -- Check if we have a last roll and if it was recent (within 45s - Double-Up window)
        if _G.cor_last_roll and _G.cor_last_roll.name and _G.cor_last_roll.timestamp then
            local elapsed = os.time() - _G.cor_last_roll.timestamp

            -- If last roll was within Double-Up window (45 seconds)
            if elapsed <= 45 then
                is_double_up = true
            end
        end

        -- ALWAYS process immediately now that we have the roll name from ability ID
        if roll_name then
            RollTracker.on_roll_cast(roll_name, roll_value)
        else
            -- Fallback: store for buff detection if we couldn't get name
            _G.cor_pending_roll_value = roll_value
            _G.cor_pending_roll_timestamp = os.time()
        end
    end
end)

---============================================================================
-- PARTY MEMBER JOB DETECTION (Packet Parser)
---============================================================================

-- Initialize party job storage
if not _G.cor_party_jobs then
    _G.cor_party_jobs = {}
end

-- Track current zone/party for auto-refresh
if not _G.cor_party_state then
    _G.cor_party_state = {
        zone_id = 0,
        party_count = 0
    }
end

-- Load packets library for parsing
local packets_loaded, packets = pcall(require, 'packets')
if not packets_loaded or not packets then
    add_to_chat(167, '[COR] ERROR: Failed to load packets library - party job detection disabled!')
end

-- Load resources library for job conversion
local res_loaded, res = pcall(require, 'resources')
if not res_loaded or not res then
    add_to_chat(167, '[COR] ERROR: Failed to load resources library - party job detection disabled!')
end

if packets_loaded and packets and res_loaded and res then
    -- Register event for party member updates (packet 0xDD and 0xDF)
    -- Store event ID in _G for cleanup in file_unload
    _G.cor_party_event_id = windower.raw_register_event('incoming chunk', function(id, original, modified, injected, blocked)
        -- Process party member update (0xDD) and char update (0xDF)
        -- 0xDD = Party member list (multiple members in one packet)
        -- 0xDF = Char update (single character, including self)
        if id ~= 0xDD and id ~= 0xDF then
            return
        end

        -- Parse the packet
        local success, packet = pcall(packets.parse, 'incoming', original)
        if not success or not packet then
            return
        end

        -- Extract party member info
        local name = packet['Name']
        local player_id = packet['ID']
        local main_job_id = packet['Main job']
        local sub_job_id = packet['Sub job']
        local main_job_level = packet['Main job level']

        -- Validate data (main job level > 0 means valid data)
        -- Note: 0xDF doesn't have Name, only ID - we'll store by ID instead
        if player_id and main_job_id and main_job_level and main_job_level > 0 then
            -- SKIP LOCAL PLAYER: For the local player (self), we use player.main_job which is always current
            -- Packets can contain stale data for the local player after job changes
            if player and player.id and player_id == player.id then
                return  -- Skip storing local player in cache
            end

            -- Convert job IDs to job codes using res.jobs
            local main_job = nil
            local sub_job = nil

            if res and res.jobs then
                if res.jobs[main_job_id] then
                    main_job = res.jobs[main_job_id].ens  -- "WAR", "RNG", etc.
                end
                if sub_job_id and res.jobs[sub_job_id] then
                    sub_job = res.jobs[sub_job_id].ens
                end
            end

            -- Store in global table (keyed by player ID since 0xDF doesn't have Name)
            -- Only store OTHER party members, not the local player
            if main_job then
                -- Try to get name from windower party list
                local player_name = name or "Unknown"

                -- Check if this player is in the windower party data
                local party = windower.ffxi.get_party()
                if party then
                    for i = 0, 5 do
                        local member = party['p' .. i]
                        if member and member.mob and member.mob.id == player_id then
                            player_name = member.name or player_name
                            break
                        end
                    end
                end

                -- Check if this is an update (job changed)
                local is_update = false
                if _G.cor_party_jobs[player_id] then
                    local old_data = _G.cor_party_jobs[player_id]
                    if old_data.main_job ~= main_job or old_data.sub_job ~= sub_job then
                        is_update = true
                    end
                end

                -- Store by player ID (not name, since 0xDF doesn't have it)
                _G.cor_party_jobs[player_id] = {
                    id = player_id,
                    name = player_name,
                    main_job = main_job,
                    sub_job = sub_job,
                    main_job_level = main_job_level,
                    timestamp = os.time()  -- For TTL validation
                }
            end
        end
    end)
else
    add_to_chat(167, '[COR] WARNING: Packet library not found - party job detection DISABLED')
    add_to_chat(167, '[COR] Job bonuses will only work for COR main/sub jobs or Tricorne proc')
end

---============================================================================
-- CLEANUP
---============================================================================

function file_unload()
    -- Stop lockstyle watchdog
    if _G.cor_lockstyle_watchdog_active then
        _G.cor_lockstyle_watchdog_active = false
    end

    -- Unregister event handlers first (CRITICAL for preventing duplicate handlers)
    if _G.cor_action_event_id then
        windower.unregister_event(_G.cor_action_event_id)
        _G.cor_action_event_id = nil
    end

    if _G.cor_party_event_id then
        windower.unregister_event(_G.cor_party_event_id)
        _G.cor_party_event_id = nil
    end

    -- Clear pending roll detection state (prevents stale data after reload)
    _G.cor_pending_roll_value = nil
    _G.cor_pending_roll_timestamp = nil

    -- Cancel all pending operations
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Unbind all keybinds
    if CORKeybinds then
        CORKeybinds.unbind_all()
    end

    -- Destroy UI
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        KeybindUI.destroy()
    end
end
