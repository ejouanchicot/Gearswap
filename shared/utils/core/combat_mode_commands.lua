---============================================================================
--- Combat Mode Commands - //gs c combatmode
---============================================================================
---   //gs c combatmode              status on this job
---   //gs c combatmode show | hide  Combat Mode on this job or not
---   //gs c combatmode key <key>    its key on this job (none = no key)
---   //gs c combatmode help
--- Saved in <Character>/config/combat_mode.lua (combat_mode.lua reads it).
---
--- @file    shared/utils/core/combat_mode_commands.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local CombatModeCommands = {}

local CombatMode = require('shared/utils/core/combat_mode')
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

--- Write the settings file.
--- @return boolean
local function save()
    local path = CombatMode.settings_path()
    local file = path and io.open(path, 'w')
    if not file then
        MessageFormatter.show_error('Combat Mode: cannot write ' .. tostring(path))
        return false
    end
    local s = CombatMode.settings()
    file:write('-- Written by //gs c combatmode. Delete it to go back to the defaults.\n')
    file:write(('return {\n    shown = %s,\n    hidden = %s,\n    keys = %s,\n}\n'):format(
        job_table(s.shown), job_table(s.hidden), job_table(s.keys)))
    file:close()
    return true
end

--- Re-lay the keys, redraw the HUD, re-apply the lock.
local function refresh()
    local ok, KeybindManager = pcall(require, 'shared/utils/keybinds/keybind_manager')
    if ok and KeybindManager.refresh_active then pcall(KeybindManager.refresh_active) end
    local ok_d, Display = pcall(require, 'shared/utils/ui/ui_display')
    if ok_d and Display and Display.update_display then pcall(Display.update_display) end
    send_command('gs c update')
end

local function status(job)
    local entry = rawget(_G, '_combat_mode_entry')
    local key = entry and entry.key ~= '' and entry.key or 'none'
    local InfoBlock = require('shared/utils/messages/info_block')
    InfoBlock.show({
        tag = 'COMBAT', title = job,
        fields = {
            {'Shown', CombatMode.is_shown(job)},
            {'Weapons locked', CombatMode.is_on()},
            {'Key', key},
        },
    })
end

local function show_help()
    require('shared/utils/messages/help_screen').show({
        title = 'COMBAT MODE', subtitle = 'Weapon lock, per job',
        groups = {{rows = {
            {'//gs c combatmode', '', 'Status on this job'},
            {'//gs c combatmode ', 'show | hide', 'Use it on this job or not'},
            {'//gs c combatmode key ', '<key> | none', 'Its key on this job'},
        }}},
        notes = {'On: main, sub and range stay where they are (ammo too on BLM, WHM).'},
    })
end

local function set_shown(job, shown)
    local s = CombatMode.settings()
    s.shown[job], s.hidden[job] = shown or nil, (not shown) or nil
    if not shown and state.CombatMode then state.CombatMode:set('Off') end
    if save() then
        MessageFormatter.show_success(('Combat Mode %s on %s.'):format(shown and 'shown' or 'hidden', job))
        refresh()
    end
end

local function set_key(job, key)
    if not key then return MessageFormatter.show_error('Usage: //gs c combatmode key <key> | none') end
    if key == 'none' then key = '' end
    if key ~= '' and not require('shared/utils/keybinds/key_validator').is_valid_key(key) then
        return MessageFormatter.show_error('Combat Mode: unknown key ' .. key)
    end
    CombatMode.settings().keys[job] = key
    local entry = rawget(_G, '_combat_mode_entry')
    if entry then entry.key = key end
    if save() then
        MessageFormatter.show_success(('Combat Mode key on %s: %s.'):format(job, key ~= '' and key or 'none'))
        refresh()
    end
end

--- Route //gs c combatmode <args>.
--- @param args table Words after the command
--- @return boolean handled
function CombatModeCommands.handle(args)
    local job = player and player.main_job
    if not job then return true end
    local sub = args[1] and args[1]:lower() or nil
    if sub == nil then status(job)
    elseif sub == 'show' then set_shown(job, true)
    elseif sub == 'hide' then set_shown(job, false)
    elseif sub == 'key' then set_key(job, args[2])
    elseif sub == 'help' then show_help()
    else MessageFormatter.show_error('Unknown: ' .. sub .. ' (//gs c combatmode help)') end
    return true
end

return CombatModeCommands
