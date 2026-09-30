# PLD (Paladin)

The page to open first when you play Paladin. It lists every key, every command and
every shared feature that works on PLD, and the files you can edit.

- What each mode does, stance by stance: [states.md](states.md)
- Every set name PLD reads, and what it puts on by itself: [sets.md](sets.md)

## Overview

PLD is set up as a tank. A stance mode (`HybridMode`) chooses your idle and engaged
sets; a weapon mode chooses the sword, and in Sortie and under /SCH the shield follows
the weapon. Two weaponskill slots follow the weapon in hand, so two macros cover every
sword. GearSwap also fires Divine Emblem before Flash and Majesty before Protect III-V
and Cure III / IV, picks your cure set by target, and swaps to a SIRD Phalanx set when
you ask for it.

The stance list depends on your subjob:

| Subjob | Stances (default in **bold**) | Notes |
|---|---|---|
| Any but /SCH | **PDT**, MDT, Sortie | Sortie narrows the weapon and rune lists and turns Phalanx SIRD On |
| /SCH | DPS, **Tanking**, Hoxne | A Sortie-only setup: Tanking always holds Burtgang + Aegis, Hoxne keeps the Hoxne Ampulla in the ammo slot |

## All keys on this job

Keys: `^` Ctrl, `!` Alt, `#` Apps (the menu key), `@` Win. The HUD (`//gs c ui`) shows
the keys that are bound now, with the current value of each mode.

| Key | Does | Condition / default |
|---|---|---|
| `^numpad9` | Cycle `HybridMode` (your stance) | Every subjob; the list and default depend on the subjob (above) |
| `^numpad1` | Cycle `MainWeapon` | Default Excalibur (/SCH: Naegling). **Unbound and hidden in the /SCH Tanking stance**, the /SCH default |
| `^numpad2` | Cycle `PhalanxSIRD` (Off, On) | Every subjob but /SCH. Default Off (On in the Sortie stance) |
| `^numpad2` | Cycle `Regen` (Off, On) | /SCH only. Default Off |
| `^numpad3` | Cycle `RuneMode` (Ignis ... Tenebrae) | /RUN only. Default Ignis; used by `//gs c rune` |
| `^numpad3` | Cycle `PhalanxSIRD` (Off, On) | /SCH only. Default On |
| `^numpad4` | Cycle `Xp` (Off, On) | /RDM only. Default Off |
| `^numpad5` | Cycle `WS1`: the weaponskill of `//gs c ws1` | Every subjob; the list follows the weapon in hand |
| `^numpad6` | Cycle `WS2`: the weaponskill of `//gs c ws2` | Every subjob; the list follows the weapon in hand |
| `^numpad7` | Nothing (an old PLD key, unbound at every load) | Free |
| `#numpad0` | Auto Medicine on / off | Common key, every job |
| `!numpad7` | Your other characters follow you (toggle) | Common key; needs a box group ([dual-box](../../guides/dualbox.md)) |
| `!numpad8` | Other characters' automation on / off | Common key; box group |
| `!numpad9` | Other characters mirror you | Common key; box group |
| `!z` | Sneak on you and every other character of the group | Common key |
| `!x` | Invisible on you and every other character of the group | Common key |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **Hidden and unbound by default**: `//gs c combatmode show` |
| `!numpad.` | Cycle Treasure Mode (Off, Tag, Full) | **Hidden and unbound by default**: `//gs c th show` |
| `f9` | Mote: cycle `OffenseMode` | No effect: PLD has only `Normal` |
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

Two PLD modes have no key: `SneakInviAOE` and `FastCast` (see [states.md](states.md)).
Your own modes from `PLD_CUSTOM.lua` add their keys to this list. Two actions on one key are
reported in chat and turn the key red in the HUD; `//gs c kc` lists every possible
conflict on every subjob.

## All commands on this job

Type them as `//gs c <command>`, or bind them to a macro (`/console gs c <command>`).
Details of the shared ones: [commands guide](../../guides/commands.md).

**PLD commands**

