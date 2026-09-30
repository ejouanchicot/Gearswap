---  ═══════════════════════════════════════════════════════════════════════════
---   HP Priority - equip order that keeps max HP (and MP) from dipping
---  ═══════════════════════════════════════════════════════════════════════════
---   GearSwap sends the pieces of a swap from the highest `priority` to the
---   lowest, pieces without one counting as 0. Every action goes through
---   several swaps (idle or engaged > precast > midcast > aftercast > idle or
---   engaged), and each starts from what the one before put on. So the rank
---   is set at each swap, not once: a piece's priority is the HP it gains
---   over the piece worn in that slot right now (player.equipment: what
---   GearSwap has sent, which the server takes as worn). The pieces that raise
---   max HP go on first, those that lower it last: max HP never dips mid-swap
---   and current HP is not lost.
---
---   How: at each job load (INIT_SYSTEMS, after Mote has loaded the sets),
---   apply() keeps the HP / MP of every piece the sets name (from
---   shared/data/equipment/ITEM_HP_MP.lua, generated from game data by
---   scripts/item_db/build_item_db.py, then dropped) and wraps GearSwap's
---   equip(): each set it is given is passed on as a copy whose pieces carry
---   their priority. The sets themselves are never changed.
---
---   HP / MP of a piece: its base, plus the 'HP+N' / 'MP+N' augments written in
---   the set (a piece named without augments, and the piece worn: the ones
---   //gs c gearscan read in the bags, <Char>/saved/gear_augments.lua, see
---   gear_scan.lua), plus its Unity bonus.
---
---   Settings: <Char>/_common/combat/HP_PRIORITY.lua (every key optional):
---     enabled   = true           false turns the whole system off
---     unity     = 'min'          'max' when your Unity leader is rank 1
---     mp_jobs   = {'BLM', ...}   MP counts too on these jobs, after HP
---     skip_jobs = {}             jobs left alone
---
---   Rules:
---     • priority = HP gained over the worn piece
---     • priority = HP gained * 1000 + MP gained   (mp_jobs)
---     • a piece that already has a priority in the set is never touched
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
--- 6000-entry lookup alive for the whole session. Only the entries of the
--- pieces the sets name are kept (apply).
local DATA_FILE = 'data/shared/data/equipment/ITEM_HP_MP.lua'

