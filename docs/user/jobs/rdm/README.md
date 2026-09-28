# RDM — Red Mage

The page to open first when you play Red Mage. It lists every key, every
command and every automatic feature you get on RDM with the provided template.

- What each mode and value does: [states.md](states.md)
- Every set name the code reads, and the gear put on by itself: [sets.md](sets.md)
- Commands shared by every job, in detail: [commands guide](../../guides/commands.md)

## Overview

Red Mage is set up as a caster that can also melee. Besides choosing your idle,
engaged and casting gear, the job does these things by itself:

- **Tier step-down.** A tiered enfeeble (Dia III, Distract III, Gravity II,
  Slow II...) or nuke (Fire V, Thundara III, Aspir III...) that is on recast or
  short of MP is replaced by the best lower tier you can cast now. Enfeebles
  only while Enfeeble Tier is On; nukes always.
- **Phalanx by target.** Phalanx II on yourself becomes Phalanx; Phalanx on
  someone else becomes Phalanx II.
- **Automatic Saboteur** (Saboteur Mode On) before the enfeebles listed in
  `RDM_SABOTEUR_CONFIG.lua` (template: Distract III, Gravity II), then the
  spell goes out once Saboteur is up.
- **Midcast by spell family.** Each enfeeble wears the set of its type
  (MND potency, INT potency, magic accuracy...), each enhancing spell the set of
  its family (Enspell, Gain, Bar-element, Refresh, Regen...), with a Composure
  version on others. The Saboteur set goes on top while Saboteur is up. A Cure
  on yourself adds `sets.midcast.CureSelf` when you have it.
- **Weapons from modes**, with single-wield or dual-wield engaged sets chosen
  from what is in your off hand and your subjob (dual wield on /NIN or /DNC).
- **Cast commands** that read a mode (nuke element and tier, enspell, gain,
  bar-spell, spikes, storm) and a cast-by-name command for any action.

## All keys on this job

Keys: `^` = Ctrl, `!` = Alt, `#` = Apps (the menu key), `@` = Win. "Shown"
means the key is bound and its row is on the HUD (`//gs c ui`) when you load
the job.

| Key | What it does | When | Shown |
|---|---|---|---|
| `^numpad1` | Main Weapon: Naegling, Colada, Daybreak | always | yes |
| `^numpad2` | Sub Weapon: Ammurapi, Genmei, Malevolence | always | yes |
| `^numpad3` | Enfeeble Mode: Potency, Skill, Duration | always | yes |
| `^numpad4` | Idle Mode: Refresh, DT | always | yes |
| `^numpad5` | Combat Mode: Off, On (weapon lock) | always | yes |
| `^numpad6` | Engaged Mode: DT, Acc, TP, Enspell | always | yes |
| `^numpad7` | Nuke Mode: FreeNuke, Magic Burst | always | yes |
| `^numpad8` | Nuke Tier: V, IV, III, II, I | always | yes |
| `^numpad9` | Enfeeble Tier: On, Off (tier step-down of enfeebles) | always | yes |
| `^numpad0` | Saboteur Mode: Off, On | always | yes |
| `^numpad.` | Enspell for `castenspell`: Enfire ... Enwater | always | yes |
| `^numpad+` | Gain spell for `castgain`: Gain-STR ... Gain-CHR | always | yes |
| `^numpad-` | Bar-element spell for `castbar` | always | yes |
| `^numpad*` | Bar-ailment spell for `castbarailment` | always | yes |
| `^numpad/` | Spikes for `castspike`: Blaze, Ice, Shock | always | yes |
| `#numpad1` | Storm for `caststorm` | /SCH only | yes, on /SCH |
| `!numpad.` | Treasure Mode: Off, Tag, Full | after `//gs c th show` | no |
| `#numpad0` | Auto Medicine on / off (common key) | always | yes |
| `!numpad7` | Your other boxes follow you (common key) | always | yes |
| `!numpad8` | Other boxes' automation on / off (common key) | always | yes |
| `!numpad9` | Other boxes mirror you (common key) | always | yes |
| `!z` | Sneak on you and every other box (common key) | always | yes |
| `!x` | Invisible on you and every other box (common key) | always | yes |
| `f9` | Mote: cycle Offense Mode. Only `Normal` on RDM: no effect | always | not on the HUD |
| `^f9` | Mote: cycle Hybrid Mode (Normal, PDT). No gear effect on RDM | always | not on the HUD |
| `!f9` / `@f9` | Mote: Ranged Mode / Weaponskill Mode. Only `Normal` on RDM: no effect | always | not on the HUD |
| `f10` / `f11` / `^f10` / `!f12` | Mote: physical / magical defense mode, its choice, reset. RDM builds its idle and engaged sets itself, so these change nothing | always | not on the HUD |
| `!f10` | Mote: Kiting. Changes nothing on RDM (same reason) | always | not on the HUD |
| `^f11` | Mote: Casting Mode. Only `Normal` on RDM: no effect | always | not on the HUD |
| `f12` | Mote: put your current gear back on and print the modes | always | not on the HUD |
| `^f12` | Mote: cycle Idle Mode (same as `^numpad4`) | always | not on the HUD |
| `^-` / `^=` | Mote: NPC target selection on / off, party target mode | always | not on the HUD |
| `^f1`-`^f8`, `!f1`-`!f8` | Temporary keys you make with `//gs c tb` | once you make one | listed by `tb list` |

