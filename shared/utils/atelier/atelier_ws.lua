---============================================================================
--- Atelier WS - the weaponskills a job's sets name, for the Atelier page
---============================================================================
--- For each weaponskill a set path names (sets.precast.WS["Savage Blade"]), and every
--- weaponskill the job can use at its level (the databases' `jobs`: relic, mythic,
--- empyrean, aeonic and prime ones included), so the page can create their sets:
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
-- The combat skills that have a weaponskill database (shared/data/weaponskills/)
local SKILLS = {'Sword', 'Dagger', 'Hand-to-Hand', 'Great Sword', 'Great Axe', 'Axe', 'Scythe', 'Polearm',
    'Katana', 'Great Katana', 'Staff', 'Club', 'Archery'}

--- Every weaponskill the databases give this job at this level: {name = combat skill}. The level
--- is under `jobs` (`job_levels` in the dagger file); `main_or_sub` lists the jobs one of which
--- must be the main or the subjob (Viper Bite, Aeolian Edge...).
--- @param job string Main job code
--- @param level number|nil Main job level (99 when unknown)
--- @param sub string|nil Subjob code
local function job_weaponskills(job, level, sub)
    local ok, Universal = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
    if not (ok and Universal and Universal.ensure_weapon_type and job) then return {} end
    for _, skill in ipairs(SKILLS) do Universal.ensure_weapon_type(skill) end
    local out, all = {}, (rawget(_G, 'WS_DATABASE') or {}).weaponskills or {}
    for name, entry in pairs(all) do
        local levels = type(entry.jobs) == 'table' and entry.jobs or entry.job_levels
        local need = type(levels) == 'table' and levels[job]
        local allowed = true
        if type(entry.main_or_sub) == 'table' then
            allowed = false
            for _, j in ipairs(entry.main_or_sub) do if j == job or j == sub then allowed = true end end
        end
        if need and allowed and (level or 99) >= need then out[name] = entry.weapon_type end
    end
    return out
end

--- @param set_list table The export's sets ({path, ...})
--- @param job string|nil Main job code (its weaponskills are added)
--- @param level number|nil Main job level
--- @param sub string|nil Subjob code
--- @return table|nil skills, table|nil info
function AtelierWS.collect(set_list, job, level, sub)
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
    for name, skill in pairs(job_weaponskills(job, level, sub)) do skills[name] = skills[name] or skill end
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
