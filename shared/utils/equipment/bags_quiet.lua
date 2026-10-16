---============================================================================
--- Bags Quiet - an action that reads the bags waits for them to stop moving
---============================================================================
--- /lockstyleset makes the game read the pieces of the style from the bags.
--- Sent while items are moving (PorterPacker's //po right after a job change,
--- a wardrobe tidy, a refill), it can make the game itself crash: Kaories,
--- 2026-10-16 21:02:43, FFXiMain.dll, the second the lockstyle of a GEO/DRK
--- load went out during a //po. BagsQuiet.run(fn) runs fn once the item count
--- of every bag (atelier_place.lua bag_counts, one cheap read per bag) stayed
--- the same QUIET checks in a row, STEP seconds apart. Still moving after
--- LIMIT seconds: fn is left out (said in the trace; //gs c lockstyle sends
--- the style again). Outside the game (no bag info), fn runs at once.
---
--- @file    shared/utils/equipment/bags_quiet.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-16
---============================================================================

local BagsQuiet = {}

local STEP, QUIET, LIMIT = 1.0, 2, 120

--- The item count of every bag, as one text; nil outside the game.
--- @return string|nil
local function counts()
    local ok, text = pcall(function() return require('shared/utils/atelier/atelier_place').bag_counts() end)
    return ok and text or nil
end

--- Run `fn` once the bags have stopped moving (see the header).
--- @param fn function The action
--- @param label string|nil What it is, for the trace ('lockstyle 12')
function BagsQuiet.run(fn, label)
    local last = counts()
    if last == nil then return fn() end
    local same, waited = 0, 0
    local function check()
        local now = counts()
        if now == last then same = same + 1 else same, last = 0, now end
        if same >= QUIET then return fn() end
        waited = waited + STEP
        if waited >= LIMIT then
            require('shared/utils/debug/trace_log').log('LOAD', '%s left out: the bags still move after %ds',
                tostring(label or 'action'), LIMIT)
            return
        end
        coroutine.schedule(check, STEP)
    end
    coroutine.schedule(check, STEP)
end

return BagsQuiet
