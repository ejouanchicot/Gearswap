---============================================================================
--- GEO Luopan Behind - a Geo- on a monster lands behind it, nobody engaged
---============================================================================
--- Off unless <Character>/geo/combat/GEO_CONFIG.lua sets `luopan_behind` to a
--- distance in yalms (5 = Silmaril's own Back offset, the Aminon setting), and
--- only while //gs c behind is on (stand_behind.lua): the targets that stand
--- behind their monster (`behind = true` in SORTIE_CONFIG: Aminon, its Leech
--- test). Every other fight keeps its bubble on the monster (the player,
--- 2026-11-13: "Aminon is the exception"); //gs c sortie sends `behind off` there.
---
--- Lead (`luopan_lead` in GEO_CONFIG, yalms, 0 = off), every other time: a Geo-
--- on a monster still walking to its target (facing it, farther than LEAD_NEAR)
--- lands ahead of it, half the way to that target, at most `luopan_lead` yalms.
--- The bubble at the pull goes while the boss walks to the tank after the Flash;
--- on the boss it would stay where the boss was (the player, 2026-11-13). The
--- target is the monster's own (target_index) when the game gives it, else the
--- player who claimed it (claim_id: the tank after the Flash; the Leeches gave no
--- target_index, every lead of 2026-11-13 evening fell back to "none"). A
--- monster standing (or already on its target) keeps the bubble on it. Each
--- lead goes to the trace (tag LUOPAN): whether the offset counts from where
--- the monster was at the cast's start or its end is only seen in game.
---
--- Why: Silmaril's Geomancy page places an offensive luopan behind the mob only
--- while the player it assists is ENGAGED (Geomancy_Actions.Geomancy_Luopan,
--- decompiled), and on Aminon HQ nobody engages. Its lock-on Combat Script casts
--- the Geo- without engaging, but on the mob itself. The addon moves a luopan by
--- writing X/Y/Z Offset into the outgoing action packet (addons/Silmaril/lib/
--- Packets.lua packet_out_0x01A); this does the same for any Geo- this character
--- aims at a monster, with Silmaril's formula (Luopan_Offset, "Back"): behind
--- the mob as it faces, so on the far side from the tank.
---
--- While a luopan is out, a Geo- is cancelled before it is sent: the game
--- refuses it anyway, and a bot script that retries every few seconds would
--- otherwise swap gear and fill the chat for nothing (2026-11-13: 23 refused
--- Geo-Frailty in one minute). auto_full_circle, when on, runs before this.
---
--- @file    shared/jobs/geo/functions/logic/luopan_behind.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-13
---============================================================================

local LuopanBehind = {}

local ACTION = 0x01A
local CAST = 3            -- action category: magic
local MONSTER = 16        -- spawn_type of a monster
local LEAD_NEAR = 4       -- yalms: a monster this close to its target is on it, no lead
local LEAD_FACING = math.rad(45) -- a monster facing further off its target is not walking to it
local LEAD_REACH = 15     -- yalms from this character the shifted point may lie (the Geo- range as the bot sees it,
                          -- addons/Silmaril/lib/GeoRange.lua): a shift past it is shortened, a Geo- aimed past the
                          -- range may be the refusals seen at the pull (2026-11-13: 2 of 3 casts lost with a lead)
local ACTION_MESSAGE = 0x029

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('LUOPAN', fmt, unpack(args)) end)
end

--- The distance set in GEO_CONFIG, nil when off.
--- @return number|nil
function LuopanBehind.distance()
    local ok, d = pcall(function() return require('shared/utils/core/job_config').get('GEO', 'luopan_behind', 0) end)
    return ok and type(d) == 'number' and d > 0 and d or nil
end

--- The lead set in GEO_CONFIG (yalms at most), nil when off.
--- @return number|nil
function LuopanBehind.lead_max()
    local ok, d = pcall(function() return require('shared/utils/core/job_config').get('GEO', 'luopan_lead', 0) end)
    return ok and type(d) == 'number' and d > 0 and d or nil
end

--- True while //gs c behind is on (its state lives on windower and outlives a GearSwap load).
--- @return boolean
function LuopanBehind.behind_on()
    local st = rawget(_G, 'windower') and windower._stand_behind
    return st ~= nil and st.on == true
end

