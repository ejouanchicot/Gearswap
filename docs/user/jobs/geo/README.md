# GEO — Geomancer: start here

The one page to open first when you play Geomancer. It lists every key and
every command that works on GEO, and every shared feature that acts on your
gear or your actions, then points to the details:

- [states.md](states.md): what each mode value does;
- [sets.md](sets.md): every set name the GEO code reads, and what goes on by itself.

## Overview

GEO keeps your bubbles in modes: an Indi- spell and a Geo- spell you pick with
a key, then one command casts each (`indi`, `geo`, `entrust`). On top of that:

- your idle and engaged gear follows the luopan: your own sets when none is
  out, the luopan sets (pet damage taken, regen) while one is out;
- `geo` picks the target for you: a party member for a buff, an enemy for a
  debuff;
- a nuke, -ra or Aspir cast from a macro steps down a tier when it cannot go out;
- with a Scholar subjob, `aoe sneak` / `aoe invi` / `aoe erase` and `dispel`
  chain the stratagems for you;
- two automatic abilities, off by default: Entrust before an Indi- on a party
  member, Full Circle before a new Geo-.

Everything below comes from the provided template. After cloning, your copies
are in `<YourName>/geo/`; if you changed them, your files win.

## All keys on this job

Key notation: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Windows.

### GEO keys (`GEO_KEYBINDS.lua`)

No GEO key depends on the subjob: all 12 are bound on every subjob and shown
on the HUD.

| Key | Mode | Default | What it changes |
|---|---|---|---|
| Ctrl+Numpad1 `^numpad1` | `SpellTier` | V | Tier of `lightspell` / `darkspell` |
| Ctrl+Numpad2 `^numpad2` | `AOETier` | III | Tier of `lightaoe` / `darkaoe` |
| Ctrl+Numpad3 `^numpad3` | `MainIndi` | Indi-Haste | Spell of `indi` and `entrust` (30 values) |
| Ctrl+Numpad4 `^numpad4` | `MainGeo` | Geo-Frailty | Spell of `geo` (28 values) |
| Ctrl+Numpad5 `^numpad5` | `MainLightSpell` | Fire | Element of `lightspell` |
| Ctrl+Numpad6 `^numpad6` | `MainDarkSpell` | Blizzard | Element of `darkspell` |
| Ctrl+Numpad7 `^numpad7` | `MainLightAOE` | Fira | Spell of `lightaoe` |
| Ctrl+Numpad8 `^numpad8` | `MainDarkAOE` | Blizzara | Spell of `darkaoe` |
| Ctrl+Numpad9 `^numpad9` | `HybridMode` | PDT | Your idle / engaged sets when no luopan is out |
| Ctrl+Numpad0 `^numpad0` | `CombatMode` | Off | Weapon lock (see Shared features) |
| Ctrl+Numpad. `^numpad.` | `LuopanMode` | DT | Engaged set while a luopan is out: DT or DPS |
| Ctrl+Numpad+ `^numpad+` | `IndicolureMode` | Self | Shown on the HUD only: nothing reads it today |

The full value lists are in [states.md](states.md).

### Keys every job gets

| Key | Does | Shown by default |
|---|---|---|
| Apps+Numpad0 `#numpad0` | Auto Medicine on / off (Echo Drops, Remedy... used when a debuff blocks your action) | yes |
| Alt+Numpad7 `!numpad7` | Your alts follow you (press again to stop) | yes |
| Alt+Numpad8 `!numpad8` | Your alts' automation on / off | yes |
| Alt+Numpad9 `!numpad9` | Alts mirror | yes |
| Alt+Z `!z` | Sneak on you and every alt | yes |
| Alt+X `!x` | Invisible on you and every alt | yes |
| Alt+Numpad. `!numpad.` | Treasure Mode (Off / Tag / Full) | no: hidden and unbound until `//gs c th show` |
| Ctrl+F1-F8, Alt+F1-F8 | Temporary keys you make with `//gs c tb` | only once you make one |
| Your own keys | Modes you add in `GEO_CUSTOM.lua` (empty in the template) | yes |

The common keys come from `<YourName>/_common/keys/COMMON_KEYBINDS.lua`. Combat Mode
needs no extra key on GEO: it is native here, on Ctrl+Numpad0.

### Mote-Include keys (always bound, not on the HUD)

