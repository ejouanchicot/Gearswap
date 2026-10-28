---============================================================================
--- No job file - what GearSwap runs for a job the character has no file for
---============================================================================
--- GearSwap looks for <Char>_<JOB>.lua, then <Char>.lua, <JOB>.lua, and last
--- data/default.lua (refresh.lua load_user_files), which includes this file.
--- Nothing is equipped: no sets, no keys, no job code. Only the Atelier's live
--- link opens (shared/utils/atelier/atelier_live.lua), so the page can add the
--- job (its "+ Add a job": shared/utils/atelier/job_adder.lua) while the
--- character plays it. AtelierNoJobFile tells the link: it answers /ping,
--- /addjob and /reload only.
---
--- @file shared/entry/no_job_file.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-25
---============================================================================

--- The last job file's loops are this load's to stop: none of this file's code would. Their counters live on
--- `windower` (they outlive the sandbox): moved on, every loop of the old load sees it is stale and ends. Left
--- running, the job watchdog saw "file WHM, you are WAR" and sent a stray gs reload, and AutoMove kept sending
--- gs c update (audit 2026-10-28 C). LoadGate's number: every task deferred by the old load is dropped.
local function stop_last_load()
    pcall(function() require('shared/utils/core/load_gate').begin() end)
    for _, key in ipairs({'_job_sync_seq', '_automove_seq', '_midcast_wd_seq'}) do
        if type(windower[key]) == 'number' then windower[key] = windower[key] + 1 end
    end
end

function get_sets()
    stop_last_load()
    AtelierNoJobFile = true
    -- GearSwap's require reads the file again at each call: the link's modules would be read at every ping
    pcall(function() require('shared/utils/core/module_cache').install() end)
    -- the last job file kept its keys down for the next load (keybind_manager.lua unbind_all): none here
    pcall(function()
        local n = require('shared/utils/keybinds/keybind_manager').release_all()
        require('shared/utils/debug/trace_log').log('LOAD', 'no job file: %d keys of the last job unbound', n)
    end)
    local job = (player and player.main_job or '?') .. '/' .. (player and player.sub_job or '?')
    pcall(function()
        local Live = require('shared/utils/atelier/atelier_live')
        if Live.allowed() then Live.start() end
        require('shared/utils/debug/trace_log').log('LOAD', 'no job file: Atelier link open')
    end)
    local text = ('GearSwap: no file for %s, nothing is equipped. Add the job from the Atelier (overview: + Add a job), then //gs reload.'):format(job)
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if not (ok and MessageFormatter and pcall(MessageFormatter.show_warning, text)) then print(text) end
    pcall(function() require('shared/utils/debug/trace_log').log('LOAD', 'no job file: told in the chat') end)
end
