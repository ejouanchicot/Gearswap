---============================================================================
--- Tuning - the numbers and names some jobs use, set per character
---============================================================================
--- Thresholds and names the jobs used to fix in their code (SAM idle HP
--- sets, COR / WHM refresh MP, waltz tiers, SMN skill-up, GEO escort, BRD
--- debuff songs). The character's _common/combat/TUNING.lua overrides them;
--- a table is merged key by key over the job's default, so one key is
--- enough. The default stays when the file or the key is missing.
---
--- @file shared/utils/core/tuning.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-30
---============================================================================

local Tuning = {}

--- The character's TUNING.lua, or an empty table.
--- @return table
local function user_file()
    local ok, cfg = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'TUNING')
    end)
    return (ok and type(cfg) == 'table') and cfg or {}
end

--- A tuning value: the file's, else `default`. A table default is merged
--- (the file's keys over it); a value of another type than the default's is
--- ignored.
--- @param key string Name in TUNING.lua
--- @param default any The job's own value
--- @return any
function Tuning.get(key, default)
    local value = user_file()[key]
    if value == nil then return default end
    if type(default) == 'table' then
        if type(value) ~= 'table' then return default end
        local merged = {}
        for k, v in pairs(default) do merged[k] = v end
        for k, v in pairs(value) do merged[k] = v end
        return merged
    end
    if default ~= nil and type(value) ~= type(default) then return default end
    return value
end

return Tuning