| Key | Command | On GEO |
|---|---|---|
| Ctrl+F9 | `cycle HybridMode` | Same as Ctrl+Numpad9 |
| F12 | `update user` | Puts your current gear back and prints the modes |
| F10 / F11, Ctrl+F10, Alt+F12, Alt+F10 | Defense modes, reset, Kiting | Nothing: GEO builds its idle and engaged sets itself and drops Mote's defense and Kiting layers |
| F9, Alt+F9, Win+F9, Ctrl+F11, Ctrl+F12 | Offense, Ranged, Weaponskill, Casting, Idle mode | Nothing: those modes keep their single value `Normal` on GEO |
| Ctrl+- / Ctrl+= | Mote's target selection modes | Mote's own behaviour |

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro).

### GEO commands

| Command | What it does |
|---|---|
| `indi` | Casts `MainIndi` on you |
| `geo` | Casts `MainGeo`: on a party member you pick for the 18 buff Geo- spells, on an enemy you pick for the others |
| `entrust` | Entrust, then `MainIndi` on a party member you pick once Entrust is up; gives up with a warning if Entrust was refused |
| `escort [Indi-X] [leader]` | Full Circle if a luopan is out, then the Indi- on you (Indi-Regen by default, `geo_escort_indi` in `_common/combat/TUNING.lua`); with a leader name, `sm follow <leader>` once the cast is over (needs an addon that answers `sm follow`) |
| `lightspell` / `darkspell` | Nuke with the element mode and `SpellTier`, stepping down to a learned, ready tier |
| `lightaoe` / `darkaoe` | Same with the -ra mode and `AOETier` |
| `lightarts` / `darkarts` | /SCH: Light / Dark Arts, then the Addendum on the next press |
| `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: the spell on the party through Light Arts and Accession (and Addendum: White for Erase) as charges allow. GEO has no single-target switch: it is always the party version |
| `dispel` | /RDM: Dispel on an enemy you pick. /SCH: Dark Arts and Addendum: Black first when needed. Other subjobs: a warning |

The /SCH and /RDM commands do not check the subjob: the game refuses them.

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
| `jump` | /DRG only: jumps |
| `stealth sneak/invi/both [self]`, `stealth check/status/...` | Sneak / Invisible on you and every alt |
| `alts on/off/toggle/follow/mirror/do/window` | Orders to your alts |
| `main`, `altcmds`, `alt <name>`, `altsync`, `altbuffs` | Dual-box roles and alt commands |
| `sortie ...` | Sortie orders, only on a character with a `SORTIE_CONFIG.lua` (Tetsouo's is the example; `sortie escort` drives a GEO alt) |
| `tb ...` | Temporary keys |
| `kc` (`keyconflicts`) | Every key conflict this job can meet |
| `watchdog [on/off/...]` | Midcast watchdog |
| `debugmidcast` | Show which midcast set each spell uses (again to stop) |
| `info <name>` | Details of an ability, spell or weaponskill |
| `jamsg` / `spellmsg` / `wsmsg [full/on/off]` | How much chat each action prints |
| `help`, `commands` | Built-in help and command list |
| `syscheck`, `fulltest`, `trace`, `debugsubjob`, `debugstate`, `testcolors` | Diagnostics |

`entrust` and `dispel` run on this character even
when your dual-box alt has commands of the same name; `//gs c alt <name>` sends
the alt's version.

## Shared features on this job

What the project's shared systems do on GEO, checked in the code.

