---============================================================================
--- Job Adder - a job added to a character from the templates (the Atelier's "Add a job")
---============================================================================
--- What clone_character.py does for one job, without a re-clone (which would put
--- every other job back to its template): asked by the page through the live link
--- (atelier_live.lua POST /addjob?job=WHM), for the character logged in.
---   <Char>/<Char>_<JOB>.lua           the one-line entry (_master/entry/Tetsouo_<JOB>.lua)
---   <Char>/<job>/<group>/<FILE>.lua   the job's settings (_master/config/<job>/), in their theme
---                                     folder (CharPaths.job_group: display, keys, inventory, combat)
---   <Char>/<job>/sets/<job>_sets.lua  the template's sets with every piece taken out: the set names,
---                                     sub-sets and set_combine stay, the gear is the player's to choose
---   character_db.lua                  the job added to the character's list
--- The character's own overlay (_master/<Char>/) wins file by file, its sets kept as they are. The
--- template's name (Tetsouo) becomes the character's, but on @author lines (as the clone does). A file that
--- exists is never written over; an entry that exists stops it all.
---
--- @file shared/utils/atelier/job_adder.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-24
---============================================================================

local JobAdder = {}

local TEMPLATE = 'Tetsouo'
JobAdder.JOBS = {WAR = true, MNK = true, WHM = true, BLM = true, RDM = true, THF = true, PLD = true, DRK = true,
    BST = true, BRD = true, RNG = true, SAM = true, NIN = true, DRG = true, SMN = true, BLU = true, COR = true,
    PUP = true, DNC = true, SCH = true, GEO = true, RUN = true}
-- The slots a set names: taken out of the sets copied from the template
local SLOTS = {main = true, sub = true, range = true, ranged = true, ammo = true, head = true, neck = true,
    ear1 = true, ear2 = true, left_ear = true, right_ear = true, lear = true, rear = true, body = true,
    hands = true, ring1 = true, ring2 = true, left_ring = true, right_ring = true, lring = true, rring = true,
    back = true, waist = true, legs = true, feet = true}

local function data_dir() return windower.addon_path .. 'data/' end

local function read(path)
    local f = io.open(path, 'rb')
    if not f then return nil end
    local text = f:read('*a')
    f:close()
    return text
end

local function write(path, text)
    require('shared/utils/core/char_paths').ensure_dir(path:match('^(.*)/[^/]*$'))
    local f = io.open(path, 'wb')
    if not f then return false end
    f:write(text)
    f:close()
    return true
end

local function exists(path)
    local f = io.open(path, 'rb')
    if f then f:close() return true end
    return false
end

--- The template's name made the character's, but on @author lines.
function JobAdder.rename(text, char)
    return (text:gsub('[^\n]*\n?', function(line)
        return line:find('@author', 1, true) and line or (line:gsub(TEMPLATE, char))
    end))
end

---============================================================================
--- SETS WITHOUT THEIR PIECES
---============================================================================

--- The end of what starts at i (a string, a comment) or nil: index of its last character.
local function skip_literal(s, i)
    local c = s:sub(i, i)
    if c == '"' or c == "'" then
        local j = i + 1
        while j <= #s do
            local d = s:sub(j, j)
            if d == '\\' then j = j + 2 elseif d == c then return j else j = j + 1 end
        end
        return #s
    end
    if s:sub(i, i + 1) == '--' then
        local eq = s:match('^%[(=*)%[', i + 2)
        if eq then local _, e = s:find(']' .. eq .. ']', i + 2, true); return e or #s end
        local e = s:find('\n', i, true)
        return e and e - 1 or #s
    end
    if c == '[' then
        local eq = s:match('^%[(=*)%[', i)
        if eq then local _, e = s:find(']' .. eq .. ']', i, true); return e or #s end
    end
    return nil
end

--- Index of the bracket closing the one at i ({ or ().
local function closing(s, i)
    local depth, j = 0, i
    while j <= #s do
        local lit = skip_literal(s, j)
        if lit then j = lit + 1
        else
            local c = s:sub(j, j)
            if c == '{' or c == '(' then depth = depth + 1
            elseif c == '}' or c == ')' then depth = depth - 1; if depth == 0 then return j end end
            j = j + 1
        end
    end
    return #s
end

local rewrite_expr

--- A table's fields, its gear taken out, its sub-tables rewritten the same way.
local function rewrite_table(inner)
    local fields, start, depth, j = {}, 1, 0, 1
    while j <= #inner do
        local lit = skip_literal(inner, j)
        if lit then j = lit + 1
        else
            local c = inner:sub(j, j)
            if c == '{' or c == '(' then depth = depth + 1
            elseif c == '}' or c == ')' then depth = depth - 1
            elseif (c == ',' or c == ';') and depth == 0 then fields[#fields + 1] = inner:sub(start, j - 1); start = j + 1 end
            j = j + 1
        end
    end
    fields[#fields + 1] = inner:sub(start)
    local kept = {}
    for _, f in ipairs(fields) do
        local body = f:gsub('%-%-[^\n]*', ''):match('^%s*(.-)%s*$')
        if body ~= '' then
            local key = body:match('^([%a_][%w_]*)%s*=') or body:match('^%[%s*["\']([^"\']+)["\']%s*%]%s*=')
            if not (key and SLOTS[key]) then
                local k, v = body:match('^(.-=)%s*(.*)$')
                if k and not k:find('[{(]') then kept[#kept + 1] = k .. ' ' .. rewrite_expr(v)
                else kept[#kept + 1] = rewrite_expr(body) end
            end
        end
    end
    if #kept == 0 then return '{}' end
    return '{' .. table.concat(kept, ', ') .. '}'
end

--- An expression with every table in it rewritten (set_combine(sets.x, {...}) keeps its call).
rewrite_expr = function(e)
    local out, j = {}, 1
    while j <= #e do
        local lit = skip_literal(e, j)
        if lit then out[#out + 1] = e:sub(j, lit); j = lit + 1
        elseif e:sub(j, j) == '{' then
            local k = closing(e, j)
            out[#out + 1] = rewrite_table(e:sub(j + 1, k - 1)); j = k + 1
        else out[#out + 1] = e:sub(j, j); j = j + 1 end
    end
    return table.concat(out)
end

--- A set file with its pieces taken out: each `sets.<...> = <expression>` and each `local <name> = <expression>`
--- written again with its tables rewritten (rewrite_table: a piece's own table, {name = ..., augments = ...}, names
--- no slot and stays whole); a piece given straight to a set (sets.x.head = '...') becomes nil; the rest as it was.
--- @param text string The template's set file
--- @return string
function JobAdder.empty_sets(text)
    local out, i = {}, 1
    while i <= #text do
        local line_end = text:find('\n', i, true) or #text + 1
        local line = text:sub(i, line_end - 1)
        -- (a set's name may hold anything in its brackets: sets.precast.WS['Tachi: Fudo'], sets['Blurred Shield +1'])
        local head = line:match('^([ \t]*sets[%.%[][^=]-=)') or line:match('^([ \t]*local[ \t]+[%a_][%w_]*[ \t]*=)')
        local eq = head and i + #head - 1
        if head and text:sub(eq + 1, eq + 1) ~= '=' then
            -- the expression: from its first word (it may start on the next line) to the end of its line, across
            -- brackets and strings
            local j, depth, started = eq + 1, 0, false
            while j <= #text do
                local lit = skip_literal(text, j)
                if lit then
                    if text:sub(j, j + 1) ~= '--' then started = true end
                    j = lit + 1
                else
                    local c = text:sub(j, j)
                    if c == '{' or c == '(' then depth = depth + 1
                    elseif c == '}' or c == ')' then depth = depth - 1
                    elseif c == '\n' and depth <= 0 and started then break end
                    if not c:match('%s') then started = true end
                    j = j + 1
                end
            end
            local last = head:match('%.([%a_][%w_]*)%s*=$') or head:match('%[%s*["\']([%a_][%w_]*)["\']%s*%]%s*=$')
            out[#out + 1] = head .. ((last and SLOTS[last]) and ' nil' or rewrite_expr(text:sub(eq + 1, j - 1)))
            i = j
        else
            out[#out + 1] = text:sub(i, line_end)
            i = line_end + 1
        end
    end
    return table.concat(out)
end

---============================================================================
--- ADD
---============================================================================

--- The job added to the character's list in character_db.lua (nothing when the character or the job is there).
local function add_to_db(char, job)
    local path = data_dir() .. 'character_db.lua'
    local text = read(path)
    if not text then return false end
    local s = text:find('\n%s*' .. char .. '%s*=%s*{')
    if not s then return false end
    local a = text:find('jobs%s*=%s*{', s)
    if not a then return false end
    local open = text:find('{', a, true)
    local close = closing(text, open)
    local list = text:sub(open + 1, close - 1)
    if list:find("['\"]" .. job .. "['\"]") then return false end
    local body = list:gsub('%s+$', '')
    local new = text:sub(1, open) .. body .. (body:match(',%s*$') and ' ' or ', ') .. "'" .. job .. "' " .. text:sub(close)
    return write(path, new)
end

--- Add a job to a character.
--- @param job string 'WHM'
--- @param char string|nil The character (the one logged in when nil)
--- @return table {ok, job, char, files = {written...}, kept = {there already...}} or {ok = false, error}
function JobAdder.add(job, char)
    job = type(job) == 'string' and job:upper() or ''
    if not JobAdder.JOBS[job] then return {ok = false, error = 'job'} end
    local CharPaths = require('shared/utils/core/char_paths')
    char = char or CharPaths.name()
    if not char then return {ok = false, error = 'char'} end
    local base, master, lower = data_dir() .. char .. '/', data_dir() .. '_master/', job:lower()
    local own = master .. char .. '/'
    local entry = base .. char .. '_' .. job .. '.lua'
    if exists(entry) then return {ok = false, error = 'exists', job = job, char = char} end
    local template = read(master .. 'entry/' .. TEMPLATE .. '_' .. job .. '.lua')
    if not template then return {ok = false, error = 'template', job = job} end
    local files, kept = {}, {}
    local function put(path, text)
        local rel = path:sub(#data_dir() + 1)
        if exists(path) then kept[#kept + 1] = rel return end
        if write(path, text) then files[#files + 1] = rel end
    end
    -- the settings: the template's files, the character's own overlay winning file by file
    local names = {}
    for _, dir in ipairs({master .. 'config/' .. lower, own .. 'config/' .. lower}) do
        local ok, names_in = pcall(windower.get_dir, dir)
        for _, name in ipairs(ok and names_in or {}) do if name:match('%.lua$') then names[name] = true end end
    end
    for name in pairs(names) do
        local text = read(own .. 'config/' .. lower .. '/' .. name)
        if not text then text = JobAdder.rename(read(master .. 'config/' .. lower .. '/' .. name) or '', char) end
        put(base .. lower .. '/' .. (CharPaths.job_group(name) or 'combat') .. '/' .. name, text)
    end
    -- the sets: the character's own as they are, else the template's without their pieces
    local mine = read(own .. 'sets/' .. lower .. '_sets.lua')
    local sets = mine or read(master .. 'sets/' .. lower .. '_sets.lua')
    if sets then
        if not mine then
            sets = '-- ' .. char .. "'s " .. job .. ' sets, made by the Atelier ("Add a job", ' .. os.date('%Y-%m-%d') ..
                ') from the template: every set is there, its pieces are yours to choose\n-- (the Atelier: Optimize this set).\n'
                .. JobAdder.rename(JobAdder.empty_sets(sets), char)
        end
        put(base .. lower .. '/sets/' .. lower .. '_sets.lua', sets)
    end
    -- the entry last: GearSwap loads the job only once it is there
    put(entry, JobAdder.rename(template, char))
    add_to_db(char, job)
    return {ok = true, job = job, char = char, files = files, kept = kept}
end

return JobAdder