- The six common keys come from your `config/COMMON_KEYBINDS.lua`; the rows
  above are the template's. The Alt+Numpad7-9 keys matter only when you
  dual-box.
- Combat Mode is native on RDM: its key is `^numpad5` above. Treasure Mode is
  hidden until `//gs c th show`, and needs `sets.TreasureHunter` in your set
  file (the template has none).
- Your own keys from `RDM_CUSTOM.lua` are added on top (the template file has
  only commented examples). Pick a key the table above does not use.
- `//gs c kc` lists every key conflict this job can meet.

## All commands on this job

Type them as `//gs c <command>`, or `/console gs c <command>` in a macro.

**Red Mage commands**

| Command | What it does |
|---|---|
| `castlight` / `castsublight` | Casts the Main / Sub Light Spell (Fire, Aero, Thunder) at the Nuke Tier on `<t>` |
| `castdark` / `castsubdark` | Same with the Main / Sub Dark Spell (Blizzard, Stone, Water) |
| `castenspell` | Casts the Enspell mode's spell on yourself |
| `castgain` | Casts the Gain spell mode's spell on yourself |
| `castbar` | Casts the Bar-element mode's spell on yourself |
| `castbarailment` | Casts the Bar-ailment mode's spell on yourself |
| `castspike` | Casts the Spikes mode's spell on yourself |
| `caststorm` | Casts the Storm mode's spell on yourself (/SCH; otherwise a "requires SCH" message) |
| `cyclestorm` | Next Storm value, with a chat line (/SCH only) |
| `enspell <element>` | Casts that enspell: `fire`, `ice` / `blizzard`, `wind` / `aero`, `earth` / `stone`, `thunder`, `water` |
| `enspell` | Next Enspell value, silently |
| `convert` / `chainspell` / `saboteur` / `composure` | Uses that ability on yourself |
| `dispelga [<target>]` | Dispelga on `<t>` (or the target you give). Daybreak goes in the main hand for the cast, even with Combat Mode On, and your weapon comes back after it (the TP is lost). A typed `/ma "Dispelga"` works only with Combat Mode Off or Daybreak already in hand |
| `<Action Name> [<target>]` | Cast-by-name: any job ability, weaponskill or spell by its exact English name, e.g. `//gs c Refresh III <stpc>`. Default target `<me>`. A name the game does not know prints "Command not recognized" |

The cast-by-name command runs only when no other command has that first word:
`//gs c Warp` is the warp command, `//gs c Jump` the /DRG jump command.

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
| `rf` (`refill`) | Restock consumables from `RDM_REFILL.lua` (you create it) |
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
| `sortie ...` | The author's Sortie orders (written for his own pair of characters) |

## Shared features on this job

Checked in the code for RDM:

