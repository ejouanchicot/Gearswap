---============================================================================
--- Message Sortie - Sortie command messages (main + GEO alt)
---============================================================================
--- Formatted messages for //gs c sortie ... (shared/utils/sortie) and the GEO
--- alt's //gs c escort (GEO_COMMANDS). Templates live in
--- data/systems/sortie_messages.lua.
---
--- @file shared/utils/messages/formatters/system/message_sortie.lua
--- @author Tetsouo
--- @version 1.1
--- @date Created: 2026-09-24
---============================================================================

local MessageSortie = {}

local MessageCore = require('shared/utils/messages/message_core')
local M = require('shared/utils/messages/api/messages')

local SEPARATOR = string.rep('=', MessageCore.SEPARATOR_WIDTH)
local LABEL_WIDTH = 8

-- Pre-coloured fragments inserted into templates (the engine does not nest
-- colour tags inside parameter values).
local YELLOW = string.char(0x1F, 50)
local GRAY = string.char(0x1F, 160)
local LIGHTBLUE = string.char(0x1F, 207)

---============================================================================
--- BLOCK HELPERS
---============================================================================

local function separator()
    M.send('SORTIE', 'separator', {separator = SEPARATOR})
end

--- Separator, title, separator.
--- @param title string
local function header(title)
    separator()
    M.send('SORTIE', 'title', {title = title})
    separator()
end

--- One "Label : value" line, labels padded so the colons line up.
--- @param key string Template: 'field', 'field_spell', 'field_on' or 'field_stopped'
--- @param label string
--- @param value string|nil
local function field(key, label, value)
    M.send('SORTIE', key, {label = ('%-' .. LABEL_WIDTH .. 's'):format(label), value = value})
end

---============================================================================
--- MAIN CHARACTER
---============================================================================

--- A Sortie target was loaded.
--- @param target string Title shown (boss name, with the profile if it differs)
--- @param alt string Alt character name
--- @param indi string Indi- cast by the alt
--- @param summary string Short description of the alt's setup
function MessageSortie.show_target_loaded(target, alt, indi, summary)
    header(target)
    field('field_on', alt)
    field('field_spell', 'Indi', indi)
    field('field', 'Setup', summary)
    separator()
end

--- Escort started from the main.
--- @param alt string Alt character name
--- @param indi string Indi- the alt casts
--- @param player_name string Character the alt will follow
function MessageSortie.show_escort(alt, indi, player_name)
    header('Escort')
    field('field_stopped', alt)
    field('field_spell', 'Indi', indi)
    field('field', 'Follow', player_name)
    separator()
end

--- Available targets, one line each.
--- @param entries table Array of {name, aliases (string, may be empty), indi, summary}
function MessageSortie.show_target_list(entries)
    header('Targets')
    for _, e in ipairs(entries) do
        M.send('SORTIE', 'list_entry', {
            name = e.name,
            aliases = e.aliases ~= '' and (' (' .. e.aliases .. ')') or '',
            indi = e.indi,
            summary = e.summary,
        })
    end
    M.send('SORTIE', 'list_orders')
    separator()
end

--- The alt's automation was stopped.
--- @param alt string Alt character name
function MessageSortie.show_alt_off(alt)
    M.send('SORTIE', 'alt_off', {alt = alt})
end

--- The alt was told to use a job ability or weaponskill.
--- @param alt string Alt character name
--- @param action string Ability or weaponskill name
function MessageSortie.show_alt_action(alt, action)
    M.send('SORTIE', 'alt_action', {alt = alt, action = action})
end

--- Unknown target name.
--- @param name string Name as typed
function MessageSortie.show_unknown_target(name)
    M.send('SORTIE', 'unknown_target', {name = name})
end

---============================================================================
--- GEO ALT
---============================================================================

--- Escort received by the GEO alt.
--- @param indi string Indi- being cast
--- @param full_circle boolean Whether the luopan is dismissed first
--- @param leader string|nil Character to follow once the cast is over
function MessageSortie.show_alt_escort(indi, full_circle, leader)
    M.send('SORTIE', 'alt_escort', {
        indi = indi,
        full_circle = full_circle and (YELLOW .. 'Full Circle' .. GRAY .. ', ') or '',
        follow = leader and ('then follows ' .. LIGHTBLUE .. leader .. GRAY .. ' right after the cast')
            or 'no follow',
    })
end

_G.MessageSortie = MessageSortie

return MessageSortie
