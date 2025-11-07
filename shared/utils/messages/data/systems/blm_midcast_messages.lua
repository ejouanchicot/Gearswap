---============================================================================
--- BLM_MIDCAST Message Data - BLM Midcast Debug Messages
---============================================================================
--- Pure data file for BLM midcast debug messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/blm_midcast_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- ELEMENTAL MAGIC MESSAGES
    ---========================================================================

    elemental_routing = {
        template = "{green}[BLM_MIDCAST] -> Routing to MidcastManager (Elemental)",
        color = 158
    },

    elemental_magic_burst_mode = {
        template = "{green}[BLM_MIDCAST]   * MagicBurstMode: {magic_burst_mode}",
        color = 158
    },

    mode_value = {
        template = "{green}[BLM_MIDCAST]   * mode_value: {mode_value}",
        color = 158
    },

    mp_conservation = {
        template = "{green}[BLM_MIDCAST]   * MP Conservation: {current_mp} < {mp_threshold} (applying MPConservation set)",
        color = 158
    },

    normal_mp = {
        template = "{green}[BLM_MIDCAST]   * Normal MP: {current_mp} >= {mp_threshold} (no MP conservation)",
        color = 158
    },

    elemental_match = {
        template = "{lightblue}[BLM_MIDCAST]   * Elemental Match: {reason}",
        color = 159
    },

    elemental_return = {
        template = "{green}[BLM_MIDCAST] <- MidcastManager returned",
        color = 158
    },

    ---========================================================================
    --- DARK MAGIC MESSAGES
    ---========================================================================

    dark_routing = {
        template = "{green}[BLM_MIDCAST] -> Routing to MidcastManager (Dark Magic)",
        color = 158
    },

    dark_return = {
        template = "{green}[BLM_MIDCAST] <- MidcastManager returned",
        color = 158
    },

    ---========================================================================
    --- ENFEEBLING MAGIC MESSAGES
    ---========================================================================

    enfeebling_routing = {
        template = "{green}[BLM_MIDCAST] -> Routing to MidcastManager (Enfeebling)",
        color = 158
    },

    enfeebling_return = {
        template = "{green}[BLM_MIDCAST] <- MidcastManager returned",
        color = 158
    },

    ---========================================================================
    --- GENERAL MESSAGES
    ---========================================================================

    skill_not_handled = {
        template = "{purple}[BLM_MIDCAST] !! Spell skill not handled by MidcastManager: {spell_skill}",
        color = 206
    },
}
