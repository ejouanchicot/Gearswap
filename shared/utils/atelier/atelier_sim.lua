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
    if kind == '<p1>' then return {type = 'PLAYER', name = 'Party member', raw = '<p1>', id = 1, index = 1, distance = 5, hpp = 75,
        ispartymember = true, isallymember = true, is_npc = false, spawn_type = 1, status = 'Idle'} end
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
local function aims(line, who, bit)
    local t = line.targets
    if type(t) == 'table' then return t[who] == true or (type(t.contains) == 'function' and t:contains(who)) end
    return type(t) == 'number' and math.floor(t / bit) % 2 == 1
end
local function aims_enemy(line) return aims(line, 'Enemy', 32) end
local function aims_self(line) return aims(line, 'Self', 1) end
local function aims_ally(line) return aims(line, 'Party', 4) or aims(line, 'Player', 2) or aims(line, 'Ally', 8) end

-- recasts: nil = the game's; 'all' = everything ready; a recast id = that one ready, the
-- others running (the ability a helper fires first is then taken as already used)
local function quarantine(messages, scheduled, recasts, tp)
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
    if recasts then
        local own = recasts ~= 'all' and recasts or nil
        local table_of = setmetatable({}, {__index = function(_, id) return (not own or id == own) and 0 or 60 end})
        swap(windower.ffxi, 'get_ability_recasts', function() return table_of end)
        swap(windower.ffxi, 'get_spell_recasts', function() return table_of end)
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

-- One run of the three steps, everything put back after it
local function run_once(G, spell, req, recasts, tp)
    local messages, scheduled, phases = {}, {}, {}
    local snap, status = snapshot_states(), player.status
    local tp_was, vitals_tp_was = player.tp, player.vitals and player.vitals.tp
    local restore = quarantine(messages, scheduled, recasts, tp)
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
        cancelled = cancelled, scheduled = scheduled.n or 0}
end

--- Run an action through the job's precast, midcast and aftercast.
--- @param req table {kind = 'ma'|'ja'|'ws', name = 'Cure IV', target = 'auto'|'me'|'enemy',
---   status = 'Idle'|'Engaged'|nil, states = {HybridMode = 'PDT'}, ignore_recasts = boolean,
---   tp = number (weaponskills, 3000 by default)}
--- @return table {ok, phases = {{phase, list}}, messages, cancelled, scheduled, error,
---   before = the ability a helper fires first (Majesty before a Cure), if any}
function AtelierSim.run(req)
    local G = gs()
    if not (G and KINDS[req.kind] and req.name) then return {ok = false, error = 'bad request'} end
    local line = find_line(req.kind, req.name)
    if not line then return {ok = false, error = 'unknown action: ' .. req.name} end

    local r_line = G.copy_entry(line)
    r_line.name = r_line[G.language] or r_line.en
    local spell = G.spell_complete(r_line)
    -- the action's own target unless one is asked: Phalanx on oneself, Flash on the enemy;
    -- 'ally': a party member (Cure on another player: CureOther sets)
    local on_me = req.target == 'me' or ((req.target == nil or req.target == 'auto') and not aims_enemy(line))
    spell.target = target_of(req.target == 'ally' and '<p1>' or on_me and '<me>' or '<t>')
    spell.action_type = G.action_type_map[KINDS[req.kind].prefix]
    spell.interrupted = false

    local tp = req.kind == 'ws' and (tonumber(req.tp) or 3000) or nil
    local own = line.recast_id or line.id
    local first = run_once(G, spell, req, req.ignore_recasts ~= false and 'all' or nil, tp)
    -- a helper (AbilityHelper) cancels the action to fire an ability first and casts it again
    -- right after: as in game, the action then runs with that ability used (its recast running)
    local before = nil
    for _, m in ipairs(first.messages) do
        local ja = tostring(m):match('^> input /ja "([^"]+)"') or tostring(m):match("^> input /ja '([^']+)'")
        if ja then before = ja break end
    end
    local result = first
    if first.cancelled and before and req.ignore_recasts ~= false then
        result = run_once(G, spell, req, own, tp)
        for i, m in ipairs(first.messages) do table.insert(result.messages, i, m) end
    end
    result.before = before
    result.spell = {name = spell.name, type = spell.type, skill = spell.skill}
    return result
end

---============================================================================
--- WORN: the idle / engaged set the job's own code builds
---============================================================================

