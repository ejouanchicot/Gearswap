---============================================================================
--- FFXI GearSwap Configuration - Summoner (SMN) - Modular Architecture
---============================================================================
--- Summoner job entry point. Delegates all logic to specialized modules under
--- shared/jobs/smn/. Blood Pact routing lives in SMN_MIDCAST + the dedicated
--- blood_pact_classifier logic module.
---
--- @file    Tetsouo_SMN.lua
--- @author  Tetsouo
--- @version 1.0.0 - Initial Release
--- @date    Created: 2026-05-28
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================

---============================================================================
--- INITIALIZATION & CONFIGURATION LOADING
---============================================================================

local LockstyleConfig_ok, LockstyleConfig = pcall(require, 'Tetsouo/config/LOCKSTYLE_CONFIG')
if not LockstyleConfig_ok then LockstyleConfig = nil end
LockstyleConfig = LockstyleConfig or {
    initial_load_delay = 8.0,
    job_change_delay = 8.0,
    cooldown = 15.0
}

local RegionConfig_ok, RegionConfig = pcall(require, 'Tetsouo/config/REGION_CONFIG')
if not RegionConfig_ok then RegionConfig = nil end
if RegionConfig then
    _G.RegionConfig = RegionConfig
end

local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')

local ConfigLoader = require('shared/utils/config/config_loader')
local UIConfig = ConfigLoader.load_ui_config('Tetsouo', 'SMN')

---============================================================================
--- GEARSWAP HOOKS - INITIALIZATION
---============================================================================

--- GearSwap entry hook: loads Mote-Include, the shared systems and the SMN modules.
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
    Profiler.mark('After data_loader')

    include('../shared/hooks/init_spell_messages.lua')
    Profiler.mark('After spell messages')

    include('../shared/hooks/init_ability_messages.lua')
    Profiler.mark('After ability messages')

    include('../shared/hooks/init_ws_messages.lua')
    Profiler.mark('After WS messages')

    _G.LockstyleConfig = LockstyleConfig
    _G.UIConfig = UIConfig
    _G.RECAST_CONFIG = require('Tetsouo/config/RECAST_CONFIG')
    Profiler.mark('After configs')

    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    include('../shared/jobs/smn/functions/smn_functions.lua')
    Profiler.mark('After smn_functions')

    if jcm_success and JobChangeManager and cancel_smn_lockstyle_operations then
        JobChangeManager.register_lockstyle_cancel("SMN", cancel_smn_lockstyle_operations)
    end

    Profiler.finish()
end

--- Load SMN equipment sets from external file (modular: sets/smn/smn_sets.lua).
--- Called by Mote-Include at the end of init_include(), after user_setup().
--- @return void
function init_gear_sets()
    include('sets/smn/smn_sets.lua')
end

---============================================================================
--- GEARSWAP HOOKS - JOB CHANGE HANDLING
---============================================================================

--- Handle sub job change events (called by Mote-Include after user_setup())
--- Hands the reload to JobChangeManager.
--- @param newSubjob string New subjob
--- @param oldSubjob string Old subjob
--- @return void
function job_sub_job_change(newSubjob, oldSubjob)
    if not jcm_success or not JobChangeManager then return end

    local main_job = player and player.main_job or "SMN"
    JobChangeManager.on_job_change(main_job, newSubjob)
end

---============================================================================
--- GEARSWAP HOOKS - USER SETUP
---============================================================================

--- Configure states, keybinds, UI, initial macrobook/lockstyle and Carbuncle auto-summon.
--- Called by Mote-Include from init_include() (inside include('Mote-Include.lua'),
--- before init_gear_sets) and again on every subjob change, before job_sub_job_change().
--- @return void
function user_setup()
    local SMNStates = require('Tetsouo/config/smn/SMN_STATES')
    SMNStates.configure()

    local kb_success, keybinds = pcall(require, 'Tetsouo/config/smn/SMN_KEYBINDS')
    if kb_success and keybinds then
        SMNKeybinds = keybinds
        SMNKeybinds.bind_all()
    else
        local msg_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if msg_success and MessageFormatter then
            MessageFormatter.show_error('[SMN] Keybinds failed to load: ' .. tostring(keybinds))
        end
    end

    if ui_success and KeybindUI then
        KeybindUI.smart_init("SMN", UIConfig.init_delay)
    end

    if jcm_success and JobChangeManager then
        JobChangeManager.initialize()

        if player and select_default_macro_book and select_default_lockstyle then
            select_default_macro_book()
            coroutine.schedule(select_default_lockstyle, LockstyleConfig.initial_load_delay)
        end
    end

    -- Auto-summon Carbuncle when no pet is out (runs on load and on every
    -- subjob change, since both go through user_setup)
    coroutine.schedule(function()
        if player and player.main_job == 'SMN' and player.status ~= 'Dead' then
            local pet = windower.ffxi.get_mob_by_target('pet')
            if not pet or not pet.id or pet.id == 0 then
                send_command('input /ma "Carbuncle" <me>')
            end
        end
    end, LockstyleConfig.initial_load_delay + 2.0)

    -- DUALBOX IPC: the require() triggers dualbox_manager auto-init, which
    -- schedules the IPC call once per gs reload. Do NOT call it explicitly here.
    pcall(require, 'shared/utils/dualbox/dualbox_manager')
end

---============================================================================
--- GEARSWAP HOOKS - STATE UPDATE
---============================================================================

--- Called by Mote-Include after state changes; updates the UI.
--- @param cmdParams table Parameters passed to Mote's handle_update
--- @param eventArgs table Mote event arguments (unused)
--- @return void
function job_update(cmdParams, eventArgs)
    if _G.LagDebugger then _G.LagDebugger.on_job_update() end
    local ui_ok, KeybindUI_local = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_ok and KeybindUI_local and KeybindUI_local.update then
        KeybindUI_local.update()
    end
end

---============================================================================
--- GEARSWAP HOOKS - CLEANUP
---============================================================================

--- Called by GearSwap when this job file is unloaded (job change, reload).
--- Stops the skillup loop, cancels pending job-change operations and unbinds keys.
--- @return void
function file_unload()
    -- Halt the Summoning Magic skillup loop before module unload so orphan
    -- coroutines can't keep spamming Siren on the next job.
    if _G.cancel_smn_skillup_loop then
        pcall(_G.cancel_smn_skillup_loop)
    end

    if jcm_success and JobChangeManager then
        JobChangeManager.cancel_all()
    end

    if SMNKeybinds and SMNKeybinds.unbind_all then
        SMNKeybinds.unbind_all()
    end
end