| Feature | On GEO |
|---|---|
| Luopan-aware gear | GEO's own: with a luopan out, `sets.luopan.idle` (idle) and `sets.luopan.engaged.DT` / `.DPS` (engaged, by `LuopanMode`); without, `sets.idle.PDT` / `.Normal` and `sets.engaged.PDT` / `.Normal` by `HybridMode`. Gear is re-picked when the luopan appears or leaves |
| Movement speed | `sets.MoveSpeed` goes on while you run, outside town, when idle (luopan out or not; not while engaged) |
| Town | In a city (Dynamis excluded) `sets.idle.Town` goes on top of the idle set, the luopan set included; in Adoulin `sets.Adoulin` first |
| Weapons | `sets['Idris']` and `sets['Genmei Shield']` (in the template) are laid on your idle and engaged sets |
| Combat Mode | Native, shown, Ctrl+Numpad0, Off by default. On puts on `sets.CombatMode` if you define one, then locks main, sub, range **and ammo**. Off frees them (unless a craft set holds them) |
| Treasure Mode | Off and hidden. `//gs c th show` gives it Alt+Numpad.; it needs a `sets.TreasureHunter` in your GEO set file |
| Obi / Orpheus | The shared automatic belt (`ELEMENTAL_BELT.lua`, `//gs c belt`) goes on after your nuke set when it helps. GEO has no belt rule of its own |
| Tier step-down | A nuke (Fire V...), -ra or Aspir cast from a macro that is on recast or short of MP goes out as the highest lower tier you know that can; nothing castable: stopped, recasts shown ([auto-tier](../../features/auto-tier-system.md)) |
| Automatic abilities | Off by default, in `<YourName>/_common/combat/AUTO_ABILITIES.lua`: `geo_entrust = true` (an Indi- cast on a party member waits for Entrust first, when it is ready), `geo_full_circle = true` (a Geo- cast while a luopan is out uses Full Circle first, then the Geo- 2 s later) |
| Entrust set | An Indi- on a party member while Entrust is up (or just used) wears `sets.midcast.Indi.Entrust` for the whole cast |
| Recast announce | `party_announce` in `RECAST_CONFIG.lua` works for abilities and for spells that do not step down |
| Doom | `sets.buff.Doom` while Doomed; its slots stay locked until Doom is gone |
| Dual Wield tiers | Only when you hold two weapons (with /NIN or /DNC): nothing with a club and shield |
| Auto Medicine | Echo Drops / Remedy when a debuff blocks your action (Apps+Numpad0) |
| Sneak / Invisible | `//gs c stealth` (Alt+Z / Alt+X). With /SCH, GEO may cover your whole group with Accession when a charge is left (GEO has no switch to stop it) |
| Warp | Every warp command. Warp spells only with a subjob that casts them (/BLM); otherwise rings and items |
| Refill | `//gs c rf` restocks the common list of `_common/inventory/REFILL_CONFIG.lua` (Panacea, Remedy, Holy Water... by default); `<YourName>/geo/inventory/GEO_REFILL.lua` can add to it or replace it ([configuration](../../guides/configuration.md#refill-job_refilllua)) |
| Craft / fishing | `//gs c craft`, `fish`: gear locked until `uncraft`; Combat Mode Off does not free what a craft set holds |
| PetTP addon | Loaded when GEO loads, unloaded when you leave GEO; `pettp = false` in `_common/display/ADDONS_CONFIG.lua` leaves it alone |
| Dual-box | As an alt, GEO tells the main when Entrust goes up or down, so the main's alt commands can aim an Indi- at the party |
| Your own modes and gear rules | `GEO_CUSTOM.lua`: extra modes with a key, gear put on last ([keybinds guide](../../guides/keybinds.md)) |
| Midcast watchdog | Puts your idle / engaged set back when the game never confirms the end of a cast ([watchdog](../../features/watchdog.md)); `FastCast` (80) is its fallback estimate |
| Lockstyle and macros | Lockstyle 5 and macro book 5 page 1 are set 8 s after each load |

Not on GEO: the Magic Burst party call and BLM's own tier refiner (BLM), pet
Blood Pact gear (SMN), cure auto-tier (WHM).

## Configuration files for this job

In `<YourName>/geo/`:

| File | What you set there |
|---|---|
| `GEO_STATES.lua` | Modes, their values and defaults (trim or reorder the Indi- / Geo- lists here) |
| `GEO_KEYBINDS.lua` | The GEO keys above |
| `GEO_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty in the template) |
| `GEO_HUD.lua` | Order of the HUD sections and rows on GEO (also written by `//gs c ui order`) |
| `GEO_LOCKSTYLE.lua` | Lockstyle number (5), per subjob through `get_style` |
| `GEO_MACROBOOK.lua` | Macro book and page per subjob (book 5 page 1), and per dual-box partner job (empty) |
| `GEO_TP_CONFIG.lua` | TP bonus pieces (Moonshade Earring) for weaponskill gear |
| `GEO_REFILL.lua` | Items `//gs c rf` keeps in your inventory on GEO, on top of or in place of the common list; every line commented at first |

Shared by every job, in `<YourName>/_common/`: `AUTO_ABILITIES.lua` (the two
GEO options), `COMMON_KEYBINDS.lua`, `combat_mode.lua` and `treasure_mode.lua`
(written by their commands), `ELEMENTAL_BELT.lua`, `RECAST_CONFIG.lua`,
`WEAPON_CONFIG.lua`, `DW_CONFIG.lua`, `STEALTH_CONFIG.lua`, `UI_CONFIG.lua`.
Your sets are in `<YourName>/geo/geo_sets.lua`. See
[configuration](../../guides/configuration.md).

## More

- [GEO modes and keys in detail](states.md)
- [GEO set names and automatic gear](sets.md)
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md), [set names guide](../../guides/sets.md)
