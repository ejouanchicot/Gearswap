---  ═══════════════════════════════════════════════════════════════════════════
---   COR Set Builder - Shared Equipment Set Construction Logic
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides shared logic for building engaged and idle sets with:
---   - Town/Adoulin detection (idle only)
---   - Weapon set application (main/sub/range)
---   - Movement gear application (idle, outside town)
---   - Hybrid mode support (PDT)
---   - sets.idle.Refresh under 50% MP (idle, outside town)
---
---   @file    shared/jobs/cor/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Updated: 2025-10-08 (Refactored to modular architecture)
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')

-- Load message formatter for error reporting
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   TOWN DETECTION (INHERITED FROM BASE)
---  ═══════════════════════════════════════════════════════════════════════════

-- Inherit universal town detection function from BaseSetBuilder
SetBuilder.select_idle_base = BaseSetBuilder.select_idle_base_town

---  ═══════════════════════════════════════════════════════════════════════════
---   SET AUGMENTATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply weapon sets to result: the MainWeapon set (its off-hand weapon only
---   when Dual Wield is there: /NIN or /DNC at a level that has the trait;
---   otherwise sets.SingleWield's sub, or none - WeaponResolver.set_for), then
---   the range weapon
---   @param result table Current equipment set
---   @return table Modified set with weapons applied
function SetBuilder.apply_weapon(result)
    if not result then
        return {}
    end

    result = BaseSetBuilder.lay_weapon(result, 'main', state.MainWeapon and state.MainWeapon.current)

    -- Apply range weapon separately (COR ranged focus)
    if state.RangeWeapon and state.RangeWeapon.current then
        local weapon_set = sets[state.RangeWeapon.current]
        if weapon_set then
            local success, combined = pcall(set_combine, result, weapon_set)
            if success then
                result = combined
            else
                MessageFormatter.show_error(string.format("Failed to apply range weapon: %s", combined))
            end
        end
    end

    return result
end

---   Apply movement speed gear to result (inherited from BaseSetBuilder)
SetBuilder.apply_movement = BaseSetBuilder.apply_movement


---  ═══════════════════════════════════════════════════════════════════════════
---   COMPLETE SET BUILDERS
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete engaged set (Mote's base set + PDT + weapons)
---   @param base_set table Base engaged set from Mote
---   @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Start with base set
    local result = base_set

    -- Step 2: Apply Hybrid mode (PDT)
    if state.HybridMode and state.HybridMode.value == 'PDT' then
        if sets.engaged.PDT then
            local success, combined = pcall(set_combine, result, sets.engaged.PDT)
            if success then
                result = combined
            end
        end
    end

    -- Step 3: Apply weapon sets from states (main+sub together, range separate)
    -- Note: Dual wield is handled here by apply_weapon() - if subjob is NIN/DNC,
    -- the full weapon set (main + sub) is applied. No sets.engaged.DW is
    -- selected anywhere in this builder.
    result = SetBuilder.apply_weapon(result)

    return result
end

---   Build complete idle set (town detection + weapons + PDT + Refresh + movement)
---   @param base_set table Base idle set from Mote
---   @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    -- Step 1: Town/Adoulin detection - use town set as base
    local result, in_town = SetBuilder.select_idle_base(base_set)

    -- Step 2: Apply weapon sets from states (applies to both town and non-town)
    result = SetBuilder.apply_weapon(result)

    -- Step 3: Early return if in town (weapons already applied)
    if in_town then
        return result
    end

    -- Step 4: Apply Hybrid mode (PDT)
    if state.HybridMode and state.HybridMode.value == 'PDT' then
        if sets.idle.PDT then
            local success, combined = pcall(set_combine, result, sets.idle.PDT)
            if success then
                result = combined
            end
        end
    end

    -- Step 5: Apply Refresh gear if MP low. max_mp > 0: a subjob without MP
    -- (NIN, DNC, WAR) must not read as "MP low". Threshold: TUNING.lua
    -- refresh_mp_below.COR
    local mp_below = require('shared/utils/core/tuning').get('refresh_mp_below', {COR = 50}).COR or 50
    if player and (player.max_mp or 0) > 0 and player.mpp and player.mpp < mp_below then
        if sets.idle.Refresh then
            local success, combined = pcall(set_combine, result, sets.idle.Refresh)
            if success then
                result = combined
            end
        end
    end

    -- Step 6: Apply movement speed
    result = SetBuilder.apply_movement(result)

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder
