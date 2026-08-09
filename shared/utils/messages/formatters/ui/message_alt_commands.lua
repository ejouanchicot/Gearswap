---============================================================================
--- Alt Commands Message Formatter - Dual-box command listing
---============================================================================
--- Renders `//gs c altcmds`. A job config holds dozens of commands, so a flat
--- dump would scroll straight out of the chat window: with no argument this
--- prints one line per group and lets you drill in, and with an argument it
--- filters by group or by substring.
---
--- @file    messages/formatters/ui/message_alt_commands.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2026-08-07 | Updated: 2026-08-09
---============================================================================

local MessageAltCommands = {}

local MessageCore = require('shared/utils/messages/message_core')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')
local Colors = MessageCore.COLORS

--- Order groups so the ones you reach for first come first.
local GROUP_ORDER = {
    'enfeebling', 'enhancing', 'healing', 'elemental', 'dark',
    'geomancy', 'roll', 'ja', 'other',
}

--- Note only what departs from the norm.
---
--- Most commands act on what you selected, and repeating that on every row
--- buries the useful part. The rule is stated once above the list; a row only
--- speaks up when it does something else - going to the alt itself, say.
--- A target may also be a function evaluated at command time (a GEO Indi-
--- switches to an ally while the alt holds Entrust).
--- @param entry table Command definition
--- @param alt string Alt character name, so the line can name them
--- @return string Suffix, empty when the command follows the norm
local function target_note(entry, alt)
    local target = entry.target or 'lastst'

    if type(target) == 'function' then
        local ok, resolved = pcall(target)
        if not ok or type(resolved) ~= 'string' then
            return ' (target varies)'
        end
        target = resolved
    end

    local notes = {
        lastst = '',                                  -- the norm
        t      = ' (on your current target)',
        bt     = ' (on the mob you are fighting)',
        ft     = ' (on who you are following)',
        scan   = ' (on your scan target)',
        me     = ' (on ' .. (alt or 'the alt') .. ')',
        pet    = " (on " .. (alt or 'the alt') .. "'s pet)",
    }
    local note = notes[target:lower()]
    return note ~= nil and note or (' (target: ' .. target .. ')')
end

--- What a command will cast, as text.
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
    if entry.tiers then
        -- Show what would actually go out now, not the whole chain.
        local best, best_level = nil, -1
        for _, t in ipairs(entry.tiers) do
            local need = t.level or 1
            if need > best_level then best, best_level = t.spell, need end
        end
        return tostring(best or '?')
    end
    if type(entry.spell) == 'function' then
        return entry.desc or '(computed)'
    end
    if entry.spell_from_state then
        return 'follows ' .. entry.spell_from_state
    end
    return tostring(entry.spell or '?')
end

--- Bucket an entry, falling back to its action when it carries no group.
--- @param entry table Command definition
--- @return string Group name
local function group_of(entry)
    if entry.group then
        return entry.group
    end
    if entry.action == 'ja' then
        return (entry.spell and tostring(entry.spell):find('Roll')) and 'roll' or 'ja'
    end
    return 'other'
end

--- Print the header line shared by both views.
--- @param alt string Alt character name
--- @param job string Alt's current job code
--- @param count number Number of commands being described
local function header(alt, job, subjob, count)
    local gray = MessageCore.create_color_code(Colors.SEPARATOR)
    local hi = MessageCore.create_color_code(Colors.HEADER)
    local jobs = job .. (subjob and subjob ~= 'NON' and ('/' .. subjob) or '')
    MessageRenderer.send(1, string.format('%s=== %s%s %s(%s)%s - %d commands ===',
        gray, hi, alt, gray, jobs, gray, count))
end

--- Which job a command came from, main or sub.
--- Two jobs are loaded at once, so without this you cannot tell whether a
--- command belongs to the alt's main kit or to its subjob - which is also what
--- decides the tier you get.
--- @param entry table Command definition
--- @return string e.g. 'RDM' for a main job, '/WHM' for a subjob
local function job_label(entry)
    local job = entry.source_job or '?'
    return entry.source == 'sub' and ('/' .. job) or job
end

--- Bucket a command by what the player has to do before firing it.
--- @param entry table Command definition
--- @return string 'select' or 'alt'
local function behaviour_of(entry)
    local target = entry.target or 'lastst'
    if type(target) == 'function' then
        local ok, resolved = pcall(target)
        target = (ok and type(resolved) == 'string') and resolved or 'lastst'
    end
    target = target:lower()
    if target == 'me' or target == 'pet' then
        return 'alt'
    end
    return 'select'
