# COR — start here

The one page to open first when you play Corsair. It lists every key, every
command and every automatic feature active on COR, and where each setting
lives. Details are on the linked pages:

- [states.md](states.md): what each mode value does, roll messages
- [sets.md](sets.md): the set names the code looks for, and the gear put on for you

## Overview

Corsair with the provided template gives you:

- **Weapons on keys**: the melee weapon and the gun are chosen from the HUD and
  put on at once. The melee set's off-hand weapon is used only with Dual Wield
  (/NIN at level 10+ or /DNC at level 20+). Otherwise, including /NIN at level 0
  in Sheol Gaol, it is replaced by the `sub` of `sets.SingleWield` (for example a
  Nusku Shield), or left out if you have no such set.
- **Two rolls on two commands**: pick a main and a sub roll, then
  `//gs c roll1` / `roll2` roll them. Pressing a roll that is already up turns
  it into a Double-Up when that is possible (Double-Up Chance up and it is the
  last roll you rolled); otherwise the press is cancelled with the reason.
- **Roll gear kept until the roll lands**: from the roll's precast to its
  result, gear updates (running, the end of a fight) wait, so your "Phantom
  Roll +" piece is worn when the roll takes effect. Double-Up wears the set of
  the roll it doubles.
- **A result line for every roll**: value, lucky / unlucky, bonus (gear, job
  bonus, Crooked Cards included), who in the party it reached, and the bust
  risk of the next Double-Up.
- **Luzaf's Ring mode**: on for 16-yalm rolls, off for 8 yalms with another
  ring.
- **Quick Draw element on a key**, fired by `//gs c shot`.
- **Ranged attacks**: `sets.precast.RA` (with Flurry I / II versions),
  `sets.midcast.RA`, a Triple Shot layer, and a bullet pouch opened for you when
  Bronze Bullets run low.
- **Fold** wears its gear only when two Busts are up (the only case where the
  gloves change anything).

The `rolltracker` addon is unloaded while COR is loaded (this job reports
rolls itself) and loaded again when you leave COR. Every mode goes back to its
default on each job change, subjob change and reload.

## All keys on this job

Ctrl = `^`, Alt = `!`, Apps (menu key) = `#`, Win = `@`. The keys come from
the provided template; after cloning, yours are in `<YourName>/cor/`
and `<YourName>/common/COMMON_KEYBINDS.lua`, and those files win. No COR key
depends on the subjob.

| Key | Does | When | Shown in the HUD |
|---|---|---|---|
| `^numpad1` | Cycle Main Weapon: Naegling | always | yes |
| `^numpad2` | Cycle Range Weapon: Anarchy, Compensator | always | yes |
| `^numpad3` | Cycle Quick Draw element: Light, Fire, Ice, Wind, Earth, Thunder, Water, Dark | always | yes |
| `^numpad4` | Cycle Main Roll (20 rolls, Chaos Roll first) | always | yes |
| `^numpad5` | Cycle Sub Roll (20 rolls, Samurai Roll first) | always | yes |
| `^numpad6` | Luzaf Ring on / off | always | yes |
| `^numpad9` | Cycle Hybrid Mode: PDT, Normal | always | yes |
| `#numpad0` | Auto Medicine on / off | always (common key) | yes |
| `!numpad7` | Alts follow this character (press again to stop) | always (common key) | yes |
| `!numpad8` | Alts' automation on / off | always (common key) | yes |
| `!numpad9` | Alts mirror | always (common key) | yes |
| `!z` | Sneak on you and every alt | always (common key) | yes |
| `!x` | Invisible on you and every alt | always (common key) | yes |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **not bound by default**: only after `//gs c combatmode show` | only when shown |
| `!numpad.` | Cycle Treasure Mode: Off, Tag, Full | **not bound by default**: only after `//gs c th show` | only when shown |
| `^f1`-`^f8`, `!f1`-`!f8` | Your temporary keys | only the ones you create with `//gs c tb` | no |

`^numpad7`, `^numpad8` and `^numpad0` are free on COR.

Mote-Include (the library under every job) also binds these keys on every
job load. They are not in the HUD. On COR:

