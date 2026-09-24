---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Midcast gear selection for Red Mage through MidcastManager, after Mote
---   has equipped its default midcast set. One handler per skill:
---     - Enfeebling: type from the enfeebling database + EnfeebleMode, then the
---       Saboteur set while Saboteur is up
---     - Enhancing: spell family from the enhancing database + target (self /
---       others under Composure); Phalanx under Accession uses the base set
---     - Healing / Dark: spell name, then the skill's base set
---     - Elemental: NukeMode
---   Other skills keep Mote's default set (see midcast_subjob below).
---
---   Enhancing Magic spell families (database-driven routing):
---     - sets.midcast['Enhancing Magic'].Enspell (Enfire, Enblizzard, etc.)
---     - sets.midcast['Enhancing Magic'].Gain (Gain-STR, Gain-INT, etc.)
---     - sets.midcast['Enhancing Magic'].BarElement (Barfire, Barblizzard, etc.)
---     - sets.midcast['Enhancing Magic'].BarAilment (Barparalyze, Barblind, etc.)
---     - sets.midcast['Enhancing Magic'].Phalanx, .Stoneskin, .Aquaveil, .Refresh, .Regen, etc.
---
---   @file    shared/jobs/rdm/functions/RDM_MIDCAST.lua
---   @author  Tetsouo
---   @version 1.0
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

    local mf_ok, mf = pcall(require, 'shared/utils/messages/message_formatter')
    if not mf_ok then mf = nil end
    MessageFormatter = mf
    local mm_ok, mm = pcall(require, 'shared/utils/midcast/midcast_manager')
    if not mm_ok then mm = nil end
    MidcastManager = mm
    local mrm_ok, mrm = pcall(require, 'shared/utils/messages/formatters/jobs/message_rdm_midcast')
    if not mrm_ok then mrm = nil end
    MessageRDMMidcast = mrm

    -- The file-scope database locals are the only record that a load worked.
    -- A separate success flag cannot be: declared here it would be local to
    -- this function, while every reader of it lives outside - which is exactly
    -- how the flags used to read nil and switch the routing off for good.
    local enfeebling_ok, enfeebling_db = pcall(require, 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
    EnfeeblingSPELLS = enfeebling_ok and enfeebling_db or nil

    local enhancing_ok, enhancing_db = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')
    EnhancingSPELLS = enhancing_ok and enhancing_db or nil

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle midcast gear selection
---   Defers to Mote-Include default behavior, customization in job_post_midcast
---   @param spell table Spell information from GearSwap
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
end

---  ─────────────────────────────────────────────────────────────────────────
---   PER-SKILL HANDLERS
---  ─────────────────────────────────────────────────────────────────────────
---   One function per magic skill, each returning true once it has equipped.

--- @param spell table Spell information from GearSwap
--- @param debug_enabled boolean Whether //gs c debugmidcast is on
--- @return boolean True when this handler equipped a set
local function midcast_enfeebling(spell, debug_enabled)
    if debug_enabled then
        MessageRDMMidcast.show_enfeebling_routing(
            spell.name or 'Unknown',
            tostring(state.EnfeebleMode and state.EnfeebleMode.value or 'nil'),
            EnfeeblingSPELLS ~= nil
        )
    end

    -- Only the debug trace reads this lookup: MidcastManager resolves the
    -- type again itself through database_func.
    local enfeebling_type = nil
    if EnfeeblingSPELLS then
        enfeebling_type = EnfeeblingSPELLS.get_enfeebling_type(spell.name)
        if debug_enabled then
            MessageRDMMidcast.show_enfeebling_type_detection(spell.name, enfeebling_type)
        end
    else
        if debug_enabled then
            MessageRDMMidcast.show_enfeebling_database_not_loaded()
        end
    end

    if debug_enabled and enfeebling_type then
        local mode_value = state.EnfeebleMode and state.EnfeebleMode.value or nil
        if mode_value then
            MessageRDMMidcast.show_enfeebling_priority_with_mode(enfeebling_type, mode_value)
        else
            MessageRDMMidcast.show_enfeebling_priority_no_mode(enfeebling_type)
        end
    end

    -- Fallback order: see MidcastManager (docs/dev/systems/midcast-and-buffs.md)
    local success = MidcastManager.select_set({
        skill = 'Enfeebling Magic',
        spell = spell,
        mode_state = state.EnfeebleMode,
        database_func = EnfeeblingSPELLS and EnfeeblingSPELLS.get_enfeebling_type or nil
    })

    if debug_enabled then
        MessageRDMMidcast.show_enfeebling_result(success)
    end

    -- Saboteur up: the Saboteur set goes on top of the enfeebling set
    if buffactive['Saboteur'] and sets.midcast['Enfeebling Magic'].Saboteur then
        if debug_enabled then
            MessageRDMMidcast.show_saboteur_override()
        end
        equip(sets.midcast['Enfeebling Magic'].Saboteur)
    end

    return true
end

--- The set paths //gs c debugmidcast says it will try, in order (debug only:
--- nothing here decides the gear).
--- @param spell table Spell from GearSwap
--- @param spell_family string|nil Family resolved from the database, if any
local function trace_enhancing_priority(spell, spell_family)
    if not spell_family then
        return
    end

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

