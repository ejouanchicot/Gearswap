---============================================================================
--- WAR TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment and Warcry settings.
--- Determines which gear to equip based on current TP to reach 2000/3000 TP thresholds.
---
--- Features:
---   • Savagery merit and Agoge Mask configuration
---   • Fencer Job Points Gifts configuration
---   • TP bonus equipment pieces (Moonshade Earring, Boii Cuisses +3, etc.)
---   • Weapon TP bonus detection (Chango +500 TP)
---   • Fencer activation detection (one-handed weapons + shield/empty sub)
---   • Automatic TP threshold calculations (2000/3000 TP)
---
--- @file    config/war/WAR_TP_CONFIG.lua
--- @module  WAR_TP_CONFIG
--- @author  Kaories
--- @version 1.0.0
--- @date    Created: 2025-01-02
---============================================================================
local WARTPConfig = {
    ---==========================================================================
    --- USER CONFIGURATION - Adjust According to Your Character
    ---==========================================================================

    --- Savagery merit points (0-5)
    --- Each merit adds 100 TP bonus to Warcry (140 TP with Agoge Mask).
    --- Example: 5/5 Savagery + Agoge Mask = 700 TP bonus from Warcry
    savagery_merits = 5,

    --- Do you own Agoge Mask? (any version: +1/+2/+3)
    --- Agoge Mask adds +40 TP bonus per merit level (100 → 140 per merit).
    has_agoge_mask = true,

    --- Fencer Job Points Gifts (0-20)
    --- Each JP Gift adds +11.5 TP bonus to Fencer (230 TP at 20/20).
    fencer_jp_gifts = 20,

    ---==========================================================================
    --- TP BONUS EQUIPMENT PIECES
    ---==========================================================================
    --- These pieces will be equipped intelligently based on TP thresholds.
    --- The calculator will equip the minimum needed to reach 2000 or 3000 TP.

    pieces = {{
        slot = "ear1",
        name = "Moonshade Earring",
        bonus = 250
    }, {
        slot = "legs",
        name = "Boii Cuisses +3",
        bonus = 100
    }},

    ---==========================================================================
    --- WEAPONS WITH AUTOMATIC TP BONUS
    ---==========================================================================
    --- These provide TP bonus when equipped as main weapon.

    weapons = {{
        name = "Chango",
        bonus = 500
    }},

    ---==========================================================================
    --- FENCER DETECTION - ONE-HANDED WEAPONS
    ---==========================================================================
    --- Weapons that can trigger Fencer (must be wielded with shield or empty sub).

    one_hand_weapons = {'Naegling', "Ikenga's Axe", 'Loxotic Mace +1'},

    ---==========================================================================
    --- FENCER DETECTION - SHIELDS
    ---==========================================================================
    --- Shields that allow Fencer to activate.
    --- Special: Blurred Shield +1 gives Fencer +1 bonus.

    shields = {'Blurred Shield +1', 'Blurred Shield' -- Add other shields WAR can use here
    },

    ---==========================================================================
    --- FENCER DETECTION - GRIPS/STRAPS (DISABLE FENCER)
    ---==========================================================================
    --- These are NOT shields, so Fencer does NOT activate.

    grips = {'Utu Grip', 'Alber Strap'}
}

---============================================================================
--- CALCULATOR FUNCTIONS
---============================================================================

--- Calculate Warcry TP bonus based on user configuration
--- Formula:
---   • Without Agoge Mask: 100 TP per merit (5/5 merits = 500 TP)
---   • With Agoge Mask:    140 TP per merit (5/5 merits = 700 TP)
---
--- @return number TP bonus from Warcry (0-700)
function WARTPConfig.get_warcry_bonus()
    if WARTPConfig.savagery_merits == 0 then
        return 0
    end

    -- Calculate bonus per merit based on Agoge Mask ownership
    local bonus_per_merit = WARTPConfig.has_agoge_mask and 140 or 100
    return WARTPConfig.savagery_merits * bonus_per_merit
end

--- Get weapon TP bonus if equipped
--- Checks if the specified weapon provides automatic TP bonus.
---
--- @param  weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (0 or 500 for Chango)
function WARTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then
        return 0
    end

    for _, weapon in ipairs(WARTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

--- Get Fencer TP bonus if conditions are met
--- Fencer activates when wielding a one-handed weapon with shield or empty sub.
--- Fencer does NOT activate with grips, straps, or dual-wielded weapons.
---
--- Formula:
---   • Fencer VIII base:     630 TP
---   • Job Points Gifts:     +11.5 TP per gift (230 TP at 20/20)
---   • Blurred Shield +1:    Additional Fencer +1 bonus (not calculated here)
---
--- @param  main_weapon string Name of main weapon
--- @param  sub_weapon  string Name of sub weapon (can be nil/empty)
--- @return number TP bonus from Fencer (0 or 630-860 depending on gear/JP)
function WARTPConfig.get_fencer_bonus(main_weapon, sub_weapon)
    if not main_weapon then
        return 0
    end

    -- Check if main weapon is one-handed
    local is_one_hand = false
    for _, weapon in ipairs(WARTPConfig.one_hand_weapons) do
        if main_weapon == weapon then
            is_one_hand = true
            break
        end
    end

    -- If not 1-hand weapon, Fencer cannot activate
    if not is_one_hand then
        return 0
    end

    -- Fencer activation conditions:
    --   ✓ Sub is empty OR sub is shield
    --   ✗ Sub is grip/strap OR sub is weapon (dual wield)

    -- Case 1: No sub weapon (empty) → Fencer active
    if not sub_weapon or sub_weapon == "" or sub_weapon == "empty" then
        local jp_bonus = WARTPConfig.fencer_jp_gifts * 11.5 -- 11.5 TP per JP Gift
        return 630 + jp_bonus
    end

    -- Case 2: Sub is shield → Fencer active
    for _, shield in ipairs(WARTPConfig.shields) do
        if sub_weapon == shield then
            local jp_bonus = WARTPConfig.fencer_jp_gifts * 11.5
            return 630 + jp_bonus
        end
    end

    -- Case 3: Sub is grip/strap → Fencer inactive (Great Axes use grips)
    for _, grip in ipairs(WARTPConfig.grips) do
        if sub_weapon == grip then
            return 0
        end
    end

    -- Case 4: Sub is anything else (probably a weapon for dual wield) → Fencer inactive
    return 0
end

---============================================================================
--- GLOBAL EXPORT & MODULE RETURN
---============================================================================

-- Make globally available for legacy code
_G.WARTPConfig = WARTPConfig

return WARTPConfig
