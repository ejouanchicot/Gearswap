---============================================================================
--- Set Writer - rewrites one set of a sets file, the rest of the file kept
---============================================================================
--- The Atelier page's "Push to GearSwap" (shared/utils/atelier/set_push.lua)
--- writes the pieces chosen in the page into the set file itself. This module
--- is the text part, with no game access: it finds where a set is written
---
---   sets.precast.WS['Disaster'] = set_combine(sets.precast.WS, { ... })
---   sets.idle = { ... }
---
--- and changes only the lines of the slots asked: a slot written already gets
--- its new value (its comment kept), a new slot gets a line in slot order, an
--- inherited slot loses its line. Strings and comments are skipped while
--- reading, so a brace inside them changes nothing.
---
--- A set written another way (a loop, an alias of another set, set_combine
--- with no table of its own) is not found: the page then offers "Copy as Lua".
---
--- @file    shared/utils/atelier/set_writer.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-02
---============================================================================

local SetWriter = {}

-- The page's slot names, in the order a set lists them
SetWriter.ORDER = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body', 'hands',
    'ring1', 'ring2', 'back', 'waist', 'legs', 'feet'}
local RANK = {}
for i, slot in ipairs(SetWriter.ORDER) do RANK[slot] = i end
-- Every spelling GearSwap accepts for a slot (lower case), by the page's name
local CANON = {left_ear = 'ear1', lear = 'ear1', right_ear = 'ear2', rear = 'ear2', left_ring = 'ring1',
    lring = 'ring1', right_ring = 'ring2', rring = 'ring2', ranged = 'range'}

--- The page's name of a slot key, or nil for a key that is no slot.
function SetWriter.canon(key)
    if type(key) ~= 'string' then return nil end
    local k = key:lower()
    k = CANON[k] or k
    return RANK[k] and k or nil
end

---============================================================================
--- READING: strings and comments skipped
---============================================================================

