# RDM — modes and keys

Red Mage modes choose your idle and engaged gear, your weapons, and the spell each
cast command uses (nukes, enspells, gains, bars, spikes).

Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

This page describes the provided template (`_master/config/rdm/`). A character
overlay used by the clone script can change values and defaults (another weapon
list, Combat Mode starting On...): if yours came from one, trust your own
`RDM_STATES.lua`. Every key and command of the job, on one page:
[README.md](README.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | `MainWeapon` | **Naegling**, Colada, Daybreak | Main-hand weapon |
| `^numpad2` | `SubWeapon` | Ammurapi, **Genmei**, Malevolence | Off hand. With a shield your engaged set is `sets.engaged.<Mode>`; with a second weapon on /NIN or /DNC, `sets.engaged.<Mode>.DW` if you defined it (other subjobs keep the normal set) |
| `^numpad6` | `EngagedMode` | **DT**, Acc, TP, Enspell | Engaged gear: `sets.engaged.DT`, `.Acc`, `.TP` or `.Enspell` |
| `^numpad4` | `IdleMode` | **Refresh**, DT | Idle gear: `sets.idle.Refresh` or `sets.idle.DT` |
| `^numpad5` | `CombatMode` | **Off**, On | `On` puts on `sets.CombatMode` if you define one, then locks main, sub and range so casting never swaps your weapons (TP kept). `Off` frees them, unless a craft session holds them |
| `^numpad3` | `EnfeebleMode` | **Potency**, Skill, Duration | Picks `sets.midcast['Enfeebling Magic'].<type>.<Mode>` (for example `.mnd_potency.Skill`) when you add such a set. The plain `.Potency` / `.Skill` / `.Duration` sets only serve an enfeeble with no type (the -ga, Inundation). The template has no `.<type>.<Mode>` set: with it the mode changes no gear |
| `^numpad7` | `NukeMode` | **FreeNuke**, Magic Burst | Elemental midcast: `sets.midcast['Elemental Magic']` or its `['Magic Burst']` variant |
| `^numpad0` | `SaboteurMode` | **Off**, On | `On` = the spells listed in `RDM_SABOTEUR_CONFIG.lua` (template: Distract III, Gravity II) use Saboteur first when it is ready, then go out once it is up |
| `^numpad8` | `NukeTier` | **V**, IV, III, II, I | Tier of the `cast*` nuke commands (`I` = base spell) |
| `^numpad9` | `EnfeebleTier` | **On**, Off | `On`: an enfeeble with tiers (Gravity II, Distract III...) that is on recast or short of MP drops to the next tier that can go. `Off`: it is cancelled and its recast shown, so you keep control of the tier. Nukes step down either way |
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
| `FastCast` | 0 to 80 by 10, default **80** | Your Fast Cast %, used only by the midcast watchdog when it cannot read the Fast Cast of your precast set |
| `HybridMode` | PDT, **Normal** | Mote's mode, cycled by Ctrl+F9. No gear effect: it is read only when `sets.idle.<IdleMode>` or `sets.engaged.<EngagedMode>` is missing, and then only `sets.idle.PDT` / `sets.engaged.PDT` |

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
| `//gs c dispelga [<target>]` | Dispelga on your target (`<t>` by default), macro: `/console gs c dispelga`. Daybreak goes in hand for the cast, even with Combat Mode On, and your weapon comes back after it (the TP is lost). Typed as `/ma "Dispelga"` it only works with Combat Mode Off or Daybreak already in hand |
| `//gs c <Action Name> [<target>]` | Any job ability, weaponskill or spell, by its exact English name, e.g. `//gs c Dia III <t>` (default target `<me>`) |

## Notes

- All modes go back to their default on every job change, subjob change and reload.
- `Storm` exists only while your subjob is SCH: its key and HUD row appear and
  disappear with the subjob.
- The last command answers only names the game knows; anything else prints
  "Command not recognized" (a dual-box alt command of that name still reaches the alt).

## Files

In `<YourChar>/rdm/`:

| File | Content |
|---|---|
| `RDM_STATES.lua` | Modes, their values and defaults |
| `RDM_KEYBINDS.lua` | The keys above |
| `RDM_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty by default) |
| `RDM_SABOTEUR_CONFIG.lua` | Spells that get an automatic Saboteur, and the wait |
| `RDM_LOCKSTYLE.lua` | Lockstyle number per subjob |
| `RDM_MACROBOOK.lua` | Macro book/page (book 2, page 1 in the template) |
| `RDM_TP_CONFIG.lua` | TP-bonus pieces used for weaponskill gear |