| Key | Mote command | Effect on COR |
|---|---|---|
| `^f9` | cycle Hybrid Mode | Same as `^numpad9` |
| `!f9` | cycle Ranged Mode | Nothing with the provided template (one value, Normal). Give the mode more values in `COR_STATES.lua` and `sets.midcast.RA.<value>` is used for ranged attacks |
| `f9`, `@f9`, `^f11`, `^f12` | cycle Offense / Weaponskill / Casting / Idle Mode | Nothing: COR gives these modes a single value |
| `f10`, `f11`, `^f10`, `!f12` | Defense Mode Physical / Magical / cycle / reset | Nothing with the provided template (no `sets.defense`); a `sets.defense` you add is laid on idle gear outside town and on engaged gear |
| `!f10` | Kiting on / off | Nothing unless you add `sets.Kiting` (idle outside town, and engaged) |
| `f12` | `update user` | Puts your gear back for your current status and prints the current modes |
| `^-`, `^=` | Mote target helpers | Mote's own target switching |

Key conflicts for this job, on every subjob: `//gs c keyconflicts`.

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro). Full list
and arguments: [commands guide](../../guides/commands.md).

**COR commands**

| Command | What it does |
|---|---|
| `shot` | `/ja "<Quick Draw element> Shot" <t>` |
| `roll1` / `roll2` | `/ja "<Main Roll>" <me>` / `/ja "<Sub Roll>" <me>` |
| `rolls` | Your active rolls with their value (rebuilt from the roll buffs you wear, so it also works after a reload; a value older than 10 minutes shows `?`) |
| `doubleup` (`du`) | Whether Double-Up is still possible (45 s after the last roll or Double-Up) |
| `clearrolls` | Forget the tracked rolls |
| `party` | The party members and the job known for each (used for the roll job bonus) |
| `clearparty` | Forget the party jobs (they come back as the game sends them) |
| `rolldebug` | Roll check on / off: for each roll, the pieces of the roll set not worn when it landed, gear updates held back, pieces out of reach, locked slots; a summary when you switch it off. Also written to `<YourName>/rolldebug.log` |
| `track_roll <roll> <value>` (`trackroll`) | Report a roll by hand, e.g. `track_roll chaos 7` (short names: `chaos`, `sam`, `hunter`, `tact`, `allies`, `wiz`, `lock`, `cor`, `cast`, `course`, `blitz`, `fight`, `rogue`, `gal`, `evo`, `bolt`, `miser`, `comp`, `ave`, `nat`) |
| `ui rollstyle` / `rollorder` / `rolllucky` / `rollparty` / `rollbust` / `roll11` / `rollremote` | Look of the roll result line ([states.md](states.md#roll-messages)) |

`shot`, `roll1` and `roll2` send a normal `/ja`, so they go through the same
checks as a macro: debuff guard, recast check, roll gear, Luzaf's Ring.

**Common commands that work on COR**

| Command | What it does |
|---|---|
| `cyclestate <Mode>` / `cycle` / `set` / `toggle` / `reset` | Change a mode (what the keys send) |
| `ui ...` | Keybind HUD: show / hide, save position, font, theme, order |
| `am [on/off]` | Auto Medicine |
| `checksets`, `wa`, `wo`, `rf`, `naked`, `reload` | Gear check, wardrobe audit / organizer, refill, unequip all, reload |
| `ls`, `dressup` | Lockstyle again, DressUp handling |
| `craft`, `fish`, `uncraft` | Crafting / fishing sets (write your own set file) |
| `warp`, `w2`, `tph`... , `<command>all`, `mount` | Travel |
| `waltz`, `aoewaltz` | /DNC: Curing Waltz on `<stpc>`, Divine Waltz |
| `lightarts`, `darkarts`, `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: Light / Dark Arts then the Addendum on the next press; Sneak / Invisible / Erase on the party with Accession |
| `jump` | /DRG: Jump / High Jump |
| `watchdog ...`, `debugmidcast` | Midcast watchdog, midcast debug |
| `stealth sneak` / `invi` / `both` ... | Sneak / Invisible on you and your alts |
| `alts ...`, `main`, `altcmds`, `alt <name>` | Dual-box group |
| `combatmode [show / hide / key]` | Combat Mode (weapon lock) on this job |
| `th [show / hide / key / clear]` | Treasure Mode on this job |
| `dw [auto / none / haste / haste2 / max]` | Dual Wield tier |
| `belt` | Obi / Orpheus status |
| `tb ...` | Temporary keys |
| `keyconflicts` (`kc`) | Every key conflict on this job |
| `info <name>`, `jamsg`, `spellmsg`, `wsmsg` | Ability / spell / weaponskill details and chat messages |
| `commands`, `help`, `testcolors` | Built-in command list, help, chat colours |
| `syscheck`, `fulltest`, `trace`, `debugsubjob`, ... | Diagnostics |

## Shared features on this job

| Feature | On COR |
|---|---|
| Weaponskill check | A weaponskill out of range or under 1000 TP is cancelled with a message; TP bonus gear (Moonshade...) from `COR_TP_CONFIG.lua` is added. The gun list in that file is not counted today (see [sets.md](sets.md#weaponskills)) |
| Recast check | An ability or spell still on recast is cancelled with the time left. Quick Draw is left to the game (it has charges). A refused roll can also tell the party when Phantom Roll is back ([states.md](states.md#notes)) |
| Debuff guard | An action you cannot do (silenced, amnesia, ...) is stopped; with Auto Medicine on, Echo Drops / Remedy / Panacea are used |
| Doom | `sets.buff.Doom` goes on and its neck, rings and waist stay locked while Doomed |
| Movement speed | `sets.MoveSpeed` on idle while you move outside town; `sets.Adoulin` in Adoulin, `sets.idle.Town` in other towns (the provided file has no `sets.idle.Town`, so other towns count as the field) |
| Obi / Orpheus | Added to damaging Quick Draws (not Light / Dark Shot), elemental weaponskills (Leaden Salute, Wildfire, Hot Shot, Aeolian Edge...) and subjob nukes, when the day, weather or distance gives enough (`//gs c belt`) |
| Dual Wield tiers | Only if you define `sets.DW` (a commented example is in the template) and hold two weapons (/NIN, /DNC). Held back while a roll is under way |
| Treasure Mode | Off and hidden. `//gs c th show`, then add `sets.TreasureHunter` to your set file (the template has none). In a fight, its pieces wait while a roll is under way |
| Combat Mode | Off and hidden. When shown and On: main, sub and range stay locked, so the knife and gun of your roll set are not swapped in either |
| Weapon without a set | With `equip_without_set = true` in `common/WEAPON_CONFIG.lua`, a Main Weapon value with no set equips that weapon by name (the gun still needs its set) |
| Your own modes | `COR_CUSTOM.lua`: extra modes, keys and gear rules without code. Idle / engaged gear rules wait while a roll is under way |
| Midcast watchdog | Puts your gear back if a cast result never arrives (`FastCast` mode, no key) |
| Lockstyle, macro book | Set on load and on each subjob change |
| Dual-box | Job exchange with your alt (its job counts for the roll job bonus), `alts` orders, macro book per alt job. A COR alt's roll results are also shown on the main |
| Messages | Ability, spell and weaponskill lines in chat (`jamsg` / `spellmsg` / `wsmsg`); rolls have their own line |
| Bullet pouch | After a ranged attack, the pouch of the bullets you wear (in your inventory) is opened when 15 or fewer are left |
| Manual waltz (/DNC) | A Curing Waltz macro on yourself is re-tiered by Mote from your missing HP and TP |

## Configuration files for this job

In `<YourName>/cor/`:

| File | Content |
|---|---|
| `COR_STATES.lua` | Modes, their values and defaults (weapons, Quick Draw, rolls, Luzaf, Hybrid, FastCast) |
| `COR_KEYBINDS.lua` | The job keys above |
| `COR_CUSTOM.lua` | Your own modes, keys and gear rules ([keybinds guide](../../guides/keybinds.md)) |
| `COR_HUD.lua` | HUD section and row order for COR (written by `//gs c ui order` / `roworder`) |
| `COR_LOCKSTYLE.lua` | Lockstyle number, per subjob if you want (template: 3 everywhere) |
| `COR_MACROBOOK.lua` | Macro book / page per subjob and per dual-box alt job (template: book 3 page 1) |
| `COR_TP_CONFIG.lua` | TP bonus pieces ([TP bonus](../war/tp-bonus.md)) |
| `COR_REFILL.lua` (optional) | What `//gs c rf` restocks (bullet pouches, cards...); without it a built-in list is used ([configuration](../../guides/configuration.md#refill-job_refilllua)) |

In `<YourName>/common/`, shared with the other jobs: `COMMON_KEYBINDS.lua`,
`WEAPON_CONFIG.lua`, `DW_CONFIG.lua`, `ELEMENTAL_BELT.lua`,
`RECAST_CONFIG.lua` (party message on a refused roll), `STEALTH_CONFIG.lua`,
`UI_CONFIG.lua` (roll message style), and `treasure_mode.lua` /
`combat_mode.lua` (written by `//gs c th` / `combatmode`). Gear:
`<YourName>/cor/cor_sets.lua`. See [configuration](../../guides/configuration.md).

## More

- [states.md](states.md): each mode in detail, roll messages
- [sets.md](sets.md): set names and automatic gear
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md)
