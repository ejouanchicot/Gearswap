---============================================================================
--- Set Catalog (BLU) - the set names BLU's own code reads
---============================================================================
--- What BLU adds to shared/utils/atelier/set_catalog_common.lua, for the
--- Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/blu/functions/logic/set_builder.lua (engaged / idle /
--- weapons), shared/jobs/blu/functions/BLU_MIDCAST.lua (MidcastManager calls,
--- buff and self-healing layers), shared/jobs/blu/functions/logic/spell_map.lua
--- (the Blue Magic category: {type:Blue Magic}, read from the character's
--- BLU_SPELL_MAP.lua by shared/utils/atelier/atelier_families.lua).
--- BLU_PRECAST.lua leaves the job ability, Fast Cast and weaponskill sets to
--- Mote (common lines: precast.FC.Blue Magic, precast.WS.{ws}.{WeaponskillMode}).
--- The subjob's spells (P1 [skill][base], Utsusemi) are common lines.
---
--- @file    shared/jobs/blu/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-28
---============================================================================

return {
    ---------------------------------------------------------------- engaged (set_builder.lua select_engaged_base, Mote's walk)
    -- sets.engaged -> .SW when single wielding (nothing, a shield or a grip in the off hand) -> [OffenseMode]
    {'engaged.SW', when = 'Fighting with one weapon (nothing, a shield or a grip in the off hand)', fr = 'Quand tu combats avec une seule arme (rien, un bouclier ou une poignée dans la main gauche).', base = 'engaged'},
    {'engaged.{OffenseMode~Normal}', when = 'Fighting with two weapons and that Offense Mode', fr = 'Quand tu combats avec deux armes et cet Offense Mode.', base = 'engaged', needs = {'state:OffenseMode'}},
    {'engaged.SW.{OffenseMode~Normal}', when = 'Fighting with one weapon and that Offense Mode (read only when sets.engaged.SW exists)', fr = 'Quand tu combats avec une seule arme et cet Offense Mode, si tu as un set engaged.SW.',
        base = 'engaged.SW', needs = {'state:OffenseMode'}},

    ---------------------------------------------------------------- idle (set_builder.lua select_idle_base)
    {'idle.{IdleMode~Normal}', when = 'Standing with that Idle Mode (Normal is sets.idle)', fr = 'Quand tu ne combats pas, avec cet Idle Mode (Normal, c’est ton set idle).', base = 'idle', needs = {'state:IdleMode'}},

    ---------------------------------------------------------------- Blue Magic (BLU_MIDCAST.lua midcast_blue_magic)
    -- MidcastManager: skill Blue Magic, type = the spell's category (spell_map.lua), mode = CastingMode.
    -- P3 resolve_type_mode
    {'midcast.Blue Magic.{type:Blue Magic}.{CastingMode~Normal}', when = 'A Blue Magic spell of that category in that Casting Mode (read only when sets.midcast[\'Blue Magic\'] exists)', fr = 'Quand tu lances un sort de Blue Magic de cette catégorie avec ce Casting Mode, si tu as un set Blue Magic.',
        base = {'midcast.Blue Magic.{type}', 'midcast.Blue Magic'}, needs = {'state:CastingMode'}},
    -- P6 resolve_type_root: tried before the line below, so a category name at the root of sets.midcast wins
    {'midcast.{type:Blue Magic}', when = 'A Blue Magic spell of that category (read before sets.midcast[\'Blue Magic\'][category]: keep it empty unless meant)', fr = 'Quand tu lances un sort de Blue Magic de cette catégorie (passe avant le set rangé sous Blue Magic : à éviter sauf si tu le veux).',
        base = 'midcast.Blue Magic'},
    -- P7 resolve_type_under_skill
    {'midcast.Blue Magic.{type:Blue Magic}', when = 'A Blue Magic spell of that category (Physical, Magical, Breath...)', fr = 'Quand tu lances un sort de Blue Magic de cette catégorie (physique, magique, souffle…).',
        base = 'midcast.Blue Magic'},
    -- P8 resolve_mode
    {'midcast.Blue Magic.{CastingMode~Normal}', when = 'Any Blue Magic spell in that Casting Mode, unless its category has a set for the mode', fr = 'Quand tu lances n’importe quel sort de Blue Magic avec ce Casting Mode, sauf si sa catégorie a un set pour ce mode.',
        base = 'midcast.Blue Magic', needs = {'state:CastingMode'}},
    -- lay_blue_overlays: on top of the Blue Magic set, in this order, for each buff that is up
    {'buff.{Burst Affinity|Chain Affinity|Convergence|Diffusion|Efflux}', when = 'Casting Blue Magic with that buff up: on top of the Blue Magic set', fr = 'Quand tu lances un sort de Blue Magic avec ce buff actif : mis par-dessus ton set de Blue Magic.'},
    {'self_healing', when = 'Casting a Healing-category Blue Magic spell on yourself: on top of the Blue Magic set', fr = 'Quand tu lances un sort de soin de Blue Magic sur toi-même : mis par-dessus ton set de Blue Magic.'},

    ---------------------------------------------------------------- spells (subjob magic, BLU_MIDCAST.lua skill_options)
    -- Enhancing Magic: database_func EnhancingSPELLS.get_spell_family (P6 root, P7 under the skill)
    {'midcast.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family, no family set at the root', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu n’as pas de set plus précis pour cette famille.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    -- Enfeebling Magic: database_func get_enfeebling_type, mode CastingMode (P3, P6, P7)
    {'midcast.Enfeebling Magic.{type:Enfeebling Magic}.{CastingMode~Normal}', when = 'An enfeeble of that kind in that Casting Mode (read only when sets.midcast[\'Enfeebling Magic\'] exists)', fr = 'Quand tu lances un affaiblissement de ce genre avec ce Casting Mode, si tu as un set Enfeebling Magic.',
        base = {'midcast.Enfeebling Magic.{type}', 'midcast.Enfeebling Magic'}, needs = {'skill:Enfeebling Magic', 'state:CastingMode'}},
    {'midcast.{type:Enfeebling Magic}', when = 'An enfeeble of that kind (read only when sets.midcast[\'Enfeebling Magic\'] exists)', fr = 'Quand tu lances un affaiblissement de ce genre, si tu as un set Enfeebling Magic.',
        base = 'midcast.Enfeebling Magic', needs = {'skill:Enfeebling Magic'}},
    {'midcast.Enfeebling Magic.{type:Enfeebling Magic}', when = 'An enfeeble of that kind, when sets.midcast.<kind> does not exist', fr = 'Quand tu lances un affaiblissement de ce genre, si tu n’as pas de set plus précis pour ce genre.',
        base = 'midcast.Enfeebling Magic', needs = {'skill:Enfeebling Magic'}},
}
