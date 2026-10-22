---============================================================================
--- Set Catalog (WAR) - the set names WAR's own code reads
---============================================================================
--- What WAR adds to shared/utils/atelier/set_catalog_common.lua, for the
--- Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua).
---
--- Sources: shared/jobs/war/functions/logic/set_builder.lua (engaged / idle),
--- shared/jobs/war/functions/WAR_MIDCAST.lua (MidcastManager calls),
--- shared/utils/midcast/midcast_fallback.lua (every other skill),
--- shared/utils/set_building/base_set_builder.lua (select_idle_base).
--- WAR_PRECAST.lua leaves the job ability, Fast Cast and weaponskill sets to
--- Mote (common lines).
---
--- The Kraken Club set of a club put in the off hand by hand,
--- sets.engaged[<MainWeapon> .. 'KC'], is offered through the MainWeapon values
--- that name it (NaeglingKC, LoxoticKC: the {MainWeapon} line); {MainWeapon}KC
--- would also offer UkonvasaraKC, NaeglingKCKC..., which a Kraken Club never reaches.
--- The subjob's spells (P1 [skill][base], Utsusemi) are the common lines.
---
--- @file    shared/jobs/war/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    ---------------------------------------------------------------- engaged (set_builder.lua select_engaged_base, first match wins)
    -- kraken_set (a MainWeapon value whose weapon set holds Kraken Club) and select_weapon_engaged
    {'engaged.{MainWeapon}', when = 'Fighting with that Main Weapon (also its Kraken Club set when that weapon set holds the club)', fr = 'Quand tu combats avec cette Main Weapon (c’est aussi son set Kraken Club quand le set de cette arme contient le club).',
        base = 'engaged', needs = {'state:MainWeapon'}},
    -- select_stance_engaged (SubtleBlow / Hoxne) and the HybridMode step
    {'engaged.{HybridMode}', when = 'Fighting with that Hybrid Mode, when the weapon has no set of its own (a stance, SubtleBlow or Hoxne, wins over the weapon set)', fr = 'Quand tu combats avec cet Hybrid Mode, si ton arme n’a pas son propre set (une stance, SubtleBlow ou Hoxne, passe avant le set de l’arme).',
        base = 'engaged', needs = {'state:HybridMode'}},
    -- select_stance_engaged: sets.engaged[mode .. 'AFM3'] under Ukonvasara Aftermath Lv.3
    {'engaged.SubtleBlowAFM3', when = 'Fighting in the SubtleBlow stance with Ukonvasara and Aftermath Lv.3 up', fr = 'Quand tu combats en stance SubtleBlow avec Ukonvasara et Aftermath Lv.3 actif.',
        base = 'engaged.SubtleBlow', needs = {'value:HybridMode=SubtleBlow'}},
    {'engaged.HoxneAFM3', when = 'Fighting in the Hoxne stance with Ukonvasara and Aftermath Lv.3 up', fr = 'Quand tu combats en stance Hoxne avec Ukonvasara et Aftermath Lv.3 actif.',
        base = 'engaged.Hoxne', needs = {'value:HybridMode=Hoxne'}},
    -- weapon_am3_set (shared/utils/equipment/weapon_aftermath.lua): sets.engaged[<MainWeapon> .. 'AFM3']
    {'engaged.{MainWeapon}AFM3', when = 'Fighting with that Main Weapon while its Aftermath is up (Aftermath Set AFM3)', fr = 'Quand tu combats avec cette Main Weapon et que son Aftermath est actif.',
        base = {'engaged.{MainWeapon}', 'engaged'}, needs = {'state:MainWeapon'}},

    ---------------------------------------------------------------- idle (base_set_builder.lua select_idle_base)
    {'idle.{HybridMode}', when = 'Standing outside a town with that Hybrid Mode', fr = 'Quand tu ne combats pas, hors de la ville, avec cet Hybrid Mode.', base = 'idle', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- spells (subjob magic)
    -- WAR_MIDCAST.lua Enhancing Magic: database_func EnhancingSPELLS.get_spell_family (P6 root, P7 under the skill)
    {'midcast.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Any Enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)', fr = 'Quand tu lances un sort d’Enhancing Magic de cette famille, si tu n’as pas de set plus précis pour cette famille.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
}
