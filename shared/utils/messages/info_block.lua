---============================================================================
--- Info Block - one renderer for every data block
---============================================================================
--- Status, stats, detail cards and lists, in the look of the Sortie messages
--- (templates in data/systems/block_messages.lua):
---
---   InfoBlock.show({
---       tag = 'WATCHDOG', title = 'Status',
---       fields = {
---           {'Enabled', true},                 -- ON (green) / OFF (red)
---           {'Buffer', '1.0 s'},               -- white
---           {'Stuck', '3', 'bad'},             -- red
---       },
---       lines = {'free text under the fields'},
---   })
---
--- Field kinds: nil (white), 'good' (green), 'bad' (red), 'warn' (orange),
--- 'spell' (spell colour), 'dim' (gray). A boolean value prints ON / OFF.
--- Labels are padded to the widest one of the block, so the colons line up.
--- Blocks built piece by piece use header, fields, text, footer.
---
--- Help screens have their own look: shared/utils/messages/help_screen.lua.
---
--- @file shared/utils/messages/info_block.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local InfoBlock = {}

local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')

local KINDS = {good = true, bad = true, warn = true, spell = true, dim = true}

--- Separator line at the chat width in use.
function InfoBlock.separator()
    M.send('BLOCK', 'separator', {separator = string.rep('=', MessageCore.SEPARATOR_WIDTH)})
end

--- Separator, "  TAG :: title", separator.
--- @param tag string
--- @param title string
function InfoBlock.header(tag, title)
    InfoBlock.separator()
    M.send('BLOCK', 'title', {tag = tag, title = title})
    InfoBlock.separator()
end

--- One "Label : value" line.
--- @param label string Already padded when it must line up
--- @param value any
--- @param kind string|nil good / bad / warn / spell / dim
function InfoBlock.field(label, value, kind)
    if value == true then return M.send('BLOCK', 'field_on', {label = label}) end
    if value == false then return M.send('BLOCK', 'field_off', {label = label}) end
    local key = KINDS[kind] and ('field_' .. kind) or 'field'
    M.send('BLOCK', key, {label = label, value = tostring(value)})
end

--- Width of the widest label of a field list.
--- @param fields table {{label, value, kind}, ...}
--- @return number
function InfoBlock.label_width(fields)
    local width = 0
    for _, f in ipairs(fields) do width = math.max(width, #f[1]) end
    return width
end

--- A text cut at word boundaries into lines of at most `room`.
local function wrap(text, room)
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

--- Field lines, labels padded to `width` (default: the widest of them).
--- A value too long for the chat line goes on under its column.
--- @param fields table {{label, value, kind}, ...}
--- @param width number|nil
function InfoBlock.fields(fields, width)
    width = width or InfoBlock.label_width(fields)
    local room = math.max(10, MessageCore.SEPARATOR_WIDTH - width - 3)
    for _, f in ipairs(fields) do
        local label = ('%-' .. width .. 's'):format(f[1])
        if type(f[2]) == 'string' and #f[2] > room then
            for i, part in ipairs(wrap(f[2], room)) do
                InfoBlock.field(i == 1 and label or string.rep(' ', width), part, f[3])
            end
        else
            InfoBlock.field(label, f[2], f[3])
        end
    end
end

--- A line that is not a field.
--- @param text string
--- @param kind string|nil 'dim' (gray) or 'bad' (red); white otherwise
function InfoBlock.text(text, kind)
    local key = (kind == 'dim' or kind == 'bad') and ('text_' .. kind) or 'text'
    M.send('BLOCK', key, {text = text})
end

--- Closing separator.
function InfoBlock.footer()
    InfoBlock.separator()
end

--- A whole block.
--- @param spec table {tag, title, fields?, lines?, width?}
---   lines: texts, or {text, kind} pairs, printed after the fields
function InfoBlock.show(spec)
    InfoBlock.header(spec.tag, spec.title)
    if spec.fields then InfoBlock.fields(spec.fields, spec.width) end
    for _, line in ipairs(spec.lines or {}) do
        if type(line) == 'table' then
            InfoBlock.text(line[1], line[2])
        else
            InfoBlock.text(line)
        end
    end
    InfoBlock.footer()
end

return InfoBlock
