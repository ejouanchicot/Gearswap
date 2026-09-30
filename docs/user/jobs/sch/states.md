# SCH — modes and keys

Scholar: your weapons, your engaged and damage-taken modes, Magic Burst, and
the Element / Nuke Tier modes that the `nuke`, `helix` and `storm` commands
read.

Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Alt = `!`, Apps = `#` (the menu key), Shift = `~`, Win = `@`.
The HUD (`//gs c ui`) shows each mode's current value; this page says what each
value does. `#numpad0` (Auto Medicine) and Alt+Numpad7-9 (alts) are common to
every job, see [keybinds](../../guides/keybinds.md).

This page describes the provided template (`_master/config/sch/`). Every key and
command of the job, on one page: [README.md](README.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Free** | Main hand. Add your weapons in `SCH_STATES.lua`: each value is `sets.<Weapon>` from your set file (or the plain weapon, if `WEAPON_CONFIG.lua` has `equip_without_set = true`). `Free` keeps the weapon you wear. |
| `^numpad2` | Sub Weapon (`SubWeapon`) | **Free** | Off hand (grip or shield), the same way. |
| `^numpad3` | Element (`Element`) | **Fire**, Ice, Wind, Earth, Lightning, Water, Light, Dark | The element of `//gs c nuke`, `helix` and `storm`. |
| `^numpad4` | Nuke Tier (`NukeTier`) | **V**, IV, III, II, I | The tier `//gs c nuke` asks for (I = the spell without a number: Fire). A tier that cannot go out drops to the next one down by itself. |
| `^numpad5` | Magic Burst (`MagicBurstMode`) | **Off**, On | On: nukes wear `sets.midcast['Elemental Magic'].MagicBurst`, helices `sets.midcast.Helix.MagicBurst` (or `.Dark.MagicBurst` / `.Light.MagicBurst`), Kaustra `sets.midcast.Kaustra.MagicBurst`, when your set file has them. |
| `^numpad6` | Offense Mode (`OffenseMode`) | **Normal**, Acc | Engaged gear: `sets.engaged.Acc` when your set file has it. |
| `^numpad7` | Sneak/Invi AOE (`SneakInviAOE`) | **On**, Off | On: `//gs c aoe sneak` / `aoe invi` use Accession and cast on you (whole party). Off: no Accession, cast on a party member you pick (`<stal>`). |
| `^numpad8` | Combat Mode (`CombatMode`) | **Off**, On | On: main, sub and range stay where they are (no spell set moves them). |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **Normal**, DT | DT: `sets.idle.DT` (outside a city) and `sets.engaged.DT`. |

Mote-Include's F-keys reach the same modes: F9 Offense Mode, Ctrl+F9 Hybrid Mode.

### Action keys

| Key | Command | What it does |
|---|---|---|
| `#numpad1` | `lightarts` | Light Arts, then Addendum: White on the next press |
| `#numpad2` | `darkarts` | Dark Arts, then Addendum: Black on the next press |
| `#numpad3` | `nuke` | Element's nuke at Nuke Tier, on your target |
| `#numpad4` | `helix` | Element's helix (II, or I), on your target |
| `#numpad5` | `storm` | Element's storm (II, or I), on you |

| Element | Nuke | Helix | Storm |
|---|---|---|---|
| Fire | Fire | Pyrohelix | Firestorm |
| Ice | Blizzard | Cryohelix | Hailstorm |
| Wind | Aero | Anemohelix | Windstorm |
| Earth | Stone | Geohelix | Sandstorm |
| Lightning | Thunder | Ionohelix | Thunderstorm |
| Water | Water | Hydrohelix | Rainstorm |
| Light | none | Luminohelix | Aurorastorm |
| Dark | none | Noctohelix | Voidstorm |

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog when it cannot read the Fast Cast of your precast set. |

Change modes with Mote's `//gs c cycle <Mode>` or `//gs c set <Mode> <Value>`, or add
your own in `SCH_CUSTOM.lua`.

## Notes

- Every mode goes back to its default on each job change, subjob change or
  reload.
- Arts: while Addendum: White / Black is up, the game shows it instead of Light
  / Dark Arts. The job counts the addendum as its Arts; in your own
  `SCH_CUSTOM.lua` rules, name both (`buff = {'Dark Arts', 'Addendum: Black'}`).
- Idle: `sets.idle.Town` / `sets.Adoulin` in a city, `sets.MoveSpeed` while
  moving outside a city.

## Files

In `<YourChar>/sch/`: `SCH_STATES.lua` (modes and defaults),
`SCH_KEYBINDS.lua` (keys), `SCH_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `SCH_TP_CONFIG.lua` (TP bonus),
`SCH_LOCKSTYLE.lua` (lockstyle 1), `SCH_MACROBOOK.lua` (book 1, page 1). See
[configuration](../../guides/configuration.md).
