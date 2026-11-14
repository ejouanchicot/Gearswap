---============================================================================
--- Party Callouts - this character's Stun and Absorb-TP told in party chat
---============================================================================
--- Each spell of the list that this character lands (or sees resisted) on a
--- monster becomes one short plain-ASCII line in party chat, for the players
--- who cannot see the alt's log:
---
---   Stun > Degei: STUNNED            Stun > Degei: STUNNED (MB)
---   Stun > Degei: RESISTED           Stun > Degei: NO EFFECT
---   Absorb-TP > Aminon: -387 TP      Absorb-TP > Aminon: RESISTED
---   Fire > Degei (after Icy Grasp): 1520 dmg
---   Water > Degei (after Flaming Kick): ABSORBED +840 HP
---
--- A spell cast within AFTER_WINDOW seconds of the monster's TP move names that
--- move (the elemental answers of the Melee / Aita profiles: Icy Grasp -> Fire...).
---
--- On with a list of spells in the job's config (GEO: geo/combat/GEO_CONFIG.lua
--- `party_callouts = {'Stun', 'Absorb-TP'}`, {} = off; asked by the player for
--- Kaories, 2026-11-13). Read from the game's action packet (category 4: a
--- spell's end): the message ids are the ones the Sortie logs show for her
--- (SortieLog: 454 TP drained, 753 the same in a Magic Burst, 236 / 271 status,
--- 85 / 284 / 655 / 656 resists, 75 no effect). Party chat goes out with
--- `input /p`; nothing goes to the own chat log. The packets come through
--- shared/utils/core/action_listener.lua (as the server sent them, before
--- Battlemod rewrites them), subscribed again at every load. Each spell of the
--- list seen goes to the trace (tag CALLOUT) with its message id, told or not.
---
--- @file    shared/utils/messages/party_callouts.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-13
---============================================================================

local PartyCallouts = {}

local SPELL_END = 4       -- action category: a spell's end
local MONSTER = 16        -- spawn_type of a monster

-- message id -> what it says, per kind of spell
local RESULTS = {
    [236] = 'STUNNED', [271] = 'STUNNED (MB)',
    [85] = 'RESISTED', [284] = 'RESISTED', [655] = 'RESISTED', [656] = 'RESISTED',
    [75] = 'NO EFFECT',
}
local TP_DRAINED = {[454] = '', [753] = ' (MB)'}
local DAMAGE = {[2] = '', [252] = ' (MB)'}
local HEALED = {[7] = true, [263] = true}        -- the monster absorbs the element
local MOB_TP_MOVE = 11                           -- action category: a monster's TP move, done
local AFTER_WINDOW = 15                          -- seconds a TP move is named in the next spell's line

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('CALLOUT', fmt, unpack(args)) end)
end

--- The party line for one spell's result, or nil when there is nothing to tell.
--- @param spell string Spell name
--- @param target string Monster name
--- @param message number Action message id
--- @param param number|nil The message's number (TP drained, damage, HP)
--- @param after string|nil The monster's TP move just before, named in the line
--- @return string|nil
function PartyCallouts.line(spell, target, message, param, after)
    local result
    if TP_DRAINED[message] then
        result = ((param or 0) > 0 and ('-%d TP'):format(param) or 'no TP to take') .. TP_DRAINED[message]
    elseif DAMAGE[message] then
        result = ('%d dmg'):format(param or 0) .. DAMAGE[message]
    elseif HEALED[message] then
        result = ('ABSORBED +%d HP'):format(param or 0)
    else
        result = RESULTS[message]
    end
    if not result then return nil end
    -- plain ASCII only: a '<' would be read as a chat token (<t>, <me>), a ';' would end the command
    local text = ('%s > %s%s: %s'):format(spell, target, after and (' (after ' .. after .. ')') or '', result)
    return (text:gsub('[^\32-\126]', ''):gsub('[<;]', ''))
end

--- The spells to tell, from the job's config: a set of names, nil when off.
--- @param job string Main job (config of that job)
--- @return table|nil
function PartyCallouts.wanted(job)
    local ok, list = pcall(function() return require('shared/utils/core/job_config').get(job, 'party_callouts', {}) end)
    if not (ok and type(list) == 'table' and #list > 0) then return nil end
    local set = {}
    for _, name in ipairs(list) do set[name] = true end
    return set
end

--- The lines of one action packet: this character's spells of `wanted` on monsters.
--- @param act table windower 'action' event table
--- @param my_id number This character's id
--- @param wanted table Set of spell names
--- @param deps table spells (resources), mob_by_id, after(mob_id) -> its recent TP move name or nil
--- @return table Array of lines
function PartyCallouts.lines(act, my_id, wanted, deps)
    local out = {}
    if not (act and act.actor_id == my_id and act.category == SPELL_END) then return out end
    local spell = deps.spells[act.param]
    if not (spell and wanted[spell.en]) then return out end
    for _, target in ipairs(act.targets or {}) do
        local mob = deps.mob_by_id(target.id)
        local action = target.actions and target.actions[1]
        if mob and mob.spawn_type == MONSTER and action then
            local after = deps.after and deps.after(target.id) or nil
            local line = PartyCallouts.line(spell.en, mob.name or '?', action.message, action.param, after)
            trace('%s on %s: message %s param %s -> %s', spell.en, tostring(mob.name), tostring(action.message),
                tostring(action.param), line or 'nothing told')
            if line then out[#out + 1] = line end
        end
    end
    return out
end

--- GearSwap's own resources (not require('resources') in the sandbox: see trace_hooks.lua).
local function spells()
    local gs = rawget(_G, 'gearswap')
    local r = rawget(_G, 'res') or (type(gs) == 'table' and gs.res)
    return type(r) == 'table' and r.spells or {}
end

--- A monster TP move's name (GearSwap's monster_abilities), nil when unknown.
--- @param id number Ability id of the action packet
--- @return string|nil
function PartyCallouts.move_name(id)
    local gs = rawget(_G, 'gearswap')
    local r = rawget(_G, 'res') or (type(gs) == 'table' and gs.res)
    local entry = type(r) == 'table' and r.monster_abilities and r.monster_abilities[id]
    return entry and entry.en or nil
end

--- This character's id, read at each action (still nil while logging in or zoning at the load).
local function my_id()
    local me = windower.ffxi.get_player()
    return me and me.id
end

--- Start telling, at each load, when the job's config lists spells.
--- @param job string Main job
function PartyCallouts.listen(job)
    local wanted = PartyCallouts.wanted(job)
    if not wanted then return end
    local moves = {}                     -- monster id -> {name, at}: its last TP move, this load
    local deps = {spells = spells(), mob_by_id = windower.ffxi.get_mob_by_id}
    function deps.after(id)
        local m = moves[id]
        return m and os.clock() - m.at <= AFTER_WINDOW and m.name or nil
    end
    require('shared/utils/core/action_listener').on('party_callouts', function(act)
        if act.category == MOB_TP_MOVE then
            local ability = PartyCallouts.move_name(act.param)
            if ability then moves[act.actor_id] = {name = ability, at = os.clock()} end
            return
        end
        if act.category ~= SPELL_END then return end
        for _, line in ipairs(PartyCallouts.lines(act, my_id(), wanted, deps)) do
            send_command('input /p ' .. line)
        end
    end)
    trace('on for %s', job)
end

_G.PartyCallouts = PartyCallouts

return PartyCallouts
