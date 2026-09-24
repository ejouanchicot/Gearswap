---  ═══════════════════════════════════════════════════════════════════════════
---   JA Database Factory - Centralized loader for per-job JA databases
---  ═══════════════════════════════════════════════════════════════════════════
---   Replaces 21 near-identical <JOB>_JA_DATABASE.lua wrappers with a single
---   parametrised loader. Each wrapper now reduces to a one-liner that calls
---   this factory with optional overrides for non-standard layouts.
---
---   Standard jobs (15): subjob / mainjob / sp modules with `.abilities` field.
---   Special cases (explicit `opts.modules`, all read `.abilities`):
---     - DNC: 15 modules (waltzes, sambas, steps, flourishes, jigs)
---     - BST: + pet_commands_mainjob / pet_commands_subjob
---     - SCH: + white/black grimoire, subjob and mainjob variants
---     - COR: + rolls_subjob / rolls_mainjob
---     - PUP: + pet_commands_subjob
---     - DRG: + pet_commands
---
---   Consumers:
---     - shared/utils/messages/handlers/ability_message_handler.lua (per-job)
---
---   @file    shared/data/job_abilities/JA_DATABASE_FACTORY.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-06
---  ═══════════════════════════════════════════════════════════════════════════

local Factory = {}

---   Build a JA database table by loading and merging job-specific modules.
---   @param job_code string Uppercase 3-letter job code (e.g. "WAR", "COR")
---   @param opts table|nil Optional overrides:
---     modules       table   List of module suffixes (default: {"subjob","mainjob","sp"})
---     source_field  string  Field name on each loaded module (default: "abilities")
---     extra         table   Additional {modules, source_field} pairs to merge after the main load
---   @return table JA_DB Map of ability_name -> ability_data
function Factory.create(job_code, opts)
    opts = opts or {}
    local job = job_code:lower()
    local modules = opts.modules or {'subjob', 'mainjob', 'sp'}
    local source_field = opts.source_field or 'abilities'

    local DB = {}

    local function load_modules(mod_list, field)
        for _, suffix in ipairs(mod_list) do
            local path = 'shared/data/job_abilities/' .. job .. '/' .. job .. '_' .. suffix
            local ok, mod = pcall(require, path)
            if ok and mod and mod[field] then
                for name, data in pairs(mod[field]) do
                    DB[name] = data
                end
            end
        end
    end

    load_modules(modules, source_field)

    -- Merge any extra module groups (no wrapper passes opts.extra today)
    if opts.extra then
        for _, group in ipairs(opts.extra) do
            load_modules(group.modules, group.source_field or 'abilities')
        end
    end

    return DB
end

return Factory
