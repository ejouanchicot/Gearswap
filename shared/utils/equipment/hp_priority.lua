---  ═══════════════════════════════════════════════════════════════════════════
---   HP Priority - equip order that keeps max HP (and MP) from dipping
---  ═══════════════════════════════════════════════════════════════════════════
---   GearSwap sends the pieces of a set from the highest `priority` to the
---   lowest, pieces without one counting as 0. Giving every piece its own HP
---   as priority makes the HP pieces go on before the HP-less ones replace
---   the others, so max HP never drops mid-swap and current HP is not lost.
---
---   Called once per job load by INIT_SYSTEMS, after Mote has loaded the sets.
---   It walks _G.sets and, for each piece that gives HP (or MP on the MP jobs):
---     • a plain name 'Null Loop' becomes {name='Null Loop', priority=50}
---     • an advanced entry {name=..., augments=...} gets its priority field
---   HP and MP come from shared/data/equipment/ITEM_HP_MP.lua (generated from
---   game data by scripts/item_db/build_item_db.py), plus the item's own
---   'HP+N' / 'MP+N' augments as written in the set (a piece the set names
---   without augments: the ones //gs c gearscan read in the bags, from
---   <Char>/saved/gear_augments.lua, see gear_scan.lua), plus its Unity bonus.
---
---   Settings: <Char>/_common/combat/HP_PRIORITY.lua (every key optional):
---     enabled   = true           false turns the whole system off
---     unity     = 'min'          'max' when your Unity leader is rank 1
---     mp_jobs   = {'BLM', ...}   priority = HP * 1000 + MP on these jobs
---     skip_jobs = {'PLD'}        jobs left alone (their sets set priorities)
---
---   Rules:
---     • priority = HP                      (all jobs)
---     • priority = HP * 1000 + MP          (mp_jobs: HP first, MP breaks ties)
---     • a piece that already has a priority is never touched
---
---   @file    shared/utils/equipment/hp_priority.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-23
---  ═══════════════════════════════════════════════════════════════════════════

local HPPriority = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

--- Loaded with dofile, not require: the project's module cache would keep the
--- 6000-entry lookup alive for the whole session, and it is only needed for
--- the one walk at job load.
local DATA_FILE = 'data/shared/data/equipment/ITEM_HP_MP.lua'

--- Defaults of HP_PRIORITY.lua. Unity rank is the rank of the character's
--- Unity leader: rank 1 gets the top of the range ('max').
local DEFAULTS = {
    enabled = true,
    unity = 'min',
    mp_jobs = { 'BLM', 'RDM', 'GEO' },
    skip_jobs = { 'PLD' },
}
local MP_WEIGHT = 1000

local SLOTS = {
    main = true, sub = true, range = true, ranged = true, ammo = true,
    head = true, neck = true, body = true, hands = true, back = true,
    waist = true, legs = true, feet = true,
    ear1 = true, ear2 = true, left_ear = true, right_ear = true, lear = true, rear = true,
    ring1 = true, ring2 = true, left_ring = true, right_ring = true, lring = true, rring = true,
}

--- Augment prefixes whose HP/MP belong to a pet, not the player.
local PET_PREFIXES = { 'Pet:', 'Avatar:', 'Automaton:', 'Wyvern:', 'Luopan:' }

---  ═══════════════════════════════════════════════════════════════════════════
---   HP / MP OF ONE PIECE
---  ═══════════════════════════════════════════════════════════════════════════

