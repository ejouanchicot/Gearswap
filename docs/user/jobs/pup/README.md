# PUP — Puppetmaster

The page to open first when you play Puppetmaster. It lists every key, every
command and every automatic feature you get on PUP with the provided template.

- What each mode and value does, and how the automaton changes your gear: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

## Overview

Puppetmaster is set up as a hand-to-hand fighter with an automaton. The
template's sets are empty: you fill them in. The job does these things by
itself:

- **Pet Mode from the automaton's head.** Harlequin = Melee, Valoredge = Tank,
  Sharpshot = Ranged, Stormwaker = Magic, Soulsoother = Heal, Spiritreaver =
  Nuke. Set again whenever you change the head or bring a new automaton out.
- **Automaton gear.** Idle, `sets.idle.Pet` while the automaton is out and
  `sets.idle.Pet.Engaged.<Pet Mode>` while it fights; engaged, `sets.engaged.Pet`
  while you both fight.
- **Automaton weaponskill gear, in time.** While Pet WS is On, the automaton
  fights and its TP reaches 1000 (`PUP_TP_CONFIG.lua`), its weaponskill set goes
  on top of your gear, before the weaponskill.
- **Overdrive.** `sets.buff.Overdrive` on top while Overdrive is up.
- **Maneuvers.** One set for the eight maneuvers (`sets.precast.JA.Maneuver`).
  They share one 10-second recast: one used on recast is cancelled with its
  time left, like any ability.
- **Weapon from a mode** (Main Weapon). The template has only `Free`: add your
  weapons in `PUP_STATES.lua`.

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Main Weapon (template: `Free` only) | always | yes |
| `^numpad2` | Offense Mode: Normal, Acc | always | yes |
| `^numpad9` | Hybrid Mode: Normal, DT | always | yes |
| `^numpad3` | Pet Mode: Melee, Tank, Ranged, Magic, Heal, Nuke (set by itself from the head) | always | yes |
| `^numpad4` | Pet WS: On, Off | always | yes |
| `!numpad1` (example) | Victory Smite with a hand-to-hand weapon: a commented example in `PUP_KEYBINDS.lua` | once you remove the `--` | when active |
| `!numpad0` | Combat Mode: Off, On (weapon lock) | after `//gs c combatmode show` | no |
| `!numpad.` | Treasure Mode: Off, Tag, Full | after `//gs c th show` | no |
| `#numpad0` | Auto Medicine on / off (common key) | always | yes |
| `!numpad7` | Your other boxes follow you (common key) | always | yes |
| `!numpad8` | Other boxes' automation on / off (common key) | always | yes |
| `!numpad9` | Other boxes mirror you (common key) | always | yes |
| `!z` | Sneak on you and every other box (common key) | always | yes |
| `!x` | Invisible on you and every other box (common key) | always | yes |
| `f9` | Mote: cycle Offense Mode (same as `^numpad2`) | always | not on the HUD |
| `^f9` | Mote: cycle Hybrid Mode (same as `^numpad9`) | always | not on the HUD |
| `f10` / `f11` | Mote: physical / magical defense mode: `sets.defense.PDT` / `.MDT` over your idle and engaged gear, if you add them | always | not on the HUD |
| `^f10` / `!f12` | Mote: physical defense choice / defense mode off | always | not on the HUD |
| `!f10` | Mote: Kiting on / off: `sets.Kiting` over idle and engaged gear | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | once you make one | listed by `tb list` |

- The six common keys come from your `common/COMMON_KEYBINDS.lua`.
- Your own keys from `PUP_CUSTOM.lua` are added on top (the template file has
  only commented examples). `//gs c kc` lists every key conflict.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

**Puppetmaster commands**

| Command | What it does |
|---|---|
| `petmode` | Shows the automaton: head, frame, the Pet Mode they give, the Pet Mode in use, Pet WS, whether it is out or fighting, its TP against the WS threshold (green when the WS gear is on) |
| `petmode auto` | Sets Pet Mode from the head again (ends a value you cycled by hand), then puts the gear on |

**Commands of every job**: the same as on the other jobs (`ui`, `cyclestate`,
`checksets`, `wa`, `wo`, `rf`, `reload`, `ls`, `warp`, `waltz`, `dw`, `th`,
`combatmode`, `debugmidcast`, `trace on|off`...): see the
[commands guide](../../guides/commands.md). With `trace on`, each idle and
engaged set chosen is logged, with the automaton layers laid on top.

## Shared features on this job

| Feature | Effect on PUP |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left, maneuvers included (one shared 10-second recast) |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `PUP_TP_CONFIG.lua` ([TP bonus](../war/tp-bonus.md)) |
| Combat Mode | Hidden; `//gs c combatmode show`, then `!numpad0` |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Movement speed | `sets.MoveSpeed` while you move, idle, outside a city |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities |
| Doom | `sets.buff.Doom` while doomed |
| Your own modes | `PUP_CUSTOM.lua`: modes with a key and gear rules, without code |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 0.5 s later; every mode goes back to its default (Pet Mode is read from the head again) |
| Keybind HUD, dual-box, chat messages | As on every job |

## Configuration files for this job

In `<YourName>/pup/`:

| File | What it sets |
|---|---|
| `PUP_STATES.lua` | Every mode: values and defaults (add your weapons here) |
| `PUP_KEYBINDS.lua` | The job keys above |
| `PUP_TP_CONFIG.lua` | TP bonus pieces for your weaponskills (Moonshade Earring +250), and `pet_ws_tp` (1000): the automaton TP from which its weaponskill gear goes on |
| `PUP_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `PUP_LOCKSTYLE.lua` | Lockstyle number (`default = 1`) |
| `PUP_MACROBOOK.lua` | Macro book and page (book 1, page 1), per subjob and per alt job |
| `PUP_HUD.lua` | Order of this job's HUD sections and rows |

Sets: `<YourName>/pup/pup_sets.lua`, see [sets.md](sets.md).

## Not done by the job

No automatic maneuvers, Repair, Deploy or Activate, no pet enmity gear and no
party message for automaton weaponskills. Attachments are not read.
