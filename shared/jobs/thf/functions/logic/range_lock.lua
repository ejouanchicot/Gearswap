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
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-19
---  ═══════════════════════════════════════════════════════════════════════════

local RangeLock = {}

--- Lock or unlock the range and ammo slots, and record which.
--- @param locked boolean True to lock, false to unlock
function RangeLock.set_slots(locked)
    -- Recorded with Combat Mode's lock registry too: it lays the lock again
    -- after `gs enable all` (//po), which frees it while RangeLock says On.
    local CombatMode = require('shared/utils/core/combat_mode')
    if locked then
        disable('range', 'ammo')
        CombatMode.hold('thf_range', {'range', 'ammo'})
    else
        enable('range', 'ammo')
        CombatMode.release('thf_range')
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

---  ═══════════════════════════════════════════════════════════════════════════
---   //gs c range: pull with the player's own ranged weapon
---  ═══════════════════════════════════════════════════════════════════════════

--- Ammo each ranged weapon type fires (res.items range_type -> ammo_type).
local AMMO_FOR = { Crossbow = 'Bolt', Bow = 'Arrow', Gun = 'Bullet', Cannon = 'Bullet' }

--- Range weapons and ammo by lower-case short and long name (built once:
--- sets write either, 'Exalted C.bow' or 'Exalted Crossbow').
local ranged_index = nil

--- The item of a slot value ('Acid Bolt' or {name = ...}), from res.items.
local function item_of(value)
    local name = type(value) == 'table' and value.name or value
    if type(name) ~= 'string' or name == '' or name:lower() == 'empty' then return nil end
    if not ranged_index then
        ranged_index = {}
        local res = rawget(_G, 'res') or require('resources')
        for _, it in pairs(res.items) do
            if type(it) == 'table' and (it.range_type or it.ammo_type) then
                if it.en then ranged_index[it.en:lower()] = it end
                if it.enl then ranged_index[it.enl:lower()] = ranged_index[it.enl:lower()] or it end
            end
        end
    end
    return ranged_index[name:lower()]
end

--- Whether an item carries a flag (resources give a set, the raw file a number).
local function has_flag(item, name, bits)
    local flags = item and item.flags
    if type(flags) == 'table' then return flags[name] == true end
    if type(flags) == 'number' then
        local all = true
        local b = 1
        while b <= bits do
            if bits % (b * 2) >= b and flags % (b * 2) < b then all = false end
            b = b * 2
        end
        return all
    end
    return false
end

--- Why this ammo must not be fired from this weapon, or nil when it may:
--- not ammo the weapon fires (a stat piece such as Coiste Bodhar, bolts in a
--- gun...), or precious ammo a shot would use up: Rare, or not stackable
--- (Hauksbok Arrow / Bullet). Ex alone is not a reason: the everyday ammo
--- (Chrono, Quelling, Eminent...) is Ex and sold by 99.
--- @param range table|nil Weapon item
--- @param ammo table|nil Ammo item
--- @return string|nil
function RangeLock.unsafe_ammo(range, ammo)
    if not range then return 'no ranged weapon in the set' end
    if not ammo then return 'no ammo in the set' end
    local wants = AMMO_FOR[range.range_type or '']
    if not wants or ammo.ammo_type ~= wants then
        return ammo.en .. ' is not ammo for ' .. range.en
    end
    if has_flag(ammo, 'Rare', 0x8000) or (tonumber(ammo.stack) or 99) <= 1 then
        return ammo.en .. ' is precious (Rare or one per stack): a shot would use it up'
    end
    return nil
end

--- The pull set: sets.RangeLock, else the range and ammo of sets.precast.RA.
--- @return table|nil set, string where it came from
local function pull_set()
    local s = rawget(_G, 'sets') or {}
    if type(s.RangeLock) == 'table' and s.RangeLock.range then return s.RangeLock, 'sets.RangeLock' end
    local ra = s.precast and s.precast.RA
    if type(ra) == 'table' and ra.range then
        return { range = ra.range, ammo = ra.ammo }, 'sets.precast.RA'
    end
    return nil, nil
end

--- //gs c range: equip the pull set, lock range + ammo, shoot the sub-target.
--- Order matters: equip, then lock (a locked slot refuses the equip), then
--- /ra. The shot is skipped, with the reason, when the ammo is unsafe.
function RangeLock.pull()
    local ok_m, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    local set, source = pull_set()
    if not set then
        RangeLock.engage()
        if ok_m then MessageFormatter.show_warning('range: no ranged weapon in sets.RangeLock or sets.precast.RA; locked what you wear, no shot') end
        return
    end
    equip({ range = set.range, ammo = set.ammo })
    RangeLock.engage()
    local ammo_name = type(set.ammo) == 'table' and set.ammo.name or set.ammo
    local ammo = item_of(set.ammo)
    local why = (ammo_name and not ammo) and (tostring(ammo_name) .. ' is not ammo (a piece worn for its stats)')
        or RangeLock.unsafe_ammo(item_of(set.range), ammo)
    if why then
        if ok_m then MessageFormatter.show_warning('range (' .. source .. '): ' .. why .. '. Not fired.') end
        return
    end
    send_command('wait 0.1; input /ra <stnpc>')
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
