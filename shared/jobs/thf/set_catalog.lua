---============================================================================
--- Set Catalog (THF) - the set names the Thief code reads
---============================================================================
--- What THF's own code reads on top of shared/utils/atelier/set_catalog_common.lua
--- (format: shared/utils/atelier/set_catalog.lua): the HybridMode idle and
--- engaged sets, the Aftermath sets, the Sneak Attack / Trick Attack overlays
--- and weaponskill variants, the Treasure Hunter versions of those, the
--- Abyssea weapons and the RangeLock pull set.
---
--- @file    shared/jobs/thf/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    ---------------------------------------------------------------- idle
    -- shared/utils/set_building/base_set_builder.lua select_idle_base (THF SetBuilder.select_idle_base):
    -- outside town, sets.idle[HybridMode] replaces Mote's idle set
    {'idle.{HybridMode}', when = 'Standing outside town with that Hybrid Mode', base = 'idle', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- engaged (logic/set_builder.lua select_engaged_base)
    -- 1. shared/utils/equipment/weapon_aftermath.lua set: sets.engaged[<MainWeapon> .. 'AFM3'] while Aftermath (272/273) is up
    {'engaged.{MainWeapon}AFM3', when = 'Fighting with that Main Weapon while its Aftermath is up, whatever the Hybrid Mode', base = {'engaged.{HybridMode}', 'engaged'},
        needs = {'state:MainWeapon'}},
    -- 2. Vajra with Aftermath Lv.3 (buff 272) and no sets.engaged.VajraAFM3
    {'engaged.PDTAFM3', when = 'Fighting with Vajra under Aftermath Lv.3 (when sets.engaged.VajraAFM3 is missing), whatever the Hybrid Mode',
        base = {'engaged.{HybridMode}', 'engaged'}, needs = {'state:MainWeapon', 'absent:engaged.VajraAFM3'}},
    -- 3. sets.engaged[HybridMode], else Mote's engaged set
    {'engaged.{HybridMode}', when = 'Fighting with that Hybrid Mode', base = 'engaged', needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- weapons
    -- set_builder.lua apply_weapon: with Aby Proc on, sets[AbyWeapon] instead of the Main / Sub Weapon sets
    {'{AbyWeapon}', when = 'Aby Proc on: that Aby Weapon value, laid on the idle and engaged sets in place of Main / Sub Weapon',
        needs = {'state:AbyWeapon'}},

    ---------------------------------------------------------------- Sneak Attack / Trick Attack (set_builder.lua apply_sata_buff)
    -- engaged only, while the buff is up or just used (_G.thf_sa_pending / thf_ta_pending); replaced by the
    -- TreasureHunterSA/TA/SATA set below when Treasure Mode is SATA or Full and that set exists
    {'buff.Sneak Attack', when = 'Fighting with Sneak Attack up: laid over the engaged set'},
    {'buff.Trick Attack', when = 'Fighting with Trick Attack up: laid over the engaged set'},

    ---------------------------------------------------------------- Treasure Hunter
    -- shared/utils/equipment/treasure_hunter.lua wants_engaged_th / action overlay; THF lays it in set_builder.lua step 4
    {'TreasureHunter', when = 'Treasure Mode Full, or Tag / SATA against a mob not tagged yet: on the engaged set and on actions against it',
        needs = {'state:TreasureMode'}},
    -- logic/treasure_hunter.lua sata_overlay: Treasure Mode SATA or Full, in place of sets.buff
    {'TreasureHunterSA', when = 'Treasure Mode SATA or Full, fighting with Sneak Attack up: in place of sets.buff[\'Sneak Attack\']',
        base = 'buff.Sneak Attack', needs = {'state:TreasureMode'}},
    {'TreasureHunterTA', when = 'Treasure Mode SATA or Full, fighting with Trick Attack up: in place of sets.buff[\'Trick Attack\']',
        base = 'buff.Trick Attack', needs = {'state:TreasureMode'}},
    {'TreasureHunterSATA', when = 'Treasure Mode SATA or Full, fighting with Sneak Attack and Trick Attack up: in place of both sets.buff',
        base = {'buff.Sneak Attack', 'buff.Trick Attack'}, needs = {'state:TreasureMode'}},

    ---------------------------------------------------------------- weaponskills (logic/sa_ta_manager.lua apply_variant, from job_post_precast)
    -- read under sets.precast.WS[spell.name] only: nothing when that weaponskill has no set of its own
    {'precast.WS.{ws}.SA', when = 'That weaponskill with Sneak Attack up (and Trick Attack up when .SATA is missing)',
        base = 'precast.WS.{ws}'},
    {'precast.WS.{ws}.TA', when = 'That weaponskill with Trick Attack up (and Sneak Attack up when .SATA and .SA are missing)',
        base = 'precast.WS.{ws}'},
    {'precast.WS.{ws}.SATA', when = 'That weaponskill with Sneak Attack and Trick Attack up',
        base = {'precast.WS.{ws}.SA', 'precast.WS.{ws}.TA', 'precast.WS.{ws}'}},

    ---------------------------------------------------------------- ranged (logic/range_lock.lua pull_set, Mote get_precast_set / get_midcast_set)
    {'RangeLock', when = '//gs c range: the ranged weapon and ammo put on and locked before the shot (needs a range piece)',
        base = 'precast.RA', needs = {'state:RangeLock'}},
    {'precast.RA', when = 'Starting a ranged attack; //gs c range takes its range and ammo when sets.RangeLock is missing'},
    {'midcast.RA', when = 'During a ranged attack', base = 'precast.RA'},

    ---------------------------------------------------------------- spells (THF_MIDCAST.lua job_post_midcast)
    -- Ninjutsu, Healing Magic: select_set with the skill only (P0, P1, P8b, P9): the common lines (Utsusemi included).
    -- Enhancing Magic: database_func ENHANCING_MAGIC_DATABASE.get_spell_family (P6 root, P7 under the skill); target_func
    -- gives 'Composure' only with the RDM main job's Composure (shared/data/job_abilities/rdm/rdm_mainjob.lua): no target levels
    {'midcast.{type:Enhancing Magic}', when = 'Any enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Any enhancing spell of that family, no family set at the root',
        base = 'midcast.Enhancing Magic', needs = {'skill:Enhancing Magic'}},

    -- No WeaponskillMode: support_tier.lua reads the tiers on sets.precast.WS[ws] only (the common {ws} line); the sets
    -- under it are the .SA / .TA / .SATA variants, equipped as they are by sa_ta_manager.lua
    skip = {'precast.WS.{set:precast.WS}.{Group|Solo|Trust}'},
}
