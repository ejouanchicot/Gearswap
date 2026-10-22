---============================================================================
--- Set Catalog (COR) - the set names the Corsair code reads
---============================================================================
--- What COR's own code adds to shared/utils/atelier/set_catalog_common.lua
--- (format: shared/utils/atelier/set_catalog.lua): Phantom Rolls, Quick Draw,
--- Luzaf's Ring, ranged attacks (precast with Flurry, midcast by Ranged Mode,
--- Triple Shot), the idle / engaged layers of its set builder and the range
--- weapon. The rolls are in the ability lists the catalog reads
--- (cor_rolls_mainjob.lua, cor_rolls_subjob.lua, res type CorsairRoll): their
--- sets are the common ability lines. The shots are not: they are named from
--- the QuickDraw state, as COR_COMMANDS.lua builds them (value .. ' Shot').
---
--- @file    shared/jobs/cor/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    ---------------------------------------------------------------- idle, engaged
    -- shared/jobs/cor/functions/logic/set_builder.lua build_idle_set (outside town only)
    {'idle.PDT', when = 'Idle outside town with Hybrid Mode PDT: laid on top of the idle set', fr = 'Quand tu ne combats pas, hors de la ville, avec l’Hybrid Mode sur PDT : mis par-dessus ton set idle.', base = 'idle'},
    {'idle.Refresh', when = 'Idle outside town with MP under 50% (a subjob with MP): laid on top of the idle set', fr = 'Quand tu ne combats pas, hors de la ville, avec moins de 50 % de tes MP (sub job à MP) : mis par-dessus ton set idle.', base = 'idle'},
    -- set_builder.lua build_engaged_set (through SupportTier.engaged: its .Group/.Solo/.Trust come from the common line)
    {'engaged.PDT', when = 'Fighting with Hybrid Mode PDT: laid on top of the engaged set', fr = 'Quand tu combats avec l’Hybrid Mode sur PDT : mis par-dessus ton set engaged.', base = 'engaged'},
    -- set_builder.lua apply_weapon: sets[state.RangeWeapon.current], idle and engaged
    {'{RangeWeapon}', when = 'That Range Weapon value: laid on the idle and engaged sets', fr = 'Avec cette valeur de Range Weapon : mis par-dessus tes sets idle et engaged.', needs = {'state:RangeWeapon'}},

    ---------------------------------------------------------------- Phantom Roll, Double-Up
    -- Mote get_precast_set (type CorsairRoll); COR_PRECAST.lua job_precast_double_up: Double-Up wears
    -- sets.precast.CorsairRoll[<last roll>], else this set (the per-roll sets are the common ability lines)
    {'precast.CorsairRoll', when = 'Any Phantom Roll without its own set; Double-Up after such a roll (a roll with its own set: Double-Up wears that one)', fr = 'Pour tout Phantom Roll sans set à lui, et pour le Double-Up qui suit un tel roll (après un roll qui a son set, Double-Up met celui-là).'},
    -- COR_PRECAST.lua apply_luzaf (job_post_precast), roll and Double-Up
    {'precast.LuzafRing', when = "Phantom Roll or Double-Up with Luzaf Ring ON (default without it: Luzaf's Ring in left_ring)",
        fr = 'Pour un Phantom Roll ou un Double-Up avec Luzaf Ring sur ON (sans ce set, la Luzaf’s Ring est mise en bague gauche).',
        needs = {'state:LuzafRing'}},
    {'precast.LuzafRingOff', when = "Phantom Roll or Double-Up with Luzaf Ring OFF: the ring put on instead of Luzaf's",
        fr = 'Pour un Phantom Roll ou un Double-Up avec Luzaf Ring sur OFF : la bague mise à la place de la Luzaf’s Ring.',
        needs = {'state:LuzafRing'}},
    -- COR_PRECAST.lua hold_fold_gear: the Fold set's slots are kept as worn with fewer than two Busts
    {'precast.JA.Fold', when = 'Using Fold with two Busts up (with fewer, its slots stay as they are)', fr = 'Quand tu utilises Fold avec deux Busts sur toi (avec moins, ses slots restent tels quels).'},

    ---------------------------------------------------------------- Quick Draw
    -- Mote get_precast_set (type CorsairShot) on the shot COR_COMMANDS.lua names from QuickDraw (value .. ' Shot').
    -- No shot is in the ability lists, so the common {abilitytype} / {ability} lines give none of these.
    {'precast.CorsairShot', when = 'Any Quick Draw shot without its own set', fr = 'Pour tout Quick Draw qui n’a pas de set à lui.'},
    {'precast.CorsairShot.{QuickDraw} Shot', when = 'That Quick Draw shot', fr = 'Pour ce Quick Draw.', base = 'precast.CorsairShot', needs = {'state:QuickDraw'}},
    {'precast.JA.{QuickDraw} Shot', when = 'That Quick Draw shot (read only while sets.precast.CorsairShot does not exist)', fr = 'Pour ce Quick Draw, si tu n’as pas de set precast.CorsairShot.',
        needs = {'state:QuickDraw', 'absent:precast.CorsairShot'}},

    ---------------------------------------------------------------- ranged attack
    -- Mote get_precast_set / get_ranged_set: sets.precast.RA, [RangedMode], then classes.CustomRangedGroups
    -- (COR_PRECAST.lua apply_cor_precast -> shared/utils/precast/flurry_tracker.lua apply_ranged_groups)
    {'precast.RA', when = 'Shooting (/ra): Snapshot and Rapid Shot', fr = 'Quand tu tires (/ra) : Snapshot et Rapid Shot.'},
    {'precast.RA.{RangedMode~Normal}', when = 'Shooting with that Ranged Mode', fr = 'Quand tu tires avec ce Ranged Mode.', base = 'precast.RA'},
    {'precast.RA.{Flurry1|Flurry2}', when = 'Shooting under Flurry (Flurry1) or Flurry II (Flurry2)', fr = 'Quand tu tires sous Flurry (Flurry1) ou Flurry II (Flurry2).', base = 'precast.RA'},
    {'precast.RA.{RangedMode~Normal}.{Flurry1|Flurry2}', when = 'Shooting with that Ranged Mode under Flurry / Flurry II', fr = 'Quand tu tires avec ce Ranged Mode, sous Flurry ou Flurry II.',
        base = {'precast.RA.{RangedMode}', 'precast.RA'}},
    -- COR_MIDCAST.lua job_post_midcast: select_set({skill = 'RA', mode_state = state.RangedMode}), P8 then P9
    {'midcast.RA', when = 'The shot itself (/ra): ranged accuracy, attack, Store TP', fr = 'Pendant le tir lui-même (/ra) : ranged accuracy, ranged attack, Store TP.'},
    {'midcast.RA.{RangedMode~Normal}', when = 'The shot with that Ranged Mode (read only when sets.midcast.RA exists)', fr = 'Pendant le tir avec ce Ranged Mode, si tu as un set midcast.RA.', base = 'midcast.RA'},
    -- COR_MIDCAST.lua job_post_midcast: buffactive['Triple Shot'], on top of the ranged set
    {'midcast.RA.TripleShot', when = 'The shot under Triple Shot: laid on top (read only when sets.midcast.RA exists)', fr = 'Pendant le tir sous Triple Shot : mis par-dessus ton set de tir, si tu as un set midcast.RA.', base = 'midcast.RA'},

    ---------------------------------------------------------------- weaponskills
    -- Mote select_specific_set: a weaponskill without a named set falls to its skill
    {'precast.WS.Marksmanship', when = 'A gun weaponskill without its own set', fr = 'Pour une weaponskill de fusil qui n’a pas de set à elle.', base = 'precast.WS'},

    ---------------------------------------------------------------- subjob spells (MidcastManager)
    -- COR_MIDCAST.lua Enhancing: database_func ENHANCING_MAGIC_DATABASE.get_spell_family (P6, P7). P1 [skill][base]
    -- of every skill (COR_MIDCAST.lua, midcast_fallback.lua) is the common line. The target_func gives 'Composure'
    -- only with the RDM main job's Composure (shared/data/job_abilities/rdm/rdm_mainjob.lua): no target levels.
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'An enhancing spell of that family (read only when sets.midcast["Enhancing Magic"] exists)', fr = 'Quand tu lances un sort d’Enhancing de cette famille, si tu as un set Enhancing Magic.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.{type:Enhancing Magic}', when = 'An enhancing spell of that family, before the one under Enhancing Magic (read only when sets.midcast["Enhancing Magic"] exists)', fr = 'Quand tu lances un sort d’Enhancing de cette famille, si tu as un set Enhancing Magic : passe avant celui rangé sous Enhancing Magic.',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},

    -- Common lines COR never reads:
    -- {SubWeapon}: set_builder.lua apply_weapon lays MainWeapon (main + its sub) and RangeWeapon only
    skip = {'{SubWeapon}'},
}
