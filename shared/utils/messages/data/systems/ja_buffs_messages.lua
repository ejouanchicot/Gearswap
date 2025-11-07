---============================================================================
--- JA_BUFFS Message Data - Job Ability Buff Messages
---============================================================================
--- Pure data file for job ability activation/status messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/ja_buffs_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- JA ACTIVATION PATTERNS
    ---========================================================================

    -- Pattern 1: JA activated with description
    activated_full = {
        template = "{lightblue}[{job_tag}] {yellow}{ability_name} {gray}{description}",
        color = 1
    },

    -- Pattern 1b: JA activated name only
    activated_name_only = {
        template = "{lightblue}[{job_tag}] {yellow}{ability_name}",
        color = 1
    },

    -- Pattern 2: JA active status
    active = {
        template = "{lightblue}[{job_tag}] {yellow}{ability_name}{green} active",
        color = 1
    },

    -- Pattern 3: JA ended
    ended = {
        template = "{lightblue}[{job_tag}] {yellow}{ability_name}{gray} ended",
        color = 1
    },

    -- Pattern 4: JA with description (colon format)
    with_description = {
        template = "{lightblue}[{job_tag}] {yellow}{ability_name}{gray}: {gray}{description}",
        color = 1
    },

    -- Pattern 5: JA using (pre-action)
    using = {
        template = "{lightblue}[{job_tag}]{gray} Using {yellow}{ability_name}",
        color = 1
    },

    -- Pattern 6: JA using double (two abilities)
    using_double = {
        template = "{lightblue}[{job_tag}]{gray} Using {yellow}{ability1}{gray} + {yellow}{ability2}",
        color = 1
    },
}
