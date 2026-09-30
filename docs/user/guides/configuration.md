# Configuration

Everything you can change lives in `<YourName>/` (created by the clone script,
see [installation](../getting-started/installation.md)). After an edit,
`//gs c reload` (or `//lua reload gearswap`) applies it.

## How your folder is organised

```
<YourName>/
    <YourName>_WAR.lua ...   one line per job: nothing to change there
    _common/                 settings of the whole character, by theme:
        display/             HUD, colours, region, lockstyle delay
        keys/                keys every job gets, Combat Mode / Treasure Mode keys
        dualbox/             dual-box settings
            alt/             your own commands for the dual-box alt (optional)
        inventory/           refill, craft, wardrobe organizer
        combat/              automatic abilities, recasts, Dual Wield, belt, weapons,
                             Sneak / Invisible, HP priority, Auto Medicine,
                             Sortie (if you have one)
        sets/                gear shared by your jobs (rings...), your craft and fishing sets
    war/, blm/ ...           one folder per job you play, by the same themes:
        display/             WAR_HUD, WAR_LOCKSTYLE, WAR_MACROBOOK
        keys/                WAR_KEYBINDS, WAR_STATES, WAR_CUSTOM
        combat/              WAR_TP_CONFIG, WAR_WS_CONFIG and the job's own settings
                             (BRD songs, RDM Saboteur, WHM cures, BST pets...)
        inventory/           WAR_REFILL
        sets/                the gear of that job (war_sets.lua...)
    saved/                   written by the game (window positions, HUD settings...): leave it
```

Settings are files, gear is always in a `sets/` folder. The `_` in front of
`_common/` puts it first in the folder list.

`_WHERE-IS-WHAT.txt`, at the top of your folder, lists every file of it and
what it holds. The clone and `migrate_layout.py` write it; after you add a
file, `python where_is_what.py <YourName>` (in the `data` folder) writes it
again.

A folder made before 2026-09-30 has `config/` and `sets/` instead; it still
works. `python migrate_layout.py <YourName>` (in the `data` folder) moves it to
the layout above, after a full backup in `data/_backups/`.

## What is in `<YourName>/_common/`

