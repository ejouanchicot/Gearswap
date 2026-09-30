# Cleanse system (`//gs c cleanse`, debuffs off the box group)

`//gs c cleanse` takes the debuffs off this character and every other member of the box group. Like `//gs c stealth` ([stealth.md](stealth.md)), each box handles itself: the key box sends `cleanse local <name>` to the others, and each one reads its own buff ids from the game, walks its debuffs most urgent first (`DEBUFF_REMOVAL.lua` order, changed by `CLEANSE_CONFIG.lua`) and, per debuff, uses its own spell when it can cast it now, else asks the partners that may have the spell (`cleanse cast <spell> <name>`) and uses its item if the debuff is still on `partner_wait` seconds later, else its own item. Every action goes through the shared action queue (`shared/utils/core/action_queue.lua`). Each box sends a one-line summary back to the key box (`cleanse report <name> <body>`), which shows one `CLEANSE` block per box.

Verified against the code on 2026-10-01 (system added 2026-10-01, commit `7950cf8`). Not yet tested in game.

## Files

| Path | Lines | Role |
|---|---:|---|
| `shared/utils/debuff/cleanse.lua` | 262 | Command router (`Cleanse.handle`), plan per debuff (`plan_one`, `plan`), `run_self`, partner request (`partners_for`, `ask_partners`, `cast_for`), item use with aura watch and Doom retries (`use_item`), reports (`report_to`, `receive_report`, `show`) |
| `shared/utils/debuff/cleanse_methods.lua` | 238 | Settings merge (`settings`), debuff order (`ordered`, `active`, `is_up`), items (`items_for`, `item_count`, `first_item`, `cast_time`), spells (`can_cast`, `partner_may_cast`, `SPELLS`) |
| `shared/data/debuffs/DEBUFF_REMOVAL.lua` | 104 | Every debuff: `key`, `name`, buff `ids`, `spell`, default `items`, `no_action`; list order = default removal order |
| `shared/utils/core/action_queue.lua` | 137 | Shared one-action-at-a-time queue (stealth and cleanse) |
| `_master/config_global/CLEANSE_CONFIG.lua` | 48 | Settings template, copied to `<Character>/_common/combat/` by the clone |

Integration points:

- `shared/utils/core/COMMON_COMMANDS.lua` `handle_command`: `cleanse` is routed to `require('shared/utils/debuff/cleanse').handle(args)` right after `stealth`; `cleanse` is in the hand-written list of `is_common_command`.
- `shared/utils/core/char_paths.lua` and `migrate_layout.py` `COMMON_GROUPS`: `CLEANSE_CONFIG.lua` -> `combat`. `where_is_what.py` describes it.
- `shared/utils/messages/formatters/ui/message_commands.lua`: `//gs c help` lists `cleanse help`, `//gs c commands` lists `cleanse`.
- `shared/utils/debuff/uncurable_debuffs.lua`: `watch` / `is_marked`, the aura marks shared with Auto Medicine.
- `shared/utils/messages/formatters/magic/message_debuffs.lua` `show_debuff_uncurable`: the line when an item did not take the debuff off.
- `shared/utils/dualbox/alt_group.lua` `get_alts()` (other members) and `shared/utils/dualbox/alt_states.lua` `get(name)` (their known job and subjob).
- `shared/utils/messages/info_block.lua` (result and `check` blocks), `help_screen.lua` (help).
- No keybind: `COMMON_KEYBINDS.lua` has none for `cleanse`.

## How it works

### Command

`Cleanse.handle(args)`, `args` = the words after `cleanse`, first one lower-cased. Always returns `true`.

| Sub | Effect |
|---|---|
| (none) | `run_self(nil)`, then `send <name> gs c cleanse local <me>` to every `AltGroup.get_alts()` member |
| `self` | `run_self(nil)` only |
| `local <name>` | `run_self(<name>)`: sent by the key box; the result goes back to `<name>` |
| `cast <spell> <name>` | `cast_for(spell, name)`: a partner asks; queue `/ma "<spell>" <name>` only when the spell is in `SPELLS` and `Methods.can_cast(spell)` is true now. Spell names have no space, so `args[2]` is the whole name |
| `report <name> <body>` | `receive_report`: another box's result, shown as a block titled `<name>` |
| `check` | Dry run: `plan()` without running it, InfoBlock `CLEANSE :: Check (nothing is used)` with a `Jobs` line and one line per debuff |
| other (`help` included) | `HelpScreen.show` |

### A press across the group

```mermaid
sequenceDiagram
    participant K as "Key box"
    participant P as "Partner (WHM)"
    participant O as "Other box (paralyzed)"
    K->>K: "run_self(nil): plan, act, show own block"
    K->>P: "send P gs c cleanse local K"
    K->>O: "send O gs c cleanse local K"
    O->>O: "plan: Paralyna not castable, partner P may have it"
    O->>P: "send P gs c cleanse cast Paralyna O"
    P->>P: "cast_for: can_cast now? queue /ma Paralyna O"
    O->>O: "queue: empty step (partner_wait), then Remedy if still paralyzed"
    O->>K: "send K gs c cleanse report O Paralysis=Paralyna_from_P,_else_Remedy"
    P->>K: "send K gs c cleanse report P none"
```

