---============================================================================
--- Set Catalog (common) - the set names every job reads
---============================================================================
--- The names Mote-Include and the shared systems read on any job, for the
--- Atelier's "+ Set" (format: shared/utils/atelier/set_catalog.lua). A job's
--- own names, and the ones it builds differently (its idle and engaged sets,
--- its spell families), are in shared/jobs/<job>/set_catalog.lua; a line the
--- job never reads is in that file's `skip`.
---
--- Sources: Mote's choices as docs/dev/systems/precast-pipeline.md
--- ("Precast set name resolution") and midcast-and-buffs.md ("Mote's own
--- choice") describe them; MidcastManager's chain (P0 exact name, P1 tier-less
--- name, P9 skill: shared/utils/midcast/midcast_manager.lua); the systems below
--- each line. Player page: docs/user/guides/sets.md.
---
--- @file    shared/utils/atelier/set_catalog_common.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-06
---============================================================================

return {
    ---------------------------------------------------------------- idle, moving, town
    {'idle', when = 'Standing, not fighting'},
    -- shared/utils/set_building/base_set_builder.lua (select_idle_base_town, lay_town_set)
    {'idle.Town', when = 'Idle in a town (Dynamis excluded), laid on top of the idle set', base = 'idle'},
    {'Adoulin', when = 'Idle in Western / Eastern Adoulin, before sets.idle.Town, laid on top of the idle set'},
    -- base_set_builder.lua apply_movement
    {'MoveSpeed', when = 'Running outside a town, not fighting: on top of the idle set'},
    {'resting', when = 'Resting (/heal)'},
    {'engaged', when = 'Weapon out, fighting'},

    ---------------------------------------------------------------- Fast Cast (Mote get_precast_set)
    {'precast.FC', when = 'Casting any spell (Fast Cast); also forced on warp spells', needs = {'spells'}},
    {'precast.FC.{skill}', when = 'Casting a spell of that skill', base = 'precast.FC'},
    -- Mote finds a Fast Cast set by the spell's exact name, then its spell map (Mote-Mappings: Cure, Utsusemi...), then
    -- its skill, then its type: never by the name without its tier
    {'precast.FC.{spellmap}', when = 'Casting any spell of that group (Mote\'s spell map)', base = {'precast.FC.{spellmap.skill}', 'precast.FC'}},
    {'precast.FC.{spell}', when = 'Casting that spell', base = {'precast.FC.{spell.skill}', 'precast.FC'}},
    {'precast.FC.{spelltype}', when = 'Casting a spell of that type, while no Fast Cast set matches its name, group or skill', base = 'precast.FC'},
    {'precast.FC.{CastingMode~Normal}', when = 'Casting with that Casting Mode (applied to the Fast Cast set chosen)', base = 'precast.FC',
        needs = {'spells'}},

    ---------------------------------------------------------------- abilities (Mote get_precast_set)
    {'precast.JA.{ja}', when = 'Using that job ability'},
    {'precast.{abilitytype}', when = 'Using any ability of that kind (Waltz, Step, CorsairRoll...)'},
    {'precast.{ability.type}.{ability}', when = 'Using that ability', base = 'precast.{ability.type}'},
    -- with no sets.precast.<type>, Mote looks the ability up under JA
    {'precast.JA.{ability}', when = 'Using that ability (read only while sets.precast.<its kind> does not exist)',
        needs = {'absent:precast.{ability.type}'}},

    ---------------------------------------------------------------- weaponskills
    {'precast.WS', when = 'Any weaponskill without its own set'},
    {'precast.WS.{ws}', when = 'That weaponskill', base = {'precast.WS.{ws.skill}', 'precast.WS'}},
    -- Mote: no set by the weaponskill's name -> its combat skill, then sets.precast.WS
    {'precast.WS.{wsskill}', when = 'Any weaponskill of that weapon type without its own set', base = 'precast.WS'},
    {'precast.WS.{ws}.{WeaponskillMode}', when = 'That weaponskill with that Weaponskill Mode', base = 'precast.WS.{ws}'},
    -- shared/utils/party/support_tier.lua (wraps Mote get_weaponskill_set; Solo falls back to Group)
    {'precast.WS.{Group|Solo|Trust}', when = 'Any weaponskill without its own set, with less support in your zone', base = 'precast.WS'},
    {'precast.WS.{ws}.{Group|Solo|Trust}', when = 'That weaponskill with less support in your zone (Group: one of BRD/COR/GEO; Solo: none; Trust: trusts only)',
        base = {'precast.WS.{ws}'}},
    {'precast.WS.{set:precast.WS}.{Group|Solo|Trust}', when = 'That set with less support in your zone (Group: one of BRD/COR/GEO; Solo: none; Trust: trusts only)',
        base = 'precast.WS.{set}'},
    -- shared/utils/party/support_tier.lua SupportTier.engaged: every engaged set the job picks
    {'engaged.{set:engaged}.{Group|Solo|Trust}', when = 'That engaged set with less support in your zone (same tiers as the weaponskills)',
        base = 'engaged.{set}'},

    ---------------------------------------------------------------- spells (Mote get_midcast_set, MidcastManager P0 / P1 / P9)
    {'midcast.FastRecast', when = 'Put on first at the start of every spell, under the spell\'s own set', needs = {'spells'}},
    {'midcast.{skill}', when = 'Any spell of that skill'},
    -- MidcastManager P1 (read while sets.midcast[skill] exists, before the mode and family sets of the job); Mote never
    -- reads the name without its tier
    {'midcast.{spellbase}', when = 'Any tier of that spell, over the job\'s mode and family sets (read while the skill\'s set exists)',
        base = 'midcast.{spellbase.skill}'},
    -- Mote's spell map at the root (Mote get_midcast_set), then MidcastManager P8b at the root and under the skill
    {'midcast.{spellmap}', when = 'Any spell of that group (Mote\'s spell map), when no set matches its name', base = 'midcast.{spellmap.skill}'},
    {'midcast.{spellmap.skill}.{spellmap}', when = 'Any spell of that group, when the root has no set for it (read while the skill\'s set exists)',
        base = 'midcast.{spellmap.skill}', needs = {'absent:midcast.{spellmap}'}},
    {'midcast.{spell}', when = 'That spell', base = {'midcast.{spell.base}', 'midcast.{spell.skill}'}},
    -- MidcastManager P1 [skill][base]: every spell goes through select_set (the job's, or
    -- shared/utils/midcast/midcast_fallback.lua), which reads nothing while sets.midcast[skill] is missing
    -- (P1 reads [base] at the root first: under the skill only while the root has none)
    {'midcast.{spellbase.skill}.{spellbase}', when = 'Any tier of that spell (read while the skill\'s set exists)', base = 'midcast.{spellbase.skill}',
        needs = {'absent:midcast.{spellbase}'}},
    {'midcast.{spellplain.skill}.{spellplain}', when = 'That spell (read while the skill\'s set exists)', base = 'midcast.{spellplain.skill}',
        needs = {'absent:midcast.{spellplain}'}},
    -- Mote's spell map Utsusemi (Ichi, Ni, San): precast under FC, midcast at the root (MidcastManager P8b)
    {'precast.FC.Utsusemi', when = 'Casting any Utsusemi', base = {'precast.FC.Ninjutsu', 'precast.FC'}, needs = {'spell:Utsusemi: Ichi'}},
    {'midcast.Utsusemi', when = 'Casting any Utsusemi', base = 'midcast.Ninjutsu', needs = {'spell:Utsusemi: Ichi'}},
    {'midcast.Ninjutsu.Utsusemi', when = 'Casting any Utsusemi (read while sets.midcast.Ninjutsu exists and sets.midcast.Utsusemi does not)',
        base = 'midcast.Ninjutsu', needs = {'spell:Utsusemi: Ichi', 'absent:midcast.Utsusemi'}},

    ---------------------------------------------------------------- put on by the shared systems
    -- shared/utils/debuff/doom_manager.lua
    {'buff.Doom', when = 'You are Doomed: neck, rings and belt stay locked until Doom is gone'},
    -- shared/utils/equipment/dual_wield.lua (engaged only, after the job's set)
    {'DW.{NoHaste|Haste|HasteII|MaxHaste}', when = 'Two weapons held, fighting: Dual Wield pieces by your magic haste', needs = {'dw'}},
    -- shared/utils/equipment/weapon_resolver.lua
    {'SingleWield', when = 'A weapon set holds an off-hand weapon you cannot dual wield: only its sub is read',
        needs = {'state:MainWeapon'}},
    -- shared/utils/core/combat_mode.lua
    {'CombatMode', when = 'Turning Combat Mode On: put on, then held by the weapon lock', needs = {'state:CombatMode'}},
    -- shared/utils/equipment/treasure_hunter.lua
    {'TreasureHunter', when = 'Treasure Mode on, against a mob not tagged yet'},
    -- base_set_builder.lua lay_weapons / weapon_resolver.lua
    {'{MainWeapon}', when = 'That Main Weapon value: laid on the idle and engaged sets', needs = {'state:MainWeapon'}},
    {'{SubWeapon}', when = 'That Sub Weapon value: laid on the idle and engaged sets', needs = {'state:SubWeapon'}},
}
