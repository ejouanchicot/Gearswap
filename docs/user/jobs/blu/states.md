# BLU — modes and keys

Blue Mage: your weapons, your engaged / idle / casting / weaponskill modes, Blue
Magic gear chosen by what each spell scales with, and two optional automatic
abilities (Unbridled Learning, the Expiacion window).

Keys: Ctrl = `^`, Alt = `!`, Apps = `#` (the menu key), Shift = `~`, Win = `@`.
The HUD (`//gs c ui`) shows each mode's current value; this page says what each
value does. `#numpad0` (Auto Medicine) and Alt+Numpad7-9 (alts) are common to
every job, see [keybinds](../../guides/keybinds.md).

This page describes the generic template (`_master/config/blu/`). Gabvanstronger's
own setup is at the end.

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Free** | Main hand. Add your weapons in `BLU_STATES.lua`: each value is `sets.<Weapon>` from your set file (or the plain weapon, if `WEAPON_CONFIG.lua` has `equip_without_set = true`). `Free` keeps the weapon you wear. |
| `^numpad2` | Sub Weapon (`SubWeapon`) | **Free** | Off hand, same rules. It also decides single wield (see below). |
| `^numpad3` | Offense Mode (`OffenseMode`) | **Normal**, Acc, DT, Subtle Blow, Refresh | Engaged gear: `sets.engaged`, or `sets.engaged.<Mode>` when your set file has it. |
| `^numpad4` | Idle Mode (`IdleMode`) | **Normal**, Evasion, DT, Regain | Idle gear: `sets.idle` (Normal) or `sets.idle.<Mode>`. |
| `^numpad5` | Casting Mode (`CastingMode`) | **Normal**, Resistant | Blue Magic: `Resistant` uses the `.Resistant` version of a spell's set when it exists (the template has one, for the `Magical` spells). |
| `^numpad6` | WS Mode (`WeaponskillMode`) | **Normal**, Acc | Weaponskill gear: the `.Acc` version of the weaponskill's set when it exists. The template has only `sets.precast.WS.Acc`, so Acc changes only weaponskills without a set of their own. In `Normal`, an Offense Mode that is also a WS mode (Acc) is used instead. |

Combat Mode (lock your weapons so nothing swaps them) exists on BLU but is hidden:
`//gs c combatmode show` shows it, then `!numpad0` cycles it.

### Weaponskill keys per weapon

`BLU_KEYBINDS.lua` has two commented examples: `numpad3` sends Savage Blade with a
sword in your main hand, Black Halo with a club. Remove the `--` to use them. A key
with `weapon = "Sword"` is bound only while your main hand is a sword, and the keys
change by themselves when you switch weapon type.

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog. |

Change modes with Mote's `//gs c cycle <Mode>` or `//gs c set <Mode> <Value>`, or add
your own in `BLU_CUSTOM.lua`.

## How Blue Magic picks its gear

Each Blue Magic spell belongs to a category in your `BLU_SPELL_MAP.lua`
(`PhysicalDex`, `Magical`, `MagicAccuracy`, `Healing`, `Buff`... 24 in the
template). The spell then wears, the first that exists:

1. a set with the spell's own name: `sets.midcast['Sound Blast']` (the template
   has Sound Blast, Restoral, White Wind);
2. `sets.midcast['Blue Magic'].<Category>.Resistant` with Casting Mode Resistant;
3. `sets.midcast['Blue Magic'].<Category>`;
4. `sets.midcast['Blue Magic']` (a spell in no category).

Then, on top: `sets.buff['Chain Affinity']` (and Burst Affinity, Convergence,
Diffusion, Efflux) while that buff is up, and `sets.self_healing` for a Healing
spell cast on yourself.

- Use the game's short names in the map: `'Winds of Promy.'`, `'Quad. Continuum'`,
  `'Evryone. Grudge'`, `'Tem. Upheaval'`. A misspelt name is never matched.
- A spell listed in two categories keeps the first in alphabetical order of
  category, and a warning names it when the job loads.
- Do not name a set at the root of `sets.midcast` after a category
  (`sets.midcast.Magical`): it would win over `sets.midcast['Blue Magic'].Magical`.
