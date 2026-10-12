---============================================================================
--- Atelier Export - what the game knows of the character
---============================================================================
--- The gear owned (bags and Porter Moogle slips), the stats and the gear worn when
--- the game last sent them, the merits, the skills, every job's level, the icons
--- and descriptions of the items named, the weaponskills of each weapon. Empty
--- outside the game. Read by shared/utils/atelier/atelier_export.lua (build).
---
--- @file    shared/utils/atelier/atelier_export_char.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-11 (out of atelier_export.lua)
---============================================================================

local ExportChar = {}

local SLOT_BY_ID = {[0] = 'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs', 'feet', 'neck', 'waist',
    'ear1', 'ear2', 'ring1', 'ring2', 'back'}
-- Bags GearSwap equips from: inventory, wardrobes 1-8
local EQUIP_BAGS = {0, 8, 10, 11, 12, 13, 14, 15, 16}
-- Every bag a player keeps gear in (3, temporary items, left out): the page's "owned" list
-- covers them all, each copy with where it is. Windower keeps the Mog House bags as last seen.
local OWNED_BAGS = {0, 8, 10, 11, 12, 13, 14, 15, 16, 1, 9, 2, 4, 5, 6, 7}
local BAG_NAMES = {[0] = 'Inventory', [1] = 'Mog Safe', [2] = 'Storage', [4] = 'Mog Locker', [5] = 'Mog Satchel',
    [6] = 'Mog Sack', [7] = 'Mog Case', [8] = 'Wardrobe', [9] = 'Mog Safe 2', [10] = 'Wardrobe 2', [11] = 'Wardrobe 3',
    [12] = 'Wardrobe 4', [13] = 'Wardrobe 5', [14] = 'Wardrobe 6', [15] = 'Wardrobe 7', [16] = 'Wardrobe 8'}

