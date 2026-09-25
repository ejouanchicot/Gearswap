---============================================================================
--- Cast Tracker - did this character's cast start?
---============================================================================
--- Listens to this character's action packets:
---   category 8, param 24931  a spell starts casting
---   any category             this character acted (a job ability first...)
--- A /ma the game refused never starts: callers (song_queue.lua) learn it in
--- a second or two instead of waiting for a timeout.
---
--- @file    shared/utils/core/cast_tracker.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local CastTracker = {}

local CATEGORY_CASTING = 8
local PARAM_START = 24931

local function store()
    windower._cast_tracker = windower._cast_tracker or {last_action = 0, last_start = 0}
    return windower._cast_tracker
end

local function on_action(act)
    local me = windower.ffxi.get_player()
    if not me or act.actor_id ~= me.id then return end
    local s = store()
    s.last_action = os.clock()
    if act.category == CATEGORY_CASTING and act.param == PARAM_START then
        s.last_start = s.last_action
    end
end

--- Listen to the action packets, once per load (the sandbox drops the
--- listener at the next one). Called from INIT_SYSTEMS.
function CastTracker.start()
    if rawget(_G, '_cast_tracker_listening') or not windower.raw_register_event then return end
    _G._cast_tracker_listening = true
    windower.raw_register_event('action', on_action)
end

--- Whether a spell started casting after `since` (os.clock()).
--- @param since number
--- @return boolean
function CastTracker.started_since(since)
    return store().last_start >= since
end

--- Whether this character did anything (ability, cast...) after `since`.
--- @param since number
--- @return boolean
function CastTracker.acted_since(since)
    return store().last_action >= since
end

return CastTracker