--- Defaults of HP_PRIORITY.lua. Unity rank is the rank of the character's
--- Unity leader: rank 1 gets the top of the range ('max').
local DEFAULTS = {
    enabled = true,
    unity = 'min',
    mp_jobs = { 'BLM', 'RDM', 'GEO' },
    skip_jobs = {},
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
---   PRIORITY OF A SWAP
---  ═══════════════════════════════════════════════════════════════════════════

--- The name player.equipment uses for each slot a set may write.
local WORN_SLOT = {
    ear1 = 'left_ear', lear = 'left_ear', ear2 = 'right_ear', rear = 'right_ear',
    ring1 = 'left_ring', lring = 'left_ring', ring2 = 'right_ring', rring = 'right_ring',
    ranged = 'range',
}

--- Load state: {index, unity, weigh_mp, scanned}, set by apply().
local state_key = '_hp_priority_state'

--- Name and augments of a slot value (nil name for empty or unknown values).
local function name_of(value)
    if type(value) == 'string' then return value, nil end
    if type(value) == 'table' and type(value.name) == 'string' then return value.name, value.augments end
    return nil
end

--- HP and MP of a slot value, 0 / 0 for an empty slot.
--- @param value string|table|nil
--- @param st table Load state
local function value_hp_mp(value, st)
    local name, augments = name_of(value)
    if not name or name == '' or name:lower() == 'empty' then return 0, 0 end
    return piece_hp_mp(st.index, name, augments, st.unity, st.scanned)
end

--- Priority of one piece of a set, or nil to leave it as it is.
--- @param key string Slot name as written in the set
--- @param value string|table
--- @param st table Load state
--- @return number|nil
local function priority_of(key, value, st)
    if type(value) == 'table' and value.priority ~= nil then return nil end
    local name = name_of(value)
    if not name then return nil end
    local worn = player and player.equipment and player.equipment[WORN_SLOT[key] or key]
    local hp, mp = value_hp_mp(value, st)
    local worn_hp, worn_mp = value_hp_mp(worn, st)
    local dhp, dmp = hp - worn_hp, mp - worn_mp
    local priority = st.weigh_mp and (dhp * MP_WEIGHT + dmp) or dhp
    return priority ~= 0 and priority or nil
end

--- A copy of a set whose pieces carry their priority for this swap.
--- @param set table
--- @param st table Load state
--- @return table
local function ranked_copy(set, st)
    local out = {}
    for key, value in pairs(set) do
        local priority = SLOTS[key] and priority_of(key, value, st)
        if priority then
            local piece = {}
            if type(value) == 'table' then
                for k, v in pairs(value) do piece[k] = v end
            else
                piece.name = value
            end
            piece.priority = priority
            out[key] = piece
        else
            out[key] = value
        end
    end
    return out
end

--- equip() of GearSwap with the ranks of this swap laid on the sets.
local function wrap_equip()
    local wrapper = rawget(_G, '_hp_priority_equip')
    if wrapper and rawget(_G, 'equip') == wrapper then return end
    local raw_equip = rawget(_G, 'equip')
    if type(raw_equip) ~= 'function' then return end
    wrapper = function(...)
        local st = rawget(_G, state_key)
        if not st then return raw_equip(...) end
        local args = { ... }
        for i = 1, select('#', ...) do
            if type(args[i]) == 'table' then args[i] = ranked_copy(args[i], st) end
        end
        return raw_equip((table.unpack or unpack)(args, 1, select("#", ...)))
    end
    _G._hp_priority_equip = wrapper
    _G.equip = wrapper
end

--- Keep the ITEM_HP_MP entries of every piece the sets name (and the pieces
--- worn now), so the 6000-entry file is not held.
--- @param data table ITEM_HP_MP
--- @return table index {[lower name] = entry}
local function build_index(data)
    local index, visited = {}, {}
    local function add(value)
        local name = name_of(value)
        if name then
            local key = name:lower()
            if data[key] then index[key] = data[key] end
        end
    end
    local function walk(t)
        if visited[t] then return end
        visited[t] = true
        for key, value in pairs(t) do
            if SLOTS[key] then add(value)
            elseif type(value) == 'table' and value.name == nil then walk(value) end
        end
    end
    walk(_G.sets)
    for _, worn in pairs(player and player.equipment or {}) do add(worn) end
    return index
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

--- Set up the ranks for the current character and job: keep the HP / MP of
--- the pieces of the sets and wrap equip(). Nothing when the system is off
--- or the job skipped. Safe when the data file, the player or the sets are
--- missing.
--- @return number Number of pieces whose HP / MP is known
function HPPriority.apply()
    _G[state_key] = nil
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
    local index = build_index(data)
    _G[state_key] = { index = index, unity = cfg.unity, weigh_mp = cfg.mp_jobs[job] == true,
        scanned = ok_s and GearScan and GearScan.load() or nil }
    wrap_equip()
    local count = 0
    for _ in pairs(index) do count = count + 1 end
    return count
end

-- Exposed for offline checks (scripts) that run the same arithmetic, and for
-- gear_scan.lua, which reads augments the same way.
HPPriority._piece_hp_mp = piece_hp_mp
HPPriority._augment_hp_mp = augment_hp_mp
HPPriority._config = { DEFAULTS = DEFAULTS, MP_WEIGHT = MP_WEIGHT }
HPPriority._ranked_copy = function(set) return ranked_copy(set, rawget(_G, state_key)) end

_G.HPPriority = HPPriority

return HPPriority
