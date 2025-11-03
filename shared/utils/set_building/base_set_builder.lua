---============================================================================
--- Base Set Builder - Universal Set Construction Functions
---============================================================================
--- Provides common set building functions used by ALL jobs.
--- Each job's set_builder.lua inherits these functions to avoid code duplication.
---
--- Features:
---   • Movement gear application (idle only, never in combat)
---   • Town/Adoulin detection (idle only)
---   • Shared logic for all 9 production jobs
---   • Error handling with MessageFormatter
---   • Safe pcall for set_combine operations
---
--- Design Philosophy:
---   Jobs inherit these functions via simple assignment:
---   SetBuilder.apply_movement = BaseSetBuilder.apply_movement
---
---   This allows jobs to override if needed while keeping 99% shared.
---
--- @file    utils/set_building/base_set_builder.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-17
---============================================================================

local BaseSetBuilder = {}

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- MOVEMENT GEAR (UNIVERSAL - IDLE ONLY)
---============================================================================

--- Apply movement speed gear if moving (idle state only)
--- Used by: WAR, PLD, DNC, THF, COR, GEO, BRD, RDM, BLM (9/9 jobs)
--- @param result table Current equipment set
--- @return table Set with movement speed applied (or unchanged if not moving)
function BaseSetBuilder.apply_movement(result)
    if state.Moving and state.Moving.value == 'true' and sets.MoveSpeed then
        local success, combined = pcall(set_combine, result, sets.MoveSpeed)
        if success then
            return combined
        else
            MessageFormatter.show_error(string.format('Failed to apply MoveSpeed: %s', combined))
        end
    end
    return result
end

---============================================================================
--- TOWN DETECTION (UNIVERSAL - IDLE ONLY)
---============================================================================

--- Detect if player is in town/Adoulin and return appropriate set
--- Checks Adoulin zones first (movement bonus), then regular cities.
--- Excludes Dynamis zones (technically cities but not safe).
---
--- Used by: WAR, PLD, DNC, THF, COR, GEO, BLM (7/9 jobs)
--- Not used by: BRD, RDM (have their own check_town variant)
---
--- @param base_set table Base idle set
--- @return table selected_set Modified set (or town/Adoulin set)
--- @return boolean is_in_town True if town gear applied
function BaseSetBuilder.select_idle_base_town(base_set)
    if world and world.area then
        -- Check Adoulin zones first (specific city with movement bonus)
        if world.area == 'Western Adoulin' or world.area == 'Eastern Adoulin' then
            if sets and sets.Adoulin then
                return sets.Adoulin, true
            end
        end

        -- Check regular cities
        if areas and areas.Cities and areas.Cities:contains(world.area) then
            -- Exclude Dynamis zones (they're technically cities but not safe)
            local not_dynamis = not world.area:contains('Dynamis')
            if not_dynamis and sets and sets.idle and sets.idle.Town then
                return sets.idle.Town, true
            end
        end
    end
    return base_set, false
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BaseSetBuilder
