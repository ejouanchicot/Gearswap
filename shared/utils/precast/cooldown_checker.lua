---============================================================================
--- Cooldown Checker - Centralized Cooldown Validation
---============================================================================
--- Provides universal cooldown checking for abilities and spells across all jobs.
--- Automatically cancels actions on cooldown and displays professional messages.
--- Excludes multi-charge abilities (Quick Draw, Stratagems) from cooldown blocking.
--- Manual recast_id mapping for abilities with missing/incorrect GearSwap data.
--- Integrates with RECAST_CONFIG for centralized tolerance management.
---
--- @file utils/precast/cooldown_checker.lua
--- @author Tetsouo
--- @version 1.4
--- @date Created: 2025-10-05
--- @date Updated: 2025-11-11 - Integrated RECAST_CONFIG tolerance
---============================================================================

local CooldownChecker = {}

-- Load message formatter for cooldown display
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load recast configuration for cooldown tolerance
local RECAST_CONFIG = _G.RECAST_CONFIG or {}

---============================================================================
--- RECAST TOLERANCE HELPERS
---============================================================================

--- Check if recast time indicates ability/spell is on cooldown
--- Uses RECAST_CONFIG tolerance if available, otherwise falls back to strict check
--- @param recast number Recast time in seconds
--- @return boolean True if on cooldown
local function is_on_cooldown(recast)
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        return RECAST_CONFIG.on_cooldown(recast)
    else
        return (recast > 0)  -- Fallback: strict check
    end
end

---============================================================================
--- MULTI-CHARGE ABILITIES (EXCLUDED FROM COOLDOWN CHECK)
---============================================================================

-- Abilities with multiple charges that can be used even when on partial cooldown
local MULTI_CHARGE_ABILITIES = {
    -- COR Quick Draw (2 charges) - All elemental variants
    ["Quick Draw"] = true,
    ["Light Shot"] = true,
    ["Dark Shot"] = true,
    ["Fire Shot"] = true,
    ["Water Shot"] = true,
    ["Thunder Shot"] = true,
    ["Earth Shot"] = true,
    ["Wind Shot"] = true,
    ["Ice Shot"] = true,

    -- SCH Stratagems (5 charges) - All variants
    ["Ebullience"] = true,
    ["Rapture"] = true,
    ["Perpetuance"] = true,
    ["Immanence"] = true,
    ["Accession"] = true,
    ["Manifestation"] = true,
    ["Addendum: White"] = true,
    ["Addendum: Black"] = true,
    ["Light Arts"] = true,
    ["Dark Arts"] = true,
    ["Parsimony"] = true,
    ["Penury"] = true,
    ["Celerity"] = true,
    ["Alacrity"] = true,
    ["Klimaform"] = true,
    ["Sublimation"] = true,
    ["Tranquility"] = true,
    ["Equanimity"] = true,
    ["Enlightenment"] = true,
    ["Altruism"] = true,
    ["Focalization"] = true,
    ["Stormsurge"] = true,
    ["Accretion"] = true,
    ["Tabula Rasa"] = true,

    -- Add other multi-charge abilities here as needed
}

---============================================================================
--- MANUAL RECAST ID MAPPING (for abilities with missing/incorrect recast_id)
---============================================================================

-- Some abilities don't provide correct recast_id in GearSwap spell data
-- Manual mapping: ability_name >> recast_id
-- NOTE: This mapping is actually NOT needed since GearSwap provides spell.recast_id correctly
-- Keeping for reference and potential future edge cases
local MANUAL_RECAST_IDS = {
    -- Add abilities with missing recast_id here if needed
}

---============================================================================
--- ABILITY COOLDOWN CHECK
---============================================================================

--- Check and display cooldown for ANY ability using spell recast_id
--- @param spell table Spell/ability data
--- @param eventArgs table Event arguments for potential cancellation
function CooldownChecker.check_ability_cooldown(spell, eventArgs)
    if not MessageFormatter then return end

    -- Get recast_id from spell data OR manual mapping
    -- Try multiple name variants: spell.name, spell.english, spell.en
    local recast_id = spell.recast_id
        or MANUAL_RECAST_IDS[spell.name]
        or MANUAL_RECAST_IDS[spell.english]
        or MANUAL_RECAST_IDS[spell.en]

    if not recast_id then return end  -- No recast_id available, skip check

    -- Skip cooldown check for multi-charge abilities (Quick Draw, etc.)
    if MULTI_CHARGE_ABILITIES[spell.name] then
        return  -- Allow ability usage (has multiple charges)
    end

    -- Check if cooldown messages are suppressed (e.g., for FBC command)
    if _G.suppress_cooldown_messages then
        return  -- Don't check cooldown or display message
    end

    local remaining_seconds = MessageFormatter.get_ability_recast_seconds(recast_id)

    if remaining_seconds and is_on_cooldown(remaining_seconds) then
        -- Get dynamic job tag (e.g., "DNC/NIN", "DNC")
        local job_tag = MessageFormatter.get_job_tag()

        -- Show cooldown message and cancel the action
        MessageFormatter.show_ability_cooldown(spell.name, remaining_seconds, job_tag)
        eventArgs.cancel = true
    end
end

---============================================================================
--- SPELL COOLDOWN CHECK
---============================================================================

--- Check magic cooldowns for ANY spell using spell recast_id
--- @param spell table Spell data
--- @param eventArgs table Event arguments
function CooldownChecker.check_spell_cooldown(spell, eventArgs)
    if not MessageFormatter then return end
    if not spell.recast_id then return end

    -- Get spell recast (in centiseconds, convert to seconds for RECAST_CONFIG)
    local remaining_centiseconds = windower.ffxi.get_spell_recasts()[spell.recast_id]

    if remaining_centiseconds then
        local remaining_seconds = remaining_centiseconds / 100
        if is_on_cooldown(remaining_seconds) then
            -- Get dynamic job tag (e.g., "DNC/NIN", "DNC")
            local job_tag = MessageFormatter.get_job_tag()

            -- Show cooldown message and cancel the action
            MessageFormatter.show_spell_cooldown(spell.name, remaining_centiseconds, job_tag)
            eventArgs.cancel = true
        end
    end
end

return CooldownChecker