### Plan of one debuff (`plan_one(entry, settings)`)

Returns `{text, tone, run, later}`; `run` acts now, `later` runs after the partner wait. First match wins:

1. `UncurableDebuffs.is_marked(entry.key)`: `left alone (item had no effect: aura?)`, nothing done.
2. Own spell: `entry.spell`, `use_spells ~= false`, not `no_action`, `Methods.can_cast(spell)` -> queue `/ma "<spell>" <me>` with a longest wait of cast time + `WAIT_MARGIN` (3 s).
3. Partner: `entry.spell` and `ask_partner ~= false` and `partners_for(spell)` not empty -> `run` sends `gs c cleanse cast <spell> <me>` to each partner; `later` (only when an item exists) uses the item if `Methods.is_up(entry)` still. Text `<spell> from <names>[, else <item>]`.
4. Own item (`first_item(items_for(entry, settings))`, not for `no_action`) -> `use_item`.
5. Nothing: `cannot act, no partner can help` (`no_action`), `no item, no spell` (the entry has a spell or items but none is usable), else `nothing removes it`.

`partners_for(spell)` keeps the other members for which `Methods.partner_may_cast(spell, job, subjob)` is true, with the job and subjob from `AltStates.get(name)`: an unknown job counts as able (asked anyway); a main job with a level for the spell; a WHM / RDM / PLD subjob whose level for the spell is 49 or less; never a SCH subjob. The partner's MP, recast, learned spells and Addendum are not checked here: `cast_for` on the partner checks them with its own `can_cast`, and does nothing when it cannot.

### One box's run (`run_self(from)`)

1. `plan()` walks `Methods.active(settings)` and calls `run` of every step in order: all queue pushes and partner requests go out at once.
2. **Single partner_wait step**: when at least one step has a `later`, one empty function step is pushed with a longest wait of `partner_wait` (default 5), then one function step (wait 0.1 s) that calls every `later` in order. A function step runs first and then waits, so the empty one holds the queue for `partner_wait` and the checks run after it. This wait is shared by every debuff a partner was asked for, not one per debuff.
3. `from` set and not this character: `report_to(from, steps)` sends `cleanse report <me> <body>`, body = `<debuff name>=<text>` per step, spaces as `_`, steps joined with `;`, `none` when empty. Otherwise the block is shown here.

### Items (`use_item(entry, item, tries, settings)`)

- Not Doom: a function step first (wait 0.05 s) calls `UncurableDebuffs.watch(entry.key, item, 0, on_marked)`, so the watch starts when the item really goes, not when an earlier item of the queue does. `watch` counts the item in the inventory, and 4 s later marks the debuff when the count dropped and the debuff is still on (60 s at most; the mark is dropped as soon as the debuff is gone). `on_marked` prints `MessageDebuffs.show_debuff_uncurable`.
- Then `/item "<name>" <me>`, longest wait `ITEM_CAST` (1 s) + `WAIT_MARGIN`.
- **Doom retries**: while `tries < doom_tries`, a function step (wait 0.1 s) checks `Methods.is_up(entry)`; Doom still on and an item still in the inventory -> `use_item` again with `tries + 1`. So `doom_tries` is the total number of Holy Waters. Doom is never watched for an aura (Holy Water fails two times in three).

### What this character has (`cleanse_methods.lua`)

- Debuffs: buff ids from `windower.ffxi.get_player().buffs` (not `buffactive`, which lags inside a scheduled function), matched against each entry's `ids`. `active(settings)` returns the entries up, in `ordered(settings)`: the `first` keys in their order, then the list order, `skip` keys removed.
- `items_for(entry, settings)`: `settings.items[entry.key]` when it is a table, else `settings.items.erasable` for an entry whose spell is Erase, else `entry.items`.
- Items: inventory (bag 0) only. Ids of the six default items are copied (`ITEM_IDS`: Echo Drops 4151, Remedy 4155, Eye Drops 4150, Antidote 4148, Holy Water 4154, Panacea 4149); another item named in the settings is looked up once in `res.items` and cached (`false` when unknown).
- `can_cast(name)`: the spell in `SPELLS`; the job reaching its level (main first, then sub, `job_for`); learned (`get_spells()[id]`); MP; recast 0; none of Silence (6), Mute (29), Omerta (262) on; **Scholar Addendum rule**: when the job that reaches the level is SCH (20), every spell but Cure needs Addendum: White (buff 401) up. A WHM/SCH casts as WHM and needs no Addendum.
- `SPELLS` (ids, MP, cast time, levels per job id 3 WHM, 5 RDM, 7 PLD, 20 SCH) are copied from `res/spells.lua`: Poisona 14, Paralyna 15, Blindna 16, Silena 17, Stona 18, Viruna 19, Cursna 20, Erase 143, Cure 1.

### Debuff table (`DEBUFF_REMOVAL.lua`)

