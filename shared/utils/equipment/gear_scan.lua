---============================================================================
--- Gear Scan - //gs c gearscan: the real augments of the player's equipment
---============================================================================
--- A set can name a piece without its augments (Sakpata's Gauntlets, a
--- one-of-a-kind cape...): GearSwap still finds it, but HPPriority then only
--- knows its base HP and MP. This command reads every bag of the character
--- (inventory, the eight wardrobes, satchel, sack, case, safes, storage,
--- locker), decodes the augments of each equipment piece with Windower's
--- extdata library, and writes them to <Char>/saved/gear_augments.lua.
--- HPPriority reads that small file at each job load; nothing is scanned
--- then.
---
--- One entry per item name. When several copies carry different augments,
--- the copies in the inventory and wardrobes (where GearSwap equips from)
--- decide; if those still differ, the entry is marked `differ` and not used:
--- the set has to name the augments to pick a copy anyway.
---
--- Path pieces (Odyssey gear, JSE necks...) decode as 'Path: A' only, without
--- the stats of the path: those HP are not counted. Their path and rank are
--- kept in the file (path = 'A', rank = 25) for whoever needs them.
---
--- @file    shared/utils/equipment/gear_scan.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

local GearScan = {}

-- Game data: the global `res` is not there for a command, the library is
local function resources()
    return rawget(_G, 'res') or require('resources')
end

local FILE = 'gear_augments.lua'

--- Bags never read (items only passing through). The others come from
--- res.bags, whose `equippable` flag marks the bags GearSwap equips from.
local SKIPPED = {temporary = true, recycle = true}

--- Path of the cache file of the character being played.
--- @param writable boolean True to create its folder when missing
--- @return string|nil
function GearScan.path(writable)
    local CharPaths = require('shared/utils/core/char_paths')
    if writable then return CharPaths.writable('saved', FILE) end
    return CharPaths.file('saved', FILE)
end

--- The cache written by the last scan: {[lower name] = {hp, mp, augments, differ}}.
--- @return table Empty when there is none
function GearScan.load()
    local path = GearScan.path(false)
    if not path then return {} end
    local ok, data = pcall(dofile, path)
    return (ok and type(data) == 'table') and data or {}
end

