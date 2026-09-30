---  ═══════════════════════════════════════════════════════════════════════════
---   Config Resolver - Load per-character refill configs and resolve foreign items
---  ═══════════════════════════════════════════════════════════════════════════
---   Per-character config files at:
---     <charname>/<job>/<JOB>_REFILL.lua (config/<job>/ before 2026-09-30)
---
---   Each file returns a table with:
---     .default = { {name='X', target=N}, ... }
---     .subjobs = { DNC = { {name=..., target=...}, ... }, ... }  -- optional
---     .store_bag   = 'case'                   -- optional, where surplus goes
---     .source_bags = {'case', 'sack'}         -- optional, where pulls come from
---   Bags: case, sack, satchel, wardrobe1..wardrobe8. Both fields can also
---   sit in <charname>/common/REFILL_CONFIG.lua, for every list at once.
---
---   Item `name` can be a string (single item) or a list of strings:
---     { name = {'Squid Sushi +1', 'Squid Sushi'}, target = 12 }
---   The list is tried in order: prefer +1, fall back to base.
---
---   CRAFT MODE override: when CraftManager.is_active() is true, uses
---   <charname>/common/craft/CRAFT_REFILL.lua instead so inventory gets
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

--- Hardcoded fallback list, used if no config file is found for the active job.
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
--- (<JOB>_REFILL.lua, CRAFT_REFILL.lua) first, then config/REFILL_CONFIG.lua.
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
    local folders = {'common/inventory', 'common/craft'}
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
            local mod = job and (char_name .. '/' .. folder .. '/' .. job .. '_REFILL')
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

--- Scan ALL character folders under data/ for *_REFILL.lua configs.
--- This makes foreign detection cross-character: Kaories on GEO will detect
--- items used by Tetsouo's other jobs (e.g. Silent Oil from Tetsouo melee
--- jobs) as foreign and push them back to the store_bag.
---
--- Heuristic for character folders: must start with uppercase letter (FFXI
--- character names are PascalCase), so _master, shared, scripts etc. are
--- skipped. Every such folder counts, frozen clones included.
--- @return table list of {char=string, job=string, cfg=table}
local function load_all_refill_configs()
    local configs = {}
    local data_dir = windower.addon_path .. 'data/'
    local entries = windower.get_dir(data_dir)
    if not entries then
        return {}
    end

    for _, char_entry in ipairs(entries) do
        if char_entry:match('^[A-Z]') then
            local char_configs = load_char_refill_configs(char_entry)
            for _, c in ipairs(char_configs) do
                table.insert(configs, c)
            end
        end
    end
    return configs
end

--- Iterate all entries in a config (default + every subjob list) and call fn(entry).
local function iterate_config_entries(cfg, fn)
    if cfg.default then
        for _, e in ipairs(cfg.default) do
            fn(e)
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

--- Build a set of item IDs that belong to OTHER jobs (not the active list).
--- Used to identify foreign refill items sitting in inventory that should be
--- pushed back to the store_bag.
--- @param char_name string
--- @param current_list table  the list resolved for the active job/subjob
--- @return table {[item_id] = display_name}
function ConfigResolver.build_foreign_items_set(char_name, current_list)
    local current_ids = {}
    for _, entry in ipairs(current_list) do
        local variants = (type(entry.name) == 'table') and entry.name or {entry.name}
        for _, n in ipairs(variants) do
            local id = ItemResolver.resolve_item_id(n)
            if id then
                current_ids[id] = true
            end
        end
    end

    -- GLOBAL scan: include configs from ALL characters so cross-character items
    -- (e.g. Silent Oil used by Tetsouo melee jobs but not by any Kaories job)
    -- are correctly flagged as foreign when running on a different character.
    local foreign = {}
    for _, c in ipairs(load_all_refill_configs()) do
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

--- The character's config/REFILL_CONFIG.lua (bags for every list), or nil.
--- @param char string Character name
--- @return table|nil
local function load_refill_config(char)
    local ok, cfg = require('shared/utils/core/char_paths').load('common', 'REFILL_CONFIG', nil, char)
    return (ok and type(cfg) == 'table') and cfg or nil
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

--- Resolve the refill list for the current player (job + subjob).
--- Looks for <charname>/config/<job>/<JOB>_REFILL.lua. Picks subjobs[<sub>]
--- entry if defined, else .default. Falls back to FALLBACK_LIST.
--- Also resolves the store_bag override (top-level cfg.store_bag).
---
--- CRAFT MODE: if a craft set is currently active (//gs c craft / //gs c fish
--- locked the slots), uses <charname>/config/craft/CRAFT_REFILL.lua instead
--- so the inventory gets craft-relevant food.
---
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
    if not ok or type(cfg) ~= 'table' then
        return FALLBACK_LIST, ('fallback (no %s)'):format(mod_path), resolve_bags(nil, global_cfg)
    end

    local bags = resolve_bags(cfg, global_cfg)
    if sub and cfg.subjobs and cfg.subjobs[sub] then
        return cfg.subjobs[sub], ('%s/%s'):format(job, sub), bags
    end
    if cfg.default then
        return cfg.default, ('%s/default'):format(job), bags
    end
    return FALLBACK_LIST, ('fallback (%s has no .default)'):format(mod_path), bags
end

return ConfigResolver
