# WAR (Warrior)

The page to open first when you play Warrior. It lists every key, every command and
every shared feature that works on WAR, and the files you can edit.

- What each mode does: [states.md](states.md)
- Every set name WAR reads, and what it puts on by itself: [sets.md](sets.md)
- TP bonus pieces (Moonshade, Boii, Chango, Warcry, Fencer): [tp-bonus.md](tp-bonus.md)

## Overview

WAR is set up as a damage dealer. A weapon mode picks the weapon set, and after each
load it is set to the weapon you are actually holding. Five weaponskill slots follow the
weapon, so five macros cover every weapon. `//gs c berserk` and `//gs c defender` fire
the whole Warrior buff chain (plus Hasso / Seigan and Third Eye on /SAM) in one press. On /DRG, a weaponskill pressed under 1000 TP is held back while
Jump builds the TP. Retaliation is cancelled by itself after 5 seconds of running out
of combat.

## All keys on this job

Keys: `^` Ctrl, `!` Alt, `#` Apps (the menu key), `@` Win. The HUD (`//gs c ui`) shows
the keys that are bound now, with the current value of each mode.

| Key | Does | Condition / default |
|---|---|---|
| `^numpad1` | Cycle `MainWeapon` (Ukonvasara, Naegling, NaeglingKC, Shining, Chango, Ikenga, Loxotic) | After loading: the weapon in your hands (Ukonvasara if it matches no set) |
| `^numpad9` | Cycle `HybridMode` (PDT, Normal) | Default PDT |
| `^numpad2` | Cycle `JumpAuto` (On, Off) | Default Off. /DRG only (hidden on other subjobs) |
| `^numpad3` | Cycle `WS1`: the weaponskill of `//gs c ws1` | The list follows the weapon |
| `^numpad4` | Cycle `WS2` (`//gs c ws2`) | Same |
| `^numpad5` | Cycle `WS3` (`//gs c ws3`) | Same |
| `^numpad6` | Cycle `WS4` (`//gs c ws4`) | Same |
| `^numpad7` | Cycle `WS5` (`//gs c ws5`) | Same; `None` when the weapon has fewer weaponskills |
| `#numpad0` | Auto Medicine on / off | Common key, every job |
| `!numpad7` | Your other characters follow you (toggle) | Common key; needs a box group ([dual-box](../../guides/dualbox.md)) |
| `!numpad8` | Other characters' automation on / off | Common key; box group |
| `!numpad9` | Other characters mirror you | Common key; box group |
| `!z` | Sneak on you and every other character of the group | Common key |
| `!x` | Invisible on you and every other character of the group | Common key |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **Hidden and unbound by default**: `//gs c combatmode show` |
| `!numpad.` | Cycle Treasure Mode (Off, Tag, Full) | **Hidden and unbound by default**: `//gs c th show` |
| `f9` | Mote: cycle `OffenseMode` | No effect: WAR has only `Normal` |
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

None of the WAR keys depends on the subjob; `^numpad8` is free. Your own modes from
`WAR_CUSTOM.lua` add their keys to this list. Two actions on one key are reported in
chat and turn the key red in the HUD; `//gs c kc` lists every possible conflict on every
subjob.

## All commands on this job

Type them as `//gs c <command>`, or bind them to a macro (`/console gs c <command>`).
Details of the shared ones: [commands guide](../../guides/commands.md).

**WAR commands**

| Command | Does |
|---|---|
| `ws1` ... `ws5` | Uses the weaponskill in that slot for the current weapon, on `<t>`. `ws6`...`ws9` only warn |
| `berserk` | Berserk, Aggressor, Retaliation, Restraint, Warcry (or Blood Rage when Warcry is on recast), the ready ones, 2 s apart; /SAM adds Hasso and Third Eye |
| `defender` | The same chain with Defender instead of Berserk; /SAM adds Seigan instead of Hasso |
| `thirdeye` | /SAM: Hasso (Seigan if Defender is up) and Third Eye. On another subjob: a warning, nothing is sent |
| `tp` | /SAM: Meditate. /DRG: Jump, then High Jump if TP is still under 1000. Other subjobs: a warning |
| `retalstatus` | Retaliation auto-cancel tracker |
| `debugretaliation` (`debugretal`) | Trace the Retaliation tracker on every movement tick (again to stop) |

`berserk`, `defender` and `thirdeye` run on WAR even if your dual-box alt has a command
with the same name; `//gs c alt berserk` sends the alt's.

**Modes and HUD**