| Feature | Effect on RDM |
|---|---|
| Debuff guard + Auto Medicine | An action blocked by silence, paralysis, amnesia... is stopped; with Auto Medicine On an Echo Drops / Remedy is used |
| Recast check | An ability or spell on recast is cancelled with its time left. Tiered nukes, and tiered enfeebles while Enfeeble Tier is On, use the tier step-down instead. Optional party message per action in `config/RECAST_CONFIG.lua` |
| Weaponskill check | Out of range or under 1000 TP: cancelled with a message. TP bonus pieces from `RDM_TP_CONFIG.lua` are handled by the TP bonus calculation ([TP bonus](../war/tp-bonus.md)) |
| Obi / Orpheus | Hachirin-no-Obi or Orpheus's Sash on nukes and on Sanguine Blade / Seraph Blade when they add at least 5 % (`config/ELEMENTAL_BELT.lua`, `//gs c belt`) |
| Combat Mode | Native on RDM (`^numpad5`): On locks main, sub and range, so no set swaps your weapons |
| Dispelga with Daybreak | `//gs c dispelga`: Daybreak for the cast, your weapon back after, even through Combat Mode |
| Treasure Mode | Hidden; `//gs c th show` to use it, with a `sets.TreasureHunter` of yours |
| Dual Wield tiers | With two weapons (/NIN, /DNC) and engaged, `sets.DW.<tier>` on top by your magic haste. The template has it commented out |
| Movement speed | `sets.MoveSpeed` while you move, idle, outside a city |
| Town idle | `sets.idle.Town` in a city, `sets.Adoulin` in the Adoulin cities |
| Doom | `sets.buff.Doom` while doomed |
| Midcast watchdog | Puts your idle or engaged gear back when the game never confirms the end of a cast; the Fast Cast mode (80 by default) is its fallback estimate |
| Your own modes | `RDM_CUSTOM.lua`: modes with a key and gear rules, without code |
| Lockstyle and macro book | Set on load and on every subjob change |
| Job change handling | A subjob change reloads the job 0.5 s later; every mode goes back to its default |
| Keybind HUD, key guard | The HUD shows every mode; the keys are sent again 2 s after each load |
| Dual-box | Job exchange with your other boxes, alt commands, macro book per alt job |
| Chat messages | Ability / spell / weaponskill messages, set with `jamsg`, `spellmsg`, `wsmsg` |
| HP priority | Gear swap order by HP and MP: only for the characters the code lists, not for a new clone |

## Configuration files for this job

In `<YourName>/config/rdm/`:

| File | What it sets |
|---|---|
| `RDM_STATES.lua` | Every mode: values and defaults (add weapons here) |
| `RDM_KEYBINDS.lua` | The job keys above |
| `RDM_CUSTOM.lua` | Your own modes, keys and gear rules (commented examples only) |
| `RDM_SABOTEUR_CONFIG.lua` | Spells that get an automatic Saboteur (Distract III, Gravity II) and the wait (2 s) |
| `RDM_LOCKSTYLE.lua` | Lockstyle number: `default = 1` is the one used; the per-subjob list is not read |
| `RDM_MACROBOOK.lua` | Macro book and page per subjob (book 2, page 1 in the template), and per alt job |
| `RDM_TP_CONFIG.lua` | TP bonus pieces for weaponskills (Moonshade Earring +250) |
| `RDM_HUD.lua` | Order of this job's HUD sections and rows |
| `RDM_REFILL.lua` | Consumables for `//gs c rf` (not in the template: you create it) |

In `<YourName>/config/`, the files every job reads that matter here:
`COMMON_KEYBINDS.lua` (common keys), `combat_mode.lua` / `treasure_mode.lua`
(written by `combatmode` / `th`), `RECAST_CONFIG.lua`, `ELEMENTAL_BELT.lua`,
`DW_CONFIG.lua`, `WEAPON_CONFIG.lua` (`equip_without_set`: a weapon value
needs no set), `LOCKSTYLE_CONFIG.lua`. See [configuration](../../guides/configuration.md).

Sets: `<YourName>/sets/rdm_sets.lua`, see [sets.md](sets.md).

## Next

- [states.md](states.md): what every mode value does, and the modes with no key.
- [sets.md](sets.md): the set names to fill in, and what is worn by itself.
