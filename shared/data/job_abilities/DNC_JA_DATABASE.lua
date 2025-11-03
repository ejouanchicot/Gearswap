---============================================================================
--- DNC Job Ability Database - Legacy Wrapper
---============================================================================
--- Auto-generated wrapper for backward compatibility with UNIVERSAL_JA_DATABASE.
--- Loads from new modular structure (subjob/mainjob/sp) and merges into
--- simple {ability_name = ability_data} format.
---
--- @file DNC_JA_DATABASE.lua
--- @author Tetsouo (auto-generated)
--- @version 1.0
--- @date Created: 2025-10-31
---============================================================================

local JA_DB = {}

-- List of all DNC modular files
local DNC_MODULES = {
    'shared/data/job_abilities/dnc/dnc_subjob',
    'shared/data/job_abilities/dnc/dnc_mainjob',
    'shared/data/job_abilities/dnc/dnc_sp',
    'shared/data/job_abilities/dnc/dnc_waltzes_subjob',
    'shared/data/job_abilities/dnc/dnc_waltzes_mainjob',
    'shared/data/job_abilities/dnc/dnc_sambas_subjob',
    'shared/data/job_abilities/dnc/dnc_sambas_mainjob',
    'shared/data/job_abilities/dnc/dnc_steps_subjob',
    'shared/data/job_abilities/dnc/dnc_steps_mainjob',
    'shared/data/job_abilities/dnc/dnc_flourishes1_subjob',
    'shared/data/job_abilities/dnc/dnc_flourishes2_subjob',
    'shared/data/job_abilities/dnc/dnc_flourishes2_mainjob',
    'shared/data/job_abilities/dnc/dnc_flourishes3_mainjob',
    'shared/data/job_abilities/dnc/dnc_jigs_subjob',
    'shared/data/job_abilities/dnc/dnc_jigs_mainjob',
}

-- Load all modules and merge abilities
for _, module_path in ipairs(DNC_MODULES) do
    local success, module = pcall(require, module_path)
    if success and module and module.abilities then
        for ability_name, ability_data in pairs(module.abilities) do
            JA_DB[ability_name] = ability_data
        end
    end
end

return JA_DB