56 entries in four groups: cannot act (Doom first, then Petrification, Sleep, Lullaby, Stun, Terror, Charm; all but Doom `no_action`), block actions (Silence, Paralysis, Curse, Amnesia, Mute, Omerta, Impairment, Muddle, Bane), ailments with their own spell (Plague, Disease, Blindness, Poison), erasable (Slow ... Dia, spell Erase, items `{'Panacea'}`). Ids 539-567 are the geomancy aura versions (Poison 540, Attack Down 557 ... Weight 567, Paralysis 566). The player page lists every entry: [Cleanse](../../user/features/cleanse.md#every-debuff-and-what-removes-it).

## Configuration

`<Character>/_common/combat/CLEANSE_CONFIG.lua` (template `_master/config_global/CLEANSE_CONFIG.lua`), read by `CleanseMethods.settings()` through `CharPaths.optional('common', 'CLEANSE_CONFIG')`. That is a `require`, so the file is read once per load; missing file = defaults. The merge is shallow: each top-level key of the file replaces the default (a missing `items` entry still falls back to the debuff's own default through `items_for`).

| Key | Default | Meaning |
|---|---|---|
| `use_spells` | `true` | Own spell before a partner or an item |
| `ask_partner` | `true` | Ask the partners that may have the spell |
| `partner_wait` | `5` | Seconds of the single wait step before the `later` checks |
| `doom_tries` | `5` | Holy Waters in all while Doom stays |
| `skip` | `{}` | Keys never handled |
| `first` | `{}` | Keys handled first, in this order |
| `items` | `{}` in `DEFAULTS`; the template writes `doom`, `curse`, `silence`, `paralysis`, `blindness`, `poison`, `erasable` with the default lists | Items per key; `erasable` for every Erase entry |

## Commands (internal)

| Command | Sent by | Effect |
|---|---|---|
| `cleanse local <name>` | The key box, to every other member | Run this box's part and report to `<name>` |
| `cleanse cast <spell> <name>` | A box that needs a spell, to its possible partners | Cast it on `<name>` if possible now |
| `cleanse report <name> <body>` | Each other box, to the key box | Show `<name>`'s result |

## Shared action queue

`shared/utils/core/action_queue.lua` (moved out of `stealth.lua` on 2026-10-01): one queue per character on `windower._action_queue`, generation `windower._action_gen_queue`, raw `action` listener `_G._action_queue_listener` registered once per load from `push`. `ActionQueue.push(command, wait, {delay, tag})`; cleanse passes `delay = 1.0` (`DELAY`) and `tag = 'CLEANSE'`, stealth its `delay` setting and `STEALTH`. A command step ends on the game's end-of-action for this character plus `delay`, or its longest wait; a function step runs first, then only its longest wait ends it; a refused `/ma` or `/item` is sent again (3 sends at most). Full description: [stealth.md](stealth.md#action-queue-sharedutilscoreaction_queuelua).

## State & lifetime

| Where | What | Lifetime |
|---|---|---|
| `windower._action_queue`, `_action_gen_queue` | Shared queue (also stealth) | Until `//lua reload gearswap` |
| `windower._uncurable_debuffs` | Aura marks per debuff key (shared with Auto Medicine) | Same; each mark 60 s at most |
| `_G._action_queue_listener` | Raw `action` event id | Per load |
| `ITEM_IDS` (module local) | Item ids, including the ones looked up | Per load |

## Invariants & gotchas

- Buff state always from `get_player().buffs`, never `buffactive`: `later` and the Doom retry run inside queued function steps.
- `no_action` entries never use the character's own spell or item: only a partner (`Cure` for Sleep / Lullaby, `Stona` for Petrification). Stun, Terror, Charm have no spell: nothing is done.
- Silence has a spell (Silena) the silenced character cannot cast on itself (`NO_SPELLS`): its partner is asked, else Echo Drops / Remedy.
- The partner request has no claim: every partner that can cast answers, so two able partners both cast (same as `stealth cast`).
- `check` and the key share `plan()`, so `check` shows what the key would do; it does not look at the partners' MP or recast.

## Known issues

Found while writing this page; not fixed.

- **Aura marks never set for multi-word keys.** `UncurableDebuffs.watch` / `is_marked` take a lowercase *buff name* and resolve its ids by matching `res.buffs[id].en:lower()`. Cleanse passes `entry.key`, which matches for one-word debuffs (`silence`, `slow`, `bio`...) but not for `max_hp_down`, `attack_down`, `magic_atk_down`, `inhibit_tp`, `str_down`... (the game names are `max hp down`, `attack down`, `magic atk. down`...): no id is found, `debuff_up` is false, so an aura debuff of those kinds is never marked and an item is spent on every press.
- **One Panacea per erasable debuff.** Each erasable debuff on the character queues its own Panacea (`use_item` does not check the debuff again before the item), although one Panacea removes them all: three erasable debuffs spend three Panaceas.
- **`;` in the report.** `report_to` joins the lines with `;` inside `send_command('send <name> gs c cleanse report ...')`. Windower's console treats `;` as a command separator, so with two debuffs or more only the first probably reaches the key box and the rest runs as a local console command. Not verified in game.
- The header of `action_queue.lua` says "a newer load drops an older queue"; the generation changes only when an idle queue starts ([stealth.md](stealth.md#known-issues)).
