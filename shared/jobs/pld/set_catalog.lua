---============================================================================
--- Set Catalog (PLD) - the set names the Paladin code reads
---============================================================================
--- What PLD's own code reads on top of shared/utils/atelier/set_catalog_common.lua
--- (format: shared/utils/atelier/set_catalog.lua). The stances are HybridMode:
--- PDT / MDT / Sortie on most subjobs, PDT / MDT / DPS / Tanking / Hoxne under
--- /SCH and /RUN (_master/config/pld/PLD_STATES.lua STANCE_SUBJOBS). The set a
--- stance wears is not always named after it (set_builder.lua
--- ENGAGED_SET_BY_MODE / IDLE_SET_BY_MODE), hence the literal names below.
---
--- @file    shared/jobs/pld/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

-- Every subjob but the stance ones (/SCH, /RUN): they get the PDT / MDT / Sortie stances
local CLASSIC_SUBS = 'sub:WAR|MNK|WHM|BLM|RDM|THF|DRK|BST|BRD|RNG|SAM|NIN|DRG|SMN|BLU|COR|PUP|DNC|GEO|NONE'

return {
    ---------------------------------------------------------------- idle
    -- logic/set_builder.lua build_idle_set step 5 (IDLE_SET_BY_MODE: PDT -> idle.PDT, every other stance -> idle.MDT),
    -- laid on Mote's idle outside town; in town only its sub is read (apply_shield)
    {'idle.PDT', when = 'Standing outside town, stance PDT (in town: only its shield is used)', base = 'idle',
        needs = {'state:HybridMode'}},
    {'idle.MDT', when = 'Standing outside town, stance MDT, Sortie, DPS, Tanking or Hoxne (in town: only its shield is used)',
        base = 'idle', needs = {'state:HybridMode'}},
    -- set_builder.lua build_idle_set step 6 (outside town)
    {'idleXp', when = 'Xp On, standing outside town: laid over the stance\'s idle set', needs = {'state:Xp'}},
    -- set_builder.lua build_idle_set step 6b (Regen is forced Off outside /SCH and /RUN: PLD_STATES.lua install_profile)
    {'idleRegen', when = 'Regen On (/SCH, /RUN), standing outside town: laid over the idle set',
        needs = {'state:Regen', 'sub:SCH|RUN'}},

    ---------------------------------------------------------------- engaged
    -- set_builder.lua select_engaged_base priority 3 (ENGAGED_SET_BY_MODE), Mote's engaged set when missing
    {'engaged.PDT', when = 'Fighting, stance PDT', base = 'engaged', needs = {'state:HybridMode'}},
    {'engaged.MDT', when = 'Fighting, stance MDT, or Tanking (/SCH, /RUN)', base = 'engaged', needs = {'state:HybridMode'}},
    {'engaged.TP', when = 'Fighting, stance Sortie', base = 'engaged', needs = {'state:HybridMode', CLASSIC_SUBS}},
    {'engaged.DPS', when = 'Fighting, stance DPS (/SCH, /RUN)', base = 'engaged', needs = {'state:HybridMode', 'sub:SCH|RUN'}},
    {'engaged.Hoxne', when = 'Fighting, stance Hoxne (/SCH, /RUN): the ammo slot then stays on Hoxne Ampulla',
        base = 'engaged', needs = {'state:HybridMode', 'sub:SCH|RUN'}},
    -- set_builder.lua select_engaged_base priorities 1-2 (before the stance's set)
    {'engaged.BurtgangKC', when = 'Fighting with Main Weapon BurtgangKC, or with a Kraken Club in the off hand, whatever the stance',
        base = 'engaged'},
    -- set_builder.lua build_engaged_set step 4
    {'meleeXp', when = 'Xp On, fighting: laid over the engaged set', needs = {'state:Xp'}},

    ---------------------------------------------------------------- weapons
    -- set_builder.lua apply_weapon: sets[weapon] read directly (no WeaponResolver, so no SingleWield and no SubWeapon);
    -- the weapon is PLD_WEAPONS.lua stance_weapon[stance] when the character's file sets one, else Main Weapon
    {'{MainWeapon}', when = 'That Main Weapon value: laid on the idle and engaged sets (a stance with its own weapon in PLD_WEAPONS.lua uses that one)',
        needs = {'state:MainWeapon'}},

    ---------------------------------------------------------------- enmity (logic/enmity_override.lua)
    -- is_active / apply_precast / apply_midcast: stance Sortie (classic subjobs) or Tanking (/SCH, /RUN)
    {'EnmityMax', when = 'Stance Sortie or Tanking: job abilities add the pieces where it differs from FullEnmity; spells whose set is FullEnmity itself are cast in it',
        base = 'FullEnmity', needs = {'state:HybridMode'}},
    -- uses_full_enmity (identity test) and enmity_max_extra (the slots EnmityMax changes)
    {'FullEnmity', when = 'Not worn by name: in Sortie / Tanking, EnmityMax only adds the slots where it differs from this set',
        needs = {'state:HybridMode'}},

    ---------------------------------------------------------------- precast
    -- PLD_PRECAST.lua job_post_precast: Cure III / Cure IV on yourself, over Mote's Fast Cast set
    {'precast.FC.CureSelf', when = 'Casting Cure III or Cure IV on yourself: put on over the Fast Cast set',
        base = {'precast.FC.Cure', 'precast.FC.Healing Magic', 'precast.FC'}},
    -- PLD_PRECAST.lua apply_sch_ws_set: PLDStates.stance_subjob() (PLD_STATES.lua) = /SCH or /RUN in DPS, Tanking or Hoxne
    {'precast.WS.SCH.{ws}', when = 'That weaponskill under /SCH or /RUN in stance DPS, Tanking or Hoxne: put on over its normal set',
        base = {'precast.WS.{ws}', 'precast.WS'}, needs = {'sub:SCH|RUN', 'state:HybridMode'}},

    ---------------------------------------------------------------- cures (PLD_MIDCAST.lua job_midcast, logic/cure_set_builder.lua generate)
    {'midcast.CureSelf', when = 'Cure, Cure II, Cure III or Cure IV on yourself', base = {'midcast.Cure', 'midcast.Healing Magic'}},
    {'midcast.CureOther', when = 'Cure, Cure II, Cure III or Cure IV on someone else', base = {'midcast.Cure', 'midcast.Healing Magic'}},
    -- Mote by spell map, and MidcastManager P1 [base] below: read only while CureSelf / CureOther is missing
    {'midcast.Cure', when = 'Cure to Cure IV, only on a target whose CureSelf / CureOther set is missing', base = 'midcast.Healing Magic'},
    -- Mote by name / MidcastManager P0: the same condition (job_midcast sets eventArgs.handled otherwise)
    {'midcast.{Cure II|Cure III|Cure IV}', when = 'That Cure, only on a target whose CureSelf / CureOther set is missing',
        base = {'midcast.Cure', 'midcast.Healing Magic'}},

    ---------------------------------------------------------------- Healing Magic (PLD_MIDCAST.lua midcast_healing, target_func Self / Other)
    -- P9
    {'midcast.Healing Magic', when = 'Any healing spell (Raise, -na...) and a Cure whose CureSelf / CureOther set is missing'},
    -- P5 [skill][target], [target]
    {'midcast.Healing Magic.{Self|Other}', when = 'A healing spell on yourself / someone else (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = 'midcast.Healing Magic'},
    {'midcast.{Self|Other}', when = 'A healing spell on yourself / someone else, with no Self / Other set under Healing Magic (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = 'midcast.Healing Magic'},
    -- P1 (paths tried in this order, the target ones before sets.midcast.Cure): Cure to Cure IV reach it only
    -- while CureSelf / CureOther is missing; plain Cure is caught first by P0 sets.midcast.Cure when that exists
    {'midcast.Cure.Self', when = 'Cure II-IV on yourself while CureSelf is missing (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = {'midcast.Cure', 'midcast.Healing Magic'}, needs = {'absent:midcast.CureSelf'}},
    {'midcast.Cure.Other', when = 'Cure II-IV on someone else while CureOther is missing (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = {'midcast.Cure', 'midcast.Healing Magic'}, needs = {'absent:midcast.CureOther'}},
    {'midcast.Self.Cure', when = 'Cure to Cure IV on yourself while CureSelf is missing, no sets.midcast.Cure.Self (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = {'midcast.Cure', 'midcast.Healing Magic'}, needs = {'absent:midcast.CureSelf'}},
    {'midcast.Other.Cure', when = 'Cure to Cure IV on someone else while CureOther is missing, no sets.midcast.Cure.Other (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = {'midcast.Cure', 'midcast.Healing Magic'}, needs = {'absent:midcast.CureOther'}},
    {'midcast.Healing Magic.Cure.Self', when = 'Cure to Cure IV on yourself while CureSelf is missing, no Cure.Self / Self.Cure at the root (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = 'midcast.Healing Magic', needs = {'absent:midcast.CureSelf'}},
    {'midcast.Healing Magic.Cure.Other', when = 'Cure to Cure IV on someone else while CureOther is missing, no Cure.Other / Other.Cure at the root (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = 'midcast.Healing Magic', needs = {'absent:midcast.CureOther'}},
    {'midcast.Healing Magic.Self.Cure', when = 'Cure to Cure IV on yourself while CureSelf is missing, no Cure.Self / Self.Cure at the root (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = 'midcast.Healing Magic', needs = {'absent:midcast.CureSelf'}},
    {'midcast.Healing Magic.Other.Cure', when = 'Cure to Cure IV on someone else while CureOther is missing, no Cure.Other / Other.Cure at the root (read only when sets.midcast[\'Healing Magic\'] exists)',
        base = 'midcast.Healing Magic', needs = {'absent:midcast.CureOther'}},
    -- P1 [skill][base]: after sets.midcast.Cure
    {'midcast.Healing Magic.Cure', when = 'Cure to Cure IV on a target whose CureSelf / CureOther set is missing, while sets.midcast.Cure is missing too',
        base = 'midcast.Healing Magic', needs = {'absent:midcast.Cure'}},

    -- P1 [skill][base] for the other tiered healing spells (Curaga...): the common line

    ---------------------------------------------------------------- enmity spells
    -- PLD_MIDCAST.lua midcast_flash (skill 'Flash': the set is its own base), caught before Divine Magic
    {'midcast.Flash', when = 'Casting Flash'},
    -- PLD_MIDCAST.lua midcast_enlight (skill 'Enmity'): P9, then P1 [skill][base]
    {'midcast.Enmity', when = 'Casting Enlight or Enlight II without a set of its own'},
    {'midcast.Enmity.Enlight', when = 'Enlight / Enlight II while sets.midcast.Enlight is missing (read only when sets.midcast.Enmity exists)',
        base = 'midcast.Enmity', needs = {'absent:midcast.Enlight'}},

    ---------------------------------------------------------------- Phalanx (PLD_MIDCAST.lua midcast_phalanx)
    {'midcast.SIRDPhalanx', when = 'Casting Phalanx with Phalanx SIRD On or Xp On: replaces the Phalanx set', base = 'midcast.Phalanx',
        needs = {'state:PhalanxSIRD'}},
    -- skill 'Phalanx': P0 / P9
    {'midcast.Phalanx', when = 'Casting Phalanx (Phalanx SIRD and Xp Off, or no SIRDPhalanx set)'},

    ---------------------------------------------------------------- Enhancing Magic (PLD_MIDCAST.lua midcast_enhancing)
    -- database_func ENHANCING_MAGIC_DATABASE.get_spell_family; target_func get_enhancing_target gives 'Composure'
    -- only with the RDM main job's Composure (shared/data/job_abilities/rdm/rdm_mainjob.lua): no target levels on PLD
    {'midcast.Enhancing Magic', when = 'Any enhancing spell (but Phalanx) without a set of its own'},
    -- P1 [skill][base] (Protect, Shell, Regen...): the common line
    -- P6 [type]
    {'midcast.{type:Enhancing Magic}', when = 'Any enhancing spell of that family (read only when sets.midcast[\'Enhancing Magic\'] exists)',
        base = 'midcast.Enhancing Magic'},
    -- P7 [skill][type]
    {'midcast.Enhancing Magic.{type:Enhancing Magic}', when = 'Any enhancing spell of that family, no family set at the root',
        base = 'midcast.Enhancing Magic'},

    ---------------------------------------------------------------- Divine Magic (PLD_MIDCAST.lua midcast_divine; Flash and Enlight go above)
    {'midcast.Divine Magic', when = 'Banish, Holy and the other divine spells but Flash and Enlight'},
    -- P1 [skill][base] (Banish, Holy...): the common line

    ---------------------------------------------------------------- Blue Magic (PLD_MIDCAST.lua midcast_blue)
    -- skill 'Cocoon' for Cocoon (its own base), 'Blue Magic' otherwise: P9; P1 [skill][base] is the common
    -- {spellplain} line (no tiers on these)
    {'midcast.Cocoon', when = 'Casting Cocoon', needs = {'sub:BLU'}},
    {'midcast.Blue Magic', when = 'Any blue spell but Cocoon without a set of its own', needs = {'sub:BLU'}},

    -- set_builder.lua apply_weapon reads sets[weapon] itself: no WeaponResolver (SingleWield), no SubWeapon state.
    -- No WeaponskillMode: support_tier.lua reads the tiers on sets.precast.WS[ws] only (the common {ws} line), never
    -- under the sets below it (sets.precast.WS.SCH and its weaponskills are equipped as they are)
    skip = {'SingleWield', '{SubWeapon}', 'precast.WS.{set:precast.WS}.{Group|Solo|Trust}'},
}
