---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Blood Pact Classifier - Routes BP name to gear category
---  ═══════════════════════════════════════════════════════════════════════════
---   Classifies every Blood Pact by name and returns its target set path
---   under sets.pet_midcast.
---
---   Note: shared/data/magic/summoning/<avatar>.lua exposes a richer per-pact
---   database (element, MP cost, level, astral_flow flag). This classifier
---   uses static name lists instead because (a) some pacts that the engine
---   marks as 'physical' (Conflag Strike) are better geared as Magical for
---   the average SMN setup, and (b) the lists below are the authoritative
---   spec from docs/SMN_BLOOD_PACTS_REFERENCE.md. Update both in sync.
---
---   Categories:
---     • BPRage.Physical    - all single/multi-hit physical pacts
---     • BPRage.Magical     - elemental nukes (Fire II, Wind Blade, Impact, etc.)
---     • BPRage.Hybrid      - Burning Strike, Flaming Crush
---     • BPRage.AstralFlow  - 2h pacts (Inferno, Aerial Blast, Zantetsuken, etc.)
---     • BPWard.Buff        - Hastega, Crimson Howl, Earthen Armor, etc.
---     • BPWard.Debuff      - Sleepga, Tidal Roar, Diamond Storm, etc.
---     • BPWard.Heal        - Healing Ruby, Whispering Wind, Soothing Current, etc.
---
---   @file    shared/jobs/smn/functions/logic/blood_pact_classifier.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

local BloodPactClassifier = {}

---============================================================================
--- BP NAME SETS
---============================================================================

local physical_pacts = S{
    'Punch','Rock Throw','Barracuda Dive','Claw','Welt','Axe Kick',
    'Shock Strike','Camisado','Regal Scratch','Poison Nails','Moonlit Charge',
    'Crescent Fang','Rock Buster','Roundhouse','Tail Whip','Double Punch',
    'Megalith Throw','Double Slap','Eclipse Bite','Mountain Buster',
    'Spinning Dive','Predator Claws','Rush','Chaotic Strike',
    'Volt Strike','Hysteric Assault','Crag Throw','Blindside','Regal Gash'
}

local hybrid_pacts = S{
    'Burning Strike','Flaming Crush'
}

local magical_pacts = S{
    'Fire II','Stone II','Water II','Aero II','Blizzard II','Thunder II',
    'Thunderspark','Meteorite','Fire IV','Stone IV','Water IV','Aero IV',
    'Blizzard IV','Thunder IV','Sonic Buffet','Nether Blast',
    'Meteor Strike','Geocrush','Grand Fall','Wind Blade','Tornado II',
    'Heavenly Strike','Thunderstorm','Level ? Holy','Holy Mist',
    'Lunar Bay','Night Terror','Conflag Strike','Impact'
}

local astral_flow_pacts = S{
    'Searing Light','Inferno','Earthen Fury','Tidal Wave','Aerial Blast',
    'Diamond Dust','Judgment Bolt','Howling Moon','Ruinous Omen',
    'Clarsach Call','Zantetsuken','Perfect Defense'
}

local ward_buff_pacts = S{
    'Shining Ruby','Glittering Ruby','Aerial Armor','Frost Armor',
    'Rolling Thunder','Katabatic Blades','Ecliptic Growl','Lightning Armor',
    'Noctoshield','Ecliptic Howl','Dream Shroud','Reraise II',
    'Crimson Howl','Hastega','Earthen Ward','Earthen Armor',
    'Fleet Wind','Inferno Howl',"Wind's Blessing",
    'Pacifying Ruby','Heavenward Howl','Hastega II','Crystal Blessing'
}

local ward_heal_pacts = S{
    'Healing Ruby','Whispering Wind','Spring Water','Healing Ruby II',
    'Chinook','Soothing Ruby','Soothing Current',"Altana's Favor"
}

local ward_debuff_pacts = S{
    'Lunatic Voice','Somnolence','Lunar Cry','Mewing Lullaby','Nightmare',
    'Lunar Roar','Slowga','Ultimate Terror','Sleepga','Bitter Elegy',
    'Eerie Eye','Tidal Roar','Shock Squall','Pavor Nocturnus',
    'Deconstruction','Chronoshift','Diamond Storm'
}

---============================================================================
--- PUBLIC API
---============================================================================

--- Classify a Blood Pact by name
--- @param bp_name string Blood Pact English name
--- @return string|nil category Path under sets.pet_midcast (e.g. "BPRage.Physical"), or nil if unknown
function BloodPactClassifier.classify(bp_name)
    if not bp_name then return nil end

    if astral_flow_pacts:contains(bp_name) then return 'BPRage.AstralFlow' end
    if physical_pacts:contains(bp_name)    then return 'BPRage.Physical' end
    if hybrid_pacts:contains(bp_name)      then return 'BPRage.Hybrid' end
    if magical_pacts:contains(bp_name)     then return 'BPRage.Magical' end
    if ward_buff_pacts:contains(bp_name)   then return 'BPWard.Buff' end
    if ward_heal_pacts:contains(bp_name)   then return 'BPWard.Heal' end
    if ward_debuff_pacts:contains(bp_name) then return 'BPWard.Debuff' end

    return nil
end

--- Lookup the gear set from a classification path
--- @param category string Path under sets.pet_midcast (e.g. "BPRage.Physical")
--- @return table|nil set The matching gear set, or nil if not defined
function BloodPactClassifier.get_set(category)
    if not category or not sets.pet_midcast then return nil end

    local cursor = sets.pet_midcast
    for part in string.gmatch(category, '[^%.]+') do
        if type(cursor) ~= 'table' then return nil end
        cursor = cursor[part]
        if cursor == nil then return nil end
    end

    if type(cursor) == 'table' then return cursor end
    return nil
end

--- Convenience: classify + lookup in one call
--- @param bp_name string Blood Pact English name
--- @return table|nil set, string|nil category
function BloodPactClassifier.resolve(bp_name)
    local category = BloodPactClassifier.classify(bp_name)
    if not category then return nil, nil end
    return BloodPactClassifier.get_set(category), category
end

return BloodPactClassifier
