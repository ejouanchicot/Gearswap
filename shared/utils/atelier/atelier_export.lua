---============================================================================
--- Atelier Export - what the Atelier page shows, written by the game itself
---============================================================================
--- data/atelier.html (open it in a browser) shows every exported job of every
--- character: sets, keys and where each comes from, modes, macro book,
--- lockstyle. This module writes that data, as the game loaded it:
---
---   //gs c atelier        export the current job now
---   //gs c atelier on     also export after every job load (per character)
---   //gs c atelier off    stop exporting on load
---
--- Files: data/<Character>/atelier/exports/<JOB>_<SUB>.js (one per job and
--- subjob; <JOB>.js before 2026-10-01, atelier/ before 2026-09-30),
--- data/atelier/index.js (the list the page reads) and data/atelier/icons/<id>.bmp
--- (item icons from the game files, shared/utils/atelier/item_icons.lua). They are JavaScript, not
--- JSON, because a page opened from the disk may load scripts but not read
--- files.
---
--- While the switch is on, set_combine is wrapped from the first line of each
--- load (install, called by config_loader) to note which set every set was
--- built from; the page greys what a set only inherits. Off, nothing is
--- wrapped and a command export shows every piece as the set's own.
---
--- @file    shared/utils/atelier/atelier_export.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-30
---============================================================================

local AtelierExport = {}

-- What the export holds, raised when it gains something the page relies on: the page warns about
-- an export written by an older exporter (2: key conditions, empty sets; 3: macro fallback, bag,
-- priority, temp keys; 2026-10-02; 4: the set catalog, 2026-10-06)
local EXPORT_VERSION = 4

---============================================================================
--- SWITCH AND PATHS
---============================================================================

local function data_path(rel)
    return windower.addon_path .. 'data/' .. rel
end

-- the switch's marker where it is (atelier/export.on, or saved/atelier.on before 2026-10-05), or where it goes
local function marker(to_write)
    if not (player and player.name) then return nil end
    local CharPaths = require('shared/utils/core/char_paths')
    return to_write and CharPaths.writable('atelier', 'atelier.on') or CharPaths.file('atelier', 'atelier.on')
end

--- On/off per character: a marker file, read once per addon load.
--- @return boolean
function AtelierExport.enabled()
    if windower._atelier_on == nil then
        local path = marker()
        local f = path and io.open(path, 'r')
        windower._atelier_on = f ~= nil
        if f then f:close() end
    end
    return windower._atelier_on == true
end

--- Wrap set_combine for this load when the switch is on (config_loader,
--- before the set file runs).
function AtelierExport.install()
    if not AtelierExport.enabled() or rawget(_G, '__atelier_prov') then return end
    local original = rawget(_G, 'set_combine')
    if type(original) ~= 'function' then return end
    local prov = setmetatable({}, {__mode = 'k'})
    _G.__atelier_prov = prov
    _G.set_combine = function(...)
        local result = original(...)
        prov[result] = {n = select('#', ...), ...}
        return result
    end
end

---============================================================================
--- COLLECT
---============================================================================

-- the walk of the sets and what the game knows of the character live in files of their own
local ExportSets = require('shared/utils/atelier/atelier_export_sets')
local ExportChar = require('shared/utils/atelier/atelier_export_char')
local collect_sets = ExportSets.collect
local collect_items, porter_list, collect_descs = ExportChar.items, ExportChar.porter_list, ExportChar.descs
local listen_stats, collect_char = ExportChar.listen_stats, ExportChar.char
local collect_ws_by_weapon, collect_weapon_skills = ExportChar.ws_by_weapon, ExportChar.weapon_skills
local collect_scan, collect_icons = ExportChar.scan, ExportChar.icons

local function source_of(bind)
    if bind._common then return 'common' end
    if bind.custom then return 'custom' end
    if bind.state == 'CombatMode' then return 'combat' end
    if bind.state == 'TreasureMode' then return 'treasure' end
    return 'job'
end

