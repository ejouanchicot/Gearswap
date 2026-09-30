# Configuration

Everything you can change lives in `<YourName>/` (created by the clone script,
see [installation](../getting-started/installation.md)). After an edit,
`//gs c reload` (or `//lua reload gearswap`) applies it.

## How your folder is organised

```
<YourName>/
    <YourName>_WAR.lua ...   one line per job: nothing to change there
    common/                  settings of the whole character, by theme:
        display/             HUD, colours, region, lockstyle delay
        keys/                keys every job gets, Combat Mode / Treasure Mode keys
        dualbox/             dual-box settings
            alt/             your own commands for the dual-box alt (optional)
        inventory/           refill, craft, wardrobe organizer
        combat/              automatic abilities, recasts, Dual Wield, belt, weapons,
                             Sneak / Invisible
        sets/                gear shared by your jobs (rings...), your craft and fishing sets
    war/, blm/ ...           one folder per job you play: its settings
        sets/                the gear of that job (war_sets.lua...)
    saved/                   written by the game (window positions, HUD settings...): leave it
```

Settings are files, gear is always in a `sets/` folder.

A folder made before 2026-09-30 has `config/` and `sets/` instead; it still
works. `python migrate_layout.py <YourName>` (in the `data` folder) moves it to
the layout above, after a full backup in `data/_backups/`.

## What is in `<YourName>/common/`

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
| `CRAFT_CONFIG.lua` | Which set file `craft` and `fish` use (`craft_file = 'craft'` reads `common/sets/craft_sets.lua`; `'goldsmithing'` reads `common/sets/goldsmithing_sets.lua`...) and their lockstyle numbers (19 and 17) |
| `REFILL_CONFIG.lua` | The bags `rf` uses, for every job: `source_bags` (where missing items are taken from, in order; default `{'case', 'sack', 'satchel'}`) and `store_bag` (where extra items go; default `'case'`). Bags: `case`, `sack`, `satchel`, `wardrobe1` to `wardrobe8` (wardrobes only hold equipment, ammo for instance). The Mog Safe, Storage and Locker only open in the Mog House |
| `DW_CONFIG.lua` | Dual Wield tiers: while you hold two weapons and are engaged, the pieces of `sets.DW.NoHaste` / `Haste` / `HasteII` / `MaxHaste` (in your job's set file) go on top of your engaged set, chosen by your magic haste (estimated from your buffs). `enabled`, and the % each buff counts for. No `sets.DW` in a job file: nothing changes. `//gs c dw` shows the estimate, `//gs c dw none\|haste\|haste2\|max` forces a tier, `//gs c dw auto` goes back. Slow / Elegy on you are not counted: while slowed, `//gs c dw none` |
| `ELEMENTAL_BELT.lua` | Hachirin-no-Obi / Orpheus's Sash put on by themselves on elemental damage (nukes, elemental weaponskills, Quick Draw...): Orpheus close to the target, the Obi when the day or weather matches, neither far away with nothing matching. `enabled`, `min_bonus` (5 %: below it, your set's belt stays). Only a belt in your inventory / wardrobes is used. `//gs c belt` shows today's values |
| `STEALTH_CONFIG.lua` | Sneak / Invisible settings (`refresh_below` 180 s, `alert_before` 60 s, `overwrite`, `alerts`, `delay` 3.0 s), also written by `//gs c stealth refresh / alert / ...` and kept on a re-clone ([Sneak and Invisible](stealth.md)) |
| `WARDROBE_CONFIG.lua` | Optional, not in the generic template: bags used by `//gs c wo` (below) |

**Written from your clone answers:**

| File | What it sets |
|---|---|
| `DUALBOX_CONFIG.lua` | Role, partner, group ([dual-box](dualbox.md)) |
| `REGION_CONFIG.lua` | Your region (US / EU / JP): some chat colour codes differ by region |

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
| `<job>/<JOB>_HUD.lua` | `//gs c ui order` / `roworder` (see the per-job table below) |
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
| `<JOB>_REFILL.lua` | Consumables for `//gs c rf` (you create it, see below) |
| others | Job-specific: `BLM_ELEMENTAL_CONFIG`, `BLM_MP_CONFIG`, `BLU_SPELL_MAP`, `BRD_SONG_CONFIG`, `BRD_TIMING_CONFIG`, `BST_ECOSYSTEM_DATA`, `BST_PET_DATA`, `DNC_WS_CONFIG`, `PLD_BLU_MAGIC`, `PLD_WS_CONFIG`, `RDM_SABOTEUR_CONFIG`, `RUN_BLU_MAGIC`, `WAR_WS_CONFIG`, `WHM_CURE_CONFIG` (see the job's page) |

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
Sack, then Satchel unless `common/inventory/REFILL_CONFIG.lua` says otherwise), and puts
the surplus back. The lists are per character and per job,
and only the author's characters ship with them: **create
`<YourName>/<job>/<JOB>_REFILL.lua` yourself**. Without it, `rf` uses a
short built-in list (Panacea, Antacid, Holy Water, Remedy, Prism Powder, Silent
Oil, 12 each). Format:

```lua
local M = {}
M.store_bag = 'case'            -- where the surplus goes (optional: REFILL_CONFIG.lua otherwise)
M.source_bags = {'satchel', 'case'}   -- where to take from, for this job only (optional)
M.default = {
    { name = 'Panacea', target = 12 },
    { name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12 },  -- +1 first, then the other
}
M.subjobs = {                   -- a different list for a subjob (optional)
    DNC = { { name = 'Panacea', target = 12 } },
}
return M
```

Consumables named only in another job's list (of any character folder in `data/`) are put back too. While a craft
set is on, `common/inventory/CRAFT_REFILL.lua` is used instead: same format, empty
until you fill it; it can set its own `source_bags` / `store_bag` too.

## Wardrobes (`WARDROBE_CONFIG.lua`, optional)

Without it, `//gs c wo` keeps the loaded job's gear in wardrobes 1-2 and pushes
the rest to wardrobes 8, 6, 5, 4, 3 (in that order); wardrobe 7 is left alone.
The file changes that with bag numbers (8 = wardrobe 1, 10 = 2, 11 = 3, 12 = 4,
13 = 5, 14 = 6, 15 = 7, 16 = 8; 5 = satchel, 6 = sack, 7 = case):

```lua
return {
    SCOPE = 'active_job',                -- or 'all_jobs': every job's sets count
    PRIMARY_BAGS  = {8, 10},
    OVERFLOW_BAGS = {16, 14, 13, 12, 11},
    KEEP_ITEMS    = {},                  -- items to keep in the main bags although no set names them
}
```

The author's own files are not published.

## Sets (`<YourName>/<job>/sets/`)

`<job>/sets/<job>_sets.lua` holds your gear for that job; `common/sets/` holds
gear several jobs use and your craft sets. Item names must match the game exactly,
augmented items need their exact `augments`, and a second copy of an item is
told apart with `bag = 'wardrobe 2'` and so on. Check with `//gs c checksets`.
The names every job understands are on [set names](sets.md); each job's own
names are on its `sets.md` page ([jobs](../jobs/README.md)).

## Troubleshooting

| Symptom | Try |
|---|---|
| An edit does nothing | `//gs c reload`; look for a Lua error in the chat or console; check you edited `<YourName>/common/...`, not `_master/` |
| Lockstyle ignores the subjob | The job's `_LOCKSTYLE.lua` has no `get_style` (see above) |
| Macro book does not change | Check the book and page exist in game, and the subjob spelling (`'SAM'`) |
| `//gs c wo` interrupted, slots locked | `//gs c wo recover` |
