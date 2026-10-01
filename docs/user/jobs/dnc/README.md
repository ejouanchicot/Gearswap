# DNC — start here

The one page to open first when you play Dancer. It lists every key, every
command and every automatic feature active on DNC, and where each setting
lives. Details are on the linked pages:

- [states.md](states.md): what each mode value does
- [sets.md](sets.md): the set names the code looks for, and the gear put on for you

## Overview

Dancer with the provided template gives you:

- **Weapons on keys**: a main weapon set (main + off hand) and an optional
  off-hand override (Blurred Knife +1).
- **Weaponskill helpers**: before a listed weaponskill, Climactic Flourish is
  used first when you have 3+ Finishing Moves; on /DRG a Jump is used first
  when your TP is short. The weaponskill follows by itself.
- **Weaponskill gear by buff**: `.SaberDance`, `.FanDance`, `.Clim` versions of
  your weaponskill sets (and their combinations) under Saber Dance, Fan Dance
  or Climactic Flourish, with the Moonshade Earring added after.
- **Engaged gear by dance**: Saber Dance and Fan Dance have their own engaged
  sets, changed as soon as the dance starts or ends.
- **One-key chains**: `step` (Presto first, main / alternate step),
  `smartbuff` (dance, samba, subjob buffs), `dance`.
- **Waltzes**: `//gs c waltz` picks the Curing Waltz tier from the missing HP
  of your target (tier bands: `waltz_from` in `_common/combat/TUNING.lua`); `aoewaltz` uses Divine Waltz.

Every mode goes back to its default on each job change, subjob change and
reload.

## All keys on this job

Ctrl = `^`, Alt = `!`, Apps (menu key) = `#`, Win = `@`. The keys come from
the provided template; after cloning, yours are in `<YourName>/dnc/`
and `<YourName>/_common/keys/COMMON_KEYBINDS.lua`, and those files win. No DNC key
depends on the subjob (Jump Auto only acts on /DRG).

| Key | Does | When | Shown in the HUD |
|---|---|---|---|
| `^numpad1` | Cycle Main Weapon: Twashtar, Mpu Gandring, Demersal | always | yes |
| `^numpad2` | Cycle Sub Override: Off, Blurred | always | yes |
| `^numpad3` | Cycle Main Step: Box Step, Quickstep, Feather Step | always | yes |
| `^numpad4` | Cycle Alt Step: Quickstep, Box Step, Feather Step | always | yes |
| `^numpad5` | Use Alt Step On / Off | always | yes |
| `^numpad6` | Climactic Auto On / Off | always | yes |
| `^numpad7` | Jump Auto On / Off, default Off | /DRG only | /DRG only |
| `^numpad8` | Cycle Dance: Saber Dance, Fan Dance | always | yes |
| `^numpad0` | Cycle Samba: Haste Samba, Drain Samba II, Aspir Samba, Off | always | yes |
| `^numpad9` | Cycle Hybrid Mode: PDT, Normal | always | yes |
| `#numpad0` | Auto Medicine on / off | always (common key) | yes |
| `!numpad7` | Alts follow this character (press again to stop) | always (common key) | yes |
| `!numpad8` | Alts' automation on / off | always (common key) | yes |
| `!numpad9` | Alts mirror | always (common key) | yes |
| `!z` | Sneak on you and every alt | always (common key) | yes |
| `!x` | Invisible on you and every alt | always (common key) | yes |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **not bound by default**: only after `//gs c combatmode show` | only when shown |
| `!numpad.` | Cycle Treasure Mode: Off, Tag, Full | **not bound by default**: only after `//gs c th show` | only when shown |
| `^f1`-`^f8`, `!f1`-`!f8` | Your temporary keys | only the ones you create with `//gs c tb` | no |

Mote-Include (the library under every job) also binds these keys on every
job load. They are not in the HUD. On DNC:

| Key | Mote command | Effect on DNC |
|---|---|---|
| `^f9` | cycle Hybrid Mode | Same as `^numpad9` |
| `f9`, `!f9`, `@f9`, `^f11`, `^f12` | cycle Offense / Ranged / Weaponskill / Casting / Idle Mode | Nothing: DNC gives these modes a single value |
| `f10`, `f11`, `^f10`, `!f12` | Defense Mode Physical / Magical / cycle / reset | Nothing with the provided template (no `sets.defense`); a `sets.defense` you add reaches idle gear outside town only, never engaged gear, and not outside town in a Hybrid Mode that has its own `sets.idle.<mode>` (PDT in the provided file) |
| `!f10` | Kiting on / off | Nothing unless you add `sets.Kiting` (idle outside town only, and not in a Hybrid Mode that has its own `sets.idle.<mode>`) |
| `f12` | `update user` | Puts your gear back for your current status and prints the current modes |
| `^-`, `^=` | Mote target helpers | Mote's own target switching |

Key conflicts for this job, on every subjob: `//gs c keyconflicts`.

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro). Full list
and arguments: [commands guide](../../guides/commands.md).

**DNC commands**

| Command | What it does |
|---|---|
| `step` | The step on `<t>`: Main Step, or Main and Alt Step in turn when Use Alt Step is On. Presto first when it is ready, not up and you are level 77+. Only a message when steps are on recast |
| `smartbuff` (`buffself`) | The selected dance (unless already up), the selected samba (never with Fan Dance, only when your TP covers it or Trance is up, and its buff is not up), then subjob buffs, by default /WAR Berserk, Aggressor, Warcry; /NIN Utsusemi: Ni, else Ichi; /SAM Hasso (two-handed weapon only) and Third Eye (the lists: `subjob` in `_common/combat/SMARTBUFF_CONFIG.lua` ([configuration](../../guides/configuration.md))). 2 s apart; what is up or on recast is listed |
| `dance` (`fandance`) | The selected dance, even if it is already up |
| `waltz` | Curing Waltz on `<stpc>`: tier from the missing HP of your current target (you, or a party member), else the highest you can use. Cancels Saber Dance first. Common command |
| `aoewaltz` | Divine Waltz II, else Divine Waltz. Common command |
| `jump` | /DRG: Jump / High Jump. Common command |

`fandance` runs on this character even when your dual-box partner is a DNC;
`//gs c alt fandance` sends the partner's.

**Common commands that work on DNC**

| Command | What it does |
|---|---|
| `cyclestate <Mode>` / `cycle` / `set` / `toggle` / `reset` | Change a mode (what the keys send) |
| `ui ...` | Keybind HUD: show / hide, save position, font, theme, order |
| `am [on/off]` | Auto Medicine |
| `checksets`, `wa`, `wo`, `rf`, `naked`, `reload` | Gear check, wardrobe audit / organizer, refill, unequip all, reload |
| `ls`, `dressup` | Lockstyle again, DressUp handling |
| `craft`, `fish`, `uncraft` | Crafting / fishing sets (write your own set file) |
| `warp`, `w2`, `tph`... , `<command>all`, `mount` | Travel |
| `watchdog ...`, `debugmidcast` | Midcast watchdog, midcast debug |
| `stealth sneak` / `invi` / `both` ... | Sneak / Invisible on you and your alts |
| `alts ...`, `main`, `altcmds`, `alt <name>` | Dual-box group |
| `combatmode [show / hide / key]` | Combat Mode (weapon lock) on this job |
| `th [show / hide / key / clear]` | Treasure Mode on this job |
| `dw [auto / none / haste / haste2 / max]` | Dual Wield tier |
| `belt` | Obi / Orpheus status |
| `tb ...` | Temporary keys |
| `keyconflicts` (`kc`) | Every key conflict on this job |
| `info <name>`, `jamsg`, `spellmsg`, `wsmsg` | Ability / spell / weaponskill details and chat messages |
| `commands`, `help`, `testcolors` | Built-in command list, help, chat colours |
| `syscheck`, `fulltest`, `trace`, `debugsubjob`, ... | Diagnostics |

## Shared features on this job

