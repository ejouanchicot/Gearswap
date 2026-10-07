---============================================================================
--- Set Catalog - the set names a job's code reads, for the Atelier's "+ Set"
---============================================================================
--- The Atelier page offers to create only the sets the code will wear. Which
--- names those are is written next to the code that reads them:
---   shared/utils/atelier/set_catalog_common.lua   what every job reads
---                                                  (Mote-Include, the shared systems)
---   shared/jobs/<job>/set_catalog.lua              what that job's own code adds
--- Each entry of those files:
---   { 'midcast.Enfeebling Magic.{type:Enfeebling Magic}.{EnfeebleMode}',
---     when  = 'Worn while casting ...',        -- one line, shown in the page
---     base  = 'midcast.Enfeebling Magic',      -- the set worn in its place today
---     needs = {'state:EnfeebleMode'} }         -- optional, all must hold
--- A path is the keys under `sets`, separated by dots. A part in braces is
--- filled from the character's data at export (SetCatalog.collect), one entry
--- per value:
---   {StateName}        the values of that Mote state (a capital first letter); {StateName~Normal|X}
---                      the same without those values
---   {a|b|c}            these words
---   {ja}               the job abilities (type JobAbility) of the main job and the subjob
---   {ability}          the other abilities (Waltz, Step, CorsairRoll...); {ability.type} its type
---   {abilitytype}      those types
---   {ws}               the weaponskills of the job (the export's ws_skill); {ws.skill} its combat skill
---   {spell}            the spells main job and subjob can cast; {spell:Skill} those of one skill.
---                      {spell.base} the name without its tier (MidcastManager P1), {spell.skill}
---   {spellbase}        the tier-less names shared by two or more spells (Cure, Protect...);
---                      {spellbase.skill}, {spellbase.type}; {spellbase:Skill} those of one skill
---   {spellplain}       the spells with no other tier (Sneak, Flash...); {spellplain:Skill}, {spellplain.skill}
---   {spellmap}         Mote's spell maps of those spells (Cure, BarElement, Utsusemi...); {spellmap:Skill},
---                      {spellmap.skill}
---   {spelltype}        their types (WhiteMagic, BlackMagic, BardSong, Ninjutsu...)
---   {wsskill}          the combat skills of the job's weaponskills (opts.ws_skill: Sword, Great Axe...)
---   {skill}            the magic skills of those spells
---   {type:Parent}      the spell families of a set (shared/utils/atelier/atelier_families.lua)
---   {set:Prefix}       every set that exists under Prefix (several keys: engaged.PDT, engaged.Naegling.DT)
--- A part may hold text around its braces: {MainWeapon}AFM3 gives NaeglingAFM3 (one value, one key).
--- `base` takes the same parts (and `{spell.base}`...; a state its path does not name: its current
--- value): it may list several paths, the first that exists is the base. `needs`:
---   state:Name   the state exists       main:WAR|PLD   main job     sub:NIN|DNC   subjob
---   dw           the job can dual wield now (shared/utils/equipment/weapon_resolver.lua)
---   absent:path  no set at that path (a part in braces filled like the path)
---   spells       the job casts spells (main or sub)   spell:Name   it casts that spell
---   skill:Name   it casts a spell of that skill
---   value:State=A|B   the state has one of those values (a mode a player may not have)
---   not:name:A|B the value bound to that part (or name.attr) holds none of those words
--- A job's file can also list `skip = {'<common path>', ...}`: common entries its code never reads.
---
--- @file    shared/utils/atelier/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

local SetCatalog = {}

-- The most entries one line of a catalog may give (a combination of long lists)
local MAX_PER_LINE = 600

---============================================================================
--- THE CHARACTER'S LISTS
---============================================================================

local function res_of()
    local gs = rawget(_G, 'gearswap')
    return rawget(_G, 'res') or (gs and gs.res)
end

local function sorted_keys(t)
    local out = {}
    for k in pairs(t) do out[#out + 1] = k end
    table.sort(out)
    return out
end

-- A job's id in the game's job list
local function job_id(res, code)
    if not (res and res.jobs and code) then return nil end
    for id, j in pairs(res.jobs) do
        if type(j) == 'table' and j.ens == code then return id end
    end
    return nil
end

--- The name without its tier, as MidcastManager P1 cuts it ("Cure III" -> "Cure").
--- @param name string
--- @return string
function SetCatalog.base_name(name)
    return (name:gsub('%s+[IVX]+$', ''))
end

-- Mote's spell map of a spell (Mote-Include get_spell_map: the job's own, else Mote-Mappings' classes.SpellMaps),
-- or nil outside GearSwap
local function spell_map(spell)
    local get_map = rawget(_G, 'get_spell_map')
    if type(get_map) == 'function' then
        local ok, map = pcall(get_map, spell)
        if ok and type(map) == 'string' then return map end
    end
    local maps = rawget(_G, 'spell_maps')
    return type(maps) == 'table' and type(maps[spell.english]) == 'string' and maps[spell.english] or nil
end

-- The spells main job and subjob can cast: {name = {skill = ..., base = ...}}. Main job: its
-- job point spells too (level above 99); subjob: up to its level.
local function spells(res, main, sub, sub_level)
    local out = {}
    if not (res and res.spells and res.skills) then return out end
    local mid, sid = job_id(res, main), job_id(res, sub)
    -- in game, the spells learned only (an empty answer: not read, every spell the jobs can have)
    local w = rawget(_G, 'windower')
    local ok, known = pcall(function() return w.ffxi.get_spells() end)
    if not (ok and type(known) == 'table' and next(known)) then known = nil end
    for id, s in pairs(res.spells) do
        local lv = type(s) == 'table' and type(s.levels) == 'table' and s.levels
        if lv and s.en and s.type ~= 'Trust' and (not known or known[s.id or id]) and ((mid and lv[mid]) or (sid and lv[sid] and lv[sid] <= (sub_level or 49))) then
            local sk = res.skills[s.skill]
            if sk and sk.en then
                out[s.en] = {skill = sk.en, base = SetCatalog.base_name(s.en), type = s.type,
                    map = spell_map({english = s.en, name = s.en, skill = sk.en, type = s.type, id = s.id or id})}
            end
        end
    end
    return out
end

-- The ability files of a job (shared/data/job_abilities/<job>/<job>_<part>.lua): the main job reads them
-- all, the subjob those ending in "subjob". A job without one of them just has no such file.
local ABILITY_FILES = {'subjob', 'mainjob', 'sp', 'pet_commands', 'pet_commands_mainjob', 'pet_commands_subjob',
    'rolls_mainjob', 'rolls_subjob', 'waltzes_mainjob', 'waltzes_subjob', 'steps_mainjob', 'steps_subjob',
    'sambas_mainjob', 'sambas_subjob', 'jigs_mainjob', 'jigs_subjob', 'flourishes1_subjob', 'flourishes2_mainjob',
    'flourishes2_subjob', 'flourishes3_mainjob', 'black_grimoire_mainjob', 'black_grimoire_subjob',
    'white_grimoire_mainjob', 'white_grimoire_subjob'}

-- The job abilities of the main job (all its modules) and of the subjob (its subjob modules),
-- with their type from the game's list when it can be read
local function abilities(res, main, sub)
    local names = {}
    local function add_module(path)
        local ok, mod = pcall(require, path)
        if ok and type(mod) == 'table' and type(mod.abilities) == 'table' then
            for name in pairs(mod.abilities) do names[name] = true end
        end
    end
    if main then
        local j = main:lower()
        for _, part in ipairs(ABILITY_FILES) do add_module('shared/data/job_abilities/' .. j .. '/' .. j .. '_' .. part) end
    end
    if sub and sub ~= 'NONE' then
        local j = sub:lower()
        for _, part in ipairs(ABILITY_FILES) do
            if part:match('subjob$') then add_module('shared/data/job_abilities/' .. j .. '/' .. j .. '_' .. part) end
        end
    end
    local types = {}
    if res and res.job_abilities then
        for _, a in pairs(res.job_abilities) do
            if type(a) == 'table' and a.en and names[a.en] and a.type then types[a.en] = a.type end
        end
    end
    local out = {}
    for name in pairs(names) do out[name] = types[name] or 'JobAbility' end
    return out
end

-- The state values: {StateName = {'Normal', 'Acc'}}, and the current one of each
local function state_values()
    local out, current = {}, {}
    for name, mode in pairs(rawget(_G, 'state') or {}) do
        local track = type(mode) == 'table' and rawget(mode, '_track')
        if track and track._class == 'mode' and track._type ~= 'string' then
            local values = {}
            if track._type == 'boolean' then values = {'On', 'Off'}
            else for i = 1, track._count do values[#values + 1] = tostring(rawget(mode, i)) end end
            out[name] = values
            current[name] = tostring(mode.current)
        end
    end
    return out, current
end

---============================================================================
--- SETS IN MEMORY
---============================================================================

-- The table at a list of keys under `sets`, or nil
local function node(keys)
    local t = rawget(_G, 'sets')
    for _, k in ipairs(keys) do
        if type(t) ~= 'table' then return nil end
        t = rawget(t, k)
    end
    return type(t) == 'table' and t or nil
end

--- A set path as the export writes it (atelier_export.lua child_path): sets.precast.JA.Berserk,
--- sets.midcast["Enfeebling Magic"].
--- @param keys table
--- @return string
function SetCatalog.path_of(keys)
    local p = 'sets'
    for _, k in ipairs(keys) do
        if type(k) == 'string' and k:match('^[%a_][%w_]*$') then p = p .. '.' .. k
        else p = p .. '["' .. tostring(k):gsub('"', '\\"') .. '"]' end
    end
    return p
end

-- Every set under a list of keys, as key lists relative to it (the prefix's own table not
-- included; the gear slots are no sets)
local SLOTS = {main = 1, sub = 1, range = 1, ranged = 1, ammo = 1, head = 1, neck = 1, ear1 = 1, ear2 = 1,
    left_ear = 1, right_ear = 1, lear = 1, rear = 1, body = 1, hands = 1, ring1 = 1, ring2 = 1, left_ring = 1,
    right_ring = 1, lring = 1, rring = 1, back = 1, waist = 1, legs = 1, feet = 1}
local function sets_under(keys)
    local out, seen = {}, {}
    local function walk(t, rel, depth)
        if depth > 6 or seen[t] then return end
        seen[t] = true
        for k, v in pairs(t) do
            if type(v) == 'table' and not (type(k) == 'string' and SLOTS[k:lower()]) then
                local r = {}
                for i, x in ipairs(rel) do r[i] = x end
                r[#r + 1] = k
                out[#out + 1] = r
                walk(v, r, depth + 1)
            end
        end
    end
    local root = node(keys)
    if root then walk(root, {}, 0) end
    return out
end

---============================================================================
--- FILLING THE PARTS IN BRACES
---============================================================================

local function in_list(value, list)
    for w in list:gmatch('[^|]+') do if w == value then return true end end
    return false
end

-- A path pattern cut into its parts: 'midcast.{spell:Enfeebling Magic}.x' -> {'midcast', '{spell:...}', 'x'}
local function split(pattern)
    local parts, cur, depth = {}, '', 0
    for i = 1, #pattern do
        local c = pattern:sub(i, i)
        if c == '{' then depth = depth + 1 elseif c == '}' then depth = depth - 1 end
        if c == '.' and depth == 0 then parts[#parts + 1] = cur cur = ''
        else cur = cur .. c end
    end
    parts[#parts + 1] = cur
    return parts
end

-- The values of one part in braces: a list of {keys = {...}, attrs = {...}}, nil for an unknown part
local function values_of(token, ctx)
    local name, arg = token:match('^([^:]+):(.+)$')
    name = name or token
    local out = {}
    local function one(v, attrs) out[#out + 1] = {keys = {v}, attrs = attrs or {}} end
    if token:find('|', 1, true) and not token:find('~', 1, true) then
        for w in token:gmatch('[^|]+') do one(w) end
    elseif name == 'ja' or name == 'ability' then
        for _, n in ipairs(sorted_keys(ctx.abilities)) do
            local t = ctx.abilities[n]
            if (name == 'ja') == (t == 'JobAbility') then one(n, {type = t}) end
        end
    elseif name == 'abilitytype' then
        local types = {}
        for _, t in pairs(ctx.abilities) do if t ~= 'JobAbility' then types[t] = true end end
        for _, t in ipairs(sorted_keys(types)) do one(t) end
    elseif name == 'ws' then
        for _, n in ipairs(ctx.ws) do one(n, {skill = ctx.ws_skill and ctx.ws_skill[n] or nil}) end
    elseif name == 'spell' then
        for _, n in ipairs(sorted_keys(ctx.spells)) do
            local s = ctx.spells[n]
            if not arg or s.skill == arg then one(n, {base = s.base, skill = s.skill}) end
        end
    elseif name == 'spellbase' then
        local count, skill, stype = {}, {}, {}
        for n, s in pairs(ctx.spells) do
            if s.base ~= n then count[s.base] = (count[s.base] or 0) + 1 skill[s.base] = s.skill stype[s.base] = s.type end
        end
        for _, b in ipairs(sorted_keys(count)) do
            if count[b] + (ctx.spells[b] and 1 or 0) >= 2 and (not arg or skill[b] == arg) then one(b, {skill = skill[b], type = stype[b]}) end
        end
    elseif name == 'spellplain' then
        -- the spells with no tier and no other tier of them: their name is their tier-less name
        local tiered = {}
        for n, s in pairs(ctx.spells) do if s.base ~= n then tiered[s.base] = true end end
        for _, n in ipairs(sorted_keys(ctx.spells)) do
            local s = ctx.spells[n]
            if s.base == n and not tiered[n] and (not arg or s.skill == arg) then one(n, {skill = s.skill, type = s.type}) end
        end
    elseif name == 'spellmap' or name == 'spelltype' then
        -- Mote's map names (Cure, BarElement, Utsusemi...) / the spells' types (WhiteMagic, BlackMagic...)
        local field, seen = name == 'spellmap' and 'map' or 'type', {}
        for _, n in ipairs(sorted_keys(ctx.spells)) do
            local sp = ctx.spells[n]
            local v = sp[field]
            if v and not seen[v] and (not arg or sp.skill == arg) then seen[v] = true one(v, {skill = sp.skill}) end
        end
        table.sort(out, function(a, b) return a.keys[1] < b.keys[1] end)
    elseif name == 'wsskill' then
        -- the combat skills of the job's weaponskills (Sword, Great Axe...): Mote's fallback under sets.precast.WS
        local seen = {}
        for _, sk in pairs(ctx.ws_skill or {}) do if type(sk) == 'string' then seen[sk] = true end end
        for _, sk in ipairs(sorted_keys(seen)) do one(sk) end
    elseif name == 'skill' then
        local skills = {}
        for _, s in pairs(ctx.spells) do skills[s.skill] = true end
        for _, s in ipairs(sorted_keys(skills)) do one(s) end
    elseif name == 'type' then
        for _, f in ipairs(sorted_keys((ctx.families or {})[arg] or {})) do one(f) end
    elseif name == 'set' then
        local prefix = split(arg)
        -- a support tier version is never the base of another one
        for _, rel in ipairs(sets_under(prefix)) do
            local tier = false
            for _, k in ipairs(rel) do if k == 'Group' or k == 'Solo' or k == 'Trust' then tier = true end end
            if not tier then out[#out + 1] = {keys = rel, attrs = {}} end
        end
        table.sort(out, function(a, b) return table.concat(a.keys, '.') < table.concat(b.keys, '.') end)
    elseif name:match('^%u') and not arg then
        -- {CastingMode~Normal}: the state's values but these
        local state_name, but = name:match('^([%w_]+)~(.+)$')
        local vals = ctx.states[state_name or name]
        if not vals then return nil end
        for _, v in ipairs(vals) do
            if not (but and in_list(v, but)) then one(v) end
        end
    else
        return nil
    end
    return out
end

-- The part's name the other parts and `base` refer to it by ({spell:Enfeebling Magic} -> spell)
local function bind_name(token)
    return token:match('^([^:|~]+)') or token
end

-- A part with text around its braces ({MainWeapon}AFM3): the value bound, as one key, put in the text;
-- nil when it is not bound or names several keys
local function glued(part, bound)
    local ok = true
    local key = part:gsub('{([^}]+)}', function(token)
        local nm, attr = token:match('^([%w_]+)%.([%w_]+)$')
        local b = bound[nm or bind_name(token)]
        local v = b and (nm and b.attrs[attr] or (not nm and #b.keys == 1 and b.keys[1]))
        if v == nil or v == false then ok = false return '' end
        return tostring(v)
    end)
    return ok and key or nil
end

-- Fill a pattern with the values bound so far: a list of keys, or nil when a part names a value not bound
-- (current: the states' current values, for a base naming a state its path does not)
local function fill(pattern, bound, current)
    local keys = {}
    for _, part in ipairs(split(pattern)) do
        local token = part:match('^{([^}]+)}$')
        if not token and part:find('{', 1, true) then
            local key = glued(part, bound)
            if not key then return nil end
            keys[#keys + 1] = key
        elseif token then
            local nm, attr = token:match('^([%w_]+)%.([%w_]+)$')
            if nm then
                local b = bound[nm]
                local v = b and b.attrs[attr]
                if v == nil then return nil end
                keys[#keys + 1] = v
            else
                local b = bound[bind_name(token)]
                -- a state the path does not name (in a base): its current value
                local cur = not b and current and current[token]
                if not b and not cur then return nil end
                if cur then keys[#keys + 1] = cur
                else for _, k in ipairs(b.keys) do keys[#keys + 1] = k end end
            end
        else
            keys[#keys + 1] = part
        end
    end
    return keys
end

-- Every way to fill a pattern's parts: a list of {name = value} bindings
local function bindings(pattern, ctx)
    local tokens, named = {}, {}
    for _, part in ipairs(split(pattern)) do
        for token in part:gmatch('{([^}]+)}') do
            if not token:match('^[%w_]+%.[%w_]+$') and not named[token] then
                named[token] = true
                tokens[#tokens + 1] = token
            end
        end
    end
    local out = {{}}
    for _, token in ipairs(tokens) do
        local vals = values_of(token, ctx)
        if not vals then return {} end
        local nxt = {}
        for _, b in ipairs(out) do
            for _, v in ipairs(vals) do
                local c = {}
                for k, x in pairs(b) do c[k] = x end
                c[bind_name(token)] = v
                nxt[#nxt + 1] = c
                if #nxt >= MAX_PER_LINE then break end
            end
            if #nxt >= MAX_PER_LINE then break end
        end
        out = nxt
    end
    return out
end

---============================================================================
--- CONDITIONS
---============================================================================

local function can_dual_wield(ctx)
    local ok, WR = pcall(require, 'shared/utils/equipment/weapon_resolver')
    if ok and WR and WR.can_dual_wield then return WR.can_dual_wield() end
    return in_list(ctx.main or '', 'NIN|DNC|THF|BLU') or in_list(ctx.sub or '', 'NIN|DNC')
end

local function holds(need, ctx, bound)
    local kind, arg = need:match('^([%w_]+):?(.*)$')
    if kind == 'state' then return ctx.states[arg] ~= nil end
    if kind == 'main' then return in_list(ctx.main or '', arg) end
    if kind == 'sub' then return in_list(ctx.sub or 'NONE', arg) end
    if kind == 'dw' then return can_dual_wield(ctx) end
    if kind == 'spells' then return next(ctx.spells) ~= nil end
    if kind == 'spell' then return ctx.spells[arg] ~= nil end
    if kind == 'value' then
        -- value:HybridMode=SubtleBlow|Hoxne  the state has one of those values
        local st, vals = arg:match('^([%w_]+)=(.+)$')
        for _, v in ipairs(st and ctx.states[st] or {}) do if in_list(v, vals) then return true end end
        return false
    end
    if kind == 'not' then
        -- not:spellbase:Lullaby|Threnody  the value bound holds none of those words
        local nm, words = arg:match('^([%w_%.]+):(.+)$')
        local bn, attr = (nm or ''):match('^([%w_]+)%.([%w_]+)$')
        local b = bound[bn or nm or '']
        local v = b and (attr and tostring(b.attrs[attr] or '') or table.concat(b.keys, ' ')) or ''
        for w in (words or ''):gmatch('[^|]+') do if v:find(w, 1, true) then return false end end
        return true
    end
    if kind == 'skill' then
        for _, sp in pairs(ctx.spells) do if sp.skill == arg then return true end end
        return false
    end
    if kind == 'absent' then
        local keys = fill(arg, bound)
        return keys ~= nil and node(keys) == nil
    end
    return false
end

---============================================================================
--- COLLECT
---============================================================================

local function load_list(path)
    local ok, list = pcall(require, path)
    return ok and type(list) == 'table' and list or {}
end

-- One catalog line, filled: its entries added to `out` (a path met already keeps its first entry)
local function expand(line, ctx, from, out, seen)
    for _, b in ipairs(bindings(line[1], ctx)) do
        local ok = true
        for _, need in ipairs(line.needs or {}) do
            if not holds(need, ctx, b) then ok = false break end
        end
        local keys = ok and fill(line[1], b)
        if keys then
            local path = SetCatalog.path_of(keys)
            if not seen[path] then
                seen[path] = true
                local base
                local bases = type(line.base) == 'table' and line.base or {line.base}
                for _, bp in ipairs(bases) do
                    local bk = fill(bp, b, ctx.current)
                    if bk and node(bk) then base = SetCatalog.path_of(bk) break end
                end
                local parent = {}
                for i = 1, #keys - 1 do parent[i] = keys[i] end
                out[#out + 1] = {path = path, when = line.when, base = base, group = line[1], from = from,
                    exists = node(keys) ~= nil or nil, parent = (#parent == 0 or node(parent) ~= nil) or nil}
            end
        end
    end
end

--- The sets the job's code reads, filled with the character's data: a list of
--- {path, when, base, group, from = 'job'|'common', exists, parent}. `exists`: the set is
--- there already; `parent`: the table it goes in exists (it can be written with no other set).
--- @param job string Main job (WAR)
--- @param opts table|nil {sub, sub_level, ws = {names}, ws_skill = {name = combat skill}, families = AtelierFamilies.collect()}
--- @return table
function SetCatalog.collect(job, opts)
    opts = opts or {}
    if not job then return {} end
    local res = res_of()
    local sub = opts.sub or (player and player.sub_job)
    local ctx = {
        main = job, sub = sub,
        states = nil,
        spells = spells(res, job, sub, opts.sub_level or (player and player.sub_job_level)),
        abilities = abilities(res, job, sub),
        ws = opts.ws or {}, ws_skill = opts.ws_skill,
        families = opts.families,
    }
    ctx.states, ctx.current = state_values()
    local job_list = load_list('shared/jobs/' .. job:lower() .. '/set_catalog')
    local skip = {}
    for _, p in ipairs(job_list.skip or {}) do skip[p] = true end
    local out, seen = {}, {}
    -- the job's own lines first: a path both name keeps the job's words
    for _, line in ipairs(job_list) do expand(line, ctx, 'job', out, seen) end
    for _, line in ipairs(load_list('shared/utils/atelier/set_catalog_common')) do
        if not skip[line[1]] then expand(line, ctx, 'common', out, seen) end
    end
    return out
end

--- Whether a path is one the catalog offers (set_push.lua creates only those): the entry, or nil.
--- @param job string
--- @param path string As the export writes it
--- @param opts table|nil As collect
--- @return table|nil
function SetCatalog.find(job, path, opts)
    for _, e in ipairs(SetCatalog.collect(job, opts)) do
        if e.path == path then return e end
    end
    return nil
end

return SetCatalog
