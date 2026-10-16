---============================================================================
--- Probe - what a loaded job equips, scenario by scenario
---============================================================================
--- Runs inside an offline GearSwap environment (foreign_eval.lua for a foreign
--- file, our_probe.lua for ours) after the job has loaded, and plays the
--- scenarios of a spec file the way GearSwap drives a job: idle and engaged
--- through handle_equipping_gear(status), an action through precast(spell)
--- then midcast(spell). equip() and cancel_spell() are recorded; what is
--- worn after each step is written per slot, under GearSwap's slot names.
---
--- Spec (JSON, written by make_spec.js), one scenario per line:
---   {label, status = 'Idle'|'Engaged', modes = {State = value},
---    action = {kind = 'spell'|'ws'|'ja', name = ...}}
---
--- @file    scripts/convert/probe.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-16
---============================================================================

local Probe = {}

-- A tiny JSON reader for the spec (objects, arrays, strings, numbers, booleans, null)
local function decode(text)
    local i = 1
    local function ws() i = text:find('[^%s]', i) or #text + 1 end
    local value
    local function str()
        local out, j = {}, i + 1
        while true do
            local c = text:sub(j, j)
            if c == '"' then break end
            if c == '\\' then
                local n = text:sub(j + 1, j + 1)
                if n == 'u' then
                    out[#out + 1] = string.char(tonumber(text:sub(j + 2, j + 5), 16) % 256)
                    j = j + 6
                else
                    out[#out + 1] = ({n = '\n', t = '\t', r = '\r', b = '\b', f = '\f'})[n] or n
                    j = j + 2
                end
            else
                out[#out + 1] = c
                j = j + 1
            end
        end
        i = j + 1
        return table.concat(out)
    end
    function value()
        ws()
        local c = text:sub(i, i)
        if c == '{' then
            local t = {}
            i = i + 1 ws()
            if text:sub(i, i) == '}' then i = i + 1 return t end
            while true do
                ws() local k = str() ws() i = i + 1
                t[k] = value() ws()
                local d = text:sub(i, i) i = i + 1
                if d == '}' then return t end
            end
        elseif c == '[' then
            local t = {}
            i = i + 1 ws()
            if text:sub(i, i) == ']' then i = i + 1 return t end
            while true do
                t[#t + 1] = value() ws()
                local d = text:sub(i, i) i = i + 1
                if d == ']' then return t end
            end
        elseif c == '"' then return str()
        elseif text:sub(i, i + 3) == 'true' then i = i + 4 return true
        elseif text:sub(i, i + 4) == 'false' then i = i + 5 return false
        elseif text:sub(i, i + 3) == 'null' then i = i + 4 return nil
        else
            local n = text:match('^-?[%d%.eE+-]+', i)
            i = i + #n
            return tonumber(n)
        end
    end
    return value()
end
Probe.decode = decode

---============================================================================
--- ACTIONS AS GEARSWAP HANDS THEM TO A JOB
---============================================================================

local function by_name(list, name)
    if type(list) ~= 'table' then return nil end
    local lower = name:lower()
    for _, v in pairs(list) do
        if type(v) == 'table' and type(v.en) == 'string' and v.en:lower() == lower then return v end
    end
end

-- The spell table GearSwap builds (helper_functions.lua spell_complete): the resource's
-- fields, its names, its skill and element as words, and a target
local function action_table(res, kind, name, S, me)
    -- a ranged attack (/ra): GearSwap's own action, with no resource line
    if kind == 'ra' then
        return {english = 'Ranged', name = 'Ranged', en = 'Ranged', action_type = 'Ranged Attack', type = 'Misc',
            prefix = '/range', id = 65535, targets = S({'Enemy'}), interrupted = false,
            target = {type = 'MONSTER', name = 'Mob', raw = '<t>', id = 99, index = 99, hpp = 100, distance = 10,
                is_npc = true, status = 1, x = 0, y = 0, z = 0, model_size = 2}}
    end
    local src = kind == 'spell' and by_name(res.spells, name)
        or kind == 'ws' and by_name(res.weapon_skills, name)
        or kind == 'ja' and by_name(res.job_abilities, name)
    if not src then return nil end
    local s = {}
    for k, v in pairs(src) do s[k] = v end
    s.english, s.name = src.en, src.en
    s.action_type = kind == 'spell' and 'Magic' or 'Ability'
    if kind == 'ws' then s.type = 'WeaponSkill' end
    if src.skill and res.skills and res.skills[src.skill] then s.skill = res.skills[src.skill].en end
    if src.element and res.elements and res.elements[src.element] then s.element = res.elements[src.element].en end
    -- the resource file gives the targets as bits; Windower's resources library (libs/resources.lua
    -- bit_slots) turns them into a set of names, which is what a job reads
    local bits, names = tonumber(src.targets) or 0, {}
    if bits == 0x60 then names = {'Object'} elseif bits == 0x9D then names = {'Corpse'} else
        for _, b in ipairs({{1, 'Self'}, {2, 'Player'}, {4, 'Party'}, {8, 'Ally'}, {16, 'NPC'}, {32, 'Enemy'}}) do
            if math.floor(bits / b[1]) % 2 == 1 then names[#names + 1] = b[2] end
        end
    end
    s.targets = S(names)
    local enemy, self_ok = s.targets:contains('Enemy'), s.targets:contains('Self')
    local self_only = not enemy and self_ok
    s.target = self_only
        and {type = 'SELF', name = me, raw = '<me>', id = 1, index = 1, hpp = 100, distance = 0, is_npc = false, status = 0, x = 0, y = 0, z = 0, model_size = 1}
        or {type = 'MONSTER', name = 'Mob', raw = '<t>', id = 99, index = 99, hpp = 100, distance = 9, is_npc = true, status = 1,
            x = 0, y = 0, z = 0, model_size = 2}
    if kind ~= 'spell' and not self_only then s.target.distance = 3 end
    s.interrupted = false
    return s
end

---============================================================================
--- RUN
---============================================================================

local function copy(t) local r = {} for k, v in pairs(t) do r[k] = v end return r end

--- What the game gives a job and the offline harnesses do not, made the same on both sides:
--- every recast ready, the bags GearSwap copies on `player` (empty), and the resources' :with().
--- @param env table
--- @param res table
function Probe.prepare(env, res)
    local ready = function() return setmetatable({}, {__index = function() return 0 end}) end
    local ffxi = env.windower and env.windower.ffxi
    if ffxi then ffxi.get_spell_recasts, ffxi.get_ability_recasts = ready, ready end
    -- the game always gives each bag's size (max_inventory...); the harnesses do not
    if ffxi and ffxi.get_items then
        local orig = ffxi.get_items
        ffxi.get_items = function(...)
            local t = orig(...)
            if type(t) == 'table' and select('#', ...) == 0 then
                for _, bag in ipairs({'inventory', 'safe', 'storage', 'locker', 'satchel', 'sack', 'case', 'wardrobe',
                    'wardrobe2', 'wardrobe3', 'wardrobe4', 'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}) do
                    t['max_' .. bag] = t['max_' .. bag] or 80
                    t[bag] = t[bag] or {}
                end
            end
            return t
        end
    end
    for _, bag in ipairs({'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4', 'wardrobe5', 'wardrobe6',
        'wardrobe7', 'wardrobe8', 'safe', 'storage', 'locker', 'satchel', 'sack', 'case'}) do
        env.player[bag] = env.player[bag] or {}
    end
    -- Windower's sets: Mote's elemental helpers union two of them
    if type(env.set) == 'table' and not rawget(env.set, 'union') then
        rawset(env.set, 'union', function(s, o)
            local r = env.S({})
            for k in pairs(s) do r[k] = true end
            for k in pairs(o or {}) do r[k] = true end
            return r
        end)
    end
    local with = {with = function(t, k, v)
        for _, x in pairs(t) do if type(x) == 'table' and x[k] == v then return x end end
    end}
    for _, name in ipairs({'spells', 'job_abilities', 'weapon_skills', 'buffs', 'items', 'jobs', 'skills', 'elements'}) do
        local t = res[name]
        if type(t) == 'table' and not getmetatable(t) then setmetatable(t, {__index = with}) end
    end
end

local function job_id(res, code)
    for id, j in pairs(res.jobs or {}) do if type(j) == 'table' and j.ens == code then return id end end
end

--- A spec line {expand = 'spells', main, sub, sub_level, modes, label_suffix} stands for one
--- scenario per spell the two jobs can cast (Trusts left out), in name order: both
--- sides expand it the same way.
--- @param spec table
--- @param res table
--- @return table
function Probe.expand(spec, res)
    local out = {}
    for _, sc in ipairs(spec) do
        if sc.expand == 'spells' then
            local mid, sid, names = job_id(res, sc.main), job_id(res, sc.sub), {}
            for _, s in pairs(res.spells or {}) do
                local lv = type(s) == 'table' and s.levels
                if lv and s.en and s.type ~= 'Trust' and ((mid and lv[mid]) or (sid and lv[sid] and lv[sid] <= (sc.sub_level or 53))) then
                    names[#names + 1] = s.en
                end
            end
            table.sort(names)
            for _, n in ipairs(names) do
                out[#out + 1] = {label = 'spell:' .. n .. (sc.label_suffix or ''), status = sc.status, modes = sc.modes,
                    buffs = sc.buffs, world = sc.world, mp = sc.mp, pet = sc.pet, action = {kind = 'spell', name = n}}
            end
        else
            out[#out + 1] = sc
        end
    end
    return out
end

--- Play every scenario of the spec in `env` and return what was worn.
--- @param env table The job's global environment, loaded
--- @param spec table List of scenarios
--- @param opts table {res, slot_name = SetDump.SLOT_NAME, piece = function(item) -> data}
--- @return table {label = {pre = {slot = piece}, mid = {...}, cancelled, error}}
function Probe.run(env, spec, opts)
    local res, SLOT_NAME = opts.res, opts.slot_name
    Probe.prepare(env, res)
    -- an item may be written by its long name (Pedagogy Loafers +3) or its short one (Peda. Loafers +3):
    -- GearSwap takes both, so the result names it the short way
    local short = {}
    for _, it in pairs(res.items or {}) do
        if type(it) == 'table' and it.en and it.enl then short[it.enl:lower()] = it.en end
    end
    local function piece(item)
        local p = opts.piece(item)
        if type(p) == 'string' and short[p:lower()] then return short[p:lower()] end
        if type(p) == 'table' and p.name and short[p.name:lower()] then p.name = short[p.name:lower()] end
        return p
    end
    local worn, cancelled = {}, false
    env.equip = function(...)
        for i = 1, select('#', ...) do
            local set = select(i, ...)
            if type(set) == 'table' then
                for k, v in pairs(set) do
                    local slot = type(k) == 'string' and SLOT_NAME[k:lower()]
                    if slot then worn[slot] = piece(v) end
                end
            end
        end
    end
    -- who cancelled: the first job frames of the stack (Mote's own frames left out)
    local cancelled_by
    env.cancel_spell = function()
        cancelled = true
        local frames = {}
        for line in debug.traceback('', 2):gmatch('[^\n]+') do
            local f = line:match('([%w_%-]+%.lua:%d+)')
            if f and not f:match('^probe%.lua') and #frames < 3 then frames[#frames + 1] = f end
        end
        cancelled_by = table.concat(frames, ' < ')
    end
    -- what the job says in the chat while cancelling (why it did) is kept with the result
    local said = {}
    local function say(color, text) said[#said + 1] = tostring(text == nil and color or text) end
    env.add_to_chat = say
    if env.windower then env.windower.add_to_chat = say end
    local defaults = {}
    for name, m in pairs(env.state or {}) do
        if type(m) == 'table' and rawget(m, '_track') then defaults[name] = m.current end
    end
    local function set_modes(modes)
        for name, value in pairs(defaults) do pcall(function() env.state[name]:set(value) end) end
        for name, value in pairs(modes or {}) do
            local m = env.state and env.state[name]
            if m then pcall(function() m:set(value) end) end
        end
    end

    local out = {}
    for _, sc in ipairs(Probe.expand(spec, res)) do
        local r = {}
        out[sc.label] = r
        set_modes(sc.modes)
        -- a mode the job does not have, or a value it does not take, is noted: that scenario
        -- then plays the default
        for name, value in pairs(sc.modes or {}) do
            local m = env.state and env.state[name]
            local now = m and m.current
            if tostring(now) ~= tostring(value) then
                r.mode_missing = (r.mode_missing and r.mode_missing .. ', ' or '') .. name .. '=' .. tostring(value)
            end
        end
        env.player.status = sc.status or 'Idle'
        -- a pet out (luopan, jug pet, automaton, wyvern): GearSwap's pet table and the game's mob
        local ffxi = env.windower and env.windower.ffxi
        if sc.pet then
            env.pet = {isvalid = true, name = sc.pet, status = 'Idle', hpp = 100, tp = 0, id = 77, index = 77, distance = 2}
        else
            env.pet = {isvalid = false}
        end
        if ffxi and not Probe._mob_wrapped then
            local orig = ffxi.get_mob_by_target
            ffxi.get_mob_by_target = function(t)
                if t == 'pet' then
                    return env.pet.isvalid and {id = 77, index = 77, name = env.pet.name, hpp = 100, status = 0,
                        x = 0, y = 0, z = 0, distance = 4, model_size = 1} or nil
                end
                return orig and orig(t)
            end
            Probe._mob_wrapped = true
        end
        -- a weaponskill at 3000 TP: allowed, and no TP Bonus piece is wanted on either side
        -- MP for a scenario that asks (sc.mp), else full
        local mp = sc.mp or 1500
        env.player.mp, env.player.mpp = mp, math.floor(mp * 100 / 1500)
        if type(env.player.vitals) == 'table' then env.player.vitals.mp, env.player.vitals.mpp = mp, env.player.mpp end
        local tp = sc.action and sc.action.kind == 'ws' and 3000 or 0
        env.player.tp = tp
        if type(env.player.vitals) == 'table' then env.player.vitals.tp = tp end
        -- the world: a zone (a city for the town sets), day and weather
        local saved_world = copy(env.world)
        env.world.weather_id = env.world.weather_id or 0
        for k, v in pairs(sc.world or {}) do env.world[k] = v end
        -- the weather's id, which Mote reads for its intensity (res/weather.lua)
        if sc.world and sc.world.weather then
            for id, w in pairs(res.weather or {}) do
                if type(w) == 'table' and w.en == sc.world.weather then env.world.weather_id = id end
            end
        end
        if sc.world and sc.world.area then
            env.world.zone = sc.world.area
            local zid
            for id, z in pairs(res.zones or {}) do if type(z) == 'table' and z.en == sc.world.area then zid = id end end
            Probe.zone_id = zid
        else
            Probe.zone_id = nil
        end
        if ffxi and not Probe._info_wrapped then
            local orig = ffxi.get_info
            ffxi.get_info = function()
                local i = orig and orig() or {}
                if Probe.zone_id then i.zone = Probe.zone_id end
                return i
            end
            Probe._info_wrapped = true
        end
        -- buffs up: GearSwap's buffactive (either case) and Mote's buff_change, as when they landed
        for _, b in ipairs(sc.buffs or {}) do
            env.buffactive[b], env.buffactive[b:lower()] = 1, 1
            if env.buff_change then pcall(env.buff_change, b, true, {}) end
        end
        worn, cancelled, said = {}, false, {}
        local ok, err = pcall(function()
            if not sc.action then
                env.handle_equipping_gear(env.player.status)
                r.pre = copy(worn)
                return
            end
            local spell = action_table(res, sc.action.kind, sc.action.name, env.S, env.player.name)
            if not spell then r.error = 'unknown action ' .. sc.action.name return end
            env.precast(spell)
            r.pre = copy(worn)
            if cancelled then r.cancelled = 'precast' return end
            env.midcast(spell)
            r.mid = copy(worn)
            if cancelled then r.cancelled = 'midcast' end
        end)
        if not ok then r.error = tostring(err) end
        if r.cancelled then
            r.said = (#said > 0 and said[#said]:gsub('[\128-\255]', ''):gsub('%c', '') .. ' - ' or '') .. (cancelled_by or '')
        end
        -- the action ends as in game, so what it held (a weapon for Dispelga...) is let go before the next one
        if sc.action and env.aftercast then
            local spell = action_table(res, sc.action.kind, sc.action.name, env.S, env.player.name)
            if spell then pcall(env.aftercast, spell) end
        end
        -- the buffs wear off and the world is put back for the next scenario
        for _, b in ipairs(sc.buffs or {}) do
            env.buffactive[b], env.buffactive[b:lower()] = nil, nil
            if env.buff_change then pcall(env.buff_change, b, false, {}) end
        end
        for k in pairs(env.world) do env.world[k] = nil end
        for k, v in pairs(saved_world) do env.world[k] = v end
    end
    return out
end

return Probe