--- The X/Y offset of a point `dist` yalms behind a mob, as Silmaril computes it.
--- @param heading number The mob's heading (windower mob.heading, radians)
--- @param dist number Yalms
--- @return number, number
function LuopanBehind.offset(heading, dist)
    local angle = heading < 0 and math.abs(heading) or (math.pi * 2 - heading)
    angle = angle + math.pi
    return math.cos(angle) * dist, math.sin(angle) * dist
end

--- GearSwap's own resources (not require('resources') in the sandbox: see trace_hooks.lua).
local function spells()
    local gs = rawget(_G, 'gearswap')
    local r = rawget(_G, 'res') or (type(gs) == 'table' and gs.res)
    return type(r) == 'table' and r.spells or {}
end

--- A Geo- cast on a monster with no offset yet: the parsed packet, the monster and the packets lib; nil otherwise.
--- @param data string The packet
--- @param deps table Test seams: packets, spells, mob_by_index
local function geo_on_monster(data, deps)
    local packets = deps.packets or require('packets')
    local p = packets.parse('outgoing', data)
    if not p or p.Category ~= CAST then return nil end
    -- already placed (Silmaril's Geomancy page sets its own offset)
    if (p['X Offset'] or 0) ~= 0 or (p['Y Offset'] or 0) ~= 0 then return nil end
    local spell = (deps.spells or spells())[p.Param]
    if not (spell and type(spell.en) == 'string' and spell.en:sub(1, 4) == 'Geo-') then return nil end
    local mob = (deps.mob_by_index or windower.ffxi.get_mob_by_index)(p['Target Index'])
    if not (mob and mob.spawn_type == MONSTER and type(mob.heading) == 'number') then return nil end
    return p, mob, packets
end

--- An outgoing action packet with the offset written, or nil to leave it as it is.
--- @param data string The packet
--- @param dist number Yalms
--- @param deps table|nil Test seams: packets, spells, mob_by_index
--- @return string|nil
function LuopanBehind.rewrite(data, dist, deps)
    local p, mob, packets = geo_on_monster(data, deps or {})
    if not p then return nil end
    p['X Offset'], p['Y Offset'] = LuopanBehind.offset(mob.heading, dist)
    p['Z Offset'] = 0
    return packets.build(p)
end

--- The lead of a monster walking to its target: half the way there, at most `max` yalms; nil when it is not
--- walking to it (farther than LEAD_NEAR and facing it within LEAD_FACING).
--- @param mob table x, y, heading
--- @param target table|nil x, y
--- @param max number Yalms
--- @return number|nil, number, number, number x, y offset, distance to the target, lead length
function LuopanBehind.lead_offset(mob, target, max)
    if not (target and type(target.x) == 'number' and type(target.y) == 'number') then return nil end
    local dx, dy = target.x - mob.x, target.y - mob.y
    local d = math.sqrt(dx * dx + dy * dy)
    if d <= LEAD_NEAR then return nil end
    -- windower heading convention (stand_behind.lua angle): -atan2(dy, dx)
    local diff = math.abs((-math.atan2(dy, dx) - mob.heading + math.pi) % (2 * math.pi) - math.pi)
    if diff > LEAD_FACING then return nil end
    local len = math.min(max, d / 2)
    return dx / d * len, dy / d * len, d, len
end

--- Who the monster walks to: its target when the game gives one, else the player who claimed it.
--- @param mob table
--- @param deps table mob_by_index, mob_by_id
--- @return table|nil, string The target mob, and which way it was found (for the trace)
function LuopanBehind.walk_target(mob, deps)
    local by_index = deps.mob_by_index or windower.ffxi.get_mob_by_index
    local by_id = deps.mob_by_id or windower.ffxi.get_mob_by_id
    local target = mob.target_index and mob.target_index ~= 0 and by_index(mob.target_index) or nil
    if target then return target, 'target' end
    target = mob.claim_id and mob.claim_id ~= 0 and by_id(mob.claim_id) or nil
    return target, target and 'claimer' or 'no target, no claim'
end

--- The lead shortened so the point stays within `reach` yalms of `me`: the length, 0 when even the monster is past it.
--- @param me table x, y
--- @param mob table x, y
--- @param ux number Unit vector to the target, x
--- @param uy number Unit vector to the target, y
--- @param len number Wanted length
--- @param reach number Yalms
--- @return number
function LuopanBehind.within_reach(me, mob, ux, uy, len, reach)
    while len > 0 do
        local px, py = mob.x + ux * len, mob.y + uy * len
        if math.sqrt((px - me.x) ^ 2 + (py - me.y) ^ 2) <= reach then return len end
        len = len - 0.5
    end
    return 0
end

--- An outgoing Geo- on a monster walking to its target, the luopan put ahead of it; nil to leave the packet.
--- @param data string The packet
--- @param max number Yalms at most
--- @param deps table|nil Test seams: packets, spells, mob_by_index, mob_by_id
--- @return string|nil
function LuopanBehind.rewrite_lead(data, max, deps)
    deps = deps or {}
    local p, mob, packets = geo_on_monster(data, deps)
    if not p then return nil end
    local target, how = LuopanBehind.walk_target(mob, deps)
    local x, y, d, len = LuopanBehind.lead_offset(mob, target, max)
    if not x then
        trace('lead: %s not walking to %s (%s, facing %.2f): bubble on it', tostring(mob.name),
            target and target.name or 'a target', how, mob.heading)
        return nil
    end
    local me = (deps.me or function() return windower.ffxi.get_mob_by_target('me') end)()
    if me then
        local wanted = len
        len = LuopanBehind.within_reach(me, mob, x / wanted, y / wanted, wanted, LEAD_REACH)
        x, y = x / wanted * len, y / wanted * len
    end
    local from_me = me and math.sqrt((mob.x - me.x) ^ 2 + (mob.y - me.y) ^ 2) or -1
    trace('lead: %s %.1f yalms from %s (%s), %.1f from me, bubble %.1f yalms ahead', tostring(mob.name), d,
        tostring(target.name), how, from_me, len)
    if len <= 0 then return nil end
    p['X Offset'], p['Y Offset'], p['Z Offset'] = x, y, 0
    return packets.build(p)
end

--- Rewrite this character's Geo- casts, once per load (raw events go at the next file load): behind the monster
--- while //gs c behind is on, else ahead of a monster walking to its target. The settings are read here, not at
--- every action packet: a change takes a //gs reload. Both off: no listener.
function LuopanBehind.listen()
    if rawget(_G, '_luopan_behind_listening') then return end
    _G._luopan_behind_listening = true
    local dist, lead = LuopanBehind.distance(), LuopanBehind.lead_max()
    if not (dist or lead) then return end
    windower.raw_register_event('outgoing chunk', function(id, original, modified, injected, blocked)
        if id ~= ACTION or blocked then return end
        local ok, rewritten
        if LuopanBehind.behind_on() then
            if dist then ok, rewritten = pcall(LuopanBehind.rewrite, modified or original, dist) end
        elseif lead then
            ok, rewritten = pcall(LuopanBehind.rewrite_lead, modified or original, lead)
        end
        if ok and rewritten then return rewritten end
    end)
    -- why a Geo- did not go (too far, moving, cannot see...): the game's refusal, to the trace
    windower.raw_register_event('incoming chunk', function(id, original)
        if id ~= ACTION_MESSAGE then return end
        pcall(LuopanBehind.trace_refusal, original)
    end)
end

--- This character's action message (0x029: a refusal, an interruption...) to the trace, with its text.
--- @param data string The packet
function LuopanBehind.trace_refusal(data)
    local me = windower.ffxi.get_player()
    local p = require('packets').parse('incoming', data)
    if not (me and p and p.Actor == me.id) then return end
    local gs = rawget(_G, 'gearswap')
    local r = rawget(_G, 'res') or (type(gs) == 'table' and gs.res)
    local entry = type(r) == 'table' and r.action_messages and r.action_messages[p.Message]
    trace('game message %s: %s', tostring(p.Message), entry and entry.en or '?')
end

--- Precast: a Geo- while a luopan is out is cancelled (the game would refuse it).
--- @param spell table
--- @param eventArgs table
--- @return boolean True when cancelled
function LuopanBehind.skip_while_out(spell, eventArgs)
    if not (LuopanBehind.distance() and LuopanBehind.behind_on()) then return false end
    if not (spell and type(spell.english) == 'string' and spell.english:sub(1, 4) == 'Geo-') then return false end
    local mob = windower.ffxi.get_mob_by_target('pet')
    if not (mob and mob.name == 'Luopan' and (mob.hpp or 0) > 0) then return false end
    eventArgs.cancel = true
    return true
end

_G.LuopanBehind = LuopanBehind

return LuopanBehind
