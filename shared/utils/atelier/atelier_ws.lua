---============================================================================
--- Atelier WS - the weaponskills a job's sets name, for the Atelier page
---============================================================================
--- For each weaponskill a set path names (sets.precast.WS["Savage Blade"]):
---   skill  its combat skill ("Sword"): the page puts a weapon of that skill in the set
---   info   what the weaponskill uses, from shared/data/weaponskills/<SKILL>_WS_DATABASE.lua:
---          type (Physical / Magical / Hybrid), mods ({STR = 60, VIT = 60}), hits, element,
---          ftp by TP ({["1000"] = 3.05, ...}), crit (its text names critical hits),
---          replicating (its fTP goes to every hit).
---          The piece picker ranks the pieces by the stats the weaponskill is after.
---
--- @file    shared/utils/atelier/atelier_ws.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-02
---============================================================================

local AtelierWS = {}

--- {weaponskill = combat skill} and {weaponskill = {type, mods, hits, element}} for the sets.
--- @param set_list table The export's sets ({path, ...})
--- @return table|nil skills, table|nil info
function AtelierWS.collect(set_list)
    local ok, res = pcall(require, 'resources')
    if not (ok and res and res.weapon_skills and res.skills) then return nil end
    local by_name = {}
    for _, ws in pairs(res.weapon_skills) do
        local skill = ws.en and ws.skill and res.skills[ws.skill]
        if skill and skill.en then by_name[ws.en] = skill.en end
    end
    local skills = {}
    for _, set in ipairs(set_list or {}) do
        for name in tostring(set.path):gmatch('"([^"]+)"') do skills[name] = by_name[name] end
        for name in tostring(set.path):gmatch('%.([%w_]+)') do skills[name] = skills[name] or by_name[name] end
    end
    local ok_db, Universal = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
    local info = {}
    for name, skill in pairs(skills) do
        local entry = ok_db and Universal.resolve and Universal.resolve(name, skill)
        if type(entry) == 'table' then
            -- what the databases say in words: a critical weaponskill, fTP carried to every hit
            local words = table.concat({entry.description or '', entry.special_notes or '', entry.notes or ''}, ' '):lower()
            local ftp = {}
            for tp, v in pairs(type(entry.ftp) == 'table' and entry.ftp or {}) do ftp[tostring(tp)] = v end
            info[name] = {type = entry.type, mods = entry.mods or entry.stat_modifiers, hits = entry.hits, element = entry.element,
                ftp = ftp, crit = words:find('crit', 1, true) ~= nil, replicating = words:find('replicat', 1, true) ~= nil}
        end
    end
    return skills, info
end

return AtelierWS