- The map is read once per load: `//gs reload` after editing it.

## Automatic abilities

In `<YourChar>/config/AUTO_ABILITIES.lua`, both off unless set to `true`:

| Option | What it does |
|---|---|
| `blu_unbridled` | When you cast a spell that needs Unbridled Learning (or Wisdom) and neither is up, the spell is stopped, Unbridled Learning goes out, and the spell is cast again on the same target once the buff is up. If Unbridled Learning is not ready, the spell goes out as it is. |
| `blu_expiacion_window` | With Tizona in your main hand, no Aftermath: Lv.3, and between 1000 and 2999 TP, your first Expiacion is cancelled with a warning; press it again within 3 s and it goes. At 3000 TP it goes at once. |

## Commands

BLU has no command of its own. The common commands work (`//gs c reload`,
`checksets`, `wa`, `wo`, `refill`, `debugmidcast`, `ui`, ...), see
[commands](../../guides/commands.md).

## Notes

- **Single wield.** With nothing, a shield or a grip in your off hand, the engaged
  set is `sets.engaged.SW` (then `sets.engaged.SW.<Offense Mode>` if it exists). An
  Offense Mode with no `.SW` version wears `sets.engaged.SW` itself: the template has
  `.SW.Acc` and `.SW.Refresh` only.
- Idle: `sets.idle.Town` / `sets.Adoulin` in a city if you define them,
  `sets.MoveSpeed` while moving outside a city.
- **AzureSets.** The AzureSets addon (`//aset`) is loaded when BLU loads, and
  unloaded once you are no longer BLU (checked 2 s after the job file unloads, so a
  subjob change or `//gs reload` keeps it).
- Weaponskill TP bonus: `BLU_TP_CONFIG.lua` (Moonshade Earring +250).
- Every mode goes back to its default on each job change, subjob change or reload.

## Gabvanstronger

His overlay (`_master/Gabvanstronger/`) keeps his own setup:

- Modes: Offense Mode adds `Capped` (no set of its own); WS Mode is Normal, Capped,
  Acc. Main Weapon: **Tizona**, Naegling, Maxentius, Sequence, Extinction, Free. Sub
  Weapon: **Sakpata's Sword**, Zantetsuken, Thibron, Tanmogayi +1, Nihility, Free.
  Weapons are plain items (no set needed).
- Mode keys: `` ^` `` Main Weapon, `` ^~` `` Sub Weapon, `f9` Offense Mode, `@f9` WS Mode,
  `^f11` Casting Mode, `^f12` Idle Mode; `~f9` Combat Mode.
- His spell and ability keys: `` !` `` Temporal Shift, `!1`-`!6` Erratic Flutter,
  Battery Charge, Cocoon, Diamondhide, Occultation, Aquaveil; `@q` Sheep Song, `@w`
  Dream Flower, `@a` Actinic Burst, `@f` Fantod, `@x` Osmosis, `@v` Entomb; `@1`-`@5`
  Chain Affinity, Burst Affinity, Efflux, Diffusion, Unbridled Learning.
- Weaponskills by weapon: with a sword, `numpad1` Requiescat, `numpad3` Expiacion,
  `numpad7` Chant du Cygne, `numpad9` Savage Blade; with a club, `numpad1` True
  Strike, `numpad3` Black Halo, `numpad9` Judgment.
- Own modes (`BLU_CUSTOM.lua`): Ranged Weapon (`` @` ``: Normal / Pull, Pull equips
  `sets.Pull` and locks range and ammo) and CP Cape (no key:
  `//gs c cyclestate CP`).
- Both automatic abilities are on. Lockstyle 2, macro book 8 page 1.

## Files

In `<YourChar>/config/blu/`: `BLU_STATES.lua` (modes and defaults),
`BLU_KEYBINDS.lua` (keys), `BLU_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `BLU_SPELL_MAP.lua` (spell categories),
`BLU_LOCKSTYLE.lua` (lockstyle 1), `BLU_MACROBOOK.lua` (book 1, page 1),
`BLU_TP_CONFIG.lua`. The options are in `<YourChar>/config/AUTO_ABILITIES.lua`. See
[configuration](../../guides/configuration.md).
