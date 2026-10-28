---============================================================================
--- Set Catalog (DRK) - the set names DRK's own code reads
---============================================================================
--- What DRK adds to shared/utils/atelier/set_catalog_common.lua, for the
--- Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/drk/functions/logic/set_builder.lua (engaged / idle /
--- weapon), shared/jobs/drk/functions/logic/drk_buff_anticipation.lua (Dark
--- Seal / Nether Void engaged variants), shared/jobs/drk/functions/DRK_MIDCAST.lua
--- (MidcastManager calls, buff layers), shared/utils/equipment/weapon_aftermath.lua,
--- shared/utils/set_building/base_set_builder.lua (select_idle_base).
--- DRK_PRECAST.lua equips sets.precast.JA[name] and sets.precast.FC itself, the
--- names Mote reads too (common lines). The subjob's spells (P1 [skill][base],
--- Utsusemi) are common lines.
---
--- @file    shared/jobs/drk/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-28
---============================================================================

return {
    ---------------------------------------------------------------- engaged (set_builder.lua select_engaged_base, first match wins)
    -- 0. weapon_aftermath.lua: sets.engaged[<MainWeapon> .. 'AFM3'] while that weapon's Aftermath is up
    {'engaged.{MainWeapon}AFM3', when = 'Fighting with that Main Weapon while its Aftermath is up, whatever the Hybrid Mode', fr = 'Quand tu combats avec cette Main Weapon et que son Aftermath est actif, quel que soit l’Hybrid Mode.',
        base = {'engaged.{HybridMode}', 'engaged'}, needs = {'state:MainWeapon'}},
    -- 1. Liberator with Aftermath Lv.3 (buff 272), when sets.engaged.LiberatorAFM3 is missing
    {'engaged.AM3', when = 'Fighting with Liberator under Aftermath Lv.3 (when sets.engaged.LiberatorAFM3 is missing), whatever the Hybrid Mode', fr = 'Quand tu combats avec Liberator sous Aftermath Lv.3, si tu n’as pas de set engaged.LiberatorAFM3, quel que soit l’Hybrid Mode.',
        base = {'engaged.{HybridMode}', 'engaged'}, needs = {'state:MainWeapon', 'absent:engaged.LiberatorAFM3'}},
    -- 2. / 3. sets.engaged.PDT / sets.engaged.Accu, else sets.engaged
    {'engaged.{HybridMode}', when = 'Fighting with that Hybrid Mode (PDT, Accu)', fr = 'Quand tu combats avec cet Hybrid Mode (PDT, Accu).', base = 'engaged', needs = {'state:HybridMode'}},
    -- drk_buff_anticipation.lua apply_buff_variants: on top of the engaged set, read under
    -- sets.engaged[<MainWeapon>][<HybridMode>] (else [<MainWeapon>].Accu); DarkSealNetherVoid falls back to DarkSeal, then NetherVoid
    {'engaged.{MainWeapon}.{HybridMode}.{DarkSeal|NetherVoid|DarkSealNetherVoid}', when = 'Fighting with that Main Weapon and Hybrid Mode, Dark Seal / Nether Void (or both) up or just used: on top of the engaged set', fr = 'Quand tu combats avec cette Main Weapon et cet Hybrid Mode, avec Dark Seal, Nether Void (ou les deux) actif ou tout juste utilisé : mis par-dessus ton set engaged.',
        base = {'engaged.{HybridMode}', 'engaged'}, needs = {'state:MainWeapon', 'state:HybridMode'}},

    ---------------------------------------------------------------- idle (base_set_builder.lua select_idle_base)
    {'idle.{HybridMode}', when = 'Standing outside a town with that Hybrid Mode', fr = 'Quand tu ne combats pas, hors de la ville, avec cet Hybrid Mode.', base = 'idle', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- Dark Magic (DRK_MIDCAST.lua job_post_midcast_dark_magic)
    -- MidcastManager with a skill of its own: 'Dread Spikes' for that spell, 'Absorb' for every Absorb-*
    {'midcast.Dread Spikes', when = 'Casting Dread Spikes (in place of the Dark Magic set)', fr = 'Quand tu lances Dread Spikes (à la place de ton set Dark Magic).', base = 'midcast.Dark Magic', needs = {'spell:Dread Spikes'}},
    {'midcast.Absorb', when = 'Casting any Absorb spell (in place of the Dark Magic set)', fr = 'Quand tu lances un sort Absorb (à la place de ton set Dark Magic).', base = 'midcast.Dark Magic', needs = {'skill:Dark Magic'}},
    -- on top of the Dark Magic set chosen: Dark Seal on every Dark Magic spell, Nether Void on Absorb / Drain / Aspir
    {'buff.Dark Seal', when = 'Casting Dark Magic with Dark Seal up: on top of the spell\'s set', fr = 'Quand tu lances un sort de Dark Magic avec Dark Seal actif : mis par-dessus le set du sort.', needs = {'skill:Dark Magic'}},
    {'buff.Nether Void', when = 'Casting Absorb, Drain or Aspir with Nether Void up: on top of the spell\'s set', fr = 'Quand tu lances Absorb, Drain ou Aspir avec Nether Void actif : mis par-dessus le set du sort.', needs = {'skill:Dark Magic'}},
}
