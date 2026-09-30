---============================================================================
--- Impact Lock - the cloak that grants Impact stays on through the cast
---============================================================================
--- Impact is only known while a cloak that grants it is worn: Twilight Cloak
--- or Crepuscular Cloak (body, and it covers the head slot). GearSwap lets
--- the spell out when the precast can put the cloak on, and the spell fails
--- if the body changes before it lands. On every job:
---
---   precast of Impact  the cloak is picked and locked:
---                        1. the body of sets.precast.FC.Impact,
---                        2. else the body of sets.midcast.Impact,
---                           (either only when it is one of the two cloaks)
---                        3. else the cloak found in the equippable bags,
---                           Crepuscular first;
---                        none: a warning, nothing locked.
---   while locked       an equip hook (equip_hooks.lua, order 5) puts the
---                      cloak on every set equipped and drops their head
---                      piece (a head would push the cloak off)
---   aftercast / cancel the lock is lifted (before the aftercast equips), and
---                      it expires after LOCK_SECONDS in any case
---
--- @file shared/utils/equipment/impact_lock.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-30 (from BLM's own Twilight Cloak lock)
---============================================================================

local ImpactLock = {}

--- The items that grant Impact, best first (res.items ids).
local CLOAKS = {
    { id = 23799, name = 'Crepuscular Cloak' },
    { id = 11363, name = 'Twilight Cloak' },
}

--- A lock not lifted by an aftercast (a cast lost some other way) ends here.
local LOCK_SECONDS = 20

local LOCK_KEY = '_impact_lock'

--- Name of a slot value ({name = ...} or a string), lower case.
local function name_of(value)
    local name = type(value) == 'table' and value.name or value
    return type(name) == 'string' and name:lower() or nil
end

--- True when a slot value is one of the cloaks.
local function is_cloak(value)
    local name = name_of(value)
    if not name then return false end
    for _, c in ipairs(CLOAKS) do
        if name == c.name:lower() then return true end
    end
    return false
end

--- A cloak the character owns in an equippable bag, or nil.
local function owned_cloak()
    local res = rawget(_G, 'res') or require('resources')
    local all = windower.ffxi.get_items()
    for _, cloak in ipairs(CLOAKS) do
        for _, bag in pairs(res.bags) do
            local contents = bag.equippable and all and all[bag.api]
            for _, it in ipairs(type(contents) == 'table' and contents or {}) do
                if type(it) == 'table' and it.id == cloak.id then return cloak.name end
            end
        end
    end
    return nil
end

--- The cloak for this Impact: the player's sets first, then the bags.
--- @return string|table|nil
function ImpactLock.cloak()
    local s = rawget(_G, 'sets') or {}
    local fc = s.precast and s.precast.FC and s.precast.FC.Impact
    if type(fc) == 'table' and is_cloak(fc.body) then return fc.body end
    local mid = s.midcast and s.midcast.Impact
    if type(mid) == 'table' and is_cloak(mid.body) then return mid.body end
    return owned_cloak()
end

--- The lock in force, or nil (none, or expired).
function ImpactLock.current()
    local lock = rawget(_G, LOCK_KEY)
    if lock and os.time() - lock.at > LOCK_SECONDS then
        _G[LOCK_KEY] = nil
        return nil
    end
    return lock
end

--- Lift the lock.
function ImpactLock.release()
    _G[LOCK_KEY] = nil
end

--- Lock the cloak for an Impact about to be cast.
--- @return boolean True when a cloak was found
function ImpactLock.engage()
    local cloak = ImpactLock.cloak()
    if not cloak then
        _G[LOCK_KEY] = nil
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_warning('Impact: no Crepuscular or Twilight Cloak in your Impact sets or your wardrobes')
        end
        return false
    end
    _G[LOCK_KEY] = { body = cloak, at = os.time() }
    return true
end

--- Equip hook: the cloak on, and no head piece, while the lock holds.
--- @param set table
--- @return table
function ImpactLock.hook(set)
    local lock = ImpactLock.current()
    if not lock then return set end
    local copy = {}
    for k, v in pairs(set) do
        if k ~= 'head' then copy[k] = v end
    end
    copy.body = lock.body
    return copy
end

--- Wrap one global function once per load: `before(spell)` runs first.
local function wrap(name, before)
    local key = '_impact_wrapped_' .. name
    local fn = rawget(_G, name)
    if type(fn) ~= 'function' or rawget(_G, key) == fn then return end
    local wrapped = function(spell, ...)
        pcall(before, spell)
        return fn(spell, ...)
    end
    _G[key] = wrapped
    _G[name] = wrapped
end

--- Install for this job load (INIT_SYSTEMS): the equip hook, and the
--- precast / aftercast / cancel_spell wrappers that set and lift the lock.
function ImpactLock.install()
    ImpactLock.release()
    require('shared/utils/equipment/equip_hooks').add('impact_lock', 5, ImpactLock.hook)
    wrap('precast', function(spell)
        if type(spell) == 'table' and spell.english == 'Impact' then
            ImpactLock.engage()
        else
            ImpactLock.release()
        end
    end)
    wrap('aftercast', function(spell)
        if type(spell) == 'table' and spell.english == 'Impact' then ImpactLock.release() end
    end)
    wrap('cancel_spell', function() ImpactLock.release() end)
end

return ImpactLock