--- Which family the spell belongs to - Enspell, Regen, Refresh and so on.
--- @param spell table Spell from GearSwap
--- @param debug_enabled boolean Whether //gs c debugmidcast is on
--- @return string|nil Family, nil when the database is not loaded
local function enhancing_family(spell, debug_enabled)
    if not EnhancingSPELLS then
        if debug_enabled then
            MessageRDMMidcast.show_enhancing_database_not_loaded()
        end
        return nil
    end

    local family = EnhancingSPELLS.get_spell_family(spell.name)
    if debug_enabled then
        MessageRDMMidcast.show_spell_family_detection(spell.name, family)
    end
    return family
end

--- @param spell table Spell information from GearSwap
--- @param debug_enabled boolean Whether //gs c debugmidcast is on
--- @return boolean True when this handler equipped a set
local function midcast_enhancing(spell, debug_enabled)
    -- Printed before the Phalanx exception, as it always was: the trace is a
    -- record of what was asked for, not of what was decided.
    if debug_enabled then
        MessageRDMMidcast.show_enhancing_routing(
            tostring(state.EnhancingMode and state.EnhancingMode.value or 'nil'),
            spell.target and spell.target.name or 'Unknown'
        )
    end

    -- Accession turns Phalanx into a party buff, and the AoE version wants the
    -- plain Enhancing set - not the Composure or family gear that would win
    -- for a single-target cast.
    if buffactive and buffactive['Accession'] and spell.english
       and spell.english:match("^Phalanx") then
        equip(sets.midcast['Enhancing Magic'])
        if debug_enabled then
            MessageFormatter.show_debug('RDM Midcast', 'Phalanx + Accession detected → Base Enhancing set')
        end
        return true
    end

    local spell_family = enhancing_family(spell, debug_enabled)

    if debug_enabled then
        trace_enhancing_priority(spell, spell_family)
    end

    -- With a family: .Enspell.self.Duration > .Enspell.self > .Enspell.Duration
    -- > .Enspell > .self.Duration > .self > .Duration > base.
    -- state.EnhancingMode is not defined for RDM, so the mode levels never apply.
    local success = MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        mode_state = state.EnhancingMode,
        target_func = MidcastManager.get_enhancing_target,
        database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
    })

    if debug_enabled then
        MessageRDMMidcast.show_enhancing_result(success)
    end

    return true
end

--- @param spell table Spell information from GearSwap
--- @param debug_enabled boolean Whether //gs c debugmidcast is on
--- @return boolean True when this handler equipped a set
local function midcast_healing(spell, debug_enabled)
    if debug_enabled then
        MessageFormatter.show_debug('RDM Midcast', 'Healing Magic detected: ' .. (spell.name or 'Unknown'))
    end

    -- Priority: sets.midcast[spell.name] (Cure/Curaga/Raise) > sets.midcast['Healing Magic'] (base)
    local success = MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell
    })

    if debug_enabled then
        MessageFormatter.show_debug('RDM Midcast', 'Healing Magic result: ' .. tostring(success))
    end

    return true
