---============================================================================
--- Temp Binds Parse - keys, actions and targets for //gs c tb
---============================================================================
--- Turns plain words into what Windower and the game expect, so a player
--- types no quotes, no slash, no brackets:
---
---   key     any of:  ^f1 !f2 ~f3 @f4 #f5  (Windower symbols)
---                    ctrl+f1 alt+f2 shift+f3 win+f4 apps+f5
---                    cf1 af2 sf3 wf4, cn1 = Ctrl+Numpad1 (short letters)
---           or none: the first free key is picked (see temp_binds.lua)
---   action  the longest run of leading words that names a spell, job
---           ability, weaponskill or item (game resources, any case):
---             dia ii vampire leech  ->  /ma "Dia II" + target "vampire leech"
---           Compared like the Shortcuts addon does: case, spaces and
---           punctuation ignored, digits = roman numerals, so dia2, Dia II
---           and dia ii are the same; beastmens seal is Beastmen's Seal.
---           A leading /ma, /ja, /ws or /item picks the kind when a name
---           exists as more than one (spells win otherwise). Words that
---           name no action are sent as they are (addon commands).
---   target  what follows the action: t, st, stnpc, bt, me... are the
---           game's own <t>, <st>...; anything else is a name, looked up at
---           each key press as the nearest player/NPC/monster (same lookup
---           as TradeNPC: get_mob_array, valid_target, and the distance
---           field is SQUARED). Nothing = the game's default target.
---
--- @file    shared/utils/keybinds/temp_binds_parse.lua
--- @author  Tetsouo
--- @version 1.1
--- @date    Created: 2026-09-24
---============================================================================

local Parse = {}

local KeyValidator = require('shared/utils/keybinds/key_validator')

local MODIFIER_WORDS = {ctrl = '^', alt = '!', shift = '~', win = '@', apps = '#'}
local MODIFIER_NAMES = {['^'] = 'Ctrl', ['!'] = 'Alt', ['~'] = 'Shift', ['@'] = 'Win', ['#'] = 'Apps'}

local GAME_TOKENS = {
    t = true, st = true, stnpc = true, stpc = true, stpt = true, stal = true,
    bt = true, me = true, pet = true, lastst = true, ht = true, ft = true, r = true,
}

--- Resource kinds in lookup order, with the chat command each one uses.
local KINDS = {
    {res = 'spells', verb = '/ma', slash = {['/ma'] = true, ['/magic'] = true}},
    {res = 'weapon_skills', verb = '/ws', slash = {['/ws'] = true, ['/weaponskill'] = true}},
    {res = 'job_abilities', verb = '/ja', slash = {['/ja'] = true, ['/jobability'] = true}},
    {res = 'items', verb = '/item', slash = {['/item'] = true}},
}

local LOOKUP_RANGE = 50

---============================================================================
--- KEYS
---============================================================================

local LETTER_MODIFIERS = {c = '^', a = '!', s = '~', w = '@'}

--- Whether each modifier letter appears at most once.
local function distinct(prefix)
    local seen = {}
    for c in prefix:gmatch('.') do
        if seen[c] then return false end
        seen[c] = true
    end
    return true
end

--- Short letter form: c/a/s/w prefixes then a key, n<x> = numpad<x>.
--- "cf1" -> "^f1", "caf1" -> "^!f1", "cn1" -> "^numpad1", "cc" -> "^c",
--- "a" -> "a". A letter key takes exactly one modifier, so real words
--- ("cast", "was") never read as keys; for Ctrl+Alt+C write ^!c.
--- @param text string Lower-case text
--- @return string|nil
local function letter_key(text)
    for i = #text - 1, 0, -1 do
        local prefix, rest = text:sub(1, i), text:sub(i + 1)
        local letter_key_ok = not rest:match('^%a$') or #prefix <= 1
        if prefix:match('^[casw]*$') and rest ~= '' and distinct(prefix) and letter_key_ok then
            rest = rest:gsub('^n([%d%.%+%-%*/])$', 'numpad%1')
            local key = prefix:gsub('.', LETTER_MODIFIERS) .. rest
            if KeyValidator.is_valid_key(key) then return key end
        end
    end
    return nil
end

--- Windower key from what the player typed: "^f1", "ctrl+f1", "cf1", "F3".
--- @param text string
--- @return string|nil Windower form, nil when not a valid key
function Parse.key(text)
    if type(text) ~= 'string' or text == '' then return nil end
    local key, prefix = text:lower(), ''
    for word, symbol in pairs(MODIFIER_WORDS) do
        while key:find(word .. '%+') do
            key = key:gsub(word .. '%+', '', 1)
            prefix = prefix .. symbol
        end
    end
    key = prefix .. key
    if KeyValidator.is_valid_key(key) then return key end
    return letter_key(text:lower())
end

--- Whether a word was meant as a key even though it is not a valid one
--- ("ctrl+fx", "^f13", "cf13"), so it is reported instead of being taken
--- for the start of a command.
--- @param text string
--- @return boolean
function Parse.looks_like_key(text)
    local t = (text or ''):lower()
    return t:find('+', 1, true) ~= nil or t:match('^[%^!~@#]') ~= nil
        or t:match('^[casw]*f%d+$') ~= nil or t:match('^[casw]*n[%d%.%+%-%*/]$') ~= nil
end

