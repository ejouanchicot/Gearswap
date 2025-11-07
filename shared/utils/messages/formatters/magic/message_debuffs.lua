---============================================================================
--- Debuff Message Formatter - Debuff Blocking (NEW SYSTEM - HYBRID)
---============================================================================
--- Displays messages when actions are blocked by debuffs (Silence, Amnesia, etc.)
--- Uses hybrid approach: Templates for separators, direct rendering for dynamic messages
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_debuffs.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageDebuffs = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')
local Colors = MessageCore.COLORS

---============================================================================
--- BLOCKED ACTION MESSAGES
---============================================================================

--- Display a spell blocked by debuff message
--- @param spell_name string Spell name
--- @param debuff_name string Debuff blocking the spell (e.g., "Silence", "Mute")
function MessageDebuffs.show_spell_blocked(spell_name, debuff_name)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)

    -- Top separator
    M.send('DEBUFFS', 'separator')

    local formatted_message = string.format(
        "%s[%s]%s %sCannot cast %s[%s%s%s]",
        spell_color, spell_name,
        separator_color,
        error_color,
        separator_color,
        debuff_color, debuff_name,
        separator_color
    )

    MessageRenderer.send(1, formatted_message)

    -- Bottom separator
    M.send('DEBUFFS', 'separator')
end

--- Display a job ability blocked by debuff message
--- @param ja_name string Job ability name
--- @param debuff_name string Debuff blocking the JA (e.g., "Amnesia")
function MessageDebuffs.show_ja_blocked(ja_name, debuff_name)
    local ja_color = MessageCore.create_color_code(Colors.JA)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)

    -- Top separator
    M.send('DEBUFFS', 'separator')

    local formatted_message = string.format(
        "%s[%s]%s %sCannot use %s[%s%s%s]",
        ja_color, ja_name,
        separator_color,
        error_color,
        separator_color,
        debuff_color, debuff_name,
        separator_color
    )

    MessageRenderer.send(1, formatted_message)

    -- Bottom separator
    M.send('DEBUFFS', 'separator')
end

--- Display a weapon skill blocked by debuff message
--- @param ws_name string Weapon skill name
--- @param debuff_name string Debuff blocking the WS (e.g., "Amnesia")
function MessageDebuffs.show_ws_blocked(ws_name, debuff_name)
    local ws_color = MessageCore.create_color_code(Colors.WS)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)

    -- Top separator
    M.send('DEBUFFS', 'separator')

    local formatted_message = string.format(
        "%s[%s]%s %sCannot use %s[%s%s%s]",
        ws_color, ws_name,
        separator_color,
        error_color,
        separator_color,
        debuff_color, debuff_name,
        separator_color
    )

    MessageRenderer.send(1, formatted_message)

    -- Bottom separator
    M.send('DEBUFFS', 'separator')
end

--- Display an item usage blocked by debuff message
--- @param item_name string Item name
--- @param debuff_name string Debuff blocking the item (e.g., "Encumbrance")
function MessageDebuffs.show_item_blocked(item_name, debuff_name)
    local item_color = MessageCore.create_color_code(Colors.ITEM_COLOR)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)

    -- Top separator
    M.send('DEBUFFS', 'separator')

    local formatted_message = string.format(
        "%s[%s]%s %sCannot use %s[%s%s%s]",
        item_color, item_name,
        separator_color,
        error_color,
        separator_color,
        debuff_color, debuff_name,
        separator_color
    )

    MessageRenderer.send(1, formatted_message)

    -- Bottom separator
    M.send('DEBUFFS', 'separator')
end

--- Display a generic action blocked message
--- @param action_name string Action name
--- @param action_type string Action type (Magic, Ability, WeaponSkill, Item)
--- @param debuff_name string Debuff blocking the action
function MessageDebuffs.show_action_blocked(action_name, action_type, debuff_name)
    if action_type == "Magic" then
        MessageDebuffs.show_spell_blocked(action_name, debuff_name)
    elseif action_type == "Ability" or action_type == "JobAbility" or action_type == "PetCommand" then
        MessageDebuffs.show_ja_blocked(action_name, debuff_name)
    elseif action_type == "WeaponSkill" or action_type == "Weaponskill" then
        MessageDebuffs.show_ws_blocked(action_name, debuff_name)
    elseif action_type == "Item" then
        MessageDebuffs.show_item_blocked(action_name, debuff_name)
    else
        -- Fallback generic message (uses Cyan as default)
        local action_color = MessageCore.create_color_code(Colors.SPELL)
        local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
        local error_color = MessageCore.create_color_code(Colors.ERROR)
        local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)

        -- Top separator
        M.send('DEBUFFS', 'separator')

        local formatted_message = string.format(
            "%s[%s]%s %sBlocked %s[%s%s%s]",
            action_color, action_name,
            separator_color,
            error_color,
            separator_color,
            debuff_color, debuff_name,
            separator_color
        )

        MessageRenderer.send(1, formatted_message)

        -- Bottom separator
        M.send('DEBUFFS', 'separator')
    end
