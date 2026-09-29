---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Midcast Module - Powered by MidcastManager
---  ═══════════════════════════════════════════════════════════════════════════
---   The Dragoon's magic is subjob magic (Blue Magic on /BLU, Cure on
---   /WHM, Utsusemi on /NIN...): MidcastManager on the spell's skill. A skill
---   with no base set (sets.midcast['Healing Magic']...) keeps Mote's pick
---   (sets.midcast[spell] / [map] / [skill] / [spell type]). Mote-Globals
---   lays sets.midcast.FastRecast first.
---
---   Then the Healing Breath trigger: while the wyvern is out and the HP is
---   under the subjob's line (logic/wyvern.lua),
---   sets.midcast.HealingBreathTrigger goes on top, so the HP checked at the
---   end of the cast meets the wyvern's "artifact head" line.
---
---   The wyvern's own breaths go through DRG_PET_MIDCAST.lua.
---
---   @file    shared/jobs/drg/functions/DRG_MIDCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')
local Wyvern = require('shared/jobs/drg/functions/logic/wyvern')

local MidcastManager = nil
local EnhancingSPELLS = nil
local EnfeeblingSPELLS = nil

--- Extra MidcastManager fields per skill: target and database routing.
--- @param skill string
--- @return table
local function skill_options(skill)
    if skill == 'Enhancing Magic' then
        return {target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil}
    end
    if skill == 'Enfeebling Magic' then
        if EnfeeblingSPELLS == nil then
            local ok, db = pcall(require, 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
            EnfeeblingSPELLS = ok and db or false
        end
        return {database_func = EnfeeblingSPELLS and EnfeeblingSPELLS.get_enfeebling_type or nil}
    end
    return {}
end

--- sets.midcast.HealingBreathTrigger on top when the spell will make the
--- wyvern cure.
--- @param spell table
local function lay_breath_trigger(spell)
    local trigger = sets.midcast and sets.midcast.HealingBreathTrigger
    if trigger and Wyvern.spell_triggers_breath(spell) then
        equip(trigger)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook: nothing DRG-specific before Mote's set.
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function job_midcast(spell, action, spellMap, eventArgs)
end

--- Post-midcast hook (MidcastManager routing, then the breath trigger)
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function job_post_midcast(spell, action, spellMap, eventArgs)
    MidcastManager, EnhancingSPELLS = MidcastDeps.load()
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end
    if not MidcastManager or spell.action_type ~= 'Magic' or not spell.skill then
        return
    end
    local config = skill_options(spell.skill)
    config.skill = spell.skill
    config.spell = spell
    MidcastManager.select_set(config)
    lay_breath_trigger(spell)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
}
