---============================================================================
--- SMN Blood Pacts Ward - Support Blood Pact Data
---============================================================================
--- Contains all ~55 support/buff blood pacts (healing/party buffs)
--- @file internal/smn/ward.lua
--- @author Tetsouo
---============================================================================
local ward = {}

---============================================================================
--- BLOOD PACTS - WARD (Support/Buff Abilities)
---============================================================================

ward.blood_pacts_ward = {

    ---========================================================================
    --- TWO-HOUR ABILITIES (Astral Flow)
    ---========================================================================

    ["Altana's Favor"] = {
        avatar                  = "Cait Sith",
        element                 = "Light",
        effect                  = "Party Support",
        restriction = "two_hour",
        SMN                     = 1
    },
    ["Perfect Defense"] = {
        avatar                  = "Alexander",
        element                 = "Light",
        effect                  = "Party Invincibility",
        restriction = "two_hour",
        SMN                     = 75
    },

    ---========================================================================
    --- HEALING / SUPPORT (Subjob Available)
    ---========================================================================

    ["Healing Ruby"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        effect                  = "Single Target Heal",
        restriction = "subjob",
        SMN                     = 1
    },
    ["Lunatic Voice"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        effect                  = "AOE Slow",
        restriction = "subjob",
        SMN                     = 15
    },
    ["Raise II"] = {
        avatar                  = "Cait Sith",
        element                 = "Light",
        effect                  = "Raise II",
        restriction = "subjob",
        SMN                     = 15
    },
    ["Somnolence"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        effect                  = "AOE Sleep",
        restriction = "subjob",
        SMN                     = 20
    },
    ["Lunar Cry"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        effect                  = "AOE Accuracy Down",
        restriction = "subjob",
        SMN                     = 21
    },
    ["Shining Ruby"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        effect                  = "Party Regen",
        restriction = "subjob",
        SMN                     = 24
    },
    ["Mewing Lullaby"] = {
        avatar                  = "Cait Sith",
        element                 = "Light",
        effect                  = "AOE Sleep",
        restriction = "subjob",
        SMN                     = 25
    },
    ["Aerial Armor"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        effect                  = "Party Blink",
        restriction = "subjob",
        SMN                     = 25
    },
    ["Frost Armor"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        effect                  = "Party Ice Spikes",
        restriction = "subjob",
        SMN                     = 28
    },
    ["Nightmare"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        effect                  = "AOE Sleep + Erase Buffs",
        restriction = "subjob",
        SMN                     = 29
    },
    ["Reraise II"] = {
        avatar                  = "Cait Sith",
        element                 = "Light",
        effect                  = "Party Reraise II",
        restriction = "subjob",
        SMN                     = 30
    },
    ["Rolling Thunder"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        effect                  = "AOE Stun",
        restriction = "subjob",
        SMN                     = 31
    },
    ["Katabatic Blades"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        effect                  = "AOE Accuracy/Evasion Down",
        restriction = "subjob",
        SMN                     = 31
    },
    ["Lunar Roar"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        effect                  = "AOE Defense Down",
        restriction = "subjob",
        SMN                     = 32
    },
    ["Slowga"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        effect                  = "AOE Slow",
        restriction = "subjob",
        SMN                     = 33
    },
    ["Whispering Wind"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        effect                  = "Party Heal",
        restriction = "subjob",
        SMN                     = 36
    },
    ["Ultimate Terror"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        effect                  = "AOE Terror",
        restriction = "subjob",
        SMN                     = 37
    },
    ["Crimson Howl"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        effect                  = "Party Attack Boost",
        restriction = "subjob",
        SMN                     = 38
    },
    ["Sleepga"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        effect                  = "AOE Sleep",
        restriction = "subjob",
        SMN                     = 39
    },
    ["Lightning Armor"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        effect                  = "Party Shock Spikes",
        restriction = "subjob",
        SMN                     = 42
    },
    ["Chinook"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        effect                  = "Party Evasion Boost",
        restriction = "subjob",
        SMN                     = 42
    },
    ["Ecliptic Growl"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        effect                  = "Party Accuracy Boost",
        restriction = "subjob",
        SMN                     = 43
    },
    ["Glittering Ruby"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        effect                  = "Party Status Ailment Resist",
        restriction = "subjob",
        SMN                     = 44
    },
    ["Earthen Ward"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        effect                  = "Party Damage Reduction",
        restriction = "subjob",
        SMN                     = 46
    },
    ["Spring Water"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        effect                  = "Party Status Ailment Removal",
        restriction = "subjob",
        SMN                     = 47
    },
    ["Hastega"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        effect                  = "Party Haste",
        restriction = "subjob",
        SMN                     = 48
    },
    ["Noctoshield"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        effect                  = "Party Magic Defense Boost",
        restriction = "subjob",
        SMN                     = 49
    },

    ---========================================================================
    --- HIGH-LEVEL WARDS (Subjob Master Only - Level 50+)
    ---========================================================================

    ["Bitter Elegy"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        effect                  = "AOE Paralysis + Blind",
        restriction = "subjob_master_only",
        SMN                     = 50
    },
    ["Ecliptic Howl"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        effect                  = "Party Evasion Boost",
        restriction = "subjob_master_only",
        SMN                     = 54
    },
    ["Eerie Eye"] = {
        avatar                  = "Cait Sith",
        element                 = "Light",
        effect                  = "AOE Accuracy Down + Evasion Down",
        restriction = "subjob_master_only",
        SMN                     = 55
    },
    ["Dream Shroud"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        effect                  = "Party Magic Attack Boost",
        restriction = "subjob_master_only",
        SMN                     = 56
    },

    ---========================================================================
    --- ENDGAME WARDS (Level 65+)
    ---========================================================================

    ["Healing Ruby II"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        effect                  = "Single Target Heal (Enhanced)",
        restriction = nil,
        SMN                     = 65
    },
    ["Deconstruction"] = {
        avatar                  = "Atomos",
        element                 = "Dark",
        effect                  = "AOE Defense Down",
        restriction = nil,
        SMN                     = 75
    },
    ["Chronoshift"] = {
        avatar                  = "Atomos",
        element                 = "Dark",
        effect                  = "Party Haste + Slow",
        restriction = nil,
        SMN                     = 75
    },
    ["Earthen Armor"] = {
        avatar                  = "Titan",
        element                 = "Earth",
        effect                  = "Party Stoneskin",
        restriction = nil,
        SMN                     = 82
    },
    ["Tidal Roar"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        effect                  = "Party Magic Defense Boost",
        restriction = nil,
        SMN                     = 84
    },
    ["Fleet Wind"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        effect                  = "Party Movement Speed",
        restriction = nil,
        SMN                     = 86
    },
    ["Inferno Howl"] = {
        avatar                  = "Ifrit",
        element                 = "Fire",
        effect                  = "Party Magic Attack Boost",
        restriction = nil,
        SMN                     = 88
    },
    ["Wind's Blessing"] = {
        avatar                  = "Siren",
        element                 = "Wind",
        effect                  = "Party Status Ailment Removal",
        restriction = nil,
        SMN                     = 88
    },
    ["Diamond Storm"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        effect                  = "Party Magic Evasion Boost",
        restriction = nil,
        SMN                     = 90
    },
    ["Shock Squall"] = {
        avatar                  = "Ramuh",
        element                 = "Thunder",
        effect                  = "Party Magic Attack Boost",
        restriction = nil,
        SMN                     = 92
    },
    ["Soothing Ruby"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        effect                  = "Party HP Recovery",
        restriction = nil,
        SMN                     = 94
    },
    ["Heavenward Howl"] = {
        avatar                  = "Fenrir",
        element                 = "Dark",
        effect                  = "Party Critical Hit Rate Boost",
        restriction = nil,
        SMN                     = 96
    },
    ["Pavor Nocturnus"] = {
        avatar                  = "Diabolos",
        element                 = "Dark",
        effect                  = "AOE Magic Burst Damage Boost",
        restriction = nil,
        SMN                     = 98
    },

    ---========================================================================
    --- LEVEL 99 WARDS
    ---========================================================================

    ["Pacifying Ruby"] = {
        avatar                  = "Carbuncle",
        element                 = "Light",
        effect                  = "Party Status Ailment Resistance",
        restriction = nil,
        SMN                     = 99
    },
    ["Hastega II"] = {
        avatar                  = "Garuda",
        element                 = "Wind",
        effect                  = "Party Haste (Enhanced)",
        restriction = nil,
        SMN                     = 99
    },
    ["Soothing Current"] = {
        avatar                  = "Leviathan",
        element                 = "Water",
        effect                  = "Party HP Recovery",
        restriction = nil,
        SMN                     = 99
    },
    ["Crystal Blessing"] = {
        avatar                  = "Shiva",
        element                 = "Ice",
        effect                  = "Party Attack/Accuracy Boost",
        restriction = nil,
        SMN                     = 99
    }
}

return ward
