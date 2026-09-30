---============================================================================
--- Command Queue - console commands sent at a steady pace
---============================================================================
--- Console commands are asynchronous: a burst of hundreds in one frame is
--- queued by Windower, not by us, and the two client crashes traced on Gab's
--- side (2026-09-29 and 2026-09-30) both hit during such a burst, on a subjob
--- change (344 commands in one second). Windower's own tracker proposed a
--- flow-controlled queue for exactly this (Windower/Lua issue #179), and
--- BindManager paced its binds the same way.
---
--- Here every keybind command goes through one queue, drained BATCH commands
--- every INTERVAL seconds. A newer command for the same key replaces the one
--- still waiting, so a key bound then unbound inside the window costs one
--- command, and a job left before its keys went out never sends them.
---
--- The queue lives on `windower` (it outlives the job file): a load, a job
--- change or a subjob change never drops what is waiting. GearSwap never
--- cancels a scheduled coroutine, so a drain loop started by an older job file
--- keeps emptying the queue after a reload; one loop runs at a time
--- (`running`, generation counter).
---
--- @file    shared/utils/core/command_queue.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

local CommandQueue = {}

local BATCH = 5
local INTERVAL = 0.25

local function queue()
    local q = windower._command_queue
    if not q then
        q = {order = {}, by_key = {}, gen = 0, running = false}
        windower._command_queue = q
    end
    return q
end

--- Send up to BATCH waiting commands; keep going while some are left.
--- @param gen number Generation of the loop that scheduled this tick
local function drain(gen)
    local q = queue()
    if gen ~= q.gen then return end
    local sent = 0
    while sent < BATCH and #q.order > 0 do
        local key = table.remove(q.order, 1)
        local command = q.by_key[key]
        q.by_key[key] = nil
        if command then
            pcall(send_command, command)
            sent = sent + 1
        end
    end
    if #q.order > 0 then
        coroutine.schedule(function() drain(gen) end, INTERVAL)
    else
        q.running = false
    end
end

--- Queue a command. `key` names what it acts on: a newer command with the
--- same key replaces this one while it waits.
--- @param key string e.g. the keybind ("^numpad1")
--- @param command string Console command
function CommandQueue.push(key, command)
    local q = queue()
    if q.by_key[key] == nil then q.order[#q.order + 1] = key end
    q.by_key[key] = command
    if not q.running then
        q.running = true
        q.gen = q.gen + 1
        local gen = q.gen
        coroutine.schedule(function() drain(gen) end, 0)
    end
end

--- Commands still waiting.
--- @return number
function CommandQueue.pending()
    return #queue().order
end

_G.CommandQueue = CommandQueue

return CommandQueue
