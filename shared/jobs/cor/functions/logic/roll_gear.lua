---  ═══════════════════════════════════════════════════════════════════════════
---   Roll Gear - the "Phantom Roll +" value of the gear worn
---  ═══════════════════════════════════════════════════════════════════════════
---   Read by RollTracker when a roll result comes in (roll bonus shown in the
---   chat). The gear is read from the game, not from GearSwap's copy.
---
---   @file    shared/jobs/cor/functions/logic/roll_gear.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-28
---  ═══════════════════════════════════════════════════════════════════════════

local RollGear = {}

--- "Phantom Roll +" potency pieces. Only the highest one counts: they do not
--- add up (Compensator, Camulus's Mantle... give duration, not potency).
local PHANTOM_ROLL_GEAR = {
    {slots = {'main'}, pattern = 'Rostam', value = 8},
    {slots = {'main'}, pattern = 'Lanun Knife', value = 7},
    {slots = {'main'}, pattern = "Commodore'?s? Knife", value = 6},
    {slots = {'neck'}, pattern = 'Regal Necklace', value = 7},
    {slots = {'left_ring', 'right_ring'}, pattern = 'Barataria Ring', value = 5},
    {slots = {'left_ring', 'right_ring'}, pattern = 'Merirosvo Ring', value = 3},
}

--- Name of the item in `slot`, read from the game. The roll result comes
--- through PartyTracker's raw 'action' listener, outside GearSwap's events:
--- player.equipment there is GearSwap's copy from before the roll's precast,
--- so the roll gear (Regal Necklace...) was often missing from it.
--- @param slot string 'neck', 'left_ring'...
--- @return string|nil English item name, nil when empty or unreadable
local function worn_live(slot)
    local ok, eq = pcall(windower.ffxi.get_items, 'equipment')
    if not ok or type(eq) ~= 'table' then return nil end
    local index, bag = eq[slot], eq[slot .. '_bag']
    if not index or index == 0 or not bag then return nil end
    local ok_item, item = pcall(windower.ffxi.get_items, bag, index)
    if not ok_item or type(item) ~= 'table' or not item.id or item.id == 0 then return nil end
    -- GearSwap's own res (gearswap.res), items already loaded: no require
    -- here, which would load the whole item list on the first roll
    local gs = rawget(_G, 'gearswap')
    local resources = rawget(_G, 'res') or (gs and gs.res)
    local entry = resources and resources.items and resources.items[item.id]
    return entry and entry.en or nil
end

--- Item in `slot`: live from the game, GearSwap's copy as a fallback.
local function worn(slot)
    local live = worn_live(slot)
    if live then return live end
    local gear = player and player.equipment
    return gear and gear[slot]
end

--- Highest "Phantom Roll +" value in the gear worn right now.
--- @return number
function RollGear.bonus()
    local best = 0
    for _, piece in ipairs(PHANTOM_ROLL_GEAR) do
        for _, slot in ipairs(piece.slots) do
            local item = worn(slot)
            if type(item) == 'string' and item:match(piece.pattern) then
                best = math.max(best, piece.value)
            end
        end
    end
    return best
end

return RollGear
