---============================================================================
--- Cooldown Checker - Centralized Cooldown Validation
---============================================================================
--- Cancels an ability or spell that is still on recast and shows the remaining
--- time. Runs right after PrecastGuard in every job's precast.
--- Multi-charge abilities (Quick Draw, SCH stratagems) are skipped: a running
--- recast does not mean no charge is left.
---
--- @file    shared/utils/precast/cooldown_checker.lua
--- @author  Tetsouo
--- @version 1.3
--- @date    Created: 2025-10-05
---============================================================================

local CooldownChecker = {}

local MessageFormatter = nil

local function get_formatter()
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
    return MessageFormatter
end

-- Set by each job entry point (_G.RECAST_CONFIG = require(...)) before the
-- job modules load; read once, when this module is first required.
local RECAST_CONFIG = _G.RECAST_CONFIG or {}

--- Check if recast time indicates ability/spell is on cooldown
--- Uses RECAST_CONFIG tolerance if available, otherwise falls back to strict check
--- @param recast number Remaining recast in seconds
--- @return boolean True if still on cooldown
local function is_on_cooldown(recast)
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        return RECAST_CONFIG.on_cooldown(recast)
    else
        return (recast > 0)  -- Fallback: strict check
    end
end

-- Abilities excluded from cooldown blocking (by name)
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

    -- SCH: stratagems share recast_id 231 (charge pool). The list also holds
    -- SCH abilities that are not stratagems (Light/Dark Arts, Sublimation,
    -- Enlightenment, Tabula Rasa...), which are exempted all the same.
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
}

-- Manual recast_id overrides (GearSwap data sometimes incorrect; currently none needed)
local MANUAL_RECAST_IDS = {}

--- Cancel an ability that is still on recast and show the remaining time.
--- @param spell table Spell/ability object from GearSwap
--- @param eventArgs table Event args (cancel is set when on cooldown)
function CooldownChecker.check_ability_cooldown(spell, eventArgs)
    local recast_id = spell.recast_id
        or MANUAL_RECAST_IDS[spell.name]
        or MANUAL_RECAST_IDS[spell.english]
        or MANUAL_RECAST_IDS[spell.en]

    if not recast_id then return end

    if MULTI_CHARGE_ABILITIES[spell.name] then
        return
    end

    -- Set by THF's FBC command while it chains abilities: skips the whole
    -- check, not only the message.
    if _G.suppress_cooldown_messages then
        return
    end

    local formatter = get_formatter()
    if not formatter then return end

    local remaining_seconds = formatter.get_ability_recast_seconds(recast_id)

    if remaining_seconds and is_on_cooldown(remaining_seconds) then
        local job_tag = formatter.get_job_tag()
        formatter.show_ability_cooldown(spell.name, remaining_seconds, job_tag)
        eventArgs.cancel = true
    end
end

--- Cancel a spell that is still on recast and show the remaining time.
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (cancel is set when on cooldown)
function CooldownChecker.check_spell_cooldown(spell, eventArgs)
    if not spell.recast_id then return end

    -- Spell recasts are in centiseconds; RECAST_CONFIG works in seconds
    local spell_recasts = windower.ffxi.get_spell_recasts()
    if not spell_recasts then return end
    local remaining_centiseconds = spell_recasts[spell.recast_id]

    if remaining_centiseconds then
        local remaining_seconds = remaining_centiseconds / 100
        if is_on_cooldown(remaining_seconds) then
            local formatter = get_formatter()
            if not formatter then return end

            local job_tag = formatter.get_job_tag()
            formatter.show_spell_cooldown(spell.name, remaining_centiseconds, job_tag)
            eventArgs.cancel = true
        end
    end
end

return CooldownChecker