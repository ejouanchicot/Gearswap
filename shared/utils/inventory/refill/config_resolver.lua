---  ═══════════════════════════════════════════════════════════════════════════
---   Config Resolver - Load per-character refill configs and resolve foreign items
---  ═══════════════════════════════════════════════════════════════════════════
---   Per-character config files at:
---     <charname>/config/<job>/<JOB>_REFILL.lua
---
---   Each file returns a table with:
---     .default = { {name='X', target=N}, ... }
---     .subjobs = { DNC = { {name=..., target=...}, ... }, ... }  -- optional
---     .store_bag = 'case' | 'sack' | 'satchel'                   -- optional
---
---   Item `name` can be a string (single item) or a list of strings:
---     { name = {'Squid Sushi +1', 'Squid Sushi'}, target = 12 }
---   The list is tried in order: prefer +1, fall back to base.
---
---   CRAFT MODE override: when _G.__CraftManagerState.active is true, uses
---   <charname>/config/craft/CRAFT_REFILL.lua instead so inventory gets
---   craft-relevant items and everything else is detected as foreign.
---
---   Public API:
---     • resolve_list_for_player()       -> list, source_label, store_info
---     • build_foreign_items_set(char_name, current_list) -> foreign_set
---
---   @file    shared/utils/inventory/refill/config_resolver.lua
---   @author  Tetsouo
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

--- Bag-key -> {id, display} resolver for store_bag overrides.
local BAG_INFO = {
    case = {id = 7, display = 'Case'},
    sack = {id = 6, display = 'Sack'},
    satchel = {id = 5, display = 'Satchel'}
}

--- Default destination bag for SURPLUS items (count > target -> move back).
--- Configs may override via `<config>.store_bag = 'sack' | 'case' | 'satchel'`.
local DEFAULT_STORE_BAG = 'case'

---  ═══════════════════════════════════════════════════════════════════════════
---   INTERNAL HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Scan <charname>/config/ for any *_REFILL.lua and load them.
--- Returns a list of loaded config tables, regardless of which job they target.
--- @param char_name string
--- @return table list of {char=string, job=string, cfg=table}
local function load_char_refill_configs(char_name)
    if not char_name then
        return {}
    end
    local configs = {}
    local config_dir = windower.windower_path .. 'addons/GearSwap/data/' .. char_name .. '/config/'
    local subdirs = windower.get_dir(config_dir)
    if not subdirs then
        return {}
    end

    for _, entry in ipairs(subdirs) do
        -- entry can be a subdir name (job folder) or a .lua file at root
        local job_path = config_dir .. entry .. '/'
        local files = windower.get_dir(job_path)
        if files then
            for _, fname in ipairs(files) do
                local job = fname:match('^(%w+)_REFILL%.lua$')
                if job then
                    local mod = char_name .. '/config/' .. entry .. '/' .. job .. '_REFILL'
                    local ok, cfg = pcall(require, mod)
                    if ok and type(cfg) == 'table' then
                        table.insert(configs, {char = char_name, job = job:upper(), cfg = cfg})
                    end
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
--- character names are PascalCase). Skips _master, _dev, gitignored backups.
--- @return table list of {char=string, job=string, cfg=table}
local function load_all_refill_configs()
    local configs = {}
    local data_dir = windower.windower_path .. 'addons/GearSwap/data/'
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

--- Resolve the refill list for the current player (job + subjob).
--- Looks for <charname>/config/<job>/<JOB>_REFILL.lua. Picks subjobs[<sub>]
--- entry if defined, else .default. Falls back to FALLBACK_LIST.
--- Also resolves the store_bag override (top-level cfg.store_bag).
---
--- CRAFT MODE: if a craft set is currently active (//gs c craft / //gs c fish
--- locked the slots), uses <charname>/config/craft/CRAFT_REFILL.lua instead
--- so the inventory gets craft-relevant food.
---
--- @return table list, string source_label, table store_info {id, display}
function ConfigResolver.resolve_list_for_player()
    local p = windower.ffxi.get_player()
    local store_info = BAG_INFO[DEFAULT_STORE_BAG]
    if not p or not p.main_job or p.main_job == 'NON' then
        return FALLBACK_LIST, 'fallback (no player)', store_info
    end
    local char = p.name

    -- Craft mode override: check the global flag set by craft_manager.
    if _G.__CraftManagerState and _G.__CraftManagerState.active then
        local craft_path = char .. '/config/craft/CRAFT_REFILL'
        local ok_c, cfg_c = pcall(require, craft_path)
        if ok_c and type(cfg_c) == 'table' then
            if cfg_c.store_bag and BAG_INFO[cfg_c.store_bag] then
                store_info = BAG_INFO[cfg_c.store_bag]
            end
            if cfg_c.default then
                local label = 'CRAFT'
                if _G.__CraftManagerState.active_name then
                    label = label .. ' (' .. _G.__CraftManagerState.active_name .. ')'
                end
                return cfg_c.default, label, store_info
            end
        end
        -- If craft refill file missing, fall through to job-based logic
    end

    local job = p.main_job:upper()
    local sub = (p.sub_job and p.sub_job ~= 'NON') and p.sub_job:upper() or nil

    -- Build require path: <charname>/config/<lowerjob>/<JOB>_REFILL
    local mod_path = char .. '/config/' .. job:lower() .. '/' .. job .. '_REFILL'
    local ok, cfg = pcall(require, mod_path)
    if not ok or type(cfg) ~= 'table' then
        return FALLBACK_LIST, ('fallback (no %s)'):format(mod_path), store_info
    end

    -- Top-level store_bag override (default = Case)
    if cfg.store_bag and BAG_INFO[cfg.store_bag] then
        store_info = BAG_INFO[cfg.store_bag]
    end

    if sub and cfg.subjobs and cfg.subjobs[sub] then
        return cfg.subjobs[sub], ('%s/%s'):format(job, sub), store_info
    end
    if cfg.default then
        return cfg.default, ('%s/default'):format(job), store_info
    end
    return FALLBACK_LIST, ('fallback (%s has no .default)'):format(mod_path), store_info
end

return ConfigResolver
