---============================================================================
--- COR Roll Debug - was the roll gear really on when the roll went off?
---============================================================================
--- //gs c rolldebug toggles it. For every Phantom Roll and Double-Up:
---   precast   the gear GearSwap sends is noted (note_precast, from
---             COR_PRECAST.job_post_precast);
---   action    when the game's action packet for the roll arrives, the gear
---             actually worn is read from the game's memory
---             (windower.ffxi.get_items), not from player.equipment, which
---             GearSwap only refreshes on its own events.
--- The block names every piece sent but not worn at that moment, the time
--- between the two, and the "Phantom Roll +" worn. A diagnostic tool: only
--- when switched on, it writes to the chat (InfoBlock) and appends the same
--- lines to <Character>/rolldebug.log, readable outside the game.
---
--- @file    shared/jobs/cor/functions/logic/roll_debug.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local RollDebug = {}

local SLOTS = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear',
    'body', 'hands', 'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'}

--- "Phantom Roll +" pieces (same values as roll_tracker.lua)
local ROLL_PLUS = {
    {'Rostam', 8}, {'Lanun Knife', 7}, {"Commodore'?s? Knife", 6},
    {'Regal Necklace', 7}, {'Barataria Ring', 5}, {'Merirosvo Ring', 3},
}

function RollDebug.enabled()
    return windower._cor_roll_debug == true
end

--- Toggle; returns the new state.
function RollDebug.toggle()
    windower._cor_roll_debug = not RollDebug.enabled()
    return windower._cor_roll_debug
end

local function piece_name(piece)
    return type(piece) == 'table' and piece.name or piece
end

--- Note what this roll's precast sends (only while enabled).
--- @param spell table
function RollDebug.note_precast(spell)
    if not RollDebug.enabled() then return end
    if not (spell.type == 'CorsairRoll' or spell.english == 'Double-Up') then return end
    local sent = {}
    for slot, piece in pairs(gearswap and gearswap.equip_list or {}) do
        local name = piece_name(piece)
        if type(name) == 'string' and name ~= '' and name ~= 'empty' then sent[slot] = name end
    end
    windower._cor_roll_debug_sent = {spell = spell.english, sent = sent, at = os.clock()}
end

--- Gear worn now, read from the game: slot -> {en, enl}.
local function worn_now()
    local ok, res = pcall(require, 'resources')
    local items = windower.ffxi.get_items()
    local equipment = items and items.equipment or {}
    local worn = {}
    for _, slot in ipairs(SLOTS) do
        local index, bag = equipment[slot], equipment[slot .. '_bag']
        if index and index > 0 and bag then
            local item = windower.ffxi.get_items(bag, index)
            local data = ok and item and item.id and res.items[item.id]
            if data then worn[slot] = {en = data.en, enl = data.enl} end
        end
    end
    return worn
end

local function same(name, worn)
    if not worn or not name then return false end
    local n = name:lower()
    return (worn.en and worn.en:lower() == n) or (worn.enl and worn.enl:lower() == n) or false
end

--- Report the gear worn when the roll's action packet arrived.
--- @param roll_name string
function RollDebug.on_roll_action(roll_name)
    if not RollDebug.enabled() then return end
    local noted = windower._cor_roll_debug_sent
    local worn = worn_now()
    local fields, missing, count = {}, 0, 0
    if noted then
        fields[#fields + 1] = {'Sent at precast', ('%.2f s before'):format(os.clock() - noted.at)}
        for _, slot in ipairs(SLOTS) do
            local name = noted.sent[slot]
            if name then
                count = count + 1
                if not same(name, worn[slot]) then
                    missing = missing + 1
                    fields[#fields + 1] = {slot, ('%s NOT on (worn: %s)'):format(name, worn[slot] and worn[slot].en or 'nothing'), 'bad'}
                end
            end
        end
        fields[#fields + 1] = {'Pieces on', ('%d / %d'):format(count - missing, count), missing == 0 and 'good' or 'bad'}
    else
        fields[#fields + 1] = {'Sent at precast', 'not seen (rolled from outside GearSwap?)', 'warn'}
    end
    local plus = 0
    for _, slot in ipairs(SLOTS) do
        for _, p in ipairs(ROLL_PLUS) do
            if worn[slot] and worn[slot].en and worn[slot].en:match(p[1]) then plus = math.max(plus, p[2]) end
        end
    end
    fields[#fields + 1] = {'Phantom Roll +', tostring(plus)}
    require('shared/utils/messages/info_block').show({tag = 'ROLLDBG', title = roll_name, fields = fields})
    RollDebug.write_log(roll_name, fields)
end

--- Append a report to <Character>/rolldebug.log.
--- @param roll_name string
--- @param fields table InfoBlock fields
function RollDebug.write_log(roll_name, fields)
    if not (player and player.name and windower.addon_path) then return end
    local file = io.open(('%sdata/%s/rolldebug.log'):format(windower.addon_path, player.name), 'a')
    if not file then return end
    local status = player.status or '?'
    file:write(('%s  %s  (%s)\n'):format(os.date('%H:%M:%S'), roll_name, status))
    for _, f in ipairs(fields) do file:write(('    %s: %s\n'):format(f[1], tostring(f[2]))) end
    file:close()
end

return RollDebug
