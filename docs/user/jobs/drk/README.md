# DRK — start here

The one page to open first when you play Dark Knight. It lists every key,
every command and every automatic feature active on DRK, and where each
setting lives. Details are on the linked pages:

- [states.md](states.md): what each mode value does
- [abilities.md](abilities.md): ability gear, Dark Seal and Nether Void
- [sets.md](sets.md): the set names the code looks for, and the gear put on for you

No maintained character plays DRK today: the provided template is complete
but has not been tested in game in its current form.

## Overview

Dark Knight with the provided template gives you:

- **Three keyed modes**: weapon, weaponskill accuracy and the engaged stance
  (PDT or Accu).
- **Aftermath gear**: with Liberator and Aftermath: Lv.3 up, `sets.engaged.AM3`
  replaces your engaged set, and the change happens about 0.1 s after the
  aftermath starts or ends (or when the spell or weaponskill under way ends).
- **Dark Magic gear by spell**: Dread Spikes, Absorb spells, Drain / Aspir
  each find their own set; Dark Seal and Nether Void pieces are added while
  those buffs are up.
- **Movement speed** on idle whenever you move outside a town. In a town the
  town set goes on top of your idle set (in the provided file it is the
  movement set, legs only).

Every mode goes back to its default on each job change, subjob change and
reload.

## All keys on this job

Ctrl = `^`, Alt = `!`, Apps (menu key) = `#`, Win = `@`. The keys come from
the provided template; after cloning, yours are in `<YourName>/drk/`
and `<YourName>/_common/keys/COMMON_KEYBINDS.lua`, and those files win.

| Key | Does | When | Shown in the HUD |
|---|---|---|---|
| `^numpad1` | Cycle Main Weapon: Caladbolg, Liberator, Redemption, Lycurgos, Loxotic | always | yes |
| `^numpad2` | Cycle WS Mode: Normal, Acc | always | yes |
| `^numpad9` | Cycle Hybrid Mode: PDT, Accu | always | yes |
| `#numpad0` | Auto Medicine on / off | always (common key) | yes |
| `!numpad7` | Alts follow this character (press again to stop) | always (common key) | yes |
| `!numpad8` | Alts' automation on / off | always (common key) | yes |
| `!numpad9` | Alts mirror | always (common key) | yes |
| `!z` | Sneak on you and every alt | always (common key) | yes |
| `!x` | Invisible on you and every alt | always (common key) | yes |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **not bound by default**: only after `//gs c combatmode show` | only when shown |
| `!numpad.` | Cycle Treasure Mode: Off, Tag, Full | **not bound by default**: only after `//gs c th show`, and it needs a `sets.TreasureHunter` you add | only when shown |
| `^f1`-`^f8`, `!f1`-`!f8` | Your temporary keys | only the ones you create with `//gs c tb` | no |

Mote-Include (the library under every job) also binds these keys on every
job load. They are not in the HUD. On DRK:

| Key | Mote command | Effect on DRK |
|---|---|---|
| `^f9` | cycle Hybrid Mode | Same as `^numpad9` |
| `@f9` | cycle Weaponskill Mode | Same as `^numpad2` |
| `f9`, `!f9`, `^f11`, `^f12` | cycle Offense / Ranged / Casting / Idle Mode | Nothing: DRK gives these modes a single value |
| `f10`, `f11`, `^f10`, `!f12` | Defense Mode Physical / Magical / cycle / reset | Nothing with the provided template (no `sets.defense`); a `sets.defense` you add reaches idle gear only, never engaged gear, and not outside town in a Hybrid Mode that has its own `sets.idle.<mode>` (PDT in the provided file) |
| `!f10` | Kiting on / off | Nothing unless you add `sets.Kiting` (idle only, and not outside town in a Hybrid Mode that has its own `sets.idle.<mode>`) |
| `f12` | `update user` | Puts your gear back for your current status and prints the current modes |
| `^-`, `^=` | Mote target helpers | Mote's own `<t>` target switching |

Key conflicts for this job, on every subjob: `//gs c keyconflicts`.

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro). Full list
and arguments: [commands guide](../../guides/commands.md).

