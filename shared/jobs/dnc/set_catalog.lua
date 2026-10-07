---============================================================================
--- Set Catalog (DNC) - the set names DNC's own code reads
---============================================================================
--- What DNC adds to shared/utils/atelier/set_catalog_common.lua, for the
--- Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/dnc/functions/logic/set_builder.lua (engaged / idle /
--- weapons), shared/jobs/dnc/functions/logic/ws_variant_selector.lua (called
--- from DNC_PRECAST.lua job_post_precast), shared/jobs/dnc/functions/DNC_MIDCAST.lua
--- (MidcastManager calls), shared/utils/midcast/midcast_fallback.lua (every
--- other skill), shared/utils/set_building/base_set_builder.lua (select_idle_base).
--- Steps, Waltzes, Sambas, Jigs, Flourishes, weaponskills and the subjob's
--- spells (P1 [skill][base], Utsusemi) are common lines.
---
--- @file    shared/jobs/dnc/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    -- ws_variant_selector.lua equips a dance / Climactic version (.SaberDance, .Clim...) as it is: the support tier
    -- (shared/utils/party/support_tier.lua) is applied to Mote's pick only, never to those
    skip = {'precast.WS.{set:precast.WS}.{Group|Solo|Trust}'},

    ---------------------------------------------------------------- engaged (set_builder.lua select_engaged_base)
    -- Priority 1: Saber Dance up
    {'engaged.SaberDance', when = 'Fighting with Saber Dance up', base = 'engaged'},
    {'engaged.SaberDance.PDT', when = 'Fighting with Saber Dance up, Hybrid Mode PDT', base = 'engaged.SaberDance',
        needs = {'state:HybridMode'}},
    -- Priority 2: HybridMode PDT with Fan Dance up
    {'engaged.FanDance', when = 'Fighting with Fan Dance up, Hybrid Mode PDT', base = 'engaged.PDT', needs = {'state:HybridMode'}},
    -- HybridMode step (PDT is read even when absent: no fallback to the base set)
    {'engaged.{HybridMode}', when = 'Fighting with that Hybrid Mode, no dance up', base = 'engaged', needs = {'state:HybridMode'}},
    -- build_engaged_set: laid on top while Saber Dance is up
    {'buff.Saber Dance', when = 'Fighting with Saber Dance up: on top of the engaged set'},

    ---------------------------------------------------------------- idle (base_set_builder.lua select_idle_base)
    {'idle.{HybridMode}', when = 'Standing outside a town with that Hybrid Mode', base = 'idle', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- weapons (set_builder.lua apply_weapon)
    -- only its sub is read, laid over the Main Weapon set's sub
    {'{SubWeaponOverride~Off}', when = 'That Sub Override value: its sub replaces the Main Weapon set\'s sub, idle and engaged',
        needs = {'state:SubWeaponOverride'}},

    ---------------------------------------------------------------- weaponskills (ws_variant_selector.lua best_variant)
    -- read only when sets.precast.WS[<ws>] exists; dance + Climactic: <dance>.Clim, else <dance>, else Clim
    {'precast.WS.{ws}.{SaberDance|FanDance}', when = 'That weaponskill with that dance up', base = 'precast.WS.{ws}'},
    {'precast.WS.{ws}.Clim', when = 'That weaponskill under Climactic Flourish', base = 'precast.WS.{ws}'},
    {'precast.WS.{ws}.{SaberDance|FanDance}.Clim', when = 'That weaponskill with that dance up and Climactic Flourish',
        base = {'precast.WS.{ws}.{SaberDance|FanDance}', 'precast.WS.{ws}.Clim', 'precast.WS.{ws}'}},
    -- apply_variant: on top of the weaponskill set under Climactic Flourish
    {'buff.Climactic Flourish', when = 'Weaponskill under Climactic Flourish: on top of the weaponskill set'},

    ---------------------------------------------------------------- spells (subjob magic)
    -- DNC_MIDCAST.lua Enhancing Magic: database_func EnhancingSPELLS.get_spell_family (P6 root, P7 under the skill)
    {'midcast.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
}
