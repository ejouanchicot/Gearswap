# BLM — Black Mage: start here

The one page to open first when you play Black Mage. It lists every key and
every command that works on BLM, and every shared feature that acts on your
gear or your actions, then points to the details:

- [states.md](states.md): what each mode value does;
- [sets.md](sets.md): every set name the BLM code reads, and what goes on by itself.

## Overview

BLM picks its nukes from modes instead of macros: an element for each "slot"
(main or sub, light or dark, single target or area) plus a tier, then one
command casts the result on the target you pick. On top of that:

- a nuke that cannot go out (recast, MP) steps down to the next tier that can;
- with Magic Burst mode On, the nuke uses your Magic Burst set and is called
  in party chat;
- with a Scholar subjob, Dark Arts is put up for you before a nuke, and the
  `storm`, `klima`, `aoe` and `dispel` commands chain the stratagems for you;
- Death, Mana Wall, Impact (Twilight Cloak), low MP and the Stone family each
  have their own gear hook (see [sets.md](sets.md)).

Everything below comes from the provided template. After cloning, your copies
are in `<YourName>/blm/`; if you changed them, your files win.

## All keys on this job

Key notation: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Windows.
"HUD" = the row shows in the keybind HUD (`//gs c ui`).

### BLM keys (`BLM_KEYBINDS.lua`)

No BLM key depends on the subjob: all are bound on every subjob. Some only
matter with /SCH, as noted.

| Key | Mode | Default | What it changes |
|---|---|---|---|
| Ctrl+Numpad1 `^numpad1` | `SpellTier` | VI | Tier of `light` / `dark` / `sublight` / `subdark` |
| Ctrl+Numpad2 `^numpad2` | `AOETier` | Aja | Tier of the four area nuke commands (`Aja` = the -ja spell) |
| Ctrl+Numpad3 `^numpad3` | `MainLightSpell` | Fire | Element of `light` |
| Ctrl+Numpad4 `^numpad4` | `MainDarkSpell` | Stone | Element of `dark` |
| Ctrl+Numpad5 `^numpad5` | `MainLightAOE` | Firaga | Spell of `aoelight` |
| Ctrl+Numpad6 `^numpad6` | `MainDarkAOE` | Stonega | Spell of `aoedark` |
| Ctrl+Numpad7 `^numpad7` | `Storm` | Firestorm | Storm cast by `storm` (/SCH) |
| Ctrl+Numpad8 `^numpad8` | `CombatMode` | Off | Weapon lock (see Shared features) |
| Ctrl+Numpad9 `^numpad9` | `HybridMode` | Normal | PDT: your PDT idle / engaged sets |
| Ctrl+Numpad0 `^numpad0` | `MagicBurstMode` | On | Off / On / Acc nuke gear, and the party call |
| Apps+Numpad3 `#numpad3` | `SubLightSpell` | Thunder | Element of `sublight` |
| Apps+Numpad4 `#numpad4` | `SubDarkSpell` | Blizzard | Element of `subdark` |
| Apps+Numpad5 `#numpad5` | `SubLightAOE` | Thundaga | Spell of `subaoelight` |
| Apps+Numpad6 `#numpad6` | `SubDarkAOE` | Blizzaga | Spell of `subaoedark` |
| Apps+Numpad7 `#numpad7` | `DeathMode` | Off | On: idle in your Death (max MP) set |
| Apps+Numpad8 `#numpad8` | `SneakInviAOE` | On | `aoe sneak` / `aoe invi` on the party or one target (/SCH) |
| Apps+Numpad9 `#numpad9` | `KlimaformAOE` | On | `klima` uses Manifestation first (/SCH) |

All 17 are on the HUD. Each press moves to the next value; the full value
lists are in [states.md](states.md).

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
| Your own keys | Modes you add in `BLM_CUSTOM.lua` (empty in the template) | yes |

The common keys come from `<YourName>/common/keys/COMMON_KEYBINDS.lua`: edit that
file to change them for every job at once. Combat Mode needs no extra key on
BLM: it is native here, on Ctrl+Numpad8.

### Mote-Include keys (always bound, not on the HUD)

Mote-Include binds these on every job file load. On BLM most do nothing with
the provided sets:

