# RUN (Rune Fencer)

The page to open first when you play Rune Fencer. It lists every key, every command
and every shared feature that works on RUN, and the files you can edit.

- What each mode does: [states.md](states.md)
- Every set name RUN reads, and what it puts on by itself: [sets.md](sets.md)

## Overview

RUN is set up as a tank. You pick a stance (PDT or MDT), a weapon (Epeolatry or
Lycurgos) and a grip (Utu or Refined); GearSwap rebuilds your idle and engaged gear from
those three choices. A rune selector feeds `//gs c rune`, and `//gs c aoe` casts a Blue
Magic enmity spell on /BLU. Cures from the subjob pick their set by target (yourself or
someone else). Runes swap no gear with the provided sets, so your tank gear stays on.

RUN ships in the provided template, but no maintained character plays it today: it is
untested in game in its current form.

## All keys on this job

Keys: `^` Ctrl, `!` Alt, `#` Apps (the menu key), `@` Win. The HUD (`//gs c ui`) shows
the keys that are bound now, with the current value of each mode.

| Key | Does | Condition / default |
|---|---|---|
| `^numpad9` | Cycle `HybridMode` (PDT, MDT) | Default PDT |
| `^numpad1` | Cycle `MainWeapon` (Epeolatry, Lycurgos) | Default Epeolatry |
| `^numpad2` | Cycle `SubWeapon` grip (Utu, Refined) | Default Refined; worn with both weapons |
| `^numpad3` | Cycle `RuneMode` (Ignis ... Tenebrae) | Default Ignis; used by `//gs c rune` |
| `#numpad0` | Auto Medicine on / off | Common key, every job |
| `!numpad7` | Your other characters follow you (toggle) | Common key; needs a box group ([dual-box](../../guides/dualbox.md)) |
| `!numpad8` | Other characters' automation on / off | Common key; box group |
| `!numpad9` | Other characters mirror you | Common key; box group |
| `!z` | Sneak on you and every other character of the group | Common key |
| `!x` | Invisible on you and every other character of the group | Common key |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **Hidden and unbound by default**: `//gs c combatmode show` |
| `!numpad.` | Cycle Treasure Mode (Off, Tag, Full) | **Hidden and unbound by default**: `//gs c th show` |
| `f9` | Mote: cycle `OffenseMode` | No effect: RUN has only `Normal` |
| `^f9` | Mote: cycle `HybridMode` | Same as `^numpad9`, with a chat line |
| `!f9` / `@f9` | Mote: cycle `RangedMode` / `WeaponskillMode` | No effect: only `Normal` |
| `f10` / `f11` | Mote: physical / magical defense mode | Lays `sets.defense.PDT` / `sets.defense.MDT` over your idle and engaged gear; the template has neither, so nothing changes |
| `^f10` | Mote: cycle `PhysicalDefenseMode` | Only `PDT` |
| `!f10` | Mote: Kiting on / off | Lays `sets.Kiting` if you define it |
| `^f11` | Mote: cycle `CastingMode` | No effect: only `Normal` |
| `f12` | Mote: re-equip your gear and print the modes | |
| `^f12` | Mote: cycle `IdleMode` | No effect: only `Normal` |
| `!f12` | Mote: defense mode off | |
| `^-` / `^=` | Mote: `<stnpc>` targeting on / off, PC target mode | |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | Free until you bind one |

None of the RUN keys depends on the subjob. Your own modes from `RUN_CUSTOM.lua` add
their keys to this list. Two actions on one key are reported in chat and turn the key
red in the HUD; `//gs c kc` lists every possible conflict on every subjob.

## All commands on this job

Type them as `//gs c <command>`, or bind them to a macro (`/console gs c <command>`).
Details of the shared ones: [commands guide](../../guides/commands.md).

**RUN commands**

