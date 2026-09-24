---============================================================================
--- WHM Cure Manager - Automatic Cure Tier Selection
---============================================================================
--- Provides intelligent Cure tier selection based on target HP missing.
--- Similar to DNC WaltzManager but for WHM Cure spells.
---
--- Features:
---   • HP-based tier (only while state.CureAutoTier is On): the smallest tier
---     that covers the missing HP; a full-HP target gets the lowest tier
---   • Recast fallback (always on): a tier on recast is swapped for the next
---     ready one, lower tiers first, then higher
---   • Configurable HP thresholds per Cure tier (WHM_CURE_CONFIG)
---   • Debug messages for tier selection
---
--- Usage (WHM_PRECAST.lua):
---   local new_spell = CureManager.select_cure_tier(spell, target)
---   -- nil = keep the spell as cast; otherwise recast with new_spell
---
--- @file    shared/utils/whm/cure_manager.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-21
---============================================================================

local CureManager = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load configuration (character-aware: supports Tetsouo + cloned characters)
-- Module is lazy-required from WHM_PRECAST.lua, so `player` is defined at load time.
local char_name = (player and player.name) or 'Tetsouo'
local config_success, WHMCureConfig = pcall(require, char_name .. '/config/whm/WHM_CURE_CONFIG')
if not config_success then
    print('[CureManager] ERROR: Could not load WHM_CURE_CONFIG')
    WHMCureConfig = {
        auto_tier_enabled = false,
        force_max_cure = false,
        debug_messages = false
    }
end

local formatter_success, WHMMessageFormatter = pcall(require, 'shared/utils/whm/whm_message_formatter')
if not formatter_success then
    WHMMessageFormatter = nil
end

local MessageCore = require('shared/utils/messages/message_core')

-- Color code embedded before the recast time in the tier change message
local RECAST_COLOR = MessageCore.create_color_code(167)

---============================================================================
--- SPELL ID MAPPING (for recast check)
---============================================================================

