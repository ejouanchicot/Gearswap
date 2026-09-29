---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Midcast Module - Powered by MidcastManager
---  ═══════════════════════════════════════════════════════════════════════════
---   The master's magic is subjob magic (Utsusemi on /NIN, Cure on /WHM...):
---   MidcastManager on the spell's skill. A skill with no base set
---   (sets.midcast['Healing Magic']...) keeps Mote's pick (sets.midcast
---   [spell] / [map] / [skill] / [spell type], so sets.midcast.Utsusemi for
---   Utsusemi). Mote-Globals lays sets.midcast.FastRecast first.
---
---   The automaton's own actions go through PUP_PET_MIDCAST.lua.
---
---   job_get_spell_map gives every "<Element> Maneuver" the map Maneuver, so
---   Mote's precast finds sets.precast.JA.Maneuver.
---
---   @file    shared/jobs/pup/functions/PUP_MIDCAST.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')

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

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook: nothing PUP-specific before Mote's set.
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function job_midcast(spell, action, spellMap, eventArgs)
end

--- Post-midcast hook (MidcastManager routing)
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
end

--- Mote spell map: 'Maneuver' for every elemental maneuver (nil = Mote's own).
--- @param spell table Spell from GearSwap
--- @param default_spell_map string|nil Mote's own map
--- @return string|nil
function job_get_spell_map(spell, default_spell_map)
    local name = spell and spell.english
    if type(name) == 'string' and name:sub(-9) == ' Maneuver' then
        return 'Maneuver'
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast
_G.job_get_spell_map = job_get_spell_map

return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
    job_get_spell_map = job_get_spell_map,
}