--- Readable form of a Windower key: "^!f1" -> "Ctrl+Alt+F1".
--- @param key string
--- @return string
function Parse.show_key(key)
    local i, parts = 1, {}
    while i < #key and MODIFIER_NAMES[key:sub(i, i)] do
        parts[#parts + 1] = MODIFIER_NAMES[key:sub(i, i)]
        i = i + 1
    end
    local name = key:sub(i)
    parts[#parts + 1] = name:match('^numpad') and ('Numpad' .. name:sub(7)) or name:upper()
    return table.concat(parts, '+')
end

---============================================================================
--- ACTIONS
---============================================================================

--- lower-case name -> proper name, per resource kind (built once).
local name_maps = nil

local function resources()
    return rawget(_G, 'res') or (windower and windower.res) or require('resources')
end

local ROMAN = {{10, 'x'}, {9, 'ix'}, {5, 'v'}, {4, 'iv'}, {1, 'i'}}

--- 12 -> "xii" (game names only go up to small numbers).
local function to_roman(digits)
    local n, out = tonumber(digits), ''
    if not n or n < 1 or n > 39 then return digits end
    for _, pair in ipairs(ROMAN) do
        while n >= pair[1] do out, n = out .. pair[2], n - pair[1] end
    end
    return out
end

--- Name as compared, the way the Shortcuts addon slugs names: letters and
--- digits only, lower case, digits as roman numerals - so "dia2", "Dia II"
--- and "dia ii" are all "diaii", and "beastmens seal" is "Beastmen's Seal".
local function norm(text)
    return (text:lower():gsub('[^%w]', ''):gsub('%d+', to_roman))
end

local function build_maps()
    if name_maps then return name_maps end
    name_maps = {}
    local res = resources()
    for _, kind in ipairs(KINDS) do
        local map = {}
        for _, entry in pairs(res[kind.res] or {}) do
            if type(entry) == 'table' and entry.en then
                map[norm(entry.en)] = map[norm(entry.en)] or entry.en
                if entry.enl then map[norm(entry.enl)] = map[norm(entry.enl)] or entry.en end
            end
        end
        name_maps[kind.res] = map
    end
    return name_maps
end

--- Longest leading run of `words` naming an action of the allowed kinds.
--- @param words table Words to scan (already stripped of quotes)
--- @param only_verb string|nil Leading slash command that restricts the kind
--- @return string|nil verb, string|nil name, number used words
local function find_action(words, only_verb)
    local maps = build_maps()
    for n = #words, 1, -1 do
        local candidate = norm(table.concat(words, ' ', 1, n))
        for _, kind in ipairs(KINDS) do
            if (not only_verb or kind.slash[only_verb]) and maps[kind.res][candidate] then
                return kind.verb, maps[kind.res][candidate], n
            end
        end
    end
    return nil, nil, 0
end

--- Stored form of what follows the key.
--- @param words table Words after the key
--- @return string|nil command, string|nil error
function Parse.command(words)
    if #words == 0 then return nil, 'nothing after the key' end
    local list, only_verb = {}, nil
    for i, w in ipairs(words) do list[i] = (w:gsub('"', '')) end
    if list[1]:sub(1, 1) == '/' then
        only_verb = list[1]:lower()
        table.remove(list, 1)
    end
    local verb, name, used = find_action(list, only_verb)
    if not verb then
        if only_verb then return nil, 'no action of that kind is named "' .. table.concat(list, ' ') .. '"' end
        return table.concat(words, ' ')
    end
    local target = table.concat(list, ' ', used + 1)
    local command = ('input %s "%s"'):format(verb, name)
    if target ~= '' then command = command .. ' {' .. target .. '}' end
    return command
end

---============================================================================
--- TARGETS (resolved at each key press)
---============================================================================

--- Nearest valid, living mob named `name` (case-insensitive), within range.
local function nearest_named(name)
    local wanted, best, best_dist = name:lower(), nil, LOOKUP_RANGE
    for _, mob in pairs(windower.ffxi.get_mob_array() or {}) do
        if mob and mob.name and mob.name:lower() == wanted and mob.valid_target
            and not (mob.hpp == 0 and not mob.is_npc) then
            local dist = math.sqrt(mob.distance or 0)
            if dist < best_dist then best, best_dist = mob, dist end
        end
    end
    return best
end

--- The stored command, ready to send: {t} -> <t>, {name} -> mob id.
--- @param command string
--- @return string|nil command, string|nil missing Name not found nearby
function Parse.resolve(command)
    local missing = nil
    local resolved = command:gsub('{([^{}]+)}', function(inner)
        if GAME_TOKENS[inner:lower()] then return '<' .. inner:lower() .. '>' end
        local mob = nearest_named(inner)
        if not mob then
            missing = missing or inner
            return ''
        end
        -- A raw mob id goes out without angle brackets; only named tokens
        -- (<t>, <me>...) take them.
        return tostring(mob.id)
    end)
    if missing then return nil, missing end
    return resolved
end

--- Readable form of a stored command, for messages and the list.
--- 'input /ma "Dia II" {vampire leech}' -> '/ma "Dia II" > vampire leech'
--- @param command string
--- @return string
function Parse.show_command(command)
    return (command:gsub('^input ', ''):gsub(' {([^{}]+)}$', ' > %1'))
end

return Parse
