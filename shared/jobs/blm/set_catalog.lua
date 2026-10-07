---============================================================================
--- Set Catalog (BLM) - the set names the Black Mage code reads
---============================================================================
--- What BLM's own code adds to set_catalog_common.lua, for the Atelier's
--- "+ Set" (format: shared/utils/atelier/set_catalog.lua): the idle and
--- engaged sets its set builder picks, the Mana Wall set, and the midcast
--- sets of its router (Elemental with Magic Burst, Impact, the MND / INT
--- enfeebles). The common P1 [skill][base] lines are re-written for the enfeebles (see below).
---
--- Not offered, although read:
---   MidcastManager P1 [skill][tier-less name] under IntEnfeebles / MndEnfeebles
---     (sets.midcast.IntEnfeebles.Blind): the split is the spell's type (Black /
---     White Magic), which no placeholder filters. The P1 lines under the real
---     skills (sets.midcast['Dark Magic'].Aspir) are common lines.
---   MidcastManager P6 [type] at the root for the enfeebles (sets.midcast.potency):
---     a family name alone would be read by every skill that has it.
---   MidcastManager P8b Mote spell map: Mote-Mappings is not in the repo.
---
--- @file    shared/jobs/blm/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    -- midcast_router.lua enfeeble_set_for: a white magic enfeeble goes through select_set with skill 'MndEnfeebles', a black
    -- one 'IntEnfeebles', when that set exists; 'Enfeebling Magic' only when it is missing. P1 [skill][base] follows it.
    skip = {'midcast.{spellbase.skill}.{spellbase}', 'midcast.{spellplain.skill}.{spellplain}'},
    {'midcast.{spellbase.skill}.{spellbase}', when = 'Any tier of that spell (read while the skill\'s set exists)', base = 'midcast.{spellbase.skill}',
        needs = {'not:spellbase.skill:Enfeebling Magic', 'absent:midcast.{spellbase}'}},
    {'midcast.{spellplain.skill}.{spellplain}', when = 'That spell (read while the skill\'s set exists)', base = 'midcast.{spellplain.skill}',
        needs = {'not:spellplain.skill:Enfeebling Magic', 'absent:midcast.{spellplain}'}},
    {'midcast.IntEnfeebles.{spellbase:Enfeebling Magic}', when = 'Any tier of that black magic enfeeble (read while sets.midcast.IntEnfeebles exists)',
        base = 'midcast.IntEnfeebles', needs = {'not:spellbase.type:WhiteMagic', 'absent:midcast.{spellbase}'}},
    {'midcast.IntEnfeebles.{spellplain:Enfeebling Magic}', when = 'That black magic enfeeble (read while sets.midcast.IntEnfeebles exists)',
        base = 'midcast.IntEnfeebles', needs = {'not:spellplain.type:WhiteMagic', 'absent:midcast.{spellplain}'}},
    {'midcast.MndEnfeebles.{spellbase:Enfeebling Magic}', when = 'Any tier of that white magic enfeeble (read while sets.midcast.MndEnfeebles exists)',
        base = 'midcast.MndEnfeebles', needs = {'not:spellbase.type:BlackMagic', 'absent:midcast.{spellbase}'}},
    {'midcast.MndEnfeebles.{spellplain:Enfeebling Magic}', when = 'That white magic enfeeble (read while sets.midcast.MndEnfeebles exists)',
        base = 'midcast.MndEnfeebles', needs = {'not:spellplain.type:BlackMagic', 'absent:midcast.{spellplain}'}},
    -- 'Enfeebling Magic' only for the spells whose MND / INT set is missing
    {'midcast.Enfeebling Magic.{spellbase:Enfeebling Magic}', when = 'Any tier of that black magic enfeeble, while sets.midcast.IntEnfeebles is missing',
        base = 'midcast.Enfeebling Magic', needs = {'not:spellbase.type:WhiteMagic', 'absent:midcast.IntEnfeebles', 'absent:midcast.{spellbase}'}},
    {'midcast.Enfeebling Magic.{spellbase:Enfeebling Magic}', when = 'Any tier of that white magic enfeeble, while sets.midcast.MndEnfeebles is missing',
        base = 'midcast.Enfeebling Magic', needs = {'not:spellbase.type:BlackMagic', 'absent:midcast.MndEnfeebles', 'absent:midcast.{spellbase}'}},
    {'midcast.Enfeebling Magic.{spellplain:Enfeebling Magic}', when = 'That black magic enfeeble, while sets.midcast.IntEnfeebles is missing',
        base = 'midcast.Enfeebling Magic', needs = {'not:spellplain.type:WhiteMagic', 'absent:midcast.IntEnfeebles', 'absent:midcast.{spellplain}'}},
    {'midcast.Enfeebling Magic.{spellplain:Enfeebling Magic}', when = 'That white magic enfeeble, while sets.midcast.MndEnfeebles is missing',
        base = 'midcast.Enfeebling Magic', needs = {'not:spellplain.type:BlackMagic', 'absent:midcast.MndEnfeebles', 'absent:midcast.{spellplain}'}},

    ---------------------------------------------------------------- idle
    -- Mote get_idle_set (sets.idle[IdleMode]); logic/set_builder.lua build_idle_set falls back to sets.idle.Normal
    {'idle.{IdleMode}', when = 'Standing, not fighting (idle.Death / idle.PDT replace it when their mode is on)', base = 'idle'},
    -- logic/set_builder.lua mode_base (allow_death): DeathMode On replaces Mote's idle, before HybridMode
    {'idle.Death', when = 'Standing, not fighting, with Death Mode On (keeps your MP up for Death)',
        base = {'idle.Normal', 'idle'}, needs = {'state:DeathMode'}},
    -- logic/set_builder.lua mode_base: HybridMode PDT replaces Mote's idle
    {'idle.PDT', when = 'Standing, not fighting, with Hybrid Mode PDT (Death Mode Off)',
        base = {'idle.Normal', 'idle'}, needs = {'state:HybridMode'}},
    -- Mote get_idle_set in a city, laid by base_set_builder.lua select_idle_base_town (only when
    -- mode_base kept Mote's pick: with idle.Death / idle.PDT worn, sets.idle.Town itself goes on top)
    {'idle.Town.{IdleMode}', when = 'Idle in a town with that Idle Mode, laid on top of the idle set', base = 'idle.Town'},
    -- logic/set_builder.lua build_idle_set step 5 (idle only, laid last)
    {'buff.Mana Wall', when = 'Idle while Mana Wall is up: laid on top of the idle set'},

    ---------------------------------------------------------------- engaged
    -- Mote get_melee_set (sets.engaged[OffenseMode]); logic/set_builder.lua build_engaged_set falls back to sets.engaged.Normal
    {'engaged.{OffenseMode}', when = 'Weapon out, fighting (engaged.PDT replaces it with Hybrid Mode PDT)', base = 'engaged'},
    -- logic/set_builder.lua mode_base: HybridMode PDT replaces Mote's engaged set
    {'engaged.PDT', when = 'Weapon out, fighting, with Hybrid Mode PDT',
        base = {'engaged.Normal', 'engaged'}, needs = {'state:HybridMode'}},
    -- Mote get_melee_set ([OffenseMode][HybridMode]): only worn while sets.engaged.PDT does not exist
    {'engaged.{OffenseMode}.PDT', when = 'Fighting with Hybrid Mode PDT (read only while sets.engaged.PDT does not exist)',
        base = 'engaged.{OffenseMode}', needs = {'state:HybridMode', 'absent:engaged.PDT'}},

    ---------------------------------------------------------------- Elemental Magic (logic/midcast_router.lua Router.handle_elemental)
    -- select_set{skill = 'Elemental Magic', mode_value = 'MagicBurst' when MagicBurstMode is On or Acc}: P9
    {'midcast.Elemental Magic', when = 'Casting a nuke with no set of its own (Magic Burst Mode Off)'},
    -- P8 [skill][mode]
    {'midcast.Elemental Magic.MagicBurst', when = 'Casting a nuke with Magic Burst Mode On or Acc (read only when sets.midcast[\'Elemental Magic\'] exists)',
        base = 'midcast.Elemental Magic', needs = {'state:MagicBurstMode'}},
    -- Router.handle_elemental: equipped last when MagicBurstMode is Acc, over the three overlays below
    {'midcast.Elemental Magic.MagicBurst.acc', when = 'Casting a nuke with Magic Burst Mode Acc: laid last, over every other nuke piece',
        base = 'midcast.Elemental Magic.MagicBurst', needs = {'state:MagicBurstMode'}},

    ---------------------------------------------------------------- Impact (midcast_router.lua Router.handle_impact, no MidcastManager;
    -- before the [spell].MagicBurst line, which would name the same paths)
    {'midcast.Impact', when = 'Casting Impact (the cloak itself is kept on by the shared Impact lock)', base = 'midcast.Elemental Magic'},
    {'midcast.Impact.MagicBurst', when = 'Casting Impact with Magic Burst Mode On (not Acc)', base = 'midcast.Impact',
        needs = {'state:MagicBurstMode'}},

    ---------------------------------------------------------------- Elemental Magic, continued
    -- P0 [spell][mode]
    {'midcast.{spell:Elemental Magic}.MagicBurst', when = 'Casting that nuke with Magic Burst Mode On or Acc (read only when sets.midcast[\'Elemental Magic\'] and the spell\'s own set exist)',
        base = 'midcast.{spell}', needs = {'state:MagicBurstMode'}},
    -- midcast_router.lua apply_mp_conservation (BLM_MP_CONFIG mp_threshold, 1000 by default)
    {'midcast.MPConservation', when = 'Casting a nuke with your MP under the threshold of BLM_MP_CONFIG: laid on top of the nuke set'},
    -- midcast_router.lua apply_elemental_match (only while the shared Elemental Belt is turned off)
    {'midcast.ElementalMatch', when = 'Casting a nuke whose element matches the day, weather or storm, with the shared Elemental Belt off: laid on top'},
    -- midcast_router.lua apply_quanpur (QUANPUR_SPELLS: Stone I-VI, Stoneja, Stonera I-III)
    {'midcast.QuanpurStone', when = 'Casting Stone, Stoneja or Stonera (not Stonega or Quake): laid on top of the nuke set'},

    ---------------------------------------------------------------- Enfeebling Magic (midcast_router.lua Router.handle_enfeebling)
    -- enfeeble_set_for: the skill passed to select_set is IntEnfeebles / MndEnfeebles when that set exists
    {'midcast.IntEnfeebles', when = 'Casting a black magic enfeeble (the game lists the spell as Black Magic)', base = 'midcast.Enfeebling Magic'},
    {'midcast.MndEnfeebles', when = 'Casting a white magic enfeeble (the game lists the spell as White Magic)', base = 'midcast.Enfeebling Magic'},
    -- P7 [skill][type], type from ENFEEBLING_MAGIC_DATABASE.get_enfeebling_type
    {'midcast.IntEnfeebles.{type:IntEnfeebles}', when = 'Casting a black magic enfeeble of that kind (read only when sets.midcast.IntEnfeebles exists)',
        base = 'midcast.IntEnfeebles'},
    {'midcast.MndEnfeebles.{type:MndEnfeebles}', when = 'Casting a white magic enfeeble of that kind (read only when sets.midcast.MndEnfeebles exists)',
        base = 'midcast.MndEnfeebles'},
    -- enfeeble_set_for falls back to 'Enfeebling Magic' when the MND / INT set is missing
    {'midcast.Enfeebling Magic.{type:Enfeebling Magic}', when = 'Casting an enfeeble of that kind while its MndEnfeebles / IntEnfeebles set is missing (read only when sets.midcast[\'Enfeebling Magic\'] exists)',
        base = 'midcast.Enfeebling Magic'},
}
