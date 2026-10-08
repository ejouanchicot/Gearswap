---============================================================================
--- Random Deal Watch - which recast timers a Random Deal gave back
---============================================================================
--- A measuring tool, off by default (//gs c dealwatch on | off). While on,
--- this character's ability recasts are read every second; when a Corsair's
--- Random Deal or Wild Card reaches this character, the timers that were
--- waiting just before and are ready just after are listed in the chat and
--- written to <Character>/logs/rolls/random_deal.log, with who used it.
---
--- One timer can stand for several abilities (every Phantom Roll shares one,
--- so do the Waltzes): the block names the timer by the abilities that use
--- it. It reads this character only: run it on each box to compare.
---
--- The state lives on `windower` (kept across a job change, lost on
--- //lua reload gearswap); each load subscribes again when it is on.
---
--- @file shared/utils/combat/random_deal_watch.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-07
---============================================================================

local RandomDealWatch = {}

local InfoBlock = require('shared/utils/messages/info_block')
local ActionListener = require('shared/utils/core/action_listener')

local POLL = 1.0          -- seconds between two reads of the recasts
local SETTLE = 1.5        -- seconds after the ability before the recasts are compared
local WAITING = 3         -- a timer with less than this left would have ended by itself
local WATCHED = {['Random Deal'] = true, ['Wild Card'] = true}
local NAMES_SHOWN = 3     -- abilities named for one shared timer

local function state()
    windower._deal_watch = windower._deal_watch or {on = false, gen = 0, prev = {}}
    return windower._deal_watch
end

local function recasts()
    local out = {}
    for id, left in pairs(windower.ffxi.get_ability_recasts() or {}) do out[id] = left end
    return out
end

--- The game's job abilities. `res` is not a global a module can count on in
--- game (atelier_export.lua found it missing): GearSwap's own, else the library.
local function abilities()
    local ok, r = pcall(function() return (type(gearswap) == 'table' and gearswap.res) or require('resources') end)
    return ok and r and r.job_abilities or {}
end

--- Ability ids of the watched abilities, by id -> name (read once).
local watched_ids
local function watched()
    if watched_ids then return watched_ids end
    watched_ids = {}
    for id, ja in pairs(abilities()) do
        if WATCHED[ja.en] then watched_ids[id] = ja.en end
    end
    local found = watched_ids
    if next(found) == nil then watched_ids = nil end
    return found
end

--- The abilities that share a recast timer, as text.
local function timer_name(recast_id)
    local names = {}
    for _, ja in pairs(abilities()) do
        if ja.recast_id == recast_id and ja.en then names[#names + 1] = ja.en end
    end
    table.sort(names)
    if #names == 0 then return 'timer ' .. recast_id end
    if #names <= NAMES_SHOWN then return table.concat(names, ', ') end
    return ('%s (+%d on the same timer)'):format(table.concat(names, ', ', 1, NAMES_SHOWN), #names - NAMES_SHOWN)
end

local function journal(line)
    pcall(function()
        local path = require('shared/utils/core/char_paths').log('rolls', 'random_deal.log')
        local file = path and io.open(path, 'a')
        if not file then return end
        file:write(os.date('%Y-%m-%d %H:%M:%S'), ' ', line, '\n')
        file:close()
    end)
end

--- Compare the recasts read before the ability with those of now.
local function report(ability, caster, before)
    local after, back, still = recasts(), {}, 0
    for id, left in pairs(before) do
        if left >= WAITING then
            if (after[id] or 0) == 0 then back[#back + 1] = id else still = still + 1 end
        end
    end
    table.sort(back)
    local fields = {{'Used by', caster}, {'Timers given back', tostring(#back)}}
    for i, id in ipairs(back) do
        fields[#fields + 1] = {('%d. had %ds left'):format(i, before[id]), timer_name(id)}
    end
    fields[#fields + 1] = {'Still waiting', tostring(still)}
    InfoBlock.show({tag = 'DEAL', title = ability, fields = fields})
    local parts = {}
    for _, id in ipairs(back) do parts[#parts + 1] = ('%s [%d, %ds]'):format(timer_name(id), id, before[id]) end
    journal(('%s by %s: %d back, %d still waiting | %s'):format(ability, caster, #back, still, table.concat(parts, ' ; ')))
end

local function on_action(act)
    local st = state()
    if not st.on or act.category ~= 6 then return end
    local ability = watched()[act.param]
    local me = windower.ffxi.get_player()
    if not (ability and me) then return end
    local reached = false
    for _, target in ipairs(act.targets or {}) do
        if target.id == me.id then reached = true end
    end
    local mob = windower.ffxi.get_mob_by_id(act.actor_id)
    local caster, before = mob and mob.name or '?', st.prev
    -- every one seen goes to the trace (//gs c trace on), reached or not: tells a watch that saw nothing from one that
    -- was out of reach
    pcall(function()
        require('shared/utils/debug/trace_log').log('DEAL', '%s by %s, reached me: %s', ability, caster, tostring(reached))
    end)
    if not reached then return end
    coroutine.schedule(function() report(ability, caster, before) end, SETTLE)
end

--- Read the recasts every POLL seconds while on; a newer loop (next load,
--- or off then on) ends this one.
local function poll(gen)
    local st = state()
    if not st.on or st.gen ~= gen then return end
    st.prev = recasts()
    coroutine.schedule(function() poll(gen) end, POLL)
end

--- Subscribe and start reading, when the watch is on (each load).
function RandomDealWatch.init()
    local st = state()
    if not st.on then return end
    st.gen = st.gen + 1
    ActionListener.on('random_deal_watch', on_action)
    poll(st.gen)
end

--- //gs c dealwatch [on | off]
--- @param args table Words after "dealwatch"
--- @return boolean true (command handled)
function RandomDealWatch.command(args)
    local st, word = state(), args[1] and args[1]:lower()
    if word == 'on' or word == 'off' then
        st.on = word == 'on'
        st.gen = st.gen + 1
        if st.on then RandomDealWatch.init() else ActionListener.off('random_deal_watch') end
    end
    InfoBlock.show({tag = 'DEAL', title = 'Random Deal watch', fields = {
        {'Watch', st.on and 'ON' or 'OFF'},
        {'Abilities found', next(watched()) and 'yes' or 'NO (resources not read)'},
        {'Listed', 'timers a Random Deal / Wild Card gave back to you'},
        {'Journal', 'logs/rolls/random_deal.log'},
    }})
    return true
end

return RandomDealWatch
