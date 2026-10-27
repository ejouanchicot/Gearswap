---  ═══════════════════════════════════════════════════════════════════════════
---   BST Ready Hold - keep a Ready move's set on until the pet's move lands
---  ═══════════════════════════════════════════════════════════════════════════
---   The pet's Ready move reads the master's gear at its IMPACT (JP blogs 2022 and
---   2023: gear swapped before the hit is not the gear counted). job_aftercast puts
---   the move's set on when the master's command ends; until the pet's action ends,
---   anything that re-equipped took it off: AutoMove sends //gs c update when the
---   player starts or stops moving, an engage changes the status. While the hold is
---   on, SetBuilder lays the move's set over the idle and engaged sets it builds, so
---   a re-equip keeps it. Released by the pet's own aftercast (job_pet_aftercast,
---   BST_AFTERCAST.lua), or after HOLD_MAX seconds when the move never lands (pet
---   dead or out of range, move refused): then //gs c update puts the normal set back.
---   Each step writes a READY line to //gs c trace.
---
---   @file    shared/jobs/bst/functions/logic/ready_hold.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-10-27
---  ═══════════════════════════════════════════════════════════════════════════

local ReadyHold = {}

local HOLD_MAX = 8.0   -- seconds : the longest a move takes to land (the pet may walk to its target)

local hold = nil       -- {set =, name =, at = os.clock(), gen =}
local gen = 0

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('READY', fmt, unpack(args)) end)
end

--- Hold `set` on for the move `name` (job_aftercast, right after it equips the set).
--- @param set table The Ready move's set
--- @param name string The move
function ReadyHold.start(set, name)
    gen = gen + 1
    local mine = gen
    hold = {set = set, name = name, at = os.clock(), gen = mine}
    trace('hold on : %s', name)
    -- the move never landed : let go, and put the normal set back (only this load's hold, only if still the same one)
    local ok, LoadGate = pcall(require, 'shared/utils/core/load_gate')
    local function expire()
        if hold and hold.gen == mine then
            trace('hold expired after %.0f s : %s', HOLD_MAX, hold.name)
            hold = nil
            send_command('gs c update')
        end
    end
    if ok and LoadGate and LoadGate.defer then LoadGate.defer(HOLD_MAX, expire, 'ready hold')
    else coroutine.schedule(expire, HOLD_MAX) end
end

--- The set held on, or nil.
--- @return table|nil
function ReadyHold.held()
    if hold and os.clock() - hold.at > HOLD_MAX + 1 then hold = nil end   -- safety : the deferred expiry was skipped
    return hold and hold.set or nil
end

--- The pet's move is over (job_pet_aftercast) : let go, before Mote puts the normal set back.
--- @param why string What ended it, for the trace
function ReadyHold.release(why)
    if not hold then return end
    trace('hold off (%s) after %.1f s : %s', why, os.clock() - hold.at, hold.name)
    hold = nil
end

_G.ReadyHold = ReadyHold
return ReadyHold
