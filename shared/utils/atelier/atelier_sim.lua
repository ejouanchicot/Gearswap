---============================================================================
--- Atelier Sim - what GearSwap would wear for an action, without doing it
---============================================================================
--- The Atelier page (Simulate tab, through the live link) asks: "Cure IV on
--- me, engaged, HybridMode PDT: what do you wear?". This module builds the
--- spell the way GearSwap does when you type the command (spell_complete of
--- the resource line, the target, the action type), then runs the job's own
--- precast, midcast and aftercast (Mote's handlers and every module behind
--- them) and reads what they put in GearSwap's equip list. Nothing reaches the
--- game: equip_list is only sent by equip_sets, which is not called; commands,
--- scheduled work and chat lines are caught for the time of the run; the
--- modes, the status and the equip list are put back afterwards.
---
--- @file shared/utils/atelier/atelier_sim.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local AtelierSim = {}

local KINDS = {
    ma = {res = 'spells', prefix = '/ma'}, ja = {res = 'job_abilities', prefix = '/ja'},
    ws = {res = 'weapon_skills', prefix = '/ws'},
}
local PHASES = {'precast', 'midcast', 'aftercast'}

local function gs() return gearswap end

-- The resource line of an action, by its English name
local function find_line(kind, name)
    local book = gs().res[KINDS[kind].res]
    local want = name:lower()
    for _, line in pairs(book) do
        if type(line) == 'table' and line.en and line.en:lower() == want then return line end
    end
    return nil
end

-- The target: yourself (GearSwap's own <me>), or a mob in reach (the one you
-- have targeted, else a stand-in at 3 yalms)
local function target_of(kind)
    local G = gs()
    local ok, mob = pcall(G.valid_target, kind)
    if ok and type(mob) == 'table' and mob.type and mob.type ~= 'NONE' then return mob end
    if kind == '<me>' then return {type = 'SELF', name = player.name, raw = '<me>', id = player.id, distance = 0, hpp = 100} end
    return {type = 'MONSTER', name = 'Training Dummy', raw = '<t>', id = 0, index = 0, distance = 3, hpp = 100,
        is_npc = true, spawn_type = 16, status = 'Engaged', model_size = 1}
end

-- One piece of the equip list as the page reads it
local function piece_of(item)
    if type(item) == 'string' then return {name = item} end
    if type(item) == 'table' then
        if item.name then
            local augs
            if type(item.augments) == 'table' and #item.augments > 0 then
                augs = {}
                for i, a in ipairs(item.augments) do augs[i] = tostring(a) end
            end
            return {name = item.name, augs = augs}
        end
        return {name = 'empty'}
    end
    return nil
end

-- GearSwap's slot names (left_ear, right_ring, ranged...) as the page names them
local SLOT_NAME = {main = 'main', sub = 'sub', range = 'range', ranged = 'range', ammo = 'ammo', head = 'head', neck = 'neck',
    ear1 = 'ear1', left_ear = 'ear1', lear = 'ear1', ear2 = 'ear2', right_ear = 'ear2', rear = 'ear2', body = 'body',
    hands = 'hands', ring1 = 'ring1', left_ring = 'ring1', lring = 'ring1', ring2 = 'ring2', right_ring = 'ring2',
    rring = 'ring2', back = 'back', waist = 'waist', legs = 'legs', feet = 'feet'}

local function read_list()
    local out = {}
    for slot, item in pairs(gs().equip_list) do
        local name = type(slot) == 'string' and SLOT_NAME[slot:lower()]
        if name then out[name] = piece_of(item) end
    end
    return out
end

---============================================================================
--- QUARANTINE: what the job code may do besides equipping
---============================================================================

