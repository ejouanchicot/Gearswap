---============================================================================
--- BLM Job Ability Database - Legacy Wrapper
---============================================================================
--- Auto-generated wrapper for backward compatibility with UNIVERSAL_JA_DATABASE.
--- Loads from new modular structure (subjob/mainjob/sp) and merges into
--- simple {ability_name = ability_data} format.
---
--- @file BLM_JA_DATABASE.lua
--- @author Tetsouo (auto-generated)
--- @version 1.0 - Improved formatting
--- @date Created: 2025-10-31
---============================================================================

local JA_DB = {}

-- Load subjob abilities
local subjob_success, subjob_module = pcall(require, 'shared/data/job_abilities/blm/blm_subjob')
if subjob_success and subjob_module and subjob_module.abilities then
    for ability_name, ability_data in pairs(subjob_module.abilities) do
        JA_DB[ability_name] = ability_data
    end
end

-- Load main job abilities
local mainjob_success, mainjob_module = pcall(require, 'shared/data/job_abilities/blm/blm_mainjob')
if mainjob_success and mainjob_module and mainjob_module.abilities then
    for ability_name, ability_data in pairs(mainjob_module.abilities) do
        JA_DB[ability_name] = ability_data
    end
end

-- Load SP abilities
local sp_success, sp_module = pcall(require, 'shared/data/job_abilities/blm/blm_sp')
if sp_success and sp_module and sp_module.abilities then
    for ability_name, ability_data in pairs(sp_module.abilities) do
        JA_DB[ability_name] = ability_data
    end
end

return JA_DB
