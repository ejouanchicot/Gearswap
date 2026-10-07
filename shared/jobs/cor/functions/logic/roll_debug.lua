---============================================================================
--- COR Roll Debug - was the roll gear really on when the roll went off?
---============================================================================
--- //gs c rolldebug toggles it (switching it off prints the session summary).
--- For every Phantom Roll and Double-Up:
---   precast   note_precast (COR_PRECAST.job_post_precast) records the gear
---             GearSwap sends, the status, whether the player is moving,
---             Combat Mode, the slots GearSwap has locked and the pieces sent
---             that are in no equippable bag (inventory, wardrobes 1-8);
---   hold      note_held (roll_hold.lua) counts the gear updates held back
---             between the precast and the landing;
---   action    on_roll_action (PartyTracker's action listener), when the
---             roll lands: the gear actually worn, read from the game's
---             memory, is compared with what was sent.
--- The suspects it checks, each one a known way to lose the roll gear:
---   a piece NOT on at landing (sent, then replaced before the roll landed);
---   a gear update during the roll (AutoMove / status change: held since
---   2026-09-28, the count says how often it happened);
---   a piece not owned or out of reach (a satchel, sack, case...);
---   a locked slot (Combat Mode on main / sub / range, other disable());
---   the "Phantom Roll +" worn at landing against the one the roll message
---   uses (RollGear.bonus), and the status / movement at both ends.
--- A diagnostic tool: only when switched on, it writes to the chat
--- (InfoBlock) and appends the same lines to <Character>/logs/rolls/rolldebug.log.
---
--- @file    shared/jobs/cor/functions/logic/roll_debug.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2026-09-25 | Updated: 2026-09-28
---============================================================================

local RollDebug = {}

local SLOTS = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear',
    'body', 'hands', 'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'}

-- Bags GearSwap can equip from: inventory, wardrobes 1-8
local EQUIP_BAGS = {0, 8, 10, 11, 12, 13, 14, 15, 16}

function RollDebug.enabled()
    return windower._cor_roll_debug == true
end

local function stats()
    windower._cor_roll_debug_stats = windower._cor_roll_debug_stats
        or {rolls = 0, gear_lost = 0, held = 0, not_owned = 0, locked = 0}
    return windower._cor_roll_debug_stats
end

--- Toggle; returns the new state. Switching off prints the summary.
function RollDebug.toggle()
    windower._cor_roll_debug = not RollDebug.enabled()
    if windower._cor_roll_debug then
        windower._cor_roll_debug_stats = nil
    else
        RollDebug.show_summary()
    end
    return windower._cor_roll_debug
end

--- GearSwap's own res (items already loaded): no require('resources').
local function items_res()
    local gs = rawget(_G, 'gearswap')
    local resources = rawget(_G, 'res') or (gs and gs.res)
    return resources and resources.items
end

local function piece_name(piece)
    return type(piece) == 'table' and piece.name or piece
end

--- Lower-case names (en and enl) of everything in the equippable bags.
local function owned_names()
    local items, names = items_res(), {}
    if not items then return nil end
    for _, bag in ipairs(EQUIP_BAGS) do
        local ok, content = pcall(windower.ffxi.get_items, bag)
        for _, item in ipairs(ok and type(content) == 'table' and content or {}) do
            local data = type(item) == 'table' and item.id and item.id > 0 and items[item.id]
            if data then
                names[(data.en or ''):lower()] = true
                names[(data.enl or ''):lower()] = true
            end
        end
    end
    return names
end

--- Whether GearSwap has `slot` locked (Combat Mode, AmpullaLock, disable()).
local function slot_locked(slot)
    local gs = rawget(_G, 'gearswap')
    local ok, locked = pcall(function()
        return gs.disable_table[gs.slot_map[slot]] == true
    end)
    return ok and locked or false
end

local function moving()
    local auto_move = rawget(_G, 'AutoMove')
    local ok, is_moving = pcall(function() return auto_move and auto_move.is_moving() end)
    return ok and is_moving and 'moving' or 'still'
end

local function combat_mode_on()
    local ok, CombatMode = pcall(require, 'shared/utils/core/combat_mode')
    return ok and CombatMode and CombatMode.is_on() or false
end

