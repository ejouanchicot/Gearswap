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
    {'idle.{IdleMode}', when = 'Standing, not fighting, in that Idle Mode', base = 'idle'},
    -- select_idle_base: HybridMode PDT, read only while sets.idle.<IdleMode> does not exist
    {'idle.PDT', when = 'Standing with Hybrid Mode PDT, only while the Idle Mode has no set of its own',
        base = 'idle', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- engaged (set_builder.lua build_engaged_set)
    -- set_builder.lua select_engaged_base: sets.engaged[EngagedMode] with a shield / one weapon
    {'engaged.{EngagedMode}', when = 'Fighting in that Engaged Mode, shield or nothing in the off hand', base = 'engaged'},
    -- select_engaged_base: .DW when has_shield_equipped says two weapons (only /NIN, /DNC)
    {'engaged.{EngagedMode}.DW', when = 'Fighting in that Engaged Mode with a weapon in each hand',
        base = {'engaged.{EngagedMode}', 'engaged'}, needs = {'dw'}},
    -- select_engaged_base: HybridMode PDT, read only while sets.engaged.<EngagedMode> does not exist
    {'engaged.PDT', when = 'Fighting with Hybrid Mode PDT, only while the Engaged Mode has no set of its own',
        base = 'engaged', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- Enfeebling (RDM_MIDCAST.lua midcast_enfeebling)
    -- select_set{skill='Enfeebling Magic', mode_state=EnfeebleMode, database_func=get_enfeebling_type}
    -- P0 resolve_exact_spell: the spell's own set, then its EnfeebleMode child
    {'midcast.{spell:Enfeebling Magic}.{EnfeebleMode}', when = 'Casting that enfeeble in that Enfeeble Mode (read only when sets.midcast.<spell> exists)',
        base = 'midcast.{spell}'},
    -- P3 resolve_type_mode
    {'midcast.Enfeebling Magic.{type:Enfeebling Magic}.{EnfeebleMode}', when = 'An enfeeble of that kind in that Enfeeble Mode (read only when sets.midcast.Enfeebling Magic exists)',
        base = {'midcast.Enfeebling Magic.{type}', 'midcast.Enfeebling Magic'}},
    -- P6 resolve_type_root
    {'midcast.{type:Enfeebling Magic}', when = 'An enfeeble of that kind (read only when sets.midcast.Enfeebling Magic exists)',
        base = 'midcast.Enfeebling Magic'},
    -- P7 resolve_type_under_skill
    {'midcast.Enfeebling Magic.{type:Enfeebling Magic}', when = 'An enfeeble of that kind, when sets.midcast.<kind> does not exist',
        base = 'midcast.Enfeebling Magic'},
    -- P8 resolve_mode
    {'midcast.Enfeebling Magic.{EnfeebleMode}', when = 'An enfeeble in that Enfeeble Mode, without a set for its kind',
        base = 'midcast.Enfeebling Magic'},
    -- midcast_enfeebling: laid on top while Saboteur is up
    {'midcast.Enfeebling Magic.Saboteur', when = 'Casting an enfeeble while Saboteur is up: on top of the enfeeble set',
        base = 'midcast.Enfeebling Magic'},

    ---------------------------------------------------------------- Enhancing (RDM_MIDCAST.lua midcast_enhancing)
    -- select_set{skill='Enhancing Magic', mode_state=EnhancingMode, target_func=get_enhancing_target,
    -- database_func=get_spell_family}. The target is 'Composure' (Composure up, target not you) or nothing.
    -- state.EnhancingMode is defined by no config: the {EnhancingMode} lines give nothing until it is.
    -- P0 resolve_exact_spell
    {'midcast.{spell:Enhancing Magic}.{EnhancingMode}', when = 'Casting that spell in that Enhancing Mode (read only when sets.midcast.<spell> exists)',
        base = 'midcast.{spell}'},
    -- P1 resolve_base_name with the Composure target
    {'midcast.' .. COMPOSURE_SPELLS .. '.Composure', when = 'Any tier of that spell on someone else under Composure',
        base = {'midcast.' .. COMPOSURE_SPELLS, 'midcast.Enhancing Magic'}},
    {'midcast.Composure.' .. COMPOSURE_SPELLS, when = 'Any tier of that spell on someone else under Composure (read only when sets.midcast.Enhancing Magic exists)',
        base = 'midcast.Enhancing Magic'},
    {'midcast.Enhancing Magic.' .. COMPOSURE_SPELLS .. '.Composure', when = 'Any tier of that spell on someone else under Composure (read only when sets.midcast.Enhancing Magic exists)',
        base = 'midcast.Enhancing Magic'},
    {'midcast.Enhancing Magic.Composure.' .. COMPOSURE_SPELLS, when = 'Any tier of that spell on someone else under Composure (read only when sets.midcast.Enhancing Magic exists)',
        base = 'midcast.Enhancing Magic'},
    -- P2 resolve_type_target_mode (needs EnhancingMode)
    {'midcast.Enhancing Magic.{type:Enhancing Magic}.Composure.{EnhancingMode}', when = 'A spell of that family on someone else under Composure, in that Enhancing Mode',
        base = 'midcast.Enhancing Magic'},
    -- P3 resolve_type_mode (needs EnhancingMode)
    {'midcast.Enhancing Magic.{type:Enhancing Magic}.{EnhancingMode}', when = 'A spell of that family in that Enhancing Mode',
        base = 'midcast.Enhancing Magic'},
    -- P4 resolve_target_mode (needs EnhancingMode)
    {'midcast.Enhancing Magic.Composure.{EnhancingMode}', when = 'An enhancing spell on someone else under Composure, in that Enhancing Mode',
        base = 'midcast.Enhancing Magic'},
    -- P5 resolve_target: under the skill, then at the root
    {'midcast.Enhancing Magic.Composure', when = 'An enhancing spell on someone else under Composure, without a set of its own',
        base = 'midcast.Enhancing Magic'},
    {'midcast.Composure', when = 'An enhancing spell on someone else under Composure, when sets.midcast.Enhancing Magic.Composure does not exist (read only when sets.midcast.Enhancing Magic exists)',
        base = 'midcast.Enhancing Magic'},
    -- P6 resolve_type_root
    {'midcast.{type:Enhancing Magic}', when = 'A spell of that family (Enspell, Gain, BarElement...) (read only when sets.midcast.Enhancing Magic exists)',
        base = 'midcast.Enhancing Magic'},
    -- P7 resolve_type_under_skill
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'A spell of that family, when sets.midcast.<family> does not exist',
        base = 'midcast.Enhancing Magic'},
    -- P8 resolve_mode (needs EnhancingMode)
    {'midcast.Enhancing Magic.{EnhancingMode}', when = 'An enhancing spell in that Enhancing Mode, without a set for its family',
        base = 'midcast.Enhancing Magic'},

    ---------------------------------------------------------------- Healing (RDM_MIDCAST.lua midcast_healing)
    -- select_set{skill='Healing Magic'}: P0, P1, P8b, P9 only (common lines).
    -- Then sets.midcast.CureSelf on top for a Cure (not a Curaga) cast on yourself.
    {'midcast.CureSelf', when = 'Casting a Cure (not a Curaga) on yourself: on top of the cure set'},

    ---------------------------------------------------------------- Elemental (RDM_MIDCAST.lua midcast_elemental)
    -- select_set{skill='Elemental Magic', mode_state=NukeMode}
    -- P0 resolve_exact_spell
    {'midcast.{spell:Elemental Magic}.{NukeMode}', when = 'Casting that nuke in that Nuke Mode (read only when sets.midcast.<spell> exists)',
        base = 'midcast.{spell}'},
    -- P8 resolve_mode
    {'midcast.Elemental Magic.{NukeMode}', when = 'A nuke in that Nuke Mode (read only when sets.midcast.Elemental Magic exists)',
        base = 'midcast.Elemental Magic'},

    -- Dark Magic (midcast_dark, select_set{skill='Dark Magic'}): P0, P1, P8b, P9 only, no line of its own.

    -- Subjob magic (midcast_fallback.lua route), Utsusemi included: the common lines.
}