| Command | Does |
|---|---|
| `cyclestate <Mode> [reverse]` | Next (or previous) value of a mode; what the keys send |
| `cycle` / `cycleback` / `set <Mode> <Value>` / `toggle` / `reset` | Mote's mode commands (print a chat line) |
| `ui` (+ `on`, `off`, `save`, `font`, `theme`, `order`, `roworder`, `help`...) | The keybind HUD |
| `am` (`automedicine`) `[on/off]` | Auto Medicine |
| `combatmode` (+ `show`, `hide`, `key <key>`, `help`) | Combat Mode on WAR |
| `th` (+ `show`, `hide`, `key <key>`, `clear`, `help`) | Treasure Mode on WAR |
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
| `watchdog` (+ `on`, `off`, `buffer`, `stats`...) | Midcast watchdog (WAR does not feed it: no effect on WAR's own casts) |
| `debugmidcast` | Print the midcast set each spell uses |

**Dual-box, keys and information**

| Command | Does |
|---|---|
| `alts on` / `off` / `toggle` / `follow` / `mirror` / `do <cmd>` / `window`, `main` | Box group orders |
| `altcmds`, `alt <name>`, `altsync`, `altbuffs` | The alt's commands and buff reports |
| `tb <key> <action> [target]`, `tb list` / `del` / `clear` / `help` | Temporary keys |
| `kc` (`keyconflicts`) | Every key conflict WAR can meet |
| `info <name>` | Ability, spell or weaponskill details |
| `jamsg` / `spellmsg` / `wsmsg` `[full / on / off]` | How much chat each action prints |
| `help`, `commands` | Built-in help and command list |
| `syscheck`, `fulltest`, `debugsubjob`, `debugstate`, `trace on/off`, `testcolors` | Diagnostics |

## Shared features on this job

| Feature | On WAR |
|---|---|
| Buff chains | `berserk` / `defender` send only the abilities that are ready and not already up, and list the others in chat |
| Automatic Jump (/DRG) | With `JumpAuto` On, a weaponskill under 1000 TP is cancelled, Jump (then High Jump) goes out, and the weaponskill is sent again. If TP is still short, the weaponskill is refused as usual. A weaponskill out of range is refused without using a jump |
| Retaliation auto-cancel | Retaliation up, not engaged, and 5 s of continuous running: `cancel Retaliation` is sent (needs the Windower `Cancel` addon) |
| Engaged set choice | Kraken Club, Aftermath: Lv.3 on Ukonvasara and weapon-named engaged sets win over the stance ([states.md](states.md#notes)); Aftermath: Lv.3 gained or lost re-dresses you about 0.1 s later (not while Doomed; during a spell or weaponskill, when it ends) |
| Hoxne stance | Not in the template. If you add `Hoxne` to `HybridMode` (and its sets), the Hoxne Ampulla goes on and the ammo slot stays on it while it is selected, as on PLD |
| Movement speed | `sets.MoveSpeed` is added to your idle gear while you run outside town; in town you wear `sets.idle.Town` (Adoulin: `sets.Adoulin`) with your weapon |
| Sneak / Invisible | Alt+Z / Alt+X cover you and the group; WAR itself uses oils and powders, or its subjob's spell or Spectral Jig ([guide](../../guides/stealth.md)) |
| Warp | Every warp command; WAR has no warp spell, so rings and items are used |
| Waltz / Jump | `waltz`, `aoewaltz` on /DNC; `jump` and `tp` on /DRG |
| Combat Mode | Hidden by default. Shown, On keeps main, sub and range where they are (no TP loss from a set swap) |
| Treasure Mode | Hidden by default, and the template has no `sets.TreasureHunter`: add the set, then `//gs c th show` |
| Dual Wield tiers | With two one-handed weapons (/NIN or /DNC) and a `sets.DW` family, which the template does not have |
| Obi / Orpheus | Automatic on elemental weaponskills (Sanguine Blade...) |
| Your own modes (`WAR_CUSTOM.lua`) | Modes with a key and gear rules, without code; empty by default ([keybinds guide](../../guides/keybinds.md#your-own-modes-job_customlua)) |
| Refill | `//gs c rf` restocks from the list in `WAR_REFILL.lua`, a file you create; without it a default list is used ([configuration](../../guides/configuration.md#refill-job_refilllua)) |
| Doom | `sets.buff.Doom` goes on and neck, rings and waist stay locked until Doom is gone |
| Auto Medicine | Echo Drops / Remedy when a debuff blocks your action (Apps+Numpad0) |
| Recast announce | An action refused on recast can tell the party, per action, from `_common/combat/RECAST_CONFIG.lua` |
| TP bonus | Moonshade Earring and Boii Cuisses +3 added only when they reach the next TP step; Chango, Warcry (Savagery merits) and Fencer counted ([TP bonus](tp-bonus.md)) |
| Subjob spells | Cures and enhancing spells from /WHM or /RDM keep the gear you had on: the template has no Fast Cast or midcast set for them (add `sets.precast.FC`, `sets.midcast['Healing Magic']`...) |

## Configuration files for this job

In `<YourName>/war/`:

| File | What you change there |
|---|---|
| `WAR_STATES.lua` | Modes, their values and defaults (add a weapon or a stance here) |
| `WAR_KEYBINDS.lua` | The WAR keys |
| `WAR_CUSTOM.lua` | Your own modes, keys and gear rules (empty by default) |
| `WAR_HUD.lua` | Order of the HUD sections and rows on WAR (also written by `//gs c ui order` / `roworder`) |
| `WAR_WS_CONFIG.lua` | The weaponskills of each weapon for the five slots |
| `WAR_TP_CONFIG.lua` | TP bonus pieces and weapons, your Savagery merits, Agoge Mask and Fencer job point gifts |
| `WAR_LOCKSTYLE.lua` | Lockstyle number, per subjob if you want (4 in the template) |
| `WAR_MACROBOOK.lua` | Macro book and page per subjob, and per dual-box alt job |
| `WAR_REFILL.lua` | Not provided: create it for `//gs c rf` |

Files shared by every job are in `<YourName>/_common/`: `COMMON_KEYBINDS.lua`,
`combat_mode.lua`, `treasure_mode.lua`, `RECAST_CONFIG.lua`, `STEALTH_CONFIG.lua`,
`DW_CONFIG.lua`, `ELEMENTAL_BELT.lua`, `UI_CONFIG.lua` ([configuration](../../guides/configuration.md)).
Your sets are in `<YourName>/war/war_sets.lua`.

## See also

- [states.md](states.md): what each mode does
- [sets.md](sets.md): set names and automatic gear
- [tp-bonus.md](tp-bonus.md): TP bonus pieces, for every job
- [Commands](../../guides/commands.md), [keybinds](../../guides/keybinds.md),
  [set names for every job](../../guides/sets.md), [all jobs](../README.md)
