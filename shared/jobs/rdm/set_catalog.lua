---============================================================================
--- Set Catalog (RDM) - the set names Red Mage's own code reads
---============================================================================
--- What the RDM code adds to shared/utils/atelier/set_catalog_common.lua, for
--- the Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/rdm/functions/logic/set_builder.lua (idle, engaged),
--- shared/jobs/rdm/functions/RDM_MIDCAST.lua (one MidcastManager.select_set per
--- skill, chain levels in shared/utils/midcast/midcast_manager.lua RESOLVERS),
--- shared/utils/midcast/midcast_fallback.lua (a subjob's magic), states in
--- _master/config/rdm/RDM_STATES.lua.
---
--- MidcastManager.select_set returns without equipping anything when
--- sets.midcast[<skill>] does not exist: every level under a skill below is
--- read only while that skill's set exists.
---
--- @file    shared/jobs/rdm/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

-- The tier-less names of the Enhancing spells RDM can cast on someone else
-- (spell list: Enhancing Magic, RDM level, a target other than Self). The
-- Composure target only exists for those (MidcastManager.get_enhancing_target).
-- Written out because no placeholder filters the spells by target ({spellbase:Enhancing
-- Magic} would add Temper, Enfire..., self-only, and leave Sneak, Invisible, Deodorize out).
local COMPOSURE_SPELLS = '{Deodorize|Flurry|Haste|Invisible|Phalanx|Protect|Refresh|Regen|Shell|Sneak}'

return {
    ---------------------------------------------------------------- idle (set_builder.lua build_idle_set)
    -- set_builder.lua select_idle_base: sets.idle[IdleMode] (Mote reads it too), else below
    {'idle.{IdleMode}', when = 'Standing, not fighting, in that Idle Mode', fr = 'Quand tu ne combats pas, avec ce Idle Mode.', base = 'idle'},
    -- select_idle_base: HybridMode PDT, read only while sets.idle.<IdleMode> does not exist
    {'idle.PDT', when = 'Standing with Hybrid Mode PDT, only while the Idle Mode has no set of its own', fr = 'Quand tu ne combats pas, avec l’Hybrid Mode sur PDT, si ton Idle Mode n’a pas son propre set.',
        base = 'idle', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- engaged (set_builder.lua build_engaged_set)
    -- set_builder.lua select_engaged_base: sets.engaged[EngagedMode] with a shield / one weapon
    {'engaged.{EngagedMode}', when = 'Fighting in that Engaged Mode, shield or nothing in the off hand', fr = 'Quand tu combats avec cet Engaged Mode, avec un bouclier ou rien dans l’autre main.', base = 'engaged'},
    -- select_engaged_base: .DW when has_shield_equipped says two weapons (only /NIN, /DNC)
    {'engaged.{EngagedMode}.DW', when = 'Fighting in that Engaged Mode with a weapon in each hand', fr = 'Quand tu combats avec cet Engaged Mode et une arme dans chaque main.',
        base = {'engaged.{EngagedMode}', 'engaged'}, needs = {'dw'}},
    -- select_engaged_base: HybridMode PDT, read only while sets.engaged.<EngagedMode> does not exist
    {'engaged.PDT', when = 'Fighting with Hybrid Mode PDT, only while the Engaged Mode has no set of its own', fr = 'Quand tu combats avec l’Hybrid Mode sur PDT, si ton Engaged Mode n’a pas son propre set.',
        base = 'engaged', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- Enfeebling (RDM_MIDCAST.lua midcast_enfeebling)
    -- select_set{skill='Enfeebling Magic', mode_state=EnfeebleMode, database_func=get_enfeebling_type}
    -- P0 resolve_exact_spell: the spell's own set, then its EnfeebleMode child
    {'midcast.{spell:Enfeebling Magic}.{EnfeebleMode}', when = 'Casting that enfeeble in that Enfeeble Mode (read only when sets.midcast.<spell> exists)', fr = 'Quand tu lances cet affaiblissement avec cet Enfeeble Mode, si tu as un set au nom du sort.',
        base = 'midcast.{spell}'},
    -- P3 resolve_type_mode
    {'midcast.Enfeebling Magic.{type:Enfeebling Magic}.{EnfeebleMode}', when = 'An enfeeble of that kind in that Enfeeble Mode (read only when sets.midcast.Enfeebling Magic exists)', fr = 'Quand tu lances un affaiblissement de ce genre avec cet Enfeeble Mode, si tu as un set Enfeebling Magic.',
        base = {'midcast.Enfeebling Magic.{type}', 'midcast.Enfeebling Magic'}},
    -- P6 resolve_type_root
    {'midcast.{type:Enfeebling Magic}', when = 'An enfeeble of that kind (read only when sets.midcast.Enfeebling Magic exists)', fr = 'Quand tu lances un affaiblissement de ce genre, si tu as un set Enfeebling Magic.',
        base = 'midcast.Enfeebling Magic'},
    -- P7 resolve_type_under_skill
    {'midcast.Enfeebling Magic.{type:Enfeebling Magic}', when = 'An enfeeble of that kind, when sets.midcast.<kind> does not exist', fr = 'Quand tu lances un affaiblissement de ce genre, si tu n’as pas de set plus précis pour ce genre.',
        base = 'midcast.Enfeebling Magic'},
    -- P8 resolve_mode
    {'midcast.Enfeebling Magic.{EnfeebleMode}', when = 'Any enfeeble while that Enfeeble Mode is chosen (not Auto), unless its kind has a set for the mode', fr = 'Quand tu lances n’importe quel affaiblissement avec cet Enfeeble Mode choisi (pas Auto), sauf si son genre a un set pour ce mode.',
        base = 'midcast.Enfeebling Magic'},
    -- midcast_enfeebling: laid on top while Saboteur is up
    {'midcast.Enfeebling Magic.Saboteur', when = 'Casting an enfeeble while Saboteur is up: on top of the enfeeble set', fr = 'Quand tu lances un affaiblissement avec Saboteur actif : mis par-dessus ton set d’affaiblissement.',
        base = 'midcast.Enfeebling Magic'},

    ---------------------------------------------------------------- Enhancing (RDM_MIDCAST.lua midcast_enhancing)
    -- select_set{skill='Enhancing Magic', mode_state=EnhancingMode, target_func=get_enhancing_target,
    -- database_func=get_spell_family}. The target is 'Composure' (Composure up, target not you) or nothing.
    -- state.EnhancingMode is defined by no config: the {EnhancingMode} lines give nothing until it is.
    -- P0 resolve_exact_spell
    {'midcast.{spell:Enhancing Magic}.{EnhancingMode}', when = 'Casting that spell in that Enhancing Mode (read only when sets.midcast.<spell> exists)', fr = 'Quand tu lances ce sort avec cet Enhancing Mode, si tu as un set au nom du sort.',
        base = 'midcast.{spell}'},
    -- P1 resolve_base_name with the Composure target
    {'midcast.' .. COMPOSURE_SPELLS .. '.Composure', when = 'Any tier of that spell on someone else under Composure', fr = 'Quand tu lances ce sort, à n’importe quel tier, sur quelqu’un d’autre avec Composure actif.',
        base = {'midcast.' .. COMPOSURE_SPELLS, 'midcast.Enhancing Magic'}},
    {'midcast.Composure.' .. COMPOSURE_SPELLS, when = 'Any tier of that spell on someone else under Composure (read only when sets.midcast.Enhancing Magic exists)', fr = 'Quand tu lances ce sort, à n’importe quel tier, sur quelqu’un d’autre avec Composure actif, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic'},
    {'midcast.Enhancing Magic.' .. COMPOSURE_SPELLS .. '.Composure', when = 'Any tier of that spell on someone else under Composure (read only when sets.midcast.Enhancing Magic exists)', fr = 'Quand tu lances ce sort, à n’importe quel tier, sur quelqu’un d’autre avec Composure actif, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic'},
    {'midcast.Enhancing Magic.Composure.' .. COMPOSURE_SPELLS, when = 'Any tier of that spell on someone else under Composure (read only when sets.midcast.Enhancing Magic exists)', fr = 'Quand tu lances ce sort, à n’importe quel tier, sur quelqu’un d’autre avec Composure actif, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic'},
    -- P2 resolve_type_target_mode (needs EnhancingMode)
    {'midcast.Enhancing Magic.{type:Enhancing Magic}.Composure.{EnhancingMode}', when = 'A spell of that family on someone else under Composure, in that Enhancing Mode', fr = 'Quand tu lances un sort de cette famille sur quelqu’un d’autre avec Composure actif, avec cet Enhancing Mode.',
        base = 'midcast.Enhancing Magic'},
    -- P3 resolve_type_mode (needs EnhancingMode)
    {'midcast.Enhancing Magic.{type:Enhancing Magic}.{EnhancingMode}', when = 'A spell of that family in that Enhancing Mode', fr = 'Quand tu lances un sort de cette famille avec cet Enhancing Mode.',
        base = 'midcast.Enhancing Magic'},
    -- P4 resolve_target_mode (needs EnhancingMode)
    {'midcast.Enhancing Magic.Composure.{EnhancingMode}', when = 'An enhancing spell on someone else under Composure, in that Enhancing Mode', fr = 'Quand tu lances un sort d’Enhancing Magic sur quelqu’un d’autre avec Composure actif, avec cet Enhancing Mode.',
        base = 'midcast.Enhancing Magic'},
    -- P5 resolve_target: under the skill, then at the root
    {'midcast.Enhancing Magic.Composure', when = 'An enhancing spell on someone else under Composure, without a set of its own', fr = 'Quand tu lances un sort d’Enhancing Magic sur quelqu’un d’autre avec Composure actif, si ce sort n’a pas de set à lui.',
        base = 'midcast.Enhancing Magic'},
    {'midcast.Composure', when = 'An enhancing spell on someone else under Composure, when sets.midcast.Enhancing Magic.Composure does not exist (read only when sets.midcast.Enhancing Magic exists)', fr = 'Quand tu lances un sort d’Enhancing Magic sur quelqu’un d’autre avec Composure actif, si tu n’as pas de set Enhancing Magic.Composure mais as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic'},
    -- P6 resolve_type_root
    {'midcast.{type:Enhancing Magic}', when = 'A spell of that family (Enspell, Gain, BarElement...) (read only when sets.midcast.Enhancing Magic exists)', fr = 'Quand tu lances un sort de cette famille (Enspell, Gain, BarElement…), si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic'},
    -- P7 resolve_type_under_skill
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'A spell of that family, when sets.midcast.<family> does not exist', fr = 'Quand tu lances un sort de cette famille, si tu n’as pas de set plus précis pour cette famille.',
        base = 'midcast.Enhancing Magic'},
    -- P8 resolve_mode (needs EnhancingMode)
    {'midcast.Enhancing Magic.{EnhancingMode}', when = 'An enhancing spell in that Enhancing Mode, without a set for its family', fr = 'Quand tu lances un sort d’Enhancing Magic avec cet Enhancing Mode, si sa famille n’a pas de set.',
        base = 'midcast.Enhancing Magic'},

    ---------------------------------------------------------------- Healing (RDM_MIDCAST.lua midcast_healing)
    -- select_set{skill='Healing Magic'}: P0, P1, P8b, P9 only (common lines).
    -- Then sets.midcast.CureSelf on top for a Cure (not a Curaga) cast on yourself.
    {'midcast.CureSelf', when = 'Casting a Cure (not a Curaga) on yourself: on top of the cure set', fr = 'Quand tu lances une Cure (pas une Curaga) sur toi-même : mis par-dessus ton set de Cure.'},
    -- Then shared/utils/whm/cure_manager.lua lay_mp_conservation (RDM_CURE_CONFIG mp_conservation_below)
    {'midcast.CureMPConservation', when = 'A Cure or Curaga while your MP is under mp_conservation_below of RDM_CURE_CONFIG.lua: on top of the cure set', fr = 'Quand tu lances une Cure ou une Curaga avec ton MP sous le seuil mp_conservation_below de RDM_CURE_CONFIG.lua : mis par-dessus ton set de Cure.'},

    ---------------------------------------------------------------- Elemental (RDM_MIDCAST.lua midcast_elemental)
    -- select_set{skill='Elemental Magic', mode_state=NukeMode}
    -- P0 resolve_exact_spell
    {'midcast.{spell:Elemental Magic}.{NukeMode}', when = 'Casting that nuke in that Nuke Mode (read only when sets.midcast.<spell> exists)', fr = 'Quand tu lances ce nuke avec ce Nuke Mode, si tu as un set au nom du sort.',
        base = 'midcast.{spell}'},
    -- P8 resolve_mode
    {'midcast.Elemental Magic.{NukeMode}', when = 'A nuke in that Nuke Mode (read only when sets.midcast.Elemental Magic exists)', fr = 'Quand tu lances un nuke avec ce Nuke Mode, si tu as un set Elemental Magic.',
        base = 'midcast.Elemental Magic'},

    -- Dark Magic (midcast_dark, select_set{skill='Dark Magic'}): P0, P1, P8b, P9 only, no line of its own.

    -- Subjob magic (midcast_fallback.lua route), Utsusemi included: the common lines.
}