--- Cure spell name -> spell id (= index into get_spell_recasts())
local CURE_IDS = {
    ['Cure'] = 1,
    ['Cure II'] = 2,
    ['Cure III'] = 3,
    ['Cure IV'] = 4,
    ['Cure V'] = 5,
    ['Cure VI'] = 6,
    ['Curaga'] = 7,
    ['Curaga II'] = 8,
    ['Curaga III'] = 9,
    ['Curaga IV'] = 10,
    ['Curaga V'] = 11
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if a spell is available (not in recast)
--- @param spell_name string Spell name (e.g., "Cure IV")
--- @return boolean available True if spell is ready
--- @return number recast Recast time remaining in SECONDS (0 if available)
local function is_spell_available(spell_name)
    local spell_id = CURE_IDS[spell_name]
    if not spell_id then
        return true, 0
    end

    local spell_recasts = windower.ffxi.get_spell_recasts()
    if not spell_recasts then
        return true, 0
    end

    local recast_centiseconds = spell_recasts[spell_id] or 0
    local recast_seconds = recast_centiseconds / 100

    return recast_seconds == 0, recast_seconds
end

--- get_hp_missing, self branch: exact HP from the player table.
--- @return number Missing HP
--- @return number HP percent
local function get_hp_missing_target_name()
    local missing = player.max_hp - player.hp
    local hpp = math.floor((player.hp / player.max_hp) * 100)
    if WHMCureConfig.debug_messages and WHMMessageFormatter then
        WHMMessageFormatter.show_debug_self_hp(player.hp, player.max_hp, missing)
    end
    return missing, hpp
end

--- get_hp_missing, party/alliance branch.
--- @param party table Result of windower.ffxi.get_party() - passed in, not read
---        from a global: the keys are p0..p5 / a1p1.., which GearSwap's own
---        `party` global does not have.
--- @param target table Target being cured
--- @return number|nil Missing HP, nil when the target is not in the party
--- @return number|nil HP percent
local function get_hp_missing_party(party, target)
    if WHMCureConfig.debug_messages and WHMMessageFormatter then
        local party_names = {}
        for i = 0, 5 do
            if party['p' .. i] and party['p' .. i].name then
                table.insert(party_names, party['p' .. i].name)
            end
        end
        WHMMessageFormatter.show_debug_party_members(table.concat(party_names, ', '))
    end

    for i = 0, 5 do
        local member = party['p' .. i]
        if member and member.name == target.name then
            -- Windower party data is unreliable for HP values in precast,
            -- so missing HP is derived from HPP
            local hpp = member.hpp or 100
            local max_hp = member.max_hp or 2000  -- Estimate if not available

            local current_hp = math.floor(max_hp * hpp / 100)
            local missing = math.max(0, max_hp - current_hp)

            if WHMCureConfig.debug_messages and WHMMessageFormatter then
                WHMMessageFormatter.show_debug_party_member_hp(member.name or 'Unknown', hpp, max_hp, current_hp, missing)
            end

            return missing, hpp
        end
    end

    -- Alliance (a1p1-a3p6)
    for i = 1, 3 do
        for j = 1, 6 do
            local member = party['a' .. i .. 'p' .. j]
            if member and member.name == target.name then
                local hpp = member.hpp or 100
                local max_hp = member.max_hp or 2000

                local current_hp = math.floor(max_hp * hpp / 100)
                local missing = math.max(0, max_hp - current_hp)

                if WHMCureConfig.debug_messages and WHMMessageFormatter then
                    WHMMessageFormatter.show_debug_alliance_member_hp(member.name or 'Unknown', hpp, max_hp, current_hp, missing)
                end

                return missing, hpp
            end
        end
    end
end

--- get_hp_missing, last resort: HPP of a target outside the party, against an
--- assumed 2000 max HP.
--- @param target table Target mob data
--- @return number Missing HP (estimate)
--- @return number HP percent
local function get_hp_missing_target_hpp(target)
    local hpp = target.hpp
    local est_max_hp = 2000 -- Rough estimate for player character
    local current_hp = math.floor(est_max_hp * hpp / 100)
    local missing = est_max_hp - current_hp
    return missing, hpp
end

--- Calculate HP missing for target (using HPP estimation like DNC Waltz)
--- @param target table Target mob data from windower.ffxi.get_mob_by_id()
--- @return number, number hp_missing, hpp
local function get_hp_missing(target)
    if not target then
        if WHMCureConfig.debug_messages and WHMMessageFormatter then
            WHMMessageFormatter.show_debug_no_target()
        end
        return 0, 0
    end

    if WHMCureConfig.debug_messages and WHMMessageFormatter then
        WHMMessageFormatter.show_debug_target(tostring(target.name), tostring(target.id))
    end

    -- Self: exact HP
    if target.name == player.name or target.id == player.id then
        return get_hp_missing_target_name()
    end

    -- Party/Alliance member: use party data. A target absent from the party
    -- returns nothing here and falls through to the HPP estimate below.
    local party = windower.ffxi.get_party()
    if party then
        local missing, hpp = get_hp_missing_party(party, target)
        if missing then
            return missing, hpp
        end
    end

    -- Fallback: estimate from HPP (mob data)
    if target.hpp then
        return get_hp_missing_target_hpp(target)
    end

    return 0, 0
end

--- Get Cure tier config based on spell name
--- @param spell_name string Original spell name (e.g., "Cure IV")
--- @return table tier_config (cure_tiers or curaga_tiers)
local function get_tier_config(spell_name)
    if spell_name:find('Curaga') then
        return WHMCureConfig.curaga_tiers
    else
        return WHMCureConfig.cure_tiers
    end
end

--- Find optimal Cure tier for given HP missing
--- @param hp_missing number HP to heal
--- @param tier_config table Tier thresholds config
--- @return string spell_name Optimal Cure spell name
local function find_optimal_tier(hp_missing, tier_config)
    local adjusted_missing = hp_missing + (WHMCureConfig.safety_margin or 50)

    for _, tier in ipairs(tier_config) do
        if adjusted_missing >= tier.min and adjusted_missing <= tier.max then
            return tier.spell
        end
    end

    -- Fallback: use highest tier
    return tier_config[#tier_config].spell
end

--- Find first available Cure spell with fallback to lower/higher tiers
--- @param optimal_spell string Optimal spell based on HP (e.g., "Cure IV")
--- @param tier_config table Tier configuration
--- @return string|nil available_spell First available spell, or nil if none found
--- @return string|nil reason Reason for tier change (e.g., "Cure IV on recast (5s)")
local function find_available_cure_with_fallback(optimal_spell, tier_config)
    local optimal_index = nil
    for i, tier in ipairs(tier_config) do
        if tier.spell == optimal_spell then
            optimal_index = i
            break
        end
    end

    if not optimal_index then
        return optimal_spell, nil
    end

    local available, recast = is_spell_available(optimal_spell)
    if available then
        return optimal_spell, nil
    end

    -- Optimal spell in recast - try lower tiers first (more MP efficient)
    local original_spell = optimal_spell
    local recast_time = string.format("%.1fs", recast)

    -- Try lower tiers (Cure IV >> Cure III >> Cure II >> Cure I)
    for i = optimal_index - 1, 1, -1 do
        local lower_tier = tier_config[i].spell
        local lower_available, _ = is_spell_available(lower_tier)

        if lower_available then
            local reason = string.format("%s on recast %s%s", original_spell, RECAST_COLOR, recast_time)
            return lower_tier, reason
        end
    end

    -- All lower tiers in recast - try higher tiers (Cure I >> Cure II >> Cure III...)
    for i = optimal_index + 1, #tier_config do
        local higher_tier = tier_config[i].spell
        local higher_available, _ = is_spell_available(higher_tier)

        if higher_available then
            local reason = string.format("%s on recast %s%s", original_spell, RECAST_COLOR, recast_time)
            return higher_tier, reason
        end
    end

    return nil, string.format("All Cure spells on recast (%s: %s%s)", original_spell, RECAST_COLOR, recast_time)
end

---============================================================================
--- MAIN CURE SELECTION LOGIC
---============================================================================

--- Select optimal Cure tier based on target HP
--- @param spell table Original spell data
--- @param target table Target entity (or nil for <me>)
--- @return string|nil new_spell_name (nil if no change needed)
function CureManager.select_cure_tier(spell, target)
    if not spell or not spell.name then
        return nil
    end

    local spell_name = spell.name
    if not (spell_name:find('Cure') or spell_name:find('Curaga')) then
        return nil
    end

    local tier_config = get_tier_config(spell_name)
    local auto_tier_enabled = state and state.CureAutoTier and state.CureAutoTier.value == 'On'

    -- ==========================================================================
    -- HP-BASED TIER SELECTION (only if auto-tier enabled)
    -- ==========================================================================

    local optimal_spell = spell_name

    if auto_tier_enabled then
        if not target then
            target = windower.ffxi.get_mob_by_target('me')
        end

        local hp_missing = get_hp_missing(target)

        -- Full HP: lowest tier, the cast is wanted for something other than
        -- healing (Stoneskin farming, waking a sleeping member...)
        if hp_missing == 0 then
            optimal_spell = tier_config[1].spell  -- First entry = lowest tier (Cure I)
        else
            optimal_spell = find_optimal_tier(hp_missing, tier_config)
        end
    end

    -- ==========================================================================
    -- RECAST FALLBACK (always active, regardless of auto-tier state)
    -- ==========================================================================

    local available_spell, recast_reason = find_available_cure_with_fallback(optimal_spell, tier_config)

    -- All tiers on recast: leave the cast as it is. WHM_PRECAST runs the recast
    -- check right after this, which reports and cancels it with the shared
    -- recast tolerance (this module tests for exactly 0).
    if not available_spell then
        return nil
    end

    if available_spell == spell_name then
        return nil
    end

    -- ==========================================================================
    -- FORMATTED OUTPUT
    -- ==========================================================================

    if WHMMessageFormatter then
        local display_reason = nil

        if recast_reason then
            display_reason = recast_reason
        elseif auto_tier_enabled and optimal_spell ~= spell_name then
            local hp_missing = target and get_hp_missing(target) or 0
            if hp_missing == 0 then
                display_reason = "Target full HP"
            end
            -- else: display_reason = nil (will use default "Target missing X HP")
        end

        if recast_reason or (auto_tier_enabled and optimal_spell ~= spell_name) then
            local hp_missing = target and get_hp_missing(target) or 0
            WHMMessageFormatter.show_cure_tier_change(spell_name, available_spell, hp_missing, display_reason)
        end
    elseif WHMCureConfig.debug_messages and WHMMessageFormatter then
        local hp_missing = target and get_hp_missing(target) or 0
        WHMMessageFormatter.show_cure_tier_change(spell_name, available_spell, hp_missing, recast_reason)
    end

    return available_spell
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return CureManager
