---============================================================================
--- Base Set Builder - Universal Set Construction Functions
---============================================================================
--- Provides common set building functions used by ALL jobs.
--- Each job's set_builder.lua inherits these functions to avoid code duplication.
---
--- Features:
---   • Movement gear application (idle only, never in combat)
---   • Town/Adoulin detection (idle only)
---   • Error handling with MessageFormatter
---   • Safe pcall for set_combine operations
---
--- Design Philosophy:
---   Jobs inherit these functions via simple assignment:
---   SetBuilder.apply_movement = BaseSetBuilder.apply_movement
---
---   This allows jobs to override if needed while keeping 99% shared.
---
--- @file    shared/utils/set_building/base_set_builder.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2025-10-17
---============================================================================

local BaseSetBuilder = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- MOVEMENT GEAR (UNIVERSAL - IDLE ONLY)
---============================================================================

--- Apply movement speed gear if moving (idle state only)
--- Used by: BLM, BRD, COR, DNC, DRK, GEO, PLD, RDM, RUN, SAM, SMN, THF, WAR, WHM
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
--- Used by: BLM, BRD, COR, DNC, DRK, GEO, PLD, RDM (as SetBuilder.check_town),
--- RUN, SAM, SMN, THF, WAR, WHM
---
--- The town set goes ON TOP of the idle set: a partial one (MoveSpeed feet,
--- Councilor's Garb) keeps the idle pieces in the other slots. In a city
--- Mote itself already picks sets.idle.Town (or its IdleMode child) as the idle
--- base; when base_set is that town node, the idle underneath is rebuilt as
--- Mote would pick it in the field (sets.idle, then its IdleMode child) and
--- the town node goes on top. A base the job chose itself (a luopan or mode
--- set) is kept. Until 2026-09-29 the town set replaced the idle set, and every
--- slot it left out kept whatever was worn on arrival.
--- @param base_set table Base idle set
--- @return table selected_set Idle set with the town/Adoulin set on top
--- @return boolean is_in_town True if town gear applied
function BaseSetBuilder.select_idle_base_town(base_set)
    if not (world and world.area) then
        return base_set, false
    end

    local in_adoulin = world.area == 'Western Adoulin' or world.area == 'Eastern Adoulin'
    local in_city = areas and areas.Cities and areas.Cities:contains(world.area)
        and not world.area:contains('Dynamis')   -- cities, but not safe

    local town = sets and sets.idle and sets.idle.Town
    local mode = state and state.IdleMode and state.IdleMode.current
    local is_mote_town = town ~= nil and base_set ~= nil
        and (base_set == town or (mode ~= nil and base_set == town[mode]))

    local idle = base_set or {}
    if is_mote_town then
        idle = sets.idle
        if mode and type(idle[mode]) == 'table' then idle = idle[mode] end
    end

    -- Adoulin first: it has its own set (movement bonus)
    if in_adoulin and sets and sets.Adoulin then
        return set_combine(idle, sets.Adoulin), true
    end
    if in_city and town then
        return set_combine(idle, is_mote_town and base_set or town), true
    end
    return base_set, false
end

--- Pure town detection (no set coupling). For callers that apply their own
--- town gear instead of a flat sets.idle.Town (e.g. BST nested sets.me.idle.Town).
--- Adoulin counts as town. Dynamis zones are excluded (technically cities, not safe).
--- @return boolean in_town True if in a city/Adoulin
function BaseSetBuilder.is_in_town()
    if world and world.area then
        if world.area == 'Western Adoulin' or world.area == 'Eastern Adoulin' then
            return true
        end
        if areas and areas.Cities and areas.Cities:contains(world.area)
            and not world.area:contains('Dynamis') then
            return true
        end
    end
    return false
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BaseSetBuilder
