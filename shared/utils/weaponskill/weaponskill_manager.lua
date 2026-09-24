---============================================================================
--- Weapon Skill Manager - WS range and status validation
---============================================================================
--- Range check (target model size + WS range x multiplier) and Amnesia check
--- for weaponskills. Loaded with include() by ws_validator.lua, which is the
--- layer WSPrecastHandler calls; published as the global WeaponSkillManager.
---
--- @file    shared/utils/weaponskill/weaponskill_manager.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-01-02
---============================================================================

local MessageWeaponskill = require('shared/utils/messages/formatters/combat/message_weaponskill')

local WeaponSkillManager = {
    -- Optional formatter override. Nothing assigns it today, so the
    -- MessageWeaponskill fallbacks below are the messages actually shown.
    MessageFormatter = nil
}

---============================================================================
--- Configuration
---============================================================================
WeaponSkillManager.config = {
    distance_check_enabled = true,  -- not read anywhere
    range_multiplier = 1.55,        -- applied to spell.range in the range check
    debug_mode = false
}

---============================================================================
--- Core Functions
---============================================================================

--- Initialize the WeaponSkill manager
function WeaponSkillManager.initialize()
    if WeaponSkillManager.config.debug_mode then
        MessageWeaponskill.show_ws_manager_initialized()
    end
end

--- Check if a weapon skill is within range
--- @param spell table The spell/WS data from GearSwap
--- @return boolean True if in range, false if should be cancelled
function WeaponSkillManager.check_weaponskill_range(spell)
    if spell.type ~= "WeaponSkill" then
        return true
    end

    if not spell or type(spell) ~= 'table' then
        if WeaponSkillManager.config.debug_mode then
            MessageWeaponskill.show_invalid_spell_parameter()
        end
        return false
    end

    -- Status (Amnesia) before range
    if not WeaponSkillManager.validate_weaponskill(spell.name) then
        cancel_spell()
        return false
    end

    if not spell.target or type(spell.target) ~= 'table' then
        if WeaponSkillManager.config.debug_mode then
            MessageWeaponskill.show_target_info_missing()
        end
        return false
    end

    if type(spell.range) ~= 'number' or type(spell.target.distance) ~= 'number' or type(spell.target.model_size) ~= 'number' then
        if WeaponSkillManager.config.debug_mode then
            MessageWeaponskill.show_missing_numeric_values()
        end
        return false
    end

    local range_multiplier = WeaponSkillManager.config.range_multiplier or 1.55
    local effective_range = spell.target.model_size + spell.range * range_multiplier

    if effective_range < spell.target.distance then
        cancel_spell()

        local distance_info = string.format("Distance: %.1fy", spell.target.distance)

        if WeaponSkillManager.MessageFormatter then
            WeaponSkillManager.MessageFormatter.show_range_error(spell.name, distance_info)
        else
            MessageWeaponskill.show_too_far(spell.name, distance_info)
        end

        return false
    end

    return true
end

--- Validate if a weapon skill can be used
--- @param ws_name string The weapon skill name
--- @return boolean True if WS can be used, false otherwise
function WeaponSkillManager.validate_weaponskill(ws_name)
    local player = windower.ffxi.get_player()

    if not player then
        if WeaponSkillManager.config.debug_mode then
            MessageWeaponskill.show_player_info_missing()
        end
        return false
    end

    -- No TP check here: WSPrecastHandler checks >= 1000 on the TP read from
    -- the game itself (TPBonusHandler.live_tp), not GearSwap's lagging copy.
    -- TP display is handled in job_post_precast via MessageFormatter.show_ws_tp()

    if buffactive and buffactive['Amnesia'] then
        if WeaponSkillManager.MessageFormatter then
            WeaponSkillManager.MessageFormatter.show_ws_validation_error(
                ws_name or "WeaponSkill",
                "Cannot use -",
                nil,  -- no detail
                "Amnesia"  -- status ailment (will be colored purple)
            )
        else
            MessageWeaponskill.show_amnesia_error(ws_name)
        end
        return false
    end

    return true
end

-- Global for include() callers (ws_validator.lua)
_G.WeaponSkillManager = WeaponSkillManager

return WeaponSkillManager