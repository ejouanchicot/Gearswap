---  ═══════════════════════════════════════════════════════════════════════════
---   Range Lock - Range/ammo slot lock kept in step with state.RangeLock
---  ═══════════════════════════════════════════════════════════════════════════
---   Locks and unlocks the range and ammo slots together with state.RangeLock
---   (the RangeLock key, every /ra, //gs c range).
---
---   GearSwap keeps slot locks in its own table, which outlives the job file:
---   a lock left in place survives gs reload, subjob and main job changes,
---   while state.RangeLock goes back to Off on every load. The lock placed
---   here is therefore recorded in the sandbox and released by the entry
---   file's file_unload, before the next job file loads.
---
---   @file    shared/jobs/thf/functions/logic/range_lock.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-19
---  ═══════════════════════════════════════════════════════════════════════════

local RangeLock = {}

--- Lock or unlock the range and ammo slots, and record which.
--- @param locked boolean True to lock, false to unlock
function RangeLock.set_slots(locked)
    if locked then
        disable('range', 'ammo')
    else
        enable('range', 'ammo')
    end
    _G.thf_range_locked = locked
end

--- Lock the slots and turn state.RangeLock on (used by /ra and //gs c range).
--- Mode:set() does not call job_state_change, so the HUD is refreshed here
--- when the state actually changes.
function RangeLock.engage()
    RangeLock.set_slots(true)

    if state and state.RangeLock and state.RangeLock.value ~= true then
        state.RangeLock:set(true)
        local ok, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
        if ok and KeybindUI and KeybindUI.update then
            KeybindUI.update()
        end
    end
end

--- Release the lock this module placed, if any (entry file_unload).
function RangeLock.release()
    if _G.thf_range_locked then
        RangeLock.set_slots(false)
    end
end

--- Put state.RangeLock back on when the slots are still locked.
--- A subjob change re-runs user_setup() in the same sandbox, which recreates
--- the state at Off until the reload that follows releases the lock.
function RangeLock.sync_state()
    if _G.thf_range_locked and state and state.RangeLock then
        state.RangeLock:set(true)
    end
end

return RangeLock
