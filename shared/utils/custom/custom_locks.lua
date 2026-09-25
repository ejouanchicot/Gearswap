---============================================================================
--- Custom Locks - slots a custom mode holds while its value is on
---============================================================================
--- A value block of <JOB>_CUSTOM.lua may carry `lock = {'main', 'sub'}`:
---   { state = 'WeaponLock', values = 'onoff', On = { lock = {'main', 'sub', 'range'} } }
---   { state = 'CP', values = 'onoff', On = { all = { back = "..." }, lock = {'back'} } }
--- While that value is current, those slots are disabled after the gear has
--- gone on (a lock set first would refuse the CP cape itself). When it is not,
--- the slots this module locked are enabled again, before the job's gear, so
--- the job can dress them.
---
--- GearSwap keeps a disabled slot across a job change. What this module
--- locked is recorded on `windower` (outlives the sandbox) and released when
--- the next job loads (CustomStates.load).
---
--- A weapon slot is never enabled while Combat Mode is On: that lock is
--- shared/utils/core/combat_mode.lua's.
---
--- @file    shared/utils/custom/custom_locks.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local CustomLocks = {}

local WEAPON_SLOTS = {main = true, sub = true, range = true, ammo = true}

local function locked()
    windower._custom_locked = windower._custom_locked or {}
    return windower._custom_locked
end

--- True when Combat Mode holds this weapon slot.
--- @param slot string
--- @return boolean
local function combat_mode_holds(slot)
    if not WEAPON_SLOTS[slot] then return false end
    local ok, CombatMode = pcall(require, 'shared/utils/core/combat_mode')
    return ok and CombatMode.is_on() or false
end

--- Enable the slots this module locked that `wanted` no longer names.
--- @param wanted table|nil Set of slot names still wanted (nil = none)
function CustomLocks.release(wanted)
    for slot in pairs(locked()) do
        if not (wanted and wanted[slot]) then
            if not combat_mode_holds(slot) then enable(slot) end
            locked()[slot] = nil
        end
    end
end

--- Disable every slot in `wanted`.
--- @param wanted table Set of slot names
function CustomLocks.apply(wanted)
    for slot in pairs(wanted) do
        disable(slot)
        locked()[slot] = true
    end
end

--- Add the slots of a block's `lock` list to `into`.
--- @param block table Active value block
--- @param into table Set, filled in
function CustomLocks.collect(block, into)
    if type(block.lock) ~= 'table' then return end
    for _, slot in ipairs(block.lock) do
        if type(slot) == 'string' then into[slot:lower()] = true end
    end
end

return CustomLocks
