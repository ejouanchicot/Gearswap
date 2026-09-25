# Configuration

Everything you can change lives in `<YourName>/` (created by the clone script,
see [installation](../getting-started/installation.md)). After an edit,
`//gs c reload` (or `//lua reload gearswap`) applies it.

## What is in `<YourName>/config/`

| File | What it sets |
|---|---|
| `COMMON_KEYBINDS.lua` | Keys every job gets ([keybinds](keybinds.md)) |
| `UI_CONFIG.lua` | HUD defaults, background presets ([HUD](../features/ui.md)) |
| `UI_COLOR_CONFIG.lua` | HUD colours of values (elements, modes...) |
| `ui_settings.lua` | HUD position and toggles, written by `//gs c ui ...` |
| `LOCKSTYLE_CONFIG.lua` | `initial_load_delay` = 8.0 s between a load and the lockstyle |
| `RECAST_CONFIG.lua` | `tolerance` = 2.0 s: an ability or spell whose recast is at or under this counts as ready |
| `message_modes.lua` | Chat detail for spells / abilities / weaponskills, written by `jamsg`, `spellmsg`, `wsmsg` |
| `CRAFT_CONFIG.lua` | Lockstyle numbers for `craft` (19) and `fish` (17) |
| `DUALBOX_CONFIG.lua` | Role, partner, group ([dual-box](dualbox.md)) |
| `REGION_CONFIG.lua` | Your region (US / EU / JP): some chat colour codes differ by region |
| `WARDROBE_CONFIG.lua` | Optional: bags used by `//gs c wo` |
| `alt/` | Alt commands, main character only ([dual-box](dualbox.md)) |
| `<job>/` | One folder per job, below |

Per job, `<YourName>/config/<job>/`:

| File | What it sets |
|---|---|
| `<JOB>_STATES.lua` | The job's modes: values and defaults |
| `<JOB>_KEYBINDS.lua` | The job's keys |
| `<JOB>_CUSTOM.lua` | Your own modes and gear rules (empty by default) |
| `<JOB>_LOCKSTYLE.lua` | Lockstyle number |
| `<JOB>_MACROBOOK.lua` | Macro book and page |
| `<JOB>_TP_CONFIG.lua` | TP bonus pieces for weaponskills ([tp-bonus](../jobs/war/tp-bonus.md)) |
| `<JOB>_REFILL.lua` | Consumables for `//gs c rf` (you create it, see below) |
| others | Job-specific: `BLM_MP_CONFIG`, `BRD_SONG_CONFIG`, `WHM_CURE_CONFIG`, `RDM_SABOTEUR_CONFIG`... (see the job's page) |

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
`get_style` function: BST, COR, DNC, DRK, GEO, PLD, RUN and WAR have it; on
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

`//gs c rf` tops up the consumables in your inventory from the Mog Case and
Mog Sack, and puts the surplus back. The lists are per character and per job,
and only the author's characters ship with them: **create
`<YourName>/config/<job>/<JOB>_REFILL.lua` yourself**. Without it, `rf` uses a
short built-in list (Panacea, Antacid, Holy Water, Remedy, Prism Powder, Silent
Oil, 12 each). Format (model: `_master/Tetsouo/config/war/WAR_REFILL.lua`):

```lua
local M = {}
M.store_bag = 'case'            -- where the surplus goes: 'case', 'sack' or 'satchel'
M.default = {
    { name = 'Panacea', target = 12 },
    { name = {'Sublime Sushi +1', 'Sublime Sushi'}, target = 12 },  -- +1 first, then the other
}
M.subjobs = {                   -- a different list for a subjob (optional)
    DNC = { { name = 'Panacea', target = 12 } },
}
return M
```

Consumables named only in another job's list are put back too. While a craft
set is on, `config/craft/CRAFT_REFILL.lua` is used instead (Tetsouo template
only).

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

The author's files are in `_master/Tetsouo/config_global/WARDROBE_CONFIG.lua`
and `_master/Kaories/config_global/WARDROBE_CONFIG.lua`.

## Sets (`<YourName>/sets/`)

`<job>_sets.lua` holds your gear. Item names must match the game exactly,
augmented items need their exact `augments`, and a second copy of an item is
told apart with `bag = 'wardrobe 2'` and so on. Check with `//gs c checksets`.
The set names each job looks for are in the developer page of the job
(section "Set names the code looks up", [docs/dev/jobs/](../../dev/README.md#jobs)).

## Troubleshooting

| Symptom | Try |
|---|---|
| An edit does nothing | `//gs c reload`; look for a Lua error in the chat or console; check you edited `<YourName>/config/...`, not `_master/` |
| Lockstyle ignores the subjob | The job's `_LOCKSTYLE.lua` has no `get_style` (see above) |
| Macro book does not change | Check the book and page exist in game, and the subjob spelling (`'SAM'`) |
| `//gs c wo` interrupted, slots locked | `//gs c wo recover` |
