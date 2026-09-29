---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Ranged - ranged attack gear beyond Mote's pick
---  ═══════════════════════════════════════════════════════════════════════════
---   Precast (the aim, Snapshot / Rapid Shot): Mote picks
---     sets.precast.RA[RangedMode], then .Flurry1 / .Flurry2 while that
---     Flurry is up (the shared FlurryTracker fills Mote's
---     classes.CustomRangedGroups); then PRECAST_LAYERS on top.
---   Midcast (the shot): RNG_MIDCAST picks sets.midcast.RA[RangedMode]
---     through MidcastManager; then MIDCAST_LAYERS on top.
---
---   A layer is sets.buff[<buff name>], laid while that buff is up
---   (buffactive is current inside a precast / midcast event). Order is
---   priority: a later layer wins a slot both name. What each buff's gear
---   does (BG-Wiki):
---     Velocity Shot   "equipment must remain equipped": its body / back
---                     cut the aiming delay and raise ranged attack, so it
---                     is laid on both the aim and the shot
---     Hover Shot      no enhancing gear known; the layer is there for your
---                     own choice
---     Decoy Shot      no enhancing gear known (job points only); same
---     Unlimited Shot  the next shot uses no ammo; Sylvan / Amini
---                     Bottillons remove its distance correction
---     Double Shot     damage / occurrence gear only counts while the
---                     ability is active
---     Barrage         Orion Bracers and the like add shots and accuracy;
---                     the buff lasts until the next ranged attack
---
---   @file    shared/jobs/rng/functions/logic/ranged.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Ranged = {}

--- Buff layers on the ranged precast (the aim)
Ranged.PRECAST_LAYERS = {'Velocity Shot'}

--- Buff layers on the ranged midcast (the shot), lowest priority first
Ranged.MIDCAST_LAYERS = {
    'Velocity Shot', 'Hover Shot', 'Decoy Shot', 'Unlimited Shot', 'Double Shot', 'Barrage',
}

--- The layers of `names` whose buff is up and whose set exists, combined.
--- @param names table Buff names, lowest priority first
--- @return table|nil set Combined layers (nil when none applies)
--- @return table laid Names of the layers laid
function Ranged.layers(names)
    local combined, laid = nil, {}
    local buff_sets = sets and sets.buff
    if not (buffactive and type(buff_sets) == 'table') then return nil, laid end
    for _, name in ipairs(names) do
        local layer = buff_sets[name]
        if buffactive[name] and type(layer) == 'table' then
            combined = combined and set_combine(combined, layer) or layer
            laid[#laid + 1] = name
        end
    end
    return combined, laid
end

--- Equip the layers of `names` that apply, and trace them.
--- @param names table Buff names, lowest priority first
--- @param phase string 'PRECAST' or 'MIDCAST' (trace tag)
--- @return table laid Names of the layers laid
function Ranged.equip_layers(names, phase)
    local combined, laid = Ranged.layers(names)
    if combined then
        equip(combined)
        require('shared/utils/debug/trace_log').log(phase, 'Ranged buff layers: %s', table.concat(laid, ', '))
    end
    return laid
end

--- Before Mote builds the ranged precast set: Flurry I / II groups.
function Ranged.prepare_precast()
    require('shared/utils/precast/flurry_tracker').apply_ranged_groups()
end

--- Listen for Flurry I / II landing (once per load; FlurryTracker guards it).
function Ranged.start()
    require('shared/utils/precast/flurry_tracker').start()
end

return Ranged
