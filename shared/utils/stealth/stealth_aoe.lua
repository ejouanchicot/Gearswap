---============================================================================
--- Stealth AoE - one Scholar covers the whole box group with Accession
---============================================================================
--- A character with Scholar (main or sub) and a stratagem charge left casts
--- Accession + Sneak / Invisible, wherever the others stand (the distance is
--- only written to the trace), when it needs the buff itself. A member it
--- did not reach gets it its own way on the next press: the Scholar, covered
--- by then, claims nothing (stealth.lua). through the existing Scholar chain
--- (ScholarActions.cast_with_stratagems, as //gs c aoe sneak: Light Arts
--- first when it is not up, each step waiting on its buff): the others do
--- nothing for that buff. One charge per buff: with a single charge, only
--- the first buff asked (Sneak before Invisible) is covered. A job with the
--- SneakInviAOE mode (BLM, PLD) set to Off never covers the group.
---
--- The box that qualifies announces it (`stealth claim <kind> <name>` to the
--- others) and casts at once, unless a claim from another box is already
--- in. The key's own box claims before relaying the key, so the others
--- see its claim first and stand back. A box that cannot cover waits half a
--- second for a claim, then goes its own way (stealth.lua). If two claims
--- ever cross, the first name in alphabetical order counts as the caster.
---
--- @file shared/utils/stealth/stealth_aoe.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

local StealthAoe = {}

local Methods = require('shared/utils/stealth/stealth_methods')

local CLAIM_LIFE = 5   -- seconds a claim counts

--- Claims seen, per kind: claims[kind][name:lower()] = {name, time}.
local function claims()
    windower._stealth_claims = windower._stealth_claims or {sneak = {}, invi = {}}
    return windower._stealth_claims
end

--- Whether Scholar is this character's main or sub job.
local function has_scholar()
    return player and (player.main_job == 'SCH' or player.sub_job == 'SCH')
end

--- The job's SneakInviAOE mode, when it has one, says whether to spend a
--- stratagem on the group.
local function aoe_allowed()
    local mode = state and state.SneakInviAOE
    return not mode or mode.value ~= 'Off'
end

--- Distance to `name` in yalms, flat (x and y, no height), or nil when not
--- in this zone. Same measure as the automation addon's own box, so the
--- two can be compared; Windower's mob.distance also counts the height and
--- read higher on slopes.
--- @param name string
--- @return number|nil
function StealthAoe.distance(name)
    local other = windower.ffxi.get_mob_by_name(name)
    local me = windower.ffxi.get_mob_by_target('me')
    if not (other and me and other.x and me.x) then return nil end
    local dx, dy = other.x - me.x, other.y - me.y
    return math.sqrt(dx * dx + dy * dy)
end

--- Write each member's distance to the trace (//gs c trace on): the only
--- way to learn Accession's real reach from the game.
--- @param names table Other members of the group
function StealthAoe.trace_distances(names)
    local ok, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if not (ok and Trace) then return end
    for _, name in ipairs(names) do
        local d = StealthAoe.distance(name)
        Trace.log('STEALTH', 'Accession: %s at %s', name, d and ('%.1f yalms'):format(d) or 'not in zone')
    end
end

--- Why this character can or cannot cover the group (//gs c stealth check).
--- @return table {scholar, allowed, charges}
function StealthAoe.status()
    local charges = 0
    if has_scholar() then
        local ok, StratagemCharges = pcall(require, 'shared/utils/scholar/stratagem_charges')
        charges = ok and StratagemCharges.available() or 0
    end
    return {scholar = has_scholar() and true or false, allowed = aoe_allowed(), charges = charges}
end

--- The kinds this character can cover for the whole group right now, in
--- the order asked, one stratagem charge each.
--- @param kinds table 'sneak' / 'invi', in order
--- @param names table Other members of the group
--- @return table Kinds it can cover (may be empty)
function StealthAoe.coverable(kinds, names)
    if #names == 0 or not has_scholar() or not aoe_allowed() then return {} end
    local StratagemCharges = require('shared/utils/scholar/stratagem_charges')
    local charges = StratagemCharges.available()
    if buffactive and buffactive['Accession'] then charges = charges + 1 end
    local out = {}
    for _, kind in ipairs(kinds) do
        if charges <= 0 then break end
        if Methods.can_cast(Methods.BY_BUFF[kind].spell) then
            out[#out + 1] = kind
            charges = charges - 1
        end
    end
    return out
end

--- Record a claim (this character's or one received).
--- @param kind string 'sneak' or 'invi'
--- @param name string Claimant
function StealthAoe.record(kind, name)
    if not (claims()[kind] and name) then return end
    claims()[kind][name:lower()] = {name = name, time = os.clock()}
end

--- The claimant that casts for `kind`: the first in alphabetical order
--- among the recent claims, or nil when nobody claimed.
--- @param kind string 'sneak' or 'invi'
--- @return string|nil
function StealthAoe.winner(kind)
    local best
    for key, claim in pairs(claims()[kind] or {}) do
        if os.clock() - claim.time <= CLAIM_LIFE and (not best or key < best:lower()) then
            best = claim.name
        end
    end
    return best
end

--- Forget the claims of `kind` once decided.
--- @param kind string
function StealthAoe.clear(kind)
    claims()[kind] = {}
end

--- Seconds the Scholar chain takes: Light Arts and Accession when they are
--- not up (about 2 s each), then the cast.
--- @param cast_wait number Cast time plus the delay setting
--- @return number
function StealthAoe.chain_time(cast_wait)
    local arts = buffactive and (buffactive['Addendum: White'] or buffactive['Light Arts'])
    local accession = buffactive and buffactive['Accession']
    return (arts and 0 or 2) + (accession and 0 or 2) + cast_wait
end

return StealthAoe
