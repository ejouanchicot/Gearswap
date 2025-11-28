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
        template = "{gray}[{lightblue}{job}{gray}] [{cyan}{spell}{gray}] >> {green}{target} {gray}>> {description}",
        color = 1
    },

    -- Spell with description (no target or self)
    spell_activated_full = {
        template = "{gray}[{lightblue}{job}{gray}] [{cyan}{spell}{gray}] >> {description}",
        color = 1
    },

    -- Spell name only with target
    spell_activated_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{cyan}{spell}{gray}] >> {green}{target}",
        color = 1
    },

    -- Spell name only (no target)
    spell_activated = {
        template = "{gray}[{lightblue}{job}{gray}] [{cyan}{spell}{gray}]",
        color = 1
    },

    ---========================================================================
    --- HEALING SPELL ACTIVATION MESSAGES (code 006)
    ---========================================================================

    -- Healing spell with description and target
    healing_spell_activated_full_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{healgreen}{spell}{gray}] >> {green}{target} {gray}>> {description}",
        color = 1
    },

    -- Healing spell with description (no target or self)
    healing_spell_activated_full = {
        template = "{gray}[{lightblue}{job}{gray}] [{healgreen}{spell}{gray}] >> {description}",
        color = 1
    },

    -- Healing spell name only with target
    healing_spell_activated_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{healgreen}{spell}{gray}] >> {green}{target}",
        color = 1
    },

    -- Healing spell name only (no target)
    healing_spell_activated = {
        template = "{gray}[{lightblue}{job}{gray}] [{healgreen}{spell}{gray}]",
        color = 1
    },

    ---========================================================================
    --- ENHANCING SPELL ACTIVATION MESSAGES (code 206)
    ---========================================================================

    -- Enhancing spell with description and target
    enhancing_spell_activated_full_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{enhancing}{spell}{gray}] >> {green}{target} {gray}>> {description}",
        color = 1
    },

    -- Enhancing spell with description (no target or self)
    enhancing_spell_activated_full = {
        template = "{gray}[{lightblue}{job}{gray}] [{enhancing}{spell}{gray}] >> {description}",
        color = 1
    },

    -- Enhancing spell name only with target
    enhancing_spell_activated_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{enhancing}{spell}{gray}] >> {green}{target}",
        color = 1
    },

    -- Enhancing spell name only (no target)
    enhancing_spell_activated = {
        template = "{gray}[{lightblue}{job}{gray}] [{enhancing}{spell}{gray}]",
        color = 1
    },

    ---========================================================================
    --- ENFEEBLING SPELL ACTIVATION MESSAGES (code 015)
    ---========================================================================

    -- Enfeebling spell with description and target
    enfeebling_spell_activated_full_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{enfeebling}{spell}{gray}] >> {green}{target} {gray}>> {description}",
        color = 1
    },

    -- Enfeebling spell with description (no target or self)
    enfeebling_spell_activated_full = {
        template = "{gray}[{lightblue}{job}{gray}] [{enfeebling}{spell}{gray}] >> {description}",
        color = 1
    },

    -- Enfeebling spell name only with target
    enfeebling_spell_activated_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{enfeebling}{spell}{gray}] >> {green}{target}",
        color = 1
    },

    -- Enfeebling spell name only (no target)
    enfeebling_spell_activated = {
        template = "{gray}[{lightblue}{job}{gray}] [{enfeebling}{spell}{gray}]",
        color = 1
    },

    ---========================================================================
    --- DIVINE SPELL ACTIVATION MESSAGES (code 022)
    ---========================================================================

    -- Divine spell with description and target
    divine_spell_activated_full_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{divine}{spell}{gray}] >> {green}{target} {gray}>> {description}",
        color = 1
    },

    -- Divine spell with description (no target or self)
    divine_spell_activated_full = {
        template = "{gray}[{lightblue}{job}{gray}] [{divine}{spell}{gray}] >> {description}",
        color = 1
    },

    -- Divine spell name only with target
    divine_spell_activated_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{divine}{spell}{gray}] >> {green}{target}",
        color = 1
    },

    -- Divine spell name only (no target)
    divine_spell_activated = {
        template = "{gray}[{lightblue}{job}{gray}] [{divine}{spell}{gray}]",
        color = 1
    },

    ---========================================================================
    --- DARK MAGIC SPELL ACTIVATION MESSAGES (code 015)
    ---========================================================================

    -- Dark magic spell with description and target
    dark_spell_activated_full_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{dark}{spell}{gray}] >> {green}{target} {gray}>> {description}",
        color = 1
    },

    -- Dark magic spell with description (no target or self)
    dark_spell_activated_full = {
        template = "{gray}[{lightblue}{job}{gray}] [{dark}{spell}{gray}] >> {description}",
        color = 1
    },

    -- Dark magic spell name only with target
    dark_spell_activated_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{dark}{spell}{gray}] >> {green}{target}",
        color = 1
    },

    -- Dark magic spell name only (no target)
    dark_spell_activated = {
        template = "{gray}[{lightblue}{job}{gray}] [{dark}{spell}{gray}]",
        color = 1
    },

    ---========================================================================
    --- BLUE MAGIC SPELL ACTIVATION MESSAGES (code 219)
    ---========================================================================

    -- Blue magic spell with description and target
    blue_spell_activated_full_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{bluemagic}{spell}{gray}] >> {green}{target} {gray}>> {description}",
        color = 1
    },

    -- Blue magic spell with description (no target or self)
    blue_spell_activated_full = {
        template = "{gray}[{lightblue}{job}{gray}] [{bluemagic}{spell}{gray}] >> {description}",
        color = 1
    },

    -- Blue magic spell name only with target
    blue_spell_activated_target = {
        template = "{gray}[{lightblue}{job}{gray}] [{bluemagic}{spell}{gray}] >> {green}{target}",
        color = 1
    },

    -- Blue magic spell name only (no target)
    blue_spell_activated = {
        template = "{gray}[{lightblue}{job}{gray}] [{bluemagic}{spell}{gray}]",
        color = 1
    },
}