The clone script copies every file of `_master/config_global/` here, each in
its theme folder (the table below gives the file name; its folder is in the
tree above), writes `DUALBOX_CONFIG.lua` and `REGION_CONFIG.lua` from your
answers, and copies one folder per job. Some files are written by the game session (by a command, or
when you drag a window): they are marked "written in game" below, and a
re-clone copies them back from the old folder (see
[installation](../getting-started/installation.md#3-create-your-character)).

**Copied from the template, you edit them:**

| File | What it sets |
|---|---|
| `COMMON_KEYBINDS.lua` | Keys every job gets ([keybinds](keybinds.md#common-keys)) |
| `UI_CONFIG.lua` | HUD defaults, background presets, look of the chat blocks ([HUD](../features/ui.md)) |
| `UI_COLOR_CONFIG.lua` | HUD colours of values (elements, modes...) |
| `LOCKSTYLE_CONFIG.lua` | `initial_load_delay` = 8.0 s between a load and the lockstyle (its only setting) |
| `RECAST_CONFIG.lua` | `tolerance` = 2.0 s: an ability or spell whose recast is at or under this counts as ready. `party_announce`: a party message when an action is refused on recast, e.g. `['Phantom Roll'] = true` sends `/p Phantom Roll ready in <recast=Phantom Roll>` (the game shows the time left); a text of your own works too, where `{action}` becomes what you tried (`'{action} : roll ready in <recast=Phantom Roll>'` sends `Bolter's Roll : roll ready in ...`). One message per second at most (`party_announce_every` = 1) |
| `AUTO_ABILITIES.lua` | Job abilities used for you, all `false` (off) by default: `sam_hasso` (SAM: your chosen stance, Hasso or Seigan, when you engage, unless one is up), `geo_entrust` (an Indi- spell cast on a party member gets Entrust first), `geo_full_circle` (a Geo- spell cast while a luopan is out gets Full Circle first), `blu_unbridled` (an unbridled spell gets Unbridled Learning first), `blu_expiacion_window` (see [BLU](../jobs/blu/states.md)) |
| `WEAPON_CONFIG.lua` | `equip_without_set` (default `false`): with `true`, a weapon mode value that has no set of that name equips the weapon of that name directly, so a plain weapon needs no set. Keep a set for an augmented weapon |
| `CRAFT_CONFIG.lua` | Which set file `craft` and `fish` use (`craft_file = 'craft'` reads `_common/sets/craft_sets.lua`; `'goldsmithing'` reads `_common/sets/goldsmithing_sets.lua`...) and their lockstyle numbers (19 and 17) |
| `REFILL_CONFIG.lua` | The common list `rf` keeps on every job, `default_list` (six medicines by default, see [Refill](#refill-job_refilllua)), and optionally `subjobs` (that list per subjob). The bags `rf` uses, for every job: `source_bags` (where missing items are taken from, in order; default `{'case', 'sack', 'satchel'}`) and `store_bag` (where extra items go; default `'case'`). Bags: `case`, `sack`, `satchel`, `wardrobe1` to `wardrobe8` (wardrobes only hold equipment, ammo for instance). The Mog Safe, Storage and Locker only open in the Mog House |
| `DW_CONFIG.lua` | Dual Wield tiers: while you hold two weapons and are engaged, the pieces of `sets.DW.NoHaste` / `Haste` / `HasteII` / `MaxHaste` (in your job's set file) go on top of your engaged set, chosen by your magic haste (estimated from your buffs). `enabled`, and the % each buff counts for. No `sets.DW` in a job file: nothing changes. `//gs c dw` shows the estimate, `//gs c dw none\|haste\|haste2\|max` forces a tier, `//gs c dw auto` goes back. Slow / Elegy on you are not counted: while slowed, `//gs c dw none` |
| `ELEMENTAL_BELT.lua` | Hachirin-no-Obi / Orpheus's Sash put on by themselves on elemental damage (nukes, elemental weaponskills, Quick Draw...): Orpheus close to the target, the Obi when the day or weather matches, neither far away with nothing matching. `enabled`, `min_bonus` (5 %: below it, your set's belt stays). Only a belt in your inventory / wardrobes is used. `//gs c belt` shows today's values |
| `STEALTH_CONFIG.lua` | Sneak / Invisible settings (`refresh_below` 180 s, `alert_before` 60 s, `overwrite`, `alerts`, `delay` 3.0 s), also written by `//gs c stealth refresh / alert / ...` and kept on a re-clone ([Sneak and Invisible](stealth.md)) |
| `HP_PRIORITY.lua` | The order your pieces go on in when a set changes. At each change (idle or engaged > precast > midcast > aftercast...) the pieces are ranked by the HP they gain over the ones you wear right then: those that raise your max HP go on first, those that lower it last, so your max HP never dips mid-swap. It changes the order only, never what you wear or your sets; a `priority` you write yourself on a piece is kept as it is. `enabled` (default `true`), `unity` (`'min'`; `'max'` when your Unity leader is rank 1, for the Unity HP / MP of Unity gear), `mp_jobs` (default `{'BLM', 'RDM', 'GEO'}`: MP counts after HP), `skip_jobs` (default `{}`: jobs left alone, their sets give their own priorities). A missing key keeps its default. For pieces your sets name without augments, run `//gs c gearscan` once (and again after new or upgraded gear): it saves their real augments in `saved/gear_augments.lua` |
| `AUTOCURE_CONFIG.lua` | Auto Medicine: `auto_cure_silence` (default `true`) and `silence_cure_items` (default `{'Echo Drops', 'Remedy'}`, used before a spell), `auto_cure_paralysis` (default `true`) and `paralysis_cure_items` (default `{'Remedy', 'Panacea'}`, used before an ability; weaponskills are left to the game), tried in the order written; an item is just its name. `auto_medicine_start` (`'On'` by default, or `'Off'`): the value Auto Medicine has when the game starts; after that, a job change keeps what you set. Every line is commented out at first: the shared defaults apply, and a key you uncomment replaces only that one. A folder cloned before 2026-09-30 does not have it: copy `_master/config_global/AUTOCURE_CONFIG.lua` into `_common/combat/` |
| `WARDROBE_CONFIG.lua` | Where `//gs c wo` puts your gear: used and unused bags, bags it never touches, and placement rules (below). Every line is commented out at first: the defaults apply |

**Written from your clone answers:**

| File | What it sets |
|---|---|
| `DUALBOX_CONFIG.lua` | Role, partner, group ([dual-box](dualbox.md)) |
| `REGION_CONFIG.lua` | Your region (US / EU / JP): some chat colour codes differ by region |

**Only if you write it (no template):**

| File | What it sets |
|---|---|
| `SORTIE_CONFIG.lua` (in `combat/`) | `//gs c sortie`: your alt, where its Silmaril profiles are, your stances and the states set per target, the targets and their aliases, `escort` and the one-shot orders to the alt. Without it the character has no sortie command (it says it is not set up, and the help does not list it). The author's, `Tetsouo/_common/combat/SORTIE_CONFIG.lua`, is the example; its header explains every key |

**Written in game (kept on a re-clone):**

| File | Written by |
|---|---|
| `ui_settings.lua` | `//gs c ui ...`: HUD position, shown parts, background, font. Wins over `UI_CONFIG.lua`; delete it to go back to those values |
| `message_modes.lua` | `//gs c jamsg` / `spellmsg` / `wsmsg`: chat detail for abilities / spells / weaponskills |
| `combat_mode.lua` | `//gs c combatmode`: on which jobs Combat Mode shows, and its key ([keybinds](keybinds.md#combat-mode-every-job)) |
| `treasure_mode.lua` | `//gs c th`: on which jobs Treasure Mode shows, and its key ([keybinds](keybinds.md#treasure-mode-every-job)) |
| `alt_window.lua` | Dragging the alt window (main only) |
| `alt_state.lua` | The `alts` orders: who follows whom, automation on / off, kept across GearSwap reloads |
| `WARP_ITEMS_OWNED.lua` | `//gs c wo scan`: the warp items you own |
| `gear_augments.lua` | `//gs c gearscan`: the augments of your gear, read by the HP priority |
| `<job>/display/<JOB>_HUD.lua` | `//gs c ui order` / `roworder` (see the per-job table below) |
| `../temp_binds.lua` | `//gs c tb` (in `<YourName>/`, not in `config/`) |

`dualbox_role.lua` is written by `//gs c main` and `setalt`: it wins over the
role in `DUALBOX_CONFIG.lua`. A re-clone does **not** keep it, on purpose: the
role you give the script applies.

**Folders:**

| Folder | Content |
|---|---|
| `display/`, `keys/`, `dualbox/`, `inventory/`, `combat/` | The settings files above, by theme |
| `dualbox/alt/` | Alt commands, main character only ([dual-box](dualbox.md#alt-commands-drive-the-alt-from-the-main)) |
| `sets/` | Gear used by several jobs (for instance `rings.lua`), your craft and fishing sets (`craft_sets.lua`...) |
| `<job>/` | One folder per job, below |

Per job, `<YourName>/<job>/`:

| File | What it sets |
|---|---|
| `<JOB>_STATES.lua` | The job's modes: values and defaults |
| `<JOB>_KEYBINDS.lua` | The job's keys |
| `<JOB>_CUSTOM.lua` | Your own modes and gear rules (empty by default) |
| `<JOB>_LOCKSTYLE.lua` | Lockstyle number |
| `<JOB>_MACROBOOK.lua` | Macro book and page |
| `<JOB>_TP_CONFIG.lua` | TP bonus pieces for weaponskills ([tp-bonus](../jobs/war/tp-bonus.md)) |
| `<JOB>_HUD.lua` | This job's HUD section and row order, empty by default; written by `//gs c ui order` / `roworder` ([HUD](../features/ui.md#order-of-the-sections-and-rows)) |
| `<JOB>_REFILL.lua` | Consumables for `//gs c rf` on this job, added to the common list or replacing it; every line commented at first (see below) |
| others | Job-specific: `BLM_ELEMENTAL_CONFIG`, `BLM_MP_CONFIG`, `BLU_SPELL_MAP`, `BRD_SONG_CONFIG`, `BRD_TIMING_CONFIG`, `BST_ECOSYSTEM_DATA`, `BST_PET_DATA`, `DNC_WS_CONFIG`, `PLD_BLU_MAGIC`, `PLD_WEAPONS`, `PLD_WS_CONFIG`, `RDM_SABOTEUR_CONFIG`, `RUN_BLU_MAGIC`, `WAR_WS_CONFIG`, `WHM_CURE_CONFIG` (see the job's page) |

## Modes (`<JOB>_STATES.lua`)

Each mode is a Mote-Include state. To change the default value, change the
`:set(...)` line of that mode; to add or remove values, edit its list:

```lua
state.MainWeapon = M {
    ['description'] = 'Main Weapon',
    'Naegling', 'Ukonvasara',
}
state.MainWeapon:set('Naegling')
```

Every mode goes back to its default on each load (job change, subjob change,
reload), except Auto Medicine. To add a mode of your own, prefer
`<JOB>_CUSTOM.lua` ([keybinds](keybinds.md#your-own-modes-job_customlua)):
it needs no code and keeps your changes apart from the job's files.

## Lockstyle (`<JOB>_LOCKSTYLE.lua`)

```lua
local WARLockstyleConfig = {}
WARLockstyleConfig.default = 4
WARLockstyleConfig.by_subjob = { ['SAM'] = 4, ['DRG'] = 4 }
function WARLockstyleConfig.get_style(subjob)
    return WARLockstyleConfig.by_subjob[subjob] or WARLockstyleConfig.default
end
return WARLockstyleConfig
```

`default` is always used. `by_subjob` counts only when the file also has the
`get_style` function: BST, COR, DNC, DRK, GEO, PLD, RUN, WAR and SMN have it; on
the other jobs `by_subjob` is ignored until you add one (copy it from
`WAR_LOCKSTYLE.lua`). The lockstyle is sent 8 s after each load, and again with
`//gs c ls`.

## Macro book (`<JOB>_MACROBOOK.lua`)

```lua
WARMacroConfig.solo = {
    ['SAM'] = { book = 22, page = 1 },
    ['default'] = { book = 22, page = 1 },
}
WARMacroConfig.dualbox = {
    ['GEO'] = {                              -- partner's main job
        ['SAM'] = { book = 23, page = 1 },   -- your subjob
    },
}
WARMacroConfig.default = { book = 22, page = 1 }
```

With dual-box on and the partner online (it reported its job in the last
30 s), `dualbox[partner job][your
subjob]` is used; otherwise `solo[your subjob]`, then `solo.default`, then
`default`.

## Refill (`<JOB>_REFILL.lua`)

`//gs c rf` tops up the consumables in your inventory from your bags (Case,
Sack, then Satchel unless `_common/inventory/REFILL_CONFIG.lua` says otherwise), and puts
the surplus back.

**The common list**, for every job, is `default_list` in
`<YourName>/_common/inventory/REFILL_CONFIG.lua`. A new character gets Panacea,
Antacid, Holy Water, Remedy, Prism Powder and Silent Oil, 12 each. You can also
give it a list per subjob (`subjobs`, an example is commented in the file):

```lua
RefillConfig.default_list = {
    { name = 'Panacea', target = 12 },
    { name = 'Remedy', target = 12 },
}
RefillConfig.subjobs = {        -- optional: the common list when your subjob is DNC
    DNC = { { name = 'Remedy', target = 12 } },
}
```

**Each job** has `<YourName>/<job>/inventory/<JOB>_REFILL.lua`. A new character
gets it with every line commented, so that job uses the common list. Uncomment
what you want:

```lua
local M = {}
M.extra = {                     -- added to the common list
    { name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12 },  -- +1 first, then the other
}
M.default = {                   -- or: a list of its own, in place of the common one
    { name = 'Remedy', target = 12 },
}
M.subjobs = {                   -- or: a list for one subjob (wins over both)
    DNC = { { name = 'Remedy', target = 12 } },
}
M.store_bag = 'case'            -- where the surplus goes, this job only (optional)
M.source_bags = {'satchel', 'case'}   -- where to take from, this job only (optional)
return M
```

An `extra` item that is already in the common list (same name, or same first
name for variants) replaces it, so the `target` you write in `extra` wins.

Which list `rf` uses, first match (the start of the `rf` report shows it as
`Config`):

1. The craft list, while a craft set is on (below).
2. The job's `subjobs` list for your subjob (`WAR/DNC`), then its `default`
   (`WAR/default`).
3. The common list: its `subjobs` list for your subjob (`common/DNC`), else
   `default_list` (`common`), plus the job's `extra` if it has one
   (`common + WAR extra`).
4. Only when neither file gives a list (no `REFILL_CONFIG.lua`, or no
   `default_list` in it): the built-in six medicines (`fallback`).

Consumables named only in another list (another job's, or any list of any character folder in `data/`) are put back too. While a craft
set is on, `_common/inventory/CRAFT_REFILL.lua` is used instead: same format, empty
until you fill it; it can set its own `source_bags` / `store_bag` too.

## Wardrobes (`WARDROBE_CONFIG.lua`)

`_common/inventory/WARDROBE_CONFIG.lua` tells `//gs c wo` where your gear goes.
Every key is optional, and a new character gets the file with every line
commented out. With nothing set, the gear of the loaded job goes to wardrobes
1-2, the rest to your other unlocked wardrobes, and no wardrobe is protected.

Name the bags in words: `'wardrobe'` (or `'wardrobe 1'`), `'wardrobe 2'` ...
`'wardrobe 8'`, or `'W1'` ... `'W8'`, and `'satchel'`, `'sack'`, `'case'`,
`'inventory'`. The game equips only from the inventory and the wardrobes: gear
put in the Satchel, Sack or Case must come back before you can wear it. A name
it does not know is ignored and shown as a `Config:` warning when `wo` starts.

```lua
return {
    SCOPE  = 'active_job',                   -- or 'all_jobs': every job's gear counts as used
    USED   = {'wardrobe', 'wardrobe 2'},     -- where the used gear goes, in this order
    UNUSED = {'wardrobe 8', 'wardrobe 6', 'wardrobe 5', 'wardrobe 4', 'wardrobe 3'},
    NEVER_TOUCH = {'wardrobe 7'},            -- bags it never touches (craft gear, for instance)
    KEEP = {'Nexus Cape'},                   -- counted as used although no set names it
    NEVER_MOVE = {'Emporium Ring'},          -- left in whatever bag it is
}
```

| Key | What it does |
|---|---|
| `SCOPE` | `'active_job'` (default): the gear of the job you play; run `wo` again after a job change. `'all_jobs'`: the gear of every job at once, when it all fits |
| `USED` | Bags for the used gear, filled in this order. Default: wardrobes 1 and 2 |
| `UNUSED` | Bags for everything else, in this order; storage bags allowed. Default: your other unlocked wardrobes, minus those a rule below uses |
| `NEVER_TOUCH` | Bags the organizer never touches; `//gs c wa` does not judge them either |
| `KEEP` | Items kept with the used gear although no set names them |
| `NEVER_MOVE` | Items never moved, wherever they are |
| `PLACE` | One item always in the bag you give; a list puts one copy in each bag |
| `JOBS` | The gear of a job in its own bags, from its set files, whatever `SCOPE` says |
| `TYPES` | Used gear of a kind in its own bags: `weapons` (main, sub, range), `ammo`, `armor` (head, body, hands, legs, feet), `accessories` (neck, ears, rings, back, waist) |
| `USED_WHEN_ALL`, `UNUSED_WHEN_ALL` | The bags of `//gs c wo alt` (every job at once), when they differ from `USED` / `UNUSED` |

The rules, for example:

```lua
PLACE = {
    ['Trizek Ring'] = 'wardrobe 8',
    ['Moonlight Ring'] = {'wardrobe 3', 'wardrobe 4'}, -- one copy in each
},
JOBS  = { WAR = {'wardrobe 3'}, PLD = {'wardrobe 4'} },
TYPES = { weapons = {'wardrobe 5'} },
```

When two rules name the same item, the stronger wins: `NEVER_TOUCH` /
`NEVER_MOVE`, then `PLACE`, then a `bag = 'wardrobe N'` written on the piece in
your sets, then `JOBS`, then `TYPES`, then doubled items (below), then `USED` /
`UNUSED`. A rule puts one copy per bag it lists; extra copies follow `USED` /
`UNUSED`.

Doubled items need no rule: when you own two copies (or more) of a used item
without augments, two Chirich Ring +1 for instance, `wo` puts one copy in each
`USED` bag, so each ring can be told apart by its bag (see
[Sets](#sets-yournamejobsets)). A bag named by a rule but in neither `USED`
nor `UNUSED` is kept for that rule: `wo` takes out the gear no rule puts there.

A file written with the older names still works: `PRIMARY_BAGS` (= `USED`),
`OVERFLOW_BAGS` (= `UNUSED`), `PROTECTED` (= `NEVER_TOUCH`), `KEEP_ITEMS`
(= `KEEP`), `ALT_PRIMARY_BAGS` / `ALT_OVERFLOW_BAGS`, and bag numbers instead
of names. `//gs c wo preview` shows what a change would move before you run it.

## Sets (`<YourName>/<job>/sets/`)

`<job>/sets/<job>_sets.lua` holds your gear for that job; `_common/sets/` holds
gear several jobs use and your craft sets. Item names must match the game exactly,
augmented items need their exact `augments`. Check with `//gs c checksets`.

Two copies of the same ring, earring or weapon (Moonlight Ring, Chirich Ring +1,
two identical daggers...) need nothing special: write the name on both sides,
for instance `left_ring = 'Chirich Ring +1', right_ring = 'Chirich Ring +1'`.
At each gear change each side keeps its own copy, the one it already wears when
it can, so a ring never jumps from one hand to the other (which would cost a
Moonlight Ring its HP). This works when the copies sit in different bags;
`//gs c wo` puts them there for you. If both copies are in the same bag, a
warning says so once per session. Writing `bag = 'wardrobe 2'` (or the
augments) on a piece is no longer needed, and is still respected when you do.
The names every job understands are on [set names](sets.md); each job's own
names are on its `sets.md` page ([jobs](../jobs/README.md)).

## Troubleshooting

| Symptom | Try |
|---|---|
| An edit does nothing | `//gs c reload`; look for a Lua error in the chat or console; check you edited `<YourName>/_common/...`, not `_master/` |
| Lockstyle ignores the subjob | The job's `_LOCKSTYLE.lua` has no `get_style` (see above) |
| Macro book does not change | Check the book and page exist in game, and the subjob spelling (`'SAM'`) |
| `//gs c wo` interrupted, slots locked | `//gs c wo recover` |
