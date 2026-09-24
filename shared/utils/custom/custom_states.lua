---============================================================================
--- Custom States - player-made states, keys and gear, from one config file
---============================================================================
--- Lets a player add a mode without writing code. One optional file per job,
--- in the character folder: <Character>/config/<job>/<JOB>_CUSTOM.lua
---
---   return {
---       { state = 'TPMode', desc = 'TP Mode', key = '^numpad7',
---         values = {'Normal', 'Acc'},
---         Acc = { engaged = { head = "Nyame Helm" } } },
---       { state = 'Kiting', desc = 'Kiting', key = '^numpad8', values = 'onoff',
---         On = { idle = { legs = "Carmine Cuisses +1" } } },
---   }
---
--- For each entry this module:
---   1. creates the Mote state (unless the job already has one by that name:
---      then only the gear is added, e.g. extra pieces for HybridMode PDT);
---   2. adds its key to the job's keybinds (HUD, validation, guard included);
---   3. equips the gear listed under the current value ON TOP of what the
---      job picked, at the moments named: idle, engaged, weaponskill,
---      ability, precast / midcast (spells), all. A moment holds pieces
---      {slot = item} or the name of an existing set ('sets.engaged.Acc').
---
--- An entry without `state` is a rule: its gear applies whenever its `when`
--- holds (see custom_conditions.lua, custom_states_validate.lua).
---
--- The gear goes on last - after the job's own logic - through two Mote
--- hooks that run after everything else: handle_equipping_gear (idle,
--- engaged) and cleanup_precast/cleanup_midcast (actions). Slot locks
--- (disable) still win, as for any equip().
---
--- The file is read with dofile, so `gs reload` picks up an edit.
---
--- @file    shared/utils/custom/custom_states.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-24
---============================================================================

local CustomStates = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')
local Validate = require('shared/utils/custom/custom_states_validate')
local Conditions = require('shared/utils/custom/custom_conditions')
local Guards = require('shared/utils/custom/custom_guards')

---============================================================================
--- LOADING
---============================================================================

--- Path of the job's custom file for the current character.
--- @param job string
--- @return string|nil
local function custom_path(job)
    if not (player and player.name and windower and windower.addon_path) then return nil end
    return ('%sdata/%s/config/%s/%s_CUSTOM.lua'):format(windower.addon_path, player.name, job:lower(), job)
end

--- Read the job's custom file. Missing file = no custom states.
--- @param job string
--- @return table List of entries (empty when none or unreadable)
local function read_entries(job)
    local path = custom_path(job)
    if not path then return {} end
    local file = io.open(path, 'r')
    if not file then return {} end
    file:close()
    local ok, entries = pcall(dofile, path)
    if not ok then
        MessageFormatter.show_error(job .. '_CUSTOM.lua: ' .. tostring(entries))
        return {}
    end
    return type(entries) == 'table' and entries or {}
end

