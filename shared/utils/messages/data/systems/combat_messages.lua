---============================================================================
--- COMBAT Message Data - Combat Messages
---============================================================================
--- Pure data file for combat validation and state messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/combat_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- RANGE & VALIDATION ERRORS
    ---========================================================================

    range_error = {
        template = "{yellow}[{ability}]{red} Too Far ! {gray}({distance})",
        color = 1
    },

    ws_validation_error_status = {
        template = "{lightblue}[{job}] {yellow}[{ws_name}]{red} {reason} {purple}{status}",
        color = 1
    },

    ws_validation_error_detail = {
        template = "{gray}[{pink}{ws_name}{gray}]{red} {reason} {gray}({detail} TP)",
        color = 1
    },

    ws_validation_error = {
        template = "{lightblue}[{job}] {yellow}[{ws_name}]{red} {reason}",
        color = 1
    },

    target_error = {
        template = "Target Error: {action} ({reason})",
        color = 167
    },

    state_change = {
        template = "Combat: {old_state} >> {new_state}",
        color = 158
    },

    ability_tp_error = {
        template = "{gray}==================================================\n{lightblue}[{job}] {gray}Ability: {yellow}{ability}{red} Not enough TP {gray}({current_tp}/{required_tp} TP)\n{gray}==================================================",
        color = 1
    },

    ---========================================================================
    --- WEAPONSKILL MESSAGES
    ---========================================================================

    ws_tp_ultimate = {
        template = "{gray}[{pink}{ws_name}{gray}]{gray} ({green}{tp} TP{gray})",
        color = 1
    },

    ws_tp_enhanced = {
        template = "{gray}[{pink}{ws_name}{gray}]{gray} ({cyan}{tp} TP{gray})",
        color = 1
    },

    ws_tp_normal = {
        template = "{gray}[{pink}{ws_name}{gray}]{gray} ({white}{tp} TP{gray})",
        color = 1
    },

    ws_activated_ultimate = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}[{pink}{ws_name}{gray}]{gray} >> {description} {gray}({green}{tp} TP{gray})",
        color = 1
    },

    ws_activated_enhanced = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}[{pink}{ws_name}{gray}]{gray} >> {description} {gray}({cyan}{tp} TP{gray})",
        color = 1
    },

    ws_activated_normal = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}[{pink}{ws_name}{gray}]{gray} >> {description} {gray}({white}{tp} TP{gray})",
        color = 1
    },

    ws_activated_no_tp = {
        template = "{gray}[{lightblue}{job}{gray}] {gray}[{pink}{ws_name}{gray}]{gray} >> {description}",
        color = 1
    },

    ---========================================================================
    --- SPELL & ABILITY USAGE
    ---========================================================================

    spell_cast = {
        template = "{lightblue}[{job}]{gray} Casting {cyan}{spell_name}",
        color = 1
    },

    ability_use = {
        template = "{lightblue}[{job}]{gray} Using {yellow}{ability_name}",
        color = 1
    },

    ---========================================================================
    --- WALTZ HEALING (DNC)
    ---========================================================================

    waltz_heal_single = {
        template = "{gray}==================================================\n{lightblue}[{job}]{gray} Curing {green}{hp} HP{gray} using {yellow}{waltz_name}\n{gray}==================================================",
        color = 1
    },

    waltz_heal_single_extra = {
        template = "{gray}==================================================\n{lightblue}[{job}]{gray} Curing {green}{hp} HP{gray} using {yellow}{waltz_name}{gray} + {green}{extra}\n{gray}==================================================",
        color = 1
    },

    waltz_heal_aoe = {
        template = "{gray}==================================================\n{lightblue}[{job}]{gray} AoE Healing using {yellow}{waltz_name}\n{gray}==================================================",
        color = 1
    },

    waltz_heal_aoe_extra = {
        template = "{gray}==================================================\n{lightblue}[{job}]{gray} AoE Healing using {yellow}{waltz_name}{gray} + {green}{extra}\n{gray}==================================================",
        color = 1
    },

    ---========================================================================
    --- JUMP MESSAGES (DRG)
    ---========================================================================

    jump_activated = {
        template = "{lightblue}[{job}] {yellow}[{jump_ability}] {gray}>> {gray}{description}",
        color = 1
    },

    jump_chaining_desc = {
        template = "{lightblue}[{job}]{gray} Chaining {yellow}[{second_jump}] {gray}>> {gray}{description}",
        color = 1
    },

    jump_chaining = {
        template = "{lightblue}[{job}]{gray} Chaining {yellow}[{second_jump}]",
        color = 1
    },

    jump_complete = {
        template = "{lightblue}[{job}]{gray} Jump sequence complete",
        color = 1
    },

    jump_relaunch = {
        template = "{lightblue}[{job}]{gray} Re-launch {yellow}{ws_name}{gray} manually",
        color = 1
    },
}
