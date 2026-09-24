---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Spell Refiner - Intelligent Tier Fallback System
---  ═══════════════════════════════════════════════════════════════════════════
---   Automatically downgrades spell tier if higher tier is not learned or is
---   on recast. Example: If Fire V is unavailable, tries Fire IV >> Fire III >>
---   Fire II >> Fire. Used by the GEO nuke commands (GEO_COMMANDS.lua).
---
---   @file    shared/jobs/geo/functions/logic/geo_spell_refiner.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-12
---  ═══════════════════════════════════════════════════════════════════════════

local GeoSpellRefiner = {}

local res = require('resources')

local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   SPELL AVAILABILITY CHECK
---  ═══════════════════════════════════════════════════════════════════════════

---   Check if player has learned a specific spell
---   @param spell_name string Full spell name (e.g., "Fire V")
---   @return boolean True if spell is learned
local function has_spell(spell_name)
    if not res or not res.spells then
        return false
    end

    local learned_spells = windower.ffxi.get_spells()
    if not learned_spells then
        return false
    end

    for spell_id, spell_data in pairs(res.spells) do
        if spell_data.en == spell_name then
            return learned_spells[spell_id] == true
        end
    end

    return false
end

---   Check if spell is currently castable (not on cooldown)
---   @param spell_name string Full spell name
---   @return boolean True if spell is ready to cast
local function is_spell_ready(spell_name)
    if not res or not res.spells then
        return false
    end

    local spell_id = nil
    for id, spell_data in pairs(res.spells) do
        if spell_data.en == spell_name then
            spell_id = id
            break
        end
    end

    if not spell_id then
        return false
    end

    local recast_info = windower.ffxi.get_spell_recasts()
    if not recast_info or not recast_info[spell_id] then
        return true -- If we can't check recast, assume it's ready
    end

    return recast_info[spell_id] == 0
end

---  ═══════════════════════════════════════════════════════════════════════════
---   TIER REFINEMENT
---  ═══════════════════════════════════════════════════════════════════════════

---   Tier order for regular spells (V >> IV >> III >> II >> I)
local SPELL_TIER_ORDER = {"V", "IV", "III", "II", "I"}

---   Tier order for AOE spells (III >> II >> I)
local AOE_TIER_ORDER = {"III", "II", "I"}

---   Refine spell to highest available tier
---   @param base_spell string Base spell name (e.g., "Fire")
---   @param desired_tier string Desired tier (e.g., "V")
---   @param is_aoe boolean True if this is an AOE spell
---   @return string|nil Final spell name to cast, or nil if none available
function GeoSpellRefiner.refine_spell(base_spell, desired_tier, is_aoe)
    if not base_spell or not desired_tier then
        return nil
    end

    local tier_order = is_aoe and AOE_TIER_ORDER or SPELL_TIER_ORDER

    -- Find starting position in tier list
    local start_index = 1
    for i, tier in ipairs(tier_order) do
        if tier == desired_tier then
            start_index = i
            break
        end
    end

    -- Try each tier from desired down to I
    for i = start_index, #tier_order do
        local tier = tier_order[i]
        local spell_name

        -- Tier "I" = base spell name (e.g., "Fire" not "Fire I")
        if tier == "I" then
            spell_name = base_spell
        else
            spell_name = base_spell .. " " .. tier
        end

        -- Not learned or on recast: fall through to the next tier down
        if has_spell(spell_name) then
            if is_spell_ready(spell_name) then
                return spell_name
            end
        end
    end

    return nil
end

---   Refine and cast spell with automatic tier fallback
---   @param base_spell string Base spell name
---   @param desired_tier string Desired tier
---   @param is_aoe boolean True if AOE spell
---   @param target string Target (<t>, <me>, <stal>, etc.)
---   @return boolean True if spell was cast
function GeoSpellRefiner.refine_and_cast(base_spell, desired_tier, is_aoe, target)
    target = target or "<t>"

    local final_spell = GeoSpellRefiner.refine_spell(base_spell, desired_tier, is_aoe)

    if final_spell then
        local desired_spell = (desired_tier == "I") and base_spell or (base_spell .. " " .. desired_tier)
        if final_spell ~= desired_spell then
            MessageFormatter.show_spell_refined(desired_spell, final_spell)
        end

        send_command('input /ma "' .. final_spell .. '" ' .. target)
        return true
    else
        local desired_spell = (desired_tier == "I") and base_spell or (base_spell .. " " .. desired_tier)
        MessageFormatter.show_no_tier_available(desired_spell)
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return GeoSpellRefiner
