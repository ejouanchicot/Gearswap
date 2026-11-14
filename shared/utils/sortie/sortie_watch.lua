---============================================================================
--- Sortie Watch - the fight starts by itself once the target's monster is claimed
---============================================================================
--- A target with `auto_fight = true` and a `mob` (Tetsouo/_common/tools/
--- SORTIE_CONFIG.lua): //gs c sortie <target> loads the prep profile as before,
--- then watches for that monster. Once one of that name is claimed by this party
--- or alliance (the tank's Flash: nobody engages, the monster's own claim is what
--- counts), it runs //gs c sortie <target> fight once, as if typed. Several of
--- that name around (Vampire Leech): the first one seen claimed.
---
--- The party's claim only: a monster fighting another group nearby never starts
--- the fight. A monster of that name already claimed when the prep is typed (a
--- Leech of the pull before still alive) never starts it either: only a new claim.
--- The monster's id goes with the fight, so the alt goes behind that one.
---
--- Stops: on firing, on any other //gs c sortie command (another target, fight
--- typed by hand, escort, off), on a zone change, after WATCH_LIMIT, and on a
--- newer GearSwap load (a job or subjob change of this character: type the prep
--- macro again). Every step goes to the trace (//gs c trace, tag SORTIE).
---
--- @file    shared/utils/sortie/sortie_watch.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-13
---============================================================================

local SortieWatch = {}

local TICK = 0.5            -- seconds between two looks
local WATCH_LIMIT = 1800    -- seconds: a watch nobody fired ends (a forgotten prep)
local MONSTER = 16          -- spawn_type of a monster

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('SORTIE', fmt, unpack(args)) end)
end

--- Ids of this party and alliance (p0-p5, a10-a15, a20-a25).
--- @param party table|nil windower.ffxi.get_party()
--- @return table Set of ids
function SortieWatch.alliance_ids(party)
    local ids = {}
    for key, member in pairs(party or {}) do
        if type(key) == 'string' and key:match('^[pa]%d+$') and type(member) == 'table' then
            local id = member.mob and member.mob.id or member.id
            if id then ids[id] = true end
        end
    end
    return ids
end

--- The living monsters of that name claimed by one of `ids`, the ids in `skip` left out.
--- @param name string Monster name (any case)
--- @param mobs table Mob array
--- @param ids table Set of party / alliance ids
--- @param skip table|nil Set of monster ids to leave out
--- @return table Array of mobs
function SortieWatch.claimed(name, mobs, ids, skip)
    name, skip = name:lower(), skip or {}
    local out = {}
    for _, mob in pairs(mobs or {}) do
        if type(mob) == 'table' and mob.spawn_type == MONSTER and (mob.hpp or 0) > 0
                and type(mob.name) == 'string' and mob.name:lower() == name
                and mob.claim_id and ids[mob.claim_id] and not skip[mob.id] then
            out[#out + 1] = mob
        end
    end
    return out
end

local function claimed_now(name, skip)
    return SortieWatch.claimed(name, windower.ffxi.get_mob_array(), SortieWatch.alliance_ids(windower.ffxi.get_party()), skip)
end

local function look(st)
    local info = windower.ffxi.get_info()
    if info and info.zone ~= st.zone then return SortieWatch.stop('zone changed') end
    if os.clock() - st.since > WATCH_LIMIT then return SortieWatch.stop('nothing after ' .. WATCH_LIMIT .. ' s') end
    local mob = claimed_now(st.mob, st.skip)[1]
    if not mob then return end
    windower._sortie_watch = nil
    trace('%s claimed by the party (id %s, claim %s, status %s, %d%%): fight for %s', tostring(mob.name),
        tostring(mob.id), tostring(mob.claim_id), tostring(mob.status), mob.hpp or 0, st.key)
    st.on_claimed(mob)
end

--- One look every TICK while the watch is the current one, in the load that started it.
local function loop(st)
    if windower._sortie_watch ~= st then return end
    if windower._load_gen ~= st.load_gen then
        windower._sortie_watch = nil
        trace('watch for %s stopped: GearSwap loaded again (type the prep macro again)', st.key)
        return
    end
    local ok, err = pcall(look, st)
    if not ok then
        windower._sortie_watch = nil
        trace('watch error: %s', tostring(err))
        return
    end
    coroutine.schedule(function() loop(st) end, TICK)
end

--- Watch for `mob` claimed by the party, then call on_claimed once. Replaces a watch under way.
--- @param key string Target key (for the trace)
--- @param mob string Monster name
--- @param on_claimed function Called once with the claimed mob, the watch already over
function SortieWatch.start(key, mob, on_claimed)
    local info = windower.ffxi.get_info()
    local skip = {}
    for _, m in ipairs(claimed_now(mob)) do skip[m.id] = true end
    local st = {key = key, mob = mob, on_claimed = on_claimed, zone = info and info.zone,
        load_gen = windower._load_gen, since = os.clock(), skip = skip}
    windower._sortie_watch = st
    trace('watching for %s claimed by the party: then fight for %s (%d already claimed, left out)', mob, key,
        #claimed_now(mob))
    loop(st)
end

--- End the watch under way, if any.
--- @param why string|nil For the trace
function SortieWatch.stop(why)
    local st = windower._sortie_watch
    if not st then return end
    windower._sortie_watch = nil
    trace('watch for %s stopped (%s)', st.key, why or 'asked')
end

--- The target key watched, or nil.
--- @return string|nil
function SortieWatch.watching()
    return windower._sortie_watch and windower._sortie_watch.key or nil
end

_G.SortieWatch = SortieWatch

return SortieWatch