--- The augments of one copy of an item (its extdata), or nil.
local function copy_augments(item)
    local ok_ext, extdata = pcall(require, 'extdata')
    local ok, ext = false, nil
    if ok_ext then ok, ext = pcall(extdata.decode, item) end
    if not (ok and ext and type(ext.augments) == 'table') then return nil end
    local augs = {}
    for _, a in ipairs(ext.augments) do
        if type(a) == 'string' and a ~= '' and a ~= 'none' then augs[#augs + 1] = a end
    end
    return #augs > 0 and augs or nil
end

--- Whether the main job can wear an item (res.items jobs: a set of job ids, or the raw bitmask).
--- Every job can "wear" fishing bait (skill 48) and pet food (ammo with damage but no skill):
--- neither is gear.
local function wearable(info)
    if info.skill == 48 or (info.skill == 0 and (info.damage or 0) > 0) then return false end
    local job = player and player.main_job_id
    if not (job and info.jobs) then return true end
    if type(info.jobs) == 'number' then return math.floor(info.jobs / 2 ^ job) % 2 == 1 end
    return info.jobs[job] == true
end

--- Owned items the main job can wear, by slot: `items` = {slot = {name, ...}} and
--- `owned` = {slot = {{name = , augs = }, ...}}, one entry per distinct copy (two capes
--- with other augments are two choices in the page).
--- The items kept at the Porter Moogle, {item id = 'Slip N'}: the slips, or the last list read
--- when they cannot be read yet (shared/utils/atelier/slip_items.lua).
local function slip_items()
    local ok, SlipItems = pcall(require, 'shared/utils/atelier/slip_items')
    return ok and SlipItems.get() or {}
end
-- the whole Porter Moogle (every job's gear, the page keeps what the shown job can wear), item ids as text keys
local function porter_list() local out = {} for id, w in pairs(slip_items()) do out[tostring(id)] = w end return out end

local function collect_items()
    local ok, res = pcall(require, 'resources')
    if not ok or not res or not res.items then return nil end
    local by_slot, owned, seen, entry_of = {}, {}, {}, {}
    -- one piece: the slots it fits, once per name for `items`, once per copy for `owned`,
    -- each copy with the places it is in (several bags when the same copy is twice) and how
    -- many there are (two Moonlight Rings in one wardrobe: one place, count 2), and its item id (one
    -- name, several items: a prime weapon's stages, Laphria II to V, each its own stats)
    local function add(info, augs, where)
        if not (info and info.slots and type(info.slots) == 'table' and info.slots.it and wearable(info)) then return end
        local copy = info.id .. '|' .. table.concat(augs or {}, '|')
        for slot_id in info.slots:it() do
            local slot = SLOT_BY_ID[slot_id]
            if slot and not seen[slot .. '|' .. info.en] then
                seen[slot .. '|' .. info.en] = true
                by_slot[slot] = by_slot[slot] or {}
                table.insert(by_slot[slot], info.en)
            end
            if slot then
                local key = slot .. '#' .. copy
                local entry = entry_of[key]
                if not entry then
                    entry = {name = info.en, id = info.id, augs = augs, where = {}, count = 0}
                    entry_of[key] = entry
                    owned[slot] = owned[slot] or {}
                    table.insert(owned[slot], entry)
                end
                local known = false
                for _, w in ipairs(entry.where) do if w == where then known = true end end
                if not known then table.insert(entry.where, where) end
                entry.count = entry.count + 1
            end
        end
    end
    for _, bag in ipairs(OWNED_BAGS) do
        for _, item in ipairs(windower.ffxi.get_items(bag) or {}) do
            local info = type(item) == 'table' and item.id and item.id > 0 and res.items[item.id]
            -- the augments are read for gear only: add() keeps nothing else, and decoding every potion and
            -- crystal of sixteen bags was a third of this stage
            if info and info.slots and wearable(info) then add(info, copy_augments(item), BAG_NAMES[bag] or tostring(bag)) end
        end
    end
    -- a slip keeps only items without augments
    for id, where in pairs(slip_items()) do add(res.items[id], nil, where) end
    for _, names in pairs(by_slot) do table.sort(names) end
    for _, list in pairs(owned) do table.sort(list, function(a, b) return a.name < b.name end) end
    return by_slot, owned
end

--- Item id of every name the page shows ({name = id}), equippable items
--- first: the page draws their icons from data/atelier/icons/<id>.bmp.
--- The game's description of each item ({["id"] = text}, string keys so the JSON
--- stays an object): the page reads every piece's stats from it.
local function collect_descs(ids)
    local ok, res = pcall(require, 'resources')
    local book = ok and res and res.item_descriptions
    if not book then return nil end
    local descs = {}
    for _, id in ipairs(ids) do
        local entry = book[id]
        if entry and entry.en then descs[tostring(id)] = entry.en end
    end
    return descs
end

-- Slots of windower.ffxi.get_items().equipment, as the page names them
local WORN_SLOTS = {main = 'main', sub = 'sub', range = 'range', ammo = 'ammo', head = 'head', neck = 'neck',
    left_ear = 'ear1', right_ear = 'ear2', body = 'body', hands = 'hands', left_ring = 'ring1', right_ring = 'ring2',
    back = 'back', waist = 'waist', legs = 'legs', feet = 'feet'}

--- Where each worn piece was when the game last sent the stats (status packet 0x061): the stats GearSwap keeps in
--- `player` are that packet's, so the gear taken out of them must be that moment's, not the export's (an export made
--- during a job ability read idle stats with the ability's gear, and the page's base came out 78 MND too high).
--- A copy of get_items('equipment') at each 0x061, kept on windower (it outlives the reloads).
local function snapshot_equipment()
    local ok, eq = pcall(windower.ffxi.get_items, 'equipment')
    if not ok or type(eq) ~= 'table' then return end
    local copy = {}
    for k, v in pairs(eq) do copy[k] = v end
    windower._atelier_stat_equipment = copy
    -- and the buffs up then: the stats count them (Protect in the Defense), the page takes them out
    local okp, me = pcall(windower.ffxi.get_player)
    if okp and type(me) == 'table' and type(me.buffs) == 'table' then
        local buffs = {}
        for i, id in ipairs(me.buffs) do buffs[i] = id end
        windower._atelier_stat_buffs = buffs
    end
    -- a count of the measures, for the page's live link (atelier_live.lua /ping): a new one is worth fetching
    windower._atelier_stat_seq = (windower._atelier_stat_seq or 0) + 1
end

--- Listen to the status packet, once per load (a raw event: a plain one from a job file runs GearSwap's refresh on
--- every packet).
local function listen_stats()
    if rawget(_G, '_atelier_stat_listening') then return end
    _G._atelier_stat_listening = true
    windower.raw_register_event('incoming chunk', function(id)
        if id == 0x061 then snapshot_equipment() end
    end)
end

--- The gear worn when the stats were sent (else right now), with the augments of these very copies.
local function worn_gear(res)
    local equipment = windower._atelier_stat_equipment
    if type(equipment) ~= 'table' then
        local items = windower.ffxi.get_items()
        equipment = items and items.equipment
    end
    if type(equipment) ~= 'table' then return nil end
    local worn = {}
    for key, slot in pairs(WORN_SLOTS) do
        local index, bag = equipment[key], equipment[key .. '_bag']
        local item = index and index > 0 and bag and windower.ffxi.get_items(bag, index)
        local info = item and item.id and item.id > 0 and res.items[item.id]
        if info then worn[slot] = {name = info.en, id = item.id, augs = copy_augments(item)} end
    end
    return worn
end

--- The merits the page offers to change: the general ones (ids below 384: HP/MP,
--- attributes, combat and magic skills, others) and the two groups of the main job
--- (ids 384 + 64 x (job - 1) and 2048 + 64 x (job - 1), res/merit_points.lua), each
--- with its level and the game's description, which says what a level gives.
--- get_player().merits names them after the English name: "Sword Skill" -> sword,
--- "Divine Magic Skill" -> divine, "Wind Instrument Skill" -> wind; four names of the
--- resource do not follow it (MERIT_KEYS).
local MERIT_KEYS = {['Ele. Mag. Debuff Dur.'] = 'elemental_magic_debuff_duration',
    ['Ele. Mag. Debuff Pot.'] = 'elemental_magic_debuff_effect',
    ['Desperate Blows Effect'] = 'desperate_blows', ['Strafe Effect'] = 'strafe'}
local function merit_key(name)
    return MERIT_KEYS[name] or (name:lower():gsub(' skill$', ''):gsub(' magic$', ''):gsub(' instrument$', ''):gsub('[^%w]+', '_'))
end
local function merit_list(res, levels)
    local job = res.jobs and player.main_job_id or nil
    if not (res.merit_points and job) then return nil end
    local first, second = 384 + 64 * (job - 1), 2048 + 64 * (job - 1)
    local list = {}
    for id, m in pairs(res.merit_points) do
        if id < 384 or (id >= first and id < first + 64) or (id >= second and id < second + 64) then
            local key = merit_key(m.en)
            list[#list + 1] = {id = id, en = m.en, key = key, level = levels[key] or 0, desc = m.endesc}
        end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

--- The character's real stats now (the game's status packet, kept by GearSwap
--- in `player`) and the gear worn while they were read: the page takes that
--- gear out and puts a set's in, to show the stats each set gives. Nil
--- outside the game.
local function collect_char()
    if not (player and player.base_str and player.max_hp) then return nil end
    local ok, res = pcall(require, 'resources')
    if not ok or not res then return nil end
    local char = {at = os.date('%Y-%m-%d %H:%M'), sub = player.sub_job, max_hp = player.max_hp, max_mp = player.max_mp,
        attack = player.attack, defense = player.defense, main_level = player.main_job_level, base = {}, add = {}}
    for _, a in ipairs({'str', 'dex', 'vit', 'agi', 'int', 'mnd', 'chr'}) do
        char.base[a] = player['base_' .. a]
        char.add[a] = player['add_' .. a]
    end
    char.worn = worn_gear(res)
    -- the buff ids up when those stats were sent (the page takes Protect out of the measured Defense); before the first
    -- status packet of a load, the ones up now
    char.buffs = windower._atelier_stat_buffs
    if not char.buffs then
        local okp, me = pcall(windower.ffxi.get_player)
        if okp and type(me) == 'table' and type(me.buffs) == 'table' then
            char.buffs = {}
            for i, id in ipairs(me.buffs) do char.buffs[i] = id end
        end
    end
    -- what the page adds to the gear's %: merit levels by name ("spell_interruption_rate" = 5),
    -- and, shown with the measure, the job points spent and the master level (status packet 0x061)
    local p = windower.ffxi.get_player() or {}
    char.merits = {}
    for name, level in pairs(p.merits or {}) do
        if type(level) == 'number' and level > 0 then char.merits[tostring(name)] = level end
    end
    char.merit_list = merit_list(res, p.merits or {})
    -- combat and magic skill levels (sword = 424...) and the subjob's level: the page
    -- computes Accuracy and Evasion from them, with the job traits of both jobs
    char.skills = {}
    for name, level in pairs(p.skills or {}) do
        if type(level) == 'number' then char.skills[tostring(name)] = level end
    end
    char.sub_level = player.sub_job_level
    char.main_level = player.main_job_level
    local jp = type(p.job_points) == 'table' and p.job_points[(player.main_job or ''):lower()]
    char.jp_spent = type(jp) == 'table' and jp.jp_spent or nil
    local packet = windower.packets and windower.packets.last_incoming and windower.packets.last_incoming(0x061)
    char.master_level = packet and #packet > 0x65 and packet:byte(0x65 + 1) or nil
    -- every job's level and master level (packet 0x01B, libs/packets/fields.lua: job levels from 0x49, master levels
    -- from 0x6D, one byte per job id 1-22; the mastery rank at 0x66, Hoxne Earring's "All BP" bonus on the page)
    local info = windower.packets and windower.packets.last_incoming and windower.packets.last_incoming(0x01B)
    char.mastery_rank = info and #info > 0x66 and info:byte(0x66 + 1) or nil
    local ok_r, res = pcall(require, 'resources')
    if info and #info >= 0x6D + 22 and ok_r and res and res.jobs then
        char.jobs = {}
        for id = 1, 22 do
            local job = res.jobs[id] and res.jobs[id].ens
            if job then char.jobs[job] = {level = info:byte(0x49 + id), ml = info:byte(0x6D + id)} end
        end
    end
    return char
end

--- The combat skill of each weapon ({name = "Sword"}, res.items skill -> res.skills):
--- the page takes the main hand's for Accuracy.
--- Each weapon's weaponskills in the job's order, the first its main one: {main hand name: {ws...}}, from the job's
--- weaponskill config (_G.<JOB>WSConfig.by_weapon, e.g. <Char>/war/combat/WAR_WS_CONFIG.lua: one list a weapon mode) and the
--- weapon each mode wears (sets.<mode>.main, from <Char>/war/sets/weapons.lua). nil for a job with no such config.
--- @param job string
--- @return table|nil
local function collect_ws_by_weapon(job)
    local cfg = job and rawget(_G, job .. 'WSConfig')
    if type(cfg) ~= 'table' or type(sets) ~= 'table' then return nil end
    -- the lists live under by_weapon (WAR_WS_CONFIG.lua), else at the top
    if type(cfg.by_weapon) == 'table' then cfg = cfg.by_weapon end
    local out, any = {}, false
    for mode, list in pairs(cfg) do
        local weapon = type(mode) == 'string' and sets[mode]
        local main = type(weapon) == 'table' and weapon.main
        main = type(main) == 'table' and main.name or main
        if type(main) == 'string' and type(list) == 'table' and not out[main] then
            local names = {}
            for _, ws in ipairs(list) do if type(ws) == 'string' then names[#names + 1] = ws end end
            if #names > 0 then out[main] = names; any = true end
        end
    end
    return any and out or nil
end

local function collect_weapon_skills(icons)
    local ok, res = pcall(require, 'resources')
    if not (ok and res and res.items and res.skills) then return nil end
    local out = {}
    for name, id in pairs(icons or {}) do
        local item = res.items[id]
        local skill = item and item.category == 'Weapon' and (item.skill or 0) > 0 and res.skills[item.skill]
        if skill and skill.en then out[name] = skill.en end
    end
    return out
end

--- What //gs c gearscan read on the character's own copies of these items
--- (<Char>/saved/gear_augments.lua, shared/utils/equipment/gear_scan.lua):
--- their real augments, and the path, rank and rank stats of Odyssey gear.
--- The page counts them for a piece the set names without augments.
local function collect_scan(icons)
    local ok, GearScan = pcall(require, 'shared/utils/equipment/gear_scan')
    if not (ok and GearScan) then return nil end
    local found, all = pcall(GearScan.load)
    if not found or type(all) ~= 'table' then return nil end
    local scan = {}
    for name in pairs(icons or {}) do
        local entry = all[name:lower()]
        if type(entry) == 'table' then
            scan[name] = {augments = entry.augments, path = entry.path, rank = entry.rank,
                rank_stats = entry.rank_stats, differ = entry.differ}
        end
    end
    return scan
end

local function collect_icons(set_list, items)
    local ok, res = pcall(require, 'resources')
    if not ok or not res or not res.items then return nil end
    -- every spelling met ('Fucho-no-obi' and 'Fucho-no-Obi'), by lower case
    local wanted = {}
    local function want(name)
        local key = name:lower()
        wanted[key] = wanted[key] or {}
        wanted[key][name] = true
    end
    for _, set in ipairs(set_list) do
        for _, p in pairs(set.pieces) do want(p.name) end
    end
    for _, names in pairs(items or {}) do
        for _, name in ipairs(names) do want(name) end
    end
    -- one name, several items (eleven Burtgangs, one per upgrade): the copy in the bags first,
    -- then equipment, then the highest id (the latest upgrade)
    local owned = {}
    for _, bag in ipairs(EQUIP_BAGS) do
        for _, item in ipairs(windower.ffxi.get_items(bag) or {}) do
            if type(item) == 'table' and item.id and item.id > 0 then owned[item.id] = true end
        end
    end
    local function rank(id)
        local info = res.items[id]
        return (owned[id] and 2 or 0) + (info and info.slots and 1 or 0), id
    end
    local function better(id, than)
        if not than then return true end
        local a, ia = rank(id)
        local b, ib = rank(than)
        return a > b or (a == b and ia > ib)
    end
    local icons = {}
    for id, info in pairs(res.items) do
        for _, key in ipairs({info.en and info.en:lower(), info.enl and info.enl:lower()}) do
            for name in pairs(wanted[key] or {}) do
                if better(id, icons[name]) then icons[name] = id end
            end
        end
    end
    return icons
end

--- @param item table one copy of an item, as windower.ffxi.get_items gives it
--- @return table|nil its augments
ExportChar.augments = copy_augments
--- @return table|nil items by slot, table|nil owned copies by slot
ExportChar.items = collect_items
--- @return table {item id as text = 'Slip N'}
ExportChar.porter_list = porter_list
--- @param ids table list of item ids
--- @return table|nil {id as text = description}
ExportChar.descs = collect_descs
--- Listen to the status packet, once per load.
ExportChar.listen_stats = listen_stats
--- @return table|nil the character's stats and the gear worn when they were read
ExportChar.char = collect_char
--- @param job string
--- @return table|nil {main hand name = {weaponskill, ...}}
ExportChar.ws_by_weapon = collect_ws_by_weapon
--- @param icons table {name = item id}
--- @return table|nil {weapon name = its combat skill}
ExportChar.weapon_skills = collect_weapon_skills
--- @param icons table {name = item id}
--- @return table|nil what //gs c gearscan read on these items
ExportChar.scan = collect_scan
--- @param set_list table the sets (ExportSets.collect)
--- @param items table|nil names by slot
--- @return table|nil {name = item id}
ExportChar.icons = collect_icons

return ExportChar
