---============================================================================
--- WHM Message Formatter - Specialized Messages for White Mage
---============================================================================
--- Provides formatted chat messages for WHM-specific actions:
---   • Cure auto-tier selection notifications
---   • Afflatus stance changes (Solace/Misery)
---   • Divine abilities (Benediction, Devotion, Martyr)
---   • Status removal (Cursna, Erase, etc.)
---
--- Features:
---   • Consistent formatting with other jobs (WAR, DNC, PLD)
---   • Color-coded messages (Cure = Green, Afflatus = Blue, etc.)
---   • HP/MP display for healing actions
---   • Integration with MessageCore for standardized output
---
--- @file utils/whm/whm_message_formatter.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
---============================================================================

local WHMMessageFormatter = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')

---============================================================================
--- COLOR DEFINITIONS
---============================================================================

local COLORS = {
    -- Job tag
    job_tag = 200,        -- Green (WHM system)

    -- Cure messages
    cure_tier = 8,        -- Light blue (tier selection)
    cure_potency = 158,   -- Light green (HP healed)
    cure_mp = 205,        -- Light cyan (MP cost)
    separator = 160,      -- Gray (arrows, separators)

    -- Afflatus
    afflatus_solace = 158,  -- Light green (healing stance)
    afflatus_misery = 167,  -- Orange/red (damage stance)

    -- Divine abilities
    benediction = 200,    -- Bright green (emergency heal)
    devotion = 205,       -- Cyan (MP transfer)
    martyr = 206,         -- Light pink (HP sacrifice)

    -- Status removal
    cursna = 8,           -- Light blue
    status_removal = 200, -- Green

    -- Auto-tier system
    auto_tier_on = 158,   -- Light green
    auto_tier_off = 167,  -- Orange

    -- Warnings
    warning = 167,        -- Orange
    error = 123           -- Red
}

---============================================================================
--- JOB TAG HELPER
---============================================================================

--- Get formatted job tag with color
--- @return string Formatted job tag [WHM/SAM] with color
local function get_job_tag()
    local job_color = MessageCore.create_color_code(COLORS.job_tag)
    local tag = MessageCore.get_job_tag()  -- Returns "WHM/SAM" or "WHM"
    return string.format("%s[%s]", job_color, tag)
end

---============================================================================
--- CURE MESSAGES
---============================================================================

--- Show Cure auto-tier selection
--- @param original_spell string Original Cure spell (e.g., "Cure IV")
--- @param new_spell string Auto-selected Cure spell (e.g., "Cure II")
--- @param hp_missing number HP missing on target
--- @param reason string Reason for tier change (optional)
function WHMMessageFormatter.show_cure_tier_change(original_spell, new_spell, hp_missing, reason)
    local potency_color = MessageCore.create_color_code(COLORS.cure_potency)
    local separator_color = MessageCore.create_color_code(COLORS.separator)
    local mp_color = MessageCore.create_color_code(COLORS.cure_mp)

    -- Build reason message with colors: gray text + colored HP number and "HP" text
    local reason_text
    if reason then
        reason_text = reason
    else
        reason_text = string.format(
            "%sTarget missing %s%d HP",
            separator_color,
            mp_color,
            hp_missing
        )
    end

    local msg = string.format(
        "%s %s%s %s>> %s%s %s(%s%s)",
        get_job_tag(),
        potency_color,
        original_spell,
        separator_color,
        potency_color,
        new_spell,
        separator_color,
        reason_text,
        separator_color
    )

    add_to_chat(001, msg)
end

--- Show Cure cast (HP healed display)
--- @param spell_name string Cure spell name
--- @param hp_healed number HP healed amount
--- @param target_name string Target name (optional)
function WHMMessageFormatter.show_cure_heal(spell_name, hp_healed, target_name)
    local tier_color = MessageCore.create_color_code(COLORS.cure_tier)
    local potency_color = MessageCore.create_color_code(COLORS.cure_potency)

    local target_str = target_name and (" >> " .. tier_color .. target_name) or ""

    local msg = string.format(
        "%s %s%s: %s HP healed%s",
        get_job_tag(),
        tier_color,
        spell_name,
        potency_color .. "+" .. tostring(hp_healed),
        target_str
    )

    add_to_chat(001, msg)
end

