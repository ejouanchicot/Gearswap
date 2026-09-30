---============================================================================
--- Duplicate Gear - which copy of a doubled item each side takes
---============================================================================
--- Two copies of the same item (Chirich Ring +1, Moonlight Ring, Stikini Ring
--- +1...) are the same name to GearSwap. Left alone it may take, for the
--- right hand, the copy the left hand already wears (the game then moves it
--- and one side ends up empty), or move a copy from one side to the other
--- between two sets (a Moonlight Ring taken off costs its HP).
---
--- This equip hook (equip_hooks.lua, before the HP priority) gives each side
--- of a pair (rings, earrings, main / sub) its own copy, by naming the bag
--- that copy is in (GearSwap's `bag` field), for a piece the set names
--- without a bag and without augments:
---   1. the copy this side already wears, if it is one;
---   2. else a copy no slot wears;
---   3. else any copy the other side of the set does not take.
--- A piece that already names its bag or its augments is left as written.
--- Two copies in the same bag cannot be told apart by bag: a warning (once
--- per session and item) says //gs c wo spreads them (the organizer puts
--- one copy per USED bag, rules.lua).
---
--- The copies are read from the bags at most every CACHE_SECONDS.
---
--- @file shared/utils/equipment/duplicate_gear.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-30
---============================================================================

local DuplicateGear = {}

local CACHE_SECONDS = 5

--- Slot pairs: the names a set may use for each side, and the name of the
--- slot in windower's equipment table.
local PAIRS = {
    { left = { 'left_ring', 'ring1', 'lring' }, right = { 'right_ring', 'ring2', 'rring' },
      worn_left = 'left_ring', worn_right = 'right_ring' },
    { left = { 'left_ear', 'ear1', 'lear' }, right = { 'right_ear', 'ear2', 'rear' },
      worn_left = 'left_ear', worn_right = 'right_ear' },
    { left = { 'main' }, right = { 'sub' }, worn_left = 'main', worn_right = 'sub' },
}

--- Equipment slots whose worn copy counts as taken.
local WORN_SLOTS = { 'main', 'sub', 'left_ear', 'right_ear', 'left_ring', 'right_ring' }

local cache = { at = -math.huge, copies = {}, worn = {} }

--- Read the equippable bags: every name owned in 2+ copies, with the bag
--- and index of each copy, and which copy each slot wears.
--- True when a copy carries augments: GearSwap tells such copies apart by
--- their augments (a set that names the augments picks the right one).
local function augmented(it, extdata)
    if not extdata then return false end
    local ok, ext = pcall(extdata.decode, it)
    return ok and ext and type(ext.augments) == 'table' and #ext.augments > 0
end

local function scan()
    local res = rawget(_G, 'res') or require('resources')
    local ok_x, extdata = pcall(require, 'extdata')
    if not ok_x then extdata = nil end
    local all = windower.ffxi.get_items()
    local copies = {}
    for bag_id, bag in pairs(res.bags) do
        local contents = bag.equippable and all and all[bag.api]
        for index, it in ipairs(type(contents) == 'table' and contents or {}) do
            if type(it) == 'table' and (it.id or 0) > 0 and (it.status == 0 or it.status == 5)
                and not augmented(it, extdata) then
                local info = res.items[it.id]
                if info and info.en then
                    -- A set may write the short or the long name: one list for both
                    local key = info.en:lower()
                    copies[key] = copies[key] or {}
                    table.insert(copies[key], { bag = bag_id, index = index, api = bag.api })
                    if info.enl and info.enl:lower() ~= key then copies[info.enl:lower()] = copies[key] end
                end
            end
        end
    end
    local doubled = {}
    local sorted = {}
    for key, list in pairs(copies) do
        if #list > 1 then
            if not sorted[list] then
                sorted[list] = true
                table.sort(list, function(a, b) return a.bag < b.bag or (a.bag == b.bag and a.index < b.index) end)
            end
            doubled[key] = list
        end
    end
    local worn = {}
    local eq = all and all.equipment or {}
    for _, slot in ipairs(WORN_SLOTS) do
        if (eq[slot] or 0) > 0 then worn[slot] = { bag = eq[slot .. '_bag'], index = eq[slot] } end
    end
    cache = { at = os.clock(), copies = doubled, worn = worn }
end

--- The doubled items and the worn copies, re-read when older than CACHE_SECONDS.
local function current()
    if os.clock() - cache.at > CACHE_SECONDS then pcall(scan) end
    return cache
