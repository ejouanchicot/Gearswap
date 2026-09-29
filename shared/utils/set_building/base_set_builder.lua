---============================================================================
--- Base Set Builder - Universal Set Construction Functions
---============================================================================
--- Provides common set building functions used by ALL jobs.
--- Each job's set_builder.lua inherits these functions to avoid code duplication.
---
--- Features:
---   • Movement gear application (idle only, never in combat)
---   • Town/Adoulin detection (idle only)
---   • Idle base by HybridMode outside town (select_idle_base)
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
local WeaponResolver = require('shared/utils/equipment/weapon_resolver')

---============================================================================
--- MOVEMENT GEAR (UNIVERSAL - IDLE ONLY)
---============================================================================

--- Apply movement speed gear if moving (idle state only)
--- Used by: BLM, BLU, BRD, BST, COR, DNC, DRK, GEO, PLD, RDM, RUN, SAM, SMN, THF,
--- WAR, WHM (every job but PUP, which has no set builder)
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
--- WEAPONS (UNIVERSAL)
---============================================================================

--- Lay the set of a weapon state value on top: WeaponResolver.set_for(slot,
--- value), i.e. sets[value], or the item by name when WEAPON_CONFIG's
--- equip_without_set is on. Unchanged when the value has no set.
--- @param result table Current equipment set
--- @param slot string 'main' or 'sub'
--- @param value string|nil State value (e.g. state.MainWeapon.current)
--- @return table
function BaseSetBuilder.lay_weapon(result, slot, value)
    local weapon_set = value and WeaponResolver.set_for(slot, value)
    if not weapon_set then
        return result
    end
    local ok, combined = pcall(set_combine, result, weapon_set)
    if ok then
        return combined
    end
    MessageFormatter.show_error(string.format('Failed to apply %s weapon %s: %s',
        slot, tostring(value), tostring(combined)))
    return result
end

--- Kraken Club still in the off hand while the chosen main weapon's set names
--- no sub: right after leaving a Kraken weapon set (WAR NaeglingKC, PLD
--- BurtgangKC) the club stays in hand for one rebuild, before the new
--- weapon's sub replaces it, and the Kraken engaged set must hold till then.
--- Used by: PLD, WAR
--- @return boolean
function BaseSetBuilder.kraken_in_offhand()
    local chosen = state.MainWeapon and sets[state.MainWeapon.current]
    if type(chosen) == 'table' and chosen.sub then
        return false
    end
    return player ~= nil and player.equipment ~= nil and player.equipment.sub == 'Kraken Club'
end

--- Lay the MainWeapon state's set, then the SubWeapon state's.
--- Used by: BLM, BLU, BRD, GEO, RDM, THF
--- @param result table Current equipment set
--- @return table
function BaseSetBuilder.lay_weapons(result)
    result = BaseSetBuilder.lay_weapon(result, 'main', state.MainWeapon and state.MainWeapon.current)
    return BaseSetBuilder.lay_weapon(result, 'sub', state.SubWeapon and state.SubWeapon.current)
end

---============================================================================
--- TOWN DETECTION (UNIVERSAL - IDLE ONLY)
---============================================================================

--- Where the player stands: 'adoulin' (Western/Eastern Adoulin), 'city' (any
--- other areas.Cities zone), or nil. Dynamis zones are cities in the list but
--- not safe, so they count as neither.
--- @return string|nil
local function town_zone()
    if not (world and world.area) then return nil end
    if world.area == 'Western Adoulin' or world.area == 'Eastern Adoulin' then
        return 'adoulin'
    end
    if areas and areas.Cities and areas.Cities:contains(world.area)
        and not world.area:contains('Dynamis') then
        return 'city'
    end
    return nil
end

--- Lay a town set ON TOP of an idle set: sets.Adoulin in Adoulin when it
--- exists, else `town_set` in any city (Adoulin included). A partial town set
--- (movement feet, Councilor's Garb) keeps the idle pieces in its other slots.
--- @param idle table Idle set underneath
--- @param town_set table|nil The job's town set
--- @return table|nil set Idle with the town set on top, nil when not applied
local function lay_town(idle, town_set)
    local zone = town_zone()
    if zone == 'adoulin' and sets and sets.Adoulin then
        return set_combine(idle, sets.Adoulin)
    end
    if zone and town_set then
        return set_combine(idle, town_set)
    end
    return nil
end

--- Lay the job's own town set on top of an idle it built itself (BST: the
--- nested sets.me.idle.Town over the pet or master idle).
--- @param idle table Idle set underneath
--- @param town_set table|nil The job's town set
--- @return table selected_set
--- @return boolean is_in_town True when a town set was laid
function BaseSetBuilder.lay_town_set(idle, town_set)
    local result = lay_town(idle, town_set)
    if result then return result, true end
    return idle, false
end

--- Detect if player is in town/Adoulin and return appropriate set
--- Checks Adoulin zones first (movement bonus), then regular cities.
--- Excludes Dynamis zones (technically cities but not safe).
---
--- Used by: BLM, BLU and RDM (both as SetBuilder.check_town), BRD, COR, GEO, PLD,
--- RUN, SAM, SMN, WHM; DNC, DRK, THF, WAR through select_idle_base
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
    local town = sets and sets.idle and sets.idle.Town
    local mode = state and state.IdleMode and state.IdleMode.current
    local is_mote_town = town ~= nil and base_set ~= nil
        and (base_set == town or (mode ~= nil and base_set == town[mode]))

    local idle = base_set or {}
    if is_mote_town then
        idle = sets.idle
        if mode and type(idle[mode]) == 'table' then idle = idle[mode] end
    end

    local result = lay_town(idle, is_mote_town and base_set or town)
    if result then return result, true end
    return base_set, false
end

--- Idle base: the town set in a city (select_idle_base_town), else the
--- HybridMode idle set, else Mote's base. HybridMode is what the player
--- toggles for PDT on the melee jobs, and Mote's idle only follows IdleMode:
--- without this, sets.idle.PDT is never worn outside town.
--- Used by: DNC, DRK, THF, WAR
--- @param base_set table Base idle set from Mote-Include
--- @return table selected_set
--- @return boolean is_in_town
function BaseSetBuilder.select_idle_base(base_set)
    local town_set, in_town = BaseSetBuilder.select_idle_base_town(base_set)
    if in_town then
        return town_set, true
    end
    local mode = state and state.HybridMode and state.HybridMode.current
    local hybrid_set = mode and sets and sets.idle and sets.idle[mode]
    if type(hybrid_set) == 'table' then
        return hybrid_set, false
    end
    return base_set, false
end

--- Pure town detection (no set coupling). Adoulin counts as town. Dynamis
--- zones are excluded (technically cities, not safe).
--- @return boolean in_town True if in a city/Adoulin
function BaseSetBuilder.is_in_town()
    return town_zone() ~= nil
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BaseSetBuilder
