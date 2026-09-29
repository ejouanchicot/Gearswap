# MNK — Monk

The page to open first when you play Monk. It lists every key, every command
and every automatic feature you get on MNK with the provided template.

- What each mode and value does: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

## Overview

Monk is set up as a hand-to-hand fighter with one weapon (no off hand). The
template's sets are empty: you fill them in. The job does these things by
itself:

- **Buff gear while fighting.** While Counterstance, Footwork, Impetus or
  Hundred Fists is up, `sets.buff.Counterstance`, `sets.buff.Footwork`,
  `sets.buff.Impetus`, `sets.buff['Hundred Fists']` go on top of your engaged
  set (in that order: a later one wins a slot both use). They come off when
  the buff wears.
- **Impetus on weaponskills.** With Impetus up, `sets.buff.Impetus` goes on
  top of every weaponskill set, then `sets.precast.WS['<name>'].Impetus` if
  you made one (the template has it for Victory Smite and Ascetic's Fury).
- **Footwork on kicks.** With Footwork up, `sets.buff.Footwork` goes on top
  of Dragon Kick and Tornado Kick, then their `.Footwork` set.
- **Counter mode.** Hybrid Mode has a third value, Counter, for a counter set
  (`sets.engaged.Counter`).
- **Weapon from a mode** (Main Weapon). The template has only `Free`: add your
  weapons in `MNK_STATES.lua`.

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Main Weapon (template: `Free` only) | always | yes |
| `^numpad2` | WS Mode: Normal, Acc | always | yes |
| `^numpad3` | Offense Mode: Normal, Acc | always | yes |
| `^numpad9` | Hybrid Mode: Normal, DT, Counter | always | yes |
| `numpad3` (example) | Victory Smite with a hand-to-hand weapon: a commented example in `MNK_KEYBINDS.lua` | once you remove the `--` | when active |
| `!numpad0` | Combat Mode: Off, On (weapon lock) | after `//gs c combatmode show` | no |
| `!numpad.` | Treasure Mode: Off, Tag, Full | after `//gs c th show` | no |
| `#numpad0` | Auto Medicine on / off (common key) | always | yes |
| `!numpad7` | Your other boxes follow you (common key) | always | yes |
| `!numpad8` | Other boxes' automation on / off (common key) | always | yes |
| `!numpad9` | Other boxes mirror you (common key) | always | yes |
| `!z` | Sneak on you and every other box (common key) | always | yes |
| `!x` | Invisible on you and every other box (common key) | always | yes |
| `f9` | Mote: cycle Offense Mode (same as `^numpad3`) | always | not on the HUD |
| `^f9` | Mote: cycle Hybrid Mode (same as `^numpad9`) | always | not on the HUD |
| `@f9` | Mote: cycle WS Mode (same as `^numpad2`) | always | not on the HUD |
| `f10` / `f11` | Mote: physical / magical defense mode: `sets.defense.PDT` / `.MDT` over your idle and engaged gear, if you add them | always | not on the HUD |
| `^f10` / `!f12` | Mote: physical defense choice / defense mode off | always | not on the HUD |
| `!f10` | Mote: Kiting on / off: `sets.Kiting` over idle and engaged gear | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | once you make one | listed by `tb list` |

- The six common keys come from your `config/COMMON_KEYBINDS.lua`.
- Your own keys from `MNK_CUSTOM.lua` are added on top (the template file has
  only commented examples). `//gs c kc` lists every key conflict.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

Monk has no command of its own. The commands of every job work as on the other
jobs (`ui`, `cyclestate`, `checksets`, `wa`, `wo`, `rf`, `reload`, `ls`,
`warp`, `waltz` on /DNC, `th`, `combatmode`, `debugmidcast`, `trace
on|off`...): see the [commands guide](../../guides/commands.md). With `trace
on`, each engaged set chosen is logged with the buff sets laid on top, and
each weaponskill with its Impetus / Footwork layers.

## Shared features on this job

| Feature | Effect on MNK |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `MNK_TP_CONFIG.lua` ([TP bonus](../war/tp-bonus.md)) |
| Combat Mode | Hidden; `//gs c combatmode show`, then `!numpad0` |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Movement speed | `sets.MoveSpeed` while you move, idle, outside a city |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities |
| Doom | `sets.buff.Doom` while doomed |
| Utsusemi (/NIN) | `sets.midcast.Utsusemi`; Utsusemi: Ichi removes your shadows so it can replace them (needs the Cancel addon) |
| Your own modes | `MNK_CUSTOM.lua`: modes with a key and gear rules, without code |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 0.5 s later; every mode goes back to its default |
| Keybind HUD, dual-box, chat messages | As on every job |

## Configuration files for this job

In `<YourName>/config/mnk/`:

| File | What it sets |
|---|---|
| `MNK_STATES.lua` | Every mode: values and defaults (add your weapons here) |
| `MNK_KEYBINDS.lua` | The job keys above |
| `MNK_TP_CONFIG.lua` | TP bonus pieces for your weaponskills (Moonshade Earring +250), and weapons with their own TP bonus (Godhands +500 as a commented example) |
| `MNK_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `MNK_LOCKSTYLE.lua` | Lockstyle number (`default = 1`) |
| `MNK_MACROBOOK.lua` | Macro book and page (book 1, page 1), per subjob and per alt job |
| `MNK_HUD.lua` | Order of this job's HUD sections and rows |

Sets: `<YourName>/sets/mnk_sets.lua`, see [sets.md](sets.md).

## Not done by the job

No automatic Impetus, Footwork or Boost before a weaponskill. No Boost set
while Boost is up (a `MNK_CUSTOM.lua` rule can do it: `when = { buff = 'Boost'
}`). Perfect Counter, Inner Strength, Mantra and Formless Strikes have their
ability set only.
