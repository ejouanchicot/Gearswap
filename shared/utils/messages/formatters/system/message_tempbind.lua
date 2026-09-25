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

-- Built at each use: the width follows the player's chat.width
local function separator_line() return string.rep('=', MessageCore.SEPARATOR_WIDTH) end
local KEY_WIDTH = 12


local function separator()
    M.send('TEMPBIND', 'separator', {separator = separator_line()})
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

--- //gs c tb help, rendered by HelpScreen in the look of //gs c commands.
--- Description column 35 (every line fits the chat width).
local HELP = {
    title = 'TEMP BINDS', subtitle = 'Keys for a repetitive task', col = 35,
    groups = {
        {title = 'COMMANDS', rows = {
            {'//gs c tb ', '<key> <what>', 'Bind a key'},
            {'//gs c tb ', '<what>', 'First free Ctrl/Alt+F1-F8'},
            {'//gs c tb force ', '<key> <what>', 'Even over a used key'},
            {'//gs c tb list', '', 'What is bound'},
            {'//gs c tb del ', '<key>', 'Unbind one'},
            {'//gs c tb clear', '', 'Unbind all'},
        }},
        {title = 'KEYS', note = 'all of these are Ctrl+F1', rows = {
            {'^f1', '', '^Ctrl !Alt ~Shift @Win #Apps'},
            {'ctrl+f1', '', 'ctrl+ alt+ shift+ win+ apps+'},
            {'cf1  cn1', '', 'Short: c a s w, n = numpad'},
            {'cc', '', 'Short letter key: one modifier'},
        }},
        {title = 'WHAT', note = 'spell, ability, WS or item name', rows = {
            {'dia2  cure4  provoke', '', 'Case, spaces, digits ignored'},
            {'beastmens seal', '', 'Punctuation ignored'},
            {'tradenpc 1 ...', '', 'Anything else: sent as is'},
            {'//sm follow off', '', 'Any addon command, as is'},
            {'/p ready  /follow', '', 'Game command, as is'},
        }},
        {title = 'TARGET', note = 'after the name', rows = {
            {'t  st  stnpc  me  bt', '', "The game's <t> <st> ..."},
            {'vampire leech', '', 'Nearest one, at each press'},
            {'(nothing)', '', "The game's default target"},
        }},
        {title = 'EXAMPLES', rows = {
            {'//gs c tb dia2 t'},
            {'//gs c tb ^f2 provoke t'},
            {'//gs c tb !f3 beastmens seal shami'},
        }},
    },
    notes = {
        'Job and Mote keys are refused (use force).',
        'Cleared by tb clear, or when the game closes.',
    },
}

--- Full help: //gs c tb help. Every line fits the chat width.
function MessageTempBind.show_help()
    require('shared/utils/messages/help_screen').show(HELP)
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
