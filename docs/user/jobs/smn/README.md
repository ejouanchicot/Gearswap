# SMN — Summoner: start here

The one page to open first when you play Summoner. It lists every key and
every command that works on SMN, and every shared feature that acts on your
gear or your actions, then points to the details:

- [states.md](states.md): what each mode value does;
- [sets.md](sets.md): every set name the SMN code reads, and what goes on by itself.

> **Getting SMN.** Pick SMN in the job list of the clone script. The
> provided set file is an empty skeleton except for the Fast Cast set: fill
> it with your gear.

## Overview

SMN gears your avatar's Blood Pacts by kind, not by name:

- every Blood Pact is sorted into Rage (Physical, Magical, Hybrid, Astral
  Flow) or Ward (Buff, Debuff, Heal), and the matching
  `sets.pet_midcast.BPRage.<kind>` / `sets.pet_midcast.BPWard.<kind>` goes on
  when you give the order and again when the avatar acts;
- while an avatar is out, your idle is `sets.idle.Avatar` by itself; while
  Avatar's Favor is up, `sets.buff["Avatar's Favor"]` goes on top of it (the
  mode follows the buff by itself);
- one-word commands summon an avatar, use a Blood Pact on the right target,
  or use an SMN ability;
- a Summoning Magic skill-up loop (summon Siren, Release, repeat);
- about 10 s after a load, Carbuncle is summoned if no avatar is out.

## All keys on this job

Key notation: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Windows.

### SMN keys (`SMN_KEYBINDS.lua`)

No SMN key depends on the subjob.

| Key | Mode | Default | What it changes |
|---|---|---|---|
| Ctrl+Numpad1 `^numpad1` | `IdleMode` | Normal | Idle set: Normal or DT (with an avatar out: `sets.idle.Avatar`, or `sets.idle.Avatar.DT` in DT if you write it) |
| Ctrl+Numpad2 `^numpad2` | `CastingMode` | Normal | Normal or Resistant: the `.Resistant` versions of your spell sets, if you write them |
| Ctrl+Numpad3 `^numpad3` | `AvatarFavor` | Off | On: `sets.buff["Avatar's Favor"]` goes on top of your idle (in town the town set goes on top of both, as always). Also switched on and off by the Avatar's Favor buff |

The full value lists are in [states.md](states.md). The `AvatarFavor` row has
been reported missing from the HUD; the key works either way.

### Keys every job gets

| Key | Does | Shown by default |
|---|---|---|
| Apps+Numpad0 `#numpad0` | Auto Medicine on / off (Echo Drops, Remedy... used when a debuff blocks your action) | yes |
| Alt+Numpad7 `!numpad7` | Your alts follow you (press again to stop) | yes |
| Alt+Numpad8 `!numpad8` | Your alts' automation on / off | yes |
| Alt+Numpad9 `!numpad9` | Alts mirror | yes |
| Alt+Z `!z` | Sneak on you and every alt | yes |
| Alt+X `!x` | Invisible on you and every alt | yes |
| Alt+Numpad0 `!numpad0` | Combat Mode (weapon lock) | no: hidden and unbound until `//gs c combatmode show` |
| Alt+Numpad. `!numpad.` | Treasure Mode (Off / Tag / Full) | no: hidden and unbound until `//gs c th show` |
| Ctrl+F1-F8, Alt+F1-F8 | Temporary keys you make with `//gs c tb` | only once you make one |
| Your own keys | Modes you add in `SMN_CUSTOM.lua` (examples only in the template) | yes |

The common keys come from `<YourName>/_common/keys/COMMON_KEYBINDS.lua`.

### Mote-Include keys (always bound, not on the HUD)

| Key | Command | On SMN |
|---|---|---|
| Ctrl+F12 | `cycle IdleMode` | Same as Ctrl+Numpad1 |
| Ctrl+F11 | `cycle CastingMode` | Same as Ctrl+Numpad2 |
| F12 | `update user` | Puts your current gear back and prints the modes |
| F10 / F11, Ctrl+F10, Alt+F12, Alt+F10 | Defense modes, reset, Kiting | Nothing while your `IdleMode` set exists: SMN's idle replaces Mote's defense and Kiting layers |
| F9, Ctrl+F9, Alt+F9, Win+F9 | Offense, Hybrid, Ranged, Weaponskill mode | Nothing: those modes keep their single value `Normal` on SMN |
| Ctrl+- / Ctrl+= | Mote's target selection modes | Mote's own behaviour |

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro).

### SMN commands

