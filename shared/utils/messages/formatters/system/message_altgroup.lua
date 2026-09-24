---============================================================================
--- Message AltGroup - messages of //gs c alts and //gs c main
---============================================================================
--- Templates live in data/systems/altgroup_messages.lua.
---
--- @file shared/utils/messages/formatters/system/message_altgroup.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-24
---============================================================================

local MessageAltGroup = {}

local M = require('shared/utils/messages/api/messages')

--- The alts' automation was switched.
--- @param names string Alts, comma-separated
--- @param on boolean New state
function MessageAltGroup.show_auto(names, on)
    M.send('ALTGROUP', on and 'auto_on' or 'auto_off', {names = names})
end

--- The alts now follow `leader`, or stopped following.
--- @param names string Alts, comma-separated
--- @param leader string|nil Leader name, nil when follow was turned off
function MessageAltGroup.show_follow(names, leader)
    if leader then
        M.send('ALTGROUP', 'follow_on', {names = names, leader = leader})
    else
        M.send('ALTGROUP', 'follow_off', {names = names})
    end
end

--- A console command went out to every alt.
--- @param names string Alts, comma-separated
--- @param command string Command sent
function MessageAltGroup.show_sent(names, command)
    M.send('ALTGROUP', 'sent', {names = names, command = command})
end

--- A mirror request went out.
function MessageAltGroup.show_mirror()
    M.send('ALTGROUP', 'mirror', {})
end

--- This character is now the main.
--- @param name string This character
--- @param alts string Its alts, comma-separated
function MessageAltGroup.show_role_main(name, alts)
    M.send('ALTGROUP', 'role_main', {name = name, alts = alts})
end

--- This character is now an alt.
--- @param name string This character
--- @param main string Its main
function MessageAltGroup.show_role_alt(name, main)
    M.send('ALTGROUP', 'role_alt', {name = name, main = main})
end

--- No alt is configured for this character.
function MessageAltGroup.show_no_alts()
    M.send('ALTGROUP', 'no_alts', {})
end

--- Subcommand list.
function MessageAltGroup.show_usage()
    M.send('ALTGROUP', 'usage', {})
end

return MessageAltGroup
