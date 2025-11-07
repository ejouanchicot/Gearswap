---============================================================================
--- RDM Midcast Module - Intelligent Midcast Gear Selection (Powered by MidcastManager)
---============================================================================
--- Handles midcast gear selection for Red Mage spells using centralized MidcastManager.
--- Only intercepts skills that require job-specific logic. All other magic is handled
--- by Mote-Include's natural pattern matching.
---
--- Intercepted Skills (Job-Specific Logic):
---   - Enfeebling: Nested sets (mnd_potency.Valeur), Saboteur override, Database type detection
---   - Enhancing: Spell family routing (Enspell/Gain/BarElement/etc.), Target detection (self vs others)
---   - Elemental: NukeMode-based selection (FreeNuke vs base)
---
--- Enhancing Magic Spell Families (NEW - v6.2):
---   Sets can now be created for spell families using database-driven routing:
---   - sets.midcast['Enhancing Magic'].Enspell (Enfire, Enblizzard, etc.)
---   - sets.midcast['Enhancing Magic'].Gain (Gain-STR, Gain-INT, etc.)
---   - sets.midcast['Enhancing Magic'].BarElement (Barfire, Barblizzard, etc.)
---   - sets.midcast['Enhancing Magic'].BarAilment (Barparalyze, Barblind, etc.)
---   - sets.midcast['Enhancing Magic'].Phalanx, .Stoneskin, .Aquaveil, .Refresh, .Regen, etc.
---
--- Mote-Include Handles Naturally:
---   - Healing Magic: Cure/Curaga/Raise → sets.midcast.Cure / sets.midcast.Raise
---
--- @file RDM_MIDCAST.lua
--- @author Tetsouo
--- @version 6.2 - Added spell_family support for Enhancing Magic
--- @date Created: 2025-10-12 | Updated: 2025-11-05
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Centralized Midcast Manager (universal nested set selection)
local MidcastManager = require('shared/utils/midcast/midcast_manager')

-- ENFEEBLING_MAGIC_DATABASE for enfeebling type detection (PRIORITY 1 - NEW)
local EnfeeblingSPELLS_success, EnfeeblingSPELLS = pcall(require, 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE')

-- ENHANCING_MAGIC_DATABASE for subjob enhancing spells (Erase, Regen III+, etc. from WHM subjob)
local EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

-- RDM Spell Database for spell messages (LEGACY - for Enhancing/Healing spells not yet migrated)
local RDMSpells_success, RDMSpells = pcall(require, 'shared/data/magic/RDM_SPELL_DATABASE')

-- Message Formatter for spell messages
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- RDM Midcast Debug Messages
local MessageRDMMidcast = require('shared/utils/messages/formatters/jobs/message_rdm_midcast')

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
        MessageRDMMidcast.show_function_entry(spell.english or 'Unknown', spell.skill or 'Unknown')
    end

    -- ==========================================================================
    -- ENFEEBLING MAGIC - Use MidcastManager with ENFEEBLING_MAGIC_DATABASE
    -- ==========================================================================
    if spell.skill == 'Enfeebling Magic' then
        if debug_enabled then
            MessageRDMMidcast.show_enfeebling_routing(
                spell.name or 'Unknown',
                tostring(state.EnfeebleMode and state.EnfeebleMode.value or 'nil'),
                EnfeeblingSPELLS_success
            )
        end

        -- DEBUG: Get enfeebling_type BEFORE MidcastManager call
        local enfeebling_type = nil
        if EnfeeblingSPELLS_success and EnfeeblingSPELLS then
            enfeebling_type = EnfeeblingSPELLS.get_enfeebling_type(spell.name)
            if debug_enabled then
                MessageRDMMidcast.show_enfeebling_type_detection(spell.name, enfeebling_type)
            end
        else
            if debug_enabled then
                MessageRDMMidcast.show_enfeebling_database_not_loaded()
            end
        end

        -- DEBUG: Show expected nested set paths
        if debug_enabled and enfeebling_type then
            local mode_value = state.EnfeebleMode and state.EnfeebleMode.value or nil
            if mode_value then
                MessageRDMMidcast.show_enfeebling_priority_with_mode(enfeebling_type, mode_value)
            else
                MessageRDMMidcast.show_enfeebling_priority_no_mode(enfeebling_type)
            end
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
            MessageRDMMidcast.show_enfeebling_result(success)
        end

        -- SABOTEUR BONUS: Override hands with Lethargy Gants +3 when Saboteur active
        -- (+5 enfeebling potency, extends duration)
        if buffactive['Saboteur'] then
            if debug_enabled then
                MessageRDMMidcast.show_saboteur_override()
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
    -- ENHANCING MAGIC - Use MidcastManager with spell_family + target detection
    -- ==========================================================================
    if spell.skill == 'Enhancing Magic' then
        if debug_enabled then
            MessageRDMMidcast.show_enhancing_routing(
                tostring(state.EnhancingMode and state.EnhancingMode.value or 'nil'),
                spell.target and spell.target.name or 'Unknown'
            )
        end

        -- DEBUG: Get spell_family BEFORE MidcastManager call
        local spell_family = nil
        if EnhancingSPELLS_success and EnhancingSPELLS then
            spell_family = EnhancingSPELLS.get_spell_family(spell.name)
            if debug_enabled then
                MessageRDMMidcast.show_spell_family_detection(spell.name, spell_family)
            end
        else
            if debug_enabled then
                MessageRDMMidcast.show_enhancing_database_not_loaded()
            end
        end

        -- DEBUG: Show expected nested set paths
        if debug_enabled and spell_family then
            local mode_value = state.EnhancingMode and state.EnhancingMode.value or nil
            local target_value = MidcastManager.get_enhancing_target(spell)
            if mode_value and target_value then
                MessageRDMMidcast.show_enhancing_priority_full(spell_family, target_value, mode_value)
            elseif target_value then
                MessageRDMMidcast.show_enhancing_priority_target_only(spell_family, target_value)
            else
                MessageRDMMidcast.show_enhancing_priority_family_only(spell_family)
            end
        end

        -- Select set using MidcastManager
        -- Priority with spell_family: .Enspell.self.Duration > .Enspell.self > .Enspell.Duration > .Enspell > .self.Duration > .self > .Duration > base
        local success = MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            mode_state = state.EnhancingMode,
            target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })

        if debug_enabled then
            MessageRDMMidcast.show_enhancing_result(success)
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
    -- HEALING MAGIC - Let Mote-Include handle naturally
    -- ==========================================================================
    -- Mote automatically handles:
    --   - Cure/Curaga → sets.midcast.Cure / sets.midcast.Curaga
    --   - Raise → sets.midcast.Raise
    --   - Specific spells → sets.midcast[spell.english]
    --
    -- No need to intercept - Mote's logic is sufficient for RDM!

    -- ==========================================================================
    -- ELEMENTAL MAGIC - Use MidcastManager with NukeMode
    -- ==========================================================================
    if spell.skill == 'Elemental Magic' then
        if debug_enabled then
            MessageRDMMidcast.show_elemental_routing(tostring(state.NukeMode and state.NukeMode.value or 'nil'))
        end

        -- Select set using MidcastManager
        -- Priority: .FreeNuke > base
        local success = MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell,
            mode_state = state.NukeMode
        })

        if debug_enabled then
            MessageRDMMidcast.show_elemental_result(success)
        end

        return
    end

    if debug_enabled then
        MessageRDMMidcast.show_skill_not_handled(spell.skill or 'Unknown')
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