--- When a string or a comment starts at i, the index just after it; else nil.
local function skip(text, i)
    local c = text:sub(i, i)
    if c == '-' and text:sub(i + 1, i + 1) == '-' then
        local eq = text:match('^%[(=*)%[', i + 2)
        if eq then
            local _, e = text:find(']' .. eq .. ']', i + 4 + #eq, true)
            return (e or #text) + 1
        end
        local e = text:find('\n', i, true)
        return e or #text + 1
    end
    if c == '"' or c == "'" then
        local j = i + 1
        while j <= #text do
            local d = text:sub(j, j)
            if d == '\\' then j = j + 2
            elseif d == c or d == '\n' then return j + 1
            else j = j + 1 end
        end
        return j
    end
    if c == '[' then
        local eq = text:match('^%[(=*)%[', i)
        if eq then
            local _, e = text:find(']' .. eq .. ']', i + 2 + #eq, true)
            return (e or #text) + 1
        end
    end
    return nil
end

local OPEN = {['{'] = true, ['('] = true, ['[']= true}
local CLOSE = {['}'] = true, [')'] = true, [']'] = true}

--- The index of the bracket closing the one at i, or nil.
local function match_close(text, i)
    local depth, j = 0, i
    while j <= #text do
        local after = skip(text, j)
        if after then j = after
        else
            local c = text:sub(j, j)
            if OPEN[c] then depth = depth + 1
            elseif CLOSE[c] then
                depth = depth - 1
                if depth == 0 then return j end
            end
            j = j + 1
        end
    end
    return nil
end

--- The next index from i that is neither blank nor a comment.
local function next_code(text, i)
    while i <= #text do
        local c = text:sub(i, i)
        if c:match('%s') then i = i + 1
        elseif c == '-' and text:sub(i + 1, i + 1) == '-' then i = skip(text, i)
        else return i end
    end
    return i
end

--- A set path ('sets.precast.WS["Savage Blade"]') as its keys: {'precast', 'WS', 'Savage Blade'}.
--- Reads from i; returns the keys and the index after the path, or nil.
local function read_path(text, i)
    if text:sub(i, i + 3) ~= 'sets' or text:sub(i + 4, i + 4):match('[%w_]') then return nil end
    local keys, j = {}, i + 4
    while true do
        local k = j
        while text:sub(k, k) == ' ' do k = k + 1 end
        local name, e = text:match('^%.%s*([%a_][%w_]*)()', k)
        if not name then
            local q = text:match('^%[%s*([\'"])', k)
            if q then name, e = text:match('^%[%s*' .. q .. '(.-)' .. q .. '%s*%]()', k) end
        end
        if not name then return keys, j end
        keys[#keys + 1] = name
        j = e
    end
end

--- The keys of a path as the page writes it.
function SetWriter.path_keys(path)
    local keys, e = read_path(path, 1)
    if not keys or e <= #path then return nil end
    return keys
end

local function same_keys(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do if a[i] ~= b[i] then return false end end
    return true
end

--- The entries of the table from o to c ({ at o, } at c): {key, slot, from, key_end, expr_from, expr_to, sep}.
local function entries(text, o, c)
    local out, i = {}, o + 1
    while true do
        i = next_code(text, i)
        if i >= c then break end
        local entry = {from = i}
        local key, e = text:match('^([%a_][%w_]*)%s*=()', i)
        if not key then
            local q = text:match('^%[%s*([\'"])', i)
            if q then key, e = text:match('^%[%s*' .. q .. '(.-)' .. q .. '%s*%]%s*=()', i) end
        end
        entry.key, entry.slot = key, SetWriter.canon(key)
        local j = key and next_code(text, e) or i
        entry.expr_from = j
        local last = j
        while j < c do
            local after = skip(text, j)
            local ch = text:sub(j, j)
            if after then
                -- a string is part of the value, a comment is not
                if ch == '"' or ch == "'" or (ch == '[' and text:sub(j + 1, j + 1):match('[%[=]')) then last = after - 1 end
                j = after
            elseif OPEN[ch] then j = (match_close(text, j) or c) + 1; last = j - 1
            elseif ch == ',' or ch == ';' then break
            else
                if not ch:match('%s') then last = j end
                j = j + 1
            end
        end
        entry.expr_to = last
        entry.sep = j < c and j or nil
        out[#out + 1] = entry
        i = j + 1
    end
    return out
end

--- Every set written in the file with a table of its own:
--- {keys, line_from, open, close, indent, entries}.
function SetWriter.definitions(text)
    local defs, pos = {}, 1
    while pos <= #text do
        local line_from = pos
        local line_to = text:find('\n', pos, true) or #text + 1
        local indent, start = text:match('^([ \t]*)()sets[%.%[ ]', pos)
        if start and start < line_to then
            local keys, after = read_path(text, start)
            local eq = keys and text:match('^%s*=()', after)
            if eq and text:sub(eq, eq) ~= '=' then
                local r = next_code(text, eq)
                local open
                if text:sub(r, r) == '{' then open = r
                elseif text:match('^set_combine%s*%(', r) then
                    local p = text:find('(', r, true)
                    local q = match_close(text, p)
                    -- the last argument, when it is a table literal reaching the closing parenthesis
                    local k = q and q - 1
                    while k and k > p and text:sub(k, k):match('%s') do k = k - 1 end
                    if k and text:sub(k, k) == '}' then
                        local j, cand = p + 1, nil
                        while j < q do
                            local after2 = skip(text, j)
                            if after2 then j = after2
                            elseif text:sub(j, j) == '{' then
                                local cl = match_close(text, j)
                                if cl == k then cand = j end
                                j = (cl or q) + 1
                            elseif OPEN[text:sub(j, j)] then j = (match_close(text, j) or q) + 1
                            else j = j + 1 end
                        end
                        open = cand
                    end
                end
                local close = open and match_close(text, open)
                if close then
                    defs[#defs + 1] = {keys = keys, line_from = line_from, open = open, close = close,
                        indent = indent, entries = entries(text, open, close)}
                    line_to = text:find('\n', close, true) or #text + 1
                end
            end
        end
        pos = line_to + 1
    end
    return defs
end

--- The definition of one set, or nil.
function SetWriter.find(text, path)
    local keys = SetWriter.path_keys(path)
    if not keys then return nil end
    for _, def in ipairs(SetWriter.definitions(text)) do
        if same_keys(def.keys, keys) then return def end
    end
    return nil
end

---============================================================================
--- WRITING
---============================================================================

local function line_start(text, i)
    while i > 1 and text:sub(i - 1, i - 1) ~= '\n' do i = i - 1 end
    return i
end

local function line_end(text, i)
    return text:find('\n', i, true) or #text + 1
end

local function only_blank(s) return s:match('^[ \t]*$') ~= nil end

--- The indent and key padding new lines of a definition take: its entries' own,
--- else the definition's indent plus 4 spaces, keys padded when the file pads them.
local function style(text, def)
    local indent, padded
    for _, e in ipairs(def.entries) do
        local ls = line_start(text, e.from)
        if e.key and only_blank(text:sub(ls, e.from - 1)) then
            indent = indent or text:sub(ls, e.from - 1)
            local pad = text:sub(e.from, e.expr_from - 1):match('^[%w_]+( +)=') or ' '
            padded = padded or #pad > 1
        end
    end
    if indent then return indent, padded end
    return def.indent .. '    ', text:find('\n[ \t]+ammo  = ') ~= nil
end

--- One `slot = expr,` line.
local function entry_line(indent, padded, slot, expr)
    local key = padded and (slot .. string.rep(' ', math.max(1, 6 - #slot))) or (slot .. ' ')
    return indent .. key .. '= ' .. expr .. ','
end

--- A table written on one line ({head = 'X', feet = Y}) is written again whole, on one line:
--- its other entries as they were, the slots in slot order.
local function edit_inline(text, def, changes)
    local parts, done, seen = {}, {}, {}
    local function add_new(upto)
        for _, slot in ipairs(SetWriter.ORDER) do
            if RANK[slot] < upto and changes[slot] and not seen[slot] then
                seen[slot] = true
                parts[#parts + 1] = slot .. ' = ' .. changes[slot]
                done[#done + 1] = {slot = slot, before = nil, after = changes[slot]}
            end
        end
    end
    for _, e in ipairs(def.entries) do
        local expr = text:sub(e.expr_from, e.expr_to)
        if e.slot then add_new(RANK[e.slot]) end
        local new = e.slot and changes[e.slot]
        if e.slot and seen[e.slot] then
            -- the same slot twice in a table: the first one stays as written
            parts[#parts + 1] = text:sub(e.from, e.expr_to)
        elseif e.slot and new ~= nil then
            seen[e.slot] = true
            if new then parts[#parts + 1] = text:sub(e.from, e.expr_from - 1) .. new end
            if new ~= expr then done[#done + 1] = {slot = e.slot, before = expr, after = new or nil} end
        else
            parts[#parts + 1] = text:sub(e.from, e.expr_to)
        end
    end
    add_new(math.huge)
    local inner = text:sub(def.open + 1, def.close - 1)
    local sp = inner:match('^ ') and ' ' or ''
    local body = #parts > 0 and (sp .. table.concat(parts, ', ') .. sp) or ''
    return text:sub(1, def.open) .. body .. text:sub(def.close), done
end

--- The file with the definition changed: changes = {slot = expr | false}, false
--- taking the slot's line out (the set inherits it again).
--- @return string text, table changes made {slot, before, after}
function SetWriter.edit(text, def, changes)
    if #def.entries > 0 and not text:sub(def.open, def.close):find('\n', 1, true) then
        return edit_inline(text, def, changes)
    end
    local nl = text:find('\r\n', 1, true) and '\r\n' or '\n'
    local indent, padded = style(text, def)
    local edits, done, by_slot = {}, {}, {}
    for _, e in ipairs(def.entries) do if e.slot and not by_slot[e.slot] then by_slot[e.slot] = e end end
    local inserts = {}
    for _, slot in ipairs(SetWriter.ORDER) do
        local expr = changes[slot]
        local e = by_slot[slot]
        if expr ~= nil then
            local before = e and text:sub(e.expr_from, e.expr_to) or nil
            if e and expr then
                if before ~= expr then
                    edits[#edits + 1] = {from = e.expr_from, to = e.expr_to, text = expr}
                    done[#done + 1] = {slot = slot, before = before, after = expr}
                end
            elseif e then
                local ls, le = line_start(text, e.from), line_end(text, e.sep or e.expr_to)
                local rest = text:sub((e.sep or e.expr_to) + 1, le - 1)
                if only_blank(text:sub(ls, e.from - 1)) and (only_blank(rest) or rest:match('^%s*%-%-')) then
                    edits[#edits + 1] = {from = ls, to = math.min(le, #text), text = ''}
                else
                    edits[#edits + 1] = {from = e.from, to = e.sep or e.expr_to, text = ''}
                end
                done[#done + 1] = {slot = slot, before = before, after = nil}
            elseif expr then
                inserts[#inserts + 1] = {slot = slot, expr = expr}
                done[#done + 1] = {slot = slot, before = nil, after = expr}
            end
        end
    end
    if #inserts > 0 then
        local multi = text:sub(def.open, def.close):find('\n', 1, true) ~= nil
        if #def.entries == 0 then
            local lines = {}
            for i, ins in ipairs(inserts) do lines[i] = entry_line(indent, padded, ins.slot, ins.expr) end
            edits[#edits + 1] = {from = def.open + 1, to = def.close - 1, text = nl .. table.concat(lines, nl) .. nl .. def.indent}
        elseif multi then
            local last = def.entries[#def.entries]
            for _, ins in ipairs(inserts) do
                -- before the first entry of a later slot that starts its line, else after the last entry
                local at
                for _, e in ipairs(def.entries) do
                    local ls = line_start(text, e.from)
                    if e.slot and RANK[e.slot] > RANK[ins.slot] and only_blank(text:sub(ls, e.from - 1)) then at = ls break end
                end
                if at then
                    edits[#edits + 1] = {from = at, to = at - 1, text = entry_line(indent, padded, ins.slot, ins.expr) .. nl, order = RANK[ins.slot]}
                else
                    if not last.sep then
                        edits[#edits + 1] = {from = last.expr_to + 1, to = last.expr_to, text = ',', order = 0}
                        last.sep = last.expr_to
                    end
                    local le = line_end(text, last.sep)
                    if le > def.close then le = def.close end
                    local at2 = text:sub(le, le) == '\n' and le + 1 or le
                    local lead = text:sub(le, le) == '\n' and '' or nl
                    local trail = text:sub(le, le) == '\n' and nl or nl .. def.indent
                    edits[#edits + 1] = {from = at2, to = at2 - 1, text = lead .. entry_line(indent, padded, ins.slot, ins.expr) .. trail, order = RANK[ins.slot]}
                end
            end
        else
            local last = def.entries[#def.entries]
            local parts = {}
            for _, ins in ipairs(inserts) do parts[#parts + 1] = ins.slot .. ' = ' .. ins.expr end
            local at = (last.sep or last.expr_to) + 1
            edits[#edits + 1] = {from = at, to = at - 1, text = (last.sep and ' ' or ', ') .. table.concat(parts, ', ') .. (last.sep and ',' or '')}
        end
    end
    -- from the end, so earlier offsets stay right; at one place a line taken out goes first
    -- (an insert there lands where it was), then the inserts in slot order
    table.sort(edits, function(a, b)
        if a.from ~= b.from then return a.from > b.from end
        local ia, ib = a.to < a.from, b.to < b.from
        if ia ~= ib then return ib end
        return (a.order or 0) > (b.order or 0)
    end)
    for _, ed in ipairs(edits) do text = text:sub(1, ed.from - 1) .. ed.text .. text:sub(ed.to + 1) end
    return text, done
end

--- A Lua string literal: single quotes unless the text holds one.
function SetWriter.quote(s)
    s = s:gsub('\\', '\\\\')
    if not s:find("'", 1, true) then return "'" .. s .. "'" end
    return '"' .. s:gsub('"', '\\"') .. '"'
end

--- A piece written out: 'Name', or {name = 'Name', augments = {'A', 'B'}}.
function SetWriter.literal(name, augs)
    if not augs or #augs == 0 then return SetWriter.quote(name) end
    local list = {}
    for i, a in ipairs(augs) do list[i] = SetWriter.quote(a) end
    return '{name = ' .. SetWriter.quote(name) .. ', augments = {' .. table.concat(list, ', ') .. '}}'
end

--- The lines of the definition (from its first line to the line of its closing brace).
function SetWriter.block(text, def)
    return text:sub(def.line_from, line_end(text, def.close) - 1)
end

--- A short hash of a text (djb2), to tell whether a file changed.
function SetWriter.hash(text)
    local h = 5381
    for i = 1, #text do h = (h * 33 + text:byte(i)) % 4294967296 end
    return string.format('%08x', h)
end

return SetWriter