end

---============================================================================
--- INCAPACITATED MESSAGE
---============================================================================

--- Display incapacitated message (player cannot act at all)
--- @param debuff_name string The incapacitating debuff
function MessageDebuffs.show_incapacitated(debuff_name)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)

    -- Top separator
    M.send('DEBUFFS', 'separator')

    local formatted_message = string.format(
        "%sIncapacitated %s[%s%s%s]",
        error_color,
        separator_color,
        debuff_color, debuff_name,
        separator_color
    )

    MessageRenderer.send(1, formatted_message)

    -- Bottom separator
    M.send('DEBUFFS', 'separator')
end

---============================================================================
--- SILENCE CURE MESSAGES
---============================================================================

--- Display silence cure success message (Echo Drops/Remedy used)
--- @param item_name string Item used (e.g., "Echo Drops", "Remedy")
--- @param spell_name string Spell that was blocked
--- @param debuff_message string Debuff being cured (e.g., "Silenced")
function MessageDebuffs.show_silence_cure_success(item_name, spell_name, debuff_message)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local item_color = MessageCore.create_color_code(Colors.ITEM_COLOR)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)

    M.send('DEBUFFS', 'separator')

    local message = string.format(
        "%sUsing %s[%s%s%s] %sto cure %s[%s%s%s] %sfor %s[%s%s%s]",
        success_color,
        separator_color,
        item_color, item_name,
        separator_color,
        success_color,
        separator_color,
        debuff_color, debuff_message or "Silenced",
        separator_color,
        success_color,
        separator_color,
        spell_color, spell_name,
        separator_color
    )

    MessageRenderer.send(1, message)
    M.send('DEBUFFS', 'separator')
end

--- Display message when no silence cure items are available
--- @param spell_name string The spell that was blocked
--- @param debuff_message string The debuff blocking the spell (e.g., "Silenced")
function MessageDebuffs.show_no_silence_cure(spell_name, debuff_message)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)
    local item_color = MessageCore.create_color_code(Colors.ITEM_COLOR)

    M.send('DEBUFFS', 'separator')

    -- First line: [Spell] Cannot cast [Debuff]
    local line1 = string.format(
        "%s[%s%s%s] %sCannot cast %s[%s%s%s]",
        separator_color,
        spell_color, spell_name,
        separator_color,
        error_color,
        separator_color,
        debuff_color, debuff_message or "Silenced",
        separator_color
    )

    -- Second line: No Echo Drops or Remedy Available
    local line2 = string.format(
        "%sNo %s%s %sor %s%s %sAvailable",
        error_color,
        item_color, "Echo Drops",
        error_color,
        item_color, "Remedy",
        error_color
    )

    MessageRenderer.send(1, line1)
    MessageRenderer.send(1, line2)
    M.send('DEBUFFS', 'separator')
end

---============================================================================
--- PARALYSIS CURE MESSAGES
---============================================================================

--- Display paralysis cure success message (Remedy/Panacea used)
--- @param item_name string Item used (e.g., "Remedy", "Panacea")
--- @param action_name string Action that was blocked (JA or WS)
--- @param debuff_message string Debuff being cured (e.g., "Paralyzed")
function MessageDebuffs.show_paralysis_cure_success(item_name, action_name, debuff_message)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local item_color = MessageCore.create_color_code(Colors.ITEM_COLOR)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)

    M.send('DEBUFFS', 'separator')

    local message = string.format(
        "%sUsing %s[%s%s%s] %sto cure %s[%s%s%s] %sfor %s[%s%s%s]",
        success_color,
        separator_color,
        item_color, item_name,
        separator_color,
        success_color,
        separator_color,
        debuff_color, debuff_message or "Paralyzed",
        separator_color,
        success_color,
        separator_color,
        ability_color, action_name,
        separator_color
    )

    MessageRenderer.send(1, message)
    M.send('DEBUFFS', 'separator')
end

--- Display message when no paralysis cure items are available
--- @param action_name string The action that was blocked (JA or WS)
--- @param debuff_message string The debuff blocking the action (e.g., "Paralyzed")
function MessageDebuffs.show_no_paralysis_cure(action_name, debuff_message)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)
    local item_color = MessageCore.create_color_code(Colors.ITEM_COLOR)

    M.send('DEBUFFS', 'separator')

    -- First line: [Action] Cannot use [Debuff]
    local line1 = string.format(
        "%s[%s%s%s] %sCannot use %s[%s%s%s]",
        separator_color,
        ability_color, action_name,
        separator_color,
        error_color,
        separator_color,
        debuff_color, debuff_message or "Paralyzed",
        separator_color
    )

    -- Second line: No Remedy Available
    local line2 = string.format(
        "%sNo %s%s %sAvailable",
        error_color,
        item_color, "Remedy",
        error_color
    )

    MessageRenderer.send(1, line1)
    MessageRenderer.send(1, line2)
    M.send('DEBUFFS', 'separator')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageDebuffs
