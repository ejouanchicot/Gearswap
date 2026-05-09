---  ═══════════════════════════════════════════════════════════════════════════
---   Refill Panels - In-game ASCII display (74-char width, project-standard)
---  ═══════════════════════════════════════════════════════════════════════════
---   All UI rendering for the refill operation:
---     • banner / section / kv / divider / separator   (low-level builders)
---     • show_error                                     (one-line tagged error)
---     • show_start                                     (start banner + config)
---     • show_progress                                  (transferring N ops)
---     • show_report                                    (final per-item table)
---
---   Color palette aligned with shared/utils/messages/core/message_engine.lua.
---   Item names are color-coded: brown=food, pink=ammo, healgreen=medicine.
---
---   @file    shared/utils/inventory/refill/refill_panels.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from refill_manager.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local RefillPanels = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CONSTANTS
---  ═══════════════════════════════════════════════════════════════════════════

local CHANNEL = 121
local WIDTH = 74
local SEP = string.rep('=', WIDTH)
local SUBSEP = string.rep('-', WIDTH)

-- Inline FFXI color codes
local C = {
    gray = string.char(0x1F, 160),
    yellow = string.char(0x1F, 50),     -- status values (kv, OK, refill counts)
    green = string.char(0x1F, 158),     -- bright green (legacy)
    healgreen = string.char(0x1F, 6),   -- pale green - medicine names
    red = string.char(0x1F, 167),
    cyan = string.char(0x1F, 123),
    white = string.char(0x1F, 1),
    orange = string.char(0x1F, 205),    -- transfer / partial refill totals
    brown = string.char(0x1F, 65),      -- food names
    pink = string.char(0x1F, 11)        -- ammo/quiver names (weapon theme)
}

--- Detect food items by name keyword.
local FOOD_KEYWORDS = {
    'sushi', 'curry', 'gyudon', 'crepe', 'sandwich', 'soup', 'stew', 'taco',
    'pizza', 'paella', 'pie', 'cake', 'salad', 'omelette', 'riceball',
    'dumpling', 'bun', 'pumpkin', 'cookie', 'daifuku', 'rolanberry', 'ration',
    'rusk', 'macaron', 'tart', 'rice', 'bread', 'noodle', 'pasta'
}

--- Detect ammo/quiver items.
local AMMO_KEYWORDS = {'bolt', 'arrow', 'bullet', 'shuriken', 'quiver', 'cartridge'}

---  ═══════════════════════════════════════════════════════════════════════════
---   LOW-LEVEL BUILDERS (private)
---  ═══════════════════════════════════════════════════════════════════════════

local function send(line)
    windower.add_to_chat(CHANNEL, line)
end

local function separator()
    send(C.gray .. SEP)
end

