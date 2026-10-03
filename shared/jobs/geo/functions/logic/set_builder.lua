---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Set Builder - Shared Equipment Set Construction Logic
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides shared logic for building engaged and idle sets with:
---   - Luopan detection (sets.me.* vs sets.luopan.*)
---   - HybridMode base without a luopan (sets.idle/engaged.PDT or .Normal)
---   - Town/Adoulin detection (idle only)
---   - Weapon set application (MainWeapon / SubWeapon states)
---   - Movement gear application (idle only)
---
---   GEO has two distinct set configurations:
---   sets.me.*     - No Luopan active (focus: refresh, defense)
---   sets.luopan.* - Luopan active (focus: Pet DT-, Pet Regen)
---
---   @file    shared/jobs/geo/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-09
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')


---  ═══════════════════════════════════════════════════════════════════════════
---   SET AUGMENTATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply weapon sets to result
---   GEO uses main weapon + sub weapon (shield)
---   Note: CombatMode weapon locking is done by
---   shared/utils/core/combat_mode.lua, not here
---   @param result table Current equipment set
---   @return table Modified set with weapons applied
function SetBuilder.apply_weapon(result)
    if not result then
        return {}
    end
    return BaseSetBuilder.lay_weapons(result)
end

---   Apply movement speed gear to result (inherited from BaseSetBuilder)
SetBuilder.apply_movement = BaseSetBuilder.apply_movement

---   Base set when no luopan is out, chosen by HybridMode.
---   The mode sets are sets.idle.PDT / .Normal and sets.engaged.PDT / .Normal;
---   the set files point both at sets.me today, so the two modes wear the same
---   gear until one of them is given its own.
---   @param mode_sets table sets.idle or sets.engaged
---   @param fallback table sets.me.idle or sets.me.engaged
---   @return table Selected base set
local function select_hybrid_base(mode_sets, fallback)
    local mode = state.HybridMode and state.HybridMode.current
    if mode and mode_sets and mode_sets[mode] then
        return mode_sets[mode]
    end
    return fallback or {}
end

---  ═══════════════════════════════════════════════════════════════════════════
---   COMPLETE SET BUILDERS
---  ═══════════════════════════════════════════════════════════════════════════

---   Build complete engaged set (base selection + LuopanMode + weapons)
---   @param base_set table Base engaged set from Mote (ignored - we use sets.me/luopan)
---   @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    -- Step 1: Select base set based on Luopan status
    local result
    if pet and pet.isvalid then
        -- A character's set file may leave out sets.luopan.engaged or sets.me:
        -- read them through locals rather than raise while a luopan is out.
        local luopan_engaged = sets.luopan and sets.luopan.engaged or {}
        local me_engaged = sets.me and sets.me.engaged
        -- Luopan active - check LuopanMode state
        if state.LuopanMode and state.LuopanMode.current then
            local mode = state.LuopanMode.current

            -- Select set based on LuopanMode (DT or DPS)
            if mode == 'DT' and luopan_engaged.DT then
                result = luopan_engaged.DT
            elseif mode == 'DPS' and luopan_engaged.DPS then
                result = luopan_engaged.DPS
            else
                -- Fallback to DT if state invalid
                result = luopan_engaged.DT or me_engaged or {}
            end
        else
            -- No LuopanMode state - fallback to DT
            result = luopan_engaged.DT or me_engaged or {}
        end
    else
        -- No Luopan - use standard engaged set
        result = select_hybrid_base(sets.engaged, sets.me.engaged)
    end
    -- the party support's version of it (.Solo, .Group: shared/utils/party/support_tier.lua)
    result = require('shared/utils/party/support_tier').engaged(result)

    -- Step 2: Apply weapon sets from states
    result = SetBuilder.apply_weapon(result)

    return result
end

---   Build complete idle set (Luopan detection + town detection + weapons + movement)
---   @param base_set table Base idle set from Mote (ignored - we use sets.me/luopan)
---   @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    -- Step 1: Select base set based on Luopan status (MOST IMPORTANT)
    local result
    if pet and pet.isvalid then
        -- Luopan active - use pet survival set (Pet DT, Pet Regen priority)
        result = sets.luopan.idle or sets.me.idle or {}
    else
        -- No Luopan - use standard idle set
        result = select_hybrid_base(sets.idle, sets.me.idle)
    end

    -- Step 2: Town detection - use town set if in town (inherited from BaseSetBuilder)
    -- Note: Town gear overrides Luopan gear (safety priority in cities)
    local town_result, in_town = BaseSetBuilder.select_idle_base_town(result)
    result = town_result

    -- Step 3: Apply weapon sets from states
    result = SetBuilder.apply_weapon(result)

    -- Step 4: Apply movement speed (if not in town)
    if not in_town then
        result = SetBuilder.apply_movement(result)
    end

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder
