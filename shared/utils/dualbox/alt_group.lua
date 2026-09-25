---============================================================================
--- Alt Group - //gs c alts : orders to the other members of the box group
---============================================================================
--- Drives the alts' automation addon (console "sm ...") through the send
--- addon, one alt at a time, so it reaches only the characters named in
--- config/DUALBOX_CONFIG.lua and not every other box on the machine.
---
---   //gs c alts on | off     automation on / off
---   //gs c alts toggle       flip it
---   //gs c alts follow       alts follow this character / stop (toggle)
---   //gs c alts follow <name> | off   alts follow that character / stop
---   //gs c alts do <command> any console command, sent to every alt
---   //gs c alts mirror       mirror request, sent from this character
---   //gs c alts window       show / hide the alt window (alt_window.lua)
---
--- Who receives the orders: see AltGroup.get_alts (DualBoxConfig.group,
--- or the main/alt names already in DUALBOX_CONFIG.lua).
---
--- The on/follow/mirror states are the last orders sent (//gs c sortie
--- reports its own through AltGroup.note), saved in alt_state.lua. Orders
--- sent another way (a macro, the alt's own keys) are not seen, so a toggle
--- can take one press to catch up. While the alt window is on screen, those
--- orders print nothing in chat: the window shows them.
---
--- @file shared/utils/dualbox/alt_group.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-24
---============================================================================

local AltGroup = {}

local function messages()
    local ok, m = pcall(require, 'shared/utils/messages/formatters/system/message_altgroup')
    return ok and m or nil
end

--- Messages for the state the alt window shows (Auto, Follow, Mirror):
--- none while the window is on screen, it already says it.
local function state_messages()
    local ok, AltWindow = pcall(require, 'shared/utils/dualbox/alt_window')
    if ok and AltWindow and AltWindow.is_shown() then return nil end
    return messages()
end

local function state_file()
    local name = player and player.name
    return name and (windower.addon_path .. 'data/' .. name .. '/config/alt_state.lua')
end

--- The orders saved by the last session of this game. Stamped with the wall
--- clock: a stamp older than this game process (os.clock counts the seconds
--- since it started) was written before a restart, and the alts start in an
--- unknown state. A stamp without a time counts as old.
local function load_state()
    local ok, data = pcall(dofile, state_file() or '')
    if not ok or type(data) ~= 'table'
        or os.time() - (tonumber(data.time) or 0) > os.clock() + 1 then
        return {}
    end
    return {on = data.on, follow = data.follow, mirror = data.mirror}
end

local function save_state(state)
    local path = state_file()
    local file = path and io.open(path, 'w')
    if not file then return end
    local function lua(v) return type(v) == 'string' and string.format('%q', v) or tostring(v) end
    file:write('-- Last //gs c alts orders (alt window). Ignored after a game restart.\n')
    file:write(string.format('return {time = %d, on = %s, follow = %s, mirror = %s}\n',
        os.time(), lua(state.on), lua(state.follow), lua(state.mirror)))
    file:close()
end

--- Last orders sent: on (bool), follow (leader name or false), mirror
--- (bool). nil = nothing sent yet, shown as "?" by the alt window. Kept
--- across GearSwap reloads (alt_state.lua), not across a game restart.
local function group_state()
    windower._alt_group = windower._alt_group or load_state()
    return windower._alt_group
end

--- An order changed the state: save it and redraw the window.
local function changed()
    save_state(group_state())
    local ok, AltWindow = pcall(require, 'shared/utils/dualbox/alt_window')
    if ok and AltWindow then AltWindow.refresh() end
end

--- The state shown by the alt window (read-only use).
--- @return table {on, follow, mirror}
function AltGroup.state()
    return group_state()
end

--- Record orders sent another way (//gs c sortie) so the window follows.
--- @param changes table Any of on, follow, mirror
function AltGroup.note(changes)
    local state = group_state()
    for key, value in pairs(changes) do state[key] = value end
    changed()
end

--- The other characters of this box group: whoever presses the key orders
--- the rest, so it works the same the day the roles are swapped.
---   group = {'Tetsouo', 'Kaories'}   everyone but this character
---   otherwise                        alt_characters / alt_character on a
---                                    main, main_character on an alt
--- @return table List of names (may be empty)
function AltGroup.get_alts()
    local cfg = _G.DualBoxConfig
    if not cfg or cfg.enabled == false then
        return {}
    end
    local me = (player and player.name or ''):lower()
    local names
    if type(cfg.group) == 'table' and #cfg.group > 0 then
        names = cfg.group
    elseif cfg.role == 'alt' then
        names = {cfg.main_character}
    elseif type(cfg.alt_characters) == 'table' and #cfg.alt_characters > 0 then
        names = cfg.alt_characters
    else
        names = {cfg.alt_character or cfg.alt_name}
    end
    local others = {}
    for _, name in ipairs(names) do
        if type(name) == 'string' and name ~= '' and name:lower() ~= me then
            others[#others + 1] = name
        end
    end
    return others
end

--- Send one console command to every alt.
--- @param alts table Names
--- @param command string Console command
local function to_alts(alts, command)
    for _, name in ipairs(alts) do
        send_command('send ' .. name .. ' ' .. command)
    end
end

local function set_auto(alts, on)
    to_alts(alts, on and 'sm on' or 'sm off')
    group_state().on = on
    changed()
    if state_messages() then state_messages().show_auto(table.concat(alts, ', '), on) end
end

--- Alts follow `leader`, or stop when leader is nil. The leader itself is
--- left out: it cannot follow itself. When that leaves no one (a box group
--- of two, told to follow the other box), nothing is sent and the saved
--- state is left alone, so the window does not claim a follow that never went out.
local function set_follow(alts, leader)
    if leader then
        local followers = {}
        for _, name in ipairs(alts) do
            if name:lower() ~= leader:lower() then followers[#followers + 1] = name end
        end
        if #followers == 0 then
            if messages() then messages().show_no_follower(leader) end
            return
        end
        alts = followers
        to_alts(alts, 'sm follow ' .. leader)
    else
        to_alts(alts, 'sm follow off')
    end
    group_state().follow = leader or false
    changed()
    if state_messages() then state_messages().show_follow(table.concat(alts, ', '), leader) end
end

--- `follow` alone toggles following this character; `follow off` stops;
--- `follow <name>` follows that character.
local function follow(alts, target)
    if target and target:lower() == 'off' then
        set_follow(alts, nil)
    elseif target then
        set_follow(alts, target:sub(1, 1):upper() .. target:sub(2):lower())
    elseif group_state().follow or not (player and player.name) then
        set_follow(alts, nil)
    else
        set_follow(alts, player.name)
    end
end

--- Words after `do`, joined back into one console command.
local function rest_of(args)
    local words = {}
    for i = 2, #args do words[#words + 1] = args[i] end
    return table.concat(words, ' ')
end

--- Handle //gs c alts ...
--- @param args table Words after "alts"
--- @return boolean handled
function AltGroup.handle(args)
    local sub = args[1] and args[1]:lower() or ''
    if sub == 'help' then
        -- Before the group check: the help is useful even with no alt set up
        if messages() then messages().show_usage() end
        return true
    end
    local alts = AltGroup.get_alts()

    if sub ~= 'mirror' and sub ~= 'window' and #alts == 0 then
        if messages() then
            if _G.DualBoxConfig == nil then
                messages().show_not_ready()
            else
                messages().show_no_alts()
            end
        end
        return true
    end

    if sub == 'on' or sub == 'off' then
        set_auto(alts, sub == 'on')
    elseif sub == 'toggle' then
        set_auto(alts, not group_state().on)
    elseif sub == 'follow' then
        follow(alts, args[2])
    elseif sub == 'do' and args[2] then
        local command = rest_of(args)
        to_alts(alts, command)
        if messages() then messages().show_sent(table.concat(alts, ', '), command) end
    elseif sub == 'mirror' then
        send_command('sm mirror')
        group_state().mirror = not group_state().mirror
        changed()
        if state_messages() then state_messages().show_mirror() end
    elseif sub == 'window' then
        require('shared/utils/dualbox/alt_window').toggle()
    elseif messages() then
        messages().show_usage()
    end
    return true
end

--- Entry point for the box-group words of //gs c: alts, main, setalt.
--- @param cmd string Command word (lowercase)
--- @param args table Words after it
--- @return boolean handled
function AltGroup.route(cmd, args)
    if cmd == 'alts' then
        return AltGroup.handle(args)
    end
    local DualBoxRole = require('shared/utils/dualbox/dualbox_role')
    if cmd == 'main' then
        return DualBoxRole.become_main()
    end
    return DualBoxRole.become_alt(args)
end

return AltGroup
