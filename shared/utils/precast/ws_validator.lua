-- WSValidator: WS range check + validity, cancels eventArgs if failed.

local WSValidator = {}

-- Load weaponskill manager (legacy include-based module)
include('../shared/utils/weaponskill/weaponskill_manager.lua')

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

return WSValidator
