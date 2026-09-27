---============================================================================
--- Key Conflicts - two actions on one key, told instead of silently lost
---============================================================================
--- A job's key list holds its own keys, the player's custom keys
--- (<JOB>_CUSTOM.lua), Combat Mode and the character's common keys
--- (config/COMMON_KEYBINDS.lua: subjob and partner layers). Only one command
--- can sit on a key; when two entries apply at once, one of them does
--- nothing. Which one wins (KeybindManager lays the keys in list order):
---   - a common entry without `override` yields to a job / custom entry;
---   - otherwise the later entry in the list is the one bound.
--- The keys are never changed here: conflicts are only reported.
---
--- What counts as a conflict, by kind of entry (job = job file, custom keys,
--- Combat Mode; own = common key for this character; partner = common key
--- with an `alt` condition):
---   job / job, job / own, job / partner, own / partner   reported
---   own / own          not reported: a common key and its subjob version
---                      (Prism Powder, /NIN Tonko: Ni) are layers on purpose
---   partner / partner  not reported: layers of the partner's own keys
---   same command twice not reported: nothing is lost
---
---   live(active, yielded)  conflicts right now (current subjob, partner,
---                          weapon), one per key: {key, bound, lost = {...}}
---   possible(binds)        every pair of entries on one key that can apply
---                          together, over all subjobs and partner jobs
---   report(job, list, told)  one chat warning per conflict and per load
---   show_possible(job, binds)  //gs c keyconflicts
---
--- @file    shared/utils/keybinds/key_conflicts.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-27
---============================================================================

local KeyConflicts = {}

local SUBJOBS = {'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG',
    'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN'}

local function keyed(bind)
    return type(bind.key) == 'string' and bind.key ~= '' and bind.command ~= nil
end

local function kind(bind)
    if not bind._common then return 'job' end
    return type(bind.alt) == 'table' and 'partner' or 'own'
end

--- Whether two entries on one key are a conflict (see the header).
--- @param a table
--- @param b table
--- @return boolean
function KeyConflicts.counts(a, b)
    if a.command == b.command and (a.raw and true) == (b.raw and true) then return false end
    local ka, kb = kind(a), kind(b)
    if ka == 'job' or kb == 'job' then return true end
    return ka ~= kb
end

--- A common entry without override gives way to a job or custom entry.
--- @param bind table
--- @return boolean
function KeyConflicts.yields(bind)
    return bind._common == true and not bind.override
end

---============================================================================
--- LIVE CONFLICTS
---============================================================================

