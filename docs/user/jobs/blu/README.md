# BLU — Blue Mage

The page to open first when you play Blue Mage. It lists every key, every
command and every automatic feature you get on BLU with the provided template.

- What each mode and value does, and how Blue Magic picks its gear: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

## Overview

Blue Mage is set up as a melee with Blue Magic. The template's sets are empty:
you fill them in. The job does these things by itself:

- **Blue Magic by category.** Each spell wears the set of what it scales with
  (`PhysicalDex`, `Magical`, `MagicAccuracy`, `Healing`, `Buff`...), from your
  `BLU_SPELL_MAP.lua`; a set named after the spell wins.
- **Blue Magic overlays.** `sets.buff[...]` for Chain Affinity, Burst Affinity,
  Convergence, Diffusion and Efflux while the buff is up, and
  `sets.self_healing` for a Healing spell on yourself.
- **Single wield.** With nothing, a shield or a grip in your off hand, the
  engaged set is `sets.engaged.SW` (then `.SW.<Offense Mode>`).
- **Weapons from modes** (Main Weapon, Sub Weapon). The template has only
  `Free`: add your weapons in `BLU_STATES.lua`.
- **AzureSets.** The AzureSets addon (`//aset`) is loaded while you are BLU
  (`AzureSets = false` in `_common/tools/ADDONS_CONFIG.lua`: left alone).
- **Two automatic abilities, off by default**: Unbridled Learning before a
  spell that needs it, and an Expiacion hold for Tizona's Aftermath: Lv.3.

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Main Weapon (template: `Free` only) | always | yes |
| `^numpad2` | Sub Weapon (template: `Free` only) | always | yes |
| `^numpad3` | Offense Mode: Normal, Acc, DT, Subtle Blow, Refresh | always | yes |
| `^numpad4` | Idle Mode: Normal, Evasion, DT, Regain | always | yes |
| `^numpad5` | Casting Mode: Normal, Resistant | always | yes |
| `^numpad6` | Weaponskill Mode: Normal, Acc | always | yes |
| `numpad3` (example) | Savage Blade with a sword, Black Halo with a club: two commented examples in `BLU_KEYBINDS.lua` | once you remove the `--`, and only with that weapon type in hand | when active |
| `!numpad0` | Combat Mode: Off, On (weapon lock) | after `//gs c combatmode show` | no |
| `!numpad.` | Treasure Mode: Off, Tag, Full | after `//gs c th show` | no |
| `#numpad0` | Auto Medicine on / off (common key) | always | yes |
| `!numpad7` | Your other boxes follow you (common key) | always | yes |
| `!numpad8` | Other boxes' automation on / off (common key) | always | yes |
| `!numpad9` | Other boxes mirror you (common key) | always | yes |
| `!z` | Sneak on you and every other box (common key) | always | yes |
| `!x` | Invisible on you and every other box (common key) | always | yes |
| `f9` | Mote: cycle Offense Mode (same as `^numpad3`) | always | not on the HUD |
| `^f9` | Mote: cycle Hybrid Mode. Only `Normal` on BLU: no effect | always | not on the HUD |
| `!f9` | Mote: cycle Ranged Mode. Only `Normal` on BLU: no effect | always | not on the HUD |
| `@f9` | Mote: cycle Weaponskill Mode (same as `^numpad6`) | always | not on the HUD |
| `f10` / `f11` | Mote: physical / magical defense mode: `sets.defense.PDT` / `.MDT` over your idle and engaged gear, if you add them (none in the template) | always | not on the HUD |
| `^f10` / `!f12` | Mote: physical defense choice / defense mode off | always | not on the HUD |
| `!f10` | Mote: Kiting on / off: `sets.Kiting` over idle and engaged gear (empty in the template) | always | not on the HUD |
| `^f11` | Mote: cycle Casting Mode (same as `^numpad5`) | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |
| `^f12` | Mote: cycle Idle Mode (same as `^numpad4`) | always | not on the HUD |
| `^-` / `^=` | Mote: NPC target selection on / off, party target mode | always | not on the HUD |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | once you make one | listed by `tb list` |

