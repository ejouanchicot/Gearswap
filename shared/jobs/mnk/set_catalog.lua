---============================================================================
--- Set Catalog (MNK) - the set names MNK's own code reads
---============================================================================
--- What MNK adds to shared/utils/atelier/set_catalog_common.lua, for the
--- Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/mnk/functions/logic/set_builder.lua (engaged / idle /
--- weapon), shared/jobs/mnk/functions/logic/buff_layers.lua (buff layers on the
--- engaged set and on weaponskills, from MNK_PRECAST.lua job_post_precast),
--- shared/jobs/mnk/functions/MNK_MIDCAST.lua (MidcastManager calls),
--- shared/utils/set_building/base_set_builder.lua (select_idle_base).
--- Job abilities, Fast Cast and weaponskills (with WeaponskillMode) are Mote's
--- picks (common lines). The subjob's spells (P1 [skill][base], Utsusemi) are
--- common lines.
---
--- @file    shared/jobs/mnk/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-28
---============================================================================

return {
    ---------------------------------------------------------------- engaged (set_builder.lua select_engaged_base)
    -- sets.engaged -> [OffenseMode] when that level has it -> [HybridMode] (DT, Counter) from that level, else from sets.engaged
    {'engaged.{OffenseMode~Normal}', when = 'Fighting with that Offense Mode', fr = 'Quand tu combats avec cet Offense Mode.', base = 'engaged', needs = {'state:OffenseMode'}},
    {'engaged.{HybridMode~Normal}', when = 'Fighting with that Hybrid Mode (also for an Offense Mode whose set has none for it)', fr = 'Quand tu combats avec cet Hybrid Mode (aussi pour un Offense Mode dont le set n’en a pas de version).',
        base = 'engaged', needs = {'state:HybridMode'}},
    {'engaged.{OffenseMode~Normal}.{HybridMode~Normal}', when = 'Fighting with that Offense Mode and that Hybrid Mode', fr = 'Quand tu combats avec cet Offense Mode et cet Hybrid Mode.',
        base = {'engaged.{OffenseMode}', 'engaged.{HybridMode}'}, needs = {'state:OffenseMode', 'state:HybridMode'}},
    -- buff_layers.lua lay_engaged: on top of the engaged set, in this order, for each buff up
    {'buff.{Counterstance|Footwork|Impetus|Hundred Fists}', when = 'Fighting with that buff up: on top of the engaged set (Impetus and Footwork: also on weaponskills, see below)', fr = 'Quand tu combats avec ce buff actif : mis par-dessus ton set engaged (Impetus et Footwork : aussi sur les weaponskills, voir plus bas).'},
    -- engaged_layer: the buff set's [HybridMode] child, when it is a table, in its place
    {'buff.{Counterstance|Footwork|Impetus|Hundred Fists}.{HybridMode~Normal}', when = 'Fighting with that buff up and that Hybrid Mode: in place of the buff\'s own set', fr = 'Quand tu combats avec ce buff actif et cet Hybrid Mode : à la place du set du buff.',
        base = 'buff.{Counterstance|Footwork|Impetus|Hundred Fists}', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- weaponskills (buff_layers.lua ws_layers, after Mote's set)
    -- Impetus on every weaponskill, Footwork on Dragon Kick and Tornado Kick: sets.buff[buff], then sets.precast.WS[ws][buff]
    {'precast.WS.{ws}.Impetus', when = 'That weaponskill with Impetus up: on top of the weaponskill set (after sets.buff.Impetus)', fr = 'Pour cette weaponskill avec Impetus actif : mis par-dessus ton set de weaponskill (après le set buff.Impetus).',
        base = 'precast.WS.{ws}'},
    {'precast.WS.{Dragon Kick|Tornado Kick}.Footwork', when = 'That kick with Footwork up: on top of the weaponskill set (after sets.buff.Footwork)', fr = 'Pour ce coup de pied avec Footwork actif : mis par-dessus ton set de weaponskill (après le set buff.Footwork).',
        base = 'precast.WS.{Dragon Kick|Tornado Kick}'},

    ---------------------------------------------------------------- idle (base_set_builder.lua select_idle_base)
    {'idle.{HybridMode}', when = 'Standing outside a town with that Hybrid Mode', fr = 'Quand tu ne combats pas, hors de la ville, avec cet Hybrid Mode.', base = 'idle', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- spells (subjob magic, MNK_MIDCAST.lua skill_options)
    -- Enhancing Magic: database_func EnhancingSPELLS.get_spell_family (P6 root, P7 under the skill)
    {'midcast.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family, no family set at the root', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu n’as pas de set plus précis pour cette famille.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
}
