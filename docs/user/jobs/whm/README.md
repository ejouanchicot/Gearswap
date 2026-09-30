# WHM — White Mage

The page to open first when you play White Mage. It lists every key, every
command and every automatic feature you get on WHM with the provided template.

- What each mode and value does: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

No maintained character plays WHM today: the job is the template only, so it
has not been checked in game in its current form.

## Overview

White Mage is set up as a healer. Besides choosing your idle and casting gear,
the job does these things by itself:

- **Cure tier by missing HP** (Cure Auto-Tier On). A Cure or Curaga is replaced
  by the tier that fits the target's missing HP, from the thresholds in
  `WHM_CURE_CONFIG.lua`. A target at full HP gets the lowest tier.
- **Cure tier on recast** (always, even with Cure Auto-Tier Off). A tier on
  recast is replaced by the next ready lower tier, then a higher one.
- **Cure gear by mode.** Cure Mode Potency or SIRD (spell interruption down)
  picks the Cure / Curaga set; engaged cures use `sets.midcast.CureMelee` when
  you fill it; under Afflatus Solace a Cure uses `sets.midcast.CureSolace` and
  the Afflatus Solace set goes on top of cures and Bar-spells.
- **Status removal** (Paralyna, Cursna, Erase...) uses its own sets, with the
  Divine Caress set on top while that buff is up. Paralyna on yourself while
  paralysed swaps no gear.
- **Enfeebles by stat**: White Magic enfeebles wear `sets.midcast.MndEnfeebles`,
  Black Magic ones `sets.midcast.IntEnfeebles`.
- **Two weapon locks**: Combat Mode (main, sub, range, ammo) and Offense Mode
  `Melee ON` (main, sub, range). Turning one off does not free the slots the
  other still holds.
- **Latent refresh**: `sets.latent_refresh` on your idle set while your MP is
  under 51 % (`refresh_mp_below` in `_common/combat/TUNING.lua`).

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Idle Mode: PDT, Refresh | always | yes |
| `^numpad2` | Combat Mode: Off, On (weapon and ammo lock) | always | yes |
| `^numpad3` | Cure Mode: Potency, SIRD | always | yes |
| `^numpad4` | Cure Auto-Tier: On, Off | always | yes |
| `^numpad5` | Afflatus Mode for `//gs c afflatus`: Solace, Misery | always | yes |
| `^numpad6` | Casting Mode: Normal, Resistant | always | yes |
| `!numpad.` | Treasure Mode: Off, Tag, Full | after `//gs c th show` | no |
| `#numpad0` | Auto Medicine on / off (common key) | always | yes |
| `!numpad7` | Your other boxes follow you (common key) | always | yes |
| `!numpad8` | Other boxes' automation on / off (common key) | always | yes |
| `!numpad9` | Other boxes mirror you (common key) | always | yes |
| `!z` | Sneak on you and every other box (common key) | always | yes |
| `!x` | Invisible on you and every other box (common key) | always | yes |
| `f9` | Mote: cycle Offense Mode (None, Melee ON). `Melee ON` locks main, sub and range | always | not on the HUD |
| `^f9` | Mote: cycle Hybrid Mode. Only `Normal` on WHM: no effect | always | not on the HUD |
| `!f9` / `@f9` | Mote: Ranged Mode / Weaponskill Mode. Only `Normal` on WHM: no effect | always | not on the HUD |
| `f10` / `f11` | Mote: physical / magical defense mode: `sets.defense.PDT` / `.MDT` over your idle and engaged gear, if you add them (none in the template; in a city the Town set goes on top and wins in every slot it names) | always | not on the HUD |
| `^f10` / `!f12` | Mote: physical defense choice / defense mode off | always | not on the HUD |
| `!f10` | Mote: Kiting on / off: `sets.Kiting` (in the template) over idle and engaged gear | always | not on the HUD |
| `^f11` | Mote: cycle Casting Mode (same as `^numpad6`) | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |
| `^f12` | Mote: cycle Idle Mode (same as `^numpad1`) | always | not on the HUD |
| `^-` / `^=` | Mote: NPC target selection on / off, party target mode | always | not on the HUD |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | once you make one | listed by `tb list` |

- The six common keys come from your `_common/keys/COMMON_KEYBINDS.lua`; the rows
  above are the template's. The Alt+Numpad7-9 keys matter only when you
  dual-box.
- Combat Mode is native on WHM: its key is `^numpad2`. Treasure Mode is hidden
  until `//gs c th show`, and needs `sets.TreasureHunter` in your set file (the
  template has none).
- Offense Mode has no numpad key: F9 (Mote) or `//gs c cycle OffenseMode`.
- Your own keys from `WHM_CUSTOM.lua` are added on top (the template file has
  only commented examples). Pick a key the table above does not use.
- `//gs c kc` lists every key conflict this job can meet.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

**White Mage commands**

| Command | What it does |
|---|---|
| `afflatus` | Uses Afflatus Solace or Afflatus Misery on yourself, following Afflatus Mode |

There is no cure command: cast Cure / Curaga as usual (macro or menu) and the
tier is chosen at the moment you cast. Cure Auto-Tier (`^numpad4`) turns the HP
part off; `//gs c set CureAutoTier Off` does the same from a macro.

**Commands of every job** (details in the [commands guide](../../guides/commands.md))

| Command | What it does |
|---|---|
| `ui` (+ `on`, `off`, `save`, `font`, `theme`, `order`, `roworder`, `help`...) | Keybind HUD: show / hide / save / style ([HUD](../../features/ui.md)) |
| `cyclestate <Mode> [reverse]` | Next (previous) value of a mode, what the keys send |
| `cycle`, `cycleback`, `set <Mode> <Value>`, `toggle`, `reset`, `update` | Mote-Include's own mode commands |
| `am` (`automedicine`) `[on\|off]` | Auto Medicine: Echo Drops / Remedy when a debuff blocks your action |
| `combatmode [show\|hide\|key <key>\|help]` | Combat Mode status and settings for this job |
| `th [show\|hide\|key <key>\|clear\|help]` | Treasure Mode status and settings for this job |
| `checksets` | Set items missing from your inventory and wardrobes |
| `wa` (`wardrobeaudit`) | Wardrobe items no set file uses |
| `wo` (`worganize`) `[preview\|scan\|keep\|alt\|recover...]` | Wardrobe organizer |
| `rf` (`refill`) | Restock consumables: the common list, plus or instead of `WHM_REFILL.lua` |
| `naked` (or `equip naked`) | Remove every piece |
| `reload` | Reload the job file |
| `ls` (`lockstyle`) | Apply the lockstyle again |
| `dressup` | Stop / resume unloading DressUp around the lockstyle |
| `craft [variant\|off]`, `fish`, `uncraft` | Crafting / fishing sets |
| `dw [auto\|none\|haste\|haste2\|max]` | Dual Wield tier status or forced tier (needs `sets.DW`, none in the template) |
| `belt` | Obi / Orpheus status for today |
| `warp`, `w2`, `ret`, `esc`, `tph`... `<cmd>all`, `warp fix` | Warp spells, rings and destination items |
| `mount` | Random mount, or dismount |
| `stealth sneak\|invi\|both [self]`, `stealth status\|check...` | Sneak / Invisible on you and your other boxes |
| `waltz` / `aoewaltz` | Curing / Divine Waltz (/DNC) |
| `lightarts`, `darkarts`, `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: Light / Dark Arts then the Addendum on the next press; Sneak / Invisible / Erase on the party with Accession |
| `smartbuff` | /WAR: Berserk, Aggressor, Warcry. /SAM: Hasso (two-handed weapon only) and Third Eye. /NIN: Utsusemi: Ni, else Ichi. /DNC: Haste Samba (350 TP). Only what is ready and not already up, 2 s apart; the rest is listed in chat. Other subjobs: a warning |
| `!numpad-` | Jump Auto on / off, shown on /DRG only (see [commands](../../guides/commands.md#combat-helpers)) |
| `jump` | /DRG jumps |
| `watchdog [on\|off\|stats\|...]` | Midcast watchdog ([watchdog](../../features/watchdog.md)) |
| `debugmidcast` | Print which midcast set each spell uses (again to stop) |
| `alts ...`, `main`, `altcmds`, `alt <name>`, `altsync`, `altbuffs` | Dual-box group ([dual-box guide](../../guides/dualbox.md)) |
| `tb <key> <action>`, `tb list`, `tb del <key>`, `tb clear` | Temporary keys |
| `kc` (`keyconflicts`) | Every key conflict this job can meet |
| `info <name>` | Details of an ability, spell or weaponskill |
| `jamsg` / `spellmsg` / `wsmsg [full\|on\|off]` | How much chat abilities / spells / weaponskills print |
| `help`, `commands` | Built-in help and command list |
| `syscheck`, `fulltest`, `trace on\|off`, `debugsubjob`, `debugstate`, `testcolors` | Diagnostics |
| `sortie ...` | Sortie orders, only on a character with a `SORTIE_CONFIG.lua` (Tetsouo's is the example) |

## Shared features on this job

Checked in the code for WHM:

| Feature | Effect on WHM |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, paralysis, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left (a Cure first gets a chance to change tier). Optional party message per action in `_common/combat/RECAST_CONFIG.lua` |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `WHM_TP_CONFIG.lua` ([TP bonus](../war/tp-bonus.md)) |
| Obi / Orpheus | Hachirin-no-Obi or Orpheus's Sash on Banish, Holy, nukes and elemental weaponskills (Flash Nova...) when they add at least 5 % (`_common/combat/ELEMENTAL_BELT.lua`, `//gs c belt`) |
| Combat Mode | Native on WHM (`^numpad2`): On puts on `sets.CombatMode` if you define one, then locks main, sub, range and ammo |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Movement speed | `sets.MoveSpeed` while you move, idle, in town too |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities if you add it |
| Doom | `sets.buff.Doom` while doomed |
| Midcast watchdog | Puts your idle or engaged gear back when the game never confirms the end of a cast; the Fast Cast mode (80 by default) is its fallback estimate |
| Your own modes | `WHM_CUSTOM.lua`: modes with a key and gear rules, without code |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 0.5 s later; every mode goes back to its default |
| Keybind HUD, key guard | The HUD shows every mode; the keys are sent again 2 s after each load |
| Dual-box | Job exchange with your other boxes, alt commands, macro book per alt job |
| Chat messages | Ability / spell / weaponskill messages (`jamsg`, `spellmsg`, `wsmsg`), plus a line for each cure tier change |
| Dual Wield tiers | Only with `sets.DW` in your set file (none in the template) |
| HP priority | Gear swap order by HP, every character; settings in `_common/combat/HP_PRIORITY.lua` ([configuration](../../guides/configuration.md)) |

## Configuration files for this job

In `<YourName>/whm/`:

| File | What it sets |
|---|---|
| `WHM_STATES.lua` | Every mode: values and defaults |
| `WHM_KEYBINDS.lua` | The job keys above |
| `WHM_CURE_CONFIG.lua` | Cure and Curaga tier thresholds (missing HP ranges), `safety_margin` (50 HP added before choosing), `debug_messages` |
| `WHM_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `WHM_LOCKSTYLE.lua` | Lockstyle number: `default = 3` is the one used; the per-subjob list is not read |
| `WHM_MACROBOOK.lua` | Macro book and page per subjob (book 11, pages 1-5 by subjob in the template), and per alt job |
| `WHM_TP_CONFIG.lua` | TP bonus pieces for weaponskills (Moonshade Earring +250) |
| `WHM_HUD.lua` | Order of this job's HUD sections and rows |
| `WHM_REFILL.lua` | Consumables for `//gs c rf` on WHM, added to the common list or replacing it; every line commented at first ([configuration](../../guides/configuration.md#refill-job_refilllua)) |

In `WHM_CURE_CONFIG.lua`, `auto_tier_enabled` and `message_color` are not
read: the auto-tier switch is the Cure Auto-Tier mode.

In `<YourName>/_common/`, the files every job reads that matter here:
`COMMON_KEYBINDS.lua` (common keys), `combat_mode.lua` / `treasure_mode.lua`
(written by `combatmode` / `th`), `RECAST_CONFIG.lua`, `ELEMENTAL_BELT.lua`,
`LOCKSTYLE_CONFIG.lua`. See [configuration](../../guides/configuration.md).

Sets: `<YourName>/whm/whm_sets.lua`, see [sets.md](sets.md).

## Next

- [states.md](states.md): what every mode value does, cure tier details.
- [sets.md](sets.md): the set names to fill in, and what is worn by itself.
