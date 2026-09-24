---============================================================================
--- Message TempBind - messages of //gs c tb (temporary keybinds)
---============================================================================
--- Templates live in data/systems/tempbind_messages.lua.
---
--- @file shared/utils/messages/formatters/system/message_tempbind.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-24
---============================================================================

local MessageTempBind = {}

local MessageCore = require('shared/utils/messages/message_core')
local M = require('shared/utils/messages/api/messages')

local SEPARATOR = string.rep('=', MessageCore.SEPARATOR_WIDTH)
local KEY_WIDTH = 12


local function separator()
    M.send('TEMPBIND', 'separator', {separator = SEPARATOR})
end

local function header(title)
    separator()
    M.send('TEMPBIND', 'title', {title = title})
    separator()
end

--- A key was bound.
--- @param key string Readable key ("Ctrl+F1")
--- @param command string Readable command
function MessageTempBind.show_added(key, command)
    M.send('TEMPBIND', 'added', {key = key, command = command})
end

--- The key is already used; nothing was bound.
--- @param key string Readable key
--- @param owner string What uses it
function MessageTempBind.show_taken(key, owner)
    M.send('TEMPBIND', 'taken', {key = key, owner = owner})
    M.send('TEMPBIND', 'taken_hint', {key_raw = key:lower()})
end

--- How to use the command, after a problem when there is one.
--- @param problem string|nil
function MessageTempBind.show_usage(problem)
    if problem then M.send('TEMPBIND', 'problem', {text = problem}) end
    MessageTempBind.show_help()
end

--- Help palette: the same codes as //gs c help
--- (message_commands.show_commands_list), so both screens look alike.
local C = {
    gray = string.char(0x1F, 8), dgray = string.char(0x1F, 160), yellow = string.char(0x1F, 36),
    gold = string.char(0x1F, 220), cyan = string.char(0x1F, 159), white = string.char(0x1F, 1),
    orange = string.char(0x1F, 68),
}

--- Column where descriptions start (dot leaders fill the gap).
local HELP_COL = 35

--- Help rows: {section} | {left, param, desc} | {'', note}. `left` is cyan,
--- `param` yellow (placeholders), `desc` white after a dot leader.
local HELP = {
    {'COMMANDS'},
    {'//gs c tb ', '<key> <what>', 'Bind a key'},
    {'//gs c tb ', '<what>', 'First free Ctrl/Alt+F1-F8'},
    {'//gs c tb force ', '<key> <what>', 'Even over a used key'},
    {'//gs c tb list', '', 'What is bound'},
    {'//gs c tb del ', '<key>', 'Unbind one'},
    {'//gs c tb clear', '', 'Unbind all'},
    {'KEYS', 'all of these are Ctrl+F1'},
    {'^f1', '', '^Ctrl !Alt ~Shift @Win #Apps'},
    {'ctrl+f1', '', 'ctrl+ alt+ shift+ win+ apps+'},
    {'cf1  cn1', '', 'Short: c a s w, n = numpad'},
    {'cc', '', 'Short letter key: one modifier'},
    {'WHAT', 'spell, ability, WS or item name'},
    {'dia2  cure4  provoke', '', 'Case, spaces, digits ignored'},
    {'beastmens seal', '', "Punctuation ignored"},
    {'tradenpc 1 ...', '', 'Anything else: sent as is'},
    {'TARGET', 'after the name'},
    {'t  st  stnpc  me  bt', '', "The game's <t> <st> ..."},
    {'vampire leech', '', 'Nearest one, at each press'},
    {'(nothing)', '', "The game's default target"},
    {'EXAMPLES'},
    {'//gs c tb dia2 t'},
    {'//gs c tb ^f2 provoke t'},
    {'//gs c tb !f3 beastmens seal shami'},
}

local function help_line(text)
    M.send('TEMPBIND', 'help_line', {text = text})
end

--- One help row, with the dot leader up to HELP_COL.
--- @param row table
local function help_row(row)
    local left, param, desc = row[1], row[2], row[3]
    if not param then
        return help_line(C.cyan .. '   ' .. left)
    end
    local width = 3 + #left + #param
    local dots = string.rep('.', math.max(2, HELP_COL - width - 2))
    help_line(C.cyan .. '   ' .. left .. C.yellow .. param .. C.gray .. ' ' .. dots .. ' ' .. C.white .. desc)
end

--- Full help: //gs c tb help. Every line fits the chat width.
function MessageTempBind.show_help()
    help_line(' ')
    help_line(C.yellow .. SEPARATOR)
    help_line(C.gold .. ' TEMP BINDS' .. C.dgray .. ' - Keys for a repetitive task')
    help_line(C.yellow .. SEPARATOR)
    for _, row in ipairs(HELP) do
        if row[3] or (row[2] and row[1]:match('^//')) then
            help_row(row)
        elseif row[1]:match('^%u+$') then
            help_line(' ')
            help_line(C.orange .. '>> ' .. row[1] .. (row[2] and (C.dgray .. ' (' .. row[2] .. ')') or ''))
        else
            help_row(row)
        end
    end
    help_line(' ')
    help_line(C.dgray .. '   Job and Mote keys are refused (use force).')
    help_line(C.dgray .. '   Cleared by tb clear, or when the game closes.')
    help_line(C.yellow .. SEPARATOR)
    help_line(' ')
end

--- Key with no temporary bind.
--- @param key string
function MessageTempBind.show_unknown(key)
    M.send('TEMPBIND', 'unknown', {key = key})
end

--- A name target is not around.
--- @param name string
function MessageTempBind.show_not_found(name)
    M.send('TEMPBIND', 'not_found', {name = name})
end

--- One bind removed.
--- @param key string
function MessageTempBind.show_removed(key)
    M.send('TEMPBIND', 'removed', {key = key})
end

--- All binds removed.
--- @param count number
function MessageTempBind.show_cleared(count)
    M.send('TEMPBIND', 'cleared', {count = count})
end

--- The current temporary binds.
--- @param rows table Array of {key, command}
function MessageTempBind.show_list(rows)
    header(#rows == 0 and 'none' or (#rows .. ' bound'))
    for _, r in ipairs(rows) do
        M.send('TEMPBIND', 'row', {key = ('%-' .. KEY_WIDTH .. 's'):format(r.key), command = r.command})
    end
    separator()
end

_G.MessageTempBind = MessageTempBind

return MessageTempBind
