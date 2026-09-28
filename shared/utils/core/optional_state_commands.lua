---============================================================================
--- Optional State Commands - //gs c <mode> show | hide | key <key> | help
---============================================================================
--- The commands of a mode built on optional_state.lua (Combat Mode, Treasure
--- Mode). They rewrite the whole settings file, header included:
---   //gs c <cmd>              status on this job
---   //gs c <cmd> show | hide  the mode on this job or not
---   //gs c <cmd> key <key>    its key on this job (none = no key)
---   //gs c <cmd> help
--- create{...}:
---   optional     the optional_state object
---   command      '<cmd>' as typed after //gs c
---   label        'Combat Mode'
---   tag          InfoBlock tag ('COMBAT')
---   header       text written at the top of the settings file
---   status       function(job) -> extra InfoBlock fields
---   subtitle     help screen subtitle
---   notes        help screen notes (list)
---   extra        optional function(sub, args, job) -> true when it handled sub
---   extra_rows   help rows for `extra`
---
--- @file    shared/utils/core/optional_state_commands.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28 (from combat_mode_commands.lua)
---============================================================================

local OptionalStateCommands = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')

--- Lua source of a {JOB = value} table, sorted.
local function job_table(t)
    local jobs = {}
    for job in pairs(t) do jobs[#jobs + 1] = job end
    table.sort(jobs)
    local parts = {}
    for _, job in ipairs(jobs) do
        parts[#parts + 1] = ('%s = %s'):format(job, type(t[job]) == 'string' and ('%q'):format(t[job]) or 'true')
    end
    return '{' .. table.concat(parts, ', ') .. '}'
end

--- Re-lay the keys, redraw the HUD, re-dress.
local function refresh()
    local ok, KeybindManager = pcall(require, 'shared/utils/keybinds/keybind_manager')
    if ok and KeybindManager.refresh_active then pcall(KeybindManager.refresh_active) end
    local ok_d, Display = pcall(require, 'shared/utils/ui/ui_display')
    if ok_d and Display and Display.update_display then pcall(Display.update_display) end
    send_command('gs c update')
end

--- Build the command handler of one optional state.
--- @param cfg table See the file header
--- @return table {handle = function(args)}
function OptionalStateCommands.create(cfg)
    local S = cfg.optional
    local C = {}

    local function save()
        local path = S.settings_path()
        local file = path and io.open(path, 'w')
        if not file then
            MessageFormatter.show_error(('%s: cannot write %s'):format(cfg.label, tostring(path)))
            return false
        end
        local s = S.settings()
        file:write(cfg.header)
        file:write(('return {\n    shown = %s,\n    hidden = %s,\n    keys = %s,\n}\n'):format(
            job_table(s.shown), job_table(s.hidden), job_table(s.keys)))
        file:close()
        return true
    end

    local function status(job)
        local entry = S.entry()
        local key = entry and entry.key ~= '' and entry.key or 'none'
        local fields = {{'Shown', S.is_shown(job)}}
        for _, field in ipairs(cfg.status and cfg.status(job) or {}) do fields[#fields + 1] = field end
        fields[#fields + 1] = {'Key', key}
        require('shared/utils/messages/info_block').show({tag = cfg.tag, title = job, fields = fields})
    end

    local function show_help()
        local rows = {
            {'//gs c ' .. cfg.command, '', 'Status on this job'},
            {'//gs c ' .. cfg.command .. ' ', 'show | hide', 'Use it on this job or not'},
            {'//gs c ' .. cfg.command .. ' key ', '<key> | none', 'Its key on this job'},
        }
        for _, row in ipairs(cfg.extra_rows or {}) do rows[#rows + 1] = row end
        require('shared/utils/messages/help_screen').show({
            title = cfg.label:upper(), subtitle = cfg.subtitle,
            groups = {{rows = rows}}, notes = cfg.notes,
        })
    end

    local function set_shown(job, shown)
        local s = S.settings()
        s.shown[job], s.hidden[job] = shown or nil, (not shown) or nil
        local mode = state and rawget(state, S.cfg.state)
        -- A job's own state may not have that value (THF has no Treasure Mode Off)
        if not shown and mode then pcall(mode.set, mode, S.cfg.values[1]) end
        if save() then
            MessageFormatter.show_success(('%s %s on %s.'):format(cfg.label, shown and 'shown' or 'hidden', job))
            refresh()
        end
    end

    local function set_key(job, key)
        if not key then
            return MessageFormatter.show_error(('Usage: //gs c %s key <key> | none'):format(cfg.command))
        end
        if key == 'none' then key = '' end
        if key ~= '' and not require('shared/utils/keybinds/key_validator').is_valid_key(key) then
            return MessageFormatter.show_error(('%s: unknown key %s'):format(cfg.label, key))
        end
        S.settings().keys[job] = key
        local entry = S.entry()
        if entry then entry.key = key end
        if save() then
            MessageFormatter.show_success(('%s key on %s: %s.'):format(cfg.label, job, key ~= '' and key or 'none'))
            refresh()
        end
    end

    --- Route //gs c <command> <args>.
    --- @param args table Words after the command
    --- @return boolean handled
    function C.handle(args)
        local job = player and player.main_job
        if not job then return true end
        local sub = args[1] and args[1]:lower() or nil
        if sub == nil then status(job)
        elseif sub == 'show' then set_shown(job, true)
        elseif sub == 'hide' then set_shown(job, false)
        elseif sub == 'key' then set_key(job, args[2])
        elseif sub == 'help' then show_help()
        elseif not (cfg.extra and cfg.extra(sub, args, job)) then
            MessageFormatter.show_error(('Unknown: %s (//gs c %s help)'):format(sub, cfg.command))
        end
        return true
    end

    return C
end

return OptionalStateCommands
