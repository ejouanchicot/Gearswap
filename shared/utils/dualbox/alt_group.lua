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
--- The on/follow/mirror states start as the last orders sent (//gs c sortie
--- reports its own through AltGroup.note), saved in alt_state.lua. When the
--- automation addon carries the local StateReport addition, every box also
--- reports its real state on each change (//gs c altreport, see
--- AltGroup.receive_report), so an order sent another way (a macro, a //sm
--- typed by hand, the alt's own keys) shows too. Without it, such an order
--- is not seen and a toggle can take one press to catch up. While the alt
--- window is on screen, those orders print nothing in chat: the window
--- shows them.
---
---   //gs c altreport <name> <on|off> <leader|off> <on|off>   (sent by the addon)
---   //gs c altmirror <name> phase <step> <npc> | results <...>  (same, mirror progress)
---
--- @file shared/utils/dualbox/alt_group.lua
--- @author ejouanchicot
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
    return name and require('shared/utils/core/char_paths').writable('saved', 'alt_state.lua', nil, name)
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
    -- Every other box learns the new leader: without the automation
    -- addon's reports, its own record would still name the old one
    to_alts(AltGroup.get_alts(), 'gs c altlead ' .. (leader or 'off'))
    group_state().follow = leader or false
    changed()
    if state_messages() then state_messages().show_follow(table.concat(alts, ', '), leader) end
end

--- Who `name` follows now: its automation addon's last report (see
--- receive_report), else this box's saved state for an alt; false = nobody,
--- nil = unknown.
local function leader_of(name)
    local r = windower._alt_reports and windower._alt_reports[name:lower()]
    if r then return r.follow end
    return nil
end

--- Whether every alt follows `leader` now.
local function all_follow(alts, leader)
    for _, name in ipairs(alts) do
        local current = leader_of(name)
        if current == nil then current = group_state().follow end
        if not current or current:lower() ~= leader:lower() then return false end
    end
    return true
end

--- This box takes the lead: it stops following anyone itself, then every
--- alt follows it. Pressed on another box than the last leader, this turns
--- the old follow around instead of making two boxes follow each other.
local function take_lead(alts)
    if leader_of(player.name) ~= false then
        send_command('sm follow off')
    end
    set_follow(alts, player.name)
end

--- `follow` alone: this box leads (see take_lead), or, when every alt
--- already follows it, the follow stops. `follow off` stops; `follow <name>`
--- follows that character.
local function follow(alts, target)
    if target and target:lower() == 'off' then
        set_follow(alts, nil)
    elseif target then
        set_follow(alts, target:sub(1, 1):upper() .. target:sub(2):lower())
    elseif not (player and player.name) then
        set_follow(alts, nil)
    elseif all_follow(alts, player.name) then
        set_follow(alts, nil)
    else
        take_lead(alts)
    end
end

--- //gs c altlead <leader|off>, sent by the box that changed the follow: the
--- record this box keeps (group_state().follow) names the new leader.
--- @param args table Words after "altlead"
--- @return boolean handled
function AltGroup.receive_lead(args)
    local leader = args[1]
    if not leader then return true end
    group_state().follow = leader:lower() ~= 'off' and leader or false
    changed()
    return true
end

---============================================================================
--- REAL STATE REPORTED BY THE AUTOMATION ADDON
---============================================================================

