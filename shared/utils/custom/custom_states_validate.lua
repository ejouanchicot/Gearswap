---============================================================================
--- Custom States Validate - plain-language checks of a <JOB>_CUSTOM.lua entry
---============================================================================
--- The file is written by players, not programmers: every mistake has to be
--- named in chat, with what to fix, instead of silently doing nothing.
---
--- Two kinds of entry:
---   mode  { state = 'Name', values = ..., <Value> = { <moment> = gear, when = {...} } }
---   rule  { when = {...}, <moment> = gear }            (no state, no key)
---
--- Fatal (entry skipped): not a block, bad state name, new state without
--- values, rule without `when`. Everything else is a warning.
---
--- @file    shared/utils/custom/custom_states_validate.lua
--- @author  Tetsouo
--- @version 1.1
--- @date    Created: 2026-09-24
---============================================================================

local Validate = {}

-- Keys are checked with the job's other keys (key_validator.lua), at bind time.
local Conditions = require('shared/utils/custom/custom_conditions')
local SLOT_IDS = Conditions.SLOT_IDS

local STATE_FIELDS = {
    state = true, desc = true, key = true, values = true, subjob = true,
    exclude_subjob = true, section = true,
}
local MOMENTS = {
    idle = true, engaged = true, weaponskill = true, ability = true,
    precast = true, midcast = true, all = true,
}
local MOMENT_LIST = 'idle, engaged, weaponskill, ability, precast, midcast, all'
local SECTIONS = {mode = true, spell = true, ability = true, weapon = true}

--- Expected type of each condition value ('list' = string/number or a list).
local WHEN_TYPES = {
    buff = 'list', no_buff = 'list', weapon = 'list', sub = 'list', range = 'list',
    ammo = 'list', subjob = 'list', no_subjob = 'list', spell = 'list', skill = 'list',
    spell_type = 'list', element = 'list', target = 'list', zone = 'list',
    mode = 'table', hp_below = 'number', hp_above = 'number', mp_below = 'number',
    mp_above = 'number', tp_below = 'number', tp_above = 'number',
    distance_below = 'number', day_weather = 'boolean', town = 'boolean',
    moving = 'boolean', pet = 'boolean',
}

--- Weapon slots: swapping them in combat throws the TP away.
local WEAPON_SLOTS = {[0] = true, [1] = true, [2] = true}
local COMBAT_MOMENTS = {engaged = true, weaponskill = true, ability = true, all = true}

local function add(problems, fmt, ...)
    problems[#problems + 1] = fmt:format(...)
end

--- Check a `when` table.
--- @param where string
--- @param when any
--- @param problems table
local function check_when(where, when, problems)
    if type(when) ~= 'table' then
        return add(problems, '%s: when must be { ... }', where)
    end
    for key, value in pairs(when) do
        local expected = WHEN_TYPES[key]
        local t = type(value)
        if not expected then
            add(problems, '%s: unknown condition "%s" - this gear will never go on', where, tostring(key))
        elseif expected == 'list' and t ~= 'string' and t ~= 'number' and t ~= 'table' then
            add(problems, '%s: %s expects a name or a list of names', where, key)
        elseif expected ~= 'list' and t ~= expected then
            add(problems, '%s: %s expects %s', where, key,
                expected == 'table' and "{ StateName = 'Value' }" or expected)
        end
    end
end

--- Check one gear block ({engaged = {...}, idle = 'sets.x', when = {...}}).
--- @param where string
--- @param block table
--- @param problems table
local function check_block(where, block, problems)
    for moment, gear in pairs(block) do
        if moment == 'when' then
            check_when(where, gear, problems)
        elseif not MOMENTS[moment] then
            add(problems, '%s: "%s" is not a moment (%s)', where, tostring(moment), MOMENT_LIST)
        elseif type(gear) == 'table' then
            for slot in pairs(gear) do
                local id = SLOT_IDS[tostring(slot)]
                if id == nil then
                    add(problems, '%s %s: "%s" is not a gear slot', where, moment, tostring(slot))
                elseif WEAPON_SLOTS[id] and COMBAT_MOMENTS[moment] then
                    add(problems, '%s %s: changing %s in combat loses your TP', where, moment, slot)
                end
            end
        elseif type(gear) ~= 'string' then
            add(problems, '%s %s: expected pieces {head = "..."} or a set name "sets.x"', where, moment)
        end
    end
end

--- Value names of a mode entry, lower-cased, as a set.
local function value_names(entry, existing)
    local names = {}
    local list = existing or (type(entry.values) == 'table' and entry.values) or {}
    for _, v in ipairs(list) do names[tostring(v):lower()] = true end
    if entry.values == 'onoff' or (existing and existing._type == 'boolean') then
        names.on, names.off = true, true
    end
    return next(names) and names or nil
end

--- Check the fields and value blocks of a mode entry.
local function check_mode(entry, existing, problems)
    local label, names = entry.state, value_names(entry, existing)
    for field, block in pairs(entry) do
        if type(field) ~= 'string' then
            add(problems, '%s: unexpected unnamed value in the entry', label)
        elseif not STATE_FIELDS[field] then
            if type(block) ~= 'table' then
                add(problems, '%s: unknown field "%s"', label, field)
            elseif names and not names[field:lower()] then
                add(problems, '%s: "%s" is not one of its values', label, field)
            else
                check_block(label .. ' ' .. field, block, problems)
            end
        end
    end
    if entry.section ~= nil and not SECTIONS[entry.section] then
        add(problems, '%s: section must be mode, spell, ability or weapon', label)
    end
end

--- Check one entry of a custom file.
--- @param entry any
--- @param states table The job's `state` table
--- @param index number|nil Position in the file, for rule messages
--- @return table problems Readable lines
--- @return boolean fatal True when the entry cannot be loaded
function Validate.entry(entry, states, index)
    if type(entry) ~= 'table' then return {'an entry is not a { ... } block'}, true end
    if entry.state == nil then
        local where = 'rule #' .. tostring(index or '?')
        if entry.when == nil then return {where .. ": needs a state = 'Name' or a when = { ... }"}, true end
        local problems = {}
        check_block(where, entry, problems)
        return problems, false
    end
    if type(entry.state) ~= 'string' or not entry.state:match('^%a[%w_]*$') then
        return {('state name "%s" must be one word, letters/digits/_'):format(tostring(entry.state))}, true
    end
    local existing = states and states[entry.state]
    local problems = {}
    if existing and entry.values then
        add(problems, '%s: the job already has this state, "values" is ignored', entry.state)
    elseif not existing and entry.values ~= 'onoff'
        and (type(entry.values) ~= 'table' or #entry.values == 0) then
        return {entry.state .. ": needs values = {'A', 'B'} or values = 'onoff'"}, true
    end
    check_mode(entry, existing, problems)
    return problems, false
end

return Validate
