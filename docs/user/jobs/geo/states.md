# GEO — modes and keys

Geomancer modes pick which Indi-, Geo- and elemental spells the cast commands use, and
how you and your luopan are geared.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad3` | `MainIndi` | **Indi-Haste** and 29 more | Spell cast by `//gs c indi` and `//gs c entrust` |
| `^numpad4` | `MainGeo` | **Geo-Frailty** and 27 more | Spell cast by `//gs c geo` |
| `^numpad5` | `MainLightSpell` | **Fire**, Aero, Thunder | Element of `//gs c lightspell` |
| `^numpad6` | `MainDarkSpell` | **Blizzard**, Stone, Water | Element of `//gs c darkspell` |
| `^numpad1` | `SpellTier` | **V**, IV, III, II, I | Tier of the single-target nukes (`I` = the base spell, e.g. `Fire`) |
| `^numpad7` | `MainLightAOE` | **Fira**, Aera, Thundara | Spell of `//gs c lightaoe` |
| `^numpad8` | `MainDarkAOE` | **Blizzara**, Stonera, Watera | Spell of `//gs c darkaoe` |
| `^numpad2` | `AOETier` | **III**, II, I | Tier of the -ra nukes (`I` = `Fira`) |
| `^numpad9` | `HybridMode` | **PDT**, Normal | Your idle/engaged base when no luopan is out |
| `^numpad0` | `CombatMode` | **Off**, On | `On` locks main, sub, range and ammo so casting never swaps your weapon. `Off` unlocks them (unless a craft session holds them) |
| `^numpad.` | `LuopanMode` | **DT**, DPS | Engaged gear while a luopan is out: `sets.luopan.engaged.DT` or `.DPS` |
| `^numpad+` | `IndicolureMode` | **Self**, Entrust | Shown in the HUD only; no command reads it today |

`MainIndi` holds the ten common buffs first (Haste, Fury, Precision, Refresh, Barrier,
Acumen, Focus, Voidance, Attunement, Regen), then the seven stat spells, then the
debuffs and Fend. `MainGeo` starts with the debuffs (Frailty, Malaise, Torpor, Slow,
Languor, Paralysis, Vex, Wilt, Slip, Fade, Gravity, Fend, Poison), then the buffs.
Reorder or trim the lists in `GEO_STATES.lua`.

## Other modes (no key)

| Mode | Values | Use |
|---|---|---|
| `MainWeapon`, `SubWeapon` | Idris / Genmei Shield | One value each; change them in `GEO_STATES.lua` |
| `FastCast` | 0 to 80 by 10, default **80** | Your Fast Cast %, used only by the midcast watchdog |

## Commands

| Command | What it does |
|---|---|
| `//gs c indi` | Casts `MainIndi` on yourself |
| `//gs c geo` | Casts `MainGeo`: on a party member (`<stpc>`) for a buff, on an enemy (`<stnpc>`) for a debuff |
| `//gs c entrust` | Uses Entrust, then casts `MainIndi` on a party member (`<stal>`) once Entrust is up; gives up with a warning if Entrust was refused |
| `//gs c escort [Indi-X] [leader]` | Full Circle if a luopan is out, then casts the Indi- on yourself (default Indi-Regen); with a leader name, sends `sm follow <leader>` once the cast is over |
| `//gs c lightspell` / `darkspell` | Nukes your target with the chosen element and `SpellTier`, stepping down a tier when the higher one is not learned or is on recast |
| `//gs c lightaoe` / `darkaoe` | Same with the -ra spells and `AOETier` |
| `//gs c lightarts` / `darkarts` | /SCH: Light or Dark Arts, then the matching Addendum on the next press |
| `//gs c aoe sneak` / `invi` / `erase` | /SCH: casts the spell on the party, with Light Arts and Accession as stratagem charges allow |
| `//gs c dispel` | /RDM: Dispel on an enemy. /SCH: under Addendum: Black. Other subjobs: a warning |

`escort` relies on an addon that answers `sm follow`; without it the follow does nothing.

## Notes

- All modes go back to their default on every job change, subjob change and reload.
- Kaories's overlay (`_master/Kaories/config/geo/`) uses the same modes and keys.

## Files

In `<YourChar>/config/geo/`:

| File | Content |
|---|---|
| `GEO_STATES.lua` | Modes, their values and defaults |
| `GEO_KEYBINDS.lua` | The keys above |
| `GEO_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty by default) |
| `GEO_LOCKSTYLE.lua` | Lockstyle number (5 for every subjob in the template) |
| `GEO_MACROBOOK.lua` | Macro book/page (book 5, page 1 in the template) |
| `GEO_TP_CONFIG.lua` | TP-bonus pieces used for weaponskill gear |
