# BRD — start here

The one page to open first when you play Bard. It lists every key, every
command and every automatic feature active on BRD, and where each setting
lives. Details are on the linked pages:

- [states.md](states.md): what each mode value does, the song packs
- [sets.md](sets.md): the set names the code looks for, and the gear put on for you

## Overview

Bard with the provided template gives you:

- **A whole song pack on one command**: pick a pack (`SongMode`), then
  `//gs c songs` sings it on yourself. How many songs and how many dummy songs
  are worked out from the instruments you own, Clarion Call and the songs of
  yours already up. Each song goes out once the previous one is over; an
  interrupted or refused song is tried again (twice at most).
- **Victory March swapped when you already have Haste**: for Blade Madrigal,
  Valor Minuet III or an Etude (`VictoryMarch`).
- **Instruments handled for you**: Honor March always on Marsyas, Aria of
  Passion on Loughnashade, dummy songs on the harp of your dummy set, every
  other buff song on the instrument chosen by `MainInstrument`.
- **Automatic Pianissimo** for a song aimed at another player, **automatic
  Marcato** before Honor March (or Aria of Passion) under Nightingale +
  Troubadour, and **AutoNitro** (Nightingale then Troubadour before a pack).
- **Song tier fallback**: a debuff song on cooldown is sung at another tier
  (Foe Lullaby II to Foe Lullaby, Carnage Elegy to Battlefield Elegy...).
- **Weapons on keys** and engaged / idle modes; Kraken Club gets its own
  engaged set.
- **One command per song**: `carol`, `etude`, `threnody`, `lullaby`, `elegy`,
  `requiem`, `song1`-`song5`, and the job abilities.

Every mode goes back to its default on each job change, subjob change and
reload.

## All keys on this job

Ctrl = `^`, Alt = `!`, Apps (menu key) = `#`, Win = `@`. The keys come from
the provided template; after cloning, yours are in `<YourName>/config/brd/`
and `<YourName>/config/COMMON_KEYBINDS.lua`, and those files win. No BRD key
depends on the subjob.

| Key | Does | When | Shown in the HUD |
|---|---|---|---|
| `^numpad1` | Cycle Main Weapon: Naegling, Twashtar, Carnwenhan, Mpu Gandring | always | yes |
| `^numpad2` | Cycle Sub Weapon: Kraken, Demersal, Genmei, Centovente | always | yes |
| `^numpad3` | Cycle Main Instrument: Gjallarhorn, Daurdabla, Marsyas | always | yes |
| `^numpad4` | Cycle Idle Mode: Refresh, DT, Regen | always | yes |
| `^numpad5` | Cycle Engaged Mode: STP, Acc, DT, SB | always | yes |
| `^numpad6` | Cycle Song Pack: Dirge, March, Madrigal, Minne, Etude, Tank, Healer, Carol, Scherzo, Arebati, Ngai | always | yes |
| `^numpad7` | Cycle Victory March replacement: Madrigal, Minuet, Etude, None | always | yes |
| `^numpad8` | Cycle Auto-Marcato song: HonorMarch, AriaPassion, Off | always | yes |
| `^numpad0` | Cycle Carol element: Fire, Ice, Wind, Earth, Lightning, Water, Light, Dark | always | yes |
| `^numpad.` | Cycle Threnody element (same eight) | always | yes |
| `#numpad1` | Cycle Etude type: STR, DEX, VIT, AGI, INT, MND, CHR | always | yes |
| `#numpad2` | Auto Nitro On / Off | always | yes |
| `#numpad0` | Auto Medicine on / off | always (common key) | yes |
| `!numpad7` | Alts follow this character (press again to stop) | always (common key) | yes |
| `!numpad8` | Alts' automation on / off | always (common key) | yes |
| `!numpad9` | Alts mirror | always (common key) | yes |
| `!z` | Sneak on you and every alt | always (common key) | yes |
| `!x` | Invisible on you and every alt | always (common key) | yes |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **not bound by default**: only after `//gs c combatmode show`. Read the warning under [Shared features](#shared-features-on-this-job) first | only when shown |
| `!numpad.` | Cycle Treasure Mode: Off, Tag, Full | **not bound by default**: only after `//gs c th show` | only when shown |
| `^f1`-`^f8`, `!f1`-`!f8` | Your temporary keys | only the ones you create with `//gs c tb` | no |

`^numpad9` is left free on BRD (the project keeps it for Hybrid Mode, which BRD
does not use). The HUD also shows your five pack songs (`Song 1`-`Song 5`),
display only.

Mote-Include (the library under every job) also binds these keys on every
job load. They are not in the HUD. On BRD:

| Key | Mote command | Effect on BRD |
|---|---|---|
| `^f12` | cycle Idle Mode | Same as `^numpad4` |
| `f9`, `^f9`, `!f9`, `@f9`, `^f11` | cycle Offense / Hybrid / Ranged / Weaponskill / Casting Mode | Nothing: BRD gives these modes a single value |
| `f10`, `f11`, `^f10`, `!f12` | Defense Mode Physical / Magical / cycle / reset | Nothing with the provided template: BRD's idle and engaged gear come from Idle Mode / Engaged Mode sets, which replace Mote's defense layer |
| `!f10` | Kiting on / off | Nothing, for the same reason |
| `f12` | `update user` | Puts your gear back for your current status and prints the current modes |
| `^-`, `^=` | Mote target helpers | Mote's own target switching |

Key conflicts for this job, on every subjob: `//gs c keyconflicts`.

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro). Full list
and arguments: [commands guide](../../guides/commands.md).