--- Is this augment about a pet?
--- @param augment string
--- @return boolean
local function is_pet_augment(augment)
    for _, prefix in ipairs(PET_PREFIXES) do
        if augment:sub(1, #prefix) == prefix then
            return true
        end
    end
    return false
end

--- HP and MP added by the augments written in the set.
--- @param augments table|nil List of augment strings
--- @return number hp, number mp
local function augment_hp_mp(augments)
    local hp, mp = 0, 0
    if type(augments) ~= 'table' then
        return hp, mp
    end
    for _, augment in ipairs(augments) do
        if type(augment) == 'string' and not is_pet_augment(augment) then
            for stat, sign, value in augment:gmatch('%f[%w]([HM]P)([%+%-])(%d+)%f[^%d%%]') do
                local amount = tonumber(value) * (sign == '-' and -1 or 1)
                if stat == 'HP' then hp = hp + amount else mp = mp + amount end
            end
        end
    end
    return hp, mp
end

--- HP and MP a piece gives.
--- @param data table ITEM_HP_MP lookup
--- @param name string Item name as written in the set
--- @param augments table|nil Augments as written in the set
--- @param unity string 'max' or 'min'
--- @param scanned table|nil gear_augments.lua (used when the set names no augments)
--- @return number hp, number mp
local function piece_hp_mp(data, name, augments, unity, scanned)
    local entry = data[name:lower()]
    local hp, mp = augment_hp_mp(augments)
    local seen = augments == nil and scanned and scanned[name:lower()]
    if type(seen) == 'table' and not seen.differ then
        hp, mp = hp + (tonumber(seen.hp) or 0), mp + (tonumber(seen.mp) or 0)
    end
    if entry then
        local u = unity == 'max' and 1 or 0
        hp = hp + entry[1] + (entry[3 + u] or 0)
        mp = mp + entry[2] + (entry[5 + u] or 0)
    end
    return hp, mp
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WALK
---  ═══════════════════════════════════════════════════════════════════════════

--- Priority of one slot value, or nil to leave it as it is.
--- @param value string|table Slot value from a set
--- @param ctx table Walk context {data, unity, weigh_mp}
--- @return number|nil
local function priority_of(value, ctx)
    local name, augments
    if type(value) == 'string' then
        name = value
    elseif type(value) == 'table' and type(value.name) == 'string' and value.priority == nil then
        name, augments = value.name, value.augments
    end
    if not name or name == '' or name:lower() == 'empty' then
        return nil
    end
    local hp, mp = piece_hp_mp(ctx.data, name, augments, ctx.unity, ctx.scanned)
    local priority = ctx.weigh_mp and (hp * MP_WEIGHT + mp) or hp
    return priority ~= 0 and priority or nil
end

--- Give every HP piece of a set tree its priority.
--- @param t table Set (or group of sets)
--- @param ctx table Walk context
--- @param visited table Tables already walked (sets reference each other)
--- @return void
local function walk(t, ctx, visited)
    if visited[t] then
        return
    end
    visited[t] = true
    for key, value in pairs(t) do
        if SLOTS[key] then
            local priority = priority_of(value, ctx)
            if priority then
                if type(value) == 'string' then
                    t[key] = { name = value, priority = priority }
                else
                    value.priority = priority
                end
                ctx.count = ctx.count + 1
            end
        elseif type(value) == 'table' and value.name == nil then
            walk(value, ctx, visited)
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- A list of job codes as a set ({'BLM'} -> {BLM = true}).
local function job_set(list)
    local out = {}
    for _, job in ipairs(type(list) == 'table' and list or {}) do out[tostring(job):upper()] = true end
    return out
end

--- The character's HP_PRIORITY.lua over the defaults.
--- @return table {enabled, unity, mp_jobs (set), skip_jobs (set)}
function HPPriority.settings()
    local ok, user = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'HP_PRIORITY')
    end)
    user = (ok and type(user) == 'table') and user or {}
    local function pick(key) if user[key] == nil then return DEFAULTS[key] end return user[key] end
    return {
        enabled = pick('enabled') ~= false,
        unity = pick('unity') == 'max' and 'max' or 'min',
        mp_jobs = job_set(pick('mp_jobs')),
        skip_jobs = job_set(pick('skip_jobs')),
    }
end

--- Apply HP priorities to the loaded sets of the current character and job.
--- Safe to call when the data file, the player or the sets are missing.
--- @return number Number of pieces given a priority
function HPPriority.apply()
    local job = player and player.main_job
    if not (job and type(_G.sets) == 'table') then
        return 0
    end
    local cfg = HPPriority.settings()
    if not cfg.enabled or cfg.skip_jobs[job] then
        return 0
    end
    local ok, data = pcall(dofile, windower.addon_path .. DATA_FILE)
    if not ok or type(data) ~= 'table' then
        return 0
    end
    local ok_s, GearScan = pcall(require, 'shared/utils/equipment/gear_scan')
    local ctx = { data = data, unity = cfg.unity, weigh_mp = cfg.mp_jobs[job] == true, count = 0,
        scanned = ok_s and GearScan and GearScan.load() or nil }
    walk(_G.sets, ctx, {})
    return ctx.count
end

-- Exposed for offline checks (scripts) that run the same arithmetic, and for
-- gear_scan.lua, which reads augments the same way.
HPPriority._piece_hp_mp = piece_hp_mp
HPPriority._augment_hp_mp = augment_hp_mp
HPPriority._config = { DEFAULTS = DEFAULTS, MP_WEIGHT = MP_WEIGHT }

_G.HPPriority = HPPriority

return HPPriority
