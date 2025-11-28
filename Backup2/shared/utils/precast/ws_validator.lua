---============================================================================
--- WS Validator - Universal WeaponSkill Validation
---============================================================================
--- Centralizes weaponskill validation logic across all jobs.
--- Eliminates ~270 lines of duplicated code across 9 PRECAST modules.
---
--- Features:
---   • Range validation (check if target within WS range)
---   • Weaponskill validity checking
---   • Automatic eventArgs.cancel on validation failure
---   • Error messages via WeaponSkillManager
---
--- Usage (in job_precast):
---   if not WSValidator.validate(spell, eventArgs) then
---       return  -- Exit if WS validation failed
---   end
---
--- @file    utils/precast/ws_validator.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-17
---============================================================================

local WSValidator = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load weaponskill manager (legacy include-based module)
include('../shared/utils/weaponskill/weaponskill_manager.lua')

---============================================================================
--- VALIDATION FUNCTION
---============================================================================

--- Validate weaponskill (range + validity checks)
--- Called in job_precast() to validate WS before gear swap
--- Sets eventArgs.cancel = true if validation fails
---
--- @param spell table Spell/ability data from GearSwap
--- @param eventArgs table Event arguments (modified if validation fails)
--- @return boolean true if WS valid, false if validation failed
function WSValidator.validate(spell, eventArgs)
    -- Early exit if not weaponskill
    if spell.type ~= 'WeaponSkill' then
        return true
    end

    -- Early exit if WeaponSkillManager not available
    if not WeaponSkillManager then
        return true
    end

    -- Range check: Ensure target is within WS range
    if not WeaponSkillManager.check_weaponskill_range(spell) then
        eventArgs.cancel = true
        return false
    end

    -- Validity check: Ensure weaponskill is valid
    if not WeaponSkillManager.validate_weaponskill(spell.name) then
        eventArgs.cancel = true
        return false
    end

    -- All validations passed
    return true
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return WSValidator