**BRD commands**

| Command | What it does |
|---|---|
| `songs` (`melee`, `meleesong`, `allsongs`) | Sings the current pack on yourself: the songs your main instrument holds, then the dummy songs, then the rest of the pack over the dummies |
| `songs full` | The same, with every dummy song whatever is already up (use it when another bard's songs are on you) |
| `songplan` | What `songs` would do now, and why: Clarion Call, instruments and the extra songs each gives, songs up (yours / all), the plan |
| `songstop` | Stops a running `songs` / `dummy` rotation |
| `dummy` (`dummysongs`) | Only the dummy songs your dummy harp can add |
| `dummy1`, `dummy2` | First / second dummy song of the list |
| `song1` ... `song5` | One song of the current pack (after the Victory March swap) |
| `carol` | `<Carol element> Carol II` |
| `etude` | The Etude of `EtudeType` |
| `threnody` | `<Threnody element> Threnody II` on `<stnpc>` |
| `lullaby` | Horde Lullaby on `<stnpc>` (becomes Horde Lullaby II when Horde Lullaby is on cooldown) |
| `lullaby2` (`foe`) | Foe Lullaby II on `<stnpc>` |
| `elegy` | Carnage Elegy on `<stnpc>` |
| `requiem` | Foe Requiem VII on `<stnpc>` |
| `nt` | Nightingale, then Troubadour 2 s later |
| `sv` / `ni` / `tr` / `ma` / `pi` | Soul Voice / Nightingale / Troubadour / Marcato / Pianissimo (`soul_voice`, `nightingale`, `troubadour`, `marcato`, `pianissimo` work too) |
| `forceidle` | Enables ring1 again and puts the idle set's left ring back on |

`carol`, `etude`, `dummy1`, `dummy2` and `song1`-`song5` aim at yourself when
you target yourself, at your current target when it is another player
(Pianissimo is then added for you), else at `<stpc>`. `songs` and `dummy`
always sing on yourself. Marcato and Pianissimo are added when the song
starts, after its recast check, never by the command.

**Common commands that work on BRD**

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
| `jump` | /DRG: Jump / High Jump |
| `watchdog ...`, `debugmidcast`, `debugprecast` | Midcast watchdog, midcast debug, precast set display |
| `stealth sneak` / `invi` / `both` ... | Sneak / Invisible on you and your alts |
| `alts ...`, `main`, `altcmds`, `alt <name>` | Dual-box group |
| `combatmode [show / hide / key]` | Combat Mode (weapon lock) on this job |
| `th [show / hide / key / clear]` | Treasure Mode on this job |
| `dw [auto / none / haste / haste2 / max]` | Dual Wield tier |
| `belt` | Obi / Orpheus status |
| `tb ...` | Temporary keys |
| `keyconflicts` (`kc`) | Every key conflict on this job |
| `info <name>`, `jamsg`, `spellmsg`, `wsmsg` | Ability / spell / weaponskill details and chat messages |
| `commands`, `help` | Built-in command list and help |
| `syscheck`, `fulltest`, `trace`, `debugsubjob`, ... | Diagnostics |

## Shared features on this job

| Feature | On BRD |
|---|---|
| Weaponskill check | A weaponskill out of range or under 1000 TP is cancelled with a message; TP bonus gear (Moonshade...) from `BRD_TP_CONFIG.lua` is added, counting Aeneas / Centovente in either hand |
| Recast check | An ability or spell still on recast is cancelled with the time left. Debuff songs that have another tier are handled first (tier fallback) |
| Automatic abilities | Pianissimo before a song on another player (the song follows once Pianissimo is up), Marcato before the `MarcatoSong` song (the song follows 2 s later), Nightingale + Troubadour before a pack (`AutoNitro`, each waits for the previous buff) |
| Debuff guard | An action you cannot do (silenced, amnesia, ...) is stopped; with Auto Medicine on, Echo Drops / Remedy / Panacea are used |
| Doom | `sets.buff.Doom` goes on and its neck, rings and waist stay locked while Doomed |
| Movement speed | `sets.MoveSpeed` on idle while you move outside town; `sets.Adoulin` in Adoulin, `sets.idle.Town` in other towns. Not while engaged |
| Obi / Orpheus | Added to elemental weaponskills (Aeolian Edge...) and subjob nukes when the day, weather or distance gives enough (`//gs c belt`). Songs never get it |
| Dual Wield tiers | Only if you define `sets.DW` (a commented example is in the template) and hold two weapons (/NIN, /DNC) |
| Treasure Mode | Off and hidden. `//gs c th show`, then add `sets.TreasureHunter` to your set file (the template has none) |
| Combat Mode | Off and hidden. **On BRD it also locks the instrument slot**: no instrument can change, dummy songs use whatever you wear, and Honor March / Aria of Passion are refused unless Marsyas / Loughnashade is already on. Leave it hidden unless you want exactly that |
| Weapon without a set | With `equip_without_set = true` in `config/WEAPON_CONFIG.lua`, a Main / Sub Weapon value with no set equips that weapon by name |
| Your own modes | `BRD_CUSTOM.lua`: extra modes, keys and gear rules without code. Your rules never touch the instrument or ammo while you sing |
| Midcast watchdog | Puts your gear back if a cast result never arrives (`FastCast` mode, no key, default 80) |
| Lockstyle, macro book | Set on load and on each subjob change |
| Dual-box | Job exchange with your alt, `alts` orders, macro book per alt job (GEO, COR or RDM in the template) |
| Messages | Ability, spell and weaponskill lines in chat (`jamsg` / `spellmsg` / `wsmsg`); each song prints what it does |
| Manual waltz (/DNC) | A Curing Waltz macro on yourself is re-tiered by Mote from your missing HP and TP |

## Configuration files for this job

In `<YourName>/config/brd/`:

| File | Content |
|---|---|
| `BRD_STATES.lua` | Modes, their values and defaults |
| `BRD_KEYBINDS.lua` | The job keys above |
| `BRD_CUSTOM.lua` | Your own modes, keys and gear rules ([keybinds guide](../../guides/keybinds.md)) |
| `BRD_SONG_CONFIG.lua` | The song packs, dummy songs, Etudes, Victory March replacements, HUD short names, song tier fallback (`SONG_REFINE`, `enabled = false` turns it off) |
| `BRD_TIMING_CONFIG.lua` | Gap after each song of a rotation (3.0 s, +1.0 s after Honor March / Aria of Passion) and the `nt` delay (2.0 s) |
| `BRD_HUD.lua` | HUD section and row order for BRD (written by `//gs c ui order` / `roworder`) |
| `BRD_LOCKSTYLE.lua` | Lockstyle number (template: 7). Its `by_subjob` table is not used: the file has no `get_style` |
| `BRD_MACROBOOK.lua` | Macro book / page per subjob and per dual-box alt job (template: book 40 page 1) |
| `BRD_TP_CONFIG.lua` | TP bonus pieces and weapons ([TP bonus](../war/tp-bonus.md)) |
| `BRD_REFILL.lua` (optional) | What `//gs c rf` restocks; without it a built-in list is used ([configuration](../../guides/configuration.md#refill-job_refilllua)) |

In `<YourName>/config/`, shared with the other jobs: `COMMON_KEYBINDS.lua`,
`WEAPON_CONFIG.lua`, `DW_CONFIG.lua`, `ELEMENTAL_BELT.lua`,
`RECAST_CONFIG.lua`, `STEALTH_CONFIG.lua`, and `treasure_mode.lua` /
`combat_mode.lua` (written by `//gs c th` / `combatmode`). Gear:
`<YourName>/sets/brd_sets.lua`. See [configuration](../../guides/configuration.md).

## More

- [states.md](states.md): each mode in detail, the song packs
- [sets.md](sets.md): set names and automatic gear (instruments, dummy songs, debuff songs)
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md)
