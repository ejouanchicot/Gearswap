---============================================================================
--- FFXI GearSwap Configuration - Ranger (RNG) - Modular Architecture
---============================================================================
--- Loader for the Ranger job: Mote-Include, the shared systems, the RNG hook
--- modules and this character's configs and sets.
---
--- @file Tetsouo_RNG.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-29
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Architecture:
---   Main File (this) >> rng_functions.lua >> Hooks >> Logic Modules
---
--- Hooks Modules:
---   RNG_PRECAST | RNG_MIDCAST | RNG_AFTERCAST | RNG_STATUS | RNG_BUFFS
---   RNG_IDLE | RNG_ENGAGED | RNG_MACROBOOK | RNG_COMMANDS | RNG_MOVEMENT
---   RNG_LOCKSTYLE
---
--- Logic Modules:
---   logic/ranged.lua       - Flurry precast groups, ranged buff layers
---   logic/set_builder.lua  - Idle / engaged sets, weapons (main, sub, range)
---============================================================================

---============================================================================
-- INITIALIZATION
---============================================================================

-- Load lockstyle timing configuration
local lockstyle_config_success, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
if not lockstyle_config_success or not LockstyleConfig then
    LockstyleConfig = {
        initial_load_delay = 8.0
    }
end

-- Region configuration, set at file level before anything loads the
-- message system (message_colors reads _G.RegionConfig).
local region_success, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

-- UI config, loaded on every reload (config_loader)
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'RNG')

--- GearSwap entry hook: loads Mote-Include, the shared systems and the RNG modules.
--- Called by GearSwap each time this job file is loaded.
--- @return void
function get_sets()
    local Profiler = require('shared/utils/debug/performance_profiler')
    Profiler.start('get_sets')

    mote_include_version = 2
    include('Mote-Include.lua')
    Profiler.mark('After Mote-Include')
    include('../shared/utils/core/INIT_SYSTEMS.lua')
    Profiler.mark('After INIT_SYSTEMS')

    require('shared/utils/data/data_loader')
    include('../shared/hooks/init_spell_messages.lua')
    include('../shared/hooks/init_ability_messages.lua')
    include('../shared/hooks/init_ws_messages.lua')
    Profiler.mark('After message hooks')

    _G.LockstyleConfig = LockstyleConfig
    _G.RECAST_CONFIG = require('Tetsouo/config/RECAST_CONFIG')

    -- RNG-specific configs
    _G.RNGTPConfig = require('Tetsouo/config/rng/RNG_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/rng/functions/rng_functions.lua')
    Profiler.mark('After rng_functions')

    if jcm_success and JobChangeManager and cancel_rng_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("RNG", cancel_rng_lockstyle_operations)
    end

    Profiler.finish()
end

---============================================================================
-- JOB CHANGE HANDLING
---============================================================================

--- Handle sub job change events (called by Mote-Include)
--- @param newSubjob string New subjob
--- @param oldSubjob string Old subjob
--- @return void
function job_sub_job_change(newSubjob, oldSubjob)
    local success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if success and JobChangeManager then
        local main_job = player and player.main_job or "RNG"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end
end

---============================================================================
-- SETUP FUNCTIONS
---============================================================================

--- Configure states, keybinds, UI and the initial macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change.
--- @return void
function user_setup()
    local RNGStates = require('Tetsouo/config/rng/RNG_STATES')
    RNGStates.configure()

    local success, keybinds = pcall(require, 'Tetsouo/config/rng/RNG_KEYBINDS')
    if success and keybinds then
        RNGKeybinds = keybinds
        RNGKeybinds.bind_all()
    else
        -- Loudly: the job loads and //gs c answers, only the keys are dead.
        -- A failed pcall may be an error in any dependency, not a missing file.
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_error('[RNG] Keybinds failed to load: ' .. tostring(keybinds))
        end
    end

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("RNG", init_delay)
    end

    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.initialize()
        if player and select_default_macro_book and select_default_lockstyle then
            select_default_macro_book()
            coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
        end
    end

    -- DUALBOX IPC: the require() triggers dualbox_manager auto-init (once per gs reload)
    pcall(require, 'shared/utils/dualbox/dualbox_manager')
end

---============================================================================
--- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include before it puts the gear on (every gs c update,
--- cycle, set, toggle): refreshes the HUD.
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

--- Load the RNG equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include('sets/rng_sets.lua')
end

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- @return void
function file_unload()
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    if RNGKeybinds and RNGKeybinds.unbind_all then
        RNGKeybinds.unbind_all()
    end
end
