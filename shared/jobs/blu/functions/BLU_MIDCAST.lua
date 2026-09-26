---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Midcast Module - Powered by MidcastManager
---  ═══════════════════════════════════════════════════════════════════════════
---   Blue Magic: MidcastManager with the spell's category as its type
---   (logic/spell_map.lua, config/blu/BLU_SPELL_MAP.lua) and CastingMode as
---   its mode. For Gab's sets that resolves as Mote did:
---     sets.midcast[spell]                    Sound Blast, Restoral, White Wind
---     sets.midcast['Blue Magic'][cat][mode]  Magical.Resistant
---     sets.midcast['Blue Magic'][cat]        Physical, PhysicalDex, Breath...
---     sets.midcast['Blue Magic']             spell in no category
---   Then, on top: sets.buff[<buff>] for each of Burst Affinity, Chain
---   Affinity, Convergence, Diffusion, Efflux that is up, and
---   sets.self_healing for a Healing-category spell on oneself.
---   Keep category names off the root of sets.midcast: MidcastManager tries
---   sets.midcast[<category>] before sets.midcast['Blue Magic'][<category>].
---
---   Other skills (subjob magic): MidcastManager on the skill; a skill with
---   no base set (sets.midcast['Healing Magic']...) keeps Mote's pick
---   (sets.midcast[spell] / [skill] / [spell type], CastingMode).
---
---   job_get_spell_map gives Mote the same category, so Mote's own
---   precast / midcast picks (sets.precast.FC['Blue Magic']...) agree.
---
---   @file    shared/jobs/blu/functions/BLU_MIDCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')
local BLUSpellMap = require('shared/jobs/blu/functions/logic/spell_map')

local MidcastManager = nil
local EnhancingSPELLS = nil
local EnfeeblingSPELLS = nil

-- Order they go on in when several are up (later wins a shared slot)
local BLUE_MAGIC_BUFFS = {'Burst Affinity', 'Chain Affinity', 'Convergence', 'Diffusion', 'Efflux'}

---  ═══════════════════════════════════════════════════════════════════════════
---   BLUE MAGIC
---  ═══════════════════════════════════════════════════════════════════════════

--- Buff and self-healing sets laid over the Blue Magic set.
--- @param spell table Spell from GearSwap
--- @param category string|nil Spell category
--- @return table Names of what went on (for the trace)
local function lay_blue_overlays(spell, category)
    local laid = {}
    for _, buff in ipairs(BLUE_MAGIC_BUFFS) do
        if buffactive[buff] and sets.buff and sets.buff[buff] then
            equip(sets.buff[buff])
            laid[#laid + 1] = 'sets.buff["' .. buff .. '"]'
        end
    end
    if category == 'Healing' and sets.self_healing and spell.target and spell.target.type == 'SELF' then
        equip(sets.self_healing)
        laid[#laid + 1] = 'sets.self_healing'
    end
    return laid
end

--- @param spell table Spell from GearSwap
local function midcast_blue_magic(spell)
    local category = BLUSpellMap.category(spell.english)
    MidcastManager.select_set({
        skill = 'Blue Magic',
        spell = spell,
        mode_state = state.CastingMode,
        database_func = BLUSpellMap.category,
    })
    local laid = lay_blue_overlays(spell, category)
    require('shared/utils/debug/trace_log').log('MIDCAST', '%s -> category %s, casting %s, on top: %s',
        spell.english, tostring(category), tostring(state.CastingMode and state.CastingMode.current),
        #laid > 0 and table.concat(laid, ', ') or 'nothing')
end

---  ═══════════════════════════════════════════════════════════════════════════
---   OTHER SKILLS (subjob magic)
---  ═══════════════════════════════════════════════════════════════════════════

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
        return {mode_state = state.CastingMode,
            database_func = EnfeeblingSPELLS and EnfeeblingSPELLS.get_enfeebling_type or nil}
    end
    return {}
end

--- @param spell table Spell from GearSwap
local function midcast_other_skill(spell)
    local config = skill_options(spell.skill)
    config.skill = spell.skill
    config.spell = spell
    MidcastManager.select_set(config)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pre-midcast hook: nothing BLU-specific before Mote's set.
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
    if spell.skill == 'Blue Magic' then
        midcast_blue_magic(spell)
    else
        midcast_other_skill(spell)
    end
end

--- Mote spell map: the Blue Magic category (nil = Mote's default map).
--- @param spell table Spell from GearSwap
--- @param default_spell_map string|nil Mote's own map
--- @return string|nil
function job_get_spell_map(spell, default_spell_map)
    if spell.skill == 'Blue Magic' then
        return BLUSpellMap.category(spell.english)
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