--- Show Cure with Stoneskin (Afflatus Solace)
--- @param spell_name string Cure spell name
--- @param hp_healed number HP healed
--- @param stoneskin_amount number Stoneskin HP absorbed
--- @param target_name string Target name (optional)
function WHMMessageFormatter.show_cure_stoneskin(spell_name, hp_healed, stoneskin_amount, target_name)
    local tier_color = MessageCore.create_color_code(COLORS.cure_tier)
    local potency_color = MessageCore.create_color_code(COLORS.cure_potency)
    local solace_color = MessageCore.create_color_code(COLORS.afflatus_solace)

    local target_str = target_name and (" >> " .. target_name) or ""

    local msg = string.format(
        "%s %s%s: %s HP + %s Stoneskin%s",
        get_job_tag(),
        tier_color,
        spell_name,
        potency_color .. "+" .. tostring(hp_healed),
        solace_color .. tostring(stoneskin_amount),
        target_str
    )

    add_to_chat(001, msg)
end

---============================================================================
--- AFFLATUS MESSAGES
---============================================================================

--- Show Afflatus stance change
--- @param stance string Afflatus stance ("Solace" or "Misery")
function WHMMessageFormatter.show_afflatus_change(stance)
    local color_code = stance == "Solace" and COLORS.afflatus_solace or COLORS.afflatus_misery
    local stance_color = MessageCore.create_color_code(color_code)
    local desc_color = MessageCore.create_color_code(COLORS.cure_tier)
    local description = stance == "Solace" and "Healing Focus" or "Damage Focus"

    local msg = string.format(
        "%s Afflatus %s%s activated (%s%s)",
        get_job_tag(),
        stance_color,
        stance,
        desc_color,
        description
    )

    add_to_chat(001, msg)
end

---============================================================================
--- DIVINE ABILITY MESSAGES
---============================================================================

--- Show Benediction cast (1hr full party heal)
function WHMMessageFormatter.show_benediction()
    local bene_color = MessageCore.create_color_code(COLORS.benediction)

    local msg = string.format(
        "%s %sBenediction activated! (Full party heal)",
        get_job_tag(),
        bene_color
    )

    add_to_chat(001, msg)
end

--- Show Devotion (MP transfer)
--- @param mp_transferred number MP transferred to target
--- @param target_name string Target name
function WHMMessageFormatter.show_devotion(mp_transferred, target_name)
    local devotion_color = MessageCore.create_color_code(COLORS.devotion)
    local mp_color = MessageCore.create_color_code(COLORS.cure_mp)
    local target_color = MessageCore.create_color_code(COLORS.cure_tier)

    local msg = string.format(
        "%s %sDevotion: %s MP >> %s%s",
        get_job_tag(),
        devotion_color,
        mp_color .. tostring(mp_transferred),
        target_color,
        target_name
    )

    add_to_chat(001, msg)
end

--- Show Martyr (HP sacrifice for party)
--- @param hp_sacrificed number HP sacrificed
--- @param hp_restored number HP restored to party
function WHMMessageFormatter.show_martyr(hp_sacrificed, hp_restored)
    local martyr_color = MessageCore.create_color_code(COLORS.martyr)
    local error_color = MessageCore.create_color_code(COLORS.error)
    local potency_color = MessageCore.create_color_code(COLORS.cure_potency)

    local msg = string.format(
        "%s %sMartyr: %s HP >> %s HP to party",
        get_job_tag(),
        martyr_color,
        error_color .. "-" .. tostring(hp_sacrificed),
        potency_color .. "+" .. tostring(hp_restored)
    )

    add_to_chat(001, msg)
end

---============================================================================
--- STATUS REMOVAL MESSAGES
---============================================================================

--- Show Cursna cast
--- @param target_name string Target name
--- @param cursna_skill number Cursna skill level (optional)
function WHMMessageFormatter.show_cursna(target_name, cursna_skill)
    local cursna_color = MessageCore.create_color_code(COLORS.cursna)
    local target_color = MessageCore.create_color_code(COLORS.cure_tier)

    local skill_str = cursna_skill and string.format(" (Skill: %d)", cursna_skill) or ""

    local msg = string.format(
        "%s %sCursna >> %s%s%s",
        get_job_tag(),
        cursna_color,
        target_color,
        target_name,
        skill_str
    )

    add_to_chat(001, msg)
end

