---============================================================================
--- PLD Weaponskill Slots Configuration
---============================================================================
--- Maps each weapon to the weaponskills you actually use with it. Instead of
--- one FFXI macro per weaponskill, two fixed macros (//gs c ws1, //gs c ws2)
--- fire whatever sits in that slot for the weapon currently in hand.
---
--- The lists drive three things:
---   • what //gs c wsN casts
---   • what the HUD shows in the WS section
---   • the options each slot can be cycled through in game
---
--- Savage Blade sits in slot 1 on every weapon: it is the one weaponskill all
--- three swords can use, so the same key always does the same thing. Slot 2
--- holds what the weapon alone unlocks - Knights of Round needs Excalibur,
--- Atonement needs Burtgang. Naegling unlocks neither, so its slot 2 reports
--- 'None' and its command does nothing.
---
--- Keys MUST match the weapon set names in pld_sets.lua (sets.Excalibur, ...),
--- which are also the options of state.MainWeapon.
---
--- @file config/pld/PLD_WS_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-21
---============================================================================

local PLDWSConfig = {}

--- Number of //gs c wsN macros wired up.
PLDWSConfig.max_slots = 2

--- Weaponskills per weapon, in slot order.
PLDWSConfig.by_weapon = {
    -- Relic sword: Knights of Round is its own weaponskill
    Excalibur = {
        'Savage Blade',
        'Knights of Round',
    },

    -- Mythic sword: Atonement is its own weaponskill, and spends TP on enmity
    Burtgang = {
        'Savage Blade',
        'Atonement',
    },

    -- Savage Blade is the whole point of this one
    Naegling = {
        'Savage Blade',
    },
}

--- Weaponskill list for a weapon, empty when the weapon has none configured.
--- @param weapon string|nil Weapon key (a state.MainWeapon option)
--- @return table List of weaponskill names, in slot order
function PLDWSConfig.get(weapon)
    if not weapon then
        return {}
    end
    return PLDWSConfig.by_weapon[weapon] or {}
end

return PLDWSConfig