| Key | Command | On BLM |
|---|---|---|
| Ctrl+F9 | `cycle HybridMode` | Same as Ctrl+Numpad9 |
| F12 | `update user` | Puts your current gear back and prints the modes |
| F10 / F11, Ctrl+F10, Alt+F12 | Physical / Magical defense mode, its variant, reset | Only with `sets.defense.PDT` / `sets.defense.MDT`, which the template does not have; and Death or PDT mode replaces that idle anyway |
| Alt+F10 | `toggle Kiting` | Only with `sets.Kiting` (absent) |
| F9, Alt+F9, Win+F9, Ctrl+F11, Ctrl+F12 | Offense, Ranged, Weaponskill, Casting, Idle mode | Nothing: BLM leaves those modes at their single value `Normal` |
| Ctrl+- / Ctrl+= | Mote's target selection modes | Mote's own behaviour |

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro).

### BLM commands

| Command | What it does |
|---|---|
| `light` / `dark` | Casts `MainLightSpell` / `MainDarkSpell` at `SpellTier` on a target you pick (`<stnpc>`) |
| `sublight` / `subdark` | Same with `SubLightSpell` / `SubDarkSpell` |
| `aoelight` / `aoedark` | Casts `MainLightAOE` / `MainDarkAOE` at `AOETier` (`Aja` = Firaja, Stoneja...) |
| `subaoelight` / `subaoedark` | Same with `SubLightAOE` / `SubDarkAOE` |
| `cyclemainlight` / `cyclemaindark` / `cyclesublight` / `cyclesubdark` | Next element of that mode, with a coloured chat line |
| `cycle Storm` | Next storm, with a coloured chat line |
| `storm` | /SCH: the `Storm` spell on you, Klimaform first when it is ready and not up. Klimaform neither up nor ready: its recast is shown, nothing is cast |
| `klima` (`klimaform`) | /SCH: Dark Arts if down and ready, Manifestation if `KlimaformAOE` is On and a charge is left, then Klimaform; each step waits for the previous buff |
| `buff` (`buffs`, `buffself`, `selfbuff`) | Stoneskin, Blink, Aquaveil, Ice Spikes, each only when missing, known and off recast |
| `lightarts` / `darkarts` | /SCH: Light / Dark Arts, then the Addendum on the next press |
| `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: the spell through Light Arts and Accession (and Addendum: White for Erase) as charges allow |
| `dispel` | /RDM: Dispel on a target you pick. /SCH: Dark Arts and Addendum: Black first when needed. Other subjobs: a warning |

The commands that need /SCH or /RDM do not check the subjob: the game refuses
the ability or spell.

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
| `sortie ...` | The author's Sortie orders |
| `tb ...` | Temporary keys |
| `kc` (`keyconflicts`) | Every key conflict this job can meet |
| `watchdog [on/off/...]` | Midcast watchdog |
| `debugmidcast` | Show which midcast set each spell uses (again to stop) |
| `info <name>` | Details of an ability, spell or weaponskill |
| `jamsg` / `spellmsg` / `wsmsg [full/on/off]` | How much chat each action prints |
| `help`, `commands` | Built-in help and command list |
| `syscheck`, `fulltest`, `trace`, `debugsubjob`, `debugstate`, `testcolors` | Diagnostics |

## Shared features on this job

What the project's shared systems do on BLM, checked in the code.

| Feature | On BLM |
|---|---|
| Movement speed | `sets.MoveSpeed` goes on while you run, outside town, when idle (not while engaged) |
| Town | In a city (Dynamis excluded) `sets.idle.Town` goes on top of the idle set (the Death / PDT set when that mode is on); in Adoulin `sets.Adoulin` first |
| Combat Mode | Native, shown, Ctrl+Numpad8, Off by default. On locks main, sub, range **and ammo**; on turning it On, `sets.CombatMode` goes on first (provided file: Bunzi's Rod, Ammurapi Shield, Sroda Tathlum). Off frees the slots (unless a craft set holds them) |
| Treasure Mode | Off and hidden. `//gs c th show` gives it Alt+Numpad.; it needs a `sets.TreasureHunter` in your BLM set file |
| Obi / Orpheus | The shared automatic belt is on by default (`ELEMENTAL_BELT.lua`, `//gs c belt`): Obi or Orpheus goes on after the nuke set when it helps. BLM's own Hachirin-no-Obi rule (`sets.midcast.ElementalMatch`, `BLM_ELEMENTAL_CONFIG.lua`) only runs when you turn the shared belt off |
| Tier step-down | BLM's own, from a macro or a command alike: a tiered nuke (Fire VI to Fire...), -ga, Sleep / Sleepga, Bind, Bio, Poison, Drain or Aspir that is on recast or short of MP goes out as the highest lower tier you know that can; a -ja falls back to the -ga family (-ga III if none can); Breakga on recast becomes Break. Nothing castable: the cast is stopped and the recasts are shown |
| Magic Burst call | `MagicBurstMode` On: `/p Casting: [<spell>] => Nuke` for an elemental nuke, at most once every 2.5 s |
| Automatic ability | /SCH: Dark Arts is put up before an elemental nuke when it is ready and neither Dark Arts nor Addendum: Black is on; the nuke is re-sent once Dark Arts lands. Always on, no option |
| Recast announce | `party_announce` in `RECAST_CONFIG.lua` works for abilities and for spells that do not step down (a tiered nuke steps down instead of being refused) |
| Doom | `sets.buff.Doom` while Doomed; its slots stay locked until Doom is gone |
| Dual Wield tiers | Only when you hold two weapons (with /NIN or /DNC): nothing with a staff |
| Auto Medicine | Echo Drops / Remedy / Panacea when a debuff blocks your action (Apps+Numpad0) |
| Sneak / Invisible | `//gs c stealth` (Alt+Z / Alt+X). With /SCH, `SneakInviAOE` Off stops it from spending a stratagem on your group |
| Warp | Every warp command. BLM casts Warp, Warp II, Escape and Retrace itself; the other destinations use rings and items |
| Refill | `//gs c rf` restocks from `<YourName>/blm/BLM_REFILL.lua` if you write one; without it, a default list (Panacea, Remedy, Holy Water...) |
| Craft / fishing | `//gs c craft`, `fish`: gear locked until `uncraft`; turning Combat Mode Off does not free the slots a craft set holds |
| Your own modes and gear rules | `BLM_CUSTOM.lua`: extra modes with a key, gear put on last ([keybinds guide](../../guides/keybinds.md)) |
| Weapons without a set | `MainWeapon` / `SubWeapon` (Hvergelmir / Alber Strap) do nothing unless you write `sets.Hvergelmir` / `sets['Alber Strap']`, or turn on `equip_without_set` in `WEAPON_CONFIG.lua` |
| Midcast watchdog | Puts your idle / engaged set back when the game never confirms the end of a cast ([watchdog](../../features/watchdog.md)); `FastCast` (80) is its fallback cast-time estimate |
| Lockstyle and macros | Lockstyle 5 and macro book 8 page 1 are set 8 s after each load |
| Dual-box | Alt keys and commands above; the macro book can follow your partner's job (`BLM_MACROBOOK.lua`) |

