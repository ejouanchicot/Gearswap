---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Midcast Module - Powered by MidcastManager
---  ═══════════════════════════════════════════════════════════════════════════
---   • Ranged attack (matched on action_type: GearSwap gives /ra the type
---     'Misc' and no skill): sets.midcast.RA[RangedMode] (Acc), else
---     sets.midcast.RA, through MidcastManager (skill 'RA'); then the buff
---     layers of logic/ranged.lua (Velocity Shot, Hover Shot, Decoy Shot,
---     Unlimited Shot, Double Shot, Barrage) on top.
---   • Magic: every spell RNG casts comes from its subjob (Utsusemi on /NIN,
---     Cure on /WHM...): MidcastManager on the spell's own skill; Enhancing
---     also with its target (self / others) and spell family. A skill with no
---     base set (sets.midcast.Ninjutsu...) keeps Mote's pick
---     (sets.midcast[spell] / [map] / [skill], so sets.midcast.Utsusemi for
---     Utsusemi). Mote-Globals lays sets.midcast.FastRecast first.
---   Utsusemi: Ichi cancelling Copy Image is shared
---   (utsusemi_shadows.lua, from the universal spell hook).
---
---   @file    shared/jobs/rng/functions/RNG_MIDCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')
local Ranged = require('shared/jobs/rng/functions/logic/ranged')

local MidcastManager = nil
local EnhancingSPELLS = nil

--- Ranged attack: the RA set for Ranged Mode, then the buff layers.
--- @param spell table
local function ranged_midcast(spell)
    MidcastManager.select_set({skill = 'RA', spell = spell, mode_state = state.RangedMode})
    Ranged.equip_layers(Ranged.MIDCAST_LAYERS, 'MIDCAST')
end

--- Subjob magic: the spell's skill, Enhancing with target and family.
--- @param spell table
local function magic_midcast(spell)
    local config = {skill = spell.skill, spell = spell}
    if spell.skill == 'Enhancing Magic' then
        config.target_func = MidcastManager.get_enhancing_target
        config.database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
    end
    MidcastManager.select_set(config)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook: nothing RNG-specific before Mote's set.
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
    if not MidcastManager then
        return
    end
    if spell.action_type == 'Ranged Attack' then
        ranged_midcast(spell)
    elseif spell.action_type == 'Magic' and spell.skill then
        magic_midcast(spell)
    end
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