| Feature | On DNC |
|---|---|
| Weaponskill check | A weaponskill out of range or under 1000 TP is cancelled with a message (not when Jump took it over to build the TP); a weaponskill out of range uses neither Jump nor Climactic Flourish; TP bonus gear (Moonshade...) from `DNC_TP_CONFIG.lua` is added after the dance / Climactic version, counting Aeneas / Centovente in either hand |
| Automatic abilities | Climactic Flourish before the weaponskills of `DNC_WS_CONFIG.lua` (Climactic Auto: 1000 TP or more, target above 25 % HP, 3+ Finishing Moves, tried once per weaponskill); Presto before `step` |
| Auto Jump (/DRG) | Below 1000 TP, a weaponskill is replaced by Jump (then High Jump if still short) and sent again (Jump Auto) |
| Recast check | An ability or spell still on recast is cancelled with the time left (Utsusemi is left to the game). A samba you cannot pay for (TP below its cost, not under Trance) is cancelled with a message |
| Debuff guard | An action you cannot do (silenced, amnesia, ...) is stopped; with Auto Medicine on, Echo Drops / Remedy are used |
| Waltzes and dances | Manual waltz macros are never re-tiered nor blocked on full HP (so a waltz can wake a sleeping party member). A manual waltz under Saber Dance or a manual samba under Fan Dance is **not** cancelled for you: the game refuses it; `//gs c waltz` cancels Saber Dance itself |
| Doom | `sets.buff.Doom` goes on and its neck, rings and waist stay locked while Doomed |
| Movement speed | `sets.MoveSpeed` on idle while you move outside town; `sets.Adoulin` in Adoulin, `sets.idle.Town` in other towns |
| Obi / Orpheus | Added to elemental weaponskills (Aeolian Edge...) when the day, weather or distance gives enough (`//gs c belt`) |
| Dual Wield tiers | Only if you define `sets.DW` (a commented example is in the template) |
| Treasure Mode | Off and hidden. `//gs c th show` to use it: the template already has `sets.TreasureHunter` |
| Combat Mode | Off and hidden. When shown and On: main, sub and range stay locked |
| Weapon without a set | With `equip_without_set = true` in `_common/combat/WEAPON_CONFIG.lua`, a Main Weapon value with no set equips that weapon by name |
| Your own modes | `DNC_CUSTOM.lua`: extra modes, keys and gear rules without code |
| Utsusemi (/NIN) | Utsusemi: Ichi removes your old shadows 2.3 s into the cast so the new ones take (shared with every job; needs Windower's Cancel addon) |
| Midcast watchdog | Puts your gear back if a cast result never arrives (`FastCast` mode, no key) |
| Lockstyle, macro book | Set on load and on each subjob change |
| Dual-box | Job exchange with your alt, `alts` orders, macro book per alt job (GEO, COR or RDM in the template) |
| Messages | Ability, spell and weaponskill lines in chat (`jamsg` / `spellmsg` / `wsmsg`) |

## Configuration files for this job

In `<YourName>/dnc/`:

| File | Content |
|---|---|
| `DNC_STATES.lua` | Modes, their values and defaults |
| `DNC_KEYBINDS.lua` | The job keys above |
| `DNC_CUSTOM.lua` | Your own modes, keys and gear rules ([keybinds guide](../../guides/keybinds.md)) |
| `DNC_WS_CONFIG.lua` | Climactic Flourish: which weaponskills (Rudra's Storm, Ruthless Stroke, Shark Bite), minimum TP (1000; a lower value counts as 1000), minimum target HP (25 %) |
| `DNC_HUD.lua` | HUD section and row order for DNC (written by `//gs c ui order` / `roworder`) |
| `DNC_LOCKSTYLE.lua` | Lockstyle number, per subjob if you want (template: 2 everywhere) |
| `DNC_MACROBOOK.lua` | Macro book / page per subjob and per dual-box alt job (template: book 4, /WAR book 5) |
| `DNC_TP_CONFIG.lua` | TP bonus pieces and weapons ([TP bonus](../war/tp-bonus.md)) |
| `DNC_REFILL.lua` | What `//gs c rf` restocks on DNC on top of or in place of the common list (every line commented at first: the common list) ([configuration](../../guides/configuration.md#refill-job_refilllua)) |

In `<YourName>/_common/`, shared with the other jobs: `COMMON_KEYBINDS.lua`,
`WEAPON_CONFIG.lua`, `DW_CONFIG.lua`, `ELEMENTAL_BELT.lua`,
`RECAST_CONFIG.lua`, `STEALTH_CONFIG.lua`, and `treasure_mode.lua` /
`combat_mode.lua` (written by `//gs c th` / `combatmode`). Gear:
`<YourName>/dnc/dnc_sets.lua`. See [configuration](../../guides/configuration.md).

## More

- [states.md](states.md): each mode in detail
- [sets.md](sets.md): set names and automatic gear
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md)