--- Show status removal (Paralyna, Erase, etc.)
--- @param spell_name string Status removal spell name
--- @param target_name string Target name
--- @param status_removed string Status effect removed (optional)
function WHMMessageFormatter.show_status_removal(spell_name, target_name, status_removed)
    local removal_color = MessageCore.create_color_code(COLORS.status_removal)
    local target_color = MessageCore.create_color_code(COLORS.cure_tier)

    local status_str = status_removed and string.format(" [%s removed]", status_removed) or ""

    local msg = string.format(
        "%s %s%s >> %s%s%s",
        get_job_tag(),
        removal_color,
        spell_name,
        target_color,
        target_name,
        status_str
    )

    add_to_chat(001, msg)
end

---============================================================================
--- AUTO-TIER SYSTEM MESSAGES
---============================================================================

--- Show auto-tier state change
--- @param enabled boolean True if auto-tier enabled, false if disabled
function WHMMessageFormatter.show_auto_tier_toggle(enabled)
    local status = enabled and "ENABLED" or "DISABLED"
    local color_code = enabled and COLORS.auto_tier_on or COLORS.auto_tier_off
    local status_color = MessageCore.create_color_code(color_code)
    local desc_color = MessageCore.create_color_code(COLORS.cure_tier)
    local description = enabled and "Auto-downgrade Cure tier based on HP" or "Always use selected Cure tier"

    local msg = string.format(
        "%s Cure Auto-Tier: %s%s (%s%s)",
        get_job_tag(),
        status_color,
        status,
        desc_color,
        description
    )

    add_to_chat(001, msg)
end

---============================================================================
--- WARNING/ERROR MESSAGES
---============================================================================

--- Show warning message
--- @param message string Warning message
function WHMMessageFormatter.warning(message)
    local warning_color = MessageCore.create_color_code(COLORS.warning)

    local msg = string.format(
        "%s %sWARNING: %s",
        get_job_tag(),
        warning_color,
        message
    )

    add_to_chat(001, msg)
end

--- Show error message
--- @param message string Error message
function WHMMessageFormatter.error(message)
    local error_color = MessageCore.create_color_code(COLORS.error)

    local msg = string.format(
        "%s %sERROR: %s",
        get_job_tag(),
        error_color,
        message
    )

    add_to_chat(001, msg)
end

---============================================================================
--- DEBUG MESSAGES (Cure Manager)
---============================================================================

--- Show no target provided debug message
function WHMMessageFormatter.show_debug_no_target()
    add_to_chat(123, '[DEBUG] No target provided')
end

--- Show target debug info
--- @param target_name string Target name
--- @param target_id string Target ID
function WHMMessageFormatter.show_debug_target(target_name, target_id)
    add_to_chat(123, string.format('[DEBUG] Target: name=%s, id=%s', target_name, target_id))
end

--- Show self HP debug info
--- @param current_hp number Current HP
--- @param max_hp number Max HP
--- @param missing_hp number Missing HP
function WHMMessageFormatter.show_debug_self_hp(current_hp, max_hp, missing_hp)
    add_to_chat(123, string.format('[DEBUG] Self: HP %d/%d | Missing: %d', current_hp, max_hp, missing_hp))
end

--- Show party members debug list
--- @param party_names string Comma-separated party member names
function WHMMessageFormatter.show_debug_party_members(party_names)
    add_to_chat(123, '[DEBUG] Party members: ' .. party_names)
end

--- Show party member HP debug info
--- @param name string Member name
--- @param hpp number HP percentage
--- @param max_hp number Max HP
--- @param current_hp number Current HP
--- @param missing_hp number Missing HP
function WHMMessageFormatter.show_debug_party_member_hp(name, hpp, max_hp, current_hp, missing_hp)
    add_to_chat(123, string.format('[DEBUG] Party member: %s | HPP: %d%% | Max: %d | Current: %d | Missing: %d',
        name, hpp, max_hp, current_hp, missing_hp))
end

--- Show alliance member HP debug info
--- @param name string Member name
--- @param hpp number HP percentage
--- @param max_hp number Max HP
--- @param current_hp number Current HP
--- @param missing_hp number Missing HP
function WHMMessageFormatter.show_debug_alliance_member_hp(name, hpp, max_hp, current_hp, missing_hp)
    add_to_chat(123, string.format('[DEBUG] Alliance member: %s | HPP: %d%% | Max: %d | Current: %d | Missing: %d',
        name, hpp, max_hp, current_hp, missing_hp))
end

--- Show cure recast error
--- @param recast_reason string Recast error reason
function WHMMessageFormatter.show_cure_recast_error(recast_reason)
    add_to_chat(123, string.format('[WHM] ERROR: %s', recast_reason or "All Cure spells on recast"))
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return WHMMessageFormatter