| Command | Does |
|---|---|
| `ws` / `ws1` / `ws2` | Uses the weaponskill in that slot for the weapon in hand, on `<t>` (`ws` = slot 1). `ws3`...`ws9` only warn |
| `rune` | Uses the `RuneMode` rune on yourself, or prints its recast. Meant for /RUN: the command does not check the subjob |
| `aoe` | /BLU: first ready Blue Magic enmity spell on `<stnpc>` (rotation in `PLD_BLU_MAGIC.lua`); none ready: shows the recasts and targets `<stnpc>`; without /BLU: an error, nothing cast |
| `aoe sneak` / `aoe invi` (`invisible`) | /SCH: Light Arts + Accession, then the spell on yourself for the party. With `SneakInviAOE` Off: no stratagem, cast on `<stal>` |
| `aoe erase` | /SCH: Light Arts + Addendum: White (+ Accession if a charge is left), then Erase |
| `lightarts` | /SCH: Light Arts, then Addendum: White on the next press |

**Modes and HUD**

| Command | Does |
|---|---|
| `cyclestate <Mode> [reverse]` | Next (or previous) value of a mode; what the keys send |
| `cycle` / `cycleback` / `set <Mode> <Value>` / `toggle` / `reset` | Mote's mode commands (print a chat line). `set Regen On` / `Off` is handy in a macro |
| `ui` (+ `on`, `off`, `save`, `font`, `theme`, `order`, `roworder`, `help`...) | The keybind HUD |
| `am` (`automedicine`) `[on/off]` | Auto Medicine |
| `combatmode` (+ `show`, `hide`, `key <key>`, `help`) | Combat Mode on PLD |
| `th` (+ `show`, `hide`, `key <key>`, `clear`, `help`) | Treasure Mode on PLD |
| `dw` (+ `auto`, `none`, `haste`, `haste2`, `max`) | Dual Wield tier (needs `sets.DW`) |
| `belt` | Obi / Orpheus status |

**Gear, inventory and travel**

| Command | Does |
|---|---|
| `checksets` | Set items you do not have |
| `wa`, `wo` (+ `preview`, `scan`, `keep`, `alt`, `recover`...) | Wardrobe audit / organizer. `wo` also frees the Hoxne ammo lock: choose the stance again afterwards |
| `rf` (`refill`) | Restock consumables |
| `naked`, `reload`, `ls` (`lockstyle`), `dressup` | Remove all gear / reload the job / apply the lockstyle again / DressUp handling |
| `craft [variant]`, `craft off`, `fish`, `uncraft` | Crafting and fishing sets |
| `warp`, `w2`, `ret`, `esc`, `tph`..., `sd`, `bt`..., `<command>all`, `warp fix`, `warp help` | Warp spells, rings and destination items |
| `mount` | A random mount, or dismount |

**Combat helpers**

| Command | Does |
|---|---|
| `waltz`, `aoewaltz` | Curing Waltz / Divine Waltz (needs /DNC) |
| `jump` | Jump, then High Jump (needs /DRG) |
| `stealth sneak` / `invi` / `both` (+ `self`, `check`, `status`...) | Sneak / Invisible on the whole group (Alt+Z / Alt+X) |
| `sortie <target>` / `escort` / `off` / `list` / `help` | The author's Sortie orders for his own pair of characters (they also give orders to a GEO alt). On PLD they also set the /SCH stance (DPS or Tanking) and Phalanx SIRD: Off for `aminon` / `aminontest`, On for every other target (`gab` changes neither); `escort` turns Regen On on /SCH |
| `watchdog` (+ `on`, `off`, `buffer`, `stats`...) | Midcast watchdog |
| `debugmidcast` | Print the midcast set each spell uses |

**Dual-box, keys and information**

| Command | Does |
|---|---|
| `alts on` / `off` / `toggle` / `follow` / `mirror` / `do <cmd>` / `window`, `main` | Box group orders |
| `altcmds`, `alt <name>`, `altsync`, `altbuffs` | The alt's commands and buff reports. `lightarts` runs on PLD when you have /SCH, and goes to your alt otherwise: `alt lightarts` always sends it to the alt's |
| `tb <key> <action> [target]`, `tb list` / `del` / `clear` / `help` | Temporary keys |
| `kc` (`keyconflicts`) | Every key conflict PLD can meet |
| `info <name>` | Ability, spell or weaponskill details |
| `jamsg` / `spellmsg` / `wsmsg` `[full / on / off]` | How much chat each action prints |
| `help`, `commands` | Built-in help and command list |
| `syscheck`, `fulltest`, `debugsubjob`, `debugstate`, `trace on/off`, `testcolors` | Diagnostics |

## Shared features on this job

