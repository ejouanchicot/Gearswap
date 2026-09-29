---============================================================================
--- FFXI GearSwap Configuration - Scholar (SCH) - Modular Architecture
---============================================================================
--- Loader for the Scholar job: Mote-Include, the shared systems, the SCH
--- hook modules and this character's configs and sets.
---
--- @file Tetsouo_SCH.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-29
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Architecture:
---   Main File (this) >> sch_functions.lua >> Hooks >> Logic Modules
---
--- Hooks Modules:
---   SCH_PRECAST | SCH_MIDCAST | SCH_AFTERCAST | SCH_STATUS | SCH_BUFFS
---   SCH_IDLE | SCH_ENGAGED | SCH_MACROBOOK | SCH_COMMANDS | SCH_MOVEMENT
---   SCH_LOCKSTYLE
---
--- Logic Modules:
---   logic/grimoire.lua        - Arts in force, grimoire / stratagem layers
---   logic/spell_tiers.lua     - Tier families for the shared TierRefiner
---   logic/spell_commands.lua  - nuke / helix / storm from Element, strat
---   logic/set_builder.lua     - Idle (Sublimation) / engaged sets
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
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'SCH')

--- GearSwap entry hook: loads Mote-Include, the shared systems and the SCH modules.
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

    -- SCH-specific configs
    _G.SCHTPConfig = require('Tetsouo/config/sch/SCH_TP_CONFIG')

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/sch/functions/sch_functions.lua')
    Profiler.mark('After sch_functions')

    if jcm_success and JobChangeManager and cancel_sch_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("SCH", cancel_sch_lockstyle_operations)
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
        local main_job = player and player.main_job or "SCH"
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
    local SCHStates = require('Tetsouo/config/sch/SCH_STATES')
    SCHStates.configure()

    local success, keybinds = pcall(require, 'Tetsouo/config/sch/SCH_KEYBINDS')
    if success and keybinds then
        SCHKeybinds = keybinds
        SCHKeybinds.bind_all()
    else
        -- Loudly: the job loads and //gs c answers, only the keys are dead.
        -- A failed pcall may be an error in any dependency, not a missing file.
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_error('[SCH] Keybinds failed to load: ' .. tostring(keybinds))
        end
    end

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("SCH", init_delay)
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
--- cycle, set, toggle): repaints the HUD.
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

--- Load the SCH equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include('sets/sch_sets.lua')
end

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- @return void
function file_unload()
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    if SCHKeybinds and SCHKeybinds.unbind_all then
        SCHKeybinds.unbind_all()
    end
end
