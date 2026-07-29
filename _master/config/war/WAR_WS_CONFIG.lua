---============================================================================
--- WAR Weaponskill Slots Configuration
---============================================================================
--- Maps each MainWeapon option to the weaponskills you actually use with it.
--- Instead of one FFXI macro per weaponskill, four or five fixed macros
--- (//gs c ws1 .. //gs c ws5) fire whatever sits in that slot for the weapon
--- currently equipped.
---
--- The lists drive three things:
---   • what //gs c wsN casts
---   • what the HUD shows in the WS section
---   • the options each slot can be cycled through in game
---
--- A weapon may list fewer entries than max_slots; the leftover slots report
--- 'None' and their command does nothing. Order matters: entry 1 lands in WS1.
---
--- Keys MUST match the options of state.MainWeapon in WAR_STATES.lua.
---
--- @file config/war/WAR_WS_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-07-29
---============================================================================

local WARWSConfig = {}

--- Number of //gs c wsN macros wired up.
WARWSConfig.max_slots = 5

--- Weaponskills per weapon, in slot order.
WARWSConfig.by_weapon = {
    -- Great Axe (Empyrean)
    Ukonvasara = {
        "Ukko's Fury",
        'Upheaval',
        'Fell Cleave',
        'Armor Break',
        'Steel Cyclone',
    },

    -- Great Axe (Aeonic)
    Chango = {
        'Upheaval',
        "Ukko's Fury",
        'Fell Cleave',
        'Steel Cyclone',
    },

    -- Polearm
    Shining = {
        'Impulse Drive',
        'Stardiver',
        'Leg Sweep',
        'Sonic Thrust',
    },

    -- Axe (one-handed)
    Ikenga = {
        'Decimation',
        'Calamity',
        'Bora Axe',
        'Mistral Axe',
    },

    -- Sword
    Naegling = {
        'Savage Blade',
        'Sanguine Blade',
        'Circle Blade',
    },

    -- Sword + Kraken Club: multi-attack build, same shortlist as Naegling
    NaeglingKC = {
        'Savage Blade',
        'Sanguine Blade',
        'Circle Blade',
    },

    -- Club
    Loxotic = {
        'Judgment',
        'Black Halo',
        'True Strike',
    },
}

--- Weaponskill list for a weapon key
--- @param weapon string Value of state.MainWeapon
--- @return table List of weaponskill names (empty when the weapon is unknown)
function WARWSConfig.get(weapon)
    if not weapon then return {} end
    return WARWSConfig.by_weapon[weapon] or {}
end

return WARWSConfig