--- Augments of one bag item, or nil when it is not augmented equipment.
--- @return table|nil augments, table|nil info (res.items), table|nil ext (decoded)
local function item_augments(item, extdata, res)
    local info = res.items[item.id]
    if not (info and (info.category == 'Armor' or info.category == 'Weapon')) then return nil, info end
    local ok, ext = pcall(extdata.decode, item)
    if not (ok and ext and type(ext.augments) == 'table') then return nil, info end
    local list = {}
    for _, augment in ipairs(ext.augments) do
        if type(augment) == 'string' and augment ~= '' and augment ~= 'none' then list[#list + 1] = augment end
    end
    return (#list > 0) and list or nil, info, ext
end

--- Text that tells two copies apart (augments, path and rank).
local function copy_key(copy)
    return table.concat(copy.augments, '|') .. '#' .. tostring(copy.path) .. '#' .. tostring(copy.rank)
end

--- Every augmented equipment copy, by lower-case name (short and long).
--- @return table copies {[name] = {{hp, mp, augments, equippable}...}}
--- @return number pieces Equipment pieces read
--- @return table shorts Short names seen (the summary counts each piece once)
local function collect(extdata, hp_mp)
    local res = resources()
    local copies, pieces, shorts = {}, 0, {}
    for bag_id, bag_info in pairs(res.bags) do
        local bag = not SKIPPED[bag_info.api or ''] and windower.ffxi.get_items(bag_id)
        if bag and bag.enabled ~= false then
            for _, item in ipairs(bag) do
                if type(item) == 'table' and (item.id or 0) > 0 then
                    local augments, info, ext = item_augments(item, extdata, res)
                    if info and (info.category == 'Armor' or info.category == 'Weapon') then pieces = pieces + 1 end
                    if augments then
                        local hp, mp = hp_mp(augments)
                        local copy = {hp = hp, mp = mp, augments = augments, equippable = bag_info.equippable == true,
                            path = ext.path, rank = ext.path and tonumber(ext.rank) or nil}
                        local short, long = info.en and info.en:lower(), info.enl and info.enl:lower()
                        if short then shorts[short] = true end
                        for _, n in ipairs({short, long ~= short and long or nil}) do
                            copies[n] = copies[n] or {}
                            table.insert(copies[n], copy)
                        end
                    end
                end
            end
        end
    end
    return copies, pieces, shorts
end

--- One entry per name: the equippable copies decide, differing copies are marked.
local function resolve(list)
    local pool = {}
    for _, copy in ipairs(list) do if copy.equippable then pool[#pool + 1] = copy end end
    if #pool == 0 then pool = list end
    local first = pool[1]
    for _, copy in ipairs(pool) do
        if copy_key(copy) ~= copy_key(first) then
            return {differ = true, copies = #pool}
        end
    end
    return {hp = first.hp, mp = first.mp, augments = first.augments, path = first.path, rank = first.rank}
end

local function quote(s) return string.format('%q', s) end

--- File text of the cache.
local function render(entries)
    local names = {}
    for name in pairs(entries) do names[#names + 1] = name end
    table.sort(names)
    local out = {
        '-- Written by //gs c gearscan on ' .. os.date('%Y-%m-%d %H:%M') .. '. Run it again after new or',
        '-- upgraded gear. Augments of your equipment, read from every bag; the HP',
        '-- priority adds the HP / MP of a piece your sets name without augments.',
        '-- differ = copies with different augments: the set names the augments.',
        '-- path / rank: pieces upgraded by path (Odyssey gear...), their stats are not here.',
        'return {',
    }
    for _, name in ipairs(names) do
        local e = entries[name]
        if e.differ then
            out[#out + 1] = ('    [%s] = {differ = true, copies = %d},'):format(quote(name), e.copies)
        else
            local augs = {}
            for _, a in ipairs(e.augments) do augs[#augs + 1] = quote(a) end
            local ranked = e.path and (', path = %s, rank = %d'):format(quote(e.path), e.rank or 0) or ''
            out[#out + 1] = ('    [%s] = {hp = %d, mp = %d, augments = {%s}%s},'):format(
                quote(name), e.hp, e.mp, table.concat(augs, ', '), ranked)
        end
    end
    out[#out + 1] = '}'
    return table.concat(out, '\n') .. '\n'
end

--- //gs c gearscan: read every bag, write the cache, show a summary.
--- @return boolean
function GearScan.run()
    local InfoBlock = require('shared/utils/messages/info_block')
    local ok_x, extdata = pcall(require, 'extdata')
    local path = GearScan.path(true)
    if not (ok_x and extdata and path) then
        InfoBlock.show({tag = 'GEARSCAN', title = 'Not available', lines = {'extdata library or character folder missing'}})
        return false
    end
    local hp_mp = require('shared/utils/equipment/hp_priority')._augment_hp_mp
    local copies, pieces, shorts = collect(extdata, hp_mp)
    local entries, with_stats, differ = {}, 0, 0
    for name, list in pairs(copies) do
        local e = resolve(list)
        entries[name] = e
        if not shorts[name] then
        elseif e.differ then differ = differ + 1
        elseif e.hp ~= 0 or e.mp ~= 0 then with_stats = with_stats + 1 end
    end
    local file = io.open(path, 'w')
    if not file then
        InfoBlock.show({tag = 'GEARSCAN', title = 'Cannot write', lines = {path}})
        return false
    end
    file:write(render(entries))
    file:close()
    InfoBlock.show({tag = 'GEARSCAN', title = 'Augments read', fields = {
        {'Equipment read', tostring(pieces)},
        {'Giving HP / MP', tostring(with_stats), 'good'},
        {'Copies that differ', tostring(differ), differ > 0 and 'warn' or nil},
        {'File', 'saved/' .. FILE, 'dim'},
    }, lines = {'Used from the next job load.'}})
    return true
end

return GearScan
