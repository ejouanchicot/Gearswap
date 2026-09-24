---============================================================================
--- Alt Commands Message Formatter - Dual-box command listing
---============================================================================
--- Renders `//gs c altcmds`. A job config holds dozens of commands, so a flat
--- dump would scroll straight out of the chat window: with no argument this
--- prints one line per group and lets you drill in, and with an argument it
--- filters by group or by substring.
---
--- @file    shared/utils/messages/formatters/ui/message_alt_commands.lua
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
    'geomancy', 'song', 'ninjutsu', 'blue',
    'summon', 'rage', 'ward', 'roll', 'ja', 'other',
}

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
        -- One name instead of the whole chain: the highest tier, whatever the
        -- alt's level (AltCommands picks the tier by level when it casts).
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
--- @param subjob string|nil Alt's current subjob code
--- @param count number Number of commands being described
local function header(alt, job, subjob, count)
    local gray = MessageCore.create_color_code(Colors.SEPARATOR)
    local hi = MessageCore.create_color_code(Colors.HEADER)
    local jobs = job .. (subjob and subjob ~= 'NON' and ('/' .. subjob) or '')
    MessageRenderer.send(1, string.format('%s=== %s%s %s(%s)%s - %d commands ===',
        gray, hi, alt, gray, jobs, gray, count))
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

local function gray_code() return MessageCore.create_color_code(Colors.SEPARATOR) end
local function key_code() return MessageCore.create_color_code(Colors.KEYBIND_KEY) end

--- Commands whose group, name or action text contains the needle.
local function matching_names(names, commands, needle)
    local hits = {}
    for _, name in ipairs(names) do
        local entry = commands[name]
        if group_of(entry) == needle
           or name:find(needle, 1, true)
           or action_label(entry):lower():find(needle, 1, true) then
            hits[#hits + 1] = name
        end
    end
    return hits
end

--- Filtered view: the syntax once, then the choices split by whether they
--- need a target chosen first.
local function show_filtered(alt, job, subjob, names, commands, filter)
    local gray, key = gray_code(), key_code()
    local hits = matching_names(names, commands, filter:lower())

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
end

--- Bucket the commands by group. GROUP_ORDER comes first; any group not named
--- there follows, in the order the commands introduced it.
--- @return table buckets keyed by group
--- @return table Group names in display order
local function group_commands(names, commands)
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

    return buckets, sorted
end

--- Overview: one line per group, with a few names as a hint.
local function show_overview(alt, job, subjob, names, commands, char)
    local gray, key = gray_code(), key_code()
    local buckets, sorted = group_commands(names, commands)

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

    -- Say where to edit. The generated file is rebuilt and would lose changes,
    -- so point at the override instead - people look for this exactly once and
    -- never remember the path.
    MessageRenderer.send(1, string.format('%s  add/remove/rename: %s%s/config/alt/%s_ALT_CUSTOM.lua%s (copy the .example)',
        gray, key, char or 'Tetsouo', job, gray))
end

--- Names whose bare form runs on the main, so only `alt <name>` reaches the alt.
--- @param alt string Alt character name
--- @param shadowed table Sorted names (already filtered)
local function show_shadowed(alt, shadowed)
    if not shadowed or #shadowed == 0 then
        return
    end
    MessageRenderer.send(1, string.format('%s  %s//gs c alt <name>%s for these (the bare name runs here, not on %s):',
        gray_code(), key_code(), gray_code(), alt))
    name_block('', shadowed, 58)
end

--- Display the alt's commands, grouped or filtered.
--- @param alt string Alt character name
--- @param job string Alt's current job code
--- @param names table Sorted command names reachable as `//gs c <name>`
--- @param commands table Command definitions keyed by name
--- @param filter string|nil Group name, or a substring to search for
--- @param subjob string|nil Alt's current subjob code
--- @param char string|nil Main character name (for the config path hint)
--- @param shadowed table|nil Sorted names reachable only as `//gs c alt <name>`
function MessageAltCommands.show_list(alt, job, names, commands, filter, subjob, char, shadowed)
    shadowed = shadowed or {}
    local filtering = filter and filter ~= ''
    if filtering then
        shadowed = matching_names(shadowed, commands, filter:lower())
    end

    if #names == 0 then
        header(alt, job, subjob, 0)
        MessageRenderer.send(1, gray_code() .. '  (nothing configured)')
    elseif filtering then
        show_filtered(alt, job, subjob, names, commands, filter)
    else
        show_overview(alt, job, subjob, names, commands, char)
    end
    show_shadowed(alt, shadowed)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageAltCommands
