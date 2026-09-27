---  ═══════════════════════════════════════════════════════════════════════════
---   Spell Gear Lock - a piece a spell cannot be cast without
---  ═══════════════════════════════════════════════════════════════════════════
---   Some spells only exist while a given piece is worn: Dispelga needs
---   Daybreak in the main hand. The piece goes on in precast, is held through
---   the cast (no set may take it off) and is released in aftercast - the
---   same shape as BRD's instrument lock (instrument_lock_config.lua).
---
---   Combat Mode On locks the weapon slots, and equip() on a locked slot is
---   dropped (set_merge sends it to not_sent_out_equip). So when the lock is
---   on, begin() opens only the slots the spell needs, and release() puts the
---   weapon that was there back, then lays the lock again. The swap still
---   costs the TP: that is the price of the spell, as with a Phantom Roll.
---
---   Wiring, per job that casts one of these spells:
---     • job_precast, last          -> SpellGearLock.begin(spell)
---     • job_post_precast, last     -> SpellGearLock.hold()
---     • job_post_midcast, last     -> SpellGearLock.hold()
---     • job_aftercast              -> SpellGearLock.release()
---
---   @file    shared/utils/equipment/spell_gear_lock.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-27
---  ═══════════════════════════════════════════════════════════════════════════

local SpellGearLock = {}

--- Spell (English name) -> the pieces it needs worn, by slot.
local REQUIRED = {
    ['Dispelga'] = {main = 'Daybreak'},
}

local unpack_list = table.unpack or unpack

--- The lock of the spell being cast (sandbox: gone on reload, like the cast).
local function current()
    return rawget(_G, '_spell_gear_lock')
end

local function combat_mode()
    local ok, CombatMode = pcall(require, 'shared/utils/core/combat_mode')
    return ok and CombatMode or nil
end

local function slot_list(gear)
    local slots = {}
    for slot in pairs(gear) do slots[#slots + 1] = slot end
    return slots
end

--- The pieces a spell needs, or nil.
--- @param spell table Spell from GearSwap
--- @return table|nil slot -> item name
function SpellGearLock.required(spell)
    return spell and REQUIRED[spell.english] or nil
end

--- Put the spell's pieces on and hold them for the cast.
--- @param spell table Spell from GearSwap
--- @return boolean True when the spell needs a piece
function SpellGearLock.begin(spell)
    local gear = SpellGearLock.required(spell)
    if not gear then return false end

    local CombatMode = combat_mode()
    local locked = CombatMode ~= nil and CombatMode.is_on()
    local previous = {}
    local worn = player and player.equipment or {}
    for slot in pairs(gear) do previous[slot] = worn[slot] end

    -- A lock left by a cast that never reached aftercast keeps what was
    -- worn before it, not the spell's own piece.
    local stale = current()
    if stale and stale.relock then previous = stale.previous end

    if locked then enable(unpack_list(slot_list(gear))) end
    equip(gear)
    _G._spell_gear_lock = {gear = gear, previous = previous, relock = locked}
    return true
end

--- Wear the spell's pieces again over whatever a set just equipped.
function SpellGearLock.hold()
    local lock = current()
    if lock then equip(lock.gear) end
end

--- End of the cast: with Combat Mode On, the previous weapon goes back and
--- the lock is laid again; Off, the job's sets bring the weapon back.
function SpellGearLock.release()
    local lock = current()
    if not lock then return end
    _G._spell_gear_lock = nil
    if not lock.relock then return end

    enable(unpack_list(slot_list(lock.gear)))
    equip(lock.previous)
    local CombatMode = combat_mode()
    if CombatMode then CombatMode.apply() end
end

return SpellGearLock
