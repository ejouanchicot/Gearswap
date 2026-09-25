---============================================================================
--- Alt Commands Message Formatter - Dual-box command listing
---============================================================================
--- Renders `//gs c altcmds`. A job config holds dozens of commands, so a flat
--- dump would scroll straight out of the chat window: with no argument this
--- prints one line per group and lets you drill in, and with an argument it
--- filters by group or by substring. Rendered with HelpScreen, in the look of
--- every help screen (//gs c commands).
---
--- @file    shared/utils/messages/formatters/ui/message_alt_commands.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2026-08-07 | Updated: 2026-08-09
---============================================================================

local MessageAltCommands = {}

local MessageCore = require('shared/utils/messages/message_core')
local HelpScreen = require('shared/utils/messages/help_screen')

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

--- Help-screen header shared by every view.
--- @param alt string Alt character name
--- @param job string Alt's current job code
--- @param subjob string|nil Alt's current subjob code
--- @param count number Number of commands being described
local function header(alt, job, subjob, count)
    local jobs = job .. (subjob and subjob ~= 'NON' and ('/' .. subjob) or '')
    HelpScreen.header('ALT COMMANDS', ('%s (%s) - %d commands'):format(alt, jobs, count))
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

--- Filtered view: the choices split by whether they need a target chosen
--- first.
--- @return table Notes to print under the list
local function show_filtered(alt, job, subjob, names, commands, filter)
    local hits = matching_names(names, commands, filter:lower())
    header(alt, job, subjob, #hits)
    if #hits == 0 then
        return {'Nothing matches "' .. filter .. '".'}
    end
    local by = { select = {}, alt = {} }
    for _, name in ipairs(hits) do
        table.insert(by[behaviour_of(commands[name])], name)
    end
    if #by.select > 0 then
        HelpScreen.group('NEEDS A TARGET', '/ta <stpc> ally, <stnpc> mob')
        HelpScreen.names(by.select)
    end
    if #by.alt > 0 then
        HelpScreen.group('ON ' .. alt:upper())
        HelpScreen.names(by.alt)
    end
    return {'//gs c <name>: ' .. alt .. ' casts it.'}
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

--- A few names of a group, cut to fit `room` with the "(count)" suffix.
local function group_sample(list, room)
    local suffix = ' (' .. #list .. ')'
    local sample = ''
    for i, name in ipairs(list) do
        local piece = sample == '' and name or (sample .. ' ' .. name)
        local more = i < #list and ' ...' or ''
        if #piece + #more + #suffix > room then
            return (sample ~= '' and sample .. ' ...' or name) .. suffix
        end
        sample = piece
    end
    return sample .. suffix
end

--- Overview: one row per group, with a few names as a hint.
--- @return table Notes to print under the list
local function show_overview(alt, job, subjob, names, commands, char)
    local buckets, sorted = group_commands(names, commands)
    header(alt, job, subjob, #names)
    HelpScreen.group('GROUPS', '//gs c altcmds <group>')
    local rows = {}
    for _, g in ipairs(sorted) do rows[#rows + 1] = {g, '', ''} end
    local col = HelpScreen.column(rows)
    for i, g in ipairs(sorted) do
        rows[i][3] = group_sample(buckets[g], MessageCore.SEPARATOR_WIDTH - col)
    end
    HelpScreen.rows(rows, col)
    -- Say where to edit. The generated file is rebuilt and would lose changes,
    -- so point at the override instead - people look for this exactly once and
    -- never remember the path.
    return {
        '//gs c <name>: ' .. alt .. ' casts it (name = spell).',
        'Search: //gs c altcmds haste',
        'Edit: ' .. (char or 'Tetsouo') .. '/config/alt/' .. job .. '_ALT_CUSTOM.lua',
    }
end

--- Names whose bare form runs on the main, so only `alt <name>` reaches the alt.
--- @param alt string Alt character name
--- @param shadowed table Sorted names (already filtered)
local function show_shadowed(alt, shadowed)
    if not shadowed or #shadowed == 0 then
        return
    end
    HelpScreen.group('//gs c alt <name>', 'the bare name runs here, not on ' .. alt)
    HelpScreen.names(shadowed)
end

function MessageAltCommands.show_list(alt, job, names, commands, filter, subjob, char, shadowed)
    shadowed = shadowed or {}
    local filtering = filter and filter ~= ''
    if filtering then
        shadowed = matching_names(shadowed, commands, filter:lower())
    end

    local notes
    if #names == 0 then
        header(alt, job, subjob, 0)
        notes = {'Nothing configured.'}
    elseif filtering then
        notes = show_filtered(alt, job, subjob, names, commands, filter)
    else
        notes = show_overview(alt, job, subjob, names, commands, char)
    end
    show_shadowed(alt, shadowed)
    HelpScreen.notes(notes)
    HelpScreen.footer()
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageAltCommands
