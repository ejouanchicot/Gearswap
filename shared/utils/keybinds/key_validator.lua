---============================================================================
--- Key Validator - catch keybind typos before Windower swallows them
---============================================================================
--- Windower never answers a `bind`: a misspelt key ("^numpd1") is dropped
--- without a word and the key simply does nothing. This checks a job's bind
--- list on load and names every entry that cannot work:
---   - key not made of modifiers (^ ! @ # ~ % $) + a known key name
---   - the same key used twice among the binds that apply (the last wins)
---   - a key with no command
---
--- A warning only: the bind is still sent, in case Windower knows a key name
--- this list does not.
---
--- @file    shared/utils/keybinds/key_validator.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-24
---============================================================================

local KeyValidator = {}

local MODIFIERS = '^!@#~%$'

local KEY_NAMES = {}
do
    local names = {
        'escape', 'esc', 'tab', 'enter', 'return', 'space', 'backspace',
        'insert', 'delete', 'home', 'end', 'pageup', 'pagedown',
        'up', 'down', 'left', 'right', 'capslock', 'numlock', 'scrolllock', 'pause',
        'numpad*', 'numpad+', 'numpad-', 'numpad.', 'numpad/', 'numpadenter',
        '-', '=', '[', ']', ';', "'", ',', '.', '/', '\\', '`',
    }
    for _, name in ipairs(names) do KEY_NAMES[name] = true end
    for i = 0, 9 do
        KEY_NAMES[tostring(i)] = true
        KEY_NAMES['numpad' .. i] = true
    end
    for i = 1, 15 do KEY_NAMES['f' .. i] = true end
    for c = string.byte('a'), string.byte('z') do KEY_NAMES[string.char(c)] = true end
end

--- Whether `key` is modifiers followed by a known key name.
--- @param key string e.g. "^numpad1"
--- @return boolean
function KeyValidator.is_valid_key(key)
    local i = 1
    while i < #key and MODIFIERS:find(key:sub(i, i), 1, true) do
        i = i + 1
    end
    return KEY_NAMES[key:sub(i):lower()] == true
end

--- Keys bound twice among the binds that apply right now. Checked on the
--- active list only: a file may reuse a key under two different subjobs.
--- Two common keys sharing a key are layers on purpose (the later one wins,
--- config/COMMON_KEYBINDS.lua): not reported, nor an override common key
--- laid over a job key on purpose.
--- @param active table Active bind entries
--- @param problems table Array appended to
local function check_duplicates(active, problems)
    local seen, seen_common = {}, {}
    for _, bind in ipairs(active or {}) do
        local key = bind.key
        if type(key) == 'string' and key ~= '' then
            if seen[key] and not (bind._common and (seen_common[key] or bind.override)) then
                problems[#problems + 1] = ('%s used twice ("%s" and "%s")'):format(key, seen[key], tostring(bind.desc))
            end
            seen[key] = tostring(bind.desc)
            seen_common[key] = bind._common == true
        end
    end
end

--- Problems in a bind list, one readable line each.
--- @param binds table Every bind entry of the file
--- @param active table|nil The entries that apply now (duplicate check)
--- @return table Array of strings (empty when all is well)
function KeyValidator.check(binds, active)
    local problems = {}
    for _, bind in ipairs(binds or {}) do
        local key, desc = bind.key, tostring(bind.desc)
        if type(key) ~= 'string' then
            problems[#problems + 1] = ('"%s": no key'):format(desc)
        elseif key ~= '' then
            if not KeyValidator.is_valid_key(key) then
                problems[#problems + 1] = ('"%s": unknown key %s'):format(desc, key)
            end
            if not bind.command or bind.command == '' then
                problems[#problems + 1] = ('"%s": key %s has no command'):format(desc, key)
            end
        end
    end
    check_duplicates(active, problems)
    return problems
end

return KeyValidator
