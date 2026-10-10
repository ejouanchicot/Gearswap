# THF — start here

The one page to open first when you play Thief. It lists every key, every
command and every automatic feature active on THF, and where each setting
lives. Details are on the linked pages:

- [states.md](states.md): what each mode value does
- [sets.md](sets.md): the set names the code looks for, and the gear put on for you

## Overview

Thief with the provided template gives you:

- **Weapons on keys**: main and off hand chosen from the HUD, plus an Abyssea
  proc mode on /WAR that swaps in a pair of any weapon type.
- **Treasure Hunter built in**: Treasure Mode is on by default (`Tag`). Your
  `sets.TreasureHunter` goes on until one of your actions lands on the mob,
  then your normal gear comes back.
- **Sneak Attack / Trick Attack gear** kept on from the ability until the hit
  or weaponskill that uses it, and `.SA` / `.TA` / `.SATA` versions of your
  weaponskill sets.
- **Range lock**: every ranged attack locks the range and ammo slots;
  `//gs c range` equips your pull weapon and shoots.
- **One-key chains**: `buff` (job and subjob lists), `fbc` (Feint, Bully,
  Conspirator), `steal` (Steal, Mug, Despoil).

Every mode goes back to its default on each job change, subjob change and
reload.

## All keys on this job

Ctrl = `^`, Alt = `!`, Apps (menu key) = `#`, Win = `@`. The keys come from
the provided template; after cloning, yours are in `<YourName>/thf/`
and `<YourName>/_common/keys/COMMON_KEYBINDS.lua`, and those files win.

