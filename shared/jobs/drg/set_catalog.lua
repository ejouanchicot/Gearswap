---============================================================================
--- Set Catalog (DRG) - the set names DRG's own code reads
---============================================================================
--- What DRG adds to shared/utils/atelier/set_catalog_common.lua, for the
--- Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/drg/functions/logic/set_builder.lua (engaged / idle,
--- wyvern layer, Spirit Surge), shared/jobs/drg/functions/logic/wyvern.lua
--- (breath sets, Healing Breath trigger), shared/jobs/drg/functions/DRG_PET_MIDCAST.lua,
--- shared/jobs/drg/functions/DRG_MIDCAST.lua (MidcastManager calls, trigger layer),
--- shared/utils/set_building/base_set_builder.lua (select_idle_base, idle_without_pet).
--- DRG_PRECAST.lua leaves the job ability, Fast Cast, pet command and
--- weaponskill sets to Mote (common lines). The subjob's spells
--- (P1 [skill][base], Utsusemi) are common lines.
---
--- @file    shared/jobs/drg/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-28
---============================================================================

return {
    ---------------------------------------------------------------- engaged (set_builder.lua select_engaged_base)
    -- sets.engaged -> [OffenseMode] when that level has it -> .DT under Hybrid Mode DT (that level's, else sets.engaged.DT)
    {'engaged.{OffenseMode~Normal}', when = 'Fighting with that Offense Mode', fr = 'Quand tu combats avec cet Offense Mode.', base = 'engaged', needs = {'state:OffenseMode'}},
    {'engaged.DT', when = 'Fighting with Hybrid Mode DT (also for an Offense Mode whose set has no .DT)', fr = 'Quand tu combats avec l’Hybrid Mode sur DT (aussi pour un Offense Mode dont le set n’a pas de version DT).',
        base = 'engaged', needs = {'value:HybridMode=DT'}},
    {'engaged.{OffenseMode~Normal}.DT', when = 'Fighting with that Offense Mode and Hybrid Mode DT', fr = 'Quand tu combats avec cet Offense Mode et l’Hybrid Mode sur DT.',
        base = {'engaged.{OffenseMode}', 'engaged.DT'}, needs = {'state:OffenseMode', 'value:HybridMode=DT'}},
    -- lay_spirit_surge: on top of the engaged set while the buff is up
    {'buff.Spirit Surge', when = 'Fighting with Spirit Surge up: on top of the engaged set', fr = 'Quand tu combats avec Spirit Surge actif : mis par-dessus ton set engaged.'},

    ---------------------------------------------------------------- idle (base_set_builder.lua select_idle_base, set_builder.lua wyvern_idle_layer)
    {'idle.{HybridMode}', when = 'Standing outside a town with that Hybrid Mode', fr = 'Quand tu ne combats pas, hors de la ville, avec cet Hybrid Mode.', base = 'idle', needs = {'state:HybridMode'}},
    {'idle.Pet', when = 'Standing outside a town with your wyvern out: on top of the idle set', fr = 'Quand tu ne combats pas, hors de la ville, avec ta wyverne sortie : mis par-dessus ton set idle.'},
    {'idle.Pet.DT', when = 'Standing outside a town with your wyvern out and Hybrid Mode DT: in place of sets.idle.Pet', fr = 'Quand tu ne combats pas, hors de la ville, avec ta wyverne sortie et l’Hybrid Mode sur DT : à la place du set idle.Pet.',
        base = 'idle.Pet', needs = {'value:HybridMode=DT'}},

    ---------------------------------------------------------------- wyvern (wyvern.lua breath_set, DRG_PET_MIDCAST.lua)
    {'midcast.HealingBreath', when = 'Your wyvern uses Healing Breath (any tier)', fr = 'Quand ta wyverne utilise Healing Breath (n’importe quel tier).'},
    {'midcast.ElementalBreath', when = 'Your wyvern uses an elemental breath (Flame, Frost, Gust, Sand, Lightning, Hydro)', fr = 'Quand ta wyverne utilise un souffle élémentaire (feu, glace, vent, terre, foudre, eau).'},
    -- DRG_MIDCAST.lua lay_breath_trigger: subjob mage (/WHM, /RDM... below 50% HP; /PLD, /NIN... below 33%), wyvern out
    {'midcast.HealingBreathTrigger', when = 'Casting a spell with your wyvern out and your HP under the subjob\'s Healing Breath line: on top of the spell\'s set', fr = 'Quand tu lances un sort avec ta wyverne sortie et tes HP sous le seuil de Healing Breath de ton sub : mis par-dessus le set du sort.',
        needs = {'spells'}},

    ---------------------------------------------------------------- spells (subjob magic, DRG_MIDCAST.lua skill_options)
    -- Enhancing Magic: database_func EnhancingSPELLS.get_spell_family (P6 root, P7 under the skill)
    {'midcast.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family, no family set at the root', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu n’as pas de set plus précis pour cette famille.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    -- Enfeebling Magic: database_func get_enfeebling_type, no mode (P6, P7)
    {'midcast.{type:Enfeebling Magic}', when = 'An enfeeble of that kind (read only when sets.midcast[\'Enfeebling Magic\'] exists)', fr = 'Quand tu lances un affaiblissement de ce genre, si tu as un set Enfeebling Magic.',
        base = 'midcast.Enfeebling Magic', needs = {'skill:Enfeebling Magic'}},
    {'midcast.Enfeebling Magic.{type:Enfeebling Magic}', when = 'An enfeeble of that kind, when sets.midcast.<kind> does not exist', fr = 'Quand tu lances un affaiblissement de ce genre, si tu n’as pas de set plus précis pour ce genre.',
        base = 'midcast.Enfeebling Magic', needs = {'skill:Enfeebling Magic'}},
}