end

--- Forget the last read (a job load, or after //gs c wo moved gear).
function DuplicateGear.invalidate()
    cache.at = -math.huge
end

--- Name of a slot value when it is a piece this hook may place.
local function placeable_name(value)
    if type(value) == 'string' and value ~= '' and value:lower() ~= 'empty' then return value end
    if type(value) == 'table' and type(value.name) == 'string' and not value.bag
        and not (type(value.augments) == 'table' and #value.augments > 0) and not value.augment then
        return value.name
    end
    return nil
end

local function same_copy(a, b)
    return a and b and a.bag == b.bag and a.index == b.index
end

--- Warn once per session that the copies of an item share one bag.
local function warn_same_bag(name)
    windower._dup_gear_warned = windower._dup_gear_warned or {}
    if windower._dup_gear_warned[name:lower()] then return end
    windower._dup_gear_warned[name:lower()] = true
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter then
        MessageFormatter.show_warning(name .. ': your copies are in the same bag, so GearSwap cannot tell them apart. //gs c wo puts one in each wardrobe.')
    end
end

--- The copy one side takes (nil to leave the piece as written).
--- @param list table Copies of the item
--- @param worn_here table|nil Copy worn in this slot
--- @param st table Cache (worn copies)
--- @param taken table|nil Copy the other side of this set takes
local function pick(list, worn_here, st, taken)
    for _, c in ipairs(list) do
        if same_copy(c, worn_here) and not same_copy(c, taken) then return c end
    end
    for _, c in ipairs(list) do
        local worn_somewhere = false
        for _, w in pairs(st.worn) do if same_copy(c, w) then worn_somewhere = true end end
        if not worn_somewhere and not same_copy(c, taken) and not (taken and taken.bag == c.bag) then return c end
    end
    for _, c in ipairs(list) do
        if not same_copy(c, taken) and not (taken and taken.bag == c.bag) then return c end
    end
    return nil
end

--- Bag id of a bag name written in a set ('wardrobe 2', 'wardrobe2').
local function bag_id_of(name)
    local key = tostring(name):lower():gsub('%s', '')
    for id, bag in pairs(rawget(_G, 'res') and res.bags or require('resources').bags) do
        if bag.api == key then return id end
    end
    return nil
end

--- Place the doubled pieces of one side pair of a set (mutates `out`).
--- The copy each side takes is remembered per item (one list serves the
--- short and the long name), so the other side never takes the same one; a
--- side whose piece names its bag counts as taking the copy in that bag.
local function place_pair(pair, set, out, st)
    local picked = {}   -- [copies list] = copy one side took
    for _, side in ipairs({ 'left', 'right' }) do
        for _, key in ipairs(pair[side]) do
            local value = set[key]
            local named = type(value) == 'table' and type(value.name) == 'string' and value.name
                or (type(value) == 'string' and value) or nil
            local list = named and st.copies[named:lower()]
            local name = placeable_name(value)
            if list and not name and type(value) == 'table' and value.bag then
                picked[list] = { bag = bag_id_of(value.bag) }
            elseif list and name then
                local bags = {}
                for _, c in ipairs(list) do bags[c.bag] = true end
                if not next(bags, next(bags)) then
                    warn_same_bag(name)
                else
                    local c = pick(list, st.worn[pair['worn_' .. side]], st, picked[list])
                    if c then
                        local piece = type(value) == 'table' and {} or { name = name }
                        if type(value) == 'table' then for k, v in pairs(value) do piece[k] = v end end
                        piece.bag = c.api
                        out[key] = piece
                        picked[list] = c
                    end
                end
            end
        end
    end
end

--- The equip hook: a copy of the set with the bag of each doubled piece named.
--- @param set table
--- @return table The set itself when nothing changes
function DuplicateGear.hook(set)
    local st = current()
    if not next(st.copies) then return set end
    local out = nil
    for _, pair in ipairs(PAIRS) do
        local work = out or {}
        place_pair(pair, set, work, st)
        if next(work) and not out then out = work end
    end
    if not out then return set end
    local copy = {}
    for k, v in pairs(set) do copy[k] = v end
    for k, v in pairs(out) do copy[k] = v end
    return copy
end

--- Register the hook for this job load (INIT_SYSTEMS).
function DuplicateGear.install()
    DuplicateGear.invalidate()
    require('shared/utils/equipment/equip_hooks').add('duplicate_gear', 10, DuplicateGear.hook)
end

return DuplicateGear
