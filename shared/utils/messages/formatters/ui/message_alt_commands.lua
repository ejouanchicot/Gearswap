---============================================================================
--- Alt Commands Message Formatter - Dual-box command listing
---============================================================================
--- Renders the list produced by `//gs c altcmds`. The row count is driven by
--- the player's own config file, so this builds lines directly instead of
--- going through fixed templates.
---
--- @file    messages/formatters/ui/message_alt_commands.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-07
---============================================================================

local MessageAltCommands = {}

local MessageCore = require('shared/utils/messages/message_core')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')
local Colors = MessageCore.COLORS

--- Short label describing what a command entry targets.
--- A target may be a function evaluated at command time (a GEO Indi- switches
--- to an ally while the alt holds Entrust), so it is resolved here too - the
--- list then shows where the command would land right now.
--- @param entry table Command definition
--- @return string Human-readable target label
local function target_label(entry)
    local target = entry.target or 'lastst'

    if type(target) == 'function' then
        local ok, resolved = pcall(target)
        if not ok or type(resolved) ~= 'string' then
            return 'depends'
        end
        target = resolved
    end

    local labels = {
        lastst = 'your last subtarget', t = 'your target',
        bt = 'your battle target', ft = 'your follow target',
        scan = 'your scan target',
        me = 'the alt itself', pet = "the alt's pet",
    }
    return labels[target:lower()] or target
end

--- What a command will cast, as text (functions cannot be previewed).
--- @param entry table Command definition
--- @return string Action label
local function action_label(entry)
    if entry.chain then
        local names = {}
        for _, step in ipairs(entry.chain) do
            names[#names + 1] = tostring(step.spell or '?')
        end
        return table.concat(names, ' + ')
    end
    if type(entry.spell) == 'function' then
        return entry.desc or '(computed)'
    end
    if entry.spell_from_state then
        return 'follows ' .. entry.spell_from_state
    end
    return tostring(entry.spell or '?')
end

--- Display every alt command available for the alt's current job
--- @param alt string Alt character name
--- @param job string Alt's current job code
--- @param names table Sorted list of command names
--- @param commands table Command definitions keyed by name
function MessageAltCommands.show_list(alt, job, names, commands)
    local gray = MessageCore.create_color_code(Colors.SEPARATOR)
    local header = MessageCore.create_color_code(Colors.HEADER)
    local key = MessageCore.create_color_code(Colors.KEYBIND_KEY)
    local spell = MessageCore.create_color_code(Colors.SPELL)

    MessageRenderer.send(1, string.format('%s=== %s%s (%s)%s alt commands ===',
        gray, header, alt, job, gray))

    if #names == 0 then
        MessageRenderer.send(1, gray .. '  (config file is empty)')
        return
    end

    for _, name in ipairs(names) do
        local entry = commands[name]
        MessageRenderer.send(1, string.format('%s  //gs c %s%-12s %s%-22s %s%s',
            gray, key, name,
            spell, action_label(entry),
            gray, target_label(entry)))
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageAltCommands
