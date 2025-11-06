---============================================================================
--- DNC TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment for Dancer weaponskills.
--- Determines which gear to equip based on current TP to reach 2000/3000 TP thresholds.
---
--- Features:
---   • TP bonus equipment configuration (Moonshade Earring)
---   • Weapon-based TP bonus tracking (REMA daggers)
---   • Automatic TP threshold optimization (2000/3000 TP)
---   • Shared configuration with THF/BRD (REMA daggers)
---   • Intelligent minimum gear selection
---
--- Usage:
---   • Modify pieces table to add/remove TP bonus accessories
---   • Modify weapons table to add/remove REMA weapons with TP bonus
---   • get_weapon_bonus(weapon_name) - Get TP bonus from equipped weapon
---
--- @file    config/dnc/DNC_TP_CONFIG.lua
--- @author  Kaories
--- @version 1.0.0
--- @date    Created: 2025-10-08
---============================================================================

local DNCTPConfig = {
    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- These pieces will be equipped intelligently based on TP thresholds
    -- The calculator will equip the minimum needed to reach 2000 or 3000 TP

    pieces = {
        -- Moonshade in ear1 (left ear) to preserve ear2 (Macu. Earring +1)
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    ---============================================================================
    --- Weapons with automatic TP bonus
    ---============================================================================
    -- These provide TP bonus when equipped as main weapon

    weapons = {
        { name = "Aeneas", bonus = 500 },      -- REMA dagger (shared with THF/BRD)
        { name = "Centovente", bonus = 1000 }  -- High-tier dagger (shared with THF)
    }
}

---============================================================================
--- Get weapon TP bonus if equipped
--- @param weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (0, 500, or 1000)
---============================================================================
function DNCTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end

    for _, weapon in ipairs(DNCTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

-- Make globally available
_G.DNCTPConfig = DNCTPConfig

return DNCTPConfig
