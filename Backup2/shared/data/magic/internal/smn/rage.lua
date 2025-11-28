---============================================================================
--- SMN Blood Pacts Rage - Offensive Blood Pact Data
---============================================================================
--- Contains all ~61 offensive blood pacts (damage abilities)
--- @file internal/smn/rage.lua
--- @author Tetsouo
---============================================================================
local rage = {}

---============================================================================
--- BLOOD PACTS - RAGE (Offensive Abilities)
---============================================================================

rage.blood_pacts_rage = {

    ---========================================================================
    --- TWO-HOUR ABILITIES (Astral Flow)
    ---========================================================================

    ["Inferno"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Earthen Fury"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Tidal Wave"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Aerial Blast"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Clarsach Call"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Diamond Dust"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Judgment Bolt"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Searing Light"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Howling Moon"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Ruinous Omen"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Zantetsuken"] = {
        avatar                  = "Odin",
        element                 = "Dark",
        damage_type             = "Magical",
        property                = nil,
        restriction = "two_hour",
        SMN                     = 75
    },

    ---========================================================================
    --- PHYSICAL BLOOD PACTS (Subjob Available)
    ---========================================================================

    ["Punch"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Physical",
        physical_type = "H2H",
        property                = "Liquefaction",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Rock Throw"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Scission",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Barracuda Dive"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Reverberation",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Claw"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        damage_type             = "Physical",
        physical_type = "Piercing",
        property                = "Detonation",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Welt"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Scission",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Axe Kick"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        damage_type             = "Physical",
        physical_type = "H2H",
        property                = "Induration",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Shock Strike"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Impaction",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Camisado"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Compression",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Regal Scratch"] = {
        avatar                  = "Cait Sith",
        element                 = "Light",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Scission",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Poison Nails"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        damage_type             = "Physical",
        physical_type = "Piercing",
        property                = "Transfixion",
        restriction = "subjob",
        SMN                     = 5
    },
    ["Moonlit Charge"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Compression",
        restriction = "subjob",
        SMN                     = 5
    },

    ---========================================================================
    --- MAGICAL BLOOD PACTS - TIER II (Subjob Available)
    ---========================================================================

    ["Fire II"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Magical",
        property                = nil,
        restriction = "subjob",
        SMN                     = 10
    },
    ["Stone II"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Magical",
        property                = nil,
        restriction = "subjob",
        SMN                     = 10
    },
    ["Water II"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        damage_type             = "Magical",
        property                = nil,
        restriction = "subjob",
        SMN                     = 10
    },
    ["Aero II"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        damage_type             = "Magical",
        property                = nil,
        restriction = "subjob",
        SMN                     = 10
    },
    ["Blizzard II"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        damage_type             = "Magical",
        property                = nil,
        restriction = "subjob",
        SMN                     = 10
    },
    ["Thunder II"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        damage_type             = "Magical",
        property                = nil,
        restriction = "subjob",
        SMN                     = 10
    },

    ---========================================================================
    --- MID-LEVEL BLOOD PACTS (Subjob Available)
    ---========================================================================

    ["Crescent Fang"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        damage_type             = "Physical",
        physical_type = "Piercing",
        property                = "Transfixion",
        restriction = "subjob",
        SMN                     = 10
    },
    ["Thunderspark"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        damage_type             = "Magical",
        property                = nil,
        restriction = "subjob",
        SMN                     = 19
    },
    ["Rock Buster"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Reverberation",
        restriction = "subjob",
        SMN                     = 21
    },
    ["Burning Strike"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Hybrid",
        physical_type = "H2H",
        property                = "Impaction",
        restriction = "subjob",
        SMN                     = 23
    },
    ["Roundhouse"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        damage_type             = "Physical",
        physical_type = "H2H",
        property                = "Detonation",
        restriction = "subjob",
        SMN                     = 25
    },
    ["Tail Whip"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Detonation",
        restriction = "subjob",
        SMN                     = 26
    },
    ["Double Punch"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Compression",
        restriction = "subjob",
        SMN                     = 30
    },
    ["Megalith Throw"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Induration",
        restriction = "subjob",
        SMN                     = 35
    },

    ---========================================================================
    --- HIGH-LEVEL BLOOD PACTS (Subjob Master Only - Level 50+)
    ---========================================================================

    ["Double Slap"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        damage_type             = "Physical",
        physical_type = "H2H",
        property                = "Scission",
        restriction = "subjob_master_only",
        SMN                     = 50
    },
    ["Meteorite"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        damage_type             = "Magical",
        property                = nil,
        restriction = "subjob_master_only",
        SMN                     = 55
    },

    ---========================================================================
    --- MAGICAL BLOOD PACTS - TIER IV (Main Job Only)
    ---========================================================================

    ["Fire IV"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Magical",
        property                = nil,
        restriction = "main_job_only",
        SMN                     = 60
    },
    ["Stone IV"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Magical",
        property                = nil,
        restriction = "main_job_only",
        SMN                     = 60
    },
    ["Water IV"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        damage_type             = "Magical",
        property                = nil,
        restriction = "main_job_only",
        SMN                     = 60
    },
    ["Aero IV"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        damage_type             = "Magical",
        property                = nil,
        restriction = "main_job_only",
        SMN                     = 60
    },
    ["Blizzard IV"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        damage_type             = "Magical",
        property                = nil,
        restriction = "main_job_only",
        SMN                     = 60
    },
    ["Thunder IV"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        damage_type             = "Magical",
        property                = nil,
        restriction = "main_job_only",
        SMN                     = 60
    },

    ---========================================================================
    --- ADVANCED BLOOD PACTS (Main Job Only - Level 65+)
    ---========================================================================

    ["Sonic Buffet"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        damage_type             = "Magical",
        property                = nil,
        restriction = "main_job_only",
        SMN                     = 65
    },
    ["Eclipse Bite"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Gravitation / Scission",
        restriction = "main_job_only",
        SMN                     = 65
    },
    ["Nether Blast"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        damage_type             = "Breath",
        property                = nil,
        restriction = "main_job_only",
        SMN                     = 65
    },

    ---========================================================================
    --- WEAPONSKILL-STYLE BLOOD PACTS (Main Job Only - Level 70)
    ---========================================================================

    ["Flaming Crush"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Hybrid",
        physical_type = "Blunt",
        property                = "Fusion / Reverberation",
        restriction = "main_job_only",
        SMN                     = 70
    },
    ["Mountain Buster"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Gravitation / Induration",
        restriction = "main_job_only",
        SMN                     = 70
    },
    ["Spinning Dive"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Distortion / Detonation",
        restriction = "main_job_only",
        SMN                     = 70
    },
    ["Predator Claws"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Fragmentation / Scission",
        restriction = "main_job_only",
        SMN                     = 70
    },
    ["Rush"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        damage_type             = "Physical",
        physical_type = "H2H",
        property                = "Distortion / Scission",
        restriction = "main_job_only",
        SMN                     = 70
    },
    ["Chaotic Strike"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Fragmentation / Transfixion",
        restriction = "main_job_only",
        SMN                     = 70
    },

    ---========================================================================
    --- MERIT BLOOD PACTS (Level 75 + Merit Points)
    ---========================================================================

    ["Meteor Strike"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        note = "Merit Points",
        SMN                     = 75
    },
    ["Geocrush"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        note = "Merit Points",
        SMN                     = 75
    },
    ["Grand Fall"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        note = "Merit Points",
        SMN                     = 75
    },
    ["Wind Blade"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        note = "Merit Points",
        SMN                     = 75
    },
    ["Heavenly Strike"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        note = "Merit Points",
        SMN                     = 75
    },
    ["Thunderstorm"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        note = "Merit Points",
        SMN                     = 75
    },

    ---========================================================================
    --- SPECIAL BLOOD PACTS (Level 75+)
    ---========================================================================

    ["Tornado II"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        SMN                     = 75
    },
    ["Level ? Holy"] = {
        avatar                  = "Cait Sith",
        element                 = "Light",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        SMN                     = 75
    },
    ["Holy Mist"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        SMN                     = 76
    },
    ["Lunar Bay"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        SMN                     = 78
    },
    ["Night Terror"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        SMN                     = 80
    },

    ---========================================================================
    --- ENDGAME BLOOD PACTS (Level 99)
    ---========================================================================

    ["Conflag Strike"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        damage_type             = "Breath",
        property                = nil,
        restriction = nil,
        SMN                     = 99
    },
    ["Volt Strike"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        damage_type             = "Physical",
        physical_type = "Blunt",
        property                = "Fragmentation / Scission",
        restriction = nil,
        SMN                     = 99
    },
    ["Hysteric Assault"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        damage_type             = "Physical",
        physical_type = "Piercing",
        property                = "Fragmentation / Transfixion",
        restriction = nil,
        SMN                     = 99
    },
    ["Crag Throw"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Gravitation / Scission",
        restriction = nil,
        SMN                     = 99
    },
    ["Blindside"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Gravitation / Transfixion",
        restriction = nil,
        SMN                     = 99
    },
    ["Regal Gash"] = {
        avatar                  = "Cait Sith",
        element                 = "Light",
        damage_type             = "Physical",
        physical_type = "Slashing",
        property                = "Distortion / Detonation",
        restriction = nil,
        SMN                     = 99
    },
    ["Impact"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        damage_type             = "Magical",
        property                = nil,
        restriction = nil,
        SMN                     = 99
    }
}

return rage
