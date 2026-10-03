---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Set Builder - Complete Equipment Set Construction Logic
---  ═══════════════════════════════════════════════════════════════════════════
---   Builds the engaged and idle sets on top of the set Mote selected:
---   - Engaged: MainWeapon / SubWeapon sets
---   - Idle: DeathMode / HybridMode base, town base (BaseSetBuilder), weapons,
---     movement gear outside town, Mana Wall set while the buff is up
---
---   @file    shared/jobs/blm/functions/logic/set_builder.lua
---   @author  ejouanchicot
---   @version 2.0 (Merged with SET_CUSTOMIZATION.lua)
---   @date    Created: 2025-10-15 | Migrated: 2025-10-15
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

-- Load base set builder (universal functions)
local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')


---  ═══════════════════════════════════════════════════════════════════════════
---   SET AUGMENTATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Apply weapon sets to result
---   BLM uses main weapon + sub weapon
---   Note: Combat Mode locking is done by shared/utils/core/combat_mode.lua
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

---  ═══════════════════════════════════════════════════════════════════════════
---   COMPLETE SET BUILDERS
---  ═══════════════════════════════════════════════════════════════════════════

---   The mode's own set in a group, when it has one: DeathMode On ->
---   <group>.Death (idle only: Death hits for MP x 3, so the idle keeps the
---   MP up), HybridMode PDT -> <group>.PDT. Mote picks by IdleMode /
---   OffenseMode only, so neither mode would change anything otherwise.
---   @param group table sets.idle or sets.engaged
---   @param base_set table Set Mote selected
---   @param allow_death boolean Whether DeathMode applies to this group
---   @return table
local function mode_base(group, base_set, allow_death)
    if not group then return base_set end
    if allow_death and state.DeathMode and state.DeathMode.value == 'On' and group.Death then
        return group.Death
    end
    if state.HybridMode and state.HybridMode.value == 'PDT' and group.PDT then
        return group.PDT
    end
    return base_set
end

---   Build complete engaged set (Mote's base set + weapons)
---   @param base_set table Base engaged set from Mote
---   @return table Complete engaged set
function SetBuilder.build_engaged_set(base_set)
    -- Step 1: Mote's base set, or the HybridMode PDT set
    local result = mode_base(sets.engaged, base_set or sets.engaged.Normal or {}, false)
    -- the party support's version of it (.Solo, .Group: shared/utils/party/support_tier.lua)
    result = require('shared/utils/party/support_tier').engaged(result)

    -- Step 2: Apply weapon sets from states
    result = SetBuilder.apply_weapon(result)

    return result
end

---   Build complete idle set (town detection + weapons + movement + Mana Wall)
---   @param base_set table Base idle set from Mote
---   @return table Complete idle set
function SetBuilder.build_idle_set(base_set)
    -- Step 1: Mote's base set, or the DeathMode / HybridMode PDT set
    local result = mode_base(sets.idle, base_set or sets.idle.Normal or {}, true)

    -- Step 2: Town detection - use town set as base (inherited from BaseSetBuilder)
    local town_result, in_town = BaseSetBuilder.select_idle_base_town(result)
    result = town_result

    -- Step 3: Apply weapon sets from states
    result = SetBuilder.apply_weapon(result)

    -- Step 4: Apply movement speed (if not in town)
    if not in_town then
        result = SetBuilder.apply_movement(result)
    end

    -- Step 5: Apply BLM-specific buff gear (Manawall)
    if buffactive and buffactive['Mana Wall'] and sets.buff and sets.buff['Mana Wall'] then
        local success, combined = pcall(set_combine, result, sets.buff['Mana Wall'])
        if success then
            result = combined
        end
    end

    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return SetBuilder
