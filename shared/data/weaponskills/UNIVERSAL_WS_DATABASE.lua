---============================================================================
--- Universal Weapon Skills Database - Complete Integration (LAZY-LOADED)
---============================================================================
--- Merges the weapon-specific WS databases into one lookup table,
--- _G.WS_DATABASE, one weapon type at a time.
---
--- **PERFORMANCE OPTIMIZATION:**
---   • LAZY-LOADED: nothing loads at startup
---   • resolve() loads only the file of the weaponskill's own skill
---   • Cached in _G.WS_DATABASE for all jobs
---
--- Pattern:
---   1. Individual weapon databases maintained separately (easy editing)
---   2. Merged into _G.WS_DATABASE on demand, per weapon type
---   3. Read by the WS messages (full mode only)
---
--- Database Coverage:
---   • SWORD (22 WS)
---   • DAGGER (18 WS)
---   • H2H (17 WS)
---   • GREATSWORD (15 WS)
---   • GREATAXE (18 WS)
---   • AXE (15 WS)
---   • SCYTHE (15 WS)
---   • POLEARM (15 WS)
---   • KATANA (15 WS)
---   • GREATKATANA (15 WS)
---   • STAFF (18 WS)
---   • CLUB (17 WS)
---   • ARCHERY (12 WS)
---   TOTAL: 212 Weapon Skills
---
--- @file UNIVERSAL_WS_DATABASE.lua
--- @author Tetsouo
--- @version 2.3 - PERFORMANCE: Lazy loading to reduce job load time
--- @date Created: 2025-10-29
--- @date Updated: 2025-11-15 - Lazy loading implementation
--- @source All data verified 300% against BG-Wiki
---============================================================================

---  ═══════════════════════════════════════════════════════════════════════════
---   GLOBAL CACHE (Shared across all jobs for instant access)
---  ═══════════════════════════════════════════════════════════════════════════

if not _G.WS_DATABASE then
    _G.WS_DATABASE = {
        weaponskills = {},
        weapon_types = {}
    }
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE INTERFACE
---  ═══════════════════════════════════════════════════════════════════════════

local UniversalWS = {}

---============================================================================
--- WEAPON TYPE CONFIGURATION
---============================================================================

-- List of all weapon types with databases (in load order)
local weapon_type_configs = {
    {file = 'SWORD_WS_DATABASE',       type = 'Sword',        count = 22},
    {file = 'DAGGER_WS_DATABASE',      type = 'Dagger',       count = 18},
    {file = 'H2H_WS_DATABASE',         type = 'Hand-to-Hand', count = 17},
    {file = 'GREATSWORD_WS_DATABASE',  type = 'Great Sword',  count = 15},
    {file = 'GREATAXE_WS_DATABASE',    type = 'Great Axe',    count = 18},
    {file = 'AXE_WS_DATABASE',         type = 'Axe',          count = 15},
    {file = 'SCYTHE_WS_DATABASE',      type = 'Scythe',       count = 15},
    {file = 'POLEARM_WS_DATABASE',     type = 'Polearm',      count = 15},
    {file = 'KATANA_WS_DATABASE',      type = 'Katana',       count = 15},
    {file = 'GREATKATANA_WS_DATABASE', type = 'Great Katana', count = 15},
    {file = 'STAFF_WS_DATABASE',       type = 'Staff',        count = 18},
    {file = 'CLUB_WS_DATABASE',        type = 'Club',         count = 17},
    {file = 'ARCHERY_WS_DATABASE',     type = 'Archery',      count = 12}
}

---============================================================================
--- LAZY LOAD FUNCTIONS (Per-weapon-type, on demand)
---============================================================================

-- Reverse lookup: weapon type name -> config entry
local config_by_type = {}
for _, config in ipairs(weapon_type_configs) do
    config_by_type[config.type] = config
end

--- Merge a single weapon type's database into the global cache (idempotent).
--- @param config table Entry from weapon_type_configs
local function merge_weapon_db(config)
    if _G.WS_DATABASE.weapon_types[config.type] then
        return  -- Already merged
    end

    local success, weapon_db = pcall(require, 'shared/data/weaponskills/' .. config.file)
    if not (success and weapon_db and weapon_db.weaponskills) then
        return
    end

    local ws_count = 0
    for ws_name, ws_data in pairs(weapon_db.weaponskills) do
        ws_data.weapon_type = config.type
        ws_data.weapon_file = config.file
        -- Root level (jobs access WS_DB['Fast Blade']) + .weaponskills (helpers)
        _G.WS_DATABASE[ws_name] = ws_data
        _G.WS_DATABASE.weaponskills[ws_name] = ws_data
        ws_count = ws_count + 1
    end

    _G.WS_DATABASE.weapon_types[config.type] = {
        file = config.file,
        count = ws_count,
        expected = config.count
    }
end

--- Load a single weapon type's database on demand.
--- @param weapon_type string Weapon type name (e.g. 'Sword', 'Hand-to-Hand')
function UniversalWS.ensure_weapon_type(weapon_type)
    local config = weapon_type and config_by_type[weapon_type]
    if config then
        merge_weapon_db(config)
    end
end

--- Resolve a weapon skill by name, loading only the database of its weapon type.
--- Every record sits in the file of its own skill, so a weaponskill that is not
--- there (Atonement, or a Marksmanship one: no file) is in none of them, and a
--- miss returns nil instead of merging all 13 databases.
--- @param ws_name string Weapon skill name
--- @param weapon_type string|nil The weaponskill's skill (GearSwap spell.skill, e.g. 'Sword')
--- @return table|nil Weapon skill data, or nil if its weapon type's database lacks it
function UniversalWS.resolve(ws_name, weapon_type)
    if _G.WS_DATABASE.weaponskills[ws_name] then
        return _G.WS_DATABASE.weaponskills[ws_name]
    end

    UniversalWS.ensure_weapon_type(weapon_type)
    return _G.WS_DATABASE.weaponskills[ws_name]
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return UniversalWS
