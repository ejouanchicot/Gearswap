---============================================================================
--- THF Engaged Module - Combat State Management
---============================================================================
--- Handles combat gear selection and customization for Thief job.
---
--- Features:
---   • Dynamic engaged set selection (Normal/PDT via HybridMode)
---   • Weapon set application (MainWeapon + SubWeapon states)
---   • Movement speed gear (idle only, disabled in combat)
---   • SA/TA buff set application (instant detection via pending flags)
---   • Aftermath detection (REMA weapon bonuses)
---   • SetBuilder integration for modular construction
---
--- Dependencies:
---   • Mote-Include (provides base engaged handling)
---   • SetBuilder logic (constructs final engaged sets)
---   • sets.engaged (base equipment sets)
---   • sets.buff['Sneak Attack'], sets.buff['Trick Attack'] (SA/TA sets)
---
--- @file    jobs/thf/functions/THF_ENGAGED.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

-- Load THF logic modules
local SetBuilder = require('shared/jobs/thf/functions/logic/set_builder')

---============================================================================
--- ENGAGED HOOKS
---============================================================================

--- Apply weapon sets and movement gear to all engaged configurations
--- Also applies SA/TA buff sets when buffs are active
--- @param meleeSet table The engaged set to customize
--- @return table Modified engaged set with current weapon, movement gear, and active buffs
function customize_melee_set(meleeSet)
    if not meleeSet then
        return {}
    end

    -- Build base engaged set (weapons, hybrid mode, movement)
    local result = SetBuilder.build_engaged_set(meleeSet)

    -- Check if SA/TA are active OR pending (just used but buff not yet in buffactive)
    local sa_active = buffactive['Sneak Attack'] or _G.thf_sa_pending
    local ta_active = buffactive['Trick Attack'] or _G.thf_ta_pending

    -- Apply SA/TA buff sets if active or pending (persist until buff consumed)
    if sa_active and ta_active then
        -- Both buffs active (SATA) >> combine both sets
        if sets.buff['Sneak Attack'] and sets.buff['Trick Attack'] then
            result = set_combine(result, sets.buff['Sneak Attack'], sets.buff['Trick Attack'])
        end
    elseif sa_active then
        -- Only Sneak Attack active or pending
        if sets.buff['Sneak Attack'] then
            result = set_combine(result, sets.buff['Sneak Attack'])
        end
    elseif ta_active then
        -- Only Trick Attack active or pending
        if sets.buff['Trick Attack'] then
            result = set_combine(result, sets.buff['Trick Attack'])
        end
    end

    return result
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make customize_melee_set available globally for GearSwap
_G.customize_melee_set = customize_melee_set

-- Also export as module
local THF_ENGAGED = {}
THF_ENGAGED.customize_melee_set = customize_melee_set

return THF_ENGAGED
