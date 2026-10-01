---============================================================================
--- Stealth Trace - what really happened to Sneak / Invisible (//gs c trace)
---============================================================================
--- The stealth decisions in the trace are taken at the key press. These
--- lines say what the game did afterwards, on every box, only while the
--- trace is on:
---   buff_change   this character's Sneak / Invisible gained, refreshed or
---                 lost, with the time left (StealthTimers, packet 0x063);
---   on_action     this character finished casting Sneak / Invisible: who
---                 the spell reached (the action packet lists every target),
---                 who of the group it missed, each one's distance at that
---                 moment, and whether Accession was up. The distance written
---                 at the key press (stealth_aoe) comes several seconds
---                 earlier, before Light Arts, Accession and the cast.
---
--- @file    shared/utils/stealth/stealth_trace.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

local StealthTrace = {}

local SPELLS = {[137] = 'Sneak', [136] = 'Invisible'}
local ACCESSION = 366
local LABELS = {sneak = 'Sneak', invi = 'Invisible'}

local function trace()
    local ok, Trace = pcall(require, 'shared/utils/debug/trace_log')
    return ok and Trace and Trace.enabled() and Trace or nil
end

--- A change of this character's own buff end times (from StealthTimers).
--- @param old table|nil Previous {sneak =, invi =} end times (0 = not up)
--- @param new table New end times
--- @param left function StealthTimers.left(kind) after the update
function StealthTrace.buff_change(old, new, left)
    local Trace = trace()
    if not Trace then return end
    for kind, label in pairs(LABELS) do
        local before, after = old and old[kind] or 0, new[kind] or 0
        if before ~= after then
            local what = (before == 0 and 'gained') or (after == 0 and 'lost') or 'refreshed'
            local rest = left(kind)
            Trace.log('STEALTH', 'buff %s %s%s', label, what,
                rest and (', %d s left'):format(math.floor(rest)) or '')
        end
    end
end

local function accession_up()
    local ok, me = pcall(windower.ffxi.get_player)
    for _, id in ipairs(ok and me and me.buffs or {}) do
        if id == ACCESSION then return true end
    end
    return false
end

--- Names of the group members other than this character.
local function group()
    local ok, AltGroup = pcall(require, 'shared/utils/dualbox/alt_group')
    return ok and AltGroup and AltGroup.get_alts() or {}
end

--- This character finished a spell: for Sneak / Invisible, log who it reached.
--- @param act table Windower action
function StealthTrace.on_action(act)
    local spell = act and act.category == 4 and SPELLS[act.param]
    if not spell then return end
    local ok, me = pcall(windower.ffxi.get_player)
    if not (ok and me and act.actor_id == me.id) then return end
    local Trace = trace()
    if not Trace then return end
    local reached, hit = {}, {}
    for _, target in ipairs(act.targets or {}) do
        local mob = windower.ffxi.get_mob_by_id(target.id)
        if mob and mob.name then
            reached[#reached + 1] = mob.name
            hit[mob.name:lower()] = true
        end
    end
    local Aoe = require('shared/utils/stealth/stealth_aoe')
    local missed = {}
    for _, name in ipairs(group()) do
        local d = Aoe.distance(name)
        local where = d and ('%.1f y'):format(d) or 'not in zone'
        if not hit[name:lower()] then missed[#missed + 1] = ('%s (%s)'):format(name, where) end
        Trace.log('STEALTH', '%s landed: %s at %s', spell, name, where)
    end
    Trace.log('STEALTH', '%s landed%s: reached %s; missed %s', spell,
        accession_up() and ' with Accession' or '', table.concat(reached, ', '),
        #missed > 0 and table.concat(missed, ', ') or 'nobody')
end

--- Listen for this character's finished spells, once per load (raw event).
function StealthTrace.start()
    if rawget(_G, '_stealth_trace_listener') then return end
    _G._stealth_trace_listener = true
    require('shared/utils/core/action_listener').on('stealth_trace', StealthTrace.on_action)
end

return StealthTrace
