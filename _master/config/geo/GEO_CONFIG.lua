---============================================================================
--- Geomancer - the job's own switches and thresholds
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file geo/combat/GEO_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- An Indi- cast on a party member gets Entrust first
    auto_entrust = false,

    -- A Geo- cast while a luopan is out gets Full Circle first
    auto_full_circle = false,
    -- Widened Compass before a Geo- on these monsters, the Geo- once its buff is up (Silmaril never fires it).
    -- {} = off. (shared/jobs/geo/functions/logic/geo_auto_abilities.lua)
    widened_compass_on = {},

    -- Bolster up and no luopan out: Blaze of Glory, so the next Geo- carries it.
    -- Bolster over with a luopan still out: Ecliptic Attrition on it if it was
    -- placed with Blaze of Glory, otherwise Full Circle (a bot such as Silmaril
    -- places it again). For a GEO played by a bot, which skips both under Bolster.
    bolster_follow = false,

    -- //gs c escort with no Indi- named
    escort_indi = 'Indi-Regen',

    -- A Geo- aimed at a monster lands this many yalms behind it (the side away from where
    -- it faces), with nobody engaged; 0 = off. 5 = Silmaril's Back offset, the Aminon
    -- setting. With it on, a Geo- is not sent while a luopan is out (the game refuses it).
    -- Only while //gs c behind is on (Sortie targets with behind = true: Aminon, leechtest);
    -- every other fight keeps the bubble on the monster.
    -- For a bot casting the bubble from a lock-on script (shared/jobs/geo/functions/logic/luopan_behind.lua)
    luopan_behind = 0,
    -- A Geo- on a monster still walking to its target (the boss coming to the tank after the Flash) lands
    -- ahead of it, half the way to that target, at most this many yalms; a monster standing keeps the
    -- bubble on it. 0 = off. Not while //gs c behind is on (Aminon: luopan_behind above).
    -- (shared/jobs/geo/functions/logic/luopan_behind.lua)
    luopan_lead = 0,
    -- These spells, once they land (or are resisted) on a monster, told in party chat in one short line:
    --   Stun > Degei: STUNNED / RESISTED / NO EFFECT      Absorb-TP > Aminon: -387 TP
    -- {} = off. (shared/utils/messages/party_callouts.lua)
    party_callouts = {},

    -- //gs c behind (sent by //gs c sortie <target> fight when the target has behind = true): the GEO
    -- walks behind the monster it is locked on, nobody engaged, and back there once it stayed
    -- off that spot this many seconds (a monster turning for a moment as the hate moves is let be)
    -- (shared/jobs/geo/functions/logic/stand_behind.lua)
    stand_behind_settle = 7,
    -- Yalms from the monster's center //gs c behind stands at; 0 = half the melee range (Silmaril's spot).
    -- Beyond the melee range a weapon skill no longer reaches.
    stand_behind_distance = 0,
    -- Once on that spot this many seconds with the monster standing still, the GEO stays put for good
    -- behind it (it only turns, the tank placed it): no more following its turns until the next
    -- //gs c behind, another monster, or the monster moving off. 0 = never, it keeps going back behind
    -- whenever the monster turns.
    stand_behind_lock = 10,
    -- Locked there and knocked back (Aminon's white hits), it walks back to that very place after
    -- this many seconds off it (the push over first); never during a spell.
    stand_behind_back = 2,
}