end

--- @param spell table Spell information from GearSwap
--- @param debug_enabled boolean Whether //gs c debugmidcast is on
--- @return boolean True when this handler equipped a set
local function midcast_elemental(spell, debug_enabled)
    if debug_enabled then
        MessageRDMMidcast.show_elemental_routing(tostring(state.NukeMode and state.NukeMode.value or 'nil'))
    end

    -- Priority: sets.midcast['Elemental Magic'][NukeMode] > base
    local success = MidcastManager.select_set({
        skill = 'Elemental Magic',
        spell = spell,
        mode_state = state.NukeMode
    })

    if debug_enabled then
        MessageRDMMidcast.show_elemental_result(success)
    end

    return true
end

--- @param spell table Spell information from GearSwap
--- @param debug_enabled boolean Whether //gs c debugmidcast is on
--- @return boolean True when this handler equipped a set
local function midcast_dark(spell, debug_enabled)
    if debug_enabled then
        MessageFormatter.show_debug('RDM Midcast', 'Dark Magic detected: ' .. (spell.name or 'Unknown'))
    end

    -- Priority: sets.midcast[spell.name] (Drain/Aspir/Stun) > sets.midcast['Dark Magic'] (base)
    local success = MidcastManager.select_set({
        skill = 'Dark Magic',
        spell = spell
    })

    if debug_enabled then
        MessageFormatter.show_debug('RDM Midcast', 'Dark Magic result: ' .. tostring(success))
    end

    return true
end

--- @param spell table Spell information from GearSwap
--- @param debug_enabled boolean Whether //gs c debugmidcast is on
--- @return boolean True when this handler equipped a set
local function midcast_subjob(spell, debug_enabled)
    if debug_enabled then
        MessageFormatter.show_debug('RDM Midcast', 'Universal Magic detected: ' .. (spell.skill or 'Unknown') .. ' - ' .. (spell.name or 'Unknown'))
    end

    -- Priority: sets.midcast[spell.name] > sets.midcast[spell.skill] (base)
    local success = MidcastManager.select_set({
        skill = spell.skill,
        spell = spell
    })

    if debug_enabled then
        MessageFormatter.show_debug('RDM Midcast', 'Universal Magic result: ' .. tostring(success))
    end

    return true
end

--- Skill name to handler. Subjob magic is not in here: it is the fallback,
--- and it matches on spell.type rather than on a known skill name.
local SKILL_HANDLERS = {
    ['Enfeebling Magic'] = midcast_enfeebling,
    ['Enhancing Magic'] = midcast_enhancing,
    ['Healing Magic'] = midcast_healing,
    ['Elemental Magic'] = midcast_elemental,
    ['Dark Magic'] = midcast_dark,
}

---   Post-midcast customization using MidcastManager
---   @param spell table Spell information from GearSwap
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end
    local debug_enabled = _G.MidcastManagerDebugState == true
    if debug_enabled then
        MessageRDMMidcast.show_function_entry(spell.english or 'Unknown', spell.skill or 'Unknown')
    end

    local handler = SKILL_HANDLERS[spell.skill]
    if handler and handler(spell, debug_enabled) then
        return
    end

    -- Magic RDM only gets from a subjob: BLU, SMN, GEO, NIN, BRD, WHM.
    -- Never reached today: spell.type is 'WhiteMagic', 'BlackMagic', 'Ninjutsu'...
    -- never 'Magic' (that is spell.action_type).
    if spell.type == 'Magic' and spell.skill and midcast_subjob(spell, debug_enabled) then
        return
    end

    if debug_enabled then
        MessageRDMMidcast.show_skill_not_handled(spell.skill or 'Unknown')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export to global scope (used by Mote-Include via include())
_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Module export (used by require() callers)
local RDM_MIDCAST = {}
RDM_MIDCAST.job_midcast       = job_midcast
RDM_MIDCAST.job_post_midcast  = job_post_midcast

return RDM_MIDCAST
