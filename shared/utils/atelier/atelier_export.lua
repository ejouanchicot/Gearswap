---============================================================================
--- Atelier Export - what the Atelier page shows, written by the game itself
---============================================================================
--- data/atelier.html (open it in a browser) shows every exported job of every
--- character: sets, keys and where each comes from, modes, macro book,
--- lockstyle. This module writes that data, as the game loaded it:
---
---   //gs c atelier        export the current job now
---   //gs c atelier on     also export after every job load (per character)
---   //gs c atelier off    stop exporting on load
---
--- Files: data/<Character>/saved/atelier/<JOB>_<SUB>.js (one per job and
--- subjob; <JOB>.js before 2026-10-01, atelier/ before 2026-09-30),
--- data/atelier/index.js (the list the page reads) and data/atelier/icons/<id>.bmp
--- (item icons from the game files, shared/utils/atelier/item_icons.lua). They are JavaScript, not
--- JSON, because a page opened from the disk may load scripts but not read
--- files.
---
--- While the switch is on, set_combine is wrapped from the first line of each
--- load (install, called by config_loader) to note which set every set was
--- built from; the page greys what a set only inherits. Off, nothing is
--- wrapped and a command export shows every piece as the set's own.
---
--- @file    shared/utils/atelier/atelier_export.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

local AtelierExport = {}

local SLOT_ALIAS = {
    main = 'main', sub = 'sub', range = 'range', ranged = 'range', ammo = 'ammo', head = 'head', neck = 'neck',
    ear1 = 'ear1', left_ear = 'ear1', lear = 'ear1', ear2 = 'ear2', right_ear = 'ear2', rear = 'ear2',
    body = 'body', hands = 'hands', ring1 = 'ring1', left_ring = 'ring1', lring = 'ring1',
    ring2 = 'ring2', right_ring = 'ring2', rring = 'ring2', back = 'back', waist = 'waist', legs = 'legs', feet = 'feet',
}
local SLOT_BY_ID = {[0] = 'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs', 'feet', 'neck', 'waist',
    'ear1', 'ear2', 'ring1', 'ring2', 'back'}
-- Bags GearSwap equips from: inventory, wardrobes 1-8
local EQUIP_BAGS = {0, 8, 10, 11, 12, 13, 14, 15, 16}
local MAX_DEPTH = 7

---============================================================================
--- SWITCH AND PATHS
---============================================================================

local function data_path(rel)
    return windower.addon_path .. 'data/' .. rel
end

local function marker()
    return player and player.name and require('shared/utils/core/char_paths').writable('saved', 'atelier.on')
end

--- On/off per character: a marker file, read once per addon load.
--- @return boolean
function AtelierExport.enabled()
    if windower._atelier_on == nil then
        local path = marker()
        local f = path and io.open(path, 'r')
        windower._atelier_on = f ~= nil
        if f then f:close() end
    end
    return windower._atelier_on == true
end

--- Wrap set_combine for this load when the switch is on (config_loader,
--- before the set file runs).
function AtelierExport.install()
    if not AtelierExport.enabled() or rawget(_G, '__atelier_prov') then return end
    local original = rawget(_G, 'set_combine')
    if type(original) ~= 'function' then return end
    local prov = setmetatable({}, {__mode = 'k'})
    _G.__atelier_prov = prov
    _G.set_combine = function(...)
        local result = original(...)
        prov[result] = {n = select('#', ...), ...}
        return result
    end
end

---============================================================================
--- COLLECT
---============================================================================

local function child_path(path, key)
    if type(key) == 'string' and key:match('^[%a_][%w_]*$') then return path .. '.' .. key end
    return path .. '["' .. tostring(key):gsub('"', '\\"') .. '"]'
end

local function slot_of(key)
    return type(key) == 'string' and SLOT_ALIAS[key:lower()]
end