Not on BLM: Entrust / Full Circle options (GEO), pet features, cure
auto-tier (WHM).

## Known issues

- **Impact Magic Burst set** (found 2026-09-28, from the code): the plain
  `sets.midcast['Impact']` is put back at the end of the cast, so
  `.MagicBurst` is never worn. Keep Twilight Cloak in `sets.midcast['Impact']`.
- With /SCH, a nuke held back for Dark Arts is re-sent on `<t>` (your current
  target), not on the target you first picked.
- The Magic Burst party call goes out even when the nuke is then stopped
  (recast, MP).

## Configuration files for this job

In `<YourName>/blm/`:

| File | What you set there |
|---|---|
| `BLM_STATES.lua` | Modes, their values and defaults |
| `BLM_KEYBINDS.lua` | The BLM keys above |
| `BLM_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty in the template) |
| `BLM_HUD.lua` | Order of the HUD sections and rows on BLM (also written by `//gs c ui order`) |
| `BLM_LOCKSTYLE.lua` | Lockstyle number (`default` = 5; `by_subjob` is not read, see [configuration](../../guides/configuration.md)) |
| `BLM_MACROBOOK.lua` | Macro book and page per subjob, and per dual-box partner job |
| `BLM_MP_CONFIG.lua` | `mp_threshold` (1000): under it, `sets.midcast.MPConservation` goes on a nuke |
| `BLM_ELEMENTAL_CONFIG.lua` | BLM's own Obi rule (storm, day, weather); only used when the shared belt is off |
| `BLM_TP_CONFIG.lua` | Moonshade Earring entry; not read by the weaponskill TP code today |
| `BLM_REFILL.lua` | Optional, not in the template: items `//gs c rf` keeps in your inventory |

Shared by every job, in `<YourName>/common/`: `COMMON_KEYBINDS.lua`,
`combat_mode.lua` and `treasure_mode.lua` (written by their commands),
`ELEMENTAL_BELT.lua`, `RECAST_CONFIG.lua`, `WEAPON_CONFIG.lua`,
`DW_CONFIG.lua`, `STEALTH_CONFIG.lua`, `UI_CONFIG.lua`. Your sets are in
`<YourName>/blm/blm_sets.lua`. See [configuration](../../guides/configuration.md).

## More

- [BLM modes and keys in detail](states.md)
- [BLM set names and automatic gear](sets.md)
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md), [set names guide](../../guides/sets.md)
