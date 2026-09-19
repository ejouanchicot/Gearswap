# Precast pipeline, weaponskills and debuff guard

This page covers everything that runs between the moment GearSwap intercepts an
outgoing `/ma`, `/ja`, `/ws` or `/item` command and the moment precast gear is
sent: the debuff guard (`PrecastGuard` + `DebuffChecker` + automatic cure items),
the recast check (`CooldownChecker` + `RECAST_CONFIG`), the pre-action ability
trigger (`AbilityHelper`), the weaponskill chain (`WSPrecastHandler` ->
`WSValidator` -> `WeaponSkillManager`, TP-bonus gear), the tier downgrade engine
(`TierRefiner`), the WAR weaponskill slots (`WSSlots`) and the Doom slot lock
(`DoomManager`). The modules are loaded lazily by every job's
`[JOB]_PRECAST.lua` (`ensure_modules_loaded()`), `DoomManager` by
`LifecycleManager`, and `AutoMedicine` by every job's `[JOB]_STATES.lua` plus
`INIT_SYSTEMS.lua`.

All line references are to the code as of 2026-09-18, including the
changes to `precast_guard.lua`, `auto_medicine.lua` and
`DEBUFF_AUTOCURE_CONFIG.lua` committed as `b89d7d6`. Every file listed below was read in full.

## Files

| Path | Lines | Role |
|------|------:|------|
| `shared/utils/debuff/precast_guard.lua` | 493 | PrecastGuard: routes by `spell.type`, cancels blocked actions, sends Echo Drops/Remedy/Panacea |
| `shared/utils/debuff/debuff_checker.lua` | 294 | Blocking-debuff tables (production and test mode) and lookups |
| `shared/utils/debuff/auto_medicine.lua` | 210 | `state.AutoMedicine` On/Off, persisted in `windower._auto_medicine`, `//gs c am` |
| `shared/utils/debuff/doom_manager.lua` | 201 | Equips `sets.buff.Doom`, locks neck/ring1/ring2/waist, unlocks on removal or death |
| `shared/config/DEBUFF_AUTOCURE_CONFIG.lua` | 70 | Auto-cure switches, cure item lists, test mode |
| `shared/utils/precast/cooldown_checker.lua` | 136 | CooldownChecker: ability and spell recast checks with tolerance |
| `_master/config_global/RECAST_CONFIG.lua` | 98 | Recast tolerance (2.0 s) and global `is_recast_ready` / `is_on_cooldown` |
| `shared/utils/precast/ability_helper.lua` | 138 | AbilityHelper: fire a JA, then re-send the spell/WS after a wait |
| `shared/utils/precast/ws_precast_handler.lua` | 84 | WSPrecastHandler: validation, TP gear, TP >= 1000 check, TP gear application |
| `shared/utils/precast/ws_validator.lua` | 35 | Thin wrapper over WeaponSkillManager (range + Amnesia) |
| `shared/utils/weaponskill/weaponskill_manager.lua` | 145 | Range formula and Amnesia check; exported as `_G.WeaponSkillManager` |
| `shared/utils/precast/tp_bonus_handler.lua` | 71 | Internal: computes TP gear into `_G.temp_tp_bonus_gear` |
| `shared/utils/weaponskill/tp_bonus_calculator.lua` | 276 | Pure TP-threshold arithmetic; exported as `_G.TPBonusCalculator` |
| `shared/utils/weaponskill/ws_slots.lua` | 141 | WAR `//gs c ws1..ws9`: weaponskill slots rebuilt per weapon |
| `shared/utils/precast/tier_refiner.lua` | 225 | TierRefiner: cast the highest tier whose recast and MP allow it |

Sampled job files used to document the contract: `shared/jobs/dnc/functions/DNC_PRECAST.lua`
(216), `shared/jobs/blm/functions/BLM_PRECAST.lua` (186),
`shared/jobs/brd/functions/BRD_PRECAST.lua` (294). PLD and RDM precast files were
read for the AbilityHelper and TierRefiner call sites.

## How it works

### Where precast comes from

1. GearSwap intercepts the outgoing command and calls `refresh_globals()`
   without a user-event flag (`GearSwap/triggers.lua:89`), so `player`,
   `player.vitals` and `buffactive` are refreshed from `windower.ffxi.get_player()`
   before any user code runs.
2. `filter_pretarget` (`GearSwap/helper_functions.lua:661`) drops spells the
   player does not know, and job abilities/weaponskills not listed in
   `windower.ffxi.get_abilities()`.
3. GearSwap builds the `spell` table. Two fields matter for routing here:
   - `spell.type` comes from the resource: `WhiteMagic`, `BlackMagic`, `BardSong`,
     `Ninjutsu`, `SummonerPact`, `BlueMagic`, `Geomancy`, `Trust` for spells;
     `JobAbility`, `PetCommand`, `CorsairRoll`, `CorsairShot`, `Samba`, `Waltz`,
     `Step`, `Flourish1-3`, `Jig`, `Scholar`, `Rune`, `Ward`, `Effusion`,
     `BloodPactRage`, `BloodPactWard`, `Monster` for abilities; `WeaponSkill`
     (`GearSwap/statics.lua:80`), `Item` (`GearSwap/triggers.lua:126`), `Misc`
     for `/ra`. **No spell ever has `spell.type == 'Magic'`.**
   - `spell.action_type` comes from the command prefix
     (`GearSwap/statics.lua:33-35`): `Magic`, `Ability` (this includes `/ws`),
     `Item`, `Ranged Attack`, `Trade`.
4. Mote's `handle_actions` (`GearSwap/libs/Mote-Include.lua:227`) calls
   `job_precast` (line 254). If `eventArgs.cancel` is set, Mote calls
   `cancel_spell()` and skips the rest. If only `eventArgs.handled` is set,
   Mote skips `default_precast` (line 263) but still runs `user_post_precast`
   (line 269, the message hooks in `shared/hooks/init_ability_messages.lua` and
   `init_ws_messages.lua`) and `job_post_precast` (line 274).
5. Gear placed with `equip()` during precast is sent even when the action is
   cancelled: GearSwap processes `equip_list` before `equip_sets_exit`
   (`GearSwap/flow.lua:115-170`).

### The job_precast contract

Every job's `job_precast` follows this order (DNC shown; BLM, BRD and WHM deviate as
noted below, RDM under [TierRefiner](#tierrefiner-sharedutilsprecasttier_refinerlua)):

```mermaid
flowchart TD
    A["job_precast(spell, action, spellMap, eventArgs)"] --> B["ensure_modules_loaded()"]
    B --> C{"PrecastGuard.guard_precast"}
    C -- "blocked (cancel set)" --> X["return"]
    C -- "not blocked" --> D{"spell.action_type"}
    D -- "Ability" --> E["CooldownChecker.check_ability_cooldown"]
    D -- "Magic" --> F["CooldownChecker.check_spell_cooldown"]
    E --> G{"eventArgs.cancel?"}
    F --> G
    D -- "other" --> G
    G -- yes --> X
    G -- no --> H["job logic: auto-abilities, refinement, Samba TP, ..."]
    H --> I{"WSPrecastHandler.handle"}
    I -- "false (cancelled)" --> X
    I -- "true" --> J["job-specific precast gear"]
    J --> K["Mote default_precast (unless handled)"]
    K --> L["user_post_precast hooks"]
    L --> M["job_post_precast: WSPrecastHandler.apply_tp_gear"]
```

- DNC (`DNC_PRECAST.lua:144-184`): guard (148), cooldown by `action_type` with
  Utsusemi Ichi/Ni excluded from the spell check (153-159), cancel check (161),
  Samba TP check against `spell.tp_cost`, skipped under Trance (166), Climactic
  timestamp (171), Jump and Climactic auto-triggers for weaponskills (176,
  `job_precast_weaponskill` 118-137), then `WSPrecastHandler.handle` for every
  action (181; it returns `true` for non-WS).
  Post-precast applies the WS variant then the TP gear (195-210).
- BLM (`BLM_PRECAST.lua:132-159`): guard (135), then `check_recast_or_refine`
  (104-119): abilities are cooldown-checked unless listed in
  `BLM_SPELL_FILTERS.CHARGE_ABILITIES`; tiered spells go to
  `refine_various_spells` (BLM's own refiner, which calls
  `TierRefiner.find_available_tier`); other spells take the plain spell check.
- BRD (`BRD_PRECAST.lua:183-228`): guard (186), then `SongRefinement` **before**
  the cooldown check (190-205; BLM, RDM and WHM depart from the order for the
  same reason), Pianissimo and Marcato replacement, cooldown (207-213), cancel
  check (215), WS handler (219), instrument lock (225).
- WHM (`WHM_PRECAST.lua:111-143`): guard (114), then `retier_cure` (121,
  helper 77-94) **before** the cooldown check: a Cure/Curaga that
  `CureManager.select_cure_tier` swaps for another tier is cancelled and re-sent
  under the new name, and `job_precast` returns; a cure left as it is (every
  tier on recast included) goes on to the cooldown check (125-131), cancel
  check (132), self-Paralyna under paralysis (136), WS handler (140). See
  [factories and helpers](factories-and-helpers.md#whm-curemanager).

The five-line `action_type` dispatch in front of `CooldownChecker` is repeated in
all 16 `[JOB]_PRECAST.lua` files; `CooldownChecker` itself has no dispatcher.

### PrecastGuard routing

`PrecastGuard.guard_precast` (`precast_guard.lua:454-471`) dispatches on
`spell.type`:

| `spell.type` | Handler | Debuffs checked (`debuff_checker.lua`) | Auto-cure |
|---|---|---|---|
| `WeaponSkill` | `check_ws` (398) | universal + amnesia/impairment/paralysis (116-120) | none; if the highest-priority hit is paralysis the WS is let through (412-414) |
| `JobAbility`, `Ability`, `PetCommand` | `check_ja` (343) | universal + amnesia/impairment/paralysis (102-106) | paralysis -> Remedy, Panacea |
| `Magic` | `check_magic` (287) | universal + silence/mute/omerta | never reached, see gotchas |
| `Item` | `check_item` (429) | universal + encumbrance (122-124) | none |
| anything else (all real spells, CorsairRoll, Waltz, Samba, Step, Flourish, Jig, Scholar, Rune, Ward, Effusion, Blood Pacts, Monster, `/ra`) | `check_and_block` (191) with `spell.action_type` | `Magic` -> magic list; `Ability` -> JA list; `Ranged Attack` -> universal only (228-233) | `Magic`+silence -> Echo Drops, Remedy; `Ability`+paralysis -> Remedy, Panacea |

Universal debuffs (checked first for every list, `debuff_checker.lua:109-114`):
stun, sleep, petrification, terror. Within a list the lowest `priority` wins
(`get_active_blocking_debuff`, 135-155), so Amnesia (1) hides Paralysis (3) and no
Remedy is spent on an action Amnesia would still block.

When a guard blocks, it sets `eventArgs.cancel = true` and prints one of
`MessageDebuffs.show_spell_blocked / show_ja_blocked / show_ws_blocked /
show_item_blocked / show_action_blocked`
(`shared/utils/messages/formatters/magic/message_debuffs.lua:27-140`).

### Automatic cure items

```mermaid
flowchart TD
    A["blocked by silence (Magic) or paralysis (Ability)"] --> B{"auto_cure_* in config AND AutoMedicine.is_enabled()"}
    B -- no --> Z["cancel + plain blocked message"]
    B -- yes --> C{"cure_pending(): os.clock() < cure_lock_until"}
    C -- yes --> D{"item in flight is in this debuff's list?"}
    D -- yes --> P["CURE_PENDING: cancel silently"]
    D -- no --> Q["CURE_BUSY: cancel + plain blocked message"]
    C -- no --> E{"first listed item present in inventory?"}
    E -- yes --> S["lock 3.0 s, send 'wait 0.4; input /item X <me>', success message; CURE_SENT: cancel"]
    E -- no --> N["CURE_NONE: cancel + 'no cure item' message"]
```

- `try_cure_debuff` (`precast_guard.lua:137-165`) walks the configured list in
  order and uses the first item with `count > 0` in the main inventory
  (`has_item_in_inventory`, 57-71). Wardrobes and other bags are not searched.
- The lock is one module-level timestamp for every debuff
  (`cure_lock_until`, 99) plus the name of the item in flight (`cure_in_flight`,
  102). `CURE_LOCK_DURATION = 3.0` (86), `CURE_INPUT_DELAY = 0.4` (92).
- The four outcomes (`CURE_SENT`, `CURE_PENDING`, `CURE_BUSY`, `CURE_NONE`,
  107-110) are what fixed the 2026-09-18 audit's P2-2: with Silence and
  Paralysis together, Echo Drops in flight no longer swallow a JA silently; the
  JA gets the plain blocked message (`CURE_BUSY`, 264-268, 327, 382). A Remedy in
  flight does cure both, so it answers `CURE_PENDING` for either debuff.
- The cure item is itself sent through `input /item`, so it goes through
  GearSwap precast and `PrecastGuard.check_item` like any other item.
- AutoMedicine Off does not unblock the action (`precast_guard.lua:241-243`,
  `auto_medicine.lua:7-11`): it only stops the item use.

### Recast check

`CooldownChecker.check_ability_cooldown` (`cooldown_checker.lua:76-110`):

1. `recast_id` from `spell.recast_id`, else `MANUAL_RECAST_IDS` (empty, 72-74).
   Weaponskills have no `recast_id`, so a WS passed here returns immediately.
2. Skips names in `MULTI_CHARGE_ABILITIES` (30-69).
3. Returns without checking while `_G.suppress_cooldown_messages` is truthy (92).
4. Reads seconds via `MessageFormatter.get_ability_recast_seconds`
   (`message_cooldowns.lua:70-76`, `windower.ffxi.get_ability_recasts()`),
   applies `RECAST_CONFIG.on_cooldown` (tolerance) and, if on cooldown, prints
   `show_ability_cooldown` and sets `eventArgs.cancel`.

`check_spell_cooldown` (112-135) reads `windower.ffxi.get_spell_recasts()`
(centiseconds), divides by 100 for the tolerance test and passes centiseconds to
`show_spell_cooldown`.

The tolerance comes from `local RECAST_CONFIG = _G.RECAST_CONFIG or {}`, captured
once when the module is first executed (17). With `ModuleCache` installed
(`INIT_SYSTEMS.lua:47-52`) that first execution is the lazy `require` in the job's
`ensure_modules_loaded()`, which happens after the entry point has set
`_G.RECAST_CONFIG`. Without `RECAST_CONFIG` the checker falls back to
`recast > 0` (25) and AbilityHelper to `recast < 1` (`ability_helper.lua:12`).

### AbilityHelper

`try_ability` / `try_ability_smart` / `try_ability_ws`
(`ability_helper.lua:79-136`) all do the same thing when the helper ability is
"usable", ready (tolerance applies) and its buff is not up: `cancel_spell()`,
then one `send_command` that chains the JA, a `wait`, and the original action
again (`/ma "<spell>" <target id>` or `/ws "<ws>" <t>`). The re-sent action goes
through the whole precast pipeline again; by then the buff is normally up and
the helper does nothing.

| Caller | Helper ability | Trigger |
|---|---|---|
| `PLD_PRECAST.lua:85-104` | Divine Emblem (`try_ability`) | Flash |
| `PLD_PRECAST.lua:85-104` | Majesty (`try_ability_smart`) | Protect III/IV/V, Cure III/IV |
| `RDM_PRECAST.lua:217-247` | Saboteur (`try_ability_smart`) | enfeebles in `RDMSaboteurConfig.auto_trigger_spells` when `state.SaboteurMode` is On |
| `dnc/functions/logic/climactic_manager.lua:75` | Climactic Flourish (`try_ability_ws`, 1 s) | configured WS, `player.tp >= min_tp`, target HP above `min_target_hpp`, and 3 or more Finishing Moves: any of the buffs `Finishing Move 3`, `4`, `5`, `(6+)` (`FINISHING_MOVES_3_PLUS`, `:32-37`, tested at `:45-52`) |

`try_ability` and `try_ability_smart` set `eventArgs.handled` but not
`eventArgs.cancel`, so the job's `job_precast` keeps running after them and Mote
still calls `user_post_precast` and `job_post_precast`. `try_ability_ws` sets
both.

`can_use_ability` (34-63) is meant to validate job and level through
`ability_data.levels`, but Windower's `res.job_abilities` entries carry no
`levels` field, so it returns `true` for any ability that exists (43-45).

### Weaponskill chain

```mermaid
sequenceDiagram
    participant J as "job_precast"
    participant H as "WSPrecastHandler.handle"
    participant V as "WSValidator.validate"
    participant M as "WeaponSkillManager"
    participant T as "TPBonusHandler / TPBonusCalculator"
    participant P as "job_post_precast"
    J->>H: spell, eventArgs, _G.<JOB>TPConfig or {}
    H->>V: validate(spell, eventArgs)
    V->>M: check_weaponskill_range(spell)
    M->>M: validate_weaponskill (Amnesia) then range formula
    V->>M: validate_weaponskill(spell.name) again
    V-->>H: false -> eventArgs.cancel, cancel_spell()
    H->>T: calculate_tp_gear(spell, tp_config)
    T-->>H: _G.temp_tp_bonus_gear = gear or nil
    H->>H: player.vitals.tp < 1000 -> cancel + "Not enough TP"
    H-->>J: true / false
    P->>H: apply_tp_gear(spell)
    H->>P: equip(_G.temp_tp_bonus_gear), clear it
```

- `WSPrecastHandler.ensure_modules_loaded` (`ws_precast_handler.lua:14-33`)
  loads MessageFormatter, WSValidator and TPBonusHandler. It loads no WS
  database; only the WS message hook reads one
  ([messages](messages.md)).
- `ws_validator.lua:6` `include()`s `weaponskill_manager.lua`, which sets
  `_G.WeaponSkillManager` (`weaponskill_manager.lua:144`). With ModuleCache the
  validator (and so the include) runs once per sandbox.
- Range formula (`weaponskill_manager.lua:82-89`):
  `target.model_size + spell.range * 1.55 < target.distance` cancels. GearSwap
  gives `target.distance` in yalms (square root applied at
  `GearSwap/targets.lua:111-112`). If `spell.range`, `target.distance` or
  `target.model_size` is not a number the WS is cancelled without a message
  (75-80, messages only in `debug_mode`).
- `validate_weaponskill` (111-141) only checks `buffactive['Amnesia']`; its
  comment (122-123) says TP validation was removed because of lag.
  `WSPrecastHandler.handle` nevertheless cancels below 1000 TP
  (`ws_precast_handler.lua:52-64`) using `player.vitals.tp`.
- `WeaponSkillManager.MessageFormatter` (17) is never assigned, so the range and
  Amnesia errors always use the `MessageWeaponskill` fallbacks (99, 135).

### TP bonus gear

`TPBonusHandler.calculate_tp_gear` (`tp_bonus_handler.lua:39-69`) reads
`player.vitals.tp`, `player.equipment.main/sub` and `buffactive`, calls
`TPBonusCalculator.calculate` and stores the result in `_G.temp_tp_bonus_gear`.
`WSPrecastHandler.apply_tp_gear` (`ws_precast_handler.lua:69-82`) equips and
clears it in `job_post_precast`; DNC applies its WS variant first so the TP piece
is not overwritten (`DNC_PRECAST.lua:198-209`).

`TPBonusCalculator.calculate` (`tp_bonus_calculator.lua:159-207`):

1. Effective TP = current TP + `get_weapon_bonus(main)` + `get_warcry_bonus()`
   (only if `buffactive['Warcry']`) + `get_hagakure_bonus()` (the config checks
   the buff itself) + `get_fencer_bonus(main, sub)` (71-91).
2. Next threshold from `config.thresholds = {2000, 3000}` (44, 96-103); none
   above 3000 -> nil.
3. Pieces sorted by bonus descending (108-121). If the gap exceeds the sum -> nil.
4. `pieces_for_gap` (131-157): first single piece whose bonus covers the gap
   (the largest, since the list is sorted), else the greedy largest-first
   combination.

TP bonus from pieces already in the WS set is not part of step 1; only the
unused `get_final_tp` (216-271) counts equipped pieces.

TP config schema (per job, `Tetsouo/config/<job>/<JOB>_TP_CONFIG.lua`, loaded
into `_G.<JOB>TPConfig` by the entry point): `pieces = { {slot, name, bonus}, ... }`
plus optional `get_weapon_bonus(weapon)`, `get_warcry_bonus()`,
`get_hagakure_bonus()`, `get_fencer_bonus(weapon, sub)`. The BLM config
(`_master/config/blm/BLM_TP_CONFIG.lua:21-24`) defines `moonshade = {name, tp_bonus}`
instead of `pieces`, which the calculator does not read.

### Tier refinement

`TierRefiner.refine(spell, eventArgs, correspondence)` (`tier_refiner.lua:200-223`):

1. Returns `false` within `REPLACEMENT_COOLDOWN = 0.2 s` of the last replacement
   (36, 204), so the re-sent replacement is not refined again.
2. Parses `spell.name` with `(%a+)%s*(%a*)` into category and tier (209).
3. `find_available_tier` (57-85) walks `correspondence[tier].replace` for at
   most `MAX_STEPS = 8` steps and returns the first tier with recast exactly 0
   and `player.mp >= mp_cost` (no tolerance here).
4. A different tier -> `execute_replacement` (171-187): stamp, send
   `wait 0.1; @input /ma "<new>" <target.raw>`, cancel, `show_spell_refinement`.
5. Same tier -> `show_unavailable` (136-158): if the requested spell's recast is
   0 the cast is let through (MP failures are left to the server); otherwise
   cancel and print the requested spell plus every lower tier's recast through
   `MessageCooldowns.show_multi_status`.

Callers: RDM `stage_cooldown` (`RDM_PRECAST.lua:151-165`) for families in
`shared/data/spells/RDM_ENFEEBLE_TIERS.lua` (instead of the cooldown check);
BLM `replacement_logic.lua:56-58` uses `find_available_tier` only. BLM keeps its
own copies of the recast display and replacement
(`blm/functions/logic/refiner/recast_display.lua:40`,
`special_handlers.lua:90`).

### WSSlots (WAR)

`WSSlots.sync(weapon_state, config)` (`ws_slots.lua:94-108`) matches the equipped
main/sub to a `state.MainWeapon` option (`detect_weapon`, 63-85), then
`rebuild` (40-55) recreates `state.WS1..WS<max_slots>` as Mote modes listing that
weapon's weaponskills. Called from `Tetsouo/config/war/WAR_STATES.lua:72-76`
and from `WAR_COMMANDS.lua` `job_state_change` when `MainWeapon` changes.
`WSSlots.cast(i)` (125-139) sends `input /ws "<name>" <t>`, which then goes
through the normal WS precast.

### Doom

`DoomManager.handle_buff_change(buff, gain)` (`doom_manager.lua:75-122`) acts
only on `buff == 'doom'` (GearSwap passes `res.buffs[id].english`, lowercase
`doom`). It reads `buffactive['doom']` rather than `gain`. Doomed: equip
`sets.buff.Doom` **then** `disable('neck','ring1','ring2','waist')` (the order
matters: `disable` is honoured at `equip()` time, `GearSwap/helper_functions.lua:319-326`).
Not doomed: `enable` the four slots and `handle_equipping_gear(player.status)`.
It returns `true` for any doom event, which makes `LifecycleManager.buff_change`
skip the job's own handler.

`handle_status_change` (131-160) re-enables the four slots on entering `Dead`
and on leaving it, re-equipping for the new status if Doom is gone.

Every job wires both through `LifecycleManager` (`shared/utils/core/lifecycle_manager.lua:38-58`)
or its own `[JOB]_BUFFS.lua` / `[JOB]_STATUS.lua` (DRK, GEO, SMN, THF, WAR).

GearSwap's `disable_table` is a GearSwap global (`GearSwap/statics.lua:194`)
that `load_user_files` does not reset, so a Doom lock survives `gs reload` and
job changes until something calls `enable`.

## Public API

### PrecastGuard (`shared/utils/debuff/precast_guard.lua`)

| Function | Returns | Side effects | Callers |
|---|---|---|---|
| `guard_precast(spell, eventArgs)` (454) | `true` if blocked | may set `eventArgs.cancel`, send a cure item, print | first step of all 16 `[JOB]_PRECAST.lua` |
| `check_and_block(spell, eventArgs)` (191) | blocked | same | `guard_precast` fallback |
| `check_magic(spell, eventArgs)` (287) | blocked | same | `guard_precast` only, unreachable |
| `check_ja(spell, eventArgs)` (343) | blocked | same | `guard_precast` |
| `check_ws(spell, eventArgs)` (398) | blocked | cancel + message | `guard_precast` |
| `check_item(spell, eventArgs)` (429) | blocked | cancel + message | `guard_precast` |
| `would_block(action_type)` (482) | blocked, debuff name | none | no caller |
| `get_active_blocks()` (489) | list | none | no caller |

### DebuffChecker (`shared/utils/debuff/debuff_checker.lua`)

`check_magic_blocked()`, `check_ja_blocked()`, `check_ws_blocked()`,
`check_item_blocked()` (182-208) each return `blocked, debuff_name, message`.
`check_action_blocked(action_type)` (215-236) dispatches on
`"Magic"`, `"Ability"/"JobAbility"/"PetCommand"`, `"WeaponSkill"/"Weaponskill"`,
`"Item"`, `"Ranged"` (GearSwap never produces `"Ranged"`; `/ra` is
`"Ranged Attack"` and falls to universal-only). `get_all_active_blocks()` (244)
and `is_incapacitated()` (289) have no caller outside this module chain.

### AutoMedicine (`shared/utils/debuff/auto_medicine.lua`, also `_G.AutoMedicine`)

| Function | Effect | Callers |
|---|---|---|
| `init(state_table, mode_ctor)` (95) | creates `state.AutoMedicine = M{'On','Off'}`, wraps `cycle/set/reset/toggle` to persist, restores the persisted value | every `[JOB]_STATES.lua` (`_master/config/*/`, 14 files; live copies) |
| `ensure()` (131) | `init()` if the state is missing | `INIT_SYSTEMS.lua:120-122` |
| `is_enabled()` (145) | `state.AutoMedicine.value == 'On'`, else persisted value | PrecastGuard (243, 316, 371) |
| `toggle()` (155), `set(enabled)` (192) | change and persist | `handle_command` |
| `handle_command(arg)` (170) | `on`/`off`/toggle, repaint the HUD if visible, print | `CommonCommands.handle_automedicine` (`COMMON_COMMANDS.lua:225-232`) |

### DoomManager (`shared/utils/debuff/doom_manager.lua`)

`handle_buff_change(buff, gain) -> boolean` (75), `handle_status_change(new, old)`
(131); callers listed above. `is_doom_locked()` (166) and `validate_doom_set()`
(182) have no caller.

### CooldownChecker (`shared/utils/precast/cooldown_checker.lua`)

`check_ability_cooldown(spell, eventArgs)` (76) and
`check_spell_cooldown(spell, eventArgs)` (112). Both set `eventArgs.cancel` and
print when on cooldown. Callers: all 16 `[JOB]_PRECAST.lua`, always gated by
`spell.action_type` (`'Ability'` / `'Magic'`). There is no third "exclusions"
parameter.

### RECAST_CONFIG (`Tetsouo/config/RECAST_CONFIG.lua`, template `_master/config_global/RECAST_CONFIG.lua`)

`RECAST_CONFIG.is_ready(recast, custom_tolerance)` (45): `nil` -> false; if
`enabled` is false, `recast == 0`; else `recast <= tolerance`.
`RECAST_CONFIG.on_cooldown(...)` (65) is its negation. Globals
`is_recast_ready(recast)` and `is_on_cooldown(recast)` (77-87) are exported with
`_G.RECAST_CONFIG` (94-96) and used directly by `waltz_manager.lua`,
`drg/auto_jump.lua`, `drg/DRG_JUMP_MANAGER.lua`,
`smartbuff/subjob_war_buffs.lua`, the DNC/THF/WAR smartbuff managers, the DNC
step manager, the PLD/RUN aoe and rune managers and `BLM_COMMANDS.lua`.

### AbilityHelper (`shared/utils/precast/ability_helper.lua`)

`can_use_ability(name)` (34), `is_ability_ready(name)` (65),
`is_buff_active(name)` (75), `try_ability(spell, eventArgs, name, wait)` (79,
default wait 2), `try_ability_smart(...)` (96, same but returns early when the
buff is up), `try_ability_ws(...)` (118, re-sends `/ws "<name>" <t>`, sets
`eventArgs.cancel` and `_G.DNC_AUTO_WS_RECAST = true`, a flag nothing reads).
Ability lookups are memoised in `ability_cache` (21-32).

### Weaponskill modules

- `WSPrecastHandler.handle(spell, eventArgs, tp_config) -> boolean` (41):
  `true` for non-WS or a WS that may proceed. `apply_tp_gear(spell)` (75).
  Callers: all 16 `[JOB]_PRECAST.lua`.
- `WSValidator.validate(spell, eventArgs) -> boolean` (`ws_validator.lua:8`).
  Caller: WSPrecastHandler only.
- `WeaponSkillManager.check_weaponskill_range(spell)` (47),
  `validate_weaponskill(ws_name)` (111), `initialize()` (37, no caller),
  `config` (23-30; `distance_check_enabled` is never read).
- `TPBonusHandler.calculate_tp_gear(spell, tp_config)` (`tp_bonus_handler.lua:39`),
  internal to WSPrecastHandler.
- `TPBonusCalculator.calculate(tp, cfg, main, buffs, sub) -> table|nil` (159),
  `get_final_tp(...)` (216, no caller), `config.thresholds`, `config.debug_mode`.
- `WSSlots.rebuild`, `detect_weapon`, `sync`, `get`, `cast` (`ws_slots.lua:40-139`).

### TierRefiner (`shared/utils/precast/tier_refiner.lua`)

`refine(spell, eventArgs, correspondence) -> boolean` (200),
`find_available_tier(name, corr, category, tier, recasts, mp) -> string` (57),
`collect_tier_cooldowns(category, start, corr, recasts) -> list` (97),
`show_unavailable(...)` (136), `execute_replacement(...)` (171).

## Commands

| Command | Args | Effect | Handler |
|---|---|---|---|
| `//gs c automedicine` / `//gs c am` | optional `on` / `off` | toggle or force `state.AutoMedicine`, persist, repaint HUD, print | `COMMON_COMMANDS.lua:495` -> `auto_medicine.lua:170` |
| `//gs c cyclestate AutoMedicine` | - | Mote cycle through the wrapped `cycle` (persists) | bound to `#numpad0` in every `[JOB]_KEYBINDS.lua` |
| `//gs c ws1` .. `//gs c ws9` | - | fire the weaponskill held by slot N (WAR) | `WAR_COMMANDS.lua:248-255` -> `ws_slots.lua:125` |
| `//gs c debugprecast` | - | toggle `_G.PrecastDebugState` (read by RDM, BRD, RUN precast debug output) | `COMMON_COMMANDS.lua:567-571` |

## Configuration

### `shared/config/DEBUFF_AUTOCURE_CONFIG.lua` (shared, no per-character copy)

| Key | Default | Read by |
|---|---|---|
| `test_mode` | `false` (29) | `debuff_checker.lua:23` (at load, builds test tables), `precast_guard.lua:223,232,308,363` |
| `test_debuff` | `"Berserk"` (30) | only `check_magic` (307), which is unreachable |
| `auto_cure_silence` | `true` (39) | `precast_guard.lua:211, 302` |
| `silence_cure_items` | Echo Drops 4151, Remedy 4155 (40-43) | `precast_guard.lua:45` |
| `auto_cure_paralysis` | `true` (48) | `precast_guard.lua:217, 358` |
| `paralysis_cure_items` | Remedy 4155, Panacea 4145 (49-52) | `precast_guard.lua:48` |
| `auto_cure_poison`, `auto_cure_blind` | `false` (57-58) | nothing |
| `debug` | `false` (64) | test-mode messages in PrecastGuard |

If the file fails to load, `precast_guard.lua:27-41` uses built-in defaults
(Panacea included) and `debuff_checker.lua:23` runs in production mode. Both
modules read the config once at load; changes need a `gs reload`.

Test mode (`debuff_checker.lua:33-38`) maps WAR buffs to debuffs: Berserk ->
Silence, Aggressor -> Amnesia, Warcry -> Stun, Defender -> Paralysis. In test mode
the production lists are empty.

### RECAST_CONFIG

`tolerance = 2.0` (31), `enabled = true` (35). Each entry point loads it with
`_G.RECAST_CONFIG = require('<Char>/config/RECAST_CONFIG')` (e.g.
`_master/entry/Tetsouo_WAR.lua:117`). `Tetsouo/config` and `Kaories/config`
copies are identical to the template. `_master/entry/Tetsouo_SAM.lua` loads it
at line 68.

### TP configs

`Tetsouo/config/<job>/<JOB>_TP_CONFIG.lua` (templates in `_master/config/<job>/`),
schema above. Jobs pass `_G.<JOB>TPConfig or {}`; an empty config yields no TP
gear.

## State & lifetime

| State | Where | Lifetime |
|---|---|---|
| `cure_lock_until`, `cure_in_flight` | `precast_guard.lua:99,102` | module-level; reset by `gs reload` / job change (new sandbox) |
| `last_replacement_time` | `tier_refiner.lua:37` | module-level |
| `ability_cache` | `ability_helper.lua:21` | module-level, never invalidated |
| `modules_loaded` + cached module refs | `ws_precast_handler.lua:12`, `tp_bonus_handler.lua:18` | module-level |
| `_G.temp_tp_bonus_gear` | written `tp_bonus_handler.lua:68`, cleared `ws_precast_handler.lua:79` | sandbox global; left set if the WS is cancelled after the calculation, overwritten by the next WS |
| `_G.suppress_cooldown_messages` | read `cooldown_checker.lua:92`; set/cleared by `thf/functions/logic/smartbuff_manager.lua:214-227` (3.0 s `coroutine.schedule`) | sandbox global |
| `_G.RECAST_CONFIG`, `_G.is_recast_ready`, `_G.is_on_cooldown` | `RECAST_CONFIG.lua:94-96` | sandbox globals, set by the entry point |
| `_G.WeaponSkillManager`, `_G.TPBonusCalculator`, `_G.AutoMedicine` | `weaponskill_manager.lua:144`, `tp_bonus_calculator.lua:274` / `tp_bonus_handler.lua:32`, `auto_medicine.lua:208` | sandbox globals |
| `_G.DNC_AUTO_WS_RECAST` | written `ability_helper.lua:132`, `DNC_PRECAST.lua:136` | never read |
| `windower._auto_medicine` | `auto_medicine.lua:47,57` | survives `gs reload` and job change; reset by `lua reload gearswap` |
| `state.AutoMedicine`, `state.WS1..n` | `auto_medicine.lua:122`, `ws_slots.lua:49-52` | Mote states; recreated by `user_setup` on each load and subjob change |
| GearSwap `disable_table` (Doom lock) | `doom_manager.lua:99,107,141,149` | GearSwap global, survives reload |

No module in this area registers Windower events, binds keys or creates text
objects. Deferred work is done only through Windower `wait` chains in
`send_command` (`precast_guard.lua:152-155`, `ability_helper.lua:91,113,133`,
`tier_refiner.lua:174`), which cannot be cancelled and outlive a `gs reload`
(they are plain console commands).

## Interactions

- Messages: `MessageFormatter` / `MessageCooldowns` / `MessageDebuffs` /
  `MessageWeaponskill` / `MessageCombat` / `MessageCore.show_test_mode` (see
  [messages](./messages.md)).
- Keybind HUD: `auto_medicine.lua:67-83` calls `UI_MANAGER.update()` when visible.
- `INIT_SYSTEMS.lua` installs `ModuleCache` (47-52) before any of these modules
  are required, and calls `AutoMedicine.ensure()` (120-122).
- Message hooks `init_ability_messages.lua` / `init_ws_messages.lua` wrap
  `user_post_precast`; the WS hook re-reads TP from `windower.ffxi.get_player()`
  and stays silent below 1000.
- Jobs: [DNC](../jobs/dnc.md), [BLM](../jobs/blm.md), [BRD](../jobs/brd.md),
  [PLD](../jobs/pld.md), [RDM](../jobs/rdm.md), [WAR](../jobs/war.md),
  [THF](../jobs/thf.md), [SAM](../jobs/sam.md).

## Invariants & gotchas

- `spell.type` is never `"Magic"`. All spells reach
  `PrecastGuard.check_and_block` through the fallback branch
  (`precast_guard.lua:467-469`), so `check_magic` and the configurable
  `test_debuff` are dead; in test mode only Berserk simulates Silence
  (hard-coded at 223).
- A `/ws` has `action_type == 'Ability'`; code that dispatches on
  `action_type` must test `spell.type == 'WeaponSkill'` first if it matters.
  `check_ability_cooldown` is harmless on a WS only because WS resources have no
  `recast_id`.
- Weaponskills are never blocked by Paralysis alone, job abilities always are,
  and spells never are.
- The Silence/Paralysis cure lock is shared on purpose (`precast_guard.lua:94-98`);
  `CURE_BUSY` makes the second debuff visible instead of silent.
- Auto-cure item uses are themselves `/item` commands and pass through
  `check_item`; anything that blocks items also blocks the auto-cure after the
  success message has been printed.
- `CooldownChecker` and `AbilityHelper` capture `_G.RECAST_CONFIG` when first
  executed. Requiring either before the entry point sets it freezes the
  fallback behaviour for the whole sandbox.
- AbilityHelper's replay chain re-enters precast. If the helper JA cannot fire
  while its recast reads ready (Amnesia, Impairment, Paralysis without a cure,
  or not available at the current level), the spell is cancelled and re-sent
  every `wait_time` seconds (see Known issues).
- The DNC Climactic auto-trigger runs before `WSPrecastHandler` (range, TP), so
  a WS pressed out of range still fires Climactic Flourish first.
- `WSValidator` calls `validate_weaponskill` twice on the success path, and
  PrecastGuard has already blocked Amnesia before it runs.
- TierRefiner requires recast exactly 0 while CooldownChecker tolerates 2.0 s;
  a tier with 1 s left is skipped by the refiner even though the checker would
  let it through.
- Doom handling is keyed on the lowercase English buff name; the lock covers
  exactly neck, ring1, ring2, waist whatever `sets.buff.Doom` contains.
- `handle_status_change` tests only `'Dead'`. GearSwap passes
  `res.statuses[...].english` (`GearSwap/gearswap.lua:328`), and a death while
  engaged is `'Engaged dead'` (`res/statuses.lua:7`), which the status safety
  unlock does not match; the buff-loss path still unlocks.
- `/ra` has `spell.type == 'Misc'` (`GearSwap/statics.lua:134`), never
  `'RangedAttack'` or `'Ranged Attack'`; only `spell.action_type` identifies it.

## Extending

- **New blocking debuff**: add it to the right production table in
  `debuff_checker.lua:96-124` (lowercase name, `priority`, `message`) and to
  `DEBUFF_DEFINITIONS` (41-62) if it should have a test-mode stand-in.
- **New cure item**: add `{ name, id }` to `silence_cure_items` or
  `paralysis_cure_items` in `DEBUFF_AUTOCURE_CONFIG.lua`, in priority order.
  Auto-cure for a new debuff needs a new branch in `check_and_block` /
  `check_ja` and a message pair in `message_debuffs.lua`.
- **New multi-charge ability**: add it to `MULTI_CHARGE_ABILITIES`
  (`cooldown_checker.lua:30-69`). PLD, RUN and BLM keep their own copies
  (`PLD_PRECAST.lua:56`, `RUN_PRECAST.lua:49`, `BLM_SPELL_FILTERS.CHARGE_ABILITIES`).
- **New auto-trigger ability**: call `AbilityHelper.try_ability_smart` after the
  cooldown check in the job's `job_precast`; return after it if the rest of the
  job logic must not run for the cancelled spell.
- **New TP piece**: add `{slot, name, bonus}` to the job's `pieces`; weapon/buff
  bonuses go in the `get_*_bonus` callbacks.
- **New tier family**: add `Family = { ['III'] = {replace='II'}, ['II'] = {replace=''} }`
  to the correspondence table the job passes to `TierRefiner.refine`.

## Known issues

- AbilityHelper replays the spell forever while the helper JA cannot fire (Amnesia, unavailable ability): `shared/utils/precast/ability_helper.lua:43`, `:110-115`.
- Encumbrance blocks all `/item` use (auto-cure included) while Muddle is not detected: `shared/utils/debuff/debuff_checker.lua:122-124`.
- Paralysis blocks Healing Waltz, the JA that removes it: `shared/utils/debuff/precast_guard.lua:216-220`, `:254-262`.
- WSPrecastHandler cancels below 1000 TP, contradicting the removed-TP-check rule: `shared/utils/precast/ws_precast_handler.lua:52-64`.
- `check_magic` unreachable; `test_debuff` ignored; `"Ranged"` branch dead: `shared/utils/debuff/precast_guard.lua:463`, `debuff_checker.lua:224`.
- `DoomManager.is_doom_locked` always returns false and unlocks the neck slot: `shared/utils/debuff/doom_manager.lua:166-176`.
- `MULTI_CHARGE_ABILITIES` includes single-recast abilities (Light/Dark Arts, Sublimation, Enlightenment, Tabula Rasa): `shared/utils/precast/cooldown_checker.lua:51-66`.
- Unused API and dead branches in the WS chain (`initialize`, `MessageFormatter` field, `distance_check_enabled`, `get_formatter`, `get_final_tp`): `shared/utils/weaponskill/weaponskill_manager.lua:17-42`.
- Unused PrecastGuard/DebuffChecker API (`would_block`, `get_active_blocks`, `get_all_active_blocks`, `is_incapacitated`): `shared/utils/debuff/precast_guard.lua:482-491`.
- `_G.DNC_AUTO_WS_RECAST` is written but never read: `shared/utils/precast/ability_helper.lua:132`.
- BLM TP config uses a `moonshade` key the calculator never reads: `_master/config/blm/BLM_TP_CONFIG.lua:21-24`.
- The precast rule doc documents a non-existent `exclusions` parameter and an ungated `check_ability_cooldown`: `.claude/rules/precast-pattern.md:14-19`, `:50-51`.
