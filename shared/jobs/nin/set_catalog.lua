---============================================================================
--- Set Catalog (NIN) - the set names NIN's own code reads
---============================================================================
--- What NIN adds to shared/utils/atelier/set_catalog_common.lua, for the
--- Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/nin/functions/logic/set_builder.lua (engaged / idle,
--- buff layers, night movement), shared/jobs/nin/functions/logic/ninjutsu.lua
--- (Ninjutsu family, Magic Burst, Futae), shared/jobs/nin/functions/NIN_MIDCAST.lua
--- (MidcastManager calls), shared/utils/set_building/base_set_builder.lua
--- (select_idle_base). NIN_PRECAST.lua leaves Fast Cast (Utsusemi included),
--- job abilities, ranged attacks and weaponskills to Mote (common lines, and
--- the ranged lines below). The Dual Wield tiers are the common sets.DW lines.
---
--- @file    shared/jobs/nin/set_catalog.lua
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
    -- lay_buff_layers: on top of the engaged set, in this order, for each buff up
    {'buff.{Yonin|Innin|Sange|Issekigan}', when = 'Fighting with that buff up: on top of the engaged set', fr = 'Quand tu combats avec ce buff actif : mis par-dessus ton set engaged.'},

    ---------------------------------------------------------------- idle and movement (base_set_builder.lua select_idle_base, set_builder.lua apply_movement)
    {'idle.{HybridMode}', when = 'Standing outside a town with that Hybrid Mode', fr = 'Quand tu ne combats pas, hors de la ville, avec cet Hybrid Mode.', base = 'idle', needs = {'state:HybridMode'}},
    {'MoveSpeed.Night', when = 'Running outside a town from dusk to dawn (17:00-7:00 Vana\'diel time): in place of sets.MoveSpeed', fr = 'Quand tu cours hors de la ville entre 17 h et 7 h (heure de Vana’diel) : à la place de ton set MoveSpeed.',
        base = 'MoveSpeed'},

    ---------------------------------------------------------------- Ninjutsu (ninjutsu.lua midcast_config: type = the family, NIN_MIDCAST.lua)
    -- P6 type at the root
    {'midcast.Migawari', when = 'Casting Migawari', fr = 'Quand tu lances Migawari.', base = 'midcast.Ninjutsu', needs = {'spell:Migawari: Ichi'}},
    -- P7 type under the skill
    {'midcast.Ninjutsu.{Elemental|Enfeebling|Enhancing}', when = 'Casting a Ninjutsu of that family (Elemental: Katon, Suiton...; Enfeebling: Kurayami, Hojo...; Enhancing: Tonko, Monomi...)', fr = 'Quand tu lances un Ninjutsu de cette famille (élémentaire : Katon, Suiton… ; affaiblissement : Kurayami, Hojo… ; renfort : Tonko, Monomi…).',
        base = 'midcast.Ninjutsu'},
    -- P3 type.mode: mode_value MagicBurst on an elemental ninjutsu while Magic Burst is On
    {'midcast.Ninjutsu.Elemental.MagicBurst', when = 'Casting an elemental Ninjutsu with Magic Burst On', fr = 'Quand tu lances un Ninjutsu élémentaire avec le Magic Burst sur On.',
        base = {'midcast.Ninjutsu.Elemental', 'midcast.Ninjutsu'}, needs = {'state:MagicBurstMode'}},
    -- futae_layer: on top of an elemental ninjutsu while Futae is up
    {'buff.Futae', when = 'Casting an elemental Ninjutsu with Futae up: on top of the spell\'s set', fr = 'Quand tu lances un Ninjutsu élémentaire avec Futae actif : mis par-dessus le set du sort.'},

    ---------------------------------------------------------------- ranged (Mote get_precast_set / get_midcast_set)
    {'precast.RA', when = 'Starting a ranged attack (throwing)', fr = 'Au début d’une attaque à distance (lancer).'},
    {'midcast.RA', when = 'During a ranged attack (throwing)', fr = 'Pendant une attaque à distance (lancer).', base = 'precast.RA'},

    ---------------------------------------------------------------- spells (subjob magic, NIN_MIDCAST.lua other_skill_config)
    -- Enhancing Magic: database_func EnhancingSPELLS.get_spell_family (P6 root, P7 under the skill)
    {'midcast.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family, no family set at the root', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu n’as pas de set plus précis pour cette famille.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
}
