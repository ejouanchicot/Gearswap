---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Midcast Module - Powered by MidcastManager
---  ═══════════════════════════════════════════════════════════════════════════
---   Every spell goes through MidcastManager.select_set on its skill, with:
---     Elemental Magic  mode MagicBurst under Magic Burst On
---                      (sets.midcast['Elemental Magic'].MagicBurst);
---                      a helix uses sets.midcast.Helix as its base when it
---                      exists, typed Dark (Noctohelix) / Light (Luminohelix):
---                      .Helix.Dark, .Helix.Light, .Helix.MagicBurst,
---                      .Helix.Dark.MagicBurst...
---     Dark Magic       Kaustra alone takes the MagicBurst mode
---                      (sets.midcast.Kaustra.MagicBurst)
---     Enhancing Magic  the enhancing database's family: Regen, Storm...
---                      (sets.midcast.Regen, sets.midcast.Storm)
---     Enfeebling Magic sets.midcast.MndEnfeebles (white) / .IntEnfeebles
---                      (black) when they exist, refined by the enfeebling
---                      database's type
---     anything else    its own skill (Cure / StatusRemoval through their
---                      Mote map, Cursna by name)
---   Then the grimoire layers (logic/grimoire.lua): Perpetuance, Rapture,
---   Ebullience, Immanence, Klimaform, Celerity / Alacrity.
---   Mote-Globals lays sets.midcast.FastRecast first; the shared
---   ElementalBelt picks Obi / Orpheus at cleanup.
---
---   @file    shared/jobs/sch/functions/SCH_MIDCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')
local Grimoire = require('shared/jobs/sch/functions/logic/grimoire')

local MidcastManager = nil
local EnhancingSPELLS = nil
local EnfeeblingSPELLS = nil

--- Helix type by spell family (the rest are plain helices).
local HELIX_TYPES = {Noctohelix = 'Dark', Luminohelix = 'Light'}

--- @return string|nil 'MagicBurst' under Magic Burst On
local function burst_mode()
    return (state.MagicBurstMode and state.MagicBurstMode.current == 'On') and 'MagicBurst' or nil
end

--- Helix type of a spell name ('Noctohelix II' -> 'Dark'), nil otherwise.
--- @param name string
--- @return string|nil
local function helix_type(name)
    return HELIX_TYPES[(name or ''):match('^(%a+)')]
end

--- @param name string
--- @return boolean True for any helix
local function is_helix(name)
    return (name or ''):find('^%a+helix') ~= nil
end

--- Enfeebling database, loaded once (false when it failed).
local function enfeebling_db()
    if EnfeeblingSPELLS == nil then
        local ok, db = pcall(require, 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
        EnfeeblingSPELLS = ok and db or false
    end
    return EnfeeblingSPELLS or nil
end

--- MidcastManager config of a spell (see header).
--- @param spell table
--- @return table
local function config_for(spell)
    local skill, name = spell.skill, spell.english
    if skill == 'Elemental Magic' then
        if is_helix(name) and sets.midcast.Helix then
            return {skill = 'Helix', mode_value = burst_mode(), database_func = helix_type}
        end
        return {skill = skill, mode_value = burst_mode()}
    elseif skill == 'Dark Magic' then
        return {skill = skill, mode_value = name == 'Kaustra' and burst_mode() or nil}
    elseif skill == 'Enhancing Magic' then
        return {skill = skill, target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil}
    elseif skill == 'Enfeebling Magic' then
        local set_name = spell.type == 'WhiteMagic' and 'MndEnfeebles' or 'IntEnfeebles'
        local db = enfeebling_db()
        return {skill = sets.midcast[set_name] and set_name or skill,
            database_func = db and db.get_enfeebling_type or nil}
    end
    return {skill = skill}
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook: nothing SCH-specific before Mote's set.
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function job_midcast(spell, action, spellMap, eventArgs)
end

--- Post-midcast hook: MidcastManager routing, then the grimoire layers.
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
    local config = config_for(spell)
    config.spell = spell
    MidcastManager.select_set(config)
    Grimoire.equip_layers(Grimoire.midcast_layers(spell))
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
    helix_type = helix_type,
}
