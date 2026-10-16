---============================================================================
--- Subjob abilities by number - //gs c ja1, ja2... for the subjob of the moment
---============================================================================
--- One macro per place in a list, whatever the subjob: //gs c ja1 is Hasso
--- under /SAM, Sneak Attack under /THF, Jump under /DRG... The lists are the
--- character's, in _common/combat/SUBJOB_CONFIG.lua `abilities`, by main job
--- (or `all` for every main job), then by subjob:
---
---   abilities = {
---       DRK = { SAM = {'Hasso', 'Meditate', 'Sekkanoki', 'Seigan'},
---               WAR = {'Aggressor', 'Berserk', 'Warcry'} },
---   },
---
--- //gs c ja 1 works too. The target is the ability's own: <me> for an
--- ability that only targets yourself, <t> otherwise; {name = 'X', target =
--- '<stnpc>'} in the list picks another one. Nothing is listed by default.
---
--- @file    shared/utils/commands/sub_abilities.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-16
---============================================================================

local SubAbilities = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')

--- The list for the current main job and subjob, or nil.
--- @return table|nil
local function current_list()
    local all = require('shared/utils/core/job_config').common('SUBJOB_CONFIG', 'abilities', {})
    if type(all) ~= 'table' or not player then return nil end
    local by_main = all[player.main_job] or all.all
    return type(by_main) == 'table' and by_main[player.sub_job] or nil
end

--- <me> for an ability that only targets yourself (the game's list), <t> otherwise.
--- @param name string
--- @return string
local function target_of(name)
    local gs = rawget(_G, 'gearswap')
    local res = rawget(_G, 'res') or (gs and gs.res)
    for _, a in pairs(res and res.job_abilities or {}) do
        if type(a) == 'table' and a.en == name then
            -- Windower's resources library gives a set of names; the raw file, bits (32 = Enemy)
            local t = a.targets
            local enemy = type(t) == 'table' and t.Enemy or type(t) == 'number' and math.floor(t / 32) % 2 == 1
            return enemy and '<t>' or '<me>'
        end
    end
    return '<t>'
end

--- Use the ability at a place of the current subjob's list.
--- @param index number
--- @return boolean true (the command is answered)
function SubAbilities.use(index)
    local list = current_list()
    local entry = list and list[index]
    if not entry then
        MessageFormatter.show_warning(('ja%s: nothing at that place for /%s (SUBJOB_CONFIG.lua abilities)')
            :format(tostring(index), tostring(player and player.sub_job)))
        return true
    end
    local name = type(entry) == 'table' and entry.name or entry
    local target = type(entry) == 'table' and entry.target or target_of(name)
    send_command(('input /ja "%s" %s'):format(name, target))
    return true
end

--- The place a command word names: ja3 -> 3, ja + '3' -> 3, else nil.
--- @param cmd string Lower-cased command word
--- @param arg string|nil Its first argument
--- @return number|nil
function SubAbilities.index_of(cmd, arg)
    local n = cmd:match('^ja(%d+)$')
    if n then return tonumber(n) end
    if cmd == 'ja' then return tonumber(arg) end
    return nil
end

return SubAbilities
