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
---   'HP+N' / 'MP+N' augments as written in the set, plus its Unity bonus.
---
---   Rules:
---     • priority = HP                      (all jobs)
---     • priority = HP * 1000 + MP          (MP_JOBS: HP first, MP breaks ties)
---     • a piece that already has a priority is never touched
---     • SKIP_JOBS keep their own hand-tuned scheme (PLD: HP deltas per set)
---     • only CHARACTERS are processed; frozen clones stay as they are
---
---   @file    shared/utils/equipment/hp_priority.lua
---   @author  Tetsouo
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

--- Characters processed, with the Unity bonus they get. Unity rank is the
--- rank of the character's Unity leader: rank 1 gets the top of the range.
local CHARACTERS = {
    Tetsouo = { unity = 'max' },
    Kaories = { unity = 'min' },
}

--- Jobs whose priority also weighs MP (HP still comes first).
local MP_JOBS = { BLM = true, RDM = true, GEO = true }
local MP_WEIGHT = 1000

--- Jobs with their own priority scheme, left untouched.
local SKIP_JOBS = { PLD = true }

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
--- @return number hp, number mp
local function piece_hp_mp(data, name, augments, unity)
    local entry = data[name:lower()]
    local hp, mp = augment_hp_mp(augments)
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
    local hp, mp = piece_hp_mp(ctx.data, name, augments, ctx.unity)
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

--- Apply HP priorities to the loaded sets of the current character and job.
--- Safe to call when the data file, the player or the sets are missing.
--- @return number Number of pieces given a priority
function HPPriority.apply()
    local who = player and CHARACTERS[player.name]
    local job = player and player.main_job
    if not (who and job and type(_G.sets) == 'table') or SKIP_JOBS[job] then
        return 0
    end
    local ok, data = pcall(dofile, windower.addon_path .. DATA_FILE)
    if not ok or type(data) ~= 'table' then
        return 0
    end
    local ctx = { data = data, unity = who.unity, weigh_mp = MP_JOBS[job] == true, count = 0 }
    walk(_G.sets, ctx, {})
    return ctx.count
end

-- Exposed for offline checks (scripts) that run the same arithmetic.
HPPriority._piece_hp_mp = piece_hp_mp
HPPriority._config = { CHARACTERS = CHARACTERS, MP_JOBS = MP_JOBS, MP_WEIGHT = MP_WEIGHT, SKIP_JOBS = SKIP_JOBS }

_G.HPPriority = HPPriority

return HPPriority