| Command | What it does |
|---|---|
| `smn summon <avatar>` | Summons an avatar or spirit by name, any case: `ifrit`, `cait sith` or `caitsith`, `fire spirit`... |
| `smn bp <pact>` | Uses a Blood Pact: on you for a Ward buff or heal, on your target for every other pact. Type the pact with its capitals (`Healing Ruby`): in lower case it is not recognised and goes on `<t>` |
| `smn astralflow` / `astralconduit` / `apogee` / `siphon` / `manacede` / `favor` / `release` / `retreat` | That ability on you (`siphon` = Elemental Siphon, `favor` = Avatar's Favor) |
| `smn assault` | Assault on your target |
| `skillup` | Starts or stops the skill-up loop: Siren, Release 5 s later, next Siren 1.5 s after the Release |
| `skillup start` / `stop` / `status` | Start / stop / show the loop |
| `skillup <1-60>` | Sets the wait after Release (seconds) and restarts the loop |

The loop stops by itself on a reload, a job change, or if you die.

### Common commands that work here

One line each; details in the [commands guide](../../guides/commands.md).

| Command | What it does |
|---|---|
| `ui` (`ui on/off/save/help`, `ui order ...`) | Keybind HUD: show / hide, save position, look, row order |
| `cyclestate <Mode> [reverse]` | Next / previous value of a mode (what the keys send) |
| `cycle` / `cycleback` / `set` / `toggle` / `reset <Mode>` | Mote-Include's mode commands |
| `am` (`automedicine`) `[on/off]` | Auto Medicine |
| `combatmode [show/hide/key]` | Combat Mode status, HUD row, key |
| `th [show/hide/key/clear]` | Treasure Mode status, HUD row, key, forget tagged mobs |
| `belt` | Obi / Orpheus: on or off, belts found, today's bonuses |
| `dw [auto/none/haste/haste2/max]` | Dual Wield tier (only matters with two weapons) |
| `checksets` | Set pieces you do not have |
| `wa` (`wardrobeaudit`) | Wardrobe pieces no set uses |
| `wo` (`worganize`) `[preview/scan/keep/alt/recover]` | Wardrobe organizer |
| `rf` (`refill`) | Restock consumables (also on your other boxes) |
| `naked` (`equip naked`) | Remove every piece |
| `reload` | Reload the job file |
| `ls` (`lockstyle`), `dressup` | Lockstyle again; DressUp handling on / off |
| `craft [variant/off]`, `fish`, `uncraft` | Crafting / fishing set, and back |
| `warp` (`w`), `w2`, `ret`, `esc`, `tph`... `sd`, `bt`... | Warp spells, rings and destination items; add `all` for every box |
| `warp fix` / `warp help` / `warp status` | Release the ring slot / help / state |
| `mount` | Random mount, or dismount |
| `waltz` / `aoewaltz` | /DNC only: Curing Waltz / Divine Waltz |
| `lightarts`, `darkarts`, `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: Light / Dark Arts then the Addendum on the next press; Sneak / Invisible / Erase on the party with Accession |
| `smartbuff` | /WAR: Berserk, Aggressor, Warcry. /SAM: Hasso (two-handed weapon only) and Third Eye. /NIN: Utsusemi: Ni, else Ichi. /DNC: Haste Samba (350 TP). Only what is ready and not already up, 2 s apart; the rest is listed in chat. Other subjobs: a warning |
| `!numpad-` | Jump Auto on / off, shown on /DRG only (see [commands](../../guides/commands.md#combat-helpers)) |
| `jump` | /DRG only: jumps |
| `stealth sneak/invi/both [self]`, `stealth check/status/...` | Sneak / Invisible on you and every alt |
| `alts on/off/toggle/follow/mirror/do/window` | Orders to your alts |
| `main`, `altcmds`, `alt <name>`, `altsync`, `altbuffs` | Dual-box roles and alt commands |
| `sortie ...` | The author's Sortie orders |
| `tb ...` | Temporary keys |
| `kc` (`keyconflicts`) | Every key conflict this job can meet |
| `watchdog [on/off/...]` | Midcast watchdog |
| `debugmidcast` | Show which set each spell or Blood Pact uses (again to stop) |
| `info <name>` | Details of an ability, spell or weaponskill (some Blood Pacts share a spell's name and cannot be shown) |
| `jamsg` / `spellmsg` / `wsmsg [full/on/off]` | How much chat each action prints |
| `help`, `commands` | Built-in help and command list |
| `syscheck`, `fulltest`, `trace`, `debugsubjob`, `debugstate`, `testcolors` | Diagnostics |

## Shared features on this job

What the project's shared systems do on SMN, checked in the code.

| Feature | On SMN |
|---|---|
| Blood Pact gear | SMN's own: the pact's kind picks `sets.pet_midcast.BPRage.*` / `BPWard.*`, put on when you give the order and again when the avatar acts. An unknown pact (Raise II today) gets none. When you use a pact, `sets.precast.BloodPactRage` / `BloodPactWard` goes on first (Blood Pact delay gear) |
| Avatar idle | Summon an avatar and `sets.idle.Avatar` becomes your idle; release it and your `IdleMode` set comes back |
| Avatar's Favor | The `AvatarFavor` mode follows the buff: gained, `sets.buff["Avatar's Favor"]` goes on top of the idle; lost, it comes off |
| Carbuncle | About 10 s after each load or subjob change, if you are alive and no avatar is out, Carbuncle is summoned |
| Movement speed | `sets.MoveSpeed` goes on while you run, outside town, when idle (over `sets.idle.Avatar` too) |
| Town | In a city (Dynamis excluded) `sets.idle.Town` goes on top of the idle (avatar or `IdleMode` set, with the Favor set); no `sets.Adoulin` in the provided file, so Adoulin uses the town set |
| Combat Mode | Not native: off and hidden. `//gs c combatmode show` gives it Alt+Numpad0; On locks main, sub and range |
| Treasure Mode | Off and hidden. `//gs c th show` gives it Alt+Numpad.; it needs a `sets.TreasureHunter` in your SMN set file |
| Obi / Orpheus | The shared automatic belt acts on your own elemental spells (a subjob nuke), not on Blood Pacts |
| Tier step-down | None on SMN |
| Recast announce | `party_announce` in `RECAST_CONFIG.lua` works for your abilities (Blood Pacts included) and spells refused on recast |
| Doom | Doom slots are handled, but the provided file has no `sets.buff.Doom`: add one |
| Dual Wield tiers | Only when you hold two weapons (with /NIN or /DNC) |
| Auto Medicine | Echo Drops / Remedy / Panacea when a debuff blocks your action (Apps+Numpad0) |
| Sneak / Invisible | `//gs c stealth` (Alt+Z / Alt+X). With /SCH, SMN may cover your whole group with Accession when a charge is left |
| Warp | Every warp command. Warp spells only with a subjob that casts them (/BLM); otherwise rings and items |
| Refill | No `SMN_REFILL.lua`: `//gs c rf` uses the default list (Panacea, Remedy, Holy Water...). Write one in `<YourName>/smn/` to choose |
| Craft / fishing | `//gs c craft`, `fish`: gear locked until `uncraft` |
| Your own modes and gear rules | `SMN_CUSTOM.lua`: extra modes with a key, gear put on last ([keybinds guide](../../guides/keybinds.md)) |
| Midcast watchdog | Puts your idle set back when the game never confirms the end of a cast ([watchdog](../../features/watchdog.md)); `FastCast` (0) is its fallback estimate |
| Lockstyle and macros | Lockstyle 1; macro book 1, page 1 (/WHM), 2 (/SCH), 3 (/RDM), 4 (/BLM), set 8 s after each load |

No TP bonus config on SMN.

## Known issues

- **Empty sets.** Every set of the provided file except the Fast Cast set is
  empty: until you fill them, only the Fast Cast set ever goes on (and stays on
  after a cast). Leave out the slots you do not use, never `slot = ""` (see
  [sets.md](sets.md)).
- **`smn bp`** needs the pact's exact capitals (`Healing Ruby`), see above.
- **Carbuncle** can be summoned twice after a subjob change (one summon
  scheduled by the old job file, one by the new).
- An unload can print "Skillup loop is not running" when the loop was off.

## Configuration files for this job

In `<YourName>/smn/`:

| File | What you set there |
|---|---|
| `SMN_STATES.lua` | Modes, their values and defaults |
| `SMN_KEYBINDS.lua` | The SMN keys above |
| `SMN_CUSTOM.lua` | Your own modes, keys and gear rules, without code (examples only) |
| `SMN_HUD.lua` | Order of the HUD sections and rows on SMN (also written by `//gs c ui order`) |
| `SMN_LOCKSTYLE.lua` | Lockstyle number (1), per subjob through `get_style` |
| `SMN_MACROBOOK.lua` | Macro book and page per subjob; dual-box block empty |
| `SMN_REFILL.lua` | Optional, not provided: items `//gs c rf` keeps in your inventory |

Shared by every job, in `<YourName>/_common/`: `COMMON_KEYBINDS.lua`,
`combat_mode.lua` and `treasure_mode.lua` (written by their commands),
`ELEMENTAL_BELT.lua`, `RECAST_CONFIG.lua`, `WEAPON_CONFIG.lua`,
`DW_CONFIG.lua`, `STEALTH_CONFIG.lua`, `UI_CONFIG.lua`. Your sets are in
`<YourName>/smn/smn_sets.lua`. See
[configuration](../../guides/configuration.md).

## More

- [SMN modes and keys in detail](states.md)
- [SMN set names and automatic gear](sets.md)
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md), [set names guide](../../guides/sets.md)
