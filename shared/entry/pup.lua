---============================================================================
--- FFXI GearSwap Configuration - Puppetmaster (PUP) - Modular Architecture
---============================================================================
--- Loader for the Puppetmaster job: Mote-Include, the shared systems, the PUP
--- hook modules and this character's configs and sets.
---
--- @file <Character>_PUP.lua
--- @author ejouanchicot
--- @version 2.0
--- @date Created: 2026-09-29
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Architecture:
---   Main File (this) >> pup_functions.lua >> Hooks >> Logic Modules
---
--- Hooks Modules:
---   PUP_PRECAST | PUP_MIDCAST | PUP_PET_MIDCAST | PUP_AFTERCAST | PUP_STATUS
---   PUP_BUFFS | PUP_IDLE | PUP_ENGAGED | PUP_MACROBOOK | PUP_COMMANDS
---   PUP_MOVEMENT | PUP_LOCKSTYLE
---
--- Logic Modules:
---   logic/automaton.lua    - Head / frame -> PetMode, pet out / fighting / TP
---   logic/pet_ws.lua       - Automaton WS gear timing (0.5 s poll)
---   logic/set_builder.lua  - Idle / engaged sets, pet layers
---============================================================================

---============================================================================
-- INITIALIZATION
---============================================================================

-- Load lockstyle timing configuration
-- Where the character's files are (_common/, <job>/, saved/; older config/ and sets/)
local CharPaths = require('shared/utils/core/char_paths')

local lockstyle_config_success, LockstyleConfig = pcall(require, CharPaths.module('common', 'LOCKSTYLE_CONFIG'))
if not lockstyle_config_success or not LockstyleConfig then
    LockstyleConfig = {
        initial_load_delay = 8.0
    }
end

-- Region configuration, set at file level before anything loads the
-- message system (message_colors reads _G.RegionConfig).
local region_success, RegionConfig = pcall(require, CharPaths.module('common', 'REGION_CONFIG'))
if region_success and RegionConfig then
    _G.RegionConfig = RegionConfig
end

-- UI config, loaded on every reload (config_loader)
local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config(CharPaths.name(), 'PUP')

--- GearSwap entry hook: loads Mote-Include, the shared systems and the PUP modules.
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

    -- PUP-specific configs
    _G.PUPTPConfig = require(CharPaths.module('job', 'PUP_TP_CONFIG', 'PUP'))

    -- Cancel any pending operations from previous job (including ALL job lockstyles)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    -- Load job-specific functions (AutoMove loaded via INIT_SYSTEMS)
    include('../shared/jobs/pup/functions/pup_functions.lua')
    Profiler.mark('After pup_functions')

    if jcm_success and JobChangeManager and cancel_pup_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("PUP", cancel_pup_lockstyle_operations)
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
        local main_job = player and player.main_job or "PUP"
        JobChangeManager.on_job_change(main_job, newSubjob)
    end
end

---============================================================================
-- SETUP FUNCTIONS
---============================================================================

--- Configure states (PetMode from the automaton's head), keybinds, UI and the
--- initial macrobook/lockstyle.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change.
--- @return void
function user_setup()
    local PUPStates = require(CharPaths.module('job', 'PUP_STATES', 'PUP'))
    PUPStates.configure()

    -- PetMode from the automaton's head before the HUD first draws it
    local am_ok, Automaton = pcall(require, 'shared/jobs/pup/functions/logic/automaton')
    if am_ok and Automaton then
        Automaton.refresh_mode(true)
    end

    local success, keybinds = pcall(require, CharPaths.module('job', 'PUP_KEYBINDS', 'PUP'))
    if success and keybinds then
        PUPKeybinds = keybinds
        PUPKeybinds.bind_all()
    else
        -- Loudly: the job loads and //gs c answers, only the keys are dead.
        -- A failed pcall may be an error in any dependency, not a missing file.
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_error('[PUP] Keybinds failed to load: ' .. tostring(keybinds))
        end
    end

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI then
        local init_delay = (_G.UIConfig and _G.UIConfig.init_delay) or 5.0
        KeybindUI.smart_init("PUP", init_delay)
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
--- cycle, set, toggle): PetMode from a changed automaton head, the pet WS
--- poll started if it has something to watch, then the HUD.
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    if _G.LagDebugger then _G.LagDebugger.on_job_update() end
    local am_ok, Automaton = pcall(require, 'shared/jobs/pup/functions/logic/automaton')
    if am_ok and Automaton then
        Automaton.refresh_mode()
    end
    local ws_ok, PetWS = pcall(require, 'shared/jobs/pup/functions/logic/pet_ws')
    if ws_ok and PetWS then
        PetWS.ensure_running()
    end

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

--- Load the PUP equipment sets.
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include(CharPaths.relative('sets', 'pup_sets.lua', 'PUP'))
end

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- @return void
function file_unload()
    -- First: GearSwap runs file_unload under one pcall (engine refresh.lua
    -- load_user_files), so an error further down would skip what follows it.
    local ws_ok, PetWS = pcall(require, 'shared/jobs/pup/functions/logic/pet_ws')
    if ws_ok and PetWS then
        PetWS.stop()
    end

    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    if PUPKeybinds and PUPKeybinds.unbind_all then
        PUPKeybinds.unbind_all()
    end
end