--- One trace line per report received (//gs c trace on).
local function trace(fmt, ...)
    local ok, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok and Trace then Trace.log('ALTS', fmt, ...) end
end

--- Whether `name` is one of this box's alts.
local function is_alt(name)
    for _, alt in ipairs(AltGroup.get_alts()) do
        if alt:lower() == name:lower() then return true end
    end
    return false
end

--- Last report of each box, on `windower` so a GearSwap reload keeps them.
local function reports()
    windower._alt_reports = windower._alt_reports or {}
    return windower._alt_reports
end

--- Group state from the reports: Auto ON if any alt is on, Follow = the
--- first alt's leader, Mirror ON if any box (this one included: a mirror
--- request starts on the box that sends it) has it on. A field no report
--- speaks for keeps its current value.
local function state_from_reports()
    local all = reports()
    local on, follow, mirror
    local me = player and player.name
    local names = AltGroup.get_alts()
    if me then names[#names + 1] = me end
    for _, name in ipairs(names) do
        local r = all[name:lower()]
        if r then
            if name ~= me then
                on = on or r.on
                if follow == nil or (not follow and r.follow) then follow = r.follow end
            end
            mirror = mirror or r.mirror
        end
    end
    return on, follow, mirror
end

--- //gs c altreport <name> <on|off> <leader|off> <on|off>, sent by every
--- box's automation addon when its state changes. Reports from a box
--- outside this group are ignored.
--- @param args table Words after "altreport"
--- @return boolean handled
function AltGroup.receive_report(args)
    local name, on, leader, mirror = args[1], args[2], args[3], args[4]
    trace('altreport %s on=%s follow=%s mirror=%s', name, on, leader, mirror)
    if not name or not on then return true end
    local me = player and player.name
    if not (me and name:lower() == me:lower()) and not is_alt(name) then return true end
    reports()[name:lower()] = {
        on = on == 'on',
        follow = (leader and leader ~= 'off') and leader or false,
        mirror = mirror == 'on',
    }
    local new_on, new_follow, new_mirror = state_from_reports()
    local state = group_state()
    if new_on ~= nil then state.on = new_on end
    if new_follow ~= nil then state.follow = new_follow end
    if new_mirror ~= nil then state.mirror = new_mirror end
    changed()
    return true
end

---============================================================================
--- MIRROR PROGRESS REPORTED BY THE AUTOMATION ADDON
---============================================================================

local RESULTS_SHOWN = 8   -- seconds, as long as the addon's own results box
local PHASE_STALE = 120   -- seconds: a step never cleared (lost report) goes

--- Progress of the current mirror, on `windower` so a reload keeps it.
local function mirror_data()
    windower._alt_mirror = windower._alt_mirror or {phases = {}, results = nil}
    return windower._alt_mirror
end

local function unword(text)
    return (text or ''):gsub('_', ' ')
end

--- Whether `name` is this box or one of its alts.
local function in_group(name)
    local me = player and player.name
    return (me and name:lower() == me:lower()) or is_alt(name)
end

--- "Name,Status|Name,Status" -> list of {name, status}
local function parse_results(text)
    local list = {}
    for item in unword(text):gmatch('[^|]+') do
        local name, status = item:match('^%s*([^,]+),%s*(.-)%s*$')
        if name then list[#list + 1] = {name = name, status = status} end
    end
    return list
end

--- //gs c altmirror <name> phase <step|-> [npc]
--- //gs c altmirror <name> results <Name,Status|...>
--- Sent by every box's automation addon (StateReport addition).
--- @param args table Words after "altmirror"
--- @return boolean handled
function AltGroup.receive_mirror(args)
    local name, kind = args[1], args[2] and args[2]:lower()
    trace('altmirror %s %s %s %s', name, kind, args[3], args[4])
    if not name or not kind or not in_group(name) then return true end
    local data = mirror_data()
    if kind == 'phase' then
        if not args[3] or args[3] == '-' then
            data.phases[name] = nil
        else
            data.phases[name] = {step = unword(args[3]), npc = args[4] ~= '-' and unword(args[4]) or nil,
                                 time = os.clock()}
        end
    elseif kind == 'results' then
        data.results = {list = parse_results(args[3]), time = os.clock()}
    end
    local ok, AltWindow = pcall(require, 'shared/utils/dualbox/alt_window')
    if ok and AltWindow then AltWindow.refresh() end
    return true
end

--- The mirror in progress, for the alt window.
--- @return table phases {name -> {step, npc}}, table|nil results list of {name, status}
function AltGroup.mirror_progress()
    local data, now = mirror_data(), os.clock()
    for name, phase in pairs(data.phases) do
        if now - phase.time > PHASE_STALE then data.phases[name] = nil end
    end
    local results = data.results
    if results and now - results.time > RESULTS_SHOWN then
        data.results, results = nil, nil
    end
    return data.phases, results and results.list or nil
end

--- Ask every box of the group (this one too) for its state: called at each
--- load, since reports sent while GearSwap was reloading are lost. Does
--- nothing visible when the addon lacks the StateReport addition.
function AltGroup.request_report()
    local alts = AltGroup.get_alts()
    if #alts == 0 then return end
    send_command('sm report')
    to_alts(alts, 'sm report')
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

--- Entry point for the box-group words of //gs c: alts, altreport, main, setalt.
--- @param cmd string Command word (lowercase)
--- @param args table Words after it
--- @return boolean handled
function AltGroup.route(cmd, args)
    if cmd == 'alts' then
        return AltGroup.handle(args)
    end
    if cmd == 'altreport' then
        return AltGroup.receive_report(args)
    end
    if cmd == 'altmirror' then
        return AltGroup.receive_mirror(args)
    end
    if cmd == 'altlead' then
        return AltGroup.receive_lead(args)
    end
    local DualBoxRole = require('shared/utils/dualbox/dualbox_role')
    if cmd == 'main' then
        return DualBoxRole.become_main()
    end
    return DualBoxRole.become_alt(args)
end

return AltGroup
