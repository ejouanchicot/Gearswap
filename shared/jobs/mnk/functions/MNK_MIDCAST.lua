---  ═══════════════════════════════════════════════════════════════════════════
---   MNK Midcast Module - Powered by MidcastManager
---  ═══════════════════════════════════════════════════════════════════════════
---   Monk casts no magic of its own: its spells are subjob magic (Utsusemi,
---   Monomi, Tonko on /NIN; Cure / Protect on a /WHM or /RDM sub).
---   MidcastManager on the spell's skill, with target_func / the enhancing
---   family for Enhancing Magic. A skill with no base set
---   (sets.midcast.Ninjutsu...) keeps Mote's pick (sets.midcast[spell] /
---   [map] / [skill] / [spell type], so sets.midcast.Utsusemi for Utsusemi).
---   Mote-Globals lays sets.midcast.FastRecast first.
---
---   @file    shared/jobs/mnk/functions/MNK_MIDCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')

local MidcastManager = nil
local EnhancingSPELLS = nil

--- Extra MidcastManager fields per skill: target and database routing.
--- @param skill string
--- @return table
local function skill_options(skill)
    if skill == 'Enhancing Magic' then
        return {target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil}
    end
    return {}
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook: nothing MNK-specific before Mote's set.
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
}