--- Note what this roll's precast sends and in what conditions (only while enabled).
--- @param spell table
function RollDebug.note_precast(spell)
    if not RollDebug.enabled() then return end
    if not (spell.type == 'CorsairRoll' or spell.english == 'Double-Up') then return end
    local sent = {}
    for slot, piece in pairs(gearswap and gearswap.equip_list or {}) do
        local name = piece_name(piece)
        if type(name) == 'string' and name ~= '' and name ~= 'empty' then sent[slot] = name end
    end
    local owned, not_owned, locked = owned_names(), {}, {}
    for slot, name in pairs(sent) do
        if owned and not owned[name:lower()] then not_owned[#not_owned + 1] = name end
        if slot_locked(slot) then locked[#locked + 1] = slot end
    end
    windower._cor_roll_debug_sent = {
        spell = spell.english, sent = sent, at = os.clock(), held = 0,
        status = player and player.status or '?', moving = moving(),
        combat_mode = combat_mode_on(), not_owned = not_owned, locked = locked,
    }
end

--- A gear update was held back during the roll (roll_hold.lua).
function RollDebug.note_held()
    local noted = windower._cor_roll_debug_sent
    if RollDebug.enabled() and noted then noted.held = (noted.held or 0) + 1 end
end

--- Gear worn now, read from the game: slot -> {en, enl}.
local function worn_now()
    local items = items_res()
    local ok, all = pcall(windower.ffxi.get_items)
    local equipment = ok and all and all.equipment or {}
    local worn = {}
    for _, slot in ipairs(SLOTS) do
        local index, bag = equipment[slot], equipment[slot .. '_bag']
        if index and index > 0 and bag then
            local item = windower.ffxi.get_items(bag, index)
            local data = items and item and item.id and items[item.id]
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

--- Fields for the gear sent at precast against the gear worn at landing.
local function gear_fields(noted, worn, fields, count)
    local missing, total = 0, 0
    for _, slot in ipairs(SLOTS) do
        local name = noted.sent[slot]
        if name then
            total = total + 1
            if not same(name, worn[slot]) then
                missing = missing + 1
                fields[#fields + 1] = {slot, ('%s NOT on (worn: %s)'):format(name, worn[slot] and worn[slot].en or 'nothing'), 'bad'}
            end
        end
    end
    fields[#fields + 1] = {'Pieces on', ('%d / %d'):format(total - missing, total), missing == 0 and 'good' or 'bad'}
    count.gear_lost = count.gear_lost + (missing > 0 and 1 or 0)
end

--- Fields for the conditions noted at precast (and the suspects found).
local function condition_fields(noted, fields, count)
    fields[#fields + 1] = {'Precast -> landing', ('%.2f s'):format(os.clock() - noted.at)}
    fields[#fields + 1] = {'Status', ('%s, %s -> %s, %s'):format(noted.status, noted.moving,
        player and player.status or '?', moving())}
    local held_mark = nil
    if (noted.held or 0) > 0 then held_mark = 'warn' end
    fields[#fields + 1] = {'Updates held', tostring(noted.held or 0), held_mark}
    count.held = count.held + (noted.held or 0)
    if #noted.not_owned > 0 then
        fields[#fields + 1] = {'Not in reach', table.concat(noted.not_owned, ', ') .. ' (not in inventory / wardrobes)', 'bad'}
        count.not_owned = count.not_owned + 1
    end
    if #noted.locked > 0 then
        fields[#fields + 1] = {'Slots locked', table.concat(noted.locked, ', ') .. (noted.combat_mode and ' (Combat Mode On)' or ''), 'warn'}
        count.locked = count.locked + 1
    end
end

--- "Phantom Roll +" worn at landing against the value the roll message uses.
local function bonus_fields(worn, fields)
    local plus = 0
    local ok, RollGear = pcall(require, 'shared/jobs/cor/functions/logic/roll_gear')
    for _, slot in ipairs(SLOTS) do
        for _, piece in ipairs(ok and RollGear.PIECES or {}) do
            if worn[slot] and worn[slot].en and worn[slot].en:match(piece.pattern) then
                plus = math.max(plus, piece.value)
            end
        end
    end
    local shown = ok and RollGear.bonus() or plus
    local mark = nil
    if plus ~= shown then mark = 'bad' end
    fields[#fields + 1] = {'Phantom Roll +', ('%d worn, %d counted by the message'):format(plus, shown), mark}
end

--- Report the gear worn when the roll's action packet arrived.
--- @param roll_name string
function RollDebug.on_roll_action(roll_name)
    if not RollDebug.enabled() then return end
    local noted = windower._cor_roll_debug_sent
    local worn = worn_now()
    local fields, count = {}, stats()
    count.rolls = count.rolls + 1
    if noted then
        gear_fields(noted, worn, fields, count)
        condition_fields(noted, fields, count)
    else
        fields[#fields + 1] = {'Sent at precast', 'not seen (rolled from outside GearSwap?)', 'warn'}
    end
    bonus_fields(worn, fields)
    windower._cor_roll_debug_sent = nil
    require('shared/utils/messages/info_block').show({tag = 'ROLLDBG', title = roll_name, fields = fields})
    RollDebug.write_log(roll_name, fields)
end

--- Session summary (on switching the debug off).
function RollDebug.show_summary()
    local count = windower._cor_roll_debug_stats
    if not count or count.rolls == 0 then return end
    local fields = {
        {'Rolls seen', tostring(count.rolls)},
        {'Gear missing at landing', tostring(count.gear_lost), count.gear_lost > 0 and 'bad' or 'good'},
        {'Updates held during rolls', tostring(count.held)},
        {'Rolls with a piece out of reach', tostring(count.not_owned), count.not_owned > 0 and 'bad' or 'good'},
        {'Rolls with a locked slot', tostring(count.locked), count.locked > 0 and 'warn' or 'good'},
    }
    require('shared/utils/messages/info_block').show({tag = 'ROLLDBG', title = 'Summary', fields = fields})
    RollDebug.write_log('SUMMARY', fields)
end

--- Append a report to <Character>/logs/rolls/rolldebug.log.
--- @param roll_name string
--- @param fields table InfoBlock fields
function RollDebug.write_log(roll_name, fields)
    if not (player and player.name and windower.addon_path) then return end
    local file = io.open(require('shared/utils/core/char_paths').log('rolls', 'rolldebug.log'), 'a')
    if not file then return end
    local status = player.status or '?'
    file:write(('%s  %s  (%s)\n'):format(os.date('%H:%M:%S'), roll_name, status))
    for _, f in ipairs(fields) do file:write(('    %s: %s\n'):format(f[1], tostring(f[2]))) end
    file:close()
end

return RollDebug
