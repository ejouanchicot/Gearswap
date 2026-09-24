---============================================================================
--- Dual-Box Role - //gs c main : "I am the main now, you are my alts"
---============================================================================
--- Typed on the character that becomes main. It switches itself to main and
--- sends `gs c setalt <me>` to the other members of the box group, which
--- switch to alt of it. No file to edit on either side.
---
--- The choice is saved in <Character>/config/dualbox_role.lua and applied
--- over DUALBOX_CONFIG.lua at every load, so it holds through a reload and a
--- game restart. Delete that file to go back to DUALBOX_CONFIG.lua.
---
--- Group: DualBoxConfig.group, else this character plus the one named in
--- DUALBOX_CONFIG.lua.
---
--- @file shared/utils/dualbox/dualbox_role.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

local DualBoxRole = {}

local function messages()
    local ok, m = pcall(require, 'shared/utils/messages/formatters/system/message_altgroup')
    return ok and m or nil
end

local function my_name()
    return (player and player.name) or (_G.DualBoxConfig and _G.DualBoxConfig.character_name)
end

local function role_file(name)
    return windower.addon_path .. 'data/' .. name .. '/config/dualbox_role.lua'
end

--- Everyone in the group but this character.
--- @return table Names
local function others()
    local cfg, me = _G.DualBoxConfig or {}, (my_name() or ''):lower()
    local names = cfg.group
    if type(names) ~= 'table' or #names == 0 then
        names = {cfg.character_name, cfg.alt_character, cfg.main_character}
    end
    local list, seen = {}, {}
    for _, name in pairs(names) do
        if type(name) == 'string' and name ~= '' and name:lower() ~= me and not seen[name:lower()] then
            seen[name:lower()] = true
            list[#list + 1] = name
        end
    end
    return list
end

--- Rewrite the live config for a role. Every dual-box module reads
--- _G.DualBoxConfig when it runs, so nothing else needs telling.
--- @param role string 'main' or 'alt'
--- @param names table Alts (role main) or {main} (role alt)
local function set_config(role, names)
    local cfg = _G.DualBoxConfig
    cfg.role = role
    if role == 'main' then
        cfg.alt_characters = names
        cfg.alt_character = names[1]
        cfg.alt_name = names[1]
        cfg.main_character = nil
    else
        cfg.main_character = names[1]
        cfg.alt_name = names[1]
        cfg.alt_character = nil
        cfg.alt_characters = nil
    end
end

local function save(role, names)
    local file = io.open(role_file(my_name()), 'w')
    if not file then return end
    local quoted = {}
    for i, n in ipairs(names) do quoted[i] = string.format('%q', n) end
    file:write('-- Written by //gs c main. Delete this file to go back to DUALBOX_CONFIG.lua.\n')
    file:write(string.format('return {role = %q, names = {%s}}\n', role, table.concat(quoted, ', ')))
    file:close()
end

--- Exchange jobs (and, as alt, buffs) with the new partners right away.
local function resync(role)
    local ok, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if ok and DualBoxManager then
        DualBoxManager.send_job_update(true)
        DualBoxManager.request_alt_job()
    end
    if role == 'alt' then
        local ok2, Reporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
        if ok2 and Reporter then Reporter.report_all() end
    end
    local ok3, AltWindow = pcall(require, 'shared/utils/dualbox/alt_window')
    if ok3 and AltWindow then AltWindow.refresh() end
end

--- //gs c main - this character becomes main, the others its alts.
--- @return boolean handled
function DualBoxRole.become_main()
    if not _G.DualBoxConfig or _G.DualBoxConfig.enabled == false then
        if messages() then messages().show_no_alts() end
        return true
    end
    local alts, me = others(), my_name()
    if #alts == 0 then
        if messages() then messages().show_no_alts() end
        return true
    end
    set_config('main', alts)
    save('main', alts)
    for _, name in ipairs(alts) do
        send_command('send ' .. name .. ' gs c setalt ' .. me)
    end
    resync('main')
    if messages() then messages().show_role_main(me, table.concat(alts, ', ')) end
    return true
end

--- //gs c setalt <main> - sent by the new main; this character becomes its alt.
--- @param args table {main name}
--- @return boolean handled
function DualBoxRole.become_alt(args)
    local main = args and args[1]
    if not main or not _G.DualBoxConfig then return true end
    set_config('alt', {main})
    save('alt', {main})
    resync('alt')
    if messages() then messages().show_role_alt(my_name(), main) end
    return true
end

--- Apply the saved role over the freshly loaded DUALBOX_CONFIG.lua.
--- Called by DualBoxManager.initialize; silent.
function DualBoxRole.apply_saved()
    local name = my_name()
    if not name or not _G.DualBoxConfig then return end
    local ok, saved = pcall(dofile, role_file(name))
    if ok and type(saved) == 'table' and (saved.role == 'main' or saved.role == 'alt')
        and type(saved.names) == 'table' and #saved.names > 0 then
        set_config(saved.role, saved.names)
    end
end

return DualBoxRole
