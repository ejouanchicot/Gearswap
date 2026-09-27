---============================================================================
--- HUD Job Config - a job's own HUD settings, in its config folder
---============================================================================
--- <Character>/config/<job>/<JOB>_HUD.lua holds what the HUD does on that
--- job only: its section order and its row order. Each list, when not
--- empty, replaces UI_CONFIG.lua's layout.section_order / layout.row_order
--- (the defaults of every job) on that job.
---
---   return {
---       section_order = {'weapons', 'modes', 'spells'},
---       row_order = {'TreasureMode', 'HybridMode'},
---   }
---
--- Read once per job and per load. //gs c ui order / roworder rewrite it
--- whole through render(): the explanation, the job's own states (read in
--- its _KEYBINDS.lua) and both lists, the one not changed kept.
---
--- @file    shared/utils/ui/hud_job_config.lua
--- @author  ejouanchicot
--- @version 1.2
--- @date    Created: 2026-09-27
---============================================================================

local HudJobConfig = {}

local HEADER = [[
-- HUD settings of this job only. UI_CONFIG.lua holds the defaults of every
-- job (layout.section_order, layout.row_order); a list here that is not
-- empty replaces the default on this job. Empty or missing = the default.
--
-- section_order: order of the HUD sections on this job. Names: spells,
--   enhancing, abilities, weapons, modes. Those left out follow in the
--   standard order.
-- row_order: order of the rows inside each section on this job. The rows
--   named come first in their section, in this order; the others follow in
--   the order of the job's _KEYBINDS file. Names = the states as written in
--   the _KEYBINDS file (capitals included), or keys.
--
-- Example:
--   section_order = {'weapons', 'modes', 'spells'},
--   row_order = {'MainWeapon', 'SubWeapon', 'TreasureMode', 'HybridMode'},
--
-- In game (this job, or name one: //gs c ui order THF weapons modes):
--   //gs c ui order weapons modes spells          this job's section order
--   //gs c ui roworder TreasureMode HybridMode    this job's row order
--   //gs c ui order reset / roworder reset        back to the default
--   //gs c ui order all ... / roworder all ...    the default of every job
-- A command puts the names typed first and keeps the others after them, in
-- their order (a job without its own list starts from the default one).
-- The commands rewrite this file; editing it by hand works too (//gs reload).
]]

local FIELDS = {'section_order', 'row_order'}

--- <Character>/config/<job>/<JOB>_HUD.lua, or nil before the player is known.
--- @param job string Job code
--- @return string|nil
function HudJobConfig.path(job)
    if not (job and player and player.name and windower and windower.addon_path) then return nil end
    return ('%sdata/%s/config/%s/%s_HUD.lua'):format(windower.addon_path, player.name, job:lower(), job:upper())
end

local function cache()
    _G._hud_job_config = _G._hud_job_config or {}
    return _G._hud_job_config
end

--- The job's settings table (empty when the file is missing or broken).
--- @param job string
--- @return table
function HudJobConfig.get(job)
    local key = job and job:upper()
    if not key then return {} end
    local known = cache()[key]
    if known ~= nil then return known end
    local path = HudJobConfig.path(key)
    local data = {}
    local file = path and io.open(path, 'r')
    if file then
        file:close()
        local ok, loaded = pcall(dofile, path)
        if ok and type(loaded) == 'table' then data = loaded end
    end
    cache()[key] = data
    return data
end

--- One of the job's own lists ('section_order' / 'row_order'), or nil when
--- it has none (the default applies).
--- @param job string
--- @param field string
--- @return table|nil
function HudJobConfig.list(job, field)
    local list = HudJobConfig.get(job)[field]
    if type(list) == 'table' and #list > 0 then return list end
    return nil
end

--- The job's own row order, or nil.
--- @param job string
--- @return table|nil
function HudJobConfig.row_order(job)
    return HudJobConfig.list(job, 'row_order')
end

--- The job's own section order, or nil.
--- @param job string
--- @return table|nil
function HudJobConfig.section_order(job)
    return HudJobConfig.list(job, 'section_order')
end

---============================================================================
--- FILE TEXT
---============================================================================

local function lua_list(list)
    local names = {}
    for i, name in ipairs(list) do
        names[i] = "'" .. tostring(name):gsub("'", "\\'") .. "'"
    end
    return '{' .. table.concat(names, ', ') .. '}'
end

--- The state names of a job's keybind file, in file order (no duplicates).
--- @param keybinds_path string|nil
--- @return table
local function job_states(keybinds_path)
    local file = keybinds_path and io.open(keybinds_path, 'r')
    if not file then return {} end
    local states, seen = {}, {}
    for line in file:lines() do
        -- A comment line ("-- Format: {... state = "state_name" ...}") is not a key
        if not line:match('^%s*%-%-') then
            for name in line:gmatch('state%s*=%s*["\']([%w_]+)["\']') do
                if not seen[name] then
                    seen[name] = true
                    states[#states + 1] = name
                end
            end
        end
    end
    file:close()
    return states
end

--- "-- States of this job (THF_KEYBINDS.lua): A, B, ..." cut at 76 columns.
local function states_comment(job, states)
    if #states == 0 then return '' end
    local lines = {}
    local line = ('-- States of this job (%s_KEYBINDS.lua):'):format(job:upper())
    for i, name in ipairs(states) do
        local word = ' ' .. name .. (i < #states and ',' or '')
        if #line + #word > 76 then
            lines[#lines + 1] = line
            line = '--  ' .. word
        else
            line = line .. word
        end
    end
    lines[#lines + 1] = line
    lines[#lines + 1] = '-- Also on every job: CombatMode, AutoMedicine and the common keys.'
    return table.concat(lines, '\n') .. '\n'
end

--- The whole file text: explanation, this job's states, the two lists (a
--- missing or empty one written commented out).
--- @param job string
--- @param data table {section_order =, row_order =}
--- @param keybinds_path string|nil The job's _KEYBINDS.lua, for its states
--- @return string
function HudJobConfig.render(job, data, keybinds_path)
    local lines = {}
    for _, name in ipairs(FIELDS) do
        local value = data[name]
        if type(value) == 'table' and #value > 0 then
            lines[#lines + 1] = ('    %s = %s,'):format(name, lua_list(value))
        else
            lines[#lines + 1] = ('    -- %s = {},'):format(name)
        end
    end
    return HEADER .. states_comment(job, job_states(keybinds_path))
        .. 'return {\n' .. table.concat(lines, '\n') .. '\n}\n'
end

--- Write one of the job's lists (nil = none: the default applies); the
--- other list of the file is kept.
--- @param job string
--- @param field string 'section_order' or 'row_order'
--- @param list table|nil
--- @return boolean saved
--- @return string|nil error
function HudJobConfig.set_list(job, field, list)
    local current = HudJobConfig.get(job)
    local path = HudJobConfig.path(job)
    local file = path and io.open(path, 'w')
    if not file then return false, 'cannot write ' .. tostring(path) end
    local data = {}
    for _, name in ipairs(FIELDS) do data[name] = current[name] end
    data[field] = list
    local keybinds_path = path:gsub('_HUD%.lua$', '_KEYBINDS.lua')
    file:write(HudJobConfig.render(job, data, keybinds_path))
    file:close()
    cache()[job:upper()] = nil
    return true
end

return HudJobConfig
