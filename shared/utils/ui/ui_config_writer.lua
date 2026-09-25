---============================================================================
--- UI Config Writer - save one look option into UI_CONFIG.lua, in place
---============================================================================
--- The in-game `//gs c ui <option>` commands save what they change here, so
--- the file stays the one place that holds the player's look. Only the
--- option's own line is rewritten: comments, other options and the line
--- endings of the file are kept as they are.
---
---   `    -- column_gap = 3,`   set to 2   ->  `    column_gap = 2,`
---   `    column_gap = 2,`      reset      ->  `    -- column_gap = 2,`
---
--- A missing line is added at the top of its block; a missing block is
--- added before `return UIConfig`.
---
--- @file shared/utils/ui/ui_config_writer.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local UIConfigWriter = {}

---============================================================================
--- VALUE TO LUA TEXT
---============================================================================

local function quote(text)
    return "'" .. tostring(text):gsub('\\', '\\\\'):gsub("'", "\\'") .. "'"
end

local function item_lua(item)
    return type(item) == 'string' and quote(item) or tostring(item)
end

--- Lua source for a value: number, boolean, text, a list, or a table of
--- name = number/text (written sorted, on one line).
--- @param value any
--- @return string
function UIConfigWriter.to_lua(value)
    if type(value) == 'string' then return quote(value) end
    if type(value) ~= 'table' then return tostring(value) end
    local parts = {}
    if #value > 0 or next(value) == nil then
        for _, item in ipairs(value) do parts[#parts + 1] = item_lua(item) end
    else
        local names = {}
        for name in pairs(value) do names[#names + 1] = tostring(name) end
        table.sort(names)
        for _, name in ipairs(names) do parts[#parts + 1] = name .. ' = ' .. item_lua(value[name]) end
    end
    return '{' .. table.concat(parts, ', ') .. '}'
end

---============================================================================
--- LINE EDITING
---============================================================================

--- Index of `UIConfig.<block> = {` and of its closing `}`, or nil.
local function find_block(lines, block)
    local first
    for i, line in ipairs(lines) do
        if not first and line:match('^UIConfig%.' .. block .. '%s*=%s*{') then
            first = i
        elseif first and line:match('^}') then
            return first, i
        end
    end
    return nil
end

--- Rewrite (or comment out, when value_text is nil) the option line.
--- @return string|nil The new line, nil when the line needs no change
local function rewrite(line, name, value_text)
    local indent, dashes = line:match('^(%s*)(%-*)%s*' .. name .. '%s*=')
    local eq = line:find('=', 1, true)
    local comma = line:find(',%s+%-%-', eq)
    local comment = comma and line:sub(comma + 1) or ''
    if value_text then
        local new_line = indent .. name .. ' = ' .. value_text .. ','
        if comma then
            -- Keep the trailing comment in its column
            local room = comma - #new_line
            comment = string.rep(' ', math.max(1, room + #comment:match('^%s*'))) .. comment:gsub('^%s*', '')
        end
        return new_line .. comment
    end
    if dashes ~= '' then return nil end
    local body = line:sub(#indent + 1)
    if comma then
        -- The "-- " prefix pushes the trailing comment right: take the three
        -- columns back from the spaces in front of it (keeping at least one).
        local head = body:sub(1, comma - #indent)
        local spaces = comment:match('^%s*')
        body = head .. string.rep(' ', math.max(1, #spaces - 3)) .. comment:sub(#spaces + 1)
    end
    return indent .. '-- ' .. body
end

--- Apply the change to the list of lines.
--- @return boolean changed
local function edit_lines(lines, block, name, value_text)
    local first, last = find_block(lines, block)
    if not first then
        if not value_text then return false end
        for i = #lines, 1, -1 do
            if lines[i]:match('^return UIConfig') then
                table.insert(lines, i, '')
                table.insert(lines, i, '}')
                table.insert(lines, i, '    ' .. name .. ' = ' .. value_text .. ',')
                table.insert(lines, i, 'UIConfig.' .. block .. ' = {')
                return true
            end
        end
        return false
    end
    for i = first + 1, last - 1 do
        if lines[i]:match('^%s*%-*%s*' .. name .. '%s*=') then
            local _, opened = lines[i]:gsub('{', '')
            local _, closed = lines[i]:gsub('}', '')
            if opened ~= closed then
                -- A table spread over several lines: rewriting one line would break it
                return false, name .. ' spans several lines in UI_CONFIG.lua, edit it there'
            end
            local new_line = rewrite(lines[i], name, value_text)
            if new_line then lines[i] = new_line end
            return new_line ~= nil
        end
    end
    if not value_text then return false end
    table.insert(lines, first + 1, '    ' .. name .. ' = ' .. value_text .. ',')
    return true
end

---============================================================================
--- PUBLIC API
---============================================================================

--- This character's UI_CONFIG.lua path, or nil before the player is known.
--- @return string|nil
function UIConfigWriter.path()
    if not (player and player.name and windower and windower.addon_path) then return nil end
    return windower.addon_path .. 'data/' .. player.name .. '/config/UI_CONFIG.lua'
end

--- Save one option. value nil = comment the line out (back to standard).
--- @param block string 'layout', 'colors' or 'chat'
--- @param name string Option name
--- @param value any New value, or nil to reset
--- @return boolean ok
--- @return string|nil err
function UIConfigWriter.set(block, name, value)
    local path = UIConfigWriter.path()
    if not path then return false, 'character not known yet' end
    local file = io.open(path, 'rb')
    if not file then return false, 'cannot read ' .. path end
    local content = file:read('*a')
    file:close()

    local eol = content:find('\r\n', 1, true) and '\r\n' or '\n'
    local lines = {}
    for line in (content:gsub('\r\n', '\n') .. '\n'):gmatch('(.-)\n') do
        lines[#lines + 1] = line
    end
    if lines[#lines] == '' then lines[#lines] = nil end

    local value_text = value ~= nil and UIConfigWriter.to_lua(value) or nil
    local changed, err = edit_lines(lines, block, name, value_text)
    if err then return false, err end
    if not changed then return true end

    file = io.open(path, 'wb')
    if not file then return false, 'cannot write ' .. path end
    file:write(table.concat(lines, eol) .. eol)
    file:close()
    return true
end

return UIConfigWriter
