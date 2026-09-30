---  ═══════════════════════════════════════════════════════════════════════════
---   Set Builder - Shared Set Construction Logic (SAM)
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized set building for both engaged and idle states.
---   Handles:
---   • Aftermath Lv.3 detection and specialized gear application
---   • Weapon selection and set application
---   • HP-based idle variations (Weak, Regen)
---   • Seigan/Third Eye buff handling
---   • Bow (Yoichinoyumi) handling
---   • HybridMode support (PDT/Normal)
---
---   Used by: SAM_IDLE.lua and SAM_ENGAGED.lua
---
---   @file    shared/jobs/sam/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-21
---  ═══════════════════════════════════════════════════════════════════════════
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')
local SetBuilder = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE SET CONSTRUCTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Put the MainWeapon state's weapon set on (it carries the sub weapon)
---   @param result table
---   @return table
function SetBuilder.apply_main_weapon(result)
    return BaseSetBuilder.lay_weapon(result, 'main', state and state.MainWeapon and state.MainWeapon.value)
end

---   Build idle set with HP-based variations and HybridMode
---   Order (each layer goes on top of the previous one):
---   0. In a city: town set on top of the idle, weapon, nothing else (as on
---      the other jobs)
---   1. HybridMode (PDT) >> sets.idle.PDT
---   2. Weak (HP < 50%) >> sets.idle.Weak, else Regen (HP < 80%) >> sets.idle.Regen
---   3. Apply weapon
---   4. sets.MoveSpeed while running
---
---   @param base_set table Base idle set from sam_sets.lua
---   @return table Complete idle set with all modifications
function SetBuilder.build_idle_set(base_set)
    if not base_set then
        return {}
    end

    local result, in_town = BaseSetBuilder.select_idle_base_town(base_set)
    if in_town then
        return SetBuilder.apply_main_weapon(result)
    end

    -- HybridMode PDT first: sets.idle.PDT is a whole set, and laid last it
    -- covered the Weak / Regen pieces, which were then never worn in PDT
    -- (the default mode)
    if state and state.HybridMode and state.HybridMode.value == 'PDT' then
        if sets.idle and sets.idle.PDT then
            result = set_combine(result, sets.idle.PDT)
        end
    end

    -- Then HP: Weak (HP < 50%), else Regen (HP < 80%), on top
    -- (_common/combat/TUNING.lua sam_idle_hp)
    if player then
        local hp = require('shared/utils/core/tuning').get('sam_idle_hp', {weak_below = 50, regen_below = 80})
        if player.hpp < hp.weak_below and sets.idle and sets.idle.Weak then
            result = set_combine(result, sets.idle.Weak)
        elseif player.hpp < hp.regen_below and sets.idle and sets.idle.Regen then
            result = set_combine(result, sets.idle.Regen)
        end
    end

    -- Priority 4: Apply main weapon (includes sub weapon in set)
    result = SetBuilder.apply_main_weapon(result)

    -- Movement speed while running (AutoMove sets state.Moving), as on the
    -- other jobs: sam_sets.lua defines sets.MoveSpeed
    return BaseSetBuilder.apply_movement(result)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED SET CONSTRUCTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Build engaged set with Seigan/Third Eye buff handling
---   Priority:
---   0. Base: AM3 set, else the OffenseMode / HybridMode set, else Mote's base
---   1. Seigan buff >> thirdeye set (PDT) or seigan set (Normal)
---   2. Apply weapon
---   3. Bow equipped (Yoichinoyumi) >> bow set
---
---   Mote nests HybridMode under the OffenseMode node (sets.engaged.Normal.PDT),
---   so its base never reaches the sibling sets.engaged.PDT; the base is
---   re-selected here.
---
---   @param base_set table Base engaged set from sam_sets.lua
---   @return table Complete engaged set with all modifications
function SetBuilder.build_engaged_set(base_set)
    if not base_set then
        return {}
    end

    local result = SetBuilder.select_engaged_base(base_set)

    -- Priority 1: Seigan buff handling
    if buffactive and buffactive['Seigan'] then
        if state and state.HybridMode and state.HybridMode.value == 'PDT' then
            -- PDT mode + Seigan >> Third Eye set (defensive)
            if sets.thirdeye then
                result = set_combine(result, sets.thirdeye)
            end
        else
            -- Normal mode + Seigan >> Seigan set (balanced)
            if sets.seigan then
                result = set_combine(result, sets.seigan)
            end
        end
    end

    -- Priority 2: Apply current main weapon (includes sub weapon in set)
    result = SetBuilder.apply_main_weapon(result)

    -- Priority 3: Bow equipped handling (Yoichinoyumi)
    if player and player.equipment and player.equipment.range == 'Yoichinoyumi' then
        if sets.bow then
            result = set_combine(result, sets.bow)
        end
    end

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED BASE SELECTION (Aftermath Lv.3, HybridMode)
---  ═══════════════════════════════════════════════════════════════════════════

---   Select engaged base set with Aftermath Lv.3 detection
---   Aftermath Lv.3 (buff ID: 272) + Weapon with AM3 = Use specialized AM3 set
---
---   Priority order:
---   1. Aftermath Lv.3 + Masamune/Kogarasumaru >> sets.engaged.AM3
---   2. OffenseMode node >> its HybridMode variant, else sets.engaged[HybridMode]
---   3. Fallback >> base_set
---
---   @param base_set table Base engaged set from sam_sets.lua
---   @return table Selected engaged set (AM3 if conditions met, otherwise hybrid/base)
function SetBuilder.select_engaged_base(base_set)
    -- Check for Aftermath Lv.3 (buff ID 272) + Mythic/Empyrean weapon
    if buffactive[272] then
        local am3_weapons = {
            ['Masamune'] = true,
            ['Kogarasumaru'] = true
        }

        if state.MainWeapon and am3_weapons[state.MainWeapon.current] then
            if sets.engaged.AM3 then
                return sets.engaged.AM3
            end
        end
    end

    -- OffenseMode picks the accuracy node, HybridMode its variant: a defensive
    -- HybridMode wins when the node has no variant for it (Mid + PDT -> PDT)
    local offense = state.OffenseMode and state.OffenseMode.current or 'Normal'
    local hybrid = state.HybridMode and state.HybridMode.current or 'Normal'
    local node = sets.engaged[offense] or sets.engaged.Normal
    if hybrid ~= 'Normal' then
        return (node and node[hybrid]) or sets.engaged[hybrid] or node or base_set
    end
    return node or base_set
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder
