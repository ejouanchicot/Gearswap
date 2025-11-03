---============================================================================
--- Weapon Skill Manager
---============================================================================
--- Centralized weapon skill validation and management system
--- Based on RANGE_MANAGER pattern for distance validation
---
--- @module WEAPONSKILL_MANAGER
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-01-02
---============================================================================

local WeaponSkillManager = {
    -- MessageFormatter will be set by the caller if available
    MessageFormatter = nil
}

---============================================================================
--- Configuration
---============================================================================
WeaponSkillManager.config = {
    -- Distance validation settings
    distance_check_enabled = true,
    range_multiplier = 1.55,  -- Range multiplier for effective distance calculation

    -- Debug settings
    debug_mode = false
}

---============================================================================
--- Core Functions
---============================================================================

--- Initialize the WeaponSkill manager
function WeaponSkillManager.initialize()
    -- Initialization logic here
    if WeaponSkillManager.config.debug_mode then
        add_to_chat(123, "[WS Manager] Initialized")
    end
end

--- Check if a weapon skill is within range
--- @param spell table The spell/WS data from GearSwap
--- @return boolean True if in range, false if should be cancelled
function WeaponSkillManager.check_weaponskill_range(spell)
    -- Only check weapon skills
    if spell.type ~= "WeaponSkill" then
        return true
    end

    -- Validation
    if not spell or type(spell) ~= 'table' then
        if WeaponSkillManager.config.debug_mode then
            add_to_chat(123, "[WS Manager] Invalid spell parameter for range check")
        end
        return false
    end

    -- Validate TP and status before range check
    if not WeaponSkillManager.validate_weaponskill(spell.name) then
        cancel_spell()
        return false
    end

    if not spell.target or type(spell.target) ~= 'table' then
        if WeaponSkillManager.config.debug_mode then
            add_to_chat(123, "[WS Manager] Spell target information missing")
        end
        return false
    end

    -- Check required numeric values
    if type(spell.range) ~= 'number' or type(spell.target.distance) ~= 'number' or type(spell.target.model_size) ~= 'number' then
        if WeaponSkillManager.config.debug_mode then
            add_to_chat(123, "[WS Manager] Missing numeric values for range calculation")
        end
        return false
    end

    -- Calculate effective range
    local range_multiplier = WeaponSkillManager.config.range_multiplier or 1.55
    local effective_range = spell.target.model_size + spell.range * range_multiplier

    -- Check if target is out of range
    if effective_range < spell.target.distance then
        -- Cancel the spell
        cancel_spell()

        -- Display error message using MessageFormatter if available
        local distance_info = string.format("Distance: %.1fy", spell.target.distance)

        if WeaponSkillManager.MessageFormatter then
            -- Use the proper formatted message
            WeaponSkillManager.MessageFormatter.show_range_error(spell.name, distance_info)
        else
            -- Fallback to basic message (no MessageFormatter loaded)
            add_to_chat(167, string.format("[%s] Too Far ! (%s)", spell.name, distance_info))
        end

        return false
    end

    return true
end

--- Validate if a weapon skill can be used
--- @param ws_name string The weapon skill name
--- @return boolean True if WS can be used, false otherwise
function WeaponSkillManager.validate_weaponskill(ws_name)
    -- Get player info
    local player = windower.ffxi.get_player()

    if not player then
        if WeaponSkillManager.config.debug_mode then
            add_to_chat(123, "[WS Manager] Player info not available")
        end
        return false
    end

    -- TP validation removed - lag causes false positives (GS sees 800-950 when player has 1000)
    -- TP display is handled in job_post_precast via MessageFormatter.show_ws_tp()

    -- Status ailment check (Amnesia only)
    if buffactive and buffactive['Amnesia'] then
        if WeaponSkillManager.MessageFormatter then
            WeaponSkillManager.MessageFormatter.show_ws_validation_error(
                ws_name or "WeaponSkill",
                "Cannot use -",
                nil,  -- no detail
                "Amnesia"  -- status ailment (will be colored purple)
            )
        else
            add_to_chat(167, string.format("[%s] Cannot use - Amnesia", ws_name or "WS"))
        end
        return false
    end

    return true
end

-- Make it globally available for GearSwap
_G.WeaponSkillManager = WeaponSkillManager

return WeaponSkillManager