-- Whether an action can aim at an enemy (resource targets: a set {Enemy = true}
-- through Windower's resources library, the raw bit field 32 otherwise)
local function aims_enemy(line)
    local t = line.targets
    if type(t) == 'table' then return t.Enemy == true or (type(t.contains) == 'function' and t:contains('Enemy')) end
    return type(t) == 'number' and math.floor(t / 32) % 2 == 1
end

local function quarantine(messages, scheduled, ignore_recasts, tp)
    local saved = {}
    local function swap(tbl, key, value)
        saved[#saved + 1] = {tbl, key, rawget(tbl, key)}
        rawset(tbl, key, value)
    end
    local function note(_, text) messages[#messages + 1] = tostring(text or _) end
    swap(windower, 'send_command', function(cmd) messages[#messages + 1] = '> ' .. tostring(cmd) end)
    swap(windower, 'add_to_chat', note)
    if rawget(_G, 'send_command') then swap(_G, 'send_command', function(cmd) messages[#messages + 1] = '> ' .. tostring(cmd) end) end
    if rawget(_G, 'add_to_chat') then swap(_G, 'add_to_chat', note) end
    if rawget(_G, 'cancel_spell') then swap(_G, 'cancel_spell', function() messages.cancelled = true end) end
    for _, name in ipairs({'cast_delay', 'change_target', 'disable', 'enable'}) do
        if rawget(_G, name) then swap(_G, name, function() end) end
    end
    swap(coroutine, 'schedule', function() scheduled.n = (scheduled.n or 0) + 1 end)
    -- a weaponskill is tried with the TP asked (3000 by default): the game would cancel it at 0
    if tp then
        local real = windower.ffxi.get_player
        swap(windower.ffxi, 'get_player', function()
            local p = real()
            if type(p) == 'table' then p.vitals = p.vitals or {}; p.vitals.tp = tp end
            return p
        end)
    end
    if ignore_recasts then
        local zero = setmetatable({}, {__index = function() return 0 end})
        swap(windower.ffxi, 'get_ability_recasts', function() return zero end)
        swap(windower.ffxi, 'get_spell_recasts', function() return zero end)
    end
    return function()
        for i = #saved, 1, -1 do rawset(saved[i][1], saved[i][2], saved[i][3]) end
    end
end

-- The modes, as they are now, to put back after the run
local function snapshot_states()
    local snap = {}
    for name, st in pairs(rawget(_G, 'state') or {}) do
        if type(st) == 'table' and st.value ~= nil and type(st.set) == 'function' then snap[name] = st.value end
    end
    return snap
end

local function set_states(values)
    local states = rawget(_G, 'state') or {}
    for name, value in pairs(values) do
        local st = states[name]
        if type(st) == 'table' and type(st.set) == 'function' then pcall(st.set, st, value) end
    end
end

---============================================================================
--- RUN
---============================================================================

--- Run an action through the job's precast, midcast and aftercast.
--- @param req table {kind = 'ma'|'ja'|'ws', name = 'Cure IV', target = 'auto'|'me'|'enemy',
---   status = 'Idle'|'Engaged'|nil, states = {HybridMode = 'PDT'}, ignore_recasts = boolean,
---   tp = number (weaponskills, 3000 by default)}
--- @return table {ok, phases = {{phase, list}}, messages, cancelled, scheduled, error}
function AtelierSim.run(req)
    local G = gs()
    if not (G and KINDS[req.kind] and req.name) then return {ok = false, error = 'bad request'} end
    local line = find_line(req.kind, req.name)
    if not line then return {ok = false, error = 'unknown action: ' .. req.name} end

    local r_line = G.copy_entry(line)
    r_line.name = r_line[G.language] or r_line.en
    local spell = G.spell_complete(r_line)
    -- the action's own target unless one is asked: Phalanx on oneself, Flash on the enemy
    local on_me = req.target == 'me' or ((req.target == nil or req.target == 'auto') and not aims_enemy(line))
    spell.target = target_of(on_me and '<me>' or '<t>')
    spell.action_type = G.action_type_map[KINDS[req.kind].prefix]
    spell.interrupted = false

    local messages, scheduled, phases = {}, {}, {}
    local snap, status = snapshot_states(), player.status
    local tp = req.kind == 'ws' and (tonumber(req.tp) or 3000) or nil
    local tp_was, vitals_tp_was = player.tp, player.vitals and player.vitals.tp
    local restore = quarantine(messages, scheduled, req.ignore_recasts ~= false, tp)
    local ok, err = pcall(function()
        set_states(req.states or {})
        if req.status then player.status = req.status end
        if tp then player.tp = tp; if player.vitals then player.vitals.tp = tp end end
        for _, phase in ipairs(PHASES) do
            local handler = rawget(_G, phase)
            if type(handler) == 'function' then
                G.table.reassign(G.equip_list, {})
                G._global.cancel_spell = false
                G._global.current_event = phase
                handler(spell)
                phases[#phases + 1] = {phase = phase, list = read_list()}
                -- a cancelled action stops here, as in game
                if phase == 'precast' and (messages.cancelled or G._global.cancel_spell) then
                    messages.cancelled = true
                    break
                end
            end
        end
    end)
    restore()
    set_states(snap)
    player.status = status
    if tp then player.tp = tp_was; if player.vitals then player.vitals.tp = vitals_tp_was end end
    G.table.reassign(G.equip_list, {})
    G._global.cancel_spell = false
    G._global.current_event = 'None'
    local cancelled = messages.cancelled == true
    messages.cancelled = nil
    return {ok = ok, error = not ok and tostring(err) or nil, phases = phases, messages = messages,
        cancelled = cancelled, scheduled = scheduled.n or 0, spell = {name = spell.name, type = spell.type, skill = spell.skill}}
end

--- The actions the page offers: the spells the character knows for the job, its
--- job abilities and weapon skills (names only, by kind).
--- @return table {ma = {...}, ja = {...}, ws = {...}}
function AtelierSim.actions()
    local G = gs()
    local out = {ma = {}, ja = {}, ws = {}}
    local ok_s, known = pcall(windower.ffxi.get_spells)
    local main, sub = player.main_job_id, player.sub_job_id
    local main_lv, sub_lv = player.main_job_level or 99, player.sub_job_level or 0
    for id, line in pairs(G.res.spells) do
        local levels = type(line.levels) == 'table' and line.levels or {}
        local usable = (levels[main] and levels[main] <= main_lv) or (sub and levels[sub] and levels[sub] <= sub_lv)
        if line.en and usable and (not ok_s or not known or known[id]) then out.ma[#out.ma + 1] = line.en end
    end
    local ok_a, abil = pcall(windower.ffxi.get_abilities)
    if ok_a and abil then
        for _, id in ipairs(abil.job_abilities or {}) do
            local line = G.res.job_abilities[id]
            if line and line.en then out.ja[#out.ja + 1] = line.en end
        end
        for _, id in ipairs(abil.weapon_skills or {}) do
            local line = G.res.weapon_skills[id]
            if line and line.en then out.ws[#out.ws + 1] = line.en end
        end
    end
    for _, list in pairs(out) do table.sort(list) end
    return out
end

return AtelierSim
