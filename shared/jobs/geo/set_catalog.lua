---============================================================================
--- Set Catalog (GEO) - the set names Geomancer's own code reads
---============================================================================
--- What the GEO code adds to shared/utils/atelier/set_catalog_common.lua, for
--- the Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/geo/functions/logic/set_builder.lua (idle, engaged:
--- sets.me.* without a luopan, sets.luopan.* with one, Mote's sets.idle /
--- sets.engaged discarded), shared/jobs/geo/functions/GEO_MIDCAST.lua (one
--- MidcastManager.select_set per skill, chain levels in
--- shared/utils/midcast/midcast_manager.lua RESOLVERS),
--- shared/utils/midcast/midcast_fallback.lua (any other skill), states in
--- _master/config/geo/GEO_STATES.lua. GEO_PRECAST.lua leaves the job ability,
--- Fast Cast and weaponskill sets to Mote (common lines).
---
--- MidcastManager.select_set returns without equipping anything when
--- sets.midcast[<skill>] does not exist: every level under a skill below is
--- read only while that skill's set exists.
---
--- @file    shared/jobs/geo/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    -- set_builder.lua replaces Mote's base idle / engaged set: sets.idle and sets.engaged themselves are never worn
    skip = {'idle', 'engaged'},

    ---------------------------------------------------------------- idle (set_builder.lua build_idle_set)
    -- select_hybrid_base fallback, and the luopan's fallback
    {'me.idle', when = 'Standing, no luopan out, when the Hybrid Mode has no idle set'},
    -- select_hybrid_base(sets.idle, sets.me.idle)
    {'idle.{HybridMode}', when = 'Standing, no luopan out, in that Hybrid Mode', base = 'me.idle', needs = {'state:HybridMode'}},
    {'luopan.idle', when = 'Standing with a luopan out (pet survival)', base = 'me.idle'},
    -- base_set_builder.lua select_idle_base_town: on top of whichever idle above (sets.me.idle.Town is not read)
    {'idle.Town', when = 'Idle in a town (Dynamis excluded), laid on top of the idle set', base = {'me.idle'}},

    ---------------------------------------------------------------- engaged (set_builder.lua build_engaged_set)
    {'me.engaged', when = 'Fighting, no luopan out, when the Hybrid Mode has no engaged set; also with a luopan when sets.luopan.engaged.DT is missing'},
    {'engaged.{HybridMode}', when = 'Fighting, no luopan out, in that Hybrid Mode', base = 'me.engaged', needs = {'state:HybridMode'}},
    -- LuopanMode DT, and the fallback of any other value
    {'luopan.engaged.DT', when = 'Fighting with a luopan out, Luopan Mode DT (also when the DPS set is missing)', base = 'me.engaged'},
    {'luopan.engaged.DPS', when = 'Fighting with a luopan out, Luopan Mode DPS', base = {'luopan.engaged.DT', 'me.engaged'},
        needs = {'state:LuopanMode'}},
    -- shared/utils/party/support_tier.lua SupportTier.engaged on the set chosen above
    {'me.engaged.{Group|Solo|Trust}', when = 'That engaged set with less support in your zone (same tiers as the weaponskills)',
        base = 'me.engaged'},
    {'luopan.engaged.{DT|DPS}.{Group|Solo|Trust}', when = 'That engaged set with less support in your zone (same tiers as the weaponskills)',
        base = 'luopan.engaged.{DT|DPS}'},

    ---------------------------------------------------------------- Geomancy (GEO_MIDCAST.lua midcast_geomancy)
    -- select_set{skill='Geomancy', database_func=geomancy_family ('Indi' / 'Geo')}
    -- P1 resolve_base_name {skill, base}: the common {spellplain} line (Indi- / Geo- names have no tier)
    -- P6 resolve_type_root
    {'midcast.{Indi|Geo}', when = 'Any Indi- (or Geo-) spell without a set of its own (read only when sets.midcast.Geomancy exists)',
        base = 'midcast.Geomancy'},
    -- P7 resolve_type_under_skill
    {'midcast.Geomancy.{Indi|Geo}', when = 'Any Indi- (or Geo-) spell, when sets.midcast.Indi (or .Geo) does not exist',
        base = 'midcast.Geomancy'},
    -- midcast_geomancy: instead of the chain, read only when sets.midcast.Indi exists
    {'midcast.Indi.Entrust', when = 'An Indi- spell cast on a party member while Entrust is up (or just used): replaces the Geomancy set',
        base = 'midcast.Indi'},

    ---------------------------------------------------------------- Enhancing (GEO_MIDCAST.lua job_post_midcast)
    -- select_set{skill='Enhancing Magic', target_func=get_enhancing_target, database_func=get_spell_family}, no mode.
    -- The target is 'Composure' only with the RDM main job's Composure (shared/data/job_abilities/rdm/rdm_mainjob.lua,
    -- main_job_only): no target levels on GEO.
    -- P6 resolve_type_root
    {'midcast.{type:Enhancing Magic}', when = 'An enhancing spell of that family (read only when sets.midcast.Enhancing Magic exists)',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    -- P7 resolve_type_under_skill
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'An enhancing spell of that family, when sets.midcast.<family> does not exist',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},

    -- Healing, Enfeebling, Elemental, Dark (PLAIN_SKILLS, select_set{skill, spell}): P0, P1, P8b, P9 only.

    -- Subjob magic (midcast_fallback.lua route), Utsusemi included: the common lines.
}
