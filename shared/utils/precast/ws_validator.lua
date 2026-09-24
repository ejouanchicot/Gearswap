---============================================================================
--- WS Validator - WeaponSkill range and validity check
---============================================================================
--- Internal step of WSPrecastHandler: checks WS range and validity through
--- WeaponSkillManager and sets eventArgs.cancel when either fails.
---
--- @file    shared/utils/precast/ws_validator.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-17
---============================================================================

local WSValidator = {}

-- weaponskill_manager.lua is include()d: it publishes WeaponSkillManager as a
-- global instead of returning a module.
include('../shared/utils/weaponskill/weaponskill_manager.lua')

--- Validate a weaponskill before it is sent.
--- Non-weaponskills, and a missing WeaponSkillManager, pass through.
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (cancel is set on failure)
--- @return boolean True if the WS may proceed, false if it was cancelled
function WSValidator.validate(spell, eventArgs)
    if spell.type ~= 'WeaponSkill' then
        return true
    end

    if not WeaponSkillManager then
        return true
    end

    if not WeaponSkillManager.check_weaponskill_range(spell) then
        eventArgs.cancel = true
        return false
    end

    if not WeaponSkillManager.validate_weaponskill(spell.name) then
        eventArgs.cancel = true
        return false
    end

    return true
end

return WSValidator
