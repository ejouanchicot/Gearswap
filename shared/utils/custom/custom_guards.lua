---============================================================================
--- Custom Guards - where the player's own gear must NOT go
---============================================================================
--- The custom gear is equipped last, so it wins over the job's choice. That
--- is the point, except where winning breaks something the player cannot
--- see from the config file. These are held back automatically:
---
---   Nothing at all
---     - while Doomed (the job's Doom handling owns the gear)
---     - for pet moves, ranged attacks and items (their own gear is required)
---     - on anything but Idle/Engaged (resting, dead, mounted)
---     - self-Paralyna while paralysed (WHM retries it without swapping)
---   Some slots
---     - Impact: body, head (Twilight Cloak is what lets it cast)
---     - songs: range, ammo (the instrument)
---     - Dispelga: main, sub
---     - Phantom Roll / Double-Up: rings (Luzaf's Ring)
---     - Call Beast / Bestial Loyalty: ammo (the jug)
---     - Hoxne stance: ammo (Hoxne Ampulla lock)
---     - Treasure Hunter wanted on this mob: the TH pieces, when engaged
---     - any slot the job has locked (disable)
---
--- @file    shared/utils/custom/custom_guards.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-24
---============================================================================

local Guards = {}

local Conditions = require('shared/utils/custom/custom_conditions')
local SLOT_IDS = Conditions.SLOT_IDS

--- Action types that carry gear of their own.
local HANDS_OFF_TYPES = {
    Monster = true, PetCommand = true, BloodPactRage = true, BloodPactWard = true,
    Item = true,
}

--- Slot names held back per action (by English name, then by type).
local SLOTS_BY_SPELL = {
    ['Impact'] = {'body', 'head'},
    ['Dispelga'] = {'main', 'sub'},
    ['Double-Up'] = {'ring1', 'ring2'},
    ['Call Beast'] = {'ammo'},
    ['Bestial Loyalty'] = {'ammo'},
}
local SLOTS_BY_TYPE = {
    BardSong = {'range', 'ammo'},
    CorsairRoll = {'ring1', 'ring2'},
}

local function add_slots(blocked, names)
    for _, name in ipairs(names or {}) do
        local id = SLOT_IDS[name]
        if id then blocked[id] = true end
    end
end

--- Whether the custom gear must stay out of this moment entirely.
--- @param spell table|nil The action (nil at idle/engaged)
--- @param eventArgs table|nil Mote event args
--- @return boolean
function Guards.hands_off(spell, eventArgs)
    if buffactive and buffactive['doom'] then return true end
    if eventArgs and (eventArgs.cancel or eventArgs.no_overlay) then return true end
    if not spell then
        local status = player and player.status
        -- No midaction() test: GearSwap still reports the action as under way
        -- while aftercast runs, which is when the gear is put back on.
        return status ~= 'Idle' and status ~= 'Engaged'
    end
    if spell.action_type == 'Ranged Attack' or spell.action_type == 'Item' then return true end
    if HANDS_OFF_TYPES[spell.type] then return true end
    return spell.english == 'Paralyna' and buffactive ~= nil and buffactive['paralysis'] ~= nil
end

--- Slot ids the custom gear must leave alone now.
--- @param moment string 'idle', 'engaged', 'precast', ...
--- @param spell table|nil
--- @return table Set of slot ids
function Guards.blocked_slots(moment, spell)
    local blocked = {}
    if spell then
        add_slots(blocked, SLOTS_BY_SPELL[spell.english])
        add_slots(blocked, SLOTS_BY_TYPE[spell.type])
    end
    if _G.ampulla_ammo_locked or (state and state.HybridMode and state.HybridMode.value == 'Hoxne') then
        blocked[SLOT_IDS.ammo] = true
    end
    if moment == 'engaged' and sets and sets.TreasureHunter and state and state.TreasureMode then
        local ok, TH = pcall(require, 'shared/jobs/thf/functions/logic/treasure_hunter')
        if ok and type(TH) == 'table' and TH.wants_engaged_th and TH.wants_engaged_th() then
            for slot in pairs(sets.TreasureHunter) do add_slots(blocked, {slot}) end
        end
    end
    local locks = gearswap and gearswap.disable_table
    if locks then
        for id = 0, 15 do
            if locks[id] then blocked[id] = true end
        end
    end
    return blocked
end

--- `gear` without the blocked slots (the same table when none is blocked).
--- @param gear table {slot = item}
--- @param blocked table Set of slot ids
--- @return table
function Guards.filter(gear, blocked)
    if next(blocked) == nil then return gear end
    local kept = {}
    for slot, item in pairs(gear) do
        local id = SLOT_IDS[slot]
        if id == nil or not blocked[id] then kept[slot] = item end
    end
    return kept
end

return Guards
