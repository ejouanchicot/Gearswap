# DRG — Dragoon

The page to open first when you play Dragoon. It lists every key, every
command and every automatic feature you get on DRG with the provided template.

- What each mode and value does: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

## Overview

Dragoon is set up as a polearm fighter with a wyvern. The template's sets are
empty: you fill them in. The job does these things by itself:

- **Wyvern gear while it is out.** Idle, outside a city, `sets.idle.Pet` goes
  on top of your idle set while the wyvern is out (`sets.idle.Pet.DT` with
  Hybrid Mode DT).
- **Spirit Surge.** `sets.buff['Spirit Surge']` on top of your engaged gear
  while Spirit Surge is up.
- **Healing Breath trigger.** When you cast a spell with the wyvern out and
  your HP under the line of your subjob (50% on /WHM /BLM /RDM /SMN /BLU /SCH
  /GEO, 33.3% on /PLD /DRK /BRD /NIN /RUN), `sets.midcast.HealingBreathTrigger`
  goes on top of the spell's gear: put the Dragoon artifact head there, it
  raises the HP line at which the wyvern cures you.
- **Breath gear.** `sets.midcast.HealingBreath` and `sets.midcast.ElementalBreath`
  when the game reports the wyvern's breath (to be confirmed in game, see
  [sets.md](sets.md#the-wyverns-breaths)).
- **Jumps.** One set per jump, and `//gs c jump` uses the first jump that is
  ready.
- **Weapon and grip from modes** (Main Weapon, Sub Weapon). The template has
  only `Free`: add your weapons in `DRG_STATES.lua`.

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Main Weapon (template: `Free` only) | always | yes |
| `^numpad2` | Sub Weapon, the grip (template: `Free` only) | always | yes |
| `^numpad3` | Offense Mode: Normal, Acc | always | yes |
| `^numpad4` | WS Mode: Normal, Acc | always | yes |
| `^numpad9` | Hybrid Mode: Normal, DT | always | yes |
| `numpad3` (example) | Camlann's Torment with a polearm: a commented example in `DRG_KEYBINDS.lua` | once you remove the `--` | when active |
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
| `f10` / `f11` | Mote: physical / magical defense mode: `sets.defense.PDT` / `.MDT` over your idle and engaged gear, if you add them | always | not on the HUD |
| `^f10` / `!f12` | Mote: physical defense choice / defense mode off | always | not on the HUD |
| `!f10` | Mote: Kiting on / off: `sets.Kiting` over idle and engaged gear | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | once you make one | listed by `tb list` |

- The six common keys come from your `common/keys/COMMON_KEYBINDS.lua`.
- Your own keys from `DRG_CUSTOM.lua` are added on top (the template file has
  only commented examples). `//gs c kc` lists every key conflict.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

**Dragoon commands**

| Command | What it does |
|---|---|
| `jump` | Uses the first jump of your list (`jumps` in `DRG_TP_CONFIG.lua`, by default Soul Jump, Spirit Jump, Jump, High Jump) that you have and that is ready. When all are on recast, shows their time left |

**Commands of every job**: the same as on the other jobs (`ui`, `cyclestate`,
`checksets`, `wa`, `wo`, `rf`, `reload`, `ls`, `warp`, `waltz`, `dw`, `th`,
`combatmode`, `debugmidcast`, `trace on|off`...): see the
[commands guide](../../guides/commands.md). With `trace on`, each idle and
engaged set chosen is logged.

## Shared features on this job

| Feature | Effect on DRG |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `DRG_TP_CONFIG.lua` ([TP bonus](../war/tp-bonus.md)) |
| Combat Mode | Hidden; `//gs c combatmode show`, then `!numpad0` |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Movement speed | `sets.MoveSpeed` while you move, idle, outside a city |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities |
| Doom | `sets.buff.Doom` while doomed |
| Your own modes | `DRG_CUSTOM.lua`: modes with a key and gear rules, without code |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 0.5 s later; every mode goes back to its default |
| Keybind HUD, dual-box, chat messages | As on every job |

## Configuration files for this job

In `<YourName>/drg/`:

| File | What it sets |
|---|---|
| `DRG_STATES.lua` | Every mode: values and defaults (add your weapons and grips here) |
| `DRG_KEYBINDS.lua` | The job keys above |
| `DRG_TP_CONFIG.lua` | TP bonus pieces for your weaponskills (Moonshade Earring +250), and `jumps`: the order `//gs c jump` tries the jumps in |
| `DRG_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `DRG_LOCKSTYLE.lua` | Lockstyle number (`default = 1`) |
| `DRG_MACROBOOK.lua` | Macro book and page (book 1, page 1), per subjob and per alt job |
| `DRG_HUD.lua` | Order of this job's HUD sections and rows |

Sets: `<YourName>/drg/drg_sets.lua`, see [sets.md](sets.md).

## Not done by the job

No automatic Call Wyvern, Spirit Link or Restoring Breath, and no automatic
jump before a weaponskill (the Jump Auto mode of WAR and DNC works only with
/DRG). Steady Wing has no set: its barrier counts the wyvern HP gear you wore
a moment before, so keep wyvern HP pieces in your idle or engaged sets.