- The six common keys come from your `_common/keys/COMMON_KEYBINDS.lua`; the rows
  above are the template's. The Alt+Numpad7-9 keys matter only when you
  dual-box.
- A key with `weapon = "Sword"` (or `"Club"`, `"Great Katana"`...) is bound
  only while your main hand is that weapon type, and the keys change by
  themselves when you switch weapon type. The two examples use the bare
  `numpad3`: pick another key if you want the plain numpad for the game.
- Your own keys from `BLU_CUSTOM.lua` are added on top (the template file has
  only commented examples). Pick a key the table above does not use.
- `//gs c kc` lists every key conflict this job can meet.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

**Blue Mage commands**: none. Blue Magic spell lists are handled by the
AzureSets addon, loaded with the job: `//aset setlist`, `//aset spellset <name>`
(AzureSets' own commands, not GearSwap's).

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
| `rf` (`refill`) | Restock consumables: the common list, plus or instead of `BLU_REFILL.lua` |
| `naked` (or `equip naked`) | Remove every piece |
| `reload` | Reload the job file |
| `ls` (`lockstyle`) | Apply the lockstyle again |
| `dressup` | Stop / resume unloading DressUp around the lockstyle |
| `craft [variant\|off]`, `fish`, `uncraft` | Crafting / fishing sets |
| `dw [auto\|none\|haste\|haste2\|max]` | Dual Wield tier status or forced tier (needs `sets.DW`) |
| `belt` | Obi / Orpheus status for today |
| `warp`, `w2`, `ret`, `esc`, `tph`... `<cmd>all`, `warp fix` | Warp spells, rings and destination items |
| `mount` | Random mount, or dismount |
| `stealth sneak\|invi\|both [self]`, `stealth status\|check...` | Sneak / Invisible on you and your other boxes |
| `waltz` / `aoewaltz` | Curing / Divine Waltz (/DNC) |
| `lightarts`, `darkarts`, `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: Light / Dark Arts then the Addendum on the next press; Sneak / Invisible / Erase on the party with Accession |
| `buff` (`buffs`, `buffself`, `selfbuff`, `smartbuff`) | Every job: your main job's list, then your subjob's (not when the subjob is disabled), from `_common/combat/BUFF_CONFIG.lua`. BLU has no list (`job.BLU`) by default: the game does not tell which blue spells are set; add one if you like, e.g. `BLU = {'Cocoon', 'Barrier Tusk'}`. Subjob lists (`subjob`) by default: /WAR Berserk, Aggressor, Warcry; /SAM Hasso (two-handed weapon only), Third Eye; /NIN Utsusemi: Ni, else Ichi; /DNC Haste Samba (350 TP); /WHM Reraise. Buffs already up or on recast are listed in chat, what your jobs cannot use is skipped quietly; the rest goes one action after the other. No list for your jobs: a warning naming the file ([configuration](../../guides/configuration.md)) |
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
| `syscheck`, `fulltest`, `trace on\|off`, `debugsubjob`, `debugstate`, `testcolors` | Diagnostics (`trace` also logs each Blue Magic category and each Unbridled / Expiacion decision) |
| `sortie ...` | Sortie orders, only on a character with a `SORTIE_CONFIG.lua` (Tetsouo's is the example) |

## Shared features on this job

Checked in the code for BLU:

| Feature | Effect on BLU |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, paralysis, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left (before Unbridled Learning is considered). Optional party message per action in `_common/combat/RECAST_CONFIG.lua` |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `BLU_TP_CONFIG.lua` ([TP bonus](../../features/tp-bonus.md)) |
| Automatic abilities | `auto_unbridled` and `expiacion_window` in `blu/combat/BLU_CONFIG.lua`, both off: see [states.md](states.md#automatic-abilities) |
| Obi / Orpheus | Hachirin-no-Obi or Orpheus's Sash on Magical Blue Magic, Sanguine Blade and the other elemental weaponskills when they add at least 5 % (`_common/gear/ELEMENTAL_BELT_CONFIG.lua`, `//gs c belt`) |
| Combat Mode | Hidden; `//gs c combatmode show`, then `!numpad0`: On locks main, sub and range |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Dual Wield tiers | With two weapons and engaged, `sets.DW.<tier>` on top by your magic haste. The template has it commented out |
| Movement speed | `sets.MoveSpeed` while you move, idle, outside a city |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities, if you add them |
| Doom | `sets.buff.Doom` while doomed |
| Midcast watchdog | Puts your idle or engaged gear back when the game never confirms the end of a cast; the Fast Cast mode (0 by default) is its fallback estimate |
| Your own modes | `BLU_CUSTOM.lua`: modes with a key and gear rules, without code |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 2 s later; every mode goes back to its default |
| Keybind HUD, key guard | The HUD shows every mode; the keys are sent again 2 s after each load |
| Dual-box | Job exchange with your other boxes, alt commands, macro book per alt job |
| Chat messages | Ability / spell / weaponskill messages, set with `jamsg`, `spellmsg`, `wsmsg` |
| Plain weapon names | With `equip_without_set = true` in `_common/gear/WEAPON_CONFIG.lua`, a weapon value that is a real weapon name needs no set |
| HP priority | Gear swap order by HP, every character; settings in `_common/gear/HP_PRIORITY_CONFIG.lua` ([configuration](../../guides/configuration.md)) |

## Configuration files for this job

In `<YourName>/blu/`, each file in its theme folder (`display/` for HUD,
lockstyle and macro book, `keys/` for states, keys and CUSTOM, `inventory/`
for refill, `combat/` for the rest):

| File | What it sets |
|---|---|
| `BLU_STATES.lua` | Every mode: values and defaults (add your weapons here) |
| `BLU_KEYBINDS.lua` | The job keys above, and the per-weapon examples |
| `BLU_SPELL_MAP.lua` | Blue Magic spell -> gear category (24 categories, every spell of the game). Read once per load: `//gs reload` after an edit |
| `BLU_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `BLU_LOCKSTYLE.lua` | Lockstyle number: `default = 1` is the one used; the per-subjob list is not read |
| `BLU_MACROBOOK.lua` | Macro book and page (book 1, page 1), per subjob and per alt job |
| `BLU_TP_CONFIG.lua` | TP bonus pieces for weaponskills (Moonshade Earring +250) |
| `BLU_HUD.lua` | Order of this job's HUD sections and rows |
| `BLU_CONFIG.lua` | The two automatic abilities, `auto_unbridled` and `expiacion_window`, both `false` ([states.md](states.md#automatic-abilities)) |
| `BLU_REFILL.lua` | Consumables for `//gs c rf` on BLU, added to the common list or replacing it; every line commented at first ([configuration](../../guides/configuration.md#refill-job_refilllua)) |

In `<YourName>/_common/`, the files every job reads that matter here:
`WEAPON_CONFIG.lua`, `COMMON_KEYBINDS.lua`, `RECAST_CONFIG.lua`,
`ELEMENTAL_BELT_CONFIG.lua`, `DW_CONFIG.lua`, `LOCKSTYLE_CONFIG.lua`; in
`<YourName>/saved/`, `combat_mode.lua` / `treasure_mode.lua` (written by
`combatmode` / `th`). See [configuration](../../guides/configuration.md).

Sets: `<YourName>/blu/sets/blu_sets.lua`, see [sets.md](sets.md).

## Next

- [states.md](states.md): what every mode value does, the Blue Magic set order,
  the automatic abilities.
- [sets.md](sets.md): the set names to fill in, and what is worn by itself.
