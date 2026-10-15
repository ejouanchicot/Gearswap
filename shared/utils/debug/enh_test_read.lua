---============================================================================
--- Enhancing Test - what the game shows of the character
---============================================================================
--- The readings shared/utils/debug/enh_test.lua makes, read from the game itself
--- (GearSwap's player table is only refreshed inside its own events, so from a
--- coroutine it can still show the moment before): the pieces really worn, the
--- vitals, the attributes and resistances of the stats packet 0x061.
---
--- @file shared/utils/debug/enh_test_read.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-14
---============================================================================

local Read = {}

Read.SLOTS = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear', 'body', 'hands',
    'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'}

local function res() return require('resources') end

--- The item worn in a slot, from the game's bags, or nil.
local function worn_item(equipment, slot)
    local index, bag = equipment[slot], equipment[slot .. '_bag']
    local item = index and index ~= 0 and bag and windower.ffxi.get_items(bag, index)
    return item and item.id and item.id ~= 0 and res().items[item.id] or nil
end

--- "sub=Ammurapi Shield, waist=Embla Sash": what is really worn, slot by slot.
--- @return string
function Read.worn_text()
    local equipment = (windower.ffxi.get_items() or {}).equipment or {}
    local parts = {}
    for _, slot in ipairs(Read.SLOTS) do
        local known = worn_item(equipment, slot)
        if known then parts[#parts + 1] = slot .. '=' .. known.en end
    end
    return #parts > 0 and table.concat(parts, ', ') or 'nothing'
end

--- "feet wants Leth. Houseaux +3": the slots of a case's set the game does not show worn, or nil when all are.
--- A slot left out of the set (weapons kept) is not looked at.
--- @param set table slot -> piece (a name, a table with .name, or empty)
--- @return string|nil
function Read.wrong_slots(set)
    local equipment = (windower.ffxi.get_items() or {}).equipment or {}
    local wrong = {}
    for _, slot in ipairs(Read.SLOTS) do
        local wanted = set[slot]
        if wanted ~= nil then
            local name = wanted ~= empty and (type(wanted) == 'table' and wanted.name or wanted) or nil
            local known = worn_item(equipment, slot)
            local worn_ok = name == nil and not known
                or known and type(name) == 'string' and (known.en:lower() == name:lower() or (known.enl or ''):lower() == name:lower())
            if not worn_ok then wrong[#wrong + 1] = slot .. ' wants ' .. tostring(name or 'nothing') end
        end
    end
    return #wrong > 0 and table.concat(wrong, ', ') or nil
end

--- The MP or HP now.
--- @param field string 'mp', 'hp', 'hpp', 'max_mp'...
--- @return number
function Read.vital(field)
    local vitals = (windower.ffxi.get_player() or {}).vitals
    return vitals and vitals[field] or 0
end

--- The stats packet 0x061 the game sent last, parsed, or nil.
local function stats_packet()
    local raw = windower.packets and windower.packets.last_incoming and windower.packets.last_incoming(0x061)
    local ok, packets = pcall(require, 'packets')
    local parsed = raw and ok and packets.parse('incoming', raw)
    return type(parsed) == 'table' and parsed or nil
end

--- "MND 173 VIT 138": attributes as the game last sent them, base plus what gear and buffs add.
--- @param stat string|table One name ('MND') or several ({'MND', 'VIT'})
--- @return string
function Read.stats_text(stat)
    local parsed, parts = stats_packet(), {}
    for _, name in ipairs(type(stat) == 'table' and stat or {stat}) do
        local value = parsed and (parsed['Base ' .. name] or 0) + (parsed['Added ' .. name] or 0)
        parts[#parts + 1] = name .. ' ' .. tostring(value)
    end
    return table.concat(parts, ' ')
end

--- An element's resistance as the game last sent it.
--- @param element string 'Fire', 'Ice', 'Wind', 'Earth', 'Lightning', 'Water', 'Light' or 'Dark'
--- @return number|nil
function Read.resist(element)
    local parsed = stats_packet()
    return parsed and parsed[element .. ' Resistance'] or nil
end

return Read