DRK has no command of its own. The common commands that work on DRK:

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
| `lightarts`, `darkarts`, `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: Light / Dark Arts then the Addendum on the next press; Sneak / Invisible / Erase on the party with Accession |
| `smartbuff` | /WAR: Berserk, Aggressor, Warcry. /SAM: Hasso (two-handed weapon only) and Third Eye. /NIN: Utsusemi: Ni, else Ichi. /DNC: Haste Samba (350 TP). Only what is ready and not already up, 2 s apart; the rest is listed in chat. Other subjobs: a warning |
| `!numpad-` | Jump Auto on / off, shown on /DRG only (see [commands](../../guides/commands.md#combat-helpers)) |
| `watchdog ...`, `debugmidcast` | Midcast watchdog, midcast debug (shows which Dark Magic set each spell used) |
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

| Feature | On DRK |
|---|---|
| Dark Seal / Nether Void | DRK's own, see [abilities.md](abilities.md) |
| Weaponskill check | A weaponskill out of range or under 1000 TP is cancelled with a message; TP bonus gear from `DRK_TP_CONFIG.lua` is added |
| Recast check | An ability or spell still on recast is cancelled with the time left (`RECAST_CONFIG.lua`) |
| Debuff guard | An action you cannot do is stopped; with Auto Medicine on, Echo Drops / Remedy / Panacea are used |
| Doom | `sets.buff.Doom` goes on and its neck, rings and waist stay locked while Doomed; the Aftermath gear change is skipped while Doomed |
| Movement speed | `sets.MoveSpeed` on idle whenever you move, outside a town. In town, `sets.idle.Town` goes on top of your idle set (the template makes it the movement set, legs only), then your weapon, and nothing else |
| Obi / Orpheus | Added to elemental weaponskills (Sanguine Blade, Dark Harvest, Shadow of Death, Infernal Scythe, ...) and damaging spells (Elemental Magic, ...) when the day, weather or distance gives enough (`//gs c belt`) |
| Treasure Hunter | Off and hidden. Needs `//gs c th show` and a `sets.TreasureHunter` you add |
| Combat Mode | Off and hidden. When shown and On: main, sub and range stay locked |
| Weapon without a set | With `equip_without_set = true` in `_common/combat/WEAPON_CONFIG.lua`, a Main Weapon value with no set equips that weapon by name |
| Dual Wield tiers | Only while holding two weapons with a `sets.DW`: not the case with the DRK weapons of the template |
| Your own modes | `DRK_CUSTOM.lua`: extra modes, keys and gear rules without code |
| Midcast watchdog | Puts your gear back if a cast result never arrives |
| Lockstyle, macro book | Set on load and on each subjob change (lockstyle per subjob in the template) |
| Dual-box | Job exchange with your alt, `alts` orders, macro book per alt job |
| Messages | Ability, spell and weaponskill lines in chat (`jamsg` / `spellmsg` / `wsmsg`) |

## Configuration files for this job

In `<YourName>/drk/`:

| File | Content |
|---|---|
| `DRK_STATES.lua` | Modes, their values and defaults (Apocalypse, Foenaria, Naegling are there, commented out) |
| `DRK_KEYBINDS.lua` | The job keys above |
| `DRK_CUSTOM.lua` | Your own modes, keys and gear rules ([keybinds guide](../../guides/keybinds.md)) |
| `DRK_HUD.lua` | HUD section and row order for DRK (written by `//gs c ui order` / `roworder`) |
| `DRK_LOCKSTYLE.lua` | Lockstyle number per subjob |
| `DRK_MACROBOOK.lua` | Macro book / page per subjob and per dual-box alt job |
| `DRK_TP_CONFIG.lua` | TP bonus pieces and weapons ([TP bonus](../war/tp-bonus.md)) |
| `DRK_REFILL.lua` (optional) | What `//gs c rf` restocks; without it a built-in list is used |

In `<YourName>/_common/`, shared with the other jobs: `COMMON_KEYBINDS.lua`,
`ELEMENTAL_BELT.lua`, `RECAST_CONFIG.lua`, `STEALTH_CONFIG.lua`, and
`treasure_mode.lua` / `combat_mode.lua` (written by `//gs c th` /
`combatmode`). Gear: `<YourName>/drk/drk_sets.lua`. See
[configuration](../../guides/configuration.md).

## More

- [states.md](states.md): each mode in detail
- [abilities.md](abilities.md): ability gear, Dark Seal and Nether Void
- [sets.md](sets.md): set names and automatic gear
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md)