-- A stand-in for buffactive: the buffs the page lists, by any case (GearSwap's is case-insensitive)
-- and by id (WAR reads Aftermath as buffactive[272])
local function buffs_of(csv)
    local t, want = {}, {}
    for name in tostring(csv or ''):gmatch('[^,]+') do t[name:lower()] = 1; want[name:lower()] = true end
    for id, line in pairs(gs().res.buffs or {}) do
        if type(line) == 'table' and line.en and want[line.en:lower()] then t[id] = 1 end
    end
    return setmetatable(t, {__index = function(tbl, k) return type(k) == 'string' and rawget(tbl, k:lower()) or nil end})
end

-- The pet GearSwap describes, as the job code reads it (pet.isvalid, status, name)
local PET_NAMES = {GEO = 'Luopan', SMN = 'Carbuncle', PUP = 'Automaton', DRG = 'Wyvern', BST = 'Pet'}
local function pet_of(kind)
    if kind ~= 'idle' and kind ~= 'engaged' then
        return {isvalid = false, status = 'None', name = nil, hpp = 0, tp = 0}
    end
    local name = PET_NAMES[player.main_job] or 'Pet'
    return {isvalid = true, status = kind == 'engaged' and 'Engaged' or 'Idle', name = name, hpp = 100, tp = 0,
        element = 'Light', id = 0, index = 0}
end

--- What the job wears idle or engaged, as its own code builds it (Mote's handle_equipping_gear,
--- the job's set builder, every overlay), with what the page chose standing for the game's:
--- the status, the modes, the buffs, the town or the field, moving, the pet. Nothing is sent.
--- @param req table {status = 'Idle'|'Engaged', states = {Mode = value}, buffs = 'A,B',
---   town = boolean, moving = boolean, pet = 'none'|'idle'|'engaged'}
--- @return table {ok, list = {slot = piece}, messages, error}
function AtelierSim.worn(req)
    local G = gs()
    if not G then return {ok = false, error = 'no gearswap'} end
    local messages, scheduled = {}, {}
    local snap, status = snapshot_states(), player.status
    local restore = quarantine(messages, scheduled, nil, nil)
    local saved = {}
    local function swap(tbl, key, value)
        if type(tbl) ~= 'table' then return end
        saved[#saved + 1] = {tbl, key, rawget(tbl, key)}
        rawset(tbl, key, value)
    end
    local list, ok, err = {}, nil, nil
    ok, err = pcall(function()
        local states = {}
        for k, v in pairs(req.states or {}) do states[k] = v end
        states.Moving = req.moving and 'true' or 'false'
        set_states(states)
        player.status = req.status == 'Engaged' and 'Engaged' or 'Idle'
        swap(_G, 'buffactive', buffs_of(req.buffs))
        swap(_G, 'pet', pet_of(req.pet))
        if rawget(_G, 'world') then swap(world, 'area', req.town and 'Bastok Markets' or 'Reisenjima') end
        G.table.reassign(G.equip_list, {})
        G._global.current_event = 'aftercast'
        local handler = rawget(_G, 'handle_equipping_gear')
        if type(handler) == 'function' then
            local pet_status = (req.pet == 'idle' or req.pet == 'engaged') and (req.pet == 'engaged' and 'Engaged' or 'Idle') or nil
            handler(player.status, pet_status)
        end
        list = read_list()
    end)
    for i = #saved, 1, -1 do rawset(saved[i][1], saved[i][2], saved[i][3]) end
    restore()
    set_states(snap)
    player.status = status
    G.table.reassign(G.equip_list, {})
    G._global.current_event = 'None'
    return {ok = ok, error = not ok and tostring(err) or nil, list = list, messages = messages}
end

--- The buffs the job's code reads (its quoted strings that are buff names of the game, in
--- shared/jobs/<job>/), and whether the job has a pet: the choices of the page's Worn view.
--- @return table {buffs = {...}, pet = boolean}
function AtelierSim.worn_options()
    local G = gs()
    local known = {}
    for _, line in pairs(G.res.buffs or {}) do
        if type(line) == 'table' and line.en then known[line.en:lower()] = line.en end
    end
    local found, seen = {}, {}
    local root = windower.addon_path .. 'data/shared/jobs/' .. tostring(player.main_job):lower() .. '/'
    local function scan(dir, depth)
        if depth > 4 then return end
        for _, name in ipairs(windower.get_dir(dir) or {}) do
            if name:match('%.lua$') then
                local f = io.open(dir .. name, 'r')
                local text = f and f:read('*a') or ''
                if f then f:close() end
                for word in text:gmatch("['\"]([^'\"\r\n]+)['\"]") do
                    local en = known[word:lower()]
                    if en and not seen[en] then seen[en] = true; found[#found + 1] = en end
                end
                -- buffs read by id (buffactive[272]: Aftermath: Lv.3)
                for id in text:gmatch('buffactive%[(%d+)%]') do
                    local line = G.res.buffs[tonumber(id)]
                    local en = type(line) == 'table' and line.en
                    if en and not seen[en] then seen[en] = true; found[#found + 1] = en end
                end
            elseif not name:match('%.') then
                scan(dir .. name .. '/', depth + 1)
            end
        end
    end
    pcall(scan, root, 0)
    table.sort(found)
    return {buffs = found, pet = PET_NAMES[player.main_job] ~= nil}
end

--- The TP bonus pieces the job's own rules add to a weaponskill at a TP: TPBonusCalculator
--- (shared/utils/weaponskill/tp_bonus_calculator.lua) with the job's TP config (<JOB>_TP_CONFIG.lua,
--- _G.<JOB>TPConfig), the main / sub the page shows and the buffs it lists (Warcry, Hagakure...:
--- they stand for buffactive during the call, so the page's choice counts, not what is on now).
--- @param req table {tp = number|nil, main = string|nil, sub = string|nil, buffs = 'Warcry,Hagakure'|nil}
--- @return table {ok, config = boolean, gear = {slot = name} (page slot names), bonus = TP the weapon
---   and buffs add, total = TP all the pieces add, thresholds = {2000, 3000}}
function AtelierSim.tp_bonus(req)
    local config = player and rawget(_G, tostring(player.main_job) .. 'TPConfig')
    local ok_c, Calc = pcall(require, 'shared/utils/weaponskill/tp_bonus_calculator')
    if not (ok_c and Calc and type(config) == 'table') then return {ok = true, gear = {}, config = false} end
    local main = req.main ~= '' and req.main or nil
    local sub = req.sub ~= '' and req.sub or nil
    local buffs = {}
    for name in tostring(req.buffs or ''):gmatch('[^,]+') do buffs[name] = true end
    local was = rawget(_G, 'buffactive')
    rawset(_G, 'buffactive', buffs)
    local ok_b, bonus = pcall(function() return Calc.effective_tp and Calc.effective_tp(0, config, main, buffs, sub) or 0 end)
    local tp = tonumber(req.tp)
    local ok, gear = true, nil
    if tp then ok, gear = pcall(Calc.calculate, tp, config, main, buffs, sub) end
    rawset(_G, 'buffactive', was)
    local out, total = {}, 0
    for slot, name in pairs(ok and type(gear) == 'table' and gear or {}) do
        local page = SLOT_NAME[tostring(slot):lower()]
        if page then out[page] = name end
    end
    for _, piece in ipairs(type(config.pieces) == 'table' and config.pieces or {}) do total = total + (tonumber(piece.bonus) or 0) end
    return {ok = ok, config = true, gear = out, bonus = ok_b and bonus or 0, total = total,
        thresholds = (Calc.config or {}).thresholds or {2000, 3000}}
end

--- The actions the page offers: the spells the character knows for the job, its
--- job abilities and weapon skills (names only, by kind).
--- @return table {ma = {...}, ja = {...}, ws = {...}, magic = {<skill> = {...}}, trust = one Trust's name or nil}
function AtelierSim.actions()
    local G = gs()
    local out = {ma = {}, ja = {}, ws = {}, magic = {}, aim = {}}
    -- aim[name]: the targets it accepts among me, ally, enemy ('me ally enemy')
    local function note_aim(line)
        local list = {}
        if aims_self(line) then list[#list + 1] = 'me' end
        if aims_ally(line) then list[#list + 1] = 'ally' end
        if aims_enemy(line) then list[#list + 1] = 'enemy' end
        out.aim[line.en] = table.concat(list, ' ')
    end
    local ok_s, known = pcall(windower.ffxi.get_spells)
    local main, sub = player.main_job_id, player.sub_job_id
    local main_lv, sub_lv = player.main_job_level or 99, player.sub_job_level or 0
    for id, line in pairs(G.res.spells) do
        local levels = type(line.levels) == 'table' and line.levels or {}
        local usable = (levels[main] and levels[main] <= main_lv) or (sub and levels[sub] and levels[sub] <= sub_lv)
        if line.en and usable and (not ok_s or not known or known[id]) then
            -- every Trust casts the same way for the job's sets: one stands for all (out.trust)
            if line.type == 'Trust' then out.trust = out.trust or line.en
            else
                note_aim(line)
                out.ma[#out.ma + 1] = line.en
                -- by magic skill, for the page's groups (Healing Magic, Enhancing Magic...)
                local skill = G.res.skills[line.skill]
                local group = skill and skill.en or 'Other'
                out.magic[group] = out.magic[group] or {}
                table.insert(out.magic[group], line.en)
            end
        end
    end
    local ok_a, abil = pcall(windower.ffxi.get_abilities)
    if ok_a and abil then
        for _, id in ipairs(abil.job_abilities or {}) do
            local line = G.res.job_abilities[id]
            if line and line.en then out.ja[#out.ja + 1] = line.en; note_aim(line) end
        end
        for _, id in ipairs(abil.weapon_skills or {}) do
            local line = G.res.weapon_skills[id]
            if line and line.en then out.ws[#out.ws + 1] = line.en; out.aim[line.en] = 'enemy' end
        end
    end
    for _, list in pairs({out.ma, out.ja, out.ws}) do table.sort(list) end
    for _, list in pairs(out.magic) do table.sort(list) end
    return out
end

return AtelierSim