--- The keys of the job, as bound now. `id` names a key in the overrides file the
--- page writes (shared/utils/keybinds/key_overrides.lua); `file_key` is the key
--- of the key file when an override changed it.
local function collect_keys()
    local module = rawget(_G, '_keybind_active')
    local ok, KeyOverrides = pcall(require, 'shared/utils/keybinds/key_overrides')
    local keys = {}
    for _, bind in ipairs(module and module.binds or {}) do
        -- visible: a function (optional_state.lua, PLD MainWeapon under the Tanking stance),
        -- read now; false means the game leaves the key unbound at the time of the export
        local shown = nil
        if type(bind.visible) == 'function' then
            local ok_v, v = pcall(bind.visible)
            shown = ok_v and v ~= false and v ~= nil
        end
        keys[#keys + 1] = {key = bind.key or '', desc = bind.desc or bind.command or '', state = bind.state,
            src = source_of(bind), subjob = type(bind.subjob) == 'string' and bind.subjob or nil,
            id = ok and KeyOverrides.id_of(bind) or nil, file_key = bind.file_key,
            subjobs = type(bind.subjob) == 'table' and bind.subjob or nil,
            exclude = type(bind.exclude_subjob) == 'string' and {bind.exclude_subjob} or bind.exclude_subjob,
            visible_now = shown, override = bind.override == true or nil,
            alt = type(bind.alt) == 'table' and bind.alt or nil,
            weapon = (type(bind.weapon) == 'string' or type(bind.weapon) == 'table') and bind.weapon or nil}
    end
    return keys
end

