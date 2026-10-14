---============================================================================
--- Lua Data - Lua text read as data, never run
---============================================================================
--- The Atelier page writes files the game reads (set_overrides.lua, keybind_overrides.lua) and rewrites settings
--- files through the game's HTTP door (shared/utils/atelier/atelier_live.lua). Running such a file with dofile
--- runs whatever it holds: a request with the door's token could make GearSwap run any Lua. This reads them as
--- data instead:
---   LuaData.parse(text)                 the value of a file "-- comments  return <value>", where a value is a
---                                       string, a number, true, false, nil or a table of them; nil and the
---                                       reason for anything else (a call, an operator, a name read)
---   LuaData.only_data_changed(a, b)     true when text b differs from text a only by data: what replaced the
---                                       changed tokens is strings, numbers, booleans, nil, table braces and
---                                       keys (a setting's new value), never a name read or a call
---
--- @file shared/utils/core/lua_data.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-14
---============================================================================

local LuaData = {}

local KEYWORDS = {['and'] = 1, ['break'] = 1, ['do'] = 1, ['else'] = 1, ['elseif'] = 1, ['end'] = 1, ['false'] = 1,
    ['for'] = 1, ['function'] = 1, ['if'] = 1, ['in'] = 1, ['local'] = 1, ['nil'] = 1, ['not'] = 1, ['or'] = 1,
    ['repeat'] = 1, ['return'] = 1, ['then'] = 1, ['true'] = 1, ['until'] = 1, ['while'] = 1}
local ESCAPES = {n = '\n', t = '\t', r = '\r', a = '\a', b = '\b', f = '\f', v = '\v', ['\\'] = '\\', ['"'] = '"', ["'"] = "'",
    ['\n'] = '\n'}

--- The end of a long bracket opened at `at` ("[[", "[==["): the position after its closing one, and its content.
local function long_bracket(text, at)
    local eq = text:match('^%[(=*)%[', at)
    if not eq then return nil end
    local open_end = at + #eq + 2
    local close = text:find(']' .. eq .. ']', open_end, true)
    if not close then return nil end
    return close + #eq + 2, text:sub(open_end, close - 1):gsub('^\r?\n', '')
end

--- A quoted string starting at `at`: the position after it and its value.
local function quoted(text, at)
    local quote, out, i = text:sub(at, at), {}, at + 1
    while i <= #text do
        local c = text:sub(i, i)
        if c == quote then return i + 1, table.concat(out) end
        if c == '\n' then return nil end
        if c == '\\' then
            local n = text:sub(i + 1, i + 1)
            local digits = text:match('^%d%d?%d?', i + 1)
            if digits then
                out[#out + 1] = string.char(tonumber(digits) % 256)
                i = i + 1 + #digits
            elseif ESCAPES[n] then
                out[#out + 1] = ESCAPES[n]
                i = i + 2
            else
                return nil
            end
        else
            out[#out + 1] = c
            i = i + 1
        end
    end
    return nil
end

--- The tokens of a Lua text, comments and spaces left out: {kind = 'str'|'num'|'name'|'kw'|'sym', v = value,
--- raw = its text}; nil and a reason when a string or a comment never ends.
--- @param text string
--- @return table|nil, string|nil
function LuaData.tokens(text)
    local out, i, n = {}, 1, #text
    while i <= n do
        local c = text:sub(i, i)
        if c:match('%s') then
            i = i + 1
        elseif text:sub(i, i + 1) == '--' then
            local after = long_bracket(text, i + 2)
            if after then i = after else i = (text:find('\n', i, true) or n) + 1 end
        elseif c == '"' or c == "'" then
            local after, value = quoted(text, i)
            if not after then return nil, 'string' end
            out[#out + 1] = {kind = 'str', v = value, raw = text:sub(i, after - 1)}
            i = after
        elseif c == '[' and text:match('^%[=*%[', i) then
            local after, value = long_bracket(text, i)
            if not after then return nil, 'string' end
            out[#out + 1] = {kind = 'str', v = value, raw = text:sub(i, after - 1)}
            i = after
        elseif c:match('%d') or (c == '.' and text:sub(i + 1, i + 1):match('%d')) then
            local raw = text:match('^0[xX]%x+', i) or text:match('^%d*%.?%d+[eE][%+%-]?%d+', i) or text:match('^%d+%.?%d*', i)
                or text:match('^%.%d+', i)
            out[#out + 1] = {kind = 'num', v = tonumber(raw), raw = raw}
            i = i + #raw
        elseif c:match('[%a_]') then
            local raw = text:match('^[%w_]+', i)
            out[#out + 1] = {kind = KEYWORDS[raw] and 'kw' or 'name', v = raw, raw = raw}
            i = i + #raw
        else
            local raw = text:match('^%.%.%.', i) or text:match('^[=~<>]=', i) or text:match('^%.%.', i) or c
            out[#out + 1] = {kind = 'sym', v = raw, raw = raw}
            i = i + #raw
        end
    end
    return out
end

local parse_value

--- A table's fields from token `i` (its "{"): the table and the token after its "}".
local function parse_table(tk, i)
    local out, index = {}, 0
    i = i + 1
    while tk[i] and tk[i].v ~= '}' do
        local key, value
        if tk[i].v == '[' then
            key, i = parse_value(tk, i + 1)
            if i == nil or not (tk[i] and tk[i].v == ']' and tk[i + 1] and tk[i + 1].v == '=') then return nil end
            value, i = parse_value(tk, i + 2)
        elseif tk[i].kind == 'name' and tk[i + 1] and tk[i + 1].v == '=' then
            key = tk[i].v
            value, i = parse_value(tk, i + 2)
        else
            index = index + 1
            key = index
            value, i = parse_value(tk, i)
        end
        if i == nil or key == nil then return nil end
        out[key] = value
        if tk[i] and (tk[i].v == ',' or tk[i].v == ';') then i = i + 1 elseif not (tk[i] and tk[i].v == '}') then return nil end
    end
    if not tk[i] then return nil end
    return out, i + 1
end

--- A value from token `i`: the value and the token after it, or nil, nil.
parse_value = function(tk, i)
    local t = tk[i]
    if not t then return nil, nil end
    if t.kind == 'str' or t.kind == 'num' then return t.v, i + 1 end
    if t.v == 'true' then return true, i + 1 end
    if t.v == 'false' then return false, i + 1 end
    if t.v == 'nil' then return nil, i + 1 end
    if t.v == '-' and tk[i + 1] and tk[i + 1].kind == 'num' then return -tk[i + 1].v, i + 2 end
    if t.v == '{' then return parse_table(tk, i) end
    return nil, nil
end

--- The value a data file returns.
--- @param text string The file's text
--- @return any|nil value, string|nil reason it is not data
function LuaData.parse(text)
    local tk, err = LuaData.tokens(text or '')
    if not tk then return nil, err end
    local i = (tk[1] and tk[1].v == 'return') and 2 or 1
    local value, after = parse_value(tk, i)
    if after == nil then return nil, 'not data' end
    if tk[after] and tk[after].v == ';' then after = after + 1 end
    if tk[after] then return nil, 'not data' end
    return value
end

-- What a changed setting may be made of: values, table braces and separators, a key and its "="
local DATA_SYMBOLS = {['{'] = true, ['}'] = true, ['['] = true, [']'] = true, ['='] = true, [','] = true, [';'] = true, ['-'] = true}
local function is_data(tk, k)
    local t = tk[k]
    if t.kind == 'str' or t.kind == 'num' then return true end
    if t.kind == 'kw' then return t.v == 'true' or t.v == 'false' or t.v == 'nil' end
    if t.kind == 'sym' then return DATA_SYMBOLS[t.v] or false end
    -- a name only as a table key (name = value), never read
    return t.kind == 'name' and tk[k + 1] ~= nil and tk[k + 1].v == '='
end

--- Whether text `after` differs from `before` only by data (the tokens between what they share at the start and
--- at the end).
--- @param before string
--- @param after string
--- @return boolean, string|nil reason when not
function LuaData.only_data_changed(before, after)
    local a, b = LuaData.tokens(before or ''), LuaData.tokens(after or '')
    if not (a and b) then return false, 'syntax' end
    local first = 1
    while a[first] and b[first] and a[first].raw == b[first].raw do first = first + 1 end
    local ea, eb = #a, #b
    while ea >= first and eb >= first and a[ea].raw == b[eb].raw do ea, eb = ea - 1, eb - 1 end
    for k = first, eb do
        if not is_data(b, k) then return false, b[k].raw end
    end
    return true
end

return LuaData
