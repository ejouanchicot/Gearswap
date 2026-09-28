# SAM — start here

The one page to open first when you play Samurai. It lists every key, every
command and every automatic feature active on SAM, and where each setting
lives. Details are on the linked pages:

- [states.md](states.md): what each mode value does
- [sets.md](sets.md): the set names the code looks for, and the gear put on for you

No maintained character plays SAM today: the provided template is complete
but has not been tested in game in its current form.

## Overview

Samurai with the provided template gives you:

- **Four keyed modes**: weapon, engaged accuracy (Offense Mode), weaponskill
  accuracy (WS Mode) and the defensive Hybrid Mode.
- **Third Eye before a weaponskill**: a weaponskill pressed while Third Eye is
  ready and not up is held back, Third Eye goes out, then the weaponskill. A
  weaponskill out of range or without 1000 TP is refused without using Third Eye.
- **A stance you choose** (Hasso or Seigan, `//gs c hasso` / `seigan`): in
  Seigan stance, Third Eye is preceded by Seigan when Seigan is down; in Hasso
  stance, Hasso is never replaced.
- **Gear by situation**: Seigan / Third Eye sets while Seigan is up, HP-based
  idle (Weak, Regen), Sekkanoki and Meikyo Shisui pieces on weaponskills.
- **Movement speed gear**: `sets.MoveSpeed` goes on over the idle set while
  you run, in town too. SAM has no town set of its own.

Every mode goes back to its default on each job change, subjob change and
reload.

## All keys on this job

Ctrl = `^`, Alt = `!`, Apps (menu key) = `#`, Win = `@`. The keys come from
the provided template; after cloning, yours are in `<YourName>/config/sam/`
and `<YourName>/config/COMMON_KEYBINDS.lua`, and those files win.

| Key | Does | When | Shown in the HUD |
|---|---|---|---|
| `^numpad1` | Cycle Main Weapon: Masamune, Kusanagi, Shining, Dojikiri, Soboro, Norifusa | always | yes |
| `^numpad2` | Cycle Offense Mode: Normal, Mid, Acc, SuBlow | always | yes |
| `^numpad3` | Cycle WS Mode: Normal, Mid, Acc | always | yes |
| `^numpad9` | Cycle Hybrid Mode: PDT, Normal, MDT | always | yes |
| `#numpad0` | Auto Medicine on / off | always (common key) | yes |
| `!numpad7` | Alts follow this character (press again to stop) | always (common key) | yes |
| `!numpad8` | Alts' automation on / off | always (common key) | yes |
| `!numpad9` | Alts mirror | always (common key) | yes |
| `!z` | Sneak on you and every alt | always (common key) | yes |
| `!x` | Invisible on you and every alt | always (common key) | yes |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **not bound by default**: only after `//gs c combatmode show` | only when shown |
| `!numpad.` | Cycle Treasure Mode: Off, Tag, Full | **not bound by default**: only after `//gs c th show`, and it needs a `sets.TreasureHunter` you add | only when shown |
| `^f1`-`^f8`, `!f1`-`!f8` | Your temporary keys | only the ones you create with `//gs c tb` | no |

There is no key for the stance: use `//gs c hasso` / `//gs c seigan` (or any
Hasso / Seigan you use), or `//gs c cycle Stance`.

Mote-Include (the library under every job) also binds these keys on every
job load. They are not in the HUD. On SAM:

| Key | Mote command | Effect on SAM |
|---|---|---|
| `f9` | cycle Offense Mode | Same as `^numpad2` |
| `^f9` | cycle Hybrid Mode | Same as `^numpad9` |
| `@f9` | cycle Weaponskill Mode | Same as `^numpad3` |
| `!f9`, `^f11`, `^f12` | cycle Ranged / Casting / Idle Mode | Nothing: SAM gives these modes a single value |
| `f10`, `f11`, `^f10`, `!f12` | Defense Mode Physical / Magical / cycle / reset | Idle only: `sets.defense.PDT` / `.MDT` from the template go under your idle layers; engaged gear ignores them |
| `!f10` | Kiting on / off | Nothing unless you add `sets.Kiting` (idle only) |
| `f12` | `update user` | Puts your gear back for your current status and prints the current modes |
| `^-`, `^=` | Mote target helpers | Mote's own `<t>` target switching |

Key conflicts for this job, on every subjob: `//gs c keyconflicts`.

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro). Full list
and arguments: [commands guide](../../guides/commands.md).

**SAM commands**

| Command | What it does |
|---|---|
| `hasso` | Makes Hasso the chosen stance and uses Hasso |
| `seigan` | Makes Seigan the chosen stance and uses Seigan |

**Common commands that work on SAM**

