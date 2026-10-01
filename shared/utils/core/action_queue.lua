---============================================================================
--- Action Queue - this character's actions, one after the other
---============================================================================
--- Used by //gs c stealth and //gs c cleanse: a character does one action at
--- a time, so both share one queue (a stealth and a cleanse pressed together
--- do not step on each other).
---
--- Every step is a console command (or a function) with its longest wait.
--- The next step goes when the game reports this character's action ended
--- (spell, item, ability, weaponskill, or an interrupted cast) plus the
--- step's `delay`, or after its longest wait, whichever comes first. A spell
--- or an item the game refused without a word ("unable to cast spells at
--- this time") is sent again, up to MAX_TRIES sends (cast_tracker.lua).
--- The queue lives on `windower`, so a queue under way goes on across a job
--- change; a queue started after it gets a new generation.
--- push_next puts a step in front: a function step uses it to act right
--- after itself (decide at the last moment, then act).
---
--- A step may carry a `guard` (opts.guard): called just before the step
--- goes, it returns nil (go), 'skip' (this step is dropped), 'stop' (every
--- step of its tag is dropped), 'stop_magic' (the spells of its tag are
--- dropped) or 'before', steps (those go first, then this one). //gs c buff
--- uses it to stop when asleep and to cure Paralysis / Silence first
--- (shared/utils/buffs/buff_guard.lua).
---
--- @file shared/utils/core/action_queue.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01 (from shared/utils/stealth/stealth.lua)
---============================================================================

local ActionQueue = {}

local START_CHECK = 1.5  -- seconds for the game to start a spell / item once sent
local MAX_TRIES = 3      -- sends of one step before giving up on it

local function queue()
    windower._action_queue = windower._action_queue or {steps = {}, busy = false}
    return windower._action_queue
end

local function trace(tag, fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log(tag or 'QUEUE', fmt, unpack(args)) end)
end

--- Whether the game can refuse the command without a word: a spell or an
--- item sent too soon after the previous action simply never starts.
local function refusable(command)
    return type(command) == 'string' and (command:find('^input /ma') or command:find('^input /item')) ~= nil
end

local run_next

--- Arm the step's longest wait and, for a spell or an item, a check that it
--- really started. Not started after START_CHECK: sent again with a fresh
--- token and a fresh longest wait, up to MAX_TRIES sends.
local function arm(q, step, gen, tries)
    q.token = (q.token or 0) + 1
    local token = q.token
    q.waiting = type(step.command) ~= 'function' and {gen = gen, token = token, delay = step.delay} or nil
    local sent_at = os.clock()
    coroutine.schedule(function()
        if q.token == token then run_next(gen) end
    end, step.wait)
    if not refusable(step.command) or tries >= MAX_TRIES then return end
    coroutine.schedule(function()
        if q.token ~= token or gen ~= windower._action_gen_queue then return end
        local ok, CastTracker = pcall(require, 'shared/utils/core/cast_tracker')
        if not (ok and CastTracker) then return end
        local started
        if step.command:find('^input /ma') then
            started = CastTracker.started_since(sent_at)
        else
            started = CastTracker.acted_since(sent_at)
        end
        if started then return end
        trace(step.tag, 'not started, sent again: %s', step.command)
        send_command(step.command)
        arm(q, step, gen, tries + 1)
    end, START_CHECK)
end

run_next = function(gen)
    local q = queue()
    if gen ~= windower._action_gen_queue then return end
    local step = table.remove(q.steps, 1)
    if not step then
        q.busy = false
        q.waiting = nil
        return
    end
    if type(step.guard) == 'function' then
        local ok, verdict, first = pcall(step.guard, step)
        if ok and verdict == 'skip' then return run_next(gen) end
        if ok and (verdict == 'stop' or verdict == 'stop_magic') then
            local kept = {}
            for _, other in ipairs(q.steps) do
                local drop = other.tag == step.tag and (verdict == 'stop' or other.magic)
                if not drop then kept[#kept + 1] = other end
            end
            q.steps = kept
            if verdict == 'stop_magic' and not step.magic then table.insert(q.steps, 1, step) end
            return run_next(gen)
        end
        if ok and verdict == 'before' and type(first) == 'table' then
            table.insert(q.steps, 1, step)
            for i = #first, 1, -1 do table.insert(q.steps, 1, first[i]) end
            return run_next(gen)
        end
    end
    -- A function step sends actions of its own (or decides what comes next):
    -- only its longest wait ends it.
    if type(step.command) == 'function' then
        pcall(step.command)
    else
        send_command(step.command)
    end
    arm(q, step, gen, 1)
end

-- Action categories that end this character's action: 3 weapon skill,
-- 4 spell finished, 5 item finished, 6 job ability; 8 with param 28787 is
-- an interrupted cast.
local ENDS = {[3] = true, [4] = true, [5] = true, [6] = true}

local function on_action(act)
    local q = windower._action_queue
    local waiting = q and q.waiting
    if not (waiting and act and player and act.actor_id == player.id) then return end
    if not (ENDS[act.category] or (act.category == 8 and act.param == 28787)) then return end
    q.waiting = nil
    coroutine.schedule(function()
        if q.token == waiting.token then run_next(waiting.gen) end
    end, waiting.delay or 0)
end

--- Listen for this character's own actions (shared/utils/core/action_listener.lua:
--- the packet as the server sent it, one raw event for every module).
local function listen()
    if rawget(_G, '_action_queue_listener') then return end
    _G._action_queue_listener = true
    require('shared/utils/core/action_listener').on('action_queue', on_action)
end

--- Add an action; starts the queue when it was idle.
--- @param command string|function Console command, or a function run in turn
--- @param wait number Longest wait for this step, in seconds
--- @param opts table|nil {delay = seconds after the action ends, tag = trace tag,
---   guard = function(step), magic = true for a spell (see the header)}
function ActionQueue.push(command, wait, opts)
    listen()
    local q = queue()
    opts = opts or {}
    q.steps[#q.steps + 1] = {command = command, wait = wait, delay = opts.delay, tag = opts.tag,
        guard = opts.guard, magic = opts.magic}
    if q.busy then return end
    q.busy = true
    windower._action_gen_queue = (windower._action_gen_queue or 0) + 1
    run_next(windower._action_gen_queue)
end

--- Put a step in front of the queue (next to go), or start the queue.
--- @param command string|function
--- @param wait number Longest wait, in seconds
--- @param opts table|nil {delay, tag}
function ActionQueue.push_next(command, wait, opts)
    local q = queue()
    if not q.busy then return ActionQueue.push(command, wait, opts) end
    opts = opts or {}
    table.insert(q.steps, 1, {command = command, wait = wait, delay = opts.delay, tag = opts.tag,
        guard = opts.guard, magic = opts.magic})
end

--- Whether steps are still waiting to go.
--- @return boolean
function ActionQueue.busy()
    return queue().busy == true
end

return ActionQueue
