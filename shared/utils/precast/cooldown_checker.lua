-- CooldownChecker: universal ability/spell cooldown validation for all jobs.
-- Skips multi-charge abilities (Quick Draw, Stratagems). Manual recast_id map for bad GS data.

local CooldownChecker = {}


local MessageFormatter = nil

local function get_formatter()
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
    return MessageFormatter
end

-- Load recast configuration for cooldown tolerance
local RECAST_CONFIG = _G.RECAST_CONFIG or {}

--- Check if recast time indicates ability/spell is on cooldown
--- Uses RECAST_CONFIG tolerance if available, otherwise falls back to strict check
local function is_on_cooldown(recast)
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        return RECAST_CONFIG.on_cooldown(recast)
    else
        return (recast > 0)  -- Fallback: strict check
    end
end

-- Multi-charge abilities excluded from cooldown blocking (Quick Draw, Stratagems)
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

-- Manual recast_id overrides (GearSwap data sometimes incorrect; currently none needed)
local MANUAL_RECAST_IDS = {
    -- Add abilities with missing recast_id here if needed
}

function CooldownChecker.check_ability_cooldown(spell, eventArgs)
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

    -- Lazy-load MessageFormatter only when actually needed
    local formatter = get_formatter()
    if not formatter then return end

    local remaining_seconds = formatter.get_ability_recast_seconds(recast_id)

    if remaining_seconds and is_on_cooldown(remaining_seconds) then
        -- Get dynamic job tag (e.g., "DNC/NIN", "DNC")
        local job_tag = formatter.get_job_tag()

        -- Show cooldown message and cancel the action
        formatter.show_ability_cooldown(spell.name, remaining_seconds, job_tag)
        eventArgs.cancel = true
    end
end

function CooldownChecker.check_spell_cooldown(spell, eventArgs)
    if not spell.recast_id then return end

    -- Get spell recast (in centiseconds, convert to seconds for RECAST_CONFIG)
    local spell_recasts = windower.ffxi.get_spell_recasts()
    if not spell_recasts then return end
    local remaining_centiseconds = spell_recasts[spell.recast_id]

    if remaining_centiseconds then
        local remaining_seconds = remaining_centiseconds / 100
        if is_on_cooldown(remaining_seconds) then
            -- Lazy-load MessageFormatter only when actually needed
            local formatter = get_formatter()
            if not formatter then return end

            -- Get dynamic job tag (e.g., "DNC/NIN", "DNC")
            local job_tag = formatter.get_job_tag()

            -- Show cooldown message and cancel the action
            formatter.show_spell_cooldown(spell.name, remaining_centiseconds, job_tag)
            eventArgs.cancel = true
        end
    end
end

return CooldownChecker