--- Conflicts among the entries that apply now.
--- @param active table Entries bound now, in list order
--- @param yielded table|nil Common entries dropped for a job key (get_active_binds)
--- @return table Array of {key, bound, lost}, in key order of appearance
function KeyConflicts.live(active, yielded)
    local by_key, order = {}, {}
    local function add(key, bind, is_bound)
        local c = by_key[key]
        if not c then
            c = {key = key, lost = {}}
            by_key[key] = c
            order[#order + 1] = key
        end
        if is_bound then
            if c.bound then c.lost[#c.lost + 1] = c.bound end
            c.bound = bind
        else
            c.lost[#c.lost + 1] = bind
        end
    end
    for _, bind in ipairs(active or {}) do
        if keyed(bind) then add(bind.key, bind, true) end
    end
    for _, bind in ipairs(yielded or {}) do
        if keyed(bind) then add(bind.key, bind, false) end
    end
    local found = {}
    for _, key in ipairs(order) do
        local c = by_key[key]
        local lost = {}
        for _, bind in ipairs(c.lost) do
            if KeyConflicts.counts(c.bound, bind) then lost[#lost + 1] = bind end
        end
        if #lost > 0 then
            c.lost = lost
            found[#found + 1] = c
        end
    end
    return found
end

---============================================================================
--- POSSIBLE CONFLICTS (all subjobs, all partner jobs)
---============================================================================

local function norm(value)
    return tostring(value):lower():gsub('%s', '')
end

--- Set of normalized names from a string / list rule, nil = anything.
local function name_set(rule)
    if rule == nil then return nil end
    local set = {}
    for _, value in ipairs(type(rule) == 'table' and rule or {rule}) do set[norm(value)] = true end
    return set
end

--- Whether two name sets (nil = anything) share a value.
local function overlap(a, b)
    if a == nil or b == nil then return true end
    for value in pairs(a) do
        if b[value] then return true end
    end
    return false
end

--- Subjobs under which a bind applies.
--- @param bind table
--- @return table Set of subjob codes
local function subjobs_of(bind)
    local only, never = name_set(bind.subjob), name_set(bind.exclude_subjob) or {}
    local set = {}
    for _, code in ipairs(SUBJOBS) do
        local key = norm(code)
        if (only == nil or only[key]) and not never[key] then set[code] = true end
    end
    return set
end

--- Whether two `alt` conditions can hold together: two named partners can
--- both be there; one partner cannot play two jobs at once.
local function alts_compatible(a, b)
    if type(a) ~= 'table' or type(b) ~= 'table' then return true end
    if a.name and b.name and norm(a.name) ~= norm(b.name) then return true end
    return overlap(name_set(a.job), name_set(b.job))
        and overlap(name_set(a.subjob), name_set(b.subjob))
        and overlap(name_set(a.weapon), name_set(b.weapon))
end

--- Subjobs under which both binds apply (empty when they never meet).
local function shared_subjobs(a, b)
    if not overlap(name_set(a.weapon), name_set(b.weapon)) then return {} end
    if not alts_compatible(a.alt, b.alt) then return {} end
    local sa, sb, both = subjobs_of(a), subjobs_of(b), {}
    for _, code in ipairs(SUBJOBS) do
        if sa[code] and sb[code] then both[#both + 1] = code end
    end
    return both
end

--- Which of two entries (a before b in the list) is bound when both apply.
local function winner(a, b)
    if KeyConflicts.yields(b) and not a._common then return a, b end
    return b, a
end

--- Every pair of entries on one key that can apply at the same time.
--- @param binds table The job's full key list (module.binds)
--- @return table Array of {key, bound, lost, subjobs}
function KeyConflicts.possible(binds)
    local found = {}
    for i = 1, #(binds or {}) do
        local a = binds[i]
        for j = i + 1, #binds do
            local b = binds[j]
            if keyed(a) and keyed(b) and a.key == b.key and KeyConflicts.counts(a, b) then
                local subjobs = shared_subjobs(a, b)
                if #subjobs > 0 then
                    local bound, lost = winner(a, b)
                    found[#found + 1] = {key = a.key, bound = bound, lost = lost, subjobs = subjobs}
                end
            end
        end
    end
    return found
end

---============================================================================
--- DISPLAY
---============================================================================

local function key_name(key)
    local ok, MessageCore = pcall(require, 'shared/utils/messages/message_core')
    if ok and MessageCore and MessageCore.convert_key_display then return MessageCore.convert_key_display(key) end
    return key
end

local function label(bind)
    return tostring(bind.desc or bind.state or bind.command)
end

--- Label cut for one chat line, with the partner / weapon condition when
--- the label does not already name it.
local function short(bind)
    local text = label(bind)
    if #text > 40 then text = text:sub(1, 38) .. '..' end
    local parts = {}
    local alt = bind.alt
    if type(alt) == 'table' and not (alt.name and text:lower():find(alt.name:lower(), 1, true)) then
        local list = function(v) return type(v) == 'table' and table.concat(v, '/') or v end
        parts[#parts + 1] = ((alt.name or 'partner') .. ' ' .. (list(alt.job) or '')
            .. (alt.subjob and ('/' .. list(alt.subjob)) or '')):gsub('%s+$', '')
    end
    if bind.weapon then
        parts[#parts + 1] = type(bind.weapon) == 'table' and table.concat(bind.weapon, '/') or tostring(bind.weapon)
    end
    if type(bind.visible) == 'function' then parts[#parts + 1] = 'when shown' end
    return #parts > 0 and (text .. ' (' .. table.concat(parts, ', ') .. ')') or text
end

--- "all subjobs", "/WAR", "/WAR /DRK", "21 subjobs".
local function subjob_text(list)
    if #list == #SUBJOBS then return 'all subjobs' end
    if #list > 6 then return ('%d subjobs'):format(#list) end
    return '/' .. table.concat(list, ' /')
end

--- Warn once per load for each conflict of `list` (live()), in one block:
--- "Key / Bound / Lost" per conflict, long values wrapped at the chat width.
--- @param job string
--- @param list table
--- @param told table Signatures already told (kept by the caller for the load)
function KeyConflicts.report(job, list, told)
    local fields = {}
    for _, c in ipairs(list) do
        local lost = {}
        for _, bind in ipairs(c.lost) do lost[#lost + 1] = label(bind) end
        local id = c.key .. '|' .. tostring(c.bound.command) .. '|' .. table.concat(lost, ',')
        if not told[id] then
            told[id] = true
            fields[#fields + 1] = {'Key', key_name(c.key), 'warn'}
            fields[#fields + 1] = {'Bound', label(c.bound)}
            fields[#fields + 1] = {'Does nothing', table.concat(lost, ' / '), 'bad'}
        end
    end
    if #fields == 0 then return end
    require('shared/utils/messages/info_block').show({
        tag = 'KEYS', title = job .. ' key conflict', fields = fields,
        lines = {{'Keys unchanged. All possible conflicts: //gs c kc', 'dim'}},
    })
end

--- Pairs of possible() grouped: one field per key, lost entry and subjobs,
--- listing everything that can take the key from it ("A < B": B takes it).
--- @param list table possible()
--- @return table InfoBlock fields {key, text, 'warn'}
local function grouped_fields(list)
    local groups, order = {}, {}
    for _, c in ipairs(list) do
        local id = c.key .. '|' .. tostring(c.lost) .. '|' .. table.concat(c.subjobs, ',')
        if not groups[id] then
            groups[id] = {c = c, winners = {}}
            order[#order + 1] = id
        end
        local winners = groups[id].winners
        winners[#winners + 1] = short(c.bound)
    end
    local fields = {}
    for _, id in ipairs(order) do
        local g = groups[id]
        fields[#fields + 1] = {key_name(g.c.key), ('[%s] %s < %s'):format(subjob_text(g.c.subjobs),
            short(g.c.lost), table.concat(g.winners, ' | ')), 'warn'}
    end
    return fields
end

--- //gs c keyconflicts: every conflict this job's keys can run into.
--- @param job string
--- @param binds table The job's full key list
function KeyConflicts.show_possible(job, binds)
    local fields = grouped_fields(KeyConflicts.possible(binds))
    local spec = {tag = 'KEYS', title = job .. ' key conflicts, all subjobs', fields = fields}
    if #fields == 0 then
        spec.lines = {{'No two keys can apply at once, on any subjob.', 'dim'}}
    else
        spec.lines = {{'"A < B": B takes the key while both apply. Keys unchanged.', 'dim'}}
    end
    require('shared/utils/messages/info_block').show(spec)
end

return KeyConflicts
