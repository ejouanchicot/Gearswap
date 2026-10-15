---============================================================================
--- Entry Kit - the hooks every job entry wrote the same way
---============================================================================
--- The 22 entries (shared/entry/<job>.lua) each carried their own copy of
--- job_update, job_sub_job_change, file_unload's common part, the keybind
--- error message and the first macro book / lockstyle. They are written once
--- here; an entry keeps only what its job adds (a lock to release first, an
--- addon to unload, a pet loop to stop).
---
--- @file    shared/utils/core/entry_kit.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-15
---============================================================================

local EntryKit = {}

-- after user_setup(), get_sets() has included the job facade by then
local FACADE_WAIT = 0.2

local function job_change_manager()
    local ok, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    return ok and JobChangeManager or nil
end

local function formatter()
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    return ok and MessageFormatter or nil
end

--- Body of job_update (Mote, after every cycle/set/toggle and gs c update):
--- refresh the HUD. Step 2 of the //gs c debugupdate trace (step 1 is
--- AutoMove's send, the next ones UI_MANAGER's and the job's customize hooks).
--- @param job string Job tag for the trace
--- @return void
function EntryKit.update_hud(job)
    if _G.LagDebugger then _G.LagDebugger.on_job_update() end
    if _G.UPDATE_DEBUG then
        local now = os.clock()
        local delta = _G._update_sent_time and (now - _G._update_sent_time) or 0
        local MessageFormatter = formatter()
        if MessageFormatter then
            MessageFormatter.show_debug(job, string.format(
                '[UPDATE_DEBUG] 2. job_update RECEIVED | t=%.3f | delta=%.3fms', now, delta * 1000))
        end
    end
    local ok, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ok and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

--- Body of job_sub_job_change: JobChangeManager debounces and reloads.
--- The dual-box message goes from user_setup() after the reload.
--- @param job string The entry's job, used while player is not readable
--- @param new_subjob string
--- @return void
function EntryKit.sub_job_change(job, new_subjob)
    local JobChangeManager = job_change_manager()
    if JobChangeManager then
        JobChangeManager.on_job_change(player and player.main_job or job, new_subjob)
    end
end

--- Common end of file_unload: cancel what the job change had scheduled, and
--- unbind the job's keys (Windower binds outlive a gs reload). A job releases
--- its own locks BEFORE calling this: GearSwap runs file_unload in a single
--- pcall, so an error here must not keep a slot locked into the next job.
--- @param keybinds table|nil The job's keybind module (<JOB>Keybinds)
--- @return void
function EntryKit.unload(keybinds)
    local JobChangeManager = job_change_manager()
    if JobChangeManager then
        JobChangeManager.cancel_all()
    end
    if keybinds and keybinds.unbind_all then
        keybinds.unbind_all()
    end
end

--- Says why the keybind file did not load. Loudly: otherwise the job loads,
--- //gs c answers, and only the keys are dead. A failed pcall(require) does
--- not mean the file is missing (the sandbox require raises the same way for
--- an error in any dependency), so the real message is the one to show.
--- @param job string Job tag
--- @param err any What pcall returned in place of the module
--- @return void
function EntryKit.keybind_error(job, err)
    local MessageFormatter = formatter()
    if MessageFormatter then
        MessageFormatter.show_error('[' .. job .. '] Keybinds failed to load: ' .. tostring(err))
    end
end

--- First macro book, then the lockstyle `lockstyle_delay` seconds later.
--- Waits for the job facade: user_setup() runs inside include('Mote-Include.lua'),
--- before get_sets() includes it, and the two functions came early only when
--- the keybinds loaded (KeybindManager's intro requires them). Without keys,
--- both used to be skipped without a word. Through LoadGate: a newer load or a
--- job change drops it.
--- @param lockstyle_delay number Seconds (LOCKSTYLE_CONFIG initial_load_delay)
--- @return void
function EntryKit.macro_and_lockstyle(lockstyle_delay)
    require('shared/utils/core/load_gate').defer(FACADE_WAIT, function()
        if player and select_default_macro_book then
            select_default_macro_book()
        end
        if select_default_lockstyle then
            coroutine.schedule(select_default_lockstyle, lockstyle_delay)
        end
    end, 'macro book')
end

return EntryKit
