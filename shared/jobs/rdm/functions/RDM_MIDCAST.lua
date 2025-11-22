---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Midcast Module - Intelligent Midcast Gear Selection (Powered by MidcastManager)
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast gear selection for Red Mage spells using centralized MidcastManager.
---   Only intercepts skills that require job-specific logic. All other magic is handled
---   by Mote-Include's natural pattern matching.
---
---   Intercepted Skills (Job-Specific Logic):
---     - Enfeebling: Nested sets (mnd_potency.Valeur), Saboteur override, Database type detection
---     - Enhancing: Spell family routing (Enspell/Gain/BarElement/etc.), Target detection (self vs others)
---     - Healing: Spell-specific sets (Cure/Curaga/Raise) with fallback to base Healing Magic set
---     - Elemental: NukeMode-based selection (FreeNuke vs base)
---     - Dark: Spell-specific sets (Drain/Aspir/Stun) with fallback to base Dark Magic set
---     - Universal: ALL other magic types (Blue Magic, Summoning, Geomancy, Ninjutsu, Songs, Divine, etc.)
---
---   Enhancing Magic Spell Families (NEW - v6.2):
---     Sets can now be created for spell families using database-driven routing:
---     - sets.midcast['Enhancing Magic'].Enspell (Enfire, Enblizzard, etc.)
---     - sets.midcast['Enhancing Magic'].Gain (Gain-STR, Gain-INT, etc.)
---     - sets.midcast['Enhancing Magic'].BarElement (Barfire, Barblizzard, etc.)
---     - sets.midcast['Enhancing Magic'].BarAilment (Barparalyze, Barblind, etc.)
---     - sets.midcast['Enhancing Magic'].Phalanx, .Stoneskin, .Aquaveil, .Refresh, .Regen, etc.
---
---   @file    shared/jobs/rdm/functions/RDM_MIDCAST.lua
---   @author  Tetsouo
---   @version 6.5 - Refactored header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = nil
local MidcastManager = nil
local EnfeeblingSPELLS = nil
local EnhancingSPELLS = nil
local MessageRDMMidcast = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

MessageFormatter = require('shared/utils/messages/message_formatter')
    MidcastManager = require('shared/utils/midcast/midcast_manager')
    MessageRDMMidcast = require('shared/utils/messages/formatters/jobs/message_rdm_midcast')

    local EnfeeblingSPELLS_success, EnhancingSPELLS_success
    EnfeeblingSPELLS_success, EnfeeblingSPELLS = pcall(require, 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

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
    -- Lazy load modules on first midcast
    ensure_modules_loaded()

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

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   ENFEEBLING MAGIC - Use MidcastManager with ENFEEBLING_MAGIC_DATABASE
    ---  ─────────────────────────────────────────────────────────────────────────
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

        -- SABOTEUR BONUS: Equip Saboteur set when active
        -- (+5 enfeebling potency from Lethargy Gants +3, extends duration)
        if buffactive['Saboteur'] and sets.midcast['Enfeebling Magic'].Saboteur then
            if debug_enabled then
                MessageRDMMidcast.show_saboteur_override()
            end
            equip(sets.midcast['Enfeebling Magic'].Saboteur)
        end

        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   ENHANCING MAGIC - Use MidcastManager with spell_family + target detection
    ---  ─────────────────────────────────────────────────────────────────────────
    if spell.skill == 'Enhancing Magic' then
        if debug_enabled then
            MessageRDMMidcast.show_enhancing_routing(
                tostring(state.EnhancingMode and state.EnhancingMode.value or 'nil'),
                spell.target and spell.target.name or 'Unknown'
            )
        end

        -- EXCEPTION: Phalanx + Accession (SCH subjob)
        -- When Accession is active, Phalanx becomes AoE party buff
        -- Use base Enhancing Magic set (ignore Composure/spell_family logic)
        if buffactive and buffactive['Accession'] and spell.english and spell.english:match("^Phalanx") then
            equip(sets.midcast['Enhancing Magic'])
            if debug_enabled then
                MessageFormatter.show_debug('RDM Midcast', 'Phalanx + Accession detected → Base Enhancing set")
            end
            return
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

        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   HEALING MAGIC - Use MidcastManager
    ---  ─────────────────────────────────────────────────────────────────────────
    if spell.skill == 'Healing Magic' then
        if debug_enabled then
            MessageFormatter.show_debug('RDM Midcast', 'Healing Magic detected: ' .. (spell.name or 'Unknown'))
        end

        -- Select set using MidcastManager
        -- Priority: sets.midcast[spell.name] (Cure/Curaga/Raise) > sets.midcast['Healing Magic'] (base)
        local success = MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell
        })

        if debug_enabled then
            MessageFormatter.show_debug('RDM Midcast', 'Healing Magic result: ' .. tostring(success))
        end

        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   ELEMENTAL MAGIC - Use MidcastManager with NukeMode
    ---  ─────────────────────────────────────────────────────────────────────────
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

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   DARK MAGIC - Use MidcastManager
    ---  ─────────────────────────────────────────────────────────────────────────
    if spell.skill == 'Dark Magic' then
        if debug_enabled then
            MessageFormatter.show_debug('RDM Midcast', 'Dark Magic detected: ' .. (spell.name or 'Unknown'))
        end

        -- Select set using MidcastManager
        -- Priority: sets.midcast[spell.name] (Drain/Aspir/Stun) > sets.midcast['Dark Magic'] (base)
        local success = MidcastManager.select_set({
            skill = 'Dark Magic',
            spell = spell
        })

        if debug_enabled then
            MessageFormatter.show_debug('RDM Midcast', 'Dark Magic result: ' .. tostring(success))
        end

        return
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   UNIVERSAL MAGIC FALLBACK - All other magic types (subjob magic)
    ---  ─────────────────────────────────────────────────────────────────────────
    -- Handles magic from subjobs that RDM doesn't have as main:
    --   - Blue Magic (sub BLU)
    --   - Summoning Magic (sub SMN)
    --   - Geomancy (sub GEO)
    --   - Ninjutsu (sub NIN)
    --   - Songs (sub BRD)
    --   - Divine Magic (sub WHM extended)
    --   - Any other magic type
    if spell.type == 'Magic' and spell.skill then
        if debug_enabled then
            MessageFormatter.show_debug('RDM Midcast', 'Universal Magic detected: ' .. (spell.skill or 'Unknown') .. ' - ' .. (spell.name or 'Unknown'))
        end

        -- Select set using MidcastManager
        -- Priority: sets.midcast[spell.name] > sets.midcast[spell.skill] (base)
        local success = MidcastManager.select_set({
            skill = spell.skill,
            spell = spell
        })

        if debug_enabled then
            MessageFormatter.show_debug('RDM Midcast', 'Universal Magic result: ' .. tostring(success))
        end

        return
    end

    if debug_enabled then
        MessageRDMMidcast.show_skill_not_handled(spell.skill or 'Unknown')
    end
end

-- Export to global scope (used by Mote-Include via include())
_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast
