# SCH — Scholar

The page to open first when you play Scholar. It lists every key, every
command and every automatic feature you get on SCH with the provided template.

- What each mode and value does: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

## Overview

Scholar is set up as a caster. The template's sets are empty: you fill them
in. The job does these things by itself:

- **Grimoire gear.** `sets.precast.FC.Grimoire` goes on top of your fast cast
  set when the spell is of the Arts you have up (white magic under Light Arts
  or Addendum: White, black magic under Dark Arts or Addendum: Black).
- **Stratagem gear.** While Perpetuance, Rapture, Ebullience, Immanence,
  Klimaform, Celerity or Alacrity is up, its `sets.buff` set goes on top of
  the spell it affects (see [sets.md](sets.md#buffs)).
- **Sublimation.** `sets.buff.Sublimation` stays on your idle gear while
  Sublimation charges, and comes off when it is complete.
- **Tier fall-back.** A nuke, -ra, Aspir, helix or storm on recast (or not
  learned, or short of MP) is cast at the highest lower tier that can go out
  (Fire V -> Fire IV..., Pyrohelix II -> Pyrohelix), instead of being refused.
- **No wasted stratagem.** A stratagem used with no charge left is stopped,
  with the time to the next charge.
- **Magic Burst mode.** Nukes, helices and Kaustra wear their `.MagicBurst`
  set while it is On.
- **Element mode.** One key picks the element; `nuke`, `helix` and `storm`
  cast that element's spell.
- **Weapons from a mode** (Main Weapon, Sub Weapon). The template has only
  `Free`: add your weapons in `SCH_STATES.lua`.

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Main Weapon (template: `Free` only) | always | yes |
| `^numpad2` | Sub Weapon (template: `Free` only) | always | yes |
| `^numpad3` | Element: Fire, Ice, Wind, Earth, Lightning, Water, Light, Dark | always | yes |
| `^numpad4` | Nuke Tier: V, IV, III, II, I | always | yes |
| `^numpad5` | Magic Burst: Off, On | always | yes |
| `^numpad6` | Offense Mode: Normal, Acc | always | yes |
| `^numpad7` | Sneak/Invi AOE: On, Off | always | yes |
| `^numpad8` | Combat Mode: Off, On (weapon lock) | always | yes |
| `^numpad9` | Hybrid Mode: Normal, DT | always | yes |
| `#numpad1` | Light Arts, then Addendum: White on the next press | always | no (action) |
| `#numpad2` | Dark Arts, then Addendum: Black on the next press | always | no (action) |
| `#numpad3` | Nuke of the Element at Nuke Tier, on your target | always | no (action) |
| `#numpad4` | Helix of the Element, on your target | always | no (action) |
| `#numpad5` | Storm of the Element, on you | always | no (action) |
| `!numpad.` | Treasure Mode: Off, Tag, Full | after `//gs c th show` | no |
| `#numpad0` | Auto Medicine on / off (common key) | always | yes |
| `!numpad7` | Your other boxes follow you (common key) | always | yes |
| `!numpad8` | Other boxes' automation on / off (common key) | always | yes |
| `!numpad9` | Other boxes mirror you (common key) | always | yes |
| `!z` | Sneak on you and every other box (common key) | always | yes |
| `!x` | Invisible on you and every other box (common key) | always | yes |
| `f9` | Mote: cycle Offense Mode (same as `^numpad6`) | always | not on the HUD |
| `^f9` | Mote: cycle Hybrid Mode (same as `^numpad9`) | always | not on the HUD |
| `f10` / `f11` | Mote: physical / magical defense mode: `sets.defense.PDT` / `.MDT` over your idle and engaged gear, if you add them | always | not on the HUD |
| `!f10` | Mote: Kiting on / off: `sets.Kiting` over idle and engaged gear | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |

- The six common keys come from your `_common/keys/COMMON_KEYBINDS.lua`.
- Your own keys from `SCH_CUSTOM.lua` are added on top (the template file has
  only commented examples). `//gs c kc` lists every key conflict.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

**Scholar commands**

| Command | What it does |
|---|---|
| `lightarts` | Light Arts; if it is up, Addendum: White; if that is up too, says so |
| `darkarts` | Dark Arts; if it is up, Addendum: Black; if that is up too, says so |
| `nuke` | The Element's nuke at Nuke Tier on `<t>` (Fire V, Blizzard IV...; tier I = Fire). Light and Dark have none: a warning |
| `helix` | The Element's helix II on `<t>` (Pyrohelix II...), tier I when you do not have II |
| `storm` | The Element's storm II on `<me>` (Firestorm II...), tier I when you do not have II |
| `aoe sneak` / `aoe invi` | Light Arts + Accession + Sneak / Invisible on you (party); with Sneak/Invi AOE Off, no Accession, on `<stal>` |
| `aoe erase` | Light Arts + Addendum: White + Accession + Erase, each only when not already up |
| `strat` | Arts up, stratagem charges, time to the next one, stratagem effects up |
| `schhelp` | This list, in the chat |
| `buff` (`buffs`, `buffself`, `selfbuff`, `smartbuff`) | Every job: your main job's list, then your subjob's (not when the subjob is disabled), from `_common/combat/BUFF_CONFIG.lua`. Your list (`job.SCH`) by default: Protect V, Shell V, Regen V, Stoneskin, Blink, Aquaveil, with Protect IV, Shell IV and Regen IV behind (Protect V level 80, Shell V 90, Regen V 99). Of the tiers of one buff, the first one learned, in reach and off recast goes and the others are left out; a buff already up, even one cast by someone else, counts as up and gets no higher tier over it. Subjob lists (`subjob`) by default: /WAR Berserk, Aggressor, Warcry; /SAM Hasso (two-handed weapon only), Third Eye; /NIN Utsusemi: Ni, else Ichi; /DNC Haste Samba (350 TP); /WHM Reraise. Buffs already up or on recast are listed in chat, what your jobs cannot use is skipped quietly; the rest goes one action after the other. No list for your jobs: a warning naming the file ([configuration](../../guides/configuration.md)) |

**Commands of every job**: the same as on the other jobs (`ui`, `cyclestate`,
`checksets`, `wa`, `wo`, `rf`, `reload`, `ls`, `warp`, `waltz`, `th`,
`combatmode`, `belt`, `debugmidcast`, `trace on|off`...): see the
[commands guide](../../guides/commands.md).

## Shared features on this job

| Feature | Effect on SCH |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left; tiered spells drop a tier instead; stratagems are checked against their charges |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `SCH_TP_CONFIG.lua` ([TP bonus](../war/tp-bonus.md)) |
| Elemental belt | Hachirin-no-Obi or Orpheus's Sash on nukes and helices by itself (`//gs c belt`) |
| Combat Mode | `^numpad8`: keeps main, sub and range where they are |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Movement speed | `sets.MoveSpeed` while you move, idle, outside a city |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities |
| Doom | `sets.buff.Doom` while doomed |
| Your own modes | `SCH_CUSTOM.lua`: modes with a key and gear rules, without code |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 2 s later; every mode goes back to its default |
| Keybind HUD, dual-box, chat messages | As on every job |

## Configuration files for this job

In `<YourName>/sch/`, each file in its theme folder (`display/` for HUD,
lockstyle and macro book, `keys/` for states, keys and CUSTOM, `inventory/`
for refill, `combat/` for the rest):

| File | What it sets |
|---|---|
| `SCH_STATES.lua` | Every mode: values and defaults (add your weapons here) |
| `SCH_KEYBINDS.lua` | The job keys above |
| `SCH_TP_CONFIG.lua` | TP bonus pieces for your weaponskills (Moonshade Earring +250) |
| `SCH_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `SCH_LOCKSTYLE.lua` | Lockstyle number (`default = 1`) |
| `SCH_MACROBOOK.lua` | Macro book and page (book 1, page 1), per subjob and per alt job |
| `SCH_HUD.lua` | Order of this job's HUD sections and rows |

Sets: `<YourName>/sch/sets/sch_sets.lua`, see [sets.md](sets.md).

## Not done by the job

No automatic Arts before a spell, no Klimaform + storm chain, no Tabula Rasa
or Enlightenment helper. The stratagem charge count is an estimate read from
the time the whole pool takes to come back, 240 s by default: with the 550 JP
gift (faster recharge) it reads high unless you set `stratagem_full_recharge`
in `_common/combat/TUNING.lua` to your value.