--- Create the Mote state of an entry unless the job already has one.
--- @param entry table
local function ensure_state(entry)
    if state[entry.state] then return end
    local desc = entry.desc or entry.state
    if entry.values == 'onoff' then
        state[entry.state] = M(false, desc)
    else
        local def = {['description'] = desc}
        for _, v in ipairs(entry.values) do def[#def + 1] = v end
        state[entry.state] = M(def)
    end
end

--- Bind entry for the job's keybind list.
--- @param entry table
--- @return table
local function bind_entry(entry)
    return {
        key = entry.key, command = 'cyclestate ' .. entry.state,
        desc = entry.desc or entry.state, state = entry.state,
        subjob = entry.subjob, exclude_subjob = entry.exclude_subjob,
        section = entry.section, custom = true,
    }
end

---============================================================================
--- GEAR
---============================================================================

--- Gear table for a moment: pieces as given, or the set a name points to.
--- @param spec table|string
--- @return table|nil
local function resolve_gear(spec)
    if type(spec) == 'table' then return spec end
    if type(spec) ~= 'string' then return nil end
    local node = _G
    for part in spec:gmatch('[^%.]+') do
        node = type(node) == 'table' and node[part] or nil
    end
    return type(node) == 'table' and node or nil
end

--- Block that applies for an entry right now, or nil.
--- A rule (no state) is its own block; a state entry uses the block named
--- after the state's current value (case-insensitive). Either may carry a
--- `when`, which must hold.
--- @param entry table
--- @param spell table|nil
--- @return table|nil
local function active_block(entry, spell)
    local block = nil
    if not entry.state then
        block = entry
    else
        local mode = state[entry.state]
        if not mode then return nil end
        local current = tostring(mode.current or mode.value):lower()
        for name, b in pairs(entry) do
            if type(name) == 'string' and name:lower() == current and type(b) == 'table' then
                block = b
                break
            end
        end
    end
    if block and Conditions.holds(block.when, spell) then return block end
    return nil
end

--- Equip every custom piece for `moments`, in file order (later wins), minus
--- the slots the guards hold back.
--- @param moments table Moment names, most general first ('all', 'engaged')
--- @param spell table|nil
local function equip_moments(moments, spell)
    local entries = _G._custom_state_entries
    if type(entries) ~= 'table' then return end
    local blocked = Guards.blocked_slots(moments[#moments], spell)
    for _, entry in ipairs(entries) do
        local block = active_block(entry, spell)
        if block then
            for _, moment in ipairs(moments) do
                local gear = resolve_gear(block[moment])
                if gear then
                    local pieces = Guards.filter(gear, blocked)
                    equip(pieces)
                    local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
                    if ok_t and Trace then
                        Trace.log('CUSTOM', '%s %s -> %s', entry.state or 'rule', moment, pieces)
                    end
                end
            end
        end
    end
end

--- Moments for an action, most general first. Midcast repeats the precast
--- moment for weaponskills and abilities: they go off with the midcast gear.
--- @param spell table
--- @param action string 'precast' or 'midcast'
--- @return table
local function action_moments(spell, action)
    if spell.type == 'WeaponSkill' then return {'all', 'weaponskill'} end
    if spell.action_type == 'Magic' then return {'all', action} end
    if spell.action_type == 'Ability' then return {'all', 'ability'} end
    return {'all'}
end

---============================================================================
--- HOOKS
---============================================================================

--- Put the gear back when a buff a condition watches comes or goes: Mote
--- does not re-equip on buff changes, so an engaged set would otherwise
--- wait for the next action to follow the buff.
--- @param buff string|number
local function on_buff_change(buff)
    local watched = _G._custom_state_buffs
    if not watched or buff == nil then return end
    if not watched[type(buff) == 'string' and buff:lower() or buff] then return end
    if type(midaction) == 'function' and midaction() then return end
    if player and (player.status == 'Idle' or player.status == 'Engaged') then
        handle_equipping_gear(player.status)
    end
end

--- Wrap Mote's handle_equipping_gear, cleanup_precast/midcast and
--- user_buff_change once per sandbox, when the job has custom entries.
--- Called from INIT_SYSTEMS, after Mote-Include has defined them: from
--- user_setup() the wrappers would be overwritten by Mote's own definitions
--- a moment later. Stored on _G, so a job reload (fresh _G) wraps again and
--- a second call in the same sandbox does not wrap twice.
function CustomStates.install_hooks()
    local entries = rawget(_G, '_custom_state_entries')
    if type(entries) ~= 'table' or #entries == 0 then return end
    if _G._custom_state_hooks and _G.handle_equipping_gear == _G._custom_state_hooks.gear then return end
    local orig_gear, orig_pre, orig_mid = handle_equipping_gear, cleanup_precast, cleanup_midcast
    local orig_buff = rawget(_G, 'user_buff_change')
    local hooks = {}
    hooks.gear = function(status, pet_status)
        if orig_gear then orig_gear(status, pet_status) end
        if Guards.hands_off(nil, nil) then return end
        equip_moments({'all', (status or player.status) == 'Engaged' and 'engaged' or 'idle'}, nil)
    end
    local function action_hook(orig, action)
        return function(spell, spellMap, eventArgs)
            if orig then orig(spell, spellMap, eventArgs) end
            if Guards.hands_off(spell, eventArgs) then return end
            equip_moments(action_moments(spell, action), spell)
        end
    end
    hooks.pre, hooks.mid = action_hook(orig_pre, 'precast'), action_hook(orig_mid, 'midcast')
    hooks.buff = function(buff, gain, eventArgs)
        if orig_buff then orig_buff(buff, gain, eventArgs) end
        on_buff_change(buff)
    end
    _G.handle_equipping_gear, _G.cleanup_precast, _G.cleanup_midcast = hooks.gear, hooks.pre, hooks.mid
    _G.user_buff_change = hooks.buff
    _G._custom_state_hooks = hooks
end

--- Buffs watched by an entry's conditions, rule or value blocks.
--- @param entry table
--- @param into table Set, filled in
local function collect_buffs(entry, into)
    Conditions.collect_buffs(entry.when, into)
    for _, block in pairs(entry) do
        if type(block) == 'table' then Conditions.collect_buffs(block.when, into) end
    end
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Load the job's custom file: create its states and add its keys to
--- `binds`. The gear is hooked later, by install_hooks(). Does nothing when
--- the file does not exist.
--- @param job string Job code ("WAR")
--- @param binds table The job's bind list, appended to
--- @return number How many custom states were loaded
function CustomStates.load(job, binds)
    -- The HUD requires the keybind file a second time: reuse this load's
    -- result instead of reading the file and warning twice.
    local cache = _G._custom_state_cache
    if cache and cache.job == job then
        for _, b in ipairs(cache.binds) do binds[#binds + 1] = b end
        return #cache.entries
    end
    local entries, added, buffs = {}, {}, {}
    for index, entry in ipairs(read_entries(job)) do
        local problems, fatal = Validate.entry(entry, state, index)
        for _, problem in ipairs(problems) do
            MessageFormatter.show_warning(job .. '_CUSTOM: ' .. problem .. (fatal and ' (skipped)' or ''))
        end
        if not fatal then
            if entry.state then ensure_state(entry) end
            collect_buffs(entry, buffs)
            if entry.state and entry.key and entry.key ~= '' then
                added[#added + 1] = bind_entry(entry)
                binds[#binds + 1] = added[#added]
            end
            entries[#entries + 1] = entry
        end
    end
    _G._custom_state_entries = entries
    _G._custom_state_buffs = buffs
    _G._custom_state_cache = {job = job, entries = entries, binds = added}
    return #entries
end

_G.CustomStates = CustomStates

return CustomStates
