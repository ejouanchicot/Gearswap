---============================================================================
--- FFXI GearSwap Configuration - Monk (MNK) - Modular Architecture
---============================================================================
--- Loader for the Monk job: Mote-Include, the shared systems, the MNK
--- hook modules and this character's configs and sets.
---
--- @file <Character>_MNK.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-29
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Architecture:
---   Main File (this) >> mnk_functions.lua >> Hooks >> Logic Modules
---
--- Hooks Modules:
---   MNK_PRECAST | MNK_MIDCAST | MNK_AFTERCAST | MNK_STATUS | MNK_BUFFS
---   MNK_IDLE | MNK_ENGAGED | MNK_MACROBOOK | MNK_COMMANDS | MNK_MOVEMENT
---   MNK_LOCKSTYLE
---
--- Logic Modules:
---   logic/buff_layers.lua  - Impetus / Footwork / Hundred Fists /
---                            Counterstance layers (engaged, weaponskills)
---   logic/set_builder.lua  - Idle / engaged sets
---============================================================================

---============================================================================
-- INITIALIZATION
---============================================================================

-- Load lockstyle timing configuration
-- Where the character's files are (_common/, <job>/, saved/; older config/ and sets/)
local CharPaths = require('shared/utils/core/char_paths')
-- The hooks every entry shares (job_update, subjob change, unload, keybind error)
local EntryKit = require('shared/utils/core/entry_kit')

local lockstyle_config_success, LockstyleConfig = pcall(require, CharPaths.module('common', 'LOCKSTYLE_CONFIG'))
if not lockstyle_config_success or not LockstyleConfig then
    LockstyleConfig = {
        initial_load_delay = 8.0
    }
end

-- UI config, loaded on every reload (config_loader)
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config(CharPaths.name(), 'MNK')

-- Region configuration, set at file level: message_colors reads
-- _G.RegionConfig at each use, so it only has to be set before the first
-- message that uses the region colour.
local region_success, RegionConfig = pcall(require, CharPaths.module('common', 'REGION_CONFIG'))
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

--- GearSwap entry hook: loads Mote-Include, the shared systems and the MNK modules.
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
    _G.RECAST_CONFIG = require(CharPaths.module('common', 'RECAST_CONFIG'))

    -- MNK-specific configs
    _G.MNKTPConfig = require(CharPaths.module('job', 'MNK_TP_CONFIG', 'MNK'))

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/mnk/functions/mnk_functions.lua')
    Profiler.mark('After mnk_functions')

    if jcm_success and JobChangeManager and cancel_mnk_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("MNK", cancel_mnk_lockstyle_operations)
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
    EntryKit.sub_job_change('MNK', newSubjob)
end

---============================================================================
-- SETUP FUNCTIONS
---============================================================================

--- Configure states, keybinds, UI and the initial macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change.
--- @return void
function user_setup()
    local MNKStates = require(CharPaths.module('job', 'MNK_STATES', 'MNK'))
    MNKStates.configure()

    local success, keybinds = pcall(require, CharPaths.module('job', 'MNK_KEYBINDS', 'MNK'))
    if success and keybinds then
        MNKKeybinds = keybinds
        MNKKeybinds.bind_all()
    else
        EntryKit.keybind_error('MNK', keybinds)
    end

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("MNK", init_delay)
    end

    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.initialize()
        EntryKit.macro_and_lockstyle(LockstyleConfig.initial_load_delay)
    end

    -- DUALBOX IPC: the require() triggers dualbox_manager auto-init (once per gs reload)
    pcall(require, 'shared/utils/dualbox/dualbox_manager')
end

---============================================================================
--- STATE UPDATE HOOK
---============================================================================

--- Called by Mote-Include after state changes: refresh the HUD.
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    EntryKit.update_hud('MNK')
end

--- Load the MNK equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include(CharPaths.relative('sets', 'mnk_sets.lua', 'MNK'))
end

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- @return void
function file_unload()
    EntryKit.unload(MNKKeybinds)
end
