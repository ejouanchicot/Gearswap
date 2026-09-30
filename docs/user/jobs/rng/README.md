# RNG — Ranger

The page to open first when you play Ranger. It lists every key, every command
and every automatic feature you get on RNG with the provided template.

- What each mode and value does: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

## Overview

Ranger is set up as a ranged job (bow, gun or crossbow) that can also melee.
The template's sets are empty: you fill them in. The job does these things by
itself:

- **Range weapon from a mode** (Range Weapon). Its set holds the weapon **and
  its ammo** (`sets['Fomalhaut'] = {range = "Fomalhaut", ammo = "Chrono
  Bullet"}`). The template has only `Free`: add your weapons in
  `RNG_STATES.lua`. Main and sub weapons work the same way.
- **Ranged attack gear.** The aim (`sets.precast.RA`, Snapshot / Rapid Shot),
  with its Flurry I / Flurry II versions while that Flurry is on you; then the
  shot (`sets.midcast.RA`). Ranged Mode Acc picks the `.Acc` versions.
- **Buff gear on the shot.** While Velocity Shot, Hover Shot, Decoy Shot,
  Unlimited Shot, Double Shot or Barrage is up, its `sets.buff` set goes on
  top of the shot (Velocity Shot on the aim too).
- **Ammo refill.** After a ranged attack, when 15 or fewer of the ammo you
  wear are left, its quiver or pouch is opened (it must be in your inventory).
- **Obi / Orpheus** on Trueflight and Wildfire, chosen by day, weather and
  distance, if you own them.
- **Off hand only with Dual Wield.** Ranger has no Dual Wield of its own: an
  off-hand weapon is held with /NIN or /DNC; otherwise `sets.SingleWield`'s
  sub (a shield) replaces it, or the off hand stays as it is.

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Main Weapon (template: `Free` only) | always | yes |
| `^numpad2` | Range Weapon (template: `Free` only) | always | yes |
| `^numpad3` | Ranged Mode: Normal, Acc | always | yes |
| `^numpad9` | Hybrid Mode: Normal, DT | always | yes |
| `^numpad4` | Sub Weapon (template: `Free` only) | always | yes |
| `^numpad5` | Offense Mode: Normal, Acc | always | yes |
| `^numpad6` | WS Mode: Normal, Acc | always | yes |
| `!numpad1`-`!numpad3` (examples) | Last Stand, Trueflight, Savage Blade (sword only): commented examples in `RNG_KEYBINDS.lua` | once you remove the `--` | when active |
| `!numpad0` | Combat Mode: Off, On (locks main, sub and range) | after `//gs c combatmode show` | no |
| `!numpad.` | Treasure Mode: Off, Tag, Full | after `//gs c th show` | no |
| `#numpad0` | Auto Medicine on / off (common key) | always | yes |
| `!numpad7` | Your other boxes follow you (common key) | always | yes |
| `!numpad8` | Other boxes' automation on / off (common key) | always | yes |
| `!numpad9` | Other boxes mirror you (common key) | always | yes |
| `!z` | Sneak on you and every other box (common key) | always | yes |
| `!x` | Invisible on you and every other box (common key) | always | yes |
| `f9` | Mote: cycle Offense Mode (same as `^numpad5`) | always | not on the HUD |
| `^f9` | Mote: cycle Hybrid Mode (same as `^numpad9`) | always | not on the HUD |
| `!f9` | Mote: cycle Ranged Mode (same as `^numpad3`) | always | not on the HUD |
| `@f9` | Mote: cycle WS Mode (same as `^numpad6`) | always | not on the HUD |
| `f10` / `f11` | Mote: physical / magical defense mode: `sets.defense.PDT` / `.MDT` over your idle and engaged gear, if you add them | always | not on the HUD |
| `^f10` / `!f12` | Mote: physical defense choice / defense mode off | always | not on the HUD |
| `!f10` | Mote: Kiting on / off: `sets.Kiting` over idle and engaged gear | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | once you make one | listed by `tb list` |

- The six common keys come from your `common/COMMON_KEYBINDS.lua`.
- Your own keys from `RNG_CUSTOM.lua` are added on top (the template file has
  only commented examples). `//gs c kc` lists every key conflict.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

Ranger has no command of its own. **Commands of every job**: `ui`,
`cyclestate`, `checksets`, `wa`, `wo`, `rf`, `reload`, `ls`, `warp`, `waltz`,
`dw`, `th`, `belt`, `combatmode`, `debugmidcast`, `trace on|off`...: see the
[commands guide](../../guides/commands.md). With `trace on`, each idle and
engaged set chosen is logged, and each ranged buff set laid on a shot.

## Shared features on this job

| Feature | Effect on RNG |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `RNG_TP_CONFIG.lua` ([TP bonus](../war/tp-bonus.md)); a bow or gun's own TP bonus is not counted |
| Obi / Orpheus | Trueflight and Wildfire (and the other elemental weaponskills), when you own the belts (`//gs c belt`) |
| Dual Wield tiers | With /NIN or /DNC and two weapons: your `sets.DW` pieces by magic haste (`//gs c dw`) |
| Combat Mode | Hidden; `//gs c combatmode show`, then `!numpad0`. Locks main, sub and range |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Utsusemi | /NIN: Utsusemi: Ichi cancels your shadows so it can take over (needs the Cancel addon) |
| Movement speed | `sets.MoveSpeed` while you move, idle, outside a city |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities |
| Doom | `sets.buff.Doom` while doomed |
| Your own modes | `RNG_CUSTOM.lua`: modes with a key and gear rules, without code. They never change a ranged attack: use the ranged sets for that |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 0.5 s later; every mode goes back to its default |
| Keybind HUD, dual-box, chat messages | As on every job |

## Configuration files for this job

In `<YourName>/rng/`:

| File | What it sets |
|---|---|
| `RNG_STATES.lua` | Every mode: values and defaults (add your weapons here) |
| `RNG_KEYBINDS.lua` | The job keys above |
| `RNG_TP_CONFIG.lua` | TP bonus pieces for your weaponskills (Moonshade Earring +250) |
| `RNG_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `RNG_LOCKSTYLE.lua` | Lockstyle number (`default = 1`) |
| `RNG_MACROBOOK.lua` | Macro book and page (book 1, page 1), per subjob and per alt job |
| `RNG_HUD.lua` | Order of this job's HUD sections and rows |

Sets: `<YourName>/rng/rng_sets.lua`, see [sets.md](sets.md).

## Not done by the job

No ammo protection (nothing stops a shot or weaponskill that would spend a
rare ammo), no Aftermath gear for the ranged relic / mythic / empyrean
weapons, no automatic Barrage, Double Shot or Velocity Shot.