| Key | Does | When | Shown in the HUD |
|---|---|---|---|
| `^numpad1` | Cycle Main Weapon: Vajra, TwashtarM, Mpu Gandring, Tauret, Naegling, Malevolence, Dagger | always | yes |
| `^numpad2` | Cycle Sub Weapon: Centovente, Tanmogayi, Kraken | always | yes |
| `^numpad3` | Cycle Treasure Mode: Tag, SATA, Full (THF's own Treasure Mode key) | always, unless you hid it with `//gs c th hide` | yes |
| `^numpad4` | Aby Proc on / off (Mote `toggle`) | **/WAR only** | yes, on /WAR |
| `^numpad5` | Cycle Aby Weapon: Dagger2, Sword, Club, Great Sword, Polearm, Staff, Scythe | **/WAR only** | yes, on /WAR |
| `^numpad6` | Range Lock on / off (Mote `toggle`) | always | yes |
| `^numpad9` | Cycle Hybrid Mode: PDT, Normal | always | yes |
| `#numpad0` | Auto Medicine on / off | always (common key) | yes |
| `!numpad7` | Alts follow this character (press again to stop) | always (common key) | yes |
| `!numpad8` | Alts' automation on / off | always (common key) | yes |
| `!numpad9` | Alts mirror | always (common key) | yes |
| `!z` | Sneak on you and every alt | always (common key) | yes |
| `!x` | Invisible on you and every alt | always (common key) | yes |
| `!numpad0` | Cycle Combat Mode (weapon lock) | **not bound by default**: only after `//gs c combatmode show` | only when shown |
| `^f1`-`^f8`, `!f1`-`!f8` | Your temporary keys | only the ones you create with `//gs c tb` | no |

Mote-Include (the library under every job) also binds these keys on every
job load. They are not in the HUD. On THF:

| Key | Mote command | Effect on THF |
|---|---|---|
| `^f9` | cycle Hybrid Mode | Same as `^numpad9` |
| `f9`, `@f9`, `!f9`, `^f11`, `^f12` | cycle Offense / Weaponskill / Ranged / Casting / Idle Mode | Nothing: THF gives these modes a single value |
| `f10`, `f11`, `^f10`, `!f12` | Defense Mode Physical / Magical / cycle / reset | Nothing with the provided template (no `sets.defense`); a `sets.defense` you add reaches idle gear only, never engaged gear, and not outside town in a Hybrid Mode that has its own `sets.idle.<mode>` (PDT in the provided file) |
| `!f10` | Kiting on / off | Nothing unless you add `sets.Kiting` (idle only, and not outside town in a Hybrid Mode that has its own `sets.idle.<mode>`) |
| `f12` | `update user` | Puts your gear back for your current status and prints the current modes |
| `^-`, `^=` | Mote target helpers | Mote's own `<t>` target switching |

Key conflicts for this job, on every subjob: `//gs c keyconflicts`.

## All commands on this job

Type `//gs c <command>` (or `/console gs c <command>` in a macro). Full list
and arguments: [commands guide](../../guides/commands.md).

**THF commands**

| Command | What it does |
|---|---|
| `buff` (`buffs`, `buffself`, `selfbuff`, `smartbuff`) | Common command. Every job: your main job's list, then your subjob's (not when the subjob is disabled), from `_common/combat/BUFF_CONFIG.lua`. THF has no list (`job.THF`) by default; add one if you like. Subjob lists (`subjob`) by default: /WAR Berserk, Aggressor, Warcry; /SAM Hasso (two-handed weapon only), Third Eye; /NIN Utsusemi: Ni, else Ichi; /DNC Haste Samba (350 TP); /WHM Reraise. Buffs already up or on recast are listed in chat, what your jobs cannot use is skipped quietly; the rest goes one action after the other. No list for your jobs: a warning naming the file ([configuration](../../guides/configuration.md)) |
| `fbc` | Feint, Bully, Conspirator: the ready ones whose buff is not already up, 1 s apart |
| `steal` | Steal, Mug, Despoil on your target, the ready ones, 1 s apart. Only on a living monster |
| `range` | Equips the range and ammo of `sets.RangeLock` (else `sets.precast.RA`), locks them, shoots `/ra <stnpc>`; never fires Rare or one-per-stack ammo, nor ammo the weapon cannot shoot |
| `th` | Treasure Mode status (mode, TH set found, mobs tagged); `th clear` forgets the tagged mobs; `th hide` / `show` / `key <key>` |

**Common commands that work on THF**

| Command | What it does |
|---|---|
| `cyclestate <Mode>` / `cycle` / `set` / `toggle` / `reset` | Change a mode (what the keys send) |
| `ui ...` | Keybind HUD: show / hide, save position, font, theme, order |
| `am [on/off]` | Auto Medicine |
| `checksets`, `wa`, `wo`, `rf`, `naked`, `reload` | Gear check, wardrobe audit / organizer, refill, unequip all, reload |
| `ls`, `dressup` | Lockstyle again, DressUp handling |
| `craft`, `fish`, `uncraft` | Crafting / fishing sets (write your own set file) |
| `warp`, `w2`, `tph`... , `<command>all`, `mount` | Travel |
| `waltz`, `aoewaltz` | /DNC: Curing Waltz on `<stpc>`, Divine Waltz |
| `lightarts`, `darkarts`, `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: Light / Dark Arts then the Addendum on the next press; Sneak / Invisible / Erase on the party with Accession |
| `jump` | /DRG: Jump / High Jump |
| `watchdog ...`, `debugmidcast` | Midcast watchdog, midcast debug |
| `stealth sneak` / `invi` / `both` ... | Sneak / Invisible on you and your alts |
| `alts ...`, `main`, `altcmds`, `alt <name>` | Dual-box group |
| `combatmode [show / hide / key]` | Combat Mode (weapon lock) on this job |
| `dw [auto / none / haste / haste2 / max]` | Dual Wield tier |
| `belt` | Obi / Orpheus status |
| `tb ...` | Temporary keys |
| `keyconflicts` (`kc`) | Every key conflict on this job |
| `info <name>`, `jamsg`, `spellmsg`, `wsmsg` | Ability / spell / weaponskill details and chat messages |
| `commands`, `help` | Built-in command list and help |
| `syscheck`, `fulltest`, `trace`, `debugsubjob`, ... | Diagnostics |

## Shared features on this job

| Feature | On THF |
|---|---|
| Treasure Hunter | Native. See [Treasure Hunter](#treasure-hunter) below |
| Weaponskill check | A weaponskill out of range or under 1000 TP is cancelled with a message; TP bonus gear (Moonshade...) from `THF_TP_CONFIG.lua` is added |
| Recast check | An ability or spell still on recast is cancelled with the time left (tolerance and party announce in `RECAST_CONFIG.lua`) |
| Debuff guard | An action you cannot do (silenced, amnesia, ...) is stopped; with Auto Medicine on, Echo Drops / Remedy are used |
| Doom | `sets.buff.Doom` goes on and its neck, rings and waist stay locked while Doomed |
| Movement speed | `sets.MoveSpeed` on idle while you move outside town; `sets.Adoulin` in Adoulin, `sets.idle.Town` in other towns |
| Obi / Orpheus | Added to elemental weaponskills (Aeolian Edge, ...) and damaging spells when the day, weather or distance gives enough (`//gs c belt`) |
| Dual Wield tiers | Only if you define `sets.DW` (a commented example is in the template) |
| Weapon without a set | With `equip_without_set = true` in `_common/gear/WEAPON_CONFIG.lua`, a Main / Sub Weapon value with no set equips that weapon by name |
| Combat Mode | Off and hidden. When shown and On: main, sub and range stay locked |
| Your own modes | `THF_CUSTOM.lua`: extra modes, keys and gear rules without code |
| Midcast watchdog | Puts your gear back if a cast result never arrives |
| Lockstyle, macro book | Set on load and on each subjob change |
| Dual-box | Job exchange with your alt, `alts` orders, macro book per alt job |
| Messages | Ability, spell and weaponskill lines in chat (`jamsg` / `spellmsg` / `wsmsg`) |
| Quiver | After a ranged attack, the quiver of the bolts you wear (Acid Bolt -> Ac. Bolt Quiver) in your inventory is opened when 5 or fewer are left (`quiver_open_at` in `_common/inventory/REFILL_CONFIG.lua`: another number, or `false` for never) |

### Treasure Hunter

| Mode | Engaged | Under Sneak / Trick Attack |
|---|---|---|
| Tag (default) | `sets.TreasureHunter` until one of your actions lands on the current target | `sets.buff['Sneak Attack']` / `['Trick Attack']` |
| SATA | as Tag | `sets.TreasureHunterSA` / `TA` / `SATA` instead |
| Full | `sets.TreasureHunter` at all times | as SATA |

In every mode, your first weaponskill, job ability, spell or ranged attack
against a mob not tagged yet also wears `sets.TreasureHunter`. Any of your
actions tags the mob (melee, ranged, weaponskill, spell, ability). A tag is
forgotten when the mob dies, when you zone, after 3 minutes with no action
on it, on a reload or subjob change, or with `//gs c th clear`.
`//gs c th hide` turns Treasure Hunter off on THF (and removes its key);
`//gs c th show` brings it back.

## Configuration files for this job

In `<YourName>/thf/`, each file in its theme folder (`display/` for HUD,
lockstyle and macro book, `keys/` for states, keys and CUSTOM, `inventory/`
for refill, `combat/` for the rest):

| File | Content |
|---|---|
| `THF_STATES.lua` | Modes, their values and defaults |
| `THF_KEYBINDS.lua` | The job keys above |
| `THF_CUSTOM.lua` | Your own modes, keys and gear rules ([keybinds guide](../../guides/keybinds.md)) |
| `THF_HUD.lua` | HUD section and row order for THF (written by `//gs c ui order` / `roworder`) |
| `THF_LOCKSTYLE.lua` | Lockstyle number (the template uses `default` only) |
| `THF_MACROBOOK.lua` | Macro book / page per subjob and per dual-box alt job |
| `THF_TP_CONFIG.lua` | TP bonus pieces and weapons ([TP bonus](../../features/tp-bonus.md)) |
| `THF_REFILL.lua` | What `//gs c rf` restocks on THF on top of or in place of the common list (every line commented at first: the common list; [configuration](../../guides/configuration.md#refill-job_refilllua)) |

In `<YourName>/_common/`, shared with the other jobs: `COMMON_KEYBINDS.lua`,
`WEAPON_CONFIG.lua`, `DW_CONFIG.lua`, `ELEMENTAL_BELT_CONFIG.lua`,
`RECAST_CONFIG.lua`, `STEALTH_CONFIG.lua`; in `<YourName>/saved/`,
`treasure_mode.lua` / `combat_mode.lua` (written by `//gs c th` /
`combatmode`). Gear:
`<YourName>/thf/sets/thf_sets.lua`. See [configuration](../../guides/configuration.md).

## More

- [states.md](states.md): each mode in detail
- [sets.md](sets.md): set names and automatic gear
- [Commands guide](../../guides/commands.md), [keybinds guide](../../guides/keybinds.md)
