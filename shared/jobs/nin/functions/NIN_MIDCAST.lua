---  ═══════════════════════════════════════════════════════════════════════════
---   NIN Midcast Module - Powered by MidcastManager
---  ═══════════════════════════════════════════════════════════════════════════
---   Every spell goes through MidcastManager on its own skill:
---   • Ninjutsu: the spell's family (logic/ninjutsu.lua) as the type, and
---     mode MagicBurst for elemental ninjutsu under MagicBurstMode On:
---       sets.midcast.Utsusemi, sets.midcast.Migawari,
---       sets.midcast.Ninjutsu.Elemental (.MagicBurst), .Enfeebling,
---       .Enhancing, sets.midcast.Ninjutsu last. Then sets.buff.Futae on
---       top of an elemental ninjutsu while Futae is up.
---   • Any other skill (a subjob's magic): its own chain; a skill with no
---     base set keeps Mote's pick.
---   Mote-Globals lays sets.midcast.FastRecast first. Obi / Orpheus on
---   elemental ninjutsu is the shared ElementalBelt, after this. Utsusemi:
---   Ichi's shadow cancel is shared too (init_spell_messages.lua ->
---   utsusemi_shadows.lua), nothing here.
---
---   @file    shared/jobs/nin/functions/NIN_MIDCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')

local MidcastManager = nil
local EnhancingSPELLS = nil
local Ninjutsu = nil

--- MidcastManager config for a spell of any skill but Ninjutsu.
--- @param spell table
--- @return table
local function other_skill_config(spell)
    local config = {skill = spell.skill, spell = spell}
    if spell.skill == 'Enhancing Magic' then
        config.target_func = MidcastManager.get_enhancing_target
        config.database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
    end
    return config
end

--- Ninjutsu: MidcastManager on the family, then the Futae layer.
--- @param spell table
local function ninjutsu_midcast(spell)
    Ninjutsu = Ninjutsu or require('shared/jobs/nin/functions/logic/ninjutsu')
    local config, family = Ninjutsu.midcast_config(spell)
    MidcastManager.select_set(config)
    local futae = Ninjutsu.futae_layer(family)
    if futae then
        equip(futae)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook: nothing NIN-specific before Mote's set.
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
    if spell.skill == 'Ninjutsu' then
        ninjutsu_midcast(spell)
        return
    end
    MidcastManager.select_set(other_skill_config(spell))
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
