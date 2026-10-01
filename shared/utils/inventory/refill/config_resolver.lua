---  ═══════════════════════════════════════════════════════════════════════════
---   Config Resolver - Load per-character refill configs and resolve foreign items
---  ═══════════════════════════════════════════════════════════════════════════
---   The list a refill uses, first match:
---     1. the craft list while a craft session runs (CRAFT_REFILL.lua)
---     2. the job's list, <charname>/<job>/inventory/<JOB>_REFILL.lua:
---          .subjobs[<sub>]  its list for that subjob
---          .default         its own list, in place of the common one
---          .extra           added to the common list (same name: its target)
---     3. the common list, <charname>/_common/inventory/REFILL_CONFIG.lua:
---          .subjobs[<sub>]  the common list for that subjob
---          .default_list    the common list
---     4. FALLBACK_LIST below (a character with neither file)
---   A job file whose lines are all comments (the template) uses the common
---   list. Both files may also set:
---     .store_bag   = 'case'                   -- where surplus goes
---     .source_bags = {'case', 'sack'}         -- where pulls come from
---   Bags: case, sack, satchel, wardrobe1..wardrobe8; the job file wins.
---   REFILL_CONFIG.lua also says which items in the inventory go back to the
---   store bag (foreign: in another list, not in the active one):
---     .store_foreign      = 'mine'           -- this character's lists (default),
---                                            -- 'all' other folders too, false never
---     .foreign_characters = {'Tetsouo'}      -- with 'all': these folders only
---     .never_store        = {'Echo Drops'}   -- never put back
---
---   Item `name` can be a string (single item) or a list of strings:
---     { name = {'Squid Sushi +1', 'Squid Sushi'}, target = 12 }
---   The list is tried in order: prefer +1, fall back to base.
---
---   CRAFT MODE override: when CraftManager.is_active() is true, uses
---   <charname>/_common/inventory/CRAFT_REFILL.lua instead so inventory gets
---   craft-relevant items and everything else is detected as foreign.
---
---   Public API:
---     • resolve_list_for_player()       -> list, source_label, store_info
---     • build_foreign_items_set(char_name, current_list) -> foreign_set
---
---   @file    shared/utils/inventory/refill/config_resolver.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-05-09 (extracted from refill_manager.lua)
---  ═══════════════════════════════════════════════════════════════════════════

local ItemResolver = require('shared/utils/inventory/refill/item_resolver')

local ConfigResolver = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CONSTANTS
---  ═══════════════════════════════════════════════════════════════════════════

--- Last resort, for a character with no list anywhere (neither a job list nor
--- REFILL_CONFIG.default_list): the list the project always used.
local FALLBACK_LIST = {
    {name = 'Panacea', target = 12},
    {name = 'Antacid', target = 12},
    {name = 'Holy Water', target = 12},
    {name = 'Remedy', target = 12},
    {name = 'Prism Powder', target = 12},
    {name = 'Silent Oil', target = 12}
}

--- The bags a refill can use: every bag the game opens away from the Mog
--- House (Mog Safe, Storage and Locker only open there). Name as written in
--- a config -> {key in windower.ffxi.get_items(), id, display}.
--- Wardrobes only hold equipment (ammo, for instance): the game refuses
--- anything else there.
local BAG_INFO = {
    case      = {key = 'case',      id = 7,  display = 'Case'},
    sack      = {key = 'sack',      id = 6,  display = 'Sack'},
    satchel   = {key = 'satchel',   id = 5,  display = 'Satchel'},
    wardrobe  = {key = 'wardrobe',  id = 8,  display = 'Wardrobe'},
    wardrobe1 = {key = 'wardrobe',  id = 8,  display = 'Wardrobe'},
    wardrobe2 = {key = 'wardrobe2', id = 10, display = 'Wardrobe 2'},
    wardrobe3 = {key = 'wardrobe3', id = 11, display = 'Wardrobe 3'},
    wardrobe4 = {key = 'wardrobe4', id = 12, display = 'Wardrobe 4'},
    wardrobe5 = {key = 'wardrobe5', id = 13, display = 'Wardrobe 5'},
    wardrobe6 = {key = 'wardrobe6', id = 14, display = 'Wardrobe 6'},
    wardrobe7 = {key = 'wardrobe7', id = 15, display = 'Wardrobe 7'},
    wardrobe8 = {key = 'wardrobe8', id = 16, display = 'Wardrobe 8'},
}