| Command | Does |
|---|---|
| `rune` | Uses the `RuneMode` rune on yourself, or prints its recast |
| `aoe` | /BLU: first ready Blue Magic enmity spell on `<stnpc>` (rotation in `RUN_BLU_MAGIC.lua`); none ready: shows the recasts and targets `<stnpc>`; without /BLU: an error, nothing cast |

**Modes and HUD**

| Command | Does |
|---|---|
| `cyclestate <Mode> [reverse]` | Next (or previous) value of a mode; what the keys send |
| `cycle` / `cycleback` / `set <Mode> <Value>` / `toggle` / `reset` | Mote's mode commands (print a chat line) |
| `ui` (+ `on`, `off`, `save`, `font`, `theme`, `order`, `roworder`, `help`...) | The keybind HUD |
| `am` (`automedicine`) `[on/off]` | Auto Medicine |
| `combatmode` (+ `show`, `hide`, `key <key>`, `help`) | Combat Mode on RUN |
| `th` (+ `show`, `hide`, `key <key>`, `clear`, `help`) | Treasure Mode on RUN |
| `dw` (+ `auto`, `none`, `haste`, `haste2`, `max`) | Dual Wield tier (needs `sets.DW`) |
| `belt` | Obi / Orpheus status |

**Gear, inventory and travel**

| Command | Does |
|---|---|
| `checksets` | Set items you do not have |
| `wa`, `wo` (+ `preview`, `scan`, `keep`, `alt`, `recover`...) | Wardrobe audit / organizer |
| `rf` (`refill`) | Restock consumables |
| `naked`, `reload`, `ls` (`lockstyle`), `dressup` | Remove all gear / reload the job / apply the lockstyle again / DressUp handling |
| `craft [variant]`, `craft off`, `fish`, `uncraft` | Crafting and fishing sets |
| `warp`, `w2`, `ret`, `esc`, `tph`..., `sd`, `bt`..., `<command>all`, `warp fix`, `warp help` | Warp spells, rings and destination items |
| `mount` | A random mount, or dismount |

**Combat helpers**