| Feature | On PLD |
|---|---|
| Automatic abilities | Divine Emblem before Flash; Majesty before Protect III / IV / V and Cure III / IV. Each is fired only when ready and its buff is down, then the spell is sent again once the buff is up. Tried once per spell |
| Enmity in Sortie | In the Sortie stance and the /SCH Tanking stance, spells that wear `sets.FullEnmity` wear `sets.EnmityMax`, and job abilities get the pieces `sets.EnmityMax` adds ([sets.md](sets.md)) |
| Hoxne stance (/SCH) | The ammo slot stays on the Hoxne Ampulla while the stance is on; freed when you leave it, change job, reload or run `//gs c wo` |
| Movement speed | `sets.MoveSpeed` is added to your idle gear while you run outside town; in town you wear `sets.idle.Town` (Adoulin: `sets.Adoulin`) with your weapon and shield |
| Sneak / Invisible | Alt+Z / Alt+X cover you and the group. With /SCH and a stratagem charge, PLD covers the whole group with Accession unless `SneakInviAOE` is Off ([guide](../../guides/stealth.md)) |
| Warp | Every warp command; PLD has no warp spell, so rings and items are used |
| Waltz / Jump | `waltz`, `aoewaltz` on /DNC; `jump` on /DRG (no automatic Jump on PLD) |
| Combat Mode | Hidden by default. Shown, On keeps main, sub and range where they are (no TP loss from a set swap) |
| Treasure Mode | Hidden by default, and the template has no `sets.TreasureHunter`: add the set, then `//gs c th show` |
| Dual Wield tiers | Only with two weapons (/NIN or /DNC) and a `sets.DW` family, which the template does not have |
| Obi / Orpheus | Automatic on elemental weaponskills (Sanguine Blade, Aeolian Edge...) and damaging spells (Banish, Banishga, magical Blue Magic) |
| Your own modes (`PLD_CUSTOM.lua`) | Modes with a key and gear rules, without code; empty by default ([keybinds guide](../../guides/keybinds.md#your-own-modes-job_customlua)) |
| Refill | `//gs c rf` restocks from the list in `PLD_REFILL.lua`, a file you create; without it a default list is used ([configuration](../../guides/configuration.md#refill-job_refilllua)) |
| Doom | `sets.buff.Doom` goes on and neck, rings and waist stay locked until Doom is gone |
| Auto Medicine | Echo Drops / Remedy when a debuff blocks your action (Apps+Numpad0) |
| Recast announce | An action refused on recast can tell the party, per action, from `_common/combat/RECAST_CONFIG.lua` |
| TP bonus | Moonshade Earring added to a weaponskill only when it reaches the next TP step; Sequence counts +500 ([TP bonus](../war/tp-bonus.md)) |

## Configuration files for this job

In `<YourName>/pld/`:

| File | What you change there |
|---|---|
| `PLD_STATES.lua` | Modes, their values and defaults, the Sortie and /SCH lists |
| `PLD_KEYBINDS.lua` | The PLD keys |
| `PLD_CUSTOM.lua` | Your own modes, keys and gear rules (empty by default) |
| `PLD_HUD.lua` | Order of the HUD sections and rows on PLD (also written by `//gs c ui order` / `roworder`) |
| `PLD_WS_CONFIG.lua` | The weaponskills of each weapon for the two slots |
| `PLD_BLU_MAGIC.lua` | Blue Magic rotation for `//gs c aoe` |
| `PLD_LOCKSTYLE.lua` | Lockstyle number, per subjob if you want (3 in the template) |
| `PLD_MACROBOOK.lua` | Macro book and page per subjob, and per dual-box alt job |
| `PLD_TP_CONFIG.lua` | TP bonus pieces and weapons |
| `PLD_REFILL.lua` | Not provided: create it for `//gs c rf` |

Files shared by every job are in `<YourName>/_common/`: `COMMON_KEYBINDS.lua`,
`combat_mode.lua`, `treasure_mode.lua`, `RECAST_CONFIG.lua`, `STEALTH_CONFIG.lua`,
`DW_CONFIG.lua`, `ELEMENTAL_BELT.lua`, `UI_CONFIG.lua` ([configuration](../../guides/configuration.md)).
Your sets are in `<YourName>/pld/pld_sets.lua`.

## See also

- [states.md](states.md): what each mode and stance does
- [sets.md](sets.md): set names and automatic gear
- [Commands](../../guides/commands.md), [keybinds](../../guides/keybinds.md),
  [set names for every job](../../guides/sets.md), [all jobs](../README.md)