--- Where SURPLUS and foreign items go, and where missing items are taken
--- from (in order), unless the player's configs say otherwise: the list file
--- (<JOB>_REFILL.lua, CRAFT_REFILL.lua) first, then _common/inventory/REFILL_CONFIG.lua.
local DEFAULT_STORE_BAG = 'case'
local DEFAULT_SOURCE_BAGS = {'case', 'sack', 'satchel'}

---  ═══════════════════════════════════════════════════════════════════════════
---   INTERNAL HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Scan a character folder for every *_REFILL.lua: <job>/inventory/ and
--- common/inventory/ (layout since 2026-09-30), <job>/, config/<job>/ and
--- config/craft/ (before).
--- Returns a list of loaded config tables, regardless of which job they target.
--- @param char_name string
--- @return table list of {char=string, job=string, cfg=table}
local function load_char_refill_configs(char_name)
    if not char_name then
        return {}
    end
    local configs, seen = {}, {}
    local base = windower.addon_path .. 'data/' .. char_name .. '/'
    local folders = {'_common/inventory', 'common/inventory', 'common/craft'}
    for _, root in ipairs({'', 'config/'}) do
        for _, entry in ipairs(windower.get_dir(base .. root) or {}) do
            if not entry:match('%.') then
                folders[#folders + 1] = root .. entry
                folders[#folders + 1] = root .. entry .. '/inventory'
            end
        end
    end
    for _, folder in ipairs(folders) do
        for _, fname in ipairs(windower.get_dir(base .. folder .. '/') or {}) do
            local job = fname:match('^(%w+)_REFILL%.lua$')
            if fname == 'REFILL_CONFIG.lua' then job = 'COMMON' end
            local mod = job and (char_name .. '/' .. folder .. '/' .. fname:gsub('%.lua$', ''))
            if mod and not seen[mod] then
                seen[mod] = true
                local ok, cfg = pcall(require, mod)
                if ok and type(cfg) == 'table' then
                    table.insert(configs, {char = char_name, job = job:upper(), cfg = cfg})
                end
            end
        end
    end
    return configs
end

--- Scan the character folders under data/ for *_REFILL.lua configs, for
--- store_foreign = 'all': Kaories on GEO then puts back the items of
--- Tetsouo's lists too (Silent Oil from his melee jobs).
---
--- Character folders start with an uppercase letter (FFXI names are
--- PascalCase), so _master, shared, scripts etc. are skipped. `only`: the
--- names to read (case-insensitive); nil or empty reads every folder.
--- @param only table|nil List of character names
--- @return table list of {char=string, job=string, cfg=table}
local function load_all_refill_configs(only)
    local wanted = {}
    for _, name in ipairs(type(only) == 'table' and only or {}) do
        if type(name) == 'string' then wanted[name:lower()] = true end
    end
    local configs = {}
    local data_dir = windower.addon_path .. 'data/'
    for _, char_entry in ipairs(windower.get_dir(data_dir) or {}) do
        if char_entry:match('^[A-Z]') and (next(wanted) == nil or wanted[char_entry:lower()]) then
            for _, c in ipairs(load_char_refill_configs(char_entry)) do
                table.insert(configs, c)
            end
        end
    end
    return configs
end

--- The character's REFILL_CONFIG.lua (bags for every list, foreign items),
--- or nil.
--- @param char string Character name
--- @return table|nil
local function load_refill_config(char)
    local ok, cfg = require('shared/utils/core/char_paths').load('common', 'REFILL_CONFIG', nil, char)
    return (ok and type(cfg) == 'table') and cfg or nil
end

--- The refill configs whose items count as foreign, from REFILL_CONFIG.lua:
--- store_foreign 'mine' (default) this character's lists, 'all' the lists
--- of foreign_characters (every folder when empty), false none.
--- @param char_name string
--- @param cfg table|nil REFILL_CONFIG.lua
--- @return table list of {char, job, cfg}
local function foreign_sources(char_name, cfg)
    local mode = cfg and cfg.store_foreign
    if mode == nil then mode = 'mine' end
    if mode == false or mode == 'off' then return {} end
    if mode == 'all' then return load_all_refill_configs(cfg.foreign_characters) end
    return load_char_refill_configs(char_name)
end

--- Iterate all entries in a config (default, extra, default_list and every
--- subjob list) and call fn(entry).
local function iterate_config_entries(cfg, fn)
    for _, key in ipairs({'default', 'extra', 'default_list'}) do
        if type(cfg[key]) == 'table' then
            for _, e in ipairs(cfg[key]) do
                fn(e)
            end
        end
    end
    if cfg.subjobs then
        for _, list in pairs(cfg.subjobs) do
            for _, e in ipairs(list) do
                fn(e)
            end
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- Build a set of item IDs that belong to OTHER lists (not the active one).
--- Used to identify foreign refill items sitting in inventory that should be
--- pushed back to the store_bag. Which lists count: store_foreign in
--- REFILL_CONFIG.lua (foreign_sources); never_store items are never in it.
--- @param char_name string
--- @param current_list table  the list resolved for the active job/subjob
--- @return table {[item_id] = display_name}
function ConfigResolver.build_foreign_items_set(char_name, current_list)
    local cfg = load_refill_config(char_name)
    local current_ids = {}
    local kept = {}
    for _, name in ipairs(cfg and type(cfg.never_store) == 'table' and cfg.never_store or {}) do
        kept[#kept + 1] = {name = name}
    end
    for _, list in ipairs({current_list, kept}) do
        for _, entry in ipairs(list) do
            local variants = (type(entry.name) == 'table') and entry.name or {entry.name}
            for _, n in ipairs(variants) do
                local id = ItemResolver.resolve_item_id(n)
                if id then current_ids[id] = true end
            end
        end
    end

    local foreign = {}
    for _, c in ipairs(foreign_sources(char_name, cfg)) do
        iterate_config_entries(c.cfg, function(entry)
            local variants = (type(entry.name) == 'table') and entry.name or {entry.name}
            for _, n in ipairs(variants) do
                local id = ItemResolver.resolve_item_id(n)
                if id and not current_ids[id] and not foreign[id] then
                    foreign[id] = n
                end
            end
        end)
    end
    return foreign
end

--- A bag named in a config, or nil when the name is not a usable bag.
local function bag(name)
    return type(name) == 'string' and BAG_INFO[name:lower():gsub('%s', '')] or nil
end

--- The bags one refill uses: `store_bag` and `source_bags` from the list
--- file, else from REFILL_CONFIG.lua, else Case / Case, Sack, Satchel.
--- Unknown bag names are skipped.
--- @param list_cfg table|nil The <JOB>_REFILL / CRAFT_REFILL table
--- @param global_cfg table|nil REFILL_CONFIG.lua
--- @return table {id, display, sources = {{key, id, display}, ...}}
local function resolve_bags(list_cfg, global_cfg)
    local function pick(field)
        if list_cfg and list_cfg[field] ~= nil then return list_cfg[field] end
        return global_cfg and global_cfg[field]
    end
    local store = bag(pick('store_bag')) or BAG_INFO[DEFAULT_STORE_BAG]
    local sources = {}
    local wanted = pick('source_bags')
    for _, name in ipairs(type(wanted) == 'table' and wanted or DEFAULT_SOURCE_BAGS) do
        sources[#sources + 1] = bag(name)
    end
    if #sources == 0 then
        for _, name in ipairs(DEFAULT_SOURCE_BAGS) do sources[#sources + 1] = BAG_INFO[name] end
    end
    return {id = store.id, display = store.display, sources = sources}
end

--- The craft list while a craft session runs (//gs c craft / fish), or nil.
--- @param char string Character name
--- @return table|nil list, string label, table cfg
local function craft_list(char)
    local CraftManager = _G.CraftManager
    if not (CraftManager and CraftManager.is_active()) then return nil end
    local ok, cfg = require('shared/utils/core/char_paths').load('craft', 'CRAFT_REFILL', nil, char)
    if not (ok and type(cfg) == 'table' and cfg.default) then return nil end
    local name = CraftManager.active_name()
    return cfg.default, name and ('CRAFT (' .. name .. ')') or 'CRAFT', cfg
end

--- The source bags used when nothing names any: Case, Sack, Satchel.
--- @return table {{key, id, display}, ...}
function ConfigResolver.default_sources()
    return resolve_bags(nil, nil).sources
end

--- Key of a list entry, to match an extra with a common entry: its name, or
--- the first of its variants, lower case.
local function entry_key(entry)
    local n = type(entry.name) == 'table' and entry.name[1] or entry.name
    return tostring(n or ''):lower()
end

--- The common list with a job's extras: an extra naming an item already in
--- the list replaces that entry (its target wins), the others are added.
--- @return table New list
local function with_extra(common, extra)
    local out, index = {}, {}
    for _, e in ipairs(common) do
        out[#out + 1] = e
        index[entry_key(e)] = #out
    end
    for _, e in ipairs(extra) do
        local at = index[entry_key(e)]
        if at then out[at] = e else out[#out + 1] = e end
    end
    return out
end

--- The common list (REFILL_CONFIG.lua) for a subjob, else FALLBACK_LIST.
--- @return table list, string label
local function common_list(global_cfg, sub)
    local subjobs = global_cfg and global_cfg.subjobs
    if sub and type(subjobs) == 'table' and type(subjobs[sub]) == 'table' then
        return subjobs[sub], 'common/' .. sub
    end
    if global_cfg and type(global_cfg.default_list) == 'table' then
        return global_cfg.default_list, 'common'
    end
    return FALLBACK_LIST, 'fallback'
end

--- Resolve the refill list for the current player (job + subjob), in the
--- order given in the file header.
--- @return table list, string source_label, table bags {id, display, sources}
    ---   (id / display: where surplus goes; sources: where pulls come from)
function ConfigResolver.resolve_list_for_player()
    local p = windower.ffxi.get_player()
    if not p or not p.main_job or p.main_job == 'NON' then
        return FALLBACK_LIST, 'fallback (no player)', resolve_bags(nil, nil)
    end
    local char = p.name
    local global_cfg = load_refill_config(char)

    -- Craft mode: craft_manager owns the session state. A missing
    -- CRAFT_REFILL.lua falls through to the job's list.
    local list, label, craft_cfg = craft_list(char)
    if list then return list, label, resolve_bags(craft_cfg, global_cfg) end

    local job = p.main_job:upper()
    local sub = (p.sub_job and p.sub_job ~= 'NON') and p.sub_job:upper() or nil
    local mod_path = require('shared/utils/core/char_paths').module('job', job .. '_REFILL', job, char)
    local ok, cfg = pcall(require, mod_path)
    if not ok or type(cfg) ~= 'table' then cfg = nil end

    local bags = resolve_bags(cfg, global_cfg)
    if cfg and sub and type(cfg.subjobs) == 'table' and type(cfg.subjobs[sub]) == 'table' then
        return cfg.subjobs[sub], ('%s/%s'):format(job, sub), bags
    end
    if cfg and type(cfg.default) == 'table' then
        return cfg.default, ('%s/default'):format(job), bags
    end
    local common, common_label = common_list(global_cfg, sub)
    if cfg and type(cfg.extra) == 'table' then
        return with_extra(common, cfg.extra), ('%s + %s extra'):format(common_label, job), bags
    end
    return common, common_label, bags
end

return ConfigResolver