| Command | Does |
|---|---|
| `waltz`, `aoewaltz` | Curing Waltz / Divine Waltz (needs /DNC) |
| `lightarts`, `darkarts`, `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: Light / Dark Arts then the Addendum on the next press; Sneak / Invisible / Erase on the party with Accession |
| `smartbuff` | /WAR: Berserk, Aggressor, Warcry. /SAM: Hasso (two-handed weapon only) and Third Eye. /NIN: Utsusemi: Ni, else Ichi. /DNC: Haste Samba (350 TP). Only what is ready and not already up, 2 s apart; the rest is listed in chat. Other subjobs: a warning |
| `!numpad-` | Jump Auto on / off, shown on /DRG only (see [commands](../../guides/commands.md#combat-helpers)) |
| `jump` | Jump, then High Jump (needs /DRG) |
| `stealth sneak` / `invi` / `both` (+ `self`, `check`, `status`...) | Sneak / Invisible on the whole group (Alt+Z / Alt+X) |
| `watchdog` (+ `on`, `off`, `buffer`, `stats`...) | Midcast watchdog |
| `debugmidcast` | Print the midcast set each spell uses |
| `debugprecast` | Print the Fast Cast set each spell uses (RUN is one of the three jobs that read it) |

**Dual-box, keys and information**

| Command | Does |
|---|---|
| `alts on` / `off` / `toggle` / `follow` / `mirror` / `do <cmd>` / `window`, `main` | Box group orders |
| `altcmds`, `alt <name>`, `altsync`, `altbuffs` | The alt's commands and buff reports |
| `tb <key> <action> [target]`, `tb list` / `del` / `clear` / `help` | Temporary keys |
| `kc` (`keyconflicts`) | Every key conflict RUN can meet |
| `info <name>` | Ability, spell or weaponskill details |
| `jamsg` / `spellmsg` / `wsmsg` `[full / on / off]` | How much chat each action prints |
| `help`, `commands` | Built-in help and command list |
| `syscheck`, `fulltest`, `debugsubjob`, `debugstate`, `trace on/off`, `testcolors` | Diagnostics |

## Shared features on this job

| Feature | On RUN |
|---|---|
| Movement speed | `sets.MoveSpeed` is added to your idle gear while you run outside town; in town you wear `sets.idle.Town` (Adoulin: `sets.Adoulin`) with your weapon and grip |
| Sneak / Invisible | Alt+Z / Alt+X cover you and the group; RUN itself uses oils and powders, or its subjob's spell or Spectral Jig ([guide](../../guides/stealth.md)) |
| Warp | Every warp command; RUN has no warp spell, so rings and items are used |
| Waltz / Jump | `waltz`, `aoewaltz` on /DNC; `jump` on /DRG (no automatic Jump on RUN) |
| Combat Mode | Hidden by default. Shown, On keeps main, sub and range where they are (no TP loss from a set swap) |
| Treasure Mode | Hidden by default, and the template has no `sets.TreasureHunter`: add the set, then `//gs c th show` |
| Dual Wield tiers | Only with two one-handed weapons and a `sets.DW` family, which the template does not have |
| Obi / Orpheus | Automatic on elemental weaponskills (Herculean Slash) and damaging spells. Not on Lunge / Swipe, which are job abilities |
| Your own modes (`RUN_CUSTOM.lua`) | Modes with a key and gear rules, without code; empty by default ([keybinds guide](../../guides/keybinds.md#your-own-modes-job_customlua)) |
| Refill | `//gs c rf` restocks from the list in `RUN_REFILL.lua`, a file you create; without it a default list is used ([configuration](../../guides/configuration.md#refill-job_refilllua)) |
| Doom | `sets.buff.Doom` goes on and neck, rings and waist stay locked until Doom is gone |
| Auto Medicine | Echo Drops / Remedy when a debuff blocks your action (Apps+Numpad0) |
| Recast announce | An action refused on recast can tell the party, per action, from `_common/combat/RECAST_CONFIG.lua` |
| TP bonus | Moonshade Earring added to a weaponskill only when it reaches the next TP step; Lionheart counts +500 ([TP bonus](../war/tp-bonus.md)) |
| Automatic abilities | None on RUN (no ability fired before a spell or weaponskill) |

## Configuration files for this job

In `<YourName>/run/`:

| File | What you change there |
|---|---|
| `RUN_STATES.lua` | Modes, their values and defaults |
| `RUN_KEYBINDS.lua` | The RUN keys |
| `RUN_CUSTOM.lua` | Your own modes, keys and gear rules (empty by default) |
| `RUN_HUD.lua` | Order of the HUD sections and rows on RUN (also written by `//gs c ui order` / `roworder`) |
| `RUN_BLU_MAGIC.lua` | Blue Magic rotation for `//gs c aoe` |
| `RUN_LOCKSTYLE.lua` | Lockstyle number, per subjob if you want (3 in the template) |
| `RUN_MACROBOOK.lua` | Macro book and page per subjob, and per dual-box alt job |
| `RUN_TP_CONFIG.lua` | TP bonus pieces and weapons |
| `RUN_REFILL.lua` | Not provided: create it for `//gs c rf` |

Files shared by every job are in `<YourName>/_common/`: `COMMON_KEYBINDS.lua`,
`combat_mode.lua`, `treasure_mode.lua`, `RECAST_CONFIG.lua`, `STEALTH_CONFIG.lua`,
`DW_CONFIG.lua`, `ELEMENTAL_BELT.lua`, `UI_CONFIG.lua` ([configuration](../../guides/configuration.md)).
Your sets are in `<YourName>/run/run_sets.lua`.

## See also

- [states.md](states.md): what each mode does
- [sets.md](sets.md): set names and automatic gear
- [Commands](../../guides/commands.md), [keybinds](../../guides/keybinds.md),
  [set names for every job](../../guides/sets.md), [all jobs](../README.md)