--- 3-line banner block (project standard, 74-char wide).
--- Middle line has +1 '=' on each side (total +2) so the variable-width FFXI
--- font makes the title row visually match the outer rules.
local function banner(title)
    local padded = ' ' .. title .. ' '
    local total = math.max(2, WIDTH - #padded) + 4 -- +4 visual compensation
    local left = math.floor(total / 2)
    local right = total - left
    send(C.gray .. SEP)
    send(C.gray .. string.rep('=', left) .. C.yellow .. padded .. C.gray .. string.rep('=', right))
    send(C.gray .. SEP)
end

--- Simple key/value row: "  label: value"
local function kv(label, value)
    send('  ' .. C.cyan .. label .. C.gray .. ': ' .. C.yellow .. tostring(value))
end

--- Tag-prefixed status line: [Refill] message
local function tagged(color, msg)
    send(C.gray .. '[' .. C.cyan .. 'Refill' .. C.gray .. ']' .. C.white .. ' ' .. color .. msg)
end

local function is_food(name)
    local n = name:lower()
    for _, kw in ipairs(FOOD_KEYWORDS) do
        if n:find(kw, 1, true) then
            return true
        end
    end
    return false
end

local function is_ammo(name)
    local n = name:lower()
    for _, kw in ipairs(AMMO_KEYWORDS) do
        if n:find(kw, 1, true) then
            return true
        end
    end
    return false
end

--- Per-item status row: "  Name: status".
--- Name color depends on category:
---   • brown     = food (Earth theme)
---   • pink      = ammo/quivers (weapon theme)
---   • healgreen = medicine (default - pale green)
local function item_row(name, value_str)
    local name_color
    if is_food(name) then
        name_color = C.brown
    elseif is_ammo(name) then
        name_color = C.pink
    else
        name_color = C.healgreen
    end
    send('  ' .. name_color .. name .. C.gray .. ': ' .. value_str)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- One-line tagged error message in red.
--- @param msg string
function RefillPanels.show_error(msg)
    tagged(C.red, msg)
end

--- Start banner: shown when refill begins, with config + scope info.
--- @param source_label string  e.g. "BLM/default" or "CRAFT (Bonecraft)"
--- @param store_display string e.g. "Case" or "Sack"
--- @param item_count number    Number of items in the refill list
function RefillPanels.show_start(source_label, store_display, item_count)
    banner('Inventory Refill - Started')
    kv('Config', source_label)
    kv('Surplus bag', store_display)
    kv('Items tracked', tostring(item_count))
end

--- Progress notice: shown when transfers are about to begin.
--- @param op_count number  Number of move operations queued
function RefillPanels.show_progress(op_count)
    tagged(C.orange, ('Transferring %d operation%s ...'):format(op_count, op_count == 1 and '' or 's'))
end

--- Final report: per-item lines + totals.
--- @param results table List of {name, target, current, deficit, moved, short,
---                source, surplus, surplus_dest, is_foreign}
function RefillPanels.show_report(results)
    banner('Inventory Refill - Complete')

    local total_moved = 0
    local total_short = 0
    local total_surplus = 0

    for _, r in ipairs(results) do
        if r.is_foreign then
            -- FOREIGN: belongs to another job's list, fully pushed back
            item_row(r.name, C.cyan .. 'foreign (' .. r.surplus .. ') -> ' .. (r.surplus_dest or 'Case'))
            total_surplus = total_surplus + r.surplus
        elseif r.surplus and r.surplus > 0 then
            -- SURPLUS: had more than target, excess pushed back
            item_row(
                r.name,
                C.orange .. r.current .. '/' .. r.target ..
                    C.gray .. ' -> ' ..
                    C.yellow .. r.target .. '/' .. r.target ..
                    C.gray .. '  (-' .. r.surplus .. ' -> ' .. (r.surplus_dest or 'Case') .. ')'
            )
            total_surplus = total_surplus + r.surplus
        elseif r.deficit <= 0 then
            -- Already at target: status in yellow
            item_row(r.name, C.yellow .. r.current .. '/' .. r.target .. ' (OK)')
        elseif r.moved > 0 and r.short <= 0 then
            -- Fully refilled: source -> target, both shown
            item_row(
                r.name,
                C.gray .. r.current .. '/' .. r.target ..
                    C.gray .. ' -> ' ..
                    C.yellow .. (r.current + r.moved) .. '/' .. r.target ..
                    C.gray .. '  (+' .. r.moved .. ' ' .. r.source .. ')'
            )
            total_moved = total_moved + r.moved
        elseif r.moved > 0 and r.short > 0 then
            -- Partially refilled
            item_row(
                r.name,
                C.gray .. r.current .. '/' .. r.target ..
                    ' -> ' ..
                    C.orange .. (r.current + r.moved) .. '/' .. r.target ..
                    C.gray .. '  (+' .. r.moved .. ' ' .. r.source .. ')' ..
                    C.red .. '  Short ' .. r.short
            )
            total_moved = total_moved + r.moved
            total_short = total_short + r.short
        else
            -- Nothing available at all
            item_row(r.name, C.red .. r.current .. '/' .. r.target .. '  Out of stock! Short ' .. r.short)
            total_short = total_short + r.short
        end
    end

    if total_moved > 0 then
        kv('Pulled in', total_moved .. ' item(s)')
    end
    if total_surplus > 0 then
        kv('Pushed out', total_surplus .. ' item(s) (surplus)')
    end
    if total_short > 0 then
        kv('Missing', total_short .. ' item(s) - restock Case/Sack!')
    end
    if total_moved == 0 and total_short == 0 and total_surplus == 0 then
        kv('Status', 'Inventory already complete')
    end
    separator()
end

return RefillPanels
