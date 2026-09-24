---============================================================================
--- DRG Message Data - Dragoon Messages
---============================================================================
--- Pure data file for DRG job messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/jobs/drg_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- JUMP ERROR MESSAGES
    ---========================================================================

    drg_subjob_required = {
        template = "{red}[Jump] Requires DRG subjob",
        color = 1
    },

    subjob_disabled = {
        template = "{red}[Jump] Subjob disabled (level 0 - Odyssey)",
        color = 1
    },

    jump_on_cooldown = {
        template = "{red}[Jump] Jump on cooldown ({recast}s)",
        color = 1
    },

    high_jump_on_cooldown = {
        template = "{red}[Jump] High Jump on cooldown ({recast}s)",
        color = 1
    }
}
