---============================================================================
--- RDM Midcast Module - Intelligent Midcast Gear Selection (Powered by MidcastManager)
---============================================================================
--- Handles midcast gear selection for Red Mage spells using centralized MidcastManager.
---
--- Features:
---   - Enfeebling: Nested sets support via MidcastManager (e.g., mnd_potency.Valeur)
---   - Enfeebling: Database type detection using ENFEEBLING_MAGIC_DATABASE (NEW!)
---   - Enfeebling: EnfeebleMode state combination
---   - Enfeebling: Auto-equips Lethargy Gants +3 when Saboteur is active
---   - Enfeebling: Spell messages with ENFEEBLING_MESSAGES_CONFIG (on/full/off modes)
---   - Enhancing: Nested sets support via MidcastManager (e.g., self.Duration)
---   - Enhancing: Target-based selection (self vs party members)
---   - Enhancing: Spell messages with ENHANCING_MESSAGES_CONFIG (on/full/off modes)
---   - Healing: Cure/Raise messages via ENHANCING_MESSAGES_CONFIG
---   - Elemental: NukeMode-based selection via MidcastManager
---   - Complete fallback chain for all magic types (nested > type > mode > base)
---
--- @file RDM_MIDCAST.lua
--- @author Tetsouo
--- @version 6.0 - Migrated to ENFEEBLING_MAGIC_DATABASE (skill-based architecture)
--- @date Created: 2025-10-12 | Updated: 2025-10-30
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Centralized Midcast Manager (universal nested set selection)
local MidcastManager = require('shared/utils/midcast/midcast_manager')