--- A set's piece as {name, aug, augs}: aug is the short line under the item
--- (first 3 augments), augs every augment, which the page counts in the stats.
local function piece(value)
    if type(value) == 'string' then return {name = value} end
    if type(value) ~= 'table' or not value.name then return nil end
    local aug, augs
    if type(value.augments) == 'table' and #value.augments > 0 then
        augs = {}
        for i = 1, #value.augments do augs[i] = tostring(value.augments[i]) end
        aug = table.concat(augs, ' · ', 1, math.min(3, #augs))
    end
    return {name = value.name, aug = aug, augs = augs}
end

--- Gear slots of one table, or nil when it holds none.
local function pieces_of(tbl)
    local pieces, count = {}, 0
    for key, value in pairs(tbl) do
        local slot = slot_of(key)
        local p = slot and piece(value)
        if p then pieces[slot] = p count = count + 1 end
    end
    return count > 0 and pieces or nil
end

--- Every set under `sets`, first path wins; a table met again is an alias.
local function walk_sets(root)
    local path_of, out, order = {}, {}, {}
    local function walk(tbl, path, depth)
        if depth > MAX_DEPTH or type(tbl) ~= 'table' then return end
        if path_of[tbl] then
            local first = out[path_of[tbl]]
            if first then first.aliases = first.aliases or {} first.aliases[#first.aliases + 1] = path end
            return
        end
        path_of[tbl] = path
        local pieces = pieces_of(tbl)
        if pieces then out[path] = {path = path, pieces = pieces} order[#order + 1] = path end
        local keys = {}
        for key, value in pairs(tbl) do
            if type(value) == 'table' and not slot_of(key) then keys[#keys + 1] = key end
        end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        for _, key in ipairs(keys) do walk(tbl[key], child_path(path, key), depth + 1) end
    end
    walk(root, 'sets', 0)
    return path_of, out, order
end

--- Base set and own slots from the set_combine notes.
local function add_provenance(path_of, out)
    local prov = rawget(_G, '__atelier_prov')
    if not prov then return end
    for tbl, args in pairs(prov) do
        local rec = path_of[tbl] and out[path_of[tbl]]
        if rec then
            local base = args[1]
            if type(base) == 'table' and path_of[base] and out[path_of[base]] then rec.base = path_of[base] end
            local own = {}
            for i = rec.base and 2 or 1, args.n do
                if type(args[i]) == 'table' then
                    for key in pairs(args[i]) do if slot_of(key) then own[#own + 1] = slot_of(key) end end
                end
            end
            rec.own = own
        end
    end
end

local function collect_sets()
    local path_of, out, order = walk_sets(sets or {})
    add_provenance(path_of, out)
    -- what the set file gave before the page's overrides (shared/utils/atelier/set_overrides.lua)
    local ok, SetOverrides = pcall(require, 'shared/utils/atelier/set_overrides')
    for path, slots in pairs(ok and SetOverrides.was or {}) do
        local rec = out[path]
        if rec then
            rec.was = {}
            for slot, value in pairs(slots) do rec.was[slot] = value and piece(value) or {name = 'empty'} end
        end
    end
    local list = {}
    for _, path in ipairs(order) do list[#list + 1] = out[path] end
    return list
end

local function source_of(bind)
    if bind._common then return 'common' end
    if bind.custom then return 'custom' end
    if bind.state == 'CombatMode' then return 'combat' end
    if bind.state == 'TreasureMode' then return 'treasure' end
    return 'job'
end

--- The keys of the job, as bound now. `id` names a key in the overrides file the
--- page writes (shared/utils/keybinds/key_overrides.lua); `file_key` is the key
--- of the key file when an override changed it.
local function collect_keys()
    local module = rawget(_G, '_keybind_active')
    local ok, KeyOverrides = pcall(require, 'shared/utils/keybinds/key_overrides')
    local keys = {}
    for _, bind in ipairs(module and module.binds or {}) do
        keys[#keys + 1] = {key = bind.key or '', desc = bind.desc or bind.command or '', state = bind.state,
            src = source_of(bind), subjob = type(bind.subjob) == 'string' and bind.subjob or nil,
            id = ok and KeyOverrides.id_of(bind) or nil, file_key = bind.file_key,
            subjobs = type(bind.subjob) == 'table' and bind.subjob or nil,
            exclude = type(bind.exclude_subjob) == 'string' and {bind.exclude_subjob} or bind.exclude_subjob}
    end
    return keys
end

local function collect_modes()
    local modes = {}
    for name, mode in pairs(state or {}) do
        local track = type(mode) == 'table' and rawget(mode, '_track')
        if track and track._class == 'mode' and track._type ~= 'string' then
            local values = {}
            if track._type == 'boolean' then values = {'off', 'on'}
            else for i = 1, track._count do values[#values + 1] = tostring(rawget(mode, i)) end end
            modes[#modes + 1] = {name = name, desc = track._description, values = values, current = tostring(mode.current)}
        end
    end
    table.sort(modes, function(a, b) return a.name < b.name end)
    return modes
end

--- A job config table (MACROBOOK / LOCKSTYLE), from the character's folder.
local function job_config(kind)
    local job = player.main_job
    local ok, cfg = require('shared/utils/core/char_paths').load('job', job .. '_' .. kind, job)
    return (ok and type(cfg) == 'table') and cfg or nil
end

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
local function collect_items()
    local ok, res = pcall(require, 'resources')
    if not ok or not res or not res.items then return nil end
    local by_slot, owned, seen = {}, {}, {}
    for _, bag in ipairs(EQUIP_BAGS) do
        for _, item in ipairs(windower.ffxi.get_items(bag) or {}) do
            local info = type(item) == 'table' and item.id and item.id > 0 and res.items[item.id]
            if info and info.slots and type(info.slots) == 'table' and info.slots.it and wearable(info) then
                local augs = copy_augments(item)
                local copy = info.en .. '|' .. table.concat(augs or {}, '|')
                for slot_id in info.slots:it() do
                    local slot = SLOT_BY_ID[slot_id]
                    if slot and not seen[slot .. '|' .. info.en] then
                        seen[slot .. '|' .. info.en] = true
                        by_slot[slot] = by_slot[slot] or {}
                        table.insert(by_slot[slot], info.en)
                    end
                    if slot and not seen[slot .. '#' .. copy] then
                        seen[slot .. '#' .. copy] = true
                        owned[slot] = owned[slot] or {}
                        table.insert(owned[slot], {name = info.en, augs = augs})
                    end
                end
            end
        end
    end
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

--- The gear worn right now, with the augments of these very copies.
local function worn_gear(res)
    local items = windower.ffxi.get_items()
    local equipment = items and items.equipment
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
    return char
end

--- The combat skill of each weapon ({name = "Sword"}, res.items skill -> res.skills):
--- the page takes the main hand's for Accuracy.
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

--- The combat skill of each weaponskill a set path names (sets.precast.WS["Savage Blade"]
--- -> "Sword"): the page puts a weapon of that skill in the weaponskill's set.
local function collect_ws_skills(set_list)
    local ok, res = pcall(require, 'resources')
    if not (ok and res and res.weapon_skills and res.skills) then return nil end
    local by_name = {}
    for _, ws in pairs(res.weapon_skills) do
        local skill = ws.en and ws.skill and res.skills[ws.skill]
        if skill and skill.en then by_name[ws.en] = skill.en end
    end
    local out = {}
    for _, set in ipairs(set_list or {}) do
        for name in tostring(set.path):gmatch('"([^"]+)"') do out[name] = by_name[name] end
        for name in tostring(set.path):gmatch('%.([%w_]+)') do out[name] = out[name] or by_name[name] end
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

---============================================================================
--- WRITE
---============================================================================

local function json(value)
    local kind = type(value)
    if kind == 'nil' or kind == 'function' then return 'null' end
    if kind == 'boolean' or kind == 'number' then return tostring(value) end
    if kind == 'string' then
        return '"' .. value:gsub('[%c"\\]', function(c)
            return ({['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n'})[c] or string.format('\\u%04x', c:byte())
        end) .. '"'
    end
    if #value > 0 or next(value) == nil then
        local parts = {}
        for i = 1, #value do parts[i] = json(value[i]) end
        return '[' .. table.concat(parts, ',') .. ']'
    end
    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    local parts = {}
    for _, key in ipairs(keys) do
        local text = json(value[key])
        if text ~= 'null' then parts[#parts + 1] = json(tostring(key)) .. ':' .. text end
    end
    return '{' .. table.concat(parts, ',') .. '}'
end

local function write(path, text)
    local file = io.open(path, 'w')
    if not file then return false end
    file:write(text)
    file:close()
    return true
end

--- data/atelier/index.js: every <Character>/saved/atelier/<JOB>_<SUB>.js on
--- the disk, and the one-file-per-job <JOB>.js written before 2026-10-01 (also
--- in <Character>/atelier/, the folder before 2026-09-30).
local function write_index()
    windower.create_dir(data_path('atelier'))
    local entries, seen = {}, {}
    for _, name in ipairs(windower.get_dir(data_path('')) or {}) do
        for _, folder in ipairs({'/saved/atelier/', '/atelier/'}) do
            for _, file in ipairs(windower.get_dir(data_path(name .. folder)) or {}) do
                local job, sub = file:match('^(%u%u%u)_?(%u*)%.js$')
                local key = job and name .. job .. sub
                if key and not seen[key] then
                    seen[key] = true
                    -- relative to data/, where atelier.html is: Tetsouo/saved/atelier/WAR_SAM.js
                    entries[#entries + 1] = {char = name, job = job, sub = sub ~= '' and sub or nil, file = name .. folder .. file}
                end
            end
        end
    end
    table.sort(entries, function(a, b) return a.char .. a.job .. (a.sub or '') < b.char .. b.job .. (b.sub or '') end)
    return write(data_path('atelier/index.js'), 'window.ATELIER_INDEX = ' .. json(entries) .. ';\n')
end

--- Export the current job. Returns the file written, or nil.
--- @return string|nil
function AtelierExport.export()
    if not (player and player.name and player.main_job) then return nil end
    local data = {
        player = player.name, job = player.main_job, sub = player.sub_job, at = os.date('%Y-%m-%d %H:%M'),
        sets = collect_sets(), keys = collect_keys(), modes = collect_modes(),
        macro = job_config('MACROBOOK'), lockstyle = job_config('LOCKSTYLE'),
        -- <job>/combat/<JOB>_WEAPONS.lua (PLD: shield per stance and weapon, stance weapon, grips):
        -- the page puts the weapons in the sets the way the job code does
        weapon_rules = job_config('WEAPONS'),
    }
    data.items, data.owned = collect_items()
    data.icons = collect_icons(data.sets, data.items)
    local ids = {}
    for _, id in pairs(data.icons or {}) do ids[#ids + 1] = id end
    data.scan = collect_scan(data.icons)
    data.char = collect_char()
    -- the worn pieces need their description and icon too, even when no set names them
    for _, piece in pairs(data.char and data.char.worn or {}) do
        data.icons = data.icons or {}
        if not data.icons[piece.name] then
            data.icons[piece.name] = piece.id
            ids[#ids + 1] = piece.id
        end
        piece.id = nil
    end
    data.descs = collect_descs(ids)
    data.wskill = collect_weapon_skills(data.icons)
    data.ws_skill = collect_ws_skills(data.sets)
    -- the keys changed in the page and saved (<Char>/saved/keybind_overrides.lua)
    local ok_o, KeyOverrides = pcall(require, 'shared/utils/keybinds/key_overrides')
    data.key_overrides = ok_o and KeyOverrides.read() or nil
    local ok_s, SetOverrides = pcall(require, 'shared/utils/atelier/set_overrides')
    data.set_overrides = ok_s and SetOverrides.read() or nil
    pcall(require('shared/utils/atelier/item_icons').write_missing, ids, data_path('atelier/icons/'))
    windower.create_dir(data_path(player.name .. '/saved'))
    windower.create_dir(data_path(player.name .. '/saved/atelier'))
    -- one file per subjob: the modes, weapons and WS a job offers can depend on it
    local sub = player.sub_job or 'NONE'
    local folder = player.name .. '/saved/atelier/'
    local rel = folder .. player.main_job .. '_' .. sub .. '.js'
    local c, j, s = json(player.name), json(player.main_job), json(sub)
    local text = ('window.ATELIER_SUBS = window.ATELIER_SUBS || {};\nATELIER_SUBS[%s] = ATELIER_SUBS[%s] || {};\n'
        .. 'ATELIER_SUBS[%s][%s] = ATELIER_SUBS[%s][%s] || {};\nATELIER_SUBS[%s][%s][%s] = %s;\n')
        :format(c, c, c, j, c, j, c, j, s, json(data))
    if not write(data_path(rel), text) then return nil end
    os.remove(data_path(folder .. player.main_job .. '.js'))
    write_index()
    return rel
end

--- After a load, when the switch is on (INIT_SYSTEMS): the job's modules and
--- keys are all in place a few seconds later.
function AtelierExport.after_load()
    if not AtelierExport.enabled() then return end
    require('shared/utils/core/load_gate').defer(4, function() pcall(AtelierExport.export) end, 'atelier export')
end

---============================================================================
--- COMMAND
---============================================================================

local function set_switch(on)
    windower._atelier_on = on
    local path = marker()
    if not path then return end
    if on then write(path, 'on') else os.remove(path) end
end

--- //gs c atelier [on|off]
--- @param args table Words after "atelier"
--- @return boolean handled
function AtelierExport.handle(args)
    local sub = args and args[1] and args[1]:lower() or ''
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    if sub == 'on' or sub == 'off' then
        set_switch(sub == 'on')
        MessageFormatter.show_info(('Atelier: export after each job load %s (reload the job for inherited pieces)')
            :format(sub == 'on' and 'ON' or 'OFF'))
        return true
    end
    local rel = AtelierExport.export()
    MessageFormatter.show_info(rel and ('Atelier: %s written, open data/atelier.html'):format(rel)
        or 'Atelier: export failed (could not write the file)')
    return true
end

_G.AtelierExport = AtelierExport

return AtelierExport