local function collect_modes()
    local modes = {}
    for name, mode in pairs(state or {}) do
        local track = type(mode) == 'table' and rawget(mode, '_track')
        if track and track._class == 'mode' and track._type ~= 'string' then
            local values = {}
            if track._type == 'boolean' then values = {'off', 'on'}
            else for i = 1, track._count do values[#values + 1] = tostring(rawget(mode, i)) end end
            modes[#modes + 1] = {name = name, desc = track._description, values = values, current = tostring(mode.current)}
        end
    end
    table.sort(modes, function(a, b) return a.name < b.name end)
    return modes
end

--- The book / lockstyle a job falls back to with no config file: the numbers its factory call
--- passes (shared/jobs/<job>/functions/<JOB>_MACROBOOK.lua: create(job, path, sub, book, page);
--- <JOB>_LOCKSTYLE.lua: create(job, path, style, sub)).
--- @return table|nil {book, page}, number|nil style
local function factory_defaults()
    local job = player.main_job
    local function args(kind)
        local path = windower.addon_path .. 'data/shared/jobs/' .. job:lower() .. '/functions/' .. job .. '_' .. kind .. '.lua'
        local f = io.open(path, 'r')
        if not f then return {} end
        local text = f:read('*a')
        f:close()
        local call = text:match(kind == 'MACROBOOK' and 'MacrobookManager%.create%((.-)%)' or 'LockstyleManager%.create%((.-)%)') or ''
        call = call:gsub('%-%-[^\n]*', '')
        local nums = {}
        for n in call:gmatch('%f[%w](%d+)%f[%W]') do nums[#nums + 1] = tonumber(n) end
        return nums
    end
    local ok_m, m = pcall(args, 'MACROBOOK')
    local ok_l, l = pcall(args, 'LOCKSTYLE')
    local book = ok_m and #m >= 2 and {book = m[#m - 1], page = m[#m]} or nil
    return book, ok_l and l[1] or nil
end

--- A job config table (MACROBOOK / LOCKSTYLE), from the character's folder.
local function job_config(kind)
    local job = player.main_job
    local ok, cfg = require('shared/utils/core/char_paths').load('job', job .. '_' .. kind, job)
    return (ok and type(cfg) == 'table') and cfg or nil
end


---============================================================================
--- WRITE
---============================================================================

--- A table's keys in the order json() writes them.
local function sorted_keys(value)
    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    return keys
end

local function json(value)
    local kind = type(value)
    if kind == 'nil' or kind == 'function' then return 'null' end
    if kind == 'boolean' or kind == 'number' then return tostring(value) end
    if kind == 'string' then
        return '"' .. value:gsub('[%c"\\]', function(c)
            return ({['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n'})[c] or string.format('\\u%04x', c:byte())
        end) .. '"'
    end
    if #value > 0 or next(value) == nil then
        local parts = {}
        for i = 1, #value do parts[i] = json(value[i]) end
        return '[' .. table.concat(parts, ',') .. ']'
    end
    local parts = {}
    for _, key in ipairs(sorted_keys(value)) do
        local text = json(value[key])
        if text ~= 'null' then parts[#parts + 1] = json(tostring(key)) .. ':' .. text end
    end
    return '{' .. table.concat(parts, ',') .. '}'
end

local function write(path, text)
    local file = io.open(path, 'w')
    if not file then return false end
    file:write(text)
    file:close()
    return true
end

--- data/atelier/index.js: every <Character>/atelier/exports/<JOB>_<SUB>.js on
--- the disk (saved/atelier/ before 2026-10-05, read when no newer copy), and the one-file-per-job
--- <JOB>.js written before 2026-10-01 (also in <Character>/atelier/, the folder before 2026-09-30).
local function write_index()
    windower.create_dir(data_path('atelier'))
    local entries, seen = {}, {}
    for _, name in ipairs(windower.get_dir(data_path('')) or {}) do
        for _, folder in ipairs({'/atelier/exports/', '/saved/atelier/', '/atelier/'}) do
            for _, file in ipairs(windower.get_dir(data_path(name .. folder)) or {}) do
                local job, sub = file:match('^(%u%u%u)_?(%u*)%.js$')
                local key = job and name .. job .. sub
                if key and not seen[key] then
                    seen[key] = true
                    -- relative to data/, where atelier.html is: Tetsouo/atelier/exports/WAR_SAM.js
                    entries[#entries + 1] = {char = name, job = job, sub = sub ~= '' and sub or nil, file = name .. folder .. file}
                end
            end
        end
    end
    table.sort(entries, function(a, b) return a.char .. a.job .. (a.sub or '') < b.char .. b.job .. (b.sub or '') end)
    -- the live link files that exist (live_<Char>.js, link_<Char>.js): the page loads only those
    local live = {}
    for _, file in ipairs(windower.get_dir(data_path('atelier')) or {}) do
        if file:match('^live_.+%.js$') or file:match('^link_.+%.js$') then live[#live + 1] = 'atelier/' .. file end
    end
    table.sort(live)
    -- each character's files the page wrote (its list of sets, its bags plan: <Char>/atelier/overrides/), those
    -- that exist: the page asks only for them (asking for a missing one leaves an error in its console)
    local page_files, chars = {}, {}
    for _, e in ipairs(entries) do
        if not chars[e.char] then
            chars[e.char] = true
            for _, file in ipairs({'list_layout.js', 'bag_plan.js'}) do
                local rel = e.char .. '/atelier/overrides/' .. file
                if windower.file_exists(data_path(rel)) then page_files[#page_files + 1] = rel end
            end
        end
    end
    table.sort(page_files)
    -- the spells behind each family set (shared/utils/atelier/atelier_families.lua)
    local ok_f, families = pcall(function() return require('shared/utils/atelier/atelier_families').collect() end)
    return write(data_path('atelier/index.js'), 'window.ATELIER_INDEX = ' .. json(entries) .. ';\nwindow.ATELIER_LIVE_FILES = '
        .. json(live) .. ';\nwindow.ATELIER_PAGE_FILES = ' .. json(page_files) .. ';\nwindow.ATELIER_FAMILIES = '
        .. json(ok_f and families or {}) .. ';\n')
end

--- The stages of a build, in order: each fills `data`. Kept apart so the export after a load runs them a few
--- a frame (export_spread) where build() runs them in one go.
--- @param data table The export being filled
--- @return table The stages, as functions
local function build_stages(data)
    local ids, slips = {}, nil
    return {
        function() data.sets = collect_sets() end,                                   -- 1
        function() data.keys = collect_keys() end,                                   -- 2
        function() data.modes = collect_modes() end,                                 -- 3
        function()                                                                   -- 4
            data.macro, data.lockstyle = job_config('MACROBOOK'), job_config('LOCKSTYLE')
            data.macro_fallback, data.lockstyle_fallback = factory_defaults()
            -- <job>/combat/<JOB>_WEAPONS.lua (PLD: shield per stance and weapon, stance weapon, grips):
            -- the page puts the weapons in the sets the way the job code does
            data.weapon_rules = job_config('WEAPONS')
        end,
        function()                                                                   -- 5
            -- a weapon state's value with no set equips that weapon only when the character turned it on
            -- (shared/utils/equipment/weapon_resolver.lua, _common/gear/WEAPON_CONFIG.lua)
            local okr, WeaponResolver = pcall(require, 'shared/utils/equipment/weapon_resolver')
            data.weapon_plain = okr and WeaponResolver.equips_without_set() or false
        end,
        function() data.items, data.owned, slips = collect_items() end,              -- 6
        function() data.porter = porter_list(slips) end,                             -- 7
        function()                                                                   -- 8
            -- PorterPacker's unpack list against the job's sets (shared/utils/atelier/porter_lists.lua): what to add, what to drop
            local okp, PorterLists = pcall(require, 'shared/utils/atelier/porter_lists')
            if okp then
                local okc, cmp = pcall(PorterLists.compare, player.main_job)
                if okc then data.porterpacker = cmp end
            end
        end,
        function() data.icons = collect_icons(data.sets, data.items) end,            -- 9
        function()                                                                   -- 10
            -- the pieces under the game's item name (shared/utils/atelier/atelier_names.lua)
            require('shared/utils/atelier/atelier_names').use_game_names(data.sets, data.icons)
        end,
        function()                                                                   -- 11
            for _, id in pairs(data.icons or {}) do ids[#ids + 1] = id end
            data.scan = collect_scan(data.icons)
        end,
        function() data.char = collect_char() end,                                   -- 12
        function()                                                                   -- 13
            -- the worn pieces need their description and icon too, even when no set names them
            for _, piece in pairs(data.char and data.char.worn or {}) do
                data.icons = data.icons or {}
                if not data.icons[piece.name] then
                    data.icons[piece.name] = piece.id
                    ids[#ids + 1] = piece.id
                end
                piece.id = nil
            end
            data.descs = collect_descs(ids)
        end,
        function()                                                                   -- 14
            -- every bag as the game holds it (shared/utils/atelier/atelier_export_bags.lua). The icons of what is not
            -- equipment are not written here (hundreds at once would stall the game): the page asks for the ones it
            -- shows and misses, a few at a time (atelier_live.lua)
            local ok_b, bags = pcall(require('shared/utils/atelier/atelier_export_bags').collect, ExportChar.augments)
            data.bags = ok_b and bags or nil
        end,
        function()                                                                   -- 15
            -- the pieces of each lockstyle set seen so far (shared/utils/lockstyle/lockstyle_pieces.lua)
            local ok_l, lock = pcall(function() return require('shared/utils/lockstyle/lockstyle_pieces').read() end)
            data.lock_pieces = (ok_l and type(lock) == 'table' and next(lock)) and lock or nil
        end,
        function() data.wskill = collect_weapon_skills(data.icons) end,              -- 16
        function() data.ws_by_weapon = collect_ws_by_weapon(player.main_job) end,    -- 17
        function()                                                                   -- 18
            -- each weaponskill's combat skill and what it uses (shared/utils/atelier/atelier_ws.lua)
            data.ws_skill, data.ws_info = require('shared/utils/atelier/atelier_ws').collect(data.sets, player.main_job, player.main_job_level, player.sub_job)
        end,
        function()                                                                   -- 19
            -- the set names the job's code reads, filled with this character's modes, spells, abilities and weaponskills:
            -- what the page's "+ Set" offers (shared/utils/atelier/set_catalog.lua)
            local ok_c, catalog = pcall(function()
                local ws = {}
                for name in pairs(data.ws_skill or {}) do ws[#ws + 1] = name end
                table.sort(ws)
                local ok_f, families = pcall(function() return require('shared/utils/atelier/atelier_families').collect() end)
                return require('shared/utils/atelier/set_catalog').collect(player.main_job,
                    {sub = player.sub_job, sub_level = player.sub_job_level, ws = ws, ws_skill = data.ws_skill, families = ok_f and families or nil})
            end)
            data.catalog = ok_c and catalog or nil
        end,
        function()                                                                   -- 20
            -- the job's TP rule (its TP pieces, each held weapon's TP Bonus): the page lays Moonshade from it when the game
            -- is on another job and cannot be asked (shared/utils/atelier/atelier_sim.lua tp_rule)
            local ok_r, tp_rule = pcall(function()
                local names = {}
                for _, slot in ipairs({'main', 'sub', 'range'}) do
                    for _, name in ipairs(type(data.items) == 'table' and data.items[slot] or {}) do names[#names + 1] = name end
                end
                return require('shared/utils/atelier/atelier_sim').tp_rule(names)
            end)
            data.tp_rule = ok_r and tp_rule or nil
        end,
        function()                                                                   -- 21
            data.export_version = EXPORT_VERSION
            -- the keys changed in the page and saved (<Char>/atelier/overrides/keybind_overrides.lua)
            local ok_o, KeyOverrides = pcall(require, 'shared/utils/keybinds/key_overrides')
            data.key_overrides = ok_o and KeyOverrides.read() or nil
            -- the keys //gs c tb bound for this game session (shared/utils/keybinds/temp_binds.lua)
            local ok_t, TempBinds = pcall(require, 'shared/utils/keybinds/temp_binds')
            data.temp_binds = ok_t and TempBinds.current and TempBinds.current() or nil
            local ok_s, SetOverrides = pcall(require, 'shared/utils/atelier/set_overrides')
            data.set_overrides = ok_s and SetOverrides.read() or nil
        end,
        function()                                                                   -- 22
            local ok_g, configs = pcall(function() return require('shared/utils/atelier/atelier_configs').collect(player.name, player.main_job) end)
            data.configs = ok_g and configs or nil   -- every settings file, as text
        end,
        function() pcall(require('shared/utils/atelier/item_icons').write_missing, ids, data_path('atelier/icons/')) end,                -- 23
        function() pcall(require('shared/utils/atelier/atelier_catalog').write_if_stale, data_path('atelier/catalog.js'), json) end,  -- 24
    }
end

--- A new, empty export for the loaded job. Nil outside a job.
local function new_data()
    if not (player and player.name and player.main_job) then return nil end
    return {player = player.name, job = player.main_job, sub = player.sub_job, at = os.date('%Y-%m-%d %H:%M')}
end

--- Run one stage; while //gs c trace is on, a stage that cost something is written (tag EXPORT).
local function run_stage(stages, stage)
    local started = os.clock()
    stages[stage]()
    local ms = (os.clock() - started) * 1000
    if ms >= 5 then
        pcall(function() require('shared/utils/debug/trace_log').log('EXPORT', 'stage %d: %d ms', stage, ms) end)
    end
end

--- The data of the loaded job, as the page reads it (the file of export(), the
--- answer of the live link: shared/utils/atelier/atelier_live.lua). Nil outside a job.
--- @param upto number|nil A diagnostic (//gs c jobtest ... parts): the build stops after that many of its
---   stages, to find by elimination which one keeps something. Nil: the whole build.
--- @return table|nil
function AtelierExport.build(upto)
    local data = new_data()
    if not data then return nil end
    local stages = build_stages(data)
    for stage = 1, #stages do
        run_stage(stages, stage)
        if upto ~= nil and stage >= upto then return data, stage end
    end
    return data
end

--- The character's measure alone (stats, the gear and buffs up when the game sent them): what the page's live link
--- fetches when a new measure came, far lighter than a whole export. Nil outside the game.
--- @return table|nil
function AtelierExport.measure()
    return collect_char()
end

--- Write a built export to its file (<Char>/atelier/exports/<JOB>_<SUB>.js) and refresh the index.
--- @param data table The export
--- @param body string json(data)
--- @return string|nil The file written, relative to data/
local function write_export(data, body, no_index)
    -- <Char>/atelier/exports/ (char_paths.lua), the old saved/atelier/ copy of the same file taken out after
    local dir, old = require('shared/utils/core/char_paths').atelier_dir('exports')
    if not dir then return nil end
    windower.create_dir(dir)
    local folder = dir:sub(#data_path('') + 1) .. '/'
    -- one file per subjob: the modes, weapons and WS a job offers can depend on it
    local sub = player.sub_job or 'NONE'
    local rel = folder .. player.main_job .. '_' .. sub .. '.js'
    local c, j, s = json(player.name), json(player.main_job), json(sub)
    local text = ('window.ATELIER_SUBS = window.ATELIER_SUBS || {};\nATELIER_SUBS[%s] = ATELIER_SUBS[%s] || {};\n'
        .. 'ATELIER_SUBS[%s][%s] = ATELIER_SUBS[%s][%s] || {};\nATELIER_SUBS[%s][%s][%s] = %s;\n')
        :format(c, c, c, j, c, j, c, j, s, body)
    if not write(data_path(rel), text) then return nil end
    os.remove(data_path(folder .. player.main_job .. '.js'))
    if old then os.remove(old .. '/' .. player.main_job .. '_' .. sub .. '.js'); os.remove(old .. '/' .. player.main_job .. '.js') end
    if not no_index then write_index() end
    return rel
end

--- Export the current job, in one go. Returns the file written, or nil.
--- @return string|nil
function AtelierExport.export()
    local data = AtelierExport.build()
    if not data then return nil end
    return write_export(data, json(data))
end

-- seconds of work the spread export does before it leaves the game a frame, and the wait before the next
local SPREAD_BUDGET, SPREAD_WAIT = 0.02, 0.02

-- Seconds the page's /export waits for the spread export of a load (its wait for the bags is 44 s at most)
local BUILD_WAIT = 60

--- How full each bag is, as the live link's ping says it (atelier_place.lua): an export built before the bags changed
--- is not theirs any more.
local function bag_signature()
    local ok, counts = pcall(function() return require('shared/utils/atelier/atelier_place').bag_counts() end)
    return ok and counts or nil
end

--- The export the spread export built for this load, for the page's live link (atelier_live.lua /export): the same
--- data built a second time in one go froze the game 0.8 s on each load the page saw (DNC, 2026-10-13).
---   'ready', json   built for this load, with the bags as they are now
---   'building'      on its way for this load: the page asks again at its next tick
---   nil             none (export off, a tour, the bags changed since, it failed, or BUILD_WAIT went by with
---                   nothing: the load let its export go, a subjob changed with no new load): the caller builds it
--- @return string|nil, string|nil
function AtelierExport.spread_result()
    local last = windower._atelier_spread
    if type(last) ~= 'table' or last.gen ~= windower._load_gen or last.failed then return nil end
    if not last.body then
        return os.time() - (last.at or 0) <= BUILD_WAIT and 'building' or nil
    end
    if last.bags ~= bag_signature() or last.tidy ~= windower._bags_changed then return nil end
    return 'ready', last.body
end

--- Export the current job a little a frame: the same stages, the same file as export(), without the freeze
--- of doing them in one go (0.8 s measured on DNC, 2026-10-13). For the export that follows every load, which
--- nobody waits for, and for the page's live link once the bags moved (atelier_live.lua /export). A newer load
--- ends it: that load exports for itself.
--- @param no_file boolean|nil true: the result for the page only, no export file written (the export switch is off)
function AtelierExport.export_spread(no_file)
    local data = new_data()
    if not data then windower._atelier_spread = nil return end
    local gen, stages = windower._load_gen, build_stages(data)
    local stage, keys, at, parts, body, written = 0, nil, 0, {}, nil, false
    -- the bags as the build starts: moved during it, the result is not given to the page (spread_result)
    local mark = {gen = gen, at = os.time(), bags = bag_signature(), tidy = windower._bags_changed}
    windower._atelier_spread = mark
    local function work()
        local started = os.clock()
        repeat
            if stage < #stages then
                stage = stage + 1
                run_stage(stages, stage)
            elseif not keys then
                keys = sorted_keys(data)
            elseif at < #keys then
                at = at + 1
                local text = json(data[keys[at]])
                if text ~= 'null' then parts[#parts + 1] = json(tostring(keys[at])) .. ':' .. text end
            -- the end on three frames: the text, the file, the index of the exports (one frame froze 0.1 to 0.4 s)
            elseif not body then
                body = '{' .. table.concat(parts, ',') .. '}'
                return true
            elseif not written then
                written = true
                if not no_file then write_export(data, body, true) end
                return true
            else
                if not no_file then write_index() end
                mark.body = body
                return false
            end
        until os.clock() - started >= SPREAD_BUDGET
        return true
    end
    local function step()
        -- a newer load, or a newer spread export of this one (the page's, //gs c bags go's): this one stops
        if gen ~= windower._load_gen or windower._atelier_spread ~= mark then return end
        local ok, more = pcall(work)
        if ok and more then return coroutine.schedule(step, SPREAD_WAIT) end
        if not ok then
            mark.failed = true
            pcall(function() require('shared/utils/debug/trace_log').log('EXPORT', 'failed: %s', tostring(more)) end)
        end
    end
    step()
end

--- After a load, when the switch is on (INIT_SYSTEMS): the job's modules and
--- keys are all in place a few seconds later.
function AtelierExport.after_load()
    listen_stats()
    -- the page's live link (shared/utils/atelier/atelier_live.lua): open at every load, for every
    -- character, unless //gs c atelier live off closed it for this one
    pcall(function()
        local Live = require('shared/utils/atelier/atelier_live')
        if Live.allowed() then Live.start() end
    end)
    -- every load (a push from the page reloads too): the pieces the sets use and PorterPacker's unpack list
    -- misses are added to it (porter_lists.lua sync; what it holds for nothing is left to the page's button)
    require('shared/utils/core/load_gate').defer(3, function()
        pcall(function() require('shared/utils/atelier/porter_lists').sync(player.main_job) end)
    end, 'porter sync')
    -- a job test (//gs c jobtest: shared/utils/debug/job_test.lua) counts and times this load; the load stays a normal one
    pcall(function() require('shared/utils/debug/job_test').on_load() end)
    -- a tour of the jobs (//gs c atelier tour: shared/utils/atelier/atelier_tour.lua) exports this load itself
    local ok_t, on_tour = pcall(function() return require('shared/utils/atelier/atelier_tour').on_load() end)
    if ok_t and on_tour then return end
    if not AtelierExport.enabled() then return end
    -- from now on the page's live link waits for this export rather than building it (spread_result)
    windower._atelier_spread = {gen = windower._load_gen, at = os.time()}
    -- waits for the level, the bags and the Porter Moogle's slips in them (unread just after a load or a zone);
    -- past the wait, the export goes with what there is (the slips' last list: shared/utils/atelier/slip_items.lua)
    local defer, try, Slips = require('shared/utils/core/load_gate').defer, nil, require('shared/utils/atelier/slip_items')
    try = function(left) local me = windower.ffxi.get_player()
        local ready = me and (me.main_job_level or 0) > 0 and Slips.bags_ready()
            and require('shared/utils/atelier/atelier_export_bags').read()
        if ready or left == 0 then return AtelierExport.export_spread() end
        defer(2, function() try(left - 1) end, 'atelier export') end
    defer(4, function() try(20) end, 'atelier export')
end

---============================================================================
--- COMMAND
---============================================================================

local function set_switch(on)
    windower._atelier_on = on
    local path = marker(on)
    if not path then return end
    if on then write(path, 'on') else os.remove(path) end
    require('shared/utils/core/char_paths').retire('atelier.on')
end

--- //gs c atelier [on|off]
--- @param args table Words after "atelier"
--- @return boolean handled
function AtelierExport.handle(args)
    local sub = args and args[1] and args[1]:lower() or ''
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    if sub == 'on' or sub == 'off' then
        set_switch(sub == 'on')
        MessageFormatter.show_info(('Atelier: export after each job load %s (reload the job for inherited pieces)')
            :format(sub == 'on' and 'ON' or 'OFF'))
        return true
    end
    if sub == 'tour' then
        require('shared/utils/atelier/atelier_tour').handle(args)
        return true
    end
    if sub == 'link' then
        local ok, err = AtelierExport.install_link()
        MessageFormatter.show_info(ok and 'Atelier: AtelierLink installed and loaded: the page can now load, unload and reload GearSwap'
            or ('Atelier: AtelierLink not installed (%s)'):format(tostring(err)))
        return true
    end
    if sub == 'icons' then
        -- every equipment icon of the game, for the pieces you do not hold (item_icons.lua)
        local said = {start = 'Atelier: %d equipment icons to write (of %d), in the background',
            progress = 'Atelier: icons %d / %d', done = 'Atelier: %d icons written, reload data/atelier.html'}
        require('shared/utils/atelier/item_icons').extract_all(data_path('atelier/icons/'), function(kind, a, b)
            MessageFormatter.show_info(said[kind]:format(a or 0, b or 0))
        end)
        return true
    end
    if sub == 'live' then
        local off = args[2] and args[2]:lower() == 'off'
        local ok, port, err = pcall(function() return require('shared/utils/atelier/atelier_live').set(not off) end)
        if off then
            MessageFormatter.show_info('Atelier: live link closed for this character (//gs c atelier live to open it again)')
        else
            MessageFormatter.show_info(ok and port and ('Atelier: live link open on 127.0.0.1:%d, reload data/atelier.html'):format(port)
                or ('Atelier: live link not opened (%s)'):format(tostring(ok and err or port)))
        end
        return true
    end
    local rel = AtelierExport.export()
    if sub == 'all' and rel then
        -- every other job is rebuilt by the page (its "Reread" button, pressed from here): the live link's /ping
        -- carries the request (atelier_live.lua), the page open in the browser sees it within seconds
        windower._atelier_rebuild = os.time()
        MessageFormatter.show_info(('Atelier: %s written; the page open in your browser now rebuilds every other job'):format(rel))
        return true
    end
    MessageFormatter.show_info(rel and ('Atelier: %s written, open data/atelier.html'):format(rel)
        or 'Atelier: export failed (could not write the file)')
    return true
end

_G.AtelierExport = AtelierExport

--- Copy the AtelierLink addon (data/scripts/atelier/AtelierLink/AtelierLink.lua) into
--- Windower's addons/AtelierLink/ and load it: an addon of its own, which keeps
--- answering the page while GearSwap is unloaded (load, unload, reload).
--- @return boolean ok, string|nil error
function AtelierExport.install_link()
    local src = io.open(data_path('scripts/atelier/AtelierLink/AtelierLink.lua'), 'rb')
    if not src then return false, 'data/scripts/atelier/AtelierLink/AtelierLink.lua missing' end
    local text = src:read('*a')
    src:close()
    local dir = windower.addon_path .. '../AtelierLink/'
    windower.create_dir(dir)
    if not write(dir .. 'AtelierLink.lua', text) then return false, 'cannot write ' .. dir end
    windower.send_command('lua reload atelierlink; lua load atelierlink')
    return true
end

--- Write data/atelier/index.js again (the live link, once its file is written).
AtelierExport.write_index = write_index

--- The page's JSON writer (the live link answers with it).
AtelierExport.json = json

return AtelierExport
