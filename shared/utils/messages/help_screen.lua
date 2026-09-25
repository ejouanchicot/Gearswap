---============================================================================
--- Help Screen - one renderer for every help screen
---============================================================================
--- A module describes its help as data; this renders it in the look of
--- //gs c commands (templates in data/systems/help_messages.lua):
---
---   HelpScreen.show({
---       title = 'WARP', subtitle = 'Teleport commands',
---       groups = {
---           {title = 'SPELLS', note = 'BLM / WHM', rows = {
---               {'//gs c warp', '', 'Warp to home point'},
---               {'//gs c tele ', '<name>', 'Teleport crag'},
---               {'//gs c w'},                     -- command alone
---           }},
---       },
---       notes = {'Items are used when no spell is known.'},
---   })
---
--- Rows are {command, placeholders, description}: the command in aqua, the
--- placeholders in mustard, a dot leader, the description in white. The
--- description column is the widest row + 4 (or `col`), so the dots line
--- up; it is capped so a line fits the chat width.
---
--- Lists built at run time (//gs c altcmds) use the same pieces directly:
--- header, group, rows, names, notes, footer.
---
--- @file shared/utils/messages/help_screen.lua
--- @author Tetsouo
--- @version 1.1
--- @date Created: 2026-09-25
---============================================================================

local HelpScreen = {}

local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')

--- Minimum dots between a command and its description.
local MIN_DOTS = 2

local function separator()
    M.send('HELP', 'separator', {separator = string.rep('=', MessageCore.SEPARATOR_WIDTH)})
end

--- Description column of a list of rows: the widest command + 2 + MIN_DOTS.
--- @param rows table Rows {command, placeholders, description}
--- @return number
function HelpScreen.column(rows)
    local widest = 0
    for _, row in ipairs(rows) do
        if row[3] then widest = math.max(widest, 3 + #row[1] + #(row[2] or '')) end
    end
    return widest + 2 + MIN_DOTS
end

--- Blank line, separator, title, separator.
--- @param title string
--- @param subtitle string|nil
function HelpScreen.header(title, subtitle)
    M.send('HELP', 'blank')
    separator()
    if subtitle then
        M.send('HELP', 'title_subtitle', {title = title, subtitle = subtitle})
    else
        M.send('HELP', 'title', {title = title})
    end
    separator()
end

--- Blank line, then ">> TITLE (note)".
--- @param title string|nil No heading when nil (the blank line stays)
--- @param note string|nil
function HelpScreen.group(title, note)
    M.send('HELP', 'blank')
    if not title then return end
    if note then
        M.send('HELP', 'group_note', {title = title, note = note})
    else
        M.send('HELP', 'group', {title = title})
    end
end

--- A description cut at word boundaries into lines of at most `room`.
local function wrap(text, room)
    if #text <= room then return {text} end
    local lines, line = {}, ''
    for word in text:gmatch('%S+') do
        if line ~= '' and #line + 1 + #word > room then
            lines[#lines + 1] = line
            line = word
        else
            line = line == '' and word or (line .. ' ' .. word)
        end
    end
    if line ~= '' then lines[#lines + 1] = line end
    return lines
end

local function send_row(row, col)
    local command, params, description = row[1], row[2] or '', row[3]
    if not description then
        if params == '' then return M.send('HELP', 'row_command', {command = command}) end
        return M.send('HELP', 'row_command_params', {command = command, params = params})
    end
    local width = 3 + #command + #params
    local dots = string.rep('.', math.max(MIN_DOTS, col - width - 2))
    -- Where the description starts, and what is left of the chat line
    local start = width + 2 + #dots
    local lines = wrap(description, math.max(10, MessageCore.SEPARATOR_WIDTH - start))
    M.send('HELP', 'row', {command = command, params = params, description = lines[1], dots = dots})
    for i = 2, #lines do
        M.send('HELP', 'row_more', {indent = string.rep(' ', start), description = lines[i]})
    end
end

--- Command rows, dots lined up at `col` (default: HelpScreen.column(rows)).
--- @param rows table
--- @param col number|nil
function HelpScreen.rows(rows, col)
    col = col or HelpScreen.column(rows)
    for _, row in ipairs(rows) do send_row(row, col) end
end

--- Names on as few lines as fit the chat width, in the command colour.
--- @param names table
function HelpScreen.names(names)
    local room = MessageCore.SEPARATOR_WIDTH - 3
    local line = ''
    for _, name in ipairs(names) do
        if line ~= '' and #line + 1 + #name > room then
            M.send('HELP', 'row_command', {command = line})
            line = name
        else
            line = line == '' and name or (line .. ' ' .. name)
        end
    end
    if line ~= '' then M.send('HELP', 'row_command', {command = line}) end
end

--- Blank line, then one gray line per note.
--- @param notes table|nil
function HelpScreen.notes(notes)
    if not notes or #notes == 0 then return end
    M.send('HELP', 'blank')
    for _, text in ipairs(notes) do M.send('HELP', 'note', {text = text}) end
end

--- Separator, blank line.
function HelpScreen.footer()
    separator()
    M.send('HELP', 'blank')
end

--- Show a whole help screen.
--- The dots line up across groups; a group with `own_col = true` (short
--- names under long commands) gets its own column instead.
--- @param spec table {title, subtitle?, col?, groups = {{title?, note?, own_col?, rows}}, notes?}
function HelpScreen.show(spec)
    local col = spec.col
    if not col then
        local all = {}
        for _, group in ipairs(spec.groups or {}) do
            if not group.own_col then
                for _, row in ipairs(group.rows or {}) do all[#all + 1] = row end
            end
        end
        col = HelpScreen.column(all)
    end
    HelpScreen.header(spec.title, spec.subtitle)
    for _, group in ipairs(spec.groups or {}) do
        HelpScreen.group(group.title, group.note)
        HelpScreen.rows(group.rows or {}, not group.own_col and col or nil)
    end
    HelpScreen.notes(spec.notes)
    HelpScreen.footer()
end

return HelpScreen