-- ENFEEBLING_MAGIC_DATABASE for enfeebling type detection (PRIORITY 1 - NEW)
local EnfeeblingSPELLS_success, EnfeeblingSPELLS = pcall(require, 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE')

-- HEALING_MAGIC_DATABASE for subjob healing spells (Poisona, etc. from WHM subjob)
local HealingSPELLS_success, HealingSPELLS = pcall(require, 'shared/data/magic/HEALING_MAGIC_DATABASE')

-- ENHANCING_MAGIC_DATABASE for subjob enhancing spells (Erase, Regen III+, etc. from WHM subjob)
local EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

-- RDM Spell Database for spell messages (LEGACY - for Enhancing/Healing spells not yet migrated)
local RDMSpells_success, RDMSpells = pcall(require, 'shared/data/magic/RDM_SPELL_DATABASE')

-- Message Formatter for spell messages
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load Enfeebling Messages Config
local _, ENFEEBLING_MESSAGES_CONFIG = pcall(require, 'shared/config/ENFEEBLING_MESSAGES_CONFIG')
if not ENFEEBLING_MESSAGES_CONFIG then
    ENFEEBLING_MESSAGES_CONFIG = {
        display_mode = 'on',
        is_enabled = function() return true end,
        show_description = function() return false end
    }
end

-- Load Enhancing Messages Config
local _, ENHANCING_MESSAGES_CONFIG = pcall(require, 'shared/config/ENHANCING_MESSAGES_CONFIG')
if not ENHANCING_MESSAGES_CONFIG then
    ENHANCING_MESSAGES_CONFIG = {
        display_mode = 'on',
        is_enabled = function() return true end,
        show_description = function() return false end
    }
end

---============================================================================
--- MIDCAST HOOKS
---============================================================================

--- Handle midcast gear selection
--- Defers to Mote-Include default behavior, customization in job_post_midcast
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments for cancellation/customization
--- @return nil (no action taken, handled in post-midcast)
function job_midcast(spell, action, spellMap, eventArgs)
    -- Handled by Mote-Include default behavior
    -- Customization done in job_post_midcast
end

--- Post-midcast customization using MidcastManager
--- Routes spell.skill to MidcastManager with appropriate configuration
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments for cancellation/customization
--- @return nil (dispatches to MidcastManager)
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Check debug state from global
    local debug_enabled = _G.MidcastManagerDebugState == true

    -- DEBUG: Log entry (only when debug mode is ON)
    if debug_enabled then
        add_to_chat(8, '===================================================')
        add_to_chat(8, '[RDM_MIDCAST] job_post_midcast() called')
        add_to_chat(8, '  Spell: ' .. (spell.english or 'Unknown'))
        add_to_chat(8, '  Skill: ' .. (spell.skill or 'Unknown'))
        add_to_chat(8, '===================================================')
    end

    -- ==========================================================================
    -- ENFEEBLING MAGIC - Use MidcastManager with ENFEEBLING_MAGIC_DATABASE
    -- ==========================================================================
    if spell.skill == 'Enfeebling Magic' then
        if debug_enabled then
            add_to_chat(158, '[RDM_MIDCAST] -> Routing to MidcastManager (Enfeebling)')
            add_to_chat(158, '[RDM_MIDCAST]   * Spell: ' .. (spell.name or 'Unknown'))
            add_to_chat(158, '[RDM_MIDCAST]   * EnfeebleMode: ' .. tostring(state.EnfeebleMode and state.EnfeebleMode.value or 'nil'))
            add_to_chat(158, '[RDM_MIDCAST]   * Database: ' .. (EnfeeblingSPELLS_success and 'ENFEEBLING_MAGIC_DATABASE Loaded' or 'Not Loaded'))
        end

        -- DEBUG: Get enfeebling_type BEFORE MidcastManager call
        local enfeebling_type = nil
        if EnfeeblingSPELLS_success and EnfeeblingSPELLS then
            enfeebling_type = EnfeeblingSPELLS.get_enfeebling_type(spell.name)
            if debug_enabled then
                add_to_chat(206, '[RDM_MIDCAST] 🔍 Enfeebling Type Detection:')
                add_to_chat(206, '[RDM_MIDCAST]   * Spell: ' .. spell.name)
                add_to_chat(206, '[RDM_MIDCAST]   * enfeebling_type: ' .. tostring(enfeebling_type or 'nil'))
            end
        else
            if debug_enabled then
                add_to_chat(167, '[RDM_MIDCAST] ⚠️ Database not loaded - cannot detect enfeebling_type')
            end
        end

        -- DEBUG: Show expected nested set paths
        if debug_enabled and enfeebling_type then
            local mode_value = state.EnfeebleMode and state.EnfeebleMode.value or nil
            add_to_chat(206, '[RDM_MIDCAST] 📊 Expected Nested Set Priority:')
            if mode_value then
                add_to_chat(206, '[RDM_MIDCAST]   1. sets.midcast[\'Enfeebling Magic\'].' .. enfeebling_type .. '.' .. mode_value)
                add_to_chat(206, '[RDM_MIDCAST]   2. sets.midcast[\'Enfeebling Magic\'].' .. enfeebling_type)
                add_to_chat(206, '[RDM_MIDCAST]   3. sets.midcast[\'Enfeebling Magic\'].' .. mode_value)
            else
                add_to_chat(206, '[RDM_MIDCAST]   1. sets.midcast[\'Enfeebling Magic\'].' .. enfeebling_type)
            end
            add_to_chat(206, '[RDM_MIDCAST]   FALLBACK: sets.midcast[\'Enfeebling Magic\']')
        end

        -- Select set using MidcastManager
        -- Priority: .mnd_potency.Valeur > .mnd_potency > .Valeur > base
        local success = MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell,
            mode_state = state.EnfeebleMode,
            database_func = EnfeeblingSPELLS_success and EnfeeblingSPELLS and EnfeeblingSPELLS.get_enfeebling_type or nil
        })

        if debug_enabled then
            add_to_chat(success and 158 or 167, '[RDM_MIDCAST] <- MidcastManager returned: ' .. tostring(success))
            if not success then
                add_to_chat(167, '[RDM_MIDCAST] ⚠️ MidcastManager failed to select set - using Mote-Include default')
            end
        end

        -- SABOTEUR BONUS: Override hands with Lethargy Gants +3 when Saboteur active
        -- (+5 enfeebling potency, extends duration)
        if buffactive['Saboteur'] then
            if debug_enabled then
                add_to_chat(206, '[RDM_MIDCAST] ** SABOTEUR ACTIVE -> Overriding hands with Lethargy Gants +3')
            end
            equip({hands = 'Lethargy Gants +3'})
        end

        -- DISABLED: RDM Enfeebling Messages
        -- Messages now handled by universal spell_message_handler (init_spell_messages.lua)
        -- This prevents duplicate messages from job-specific + universal system
        --
        -- LEGACY CODE (commented out to prevent duplicates):
        -- if ENFEEBLING_MESSAGES_CONFIG.is_enabled() and RDMSpells_success and RDMSpells then
        --     local spell_data = RDMSpells.spells[spell.name]
        --     if spell_data and spell_data.category == 'Enfeebling' then
        --         MessageFormatter.show_spell_activated(spell.name, description)
        --     end
        -- end

        return
    end

    -- ==========================================================================
    -- ENHANCING MAGIC - Use MidcastManager with target detection
    -- ==========================================================================
    if spell.skill == 'Enhancing Magic' then
        if debug_enabled then
            add_to_chat(158, '[RDM_MIDCAST] -> Routing to MidcastManager (Enhancing)')
            add_to_chat(158, '[RDM_MIDCAST]   * EnhancingMode: ' .. tostring(state.EnhancingMode and state.EnhancingMode.value or 'nil'))
            add_to_chat(158, '[RDM_MIDCAST]   * Target: ' .. (spell.target and spell.target.name or 'Unknown'))
        end

        -- Select set using MidcastManager
        -- Priority: .self.Duration > .self > .Duration > base
        local success = MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            mode_state = state.EnhancingMode,
            target_func = MidcastManager.get_enhancing_target
        })

        if debug_enabled then
            add_to_chat(success and 158 or 167, '[RDM_MIDCAST] <- MidcastManager returned: ' .. tostring(success))
        end

        -- Display Enhancing Magic message (if enabled in config)
        if ENHANCING_MESSAGES_CONFIG.is_enabled() then
            local spell_data = nil

            -- Try RDM database first (RDM native enhancing spells)
            if RDMSpells_success and RDMSpells then
                spell_data = RDMSpells.spells[spell.name]
            end

            -- If not found, try ENHANCING_MAGIC_DATABASE (for subjob spells like Erase, Regen III-V)
            if not spell_data and EnhancingSPELLS_success and EnhancingSPELLS then
                spell_data = EnhancingSPELLS.spells[spell.name]
            end

            -- DISABLED: Messages handled by universal spell_message_handler
            -- if spell_data and (spell_data.category == 'Enhancing' or spell_data.category == 'Healing') then
            --     MessageFormatter.show_spell_activated(spell.name, description)
            -- end
        end

        return
    end

    -- ==========================================================================
    -- HEALING MAGIC - Use MidcastManager (Cure I-IV, Raise I-II for RDM)
    -- ==========================================================================
    if spell.skill == 'Healing Magic' then
        if debug_enabled then
            add_to_chat(158, '[RDM_MIDCAST] -> Routing to MidcastManager (Healing)')
            add_to_chat(158, '[RDM_MIDCAST]   * Spell: ' .. (spell.name or 'Unknown'))
            add_to_chat(158, '[RDM_MIDCAST]   * CureMode: ' .. tostring(state.CureMode and state.CureMode.value or 'nil'))
        end

        -- Select set using MidcastManager
        -- Priority: .CureMode > base
        local success = MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell,
            mode_state = state.CureMode
        })

        if debug_enabled then
            add_to_chat(success and 158 or 167, '[RDM_MIDCAST] <- MidcastManager returned: ' .. tostring(success))
        end

        -- Display Healing Magic message (if enabled in config)
        if ENHANCING_MESSAGES_CONFIG.is_enabled() then
            local spell_data = nil

            -- Try RDM database first (Cure I-IV, Raise I-II)
            if RDMSpells_success and RDMSpells then
                spell_data = RDMSpells.spells[spell.name]
            end

            -- If not found, try HEALING_MAGIC_DATABASE (for subjob spells like Poisona)
            if not spell_data and HealingSPELLS_success and HealingSPELLS then
                spell_data = HealingSPELLS.spells[spell.name]
            end

            -- DISABLED: Messages handled by universal spell_message_handler
            -- if spell_data and spell_data.category == 'Healing' then
            --     MessageFormatter.show_spell_activated(spell.name, description)
            -- end
        end

        return
    end

    -- ==========================================================================
    -- ELEMENTAL MAGIC - Use MidcastManager with NukeMode
    -- ==========================================================================
    if spell.skill == 'Elemental Magic' then
        if debug_enabled then
            add_to_chat(158, '[RDM_MIDCAST] -> Routing to MidcastManager (Elemental)')
            add_to_chat(158, '[RDM_MIDCAST]   * NukeMode: ' .. tostring(state.NukeMode and state.NukeMode.value or 'nil'))
        end

        -- Select set using MidcastManager
        -- Priority: .FreeNuke > base
        local success = MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell,
            mode_state = state.NukeMode
        })

        if debug_enabled then
            add_to_chat(success and 158 or 167, '[RDM_MIDCAST] <- MidcastManager returned: ' .. tostring(success))
        end

        return
    end

    if debug_enabled then
        add_to_chat(206, '[RDM_MIDCAST] !! Spell skill not handled by MidcastManager: ' .. (spell.skill or 'Unknown'))
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export to global scope
_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Export module
local RDM_MIDCAST = {}
RDM_MIDCAST.job_midcast = job_midcast
RDM_MIDCAST.job_post_midcast = job_post_midcast

return RDM_MIDCAST
