---============================================================================
--- Debuff Message Formatter - Debuff Blocking
---============================================================================
--- Displays messages when actions are blocked by debuffs (Silence, Amnesia, etc.)
--- Separators come from the DEBUFFS templates; the lines are built by hand
--- with inline colors and sent with MessageRenderer.send(text, 1) (base
--- color 1; every segment carries its own inline color).
---
--- @file    shared/utils/messages/formatters/magic/message_debuffs.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageDebuffs = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')
local Colors = MessageCore.COLORS

--- "Echo Drops or Remedy", each name in the item colour.
--- @param items table|nil {name, id} list from AUTOCURE_CONFIG
--- @param default table Names when the list is empty
--- @param item_color string
--- @param text_color string
--- @return string
--- "Asked Kaories for Paralyna", when partners were asked.
--- @param asked table|nil names
--- @param spell string
local function send_asked(asked, spell)
    if not asked or #asked == 0 then return end
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    MessageRenderer.send(string.format("%sAsked %s for %s%s",
        success_color, table.concat(asked, ', '), spell_color, spell), 1)
end

local function items_label(items, default, item_color, text_color)
    local names = {}
    for _, item in ipairs(type(items) == 'table' and items or {}) do
        names[#names + 1] = item.name
    end
    if #names == 0 then names = default end
    local parts = {}
    for _, name in ipairs(names) do parts[#parts + 1] = item_color .. name end
    return table.concat(parts, text_color .. ' or ')
end

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

    MessageRenderer.send(formatted_message, 1)

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

    MessageRenderer.send(formatted_message, 1)

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

    MessageRenderer.send(formatted_message, 1)

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

    MessageRenderer.send(formatted_message, 1)

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

        MessageRenderer.send(formatted_message, 1)

        -- Bottom separator
        M.send('DEBUFFS', 'separator')
    end
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

    MessageRenderer.send(message, 1)
    M.send('DEBUFFS', 'separator')
end

--- Display message when no silence cure items are available
--- @param spell_name string The spell that was blocked
--- @param debuff_message string The debuff blocking the spell (e.g., "Silenced")
--- @param items table|nil Cure list tried ({name, id}); names shown
--- @param asked table|nil Partners asked for Silena
function MessageDebuffs.show_no_silence_cure(spell_name, debuff_message, items, asked)
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

    -- Second line: No <the configured items> Available
    local line2 = string.format(
        "%sNo %s %sAvailable",
        error_color,
        items_label(items, {"Echo Drops", "Remedy"}, item_color, error_color),
        error_color
    )

    MessageRenderer.send(line1, 1)
    MessageRenderer.send(line2, 1)
    send_asked(asked, 'Silena')
    M.send('DEBUFFS', 'separator')
end

---============================================================================
--- PARALYSIS CURE MESSAGES
---============================================================================

--- Display paralysis cure success message (Remedy used)
--- @param item_name string Item used (e.g., "Remedy")
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

    MessageRenderer.send(message, 1)
    M.send('DEBUFFS', 'separator')
end

--- Display message when no paralysis cure item is left: the ability goes
--- anyway (paralysis only makes it fail some of the time)
--- @param action_name string The ability
--- @param debuff_message string The debuff (e.g., "Paralyzed")
--- @param items table|nil Cure list tried ({name, id}); names shown
--- @param asked table|nil Partners asked for Paralyna
function MessageDebuffs.show_no_paralysis_cure(action_name, debuff_message, items, asked)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)
    local item_color = MessageCore.create_color_code(Colors.ITEM_COLOR)

    M.send('DEBUFFS', 'separator')

    -- First line: [Action] goes anyway [Debuff]
    local line1 = string.format(
        "%s[%s%s%s] %sgoes anyway %s[%s%s%s]",
        separator_color,
        ability_color, action_name,
        separator_color,
        error_color,
        separator_color,
        debuff_color, debuff_message or "Paralyzed",
        separator_color
    )

    -- Second line: No <the configured items> Available
    local line2 = string.format(
        "%sNo %s %sAvailable",
        error_color,
        items_label(items, {"Remedy"}, item_color, error_color),
        error_color
    )

    MessageRenderer.send(line1, 1)
    MessageRenderer.send(line2, 1)
    send_asked(asked, 'Paralyna')
    M.send('DEBUFFS', 'separator')
end

--- Display once that a cure item did not take a debuff off (an aura keeps
--- it on): no more item for it while it stays
--- @param debuff_name string Debuff (e.g., "paralysis")
--- @param item_name string Item that was used up
function MessageDebuffs.show_debuff_uncurable(debuff_name, item_name)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local debuff_color = MessageCore.create_color_code(Colors.DEBUFF)
    local item_color = MessageCore.create_color_code(Colors.ITEM_COLOR)

    M.send('DEBUFFS', 'separator')
    MessageRenderer.send(string.format(
        "%s[%s%s%s] %sdid not remove %s[%s%s%s] %s(aura?)",
        separator_color, item_color, item_name or '?', separator_color,
        error_color,
        separator_color, debuff_color, debuff_name or '?', separator_color,
        error_color
    ), 1)
    MessageRenderer.send(string.format("%sNo more item for it while it stays", error_color), 1)
    M.send('DEBUFFS', 'separator')
end

---============================================================================
--- AUTO MEDICINE TOGGLE
---============================================================================

--- Display the Auto Medicine toggle result
--- @param enabled boolean True if auto-cure items are now allowed
function MessageDebuffs.show_auto_medicine_toggled(enabled)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local item_color = MessageCore.create_color_code(Colors.ITEM_COLOR)
    local status_color = MessageCore.create_color_code(enabled and Colors.SUCCESS or Colors.ERROR)

    M.send('DEBUFFS', 'separator')

    local message = string.format(
        "%s[%s%s%s] %s%s",
        separator_color,
        item_color, "Auto Medicine",
        separator_color,
        status_color, enabled and "ON" or "OFF"
    )

    MessageRenderer.send(message, 1)

    if not enabled then
        local hint_color = MessageCore.create_color_code(Colors.ERROR)
        MessageRenderer.send(string.format(
            "%sNo Echo Drops / Remedy will be used automatically",
            hint_color
        ), 1)
    end

    M.send('DEBUFFS', 'separator')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageDebuffs
