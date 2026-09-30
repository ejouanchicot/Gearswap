# NIN — Ninja

The page to open first when you play Ninja. It lists every key, every command
and every automatic feature you get on NIN with the provided template.

- What each mode and value does: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

## Overview

Ninja is set up as a dual-wielding melee job that also nukes, enfeebles and
tanks with shadows. The template's sets are empty: you fill them in. The job
does these things by itself:

- **Ninjutsu by family.** Utsusemi wears `sets.midcast.Utsusemi`, Migawari
  `sets.midcast.Migawari`, the elemental ninjutsu (Katon..Doton)
  `sets.midcast.Ninjutsu.Elemental`, the enfeebling ones (Kurayami, Hojo,
  Jubaku, Aisha, Yurin, Dokumori) `.Enfeebling`, the others (Tonko, Monomi,
  Myoshu, Kakka, Gekka, Yain) `.Enhancing`.
- **Magic Burst mode.** With Magic Burst On, elemental ninjutsu wears
  `sets.midcast.Ninjutsu.Elemental.MagicBurst`.
- **Futae.** `sets.buff.Futae` on top of the elemental ninjutsu you cast
  under Futae.
- **Yonin, Innin, Sange, Issekigan.** Each one's `sets.buff.<name>` on top of
  your engaged gear while the buff is up.
- **Night movement speed.** While you move outside a city,
  `sets.MoveSpeed.Night` from 17:00 to 7:00 (Vana'diel time),
  `sets.MoveSpeed` the rest of the day.
- **Weapons from modes** (Main Weapon, Sub Weapon). The template has only
  `Free`: add your weapons in `NIN_STATES.lua`.

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Main Weapon (template: `Free` only) | always | yes |
| `^numpad2` | Sub Weapon (template: `Free` only) | always | yes |
| `^numpad3` | Magic Burst: Off, On | always | yes |
| `^numpad4` | Offense Mode: Normal, Acc | always | yes |
| `^numpad5` | WS Mode: Normal, Acc | always | yes |
| `^numpad9` | Hybrid Mode: Normal, DT | always | yes |
| `!numpad1` (examples) | Blade: Hi with a katana, Savage Blade with a sword: commented examples in `NIN_KEYBINDS.lua` | once you remove the `--` | when active |
| `!numpad0` | Combat Mode: Off, On (weapon lock) | after `//gs c combatmode show` | no |
| `!numpad.` | Treasure Mode: Off, Tag, Full | after `//gs c th show` | no |
| `#numpad0` | Auto Medicine on / off (common key) | always | yes |
| `!numpad7` | Your other boxes follow you (common key) | always | yes |
| `!numpad8` | Other boxes' automation on / off (common key) | always | yes |
| `!numpad9` | Other boxes mirror you (common key) | always | yes |
| `!z` | Sneak on you and every other box (common key): Spectral Jig on /DNC, else Monomi | always | yes |
| `!x` | Invisible on you and every other box (common key): Spectral Jig on /DNC, else Tonko | always | yes |
| `f9` | Mote: cycle Offense Mode (same as `^numpad4`) | always | not on the HUD |
| `^f9` | Mote: cycle Hybrid Mode (same as `^numpad9`) | always | not on the HUD |
| `@f9` | Mote: cycle WS Mode (same as `^numpad5`) | always | not on the HUD |
| `f10` / `f11` | Mote: physical / magical defense mode: `sets.defense.PDT` / `.MDT` over your idle and engaged gear, if you add them | always | not on the HUD |
| `^f10` / `!f12` | Mote: physical defense choice / defense mode off | always | not on the HUD |
| `!f10` | Mote: Kiting on / off: `sets.Kiting` over idle and engaged gear | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | once you make one | listed by `tb list` |

- The six common keys come from your `common/keys/COMMON_KEYBINDS.lua`.
- Your own keys from `NIN_CUSTOM.lua` are added on top (the template file has
  only commented examples). `//gs c kc` lists every key conflict.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

Ninja has no command of its own. **Commands of every job**: `ui`,
`cyclestate`, `checksets`, `wa`, `wo`, `rf`, `reload`, `ls`, `warp`, `waltz`,
`dw`, `th`, `stealth`, `belt`, `combatmode`, `debugmidcast`, `trace on|off`...:
see the [commands guide](../../guides/commands.md). With `trace on`, each
engaged set chosen is logged, with the buff layers laid on top;
`debugmidcast` shows which Ninjutsu set was picked and why.

## Shared features on this job

| Feature | Effect on NIN |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left. Utsusemi too: a San on recast is **not** replaced by Ni |
| Utsusemi: Ichi | Your shadows are cancelled 2.3 s into the cast so Ichi can replace them (needs the Cancel addon) |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `NIN_TP_CONFIG.lua` ([TP bonus](../war/tp-bonus.md)) |
| Obi / Orpheus | On elemental ninjutsu and on Blade: Chi, Teki, To, Ei and Aeolian Edge, when one of the belts adds enough (`//gs c belt`) |
| Dual Wield tiers | `sets.DW.*` on top of your engaged gear, by your magic haste (`//gs c dw`) |
| Combat Mode | Hidden; `//gs c combatmode show`, then `!numpad0` |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities |
| Doom | `sets.buff.Doom` while doomed |
| Your own modes | `NIN_CUSTOM.lua`: modes with a key and gear rules, without code |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 0.5 s later; every mode goes back to its default |
| Keybind HUD, dual-box, chat messages | As on every job |

## Configuration files for this job

In `<YourName>/nin/`:

| File | What it sets |
|---|---|
| `NIN_STATES.lua` | Every mode: values and defaults (add your weapons here) |
| `NIN_KEYBINDS.lua` | The job keys above |
| `NIN_TP_CONFIG.lua` | TP bonus pieces for your weaponskills (Moonshade Earring +250) |
| `NIN_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `NIN_LOCKSTYLE.lua` | Lockstyle number (`default = 1`) |
| `NIN_MACROBOOK.lua` | Macro book and page (book 1, page 1), per subjob and per alt job |
| `NIN_HUD.lua` | Order of this job's HUD sections and rows |

Sets: `<YourName>/nin/nin_sets.lua`, see [sets.md](sets.md).

## Not done by the job

No automatic Utsusemi (and no drop from San to Ni when San is on recast), no
ninja tool count or warning, no automatic Yonin / Innin, no party message for
magic bursts.
