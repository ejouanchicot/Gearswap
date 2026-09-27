---============================================================================
--- Message Stealth - messages of //gs c stealth (Sneak / Invisible)
---============================================================================
--- Templates live in data/systems/stealth_messages.lua.
---
--- @file shared/utils/messages/formatters/system/message_stealth.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-26
---============================================================================

local MessageStealth = {}

local M = require('shared/utils/messages/api/messages')

--- A buff still has enough time, or is up with no known time (the game
--- sends it at the next buff change): not cast again.
--- @param buff string 'Sneak' or 'Invisible'
--- @param left string|nil Time left, "4:12"; nil or "-" when not known
function MessageStealth.show_skipped(buff, left)
    if not left or left == '-' then
        M.send('STEALTH', 'skipped_unknown', {buff = buff})
    else
        M.send('STEALTH', 'skipped', {buff = buff, left = left})
    end
end

--- Another box covers the group with Accession.
--- @param buff string 'Sneak' or 'Invisible'
--- @param name string The Scholar casting it
function MessageStealth.show_covered(buff, name)
    M.send('STEALTH', 'covered', {buff = buff, name = name})
end

--- `self` mode: this character has no way of its own.
--- @param buff string 'Sneak' or 'Invisible'
function MessageStealth.show_no_way(buff)
    M.send('STEALTH', 'no_way', {buff = buff})
end

--- This character had no way of its own: the other boxes were asked.
--- @param buff string 'Sneak' or 'Invisible'
function MessageStealth.show_asked(buff)
    M.send('STEALTH', 'asked', {buff = buff})
end

--- A buff is about to wear off.
--- @param name string|nil Other character, nil for this one
--- @param buff string 'Sneak' or 'Invisible'
--- @param left number Seconds left
function MessageStealth.show_wearing_off(name, buff, left)
    local text = ('%d s'):format(math.floor(left))
    if name then
        M.send('STEALTH', 'wearing_off_other', {name = name, buff = buff, left = text})
    else
        M.send('STEALTH', 'wearing_off', {buff = buff, left = text})
    end
end

--- A setting was changed.
--- @param key string Setting name
--- @param value any New value
--- @param saved boolean Whether it reached the file
function MessageStealth.show_setting(key, value, saved)
    local text = value == true and 'ON' or value == false and 'OFF' or tostring(value)
    M.send('STEALTH', saved and 'setting' or 'setting_unsaved', {key = key, value = text})
end

--- The command's usage.
function MessageStealth.show_usage()
    M.send('STEALTH', 'usage', {})
end

return MessageStealth
