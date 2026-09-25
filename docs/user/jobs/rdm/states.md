# RDM — modes and keys

Red Mage modes choose your idle and engaged gear, your weapons, and the spell each
cast command uses (nukes, enspells, gains, bars, spikes).

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

This page describes the generic template (`_master/config/rdm/`). Kaories's overlay
differs in two values: Maxentius replaces Daybreak (and is the default weapon), and
`CombatMode` starts On.

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | `MainWeapon` | **Naegling**, Colada, Daybreak | Main-hand weapon |
| `^numpad2` | `SubWeapon` | Ammurapi, **Genmei**, Malevolence | Off hand. With a shield your engaged set is `sets.engaged.<Mode>`; with a second weapon, `sets.engaged.<Mode>.DW` if you defined it |
| `^numpad6` | `EngagedMode` | **DT**, Acc, TP, Enspell | Engaged gear: `sets.engaged.DT`, `.Acc`, `.TP` or `.Enspell` |
| `^numpad4` | `IdleMode` | **Refresh**, DT | Idle gear: `sets.idle.Refresh` or `sets.idle.DT` |
| `^numpad5` | `CombatMode` | **Off**, On | `On` locks main, sub and range so casting never swaps your weapons (TP kept). `Off` frees them, unless a craft session holds them |
| `^numpad3` | `EnfeebleMode` | **Potency**, Skill, Duration | Meant to pick the enfeebling set. Today it changes no gear: every enfeeble already uses its own type set |
| `^numpad7` | `NukeMode` | **FreeNuke**, Magic Burst | Elemental midcast: `sets.midcast['Elemental Magic']` or its `['Magic Burst']` variant |
| `^numpad0` | `SaboteurMode` | **Off**, On | `On` = the spells listed in `RDM_SABOTEUR_CONFIG.lua` (template: Distract III, Gravity II) use Saboteur first when it is ready, then go out once it is up |
| `^numpad8` | `NukeTier` | **V**, IV, III, II, I | Tier of the `cast*` nuke commands (`I` = base spell) |
| `^numpad.` | `EnSpell` | **Enfire**, Enblizzard, Enaero, Enstone, Enthunder, Enwater | Spell of `//gs c castenspell` |
| `^numpad+` | `GainSpell` | **Gain-STR** … Gain-CHR | Spell of `//gs c castgain` |
| `^numpad-` | `Barspell` | **Barfire**, Barblizzard, Baraero, Barstone, Barthunder, Barwater | Spell of `//gs c castbar` |
| `^numpad*` | `BarAilment` | **Baramnesia**, Barparalyze, Barsilence, Barpetrify, Barpoison, Barblind, Barsleep, Barvirus | Spell of `//gs c castbarailment` |
| `^numpad/` | `Spike` | **Blaze Spikes**, Ice Spikes, Shock Spikes | Spell of `//gs c castspike` |
| `#numpad1` (/SCH) | `Storm` | **Firestorm**, Hailstorm, Windstorm, Sandstorm, Thunderstorm, Rainstorm, Aurorastorm, Voidstorm | Spell of `//gs c caststorm`. The mode and key exist only under /SCH |

## Other modes (no key)

| Mode | Values | Use |
|---|---|---|
| `MainLightSpell` / `SubLightSpell` | Fire, Aero, Thunder (defaults **Fire** / **Thunder**) | Elements of `castlight` / `castsublight` |
| `MainDarkSpell` / `SubDarkSpell` | Blizzard, Stone, Water (defaults **Blizzard** / **Stone**) | Elements of `castdark` / `castsubdark` |
| `FastCast` | 0 to 80 by 10, default **80** | Your Fast Cast %, used only by the midcast watchdog |

Change them with Mote's `//gs c cycle <Mode>` or `//gs c set <Mode> <Value>`, or bind
them in `RDM_CUSTOM.lua`.

## Commands

| Command | What it does |
|---|---|
| `//gs c castlight` / `castsublight` / `castdark` / `castsubdark` | Casts `<Element> <NukeTier>` on your target |
| `//gs c castenspell` / `castgain` / `castbar` / `castbarailment` / `castspike` / `caststorm` | Casts the mode's current spell on yourself |
| `//gs c enspell <element>` | Casts that enspell (fire, ice/blizzard, wind/aero, earth/stone, thunder, water). Without an element: cycles `EnSpell` |
| `//gs c cyclestorm` | Cycles `Storm` (says so if you are not /SCH) |
| `//gs c convert` / `chainspell` / `saboteur` / `composure` | Uses that ability on yourself |
| `//gs c <Action Name> [<target>]` | Any job ability, weaponskill or spell, by its exact English name, e.g. `//gs c Dia III <t>` (default target `<me>`) |

## Notes

- All modes go back to their default on every job change, subjob change and reload.
- The last command answers only names the game knows; anything else prints
  "Command not recognized" (a dual-box alt command of that name still reaches the alt).

## Files

In `<YourChar>/config/rdm/`:

| File | Content |
|---|---|
| `RDM_STATES.lua` | Modes, their values and defaults |
| `RDM_KEYBINDS.lua` | The keys above |
| `RDM_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty by default) |
| `RDM_SABOTEUR_CONFIG.lua` | Spells that get an automatic Saboteur, and the wait |
| `RDM_LOCKSTYLE.lua` | Lockstyle number per subjob |
| `RDM_MACROBOOK.lua` | Macro book/page (book 2, page 1 in the template) |
| `RDM_TP_CONFIG.lua` | TP-bonus pieces used for weaponskill gear |