| Command | What it does |
|---|---|
| `cyclestate <Mode>` / `cycle` / `set` / `toggle` / `reset` | Change a mode (what the keys send) |
| `ui ...` | Keybind HUD: show / hide, save position, font, theme, order |
| `am [on/off]` | Auto Medicine |
| `checksets`, `wa`, `wo`, `rf`, `naked`, `reload` | Gear check, wardrobe audit / organizer, refill, unequip all, reload |
| `ls`, `dressup` | Lockstyle again, DressUp handling |
| `craft`, `fish`, `uncraft` | Crafting / fishing sets (write your own set file) |
| `warp`, `w2`, `tph`... , `<command>all`, `mount` | Travel |
| `jump` | /DRG: Jump / High Jump |
| `waltz`, `aoewaltz` | /DNC: Curing Waltz on `<stpc>`, Divine Waltz |
| `watchdog ...`, `debugmidcast` | Midcast watchdog, midcast debug |
| `stealth sneak` / `invi` / `both` ... | Sneak / Invisible on you and your alts |
| `alts ...`, `main`, `altcmds`, `alt <name>` | Dual-box group |
| `th [show / hide / key / clear]` | Treasure Mode on this job |
| `combatmode [show / hide / key]` | Combat Mode (weapon lock) on this job |
| `dw`, `belt` | Dual Wield tier, Obi / Orpheus status |
| `tb ...` | Temporary keys |
| `keyconflicts` (`kc`) | Every key conflict on this job |
| `info <name>`, `jamsg`, `spellmsg`, `wsmsg` | Ability / spell / weaponskill details and chat messages |
| `commands`, `help` | Built-in command list and help |
| `syscheck`, `fulltest`, `trace`, `debugsubjob`, ... | Diagnostics |

## Shared features on this job

| Feature | On SAM |
|---|---|
| Third Eye / Seigan automation | SAM's own, see [states.md](states.md#notes) |
| Auto stance (off by default) | With `sam_hasso = true` in `config/AUTO_ABILITIES.lua`: your chosen stance (Hasso, or Seigan after `//gs c seigan`) when you engage, unless Hasso or Seigan is up and only when it is ready |
| Weaponskill check | A weaponskill out of range or under 1000 TP is cancelled with a message; TP bonus gear from `SAM_TP_CONFIG.lua` is added (Hagakure counted while it is up) |
| Recast check | An ability or spell still on recast is cancelled with the time left (`RECAST_CONFIG.lua`) |
| Debuff guard | An action you cannot do is stopped; with Auto Medicine on, Echo Drops / Remedy / Panacea are used |
| Doom | `sets.buff.Doom` goes on and its neck, rings and waist stay locked while Doomed |
| Movement speed | `sets.MoveSpeed` on idle while you move, in town too |
| Obi / Orpheus | Added to elemental weaponskills (Tachi: Goten, Kagero, Jinpu, Koki, ...) and damaging spells when the day, weather or distance gives enough (`//gs c belt`) |
| Treasure Hunter | Off and hidden. Needs `//gs c th show` and a `sets.TreasureHunter` you add |
| Combat Mode | Off and hidden. When shown and On: main, sub and range stay locked |
| Weapon without a set | With `equip_without_set = true` in `config/WEAPON_CONFIG.lua`, a Main Weapon value with no set equips that weapon by name |
| Dual Wield tiers | Only while holding two weapons with a `sets.DW`: not the case with great katanas |
| Your own modes | `SAM_CUSTOM.lua`: extra modes, keys and gear rules without code |
| Midcast watchdog | Puts your gear back if a cast result never arrives |
| Lockstyle, macro book | Set on load and on each subjob change |
| Dual-box | Job exchange with your alt, `alts` orders |
| Messages | Ability, spell and weaponskill lines in chat (`jamsg` / `spellmsg` / `wsmsg`) |

## Configuration files for this job

In `<YourName>/config/sam/`:

| File | Content |
|---|---|
| `SAM_STATES.lua` | Modes, their values and defaults (Stance included) |
| `SAM_KEYBINDS.lua` | The job keys above |
| `SAM_CUSTOM.lua` | Your own modes, keys and gear rules ([keybinds guide](../../guides/keybinds.md)) |
| `SAM_HUD.lua` | HUD section and row order for SAM (written by `//gs c ui order` / `roworder`) |
| `SAM_LOCKSTYLE.lua` | Lockstyle number (the template uses `default` only) |
| `SAM_MACROBOOK.lua` | Macro book / page per subjob (the dual-box table is empty) |
| `SAM_TP_CONFIG.lua` | Hagakure job points, TP bonus pieces and weapons ([TP bonus](../war/tp-bonus.md)) |
| `SAM_REFILL.lua` (optional) | What `//gs c rf` restocks; without it a built-in list is used |

In `<YourName>/config/`, shared with the other jobs: `AUTO_ABILITIES.lua`
(`sam_hasso`), `COMMON_KEYBINDS.lua`, `WEAPON_CONFIG.lua`,
`ELEMENTAL_BELT.lua`, `RECAST_CONFIG.lua`, `STEALTH_CONFIG.lua`, and
`treasure_mode.lua` / `combat_mode.lua` (written by `//gs c th` /
`combatmode`). Gear: `<YourName>/sets/sam_sets.lua`. See
[configuration](../../guides/configuration.md).

## More

- [states.md](states.md): each mode in detail
- [sets.md](sets.md): set names and automatic gear
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md)
