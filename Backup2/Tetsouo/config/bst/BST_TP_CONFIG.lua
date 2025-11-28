---============================================================================
--- BST TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment for Beastmaster.
--- BST can engage in melee combat alongside their pet.
---
--- Features:
---   • TP bonus equipment pieces (Moonshade Earring, etc.)
---   • Weapon TP bonus detection
---   • Automatic TP threshold calculations (2000/3000 TP)
---
--- @file    config/bst/BST_TP_CONFIG.lua
--- @module  BST_TP_CONFIG
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-22
---============================================================================
local BSTTPConfig = {
    ---==========================================================================
    --- USER CONFIGURATION - Adjust According to Your Character
    ---==========================================================================

    --- Fencer Job Points Gifts (0-4)
    --- Number of JP Gift ranks obtained for Fencer TP Bonus.
    --- Fencer grants TP bonus when single-wielding (main hand only or with shield).
    ---
    --- Base Fencer (job trait): +200 (Lv80), +300 (Lv87), +400 (Lv94)
    ---
    --- JP Gift Ranks:
    ---   Rank 1 (150 JP):  +50 TP
    ---   Rank 2 (500 JP):  +50 TP
    ---   Rank 3 (1125 JP): +60 TP
    ---   Rank 4 (2000 JP): +70 TP
    ---
    --- Examples:
    ---   0 = No JP Gifts >> Base only (+200/300/400)
    ---   1 = Rank 150 only >> Base +50
    ---   2 = Ranks 150+500 >> Base +100
    ---   3 = Ranks 150+500+1125 >> Base +160
    ---   4 = All ranks >> Base +230 (max)
    fencer_jp_gifts = 4,
    ---==========================================================================
    --- TP BONUS EQUIPMENT PIECES
    ---==========================================================================
    --- These pieces will be equipped intelligently based on TP thresholds.
    --- The calculator will equip the minimum needed to reach 2000 or 3000 TP.

    pieces = {
        {
            slot = 'ear1',
            name = 'Moonshade Earring',
            bonus = 250
        }
    },
    ---==========================================================================
    --- WEAPONS WITH AUTOMATIC TP BONUS
    ---==========================================================================
    --- These provide TP bonus when equipped as main weapon.

    weapons = {}
}

---============================================================================
--- CALCULATOR FUNCTIONS
---============================================================================

--- Get weapon TP bonus if equipped
--- Checks if the specified weapon provides automatic TP bonus.
---
--- @param  weapon_name string Name of the main weapon
--- @return number TP bonus from weapon
function BSTTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then
        return 0
    end

    for _, weapon in ipairs(BSTTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

--- Get Fencer TP bonus if single-wielding
--- Fencer grants TP bonus when wielding main hand only (no sub weapon OR with shield).
--- Base bonus depends on job level (BST trait):
---   - Lv 94+: +400 TP (Tier III)
---   - Lv 87-93: +300 TP (Tier II)
---   - Lv 80-86: +200 TP (Tier I)
--- JP Gifts add additional bonus (up to +230 TP total).
---
--- @param  weapon_name string Name of the main weapon (optional, for future checks)
--- @param  sub_weapon string Name of the sub weapon (optional, to check single-wield)
--- @return number TP bonus from Fencer (0 if dual-wielding)
function BSTTPConfig.get_fencer_bonus(weapon_name, sub_weapon)
    -- Fencer activation logic for BST:
    -- BST can ONLY dual-wield if subjob is NIN or DNC.
    -- If subjob is NOT NIN/DNC >> Fencer is ALWAYS active (cannot dual-wield)
    -- If subjob IS NIN/DNC >> Check equipment (must have sub weapon to dual-wield)

    local is_fencer_active = false

    -- Get current subjob
    local subjob = player and player.sub_job or nil

    -- Check if dual-wield is possible based on subjob
    if subjob ~= 'NIN' and subjob ~= 'DNC' then
        -- Cannot dual-wield >> Fencer ALWAYS active
        is_fencer_active = true
    else
        -- Can dual-wield (NIN or DNC subjob) >> Check if actually dual-wielding
        local sub_name = sub_weapon
        if not sub_name and player and player.equipment then
            sub_name = player.equipment.sub
        end

        -- If no sub weapon OR sub is shield/grip >> Fencer active
        if not sub_name or sub_name == 'empty' or sub_name == '' then
            is_fencer_active = true
        else
            -- Sub equipped: assume dual-wielding (weapon in sub) >> Fencer inactive
            is_fencer_active = false
        end
    end

    if not is_fencer_active then
        return 0
    end

    -- Calculate base Fencer bonus based on job level
    local base_bonus = 0
    if player and player.main_job_level then
        local level = player.main_job_level
        if level >= 94 then
            base_bonus = 400 -- Tier III
        elseif level >= 87 then
            base_bonus = 300 -- Tier II
        elseif level >= 80 then
            base_bonus = 200 -- Tier I
        end
    end

    -- Calculate JP Gifts bonus based on number of ranks obtained
    local jp_bonus = 0
    if BSTTPConfig.fencer_jp_gifts >= 1 then
        jp_bonus = jp_bonus + 50 -- Rank 1 (150 JP)
    end
    if BSTTPConfig.fencer_jp_gifts >= 2 then
        jp_bonus = jp_bonus + 50 -- Rank 2 (500 JP)
    end
    if BSTTPConfig.fencer_jp_gifts >= 3 then
        jp_bonus = jp_bonus + 60 -- Rank 3 (1125 JP)
    end
    if BSTTPConfig.fencer_jp_gifts >= 4 then
        jp_bonus = jp_bonus + 70 -- Rank 4 (2000 JP)
    end

    return base_bonus + jp_bonus
end

---============================================================================
--- GLOBAL EXPORT & MODULE RETURN
---============================================================================

-- Make globally available for legacy code
_G.BSTTPConfig = BSTTPConfig

return BSTTPConfig
