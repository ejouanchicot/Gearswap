---============================================================================
--- Flurry Tracker - is Flurry I or Flurry II on this character?
---============================================================================
--- The buff is the same ("Flurry") for both spells, so the level comes from
--- the spell that landed: an action packet, category 4 (spell finished), with
--- param 845 (Flurry) or 846 (Flurry II) and this character among its
--- targets. Flurry I never replaces a Flurry II still up. The level is
--- forgotten as soon as the Flurry buff is gone, read from the game.
---
--- Ranged jobs put the level in classes.CustomRangedGroups before the
--- precast, so Mote picks sets.precast.RA.Flurry1 / Flurry2 when they exist
--- (FlurryTracker.apply_ranged_groups).
---
--- @file    shared/utils/precast/flurry_tracker.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local FlurryTracker = {}

local CATEGORY_SPELL_FINISH = 4
local FLURRY_SPELLS = {[845] = 1, [846] = 2}
-- Two buffs are named "Flurry" in res/buffs.lua (265, 581): either one means
-- Flurry is up; the level comes from the spell packet, not from the buff id
local FLURRY_BUFFS = {[265] = true, [581] = true}

local function on_action(act)
    local level = act.category == CATEGORY_SPELL_FINISH and FLURRY_SPELLS[act.param]
    if not level then return end
    local me = windower.ffxi.get_player()
    if not me then return end
    for _, target in ipairs(act.targets or {}) do
        if target.id == me.id then
            if level == 2 or (windower._flurry_level or 0) < 2 then
                windower._flurry_level = level
            end
            return
        end
    end
end

--- Listen to the action packets, once per load (the sandbox drops the
--- listener at the next one).
function FlurryTracker.start()
    if rawget(_G, '_flurry_listening') or not windower.raw_register_event then return end
    _G._flurry_listening = true
    windower.raw_register_event('action', on_action)
end

--- Flurry level up now: 0, 1 or 2.
--- @return number
function FlurryTracker.level()
    local me = windower.ffxi.get_player()
    local up = false
    for _, id in ipairs(me and me.buffs or {}) do
        if FLURRY_BUFFS[id] then up = true end
    end
    if up then return windower._flurry_level or 1 end
    windower._flurry_level = nil
    return 0
end

--- Set classes.CustomRangedGroups for a ranged attack's precast: 'Flurry1'
--- or 'Flurry2' while that Flurry is up, nothing otherwise.
function FlurryTracker.apply_ranged_groups()
    if not (classes and classes.CustomRangedGroups) then return end
    classes.CustomRangedGroups:clear()
    local level = FlurryTracker.level()
    if level > 0 then classes.CustomRangedGroups:append('Flurry' .. level) end
end

return FlurryTracker
