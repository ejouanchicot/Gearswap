---============================================================================
--- MAGIC Message Data - Generic Magic Messages
---============================================================================
--- Pure data file for generic magic spell messages (used by ALL jobs)
--- Used by new message system (api/messages.lua)
---
--- @file data/jobs/magic_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- SPELL ACTIVATION MESSAGES
    ---========================================================================

    -- Spell with description and target
    spell_activated_full_target = {
        template = "{lightblue}[{job}] {cyan}[{spell}] {gray}>> {green}{target} {gray}-> {gray}{description}",
        color = 1
    },

    -- Spell with description (no target or self)
    spell_activated_full = {
        template = "{lightblue}[{job}] {cyan}[{spell}] {gray}-> {gray}{description}",
        color = 1
    },

    -- Spell name only with target
    spell_activated_target = {
        template = "{lightblue}[{job}] {cyan}[{spell}] {gray}>> {green}{target}",
        color = 1
    },

    -- Spell name only (no target)
    spell_activated = {
        template = "{lightblue}[{job}] {cyan}[{spell}]",
        color = 1
    },
}