end

--- Print names on as few lines as possible, wrapped to the chat width.
---
--- One line per command wastes the window: a dozen names fit on two lines, and
--- what the reader wants is the set of choices, not a table.
--- @param label string Leading label, e.g. 'on your target:'
--- @param names table Command names
--- @param width number Characters to wrap at
local function name_block(label, names, width)
    if #names == 0 then
        return
    end

    local gray = MessageCore.create_color_code(Colors.SEPARATOR)
    local key = MessageCore.create_color_code(Colors.KEYBIND_KEY)

    local line, first = '', true
    for _, n in ipairs(names) do
        if #line + #n + 1 > width then
            MessageRenderer.send(1, string.format('%s  %-16s%s%s',
                gray, first and label or '', key, line))
            line, first = '', false
        end
        line = line == '' and n or (line .. ' ' .. n)
    end
    if line ~= '' then
        MessageRenderer.send(1, string.format('%s  %-16s%s%s',
            gray, first and label or '', key, line))
    end
end

--- Display the alt's commands, grouped or filtered.
--- @param alt string Alt character name
--- @param job string Alt's current job code
--- @param names table Sorted list of command names
--- @param commands table Command definitions keyed by name
--- @param filter string|nil Group name, or a substring to search for
function MessageAltCommands.show_list(alt, job, names, commands, filter, subjob)
    local gray = MessageCore.create_color_code(Colors.SEPARATOR)
    local key = MessageCore.create_color_code(Colors.KEYBIND_KEY)

    if #names == 0 then
        header(alt, job, subjob, 0)
        MessageRenderer.send(1, gray .. '  (nothing configured)')
        return
    end

    -- Filtered view: syntax once, then the choices.
    if filter and filter ~= '' then
        local needle = filter:lower()
        local hits = {}
        for _, name in ipairs(names) do
            local entry = commands[name]
            if group_of(entry) == needle
               or name:find(needle, 1, true)
               or action_label(entry):lower():find(needle, 1, true) then
                hits[#hits + 1] = name
            end
        end

        header(alt, job, subjob, #hits)
        if #hits == 0 then
            MessageRenderer.send(1, gray .. '  nothing matches "' .. filter .. '"')
            return
        end

        MessageRenderer.send(1, string.format('%s  %s//gs c <name>%s and %s casts it.',
            gray, key, gray, alt))

        local by = { select = {}, alt = {} }
        for _, name in ipairs(hits) do
            table.insert(by[behaviour_of(commands[name])], name)
        end

        name_block('needs a target:', by.select, 58)
        name_block('on ' .. alt .. ':', by.alt, 58)

        if #by.select > 0 then
            MessageRenderer.send(1, gray ..
                '  pick it with /ta <stpc> for an ally, /ta <stnpc> for a mob')
        end
        return
    end

    -- Overview: one line per group, with a couple of names as a hint.
    local buckets, order = {}, {}
    for _, name in ipairs(names) do
        local g = group_of(commands[name])
        if not buckets[g] then
            buckets[g] = {}
            order[#order + 1] = g
        end
        table.insert(buckets[g], name)
    end

    local sorted = {}
    for _, g in ipairs(GROUP_ORDER) do
        if buckets[g] then sorted[#sorted + 1] = g end
    end
    for _, g in ipairs(order) do
        local seen = false
        for _, s in ipairs(sorted) do if s == g then seen = true end end
        if not seen then sorted[#sorted + 1] = g end
    end

    header(alt, job, subjob, #names)
    MessageRenderer.send(1, string.format('%s  %s//gs c <name>%s and %s casts it - the name IS the spell name.',
        gray, key, gray, alt))

    for _, g in ipairs(sorted) do
        local list = buckets[g]
        local sample = table.concat(list, ' ', 1, math.min(5, #list))
        if #list > 5 then sample = sample .. ' ...' end
        MessageRenderer.send(1, string.format('%s  %-16s%s%s %s(%d)',
            gray, g .. ':', MessageCore.create_color_code(Colors.SPELL), sample, gray, #list))
    end

    MessageRenderer.send(1, string.format('%s  %s//gs c altcmds <group>%s for the rest, or search: %s//gs c altcmds haste',
        gray, key, gray, key))
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageAltCommands
