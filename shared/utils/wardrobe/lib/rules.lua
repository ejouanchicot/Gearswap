---============================================================================
--- Wardrobe Organizer - Placement rules of the character's config
---============================================================================
--- Turns PLACE, JOBS and TYPES of WARDROBE_CONFIG.lua into pins: the map
--- {[item name lower] = {bag, ...}} the organizer already honours for the
--- `bag = 'wardrobe N'` written in the sets (one copy per listed bag, a copy
--- already in one of them stays). The final map, strongest first:
---   PLACE  >  bag = '...' in the sets  >  JOBS  >  TYPES  >  doubled items
--- A used item owned in several copies is spread one copy per USED bag (then
--- the next equippable FILL_FALLBACK bags), so GearSwap can tell the copies
--- apart by bag (shared/utils/equipment/duplicate_gear.lua names that bag at
--- each swap).
--- NEVER_MOVE is not a pin: those items are invisible to the organizer
--- (Items.is_equipment).
---
--- JOBS pins the gear of each listed job, from its set files, whatever the
--- scope. TYPES pins the gear of that type that is used in the current scope
--- (unused gear goes to the UNUSED bags).
---
--- @file shared/utils/wardrobe/lib/rules.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-30
---============================================================================

local Config = require('shared/utils/wardrobe/lib/config')
local Items  = require('shared/utils/wardrobe/lib/items')

local Rules = {}

--- Type of an item from its slots (res.items bit field, or a set of slot ids).
--- Slot ids: 0 main, 1 sub, 2 range, 3 ammo, 4-8 head..feet, 9-15 neck..back.
--- @param item_id number
--- @return string|nil 'weapons' | 'ammo' | 'armor' | 'accessories'
function Rules.item_type(item_id)
    local d = require('resources').items[item_id]
    local slots = d and d.slots
    if not slots then return nil end
    local function has(bit)
        if type(slots) == 'number' then return math.floor(slots / 2 ^ bit) % 2 == 1 end
        if type(slots) == 'table' then
            if slots.contains then return slots:contains(bit) end
            return slots[bit] == true
        end
        return false
    end
    if has(0) or has(1) or has(2) then return 'weapons' end
    if has(3) then return 'ammo' end
    for bit = 4, 8 do if has(bit) then return 'armor' end end
    for bit = 9, 15 do if has(bit) then return 'accessories' end end
    return nil
end

--- Bags of the jobs using an item, in job order (one list for all of them).
local function job_bags(jobs_using)
    local jobs = {}
    for job in pairs(jobs_using) do
        if Config.RULES.jobs[job] then jobs[#jobs + 1] = job end
    end
    table.sort(jobs)
    local out, seen = {}, {}
    for _, job in ipairs(jobs) do
        for _, b in ipairs(Config.RULES.jobs[job]) do
            if not seen[b] then seen[b] = true; out[#out + 1] = b end
        end
    end
    return out
end

--- JOBS pins, from every job's set files.
local function jobs_pins()
    local pins = {}
    if not next(Config.RULES.jobs) then return pins end
    local ok, Auditor = pcall(require, 'shared/utils/equipment/wardrobe_auditor')
    if not (ok and Auditor and Auditor.build_frequency_map) then return pins end
    for name, jobs_using in pairs(Auditor.build_frequency_map()) do
        local bags = job_bags(jobs_using)
        if #bags > 0 then pins[name] = bags end
    end
    return pins
end

--- TYPES pins for the used items found in the inventory and the scanned bags.
local function types_pins(used_names)
    local pins = {}
    if not next(Config.RULES.types) then return pins end
    local bags = {Config.INV_BAG}
    for _, b in ipairs(Config.ALL_WARDROBES) do bags[#bags + 1] = b end
    for _, b in ipairs(Config.OVERFLOW_BAGS) do bags[#bags + 1] = b end
    for _, bag in ipairs(bags) do
        for _, it in ipairs(windower.ffxi.get_items(bag) or {}) do
            if type(it) == 'table' and (it.id or 0) > 0 and Items.is_used_name(it.id, used_names) then
                local list = Config.RULES.types[Rules.item_type(it.id) or '']
                if list then
                    for _, n in ipairs(Items.item_names(it.id)) do pins[n] = list end
                end
            end
        end
    end
    return pins
end

--- True when a copy carries augments: GearSwap tells such copies apart by
--- their augments, so they are not doubled items here.
local function augmented(it, extdata)
    if not extdata then return false end
    local ok, ext = pcall(extdata.decode, it)
    return ok and ext and type(ext.augments) == 'table' and #ext.augments > 0
end

--- Doubled used items (same item, no augments): one copy per USED bag, then
--- the equippable fallbacks.
local function duplicate_pins(used_names)
    local count = {}
    local ok_x, extdata = pcall(require, 'extdata')
    if not ok_x then extdata = nil end
    local bags = {Config.INV_BAG}
    for _, b in ipairs(Config.ALL_WARDROBES) do bags[#bags + 1] = b end
    for _, b in ipairs(Config.OVERFLOW_BAGS) do bags[#bags + 1] = b end
    local seen_bag = {}
    for _, bag in ipairs(bags) do
        if not seen_bag[bag] then
            seen_bag[bag] = true
            for _, it in ipairs(windower.ffxi.get_items(bag) or {}) do
                if type(it) == 'table' and (it.id or 0) > 0 and Items.is_equipment(it.id)
                    and Items.is_used_name(it.id, used_names) and not augmented(it, extdata) then
                    count[it.id] = (count[it.id] or 0) + 1
                end
            end
        end
    end
    local res = require('resources')
    local targets = {}
    for _, b in ipairs(Config.PRIMARY_BAGS) do targets[#targets + 1] = b end
    for _, b in ipairs(Config.FILL_FALLBACK) do
        local info = res.bags[b]
        if info and info.equippable then targets[#targets + 1] = b end
    end
    local pins = {}
    for id, n in pairs(count) do
        if n > 1 then
            local list = {}
            for i = 1, math.min(n, #targets) do list[i] = targets[i] end
            if #list > 1 then
                for _, name in ipairs(Items.item_names(id)) do pins[name] = list end
            end
        end
    end
    return pins
end

--- The pins of the organizer: the sets' own `bag =` pins merged with the
--- config's rules, strongest last written.
--- @param set_pins table {[name] = {bag, ...}} from WardrobeAuditor.build_pinned_bags
--- @param used_names table Set of used names in the current scope
--- @return table {[name] = {bag, ...}}
function Rules.pins(set_pins, used_names)
    local out = {}
    for _, layer in ipairs({duplicate_pins(used_names), types_pins(used_names), jobs_pins(), set_pins or {},
            Config.RULES.place}) do
        for name, bags in pairs(layer) do out[name] = bags end
    end
    return out
end

return Rules
