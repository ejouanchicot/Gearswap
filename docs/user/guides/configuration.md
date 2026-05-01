# Configuration

All your customizations live under **`<Yourname>/config/`**. Reload with
`//gs c reload` or `//lua reload gearswap` after edits.

> Replace `<Yourname>` with your in-game character name throughout.

---

## Directory layout

```
<Yourname>/
├── <Yourname>_<JOB>.lua            Entry-point per job (one per played job)
├── sets/
│   └── <job>_sets.lua              Equipment sets per job
└── config/
    ├── DUALBOX_CONFIG.lua          DualBox role + partner
    ├── REGION_CONFIG.lua           EU/NA region preferences
    ├── WARDROBE_CONFIG.lua         primary/overflow bag layout
    ├── LOCKSTYLE_CONFIG.lua        global lockstyle timing/throttle
    ├── RECAST_CONFIG.lua           cooldown tolerances
    ├── UI_CONFIG.lua               keybind UI behavior
    ├── ui_settings.lua             UI position + toggles
    ├── message_modes.lua           per-namespace verbosity
    ├── craft/
    │   └── CRAFT_REFILL.lua        consumables to keep while crafting
    └── <job>/                      Per-job configs (one folder per played job)
        ├── <JOB>_KEYBINDS.lua      Your keybinds for the job
        ├── <JOB>_STATES.lua        State definitions (Mote-Include M{})
        ├── <JOB>_LOCKSTYLE.lua     Per-subjob lockstyle ID
        ├── <JOB>_MACROBOOK.lua     Per-subjob macrobook page
        ├── <JOB>_REFILL.lua        Consumables wanted in inv
        └── <JOB>_TP_CONFIG.lua     (WAR/SAM/DRK) TP-bonus thresholds
```

The clone script (`clone_character.py`) generates the standard layout
from `_master/` templates. Add files yourself only when you want to
extend it.

---

## Lockstyle

### Per-job — `<Yourname>/config/<job>/<JOB>_LOCKSTYLE.lua`

```lua
local WARLockstyleConfig = {}

WARLockstyleConfig.default = 1            -- fallback lockstyle ID

WARLockstyleConfig.by_subjob = {           -- per-subjob overrides
    ['SAM'] = 1,
    ['NIN'] = 2,
    ['DNC'] = 3,
}

return WARLockstyleConfig
```

Lockstyle IDs are 1-200 (FFXI maximum). Look them up in DressUp.

### Global timing — `<Yourname>/config/LOCKSTYLE_CONFIG.lua`

| Setting | Default | Notes |
| --- | --- | --- |
| `delay_after_load` | 2.0s | Delay before first apply on job load |
| `cooldown` | 15.0s | FFXI-enforced minimum between applies |

If lockstyle silently fails right after a job change, increase
`delay_after_load`. The 15s cooldown is a hard floor — the manager
throttles automatically.

---

## Macrobook

`<Yourname>/config/<job>/<JOB>_MACROBOOK.lua`:

```lua
local WARMacroConfig = {}

WARMacroConfig.default = { book = 22, page = 1 }

WARMacroConfig.macrobooks = {
    ['SAM'] = { book = 22, page = 1 },
    ['DRG'] = { book = 25, page = 1 },
    ['DNC'] = { book = 28, page = 1 },
}

return WARMacroConfig
```

The framework calls `set_macro_book(book, page)` automatically through
`MacrobookManager`. Don't write manual `send_command` calls.

---

## Keybinds

`<Yourname>/config/<job>/<JOB>_KEYBINDS.lua`:

```lua
local WARKeybinds = {}

WARKeybinds.binds = {
    { key = "!1", command = "cyclestate MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    { key = "!2", command = "cyclestate HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
    -- Add more as needed
}

return WARKeybinds
```

`key` uses Windower's syntax:

| Prefix | Modifier |
| --- | --- |
| `!` | Alt |
| `^` | Ctrl |
| `@` | Win |
| (none) | bare key |

Examples: `!1` = Alt+1, `^!2` = Ctrl+Alt+2, `!#9` = Alt+Shift+9.

The framework calls `windower.send_command('bind ' .. key .. ' gs c <command>')`
on load and unbinds on unload.

> Mote-Include's universal F9-F12 binds are **not** registered — every
> shortcut is per-job by design.

---

## States

`<Yourname>/config/<job>/<JOB>_STATES.lua`:

```lua
local WARStates = {}

function WARStates.setup()
    state.MainWeapon = M{ ['description'] = 'Main Weapon',
        'Ukonvasara', 'Naegling', 'Chango', 'Loxotic Mace' }

    state.HybridMode:options('Normal', 'PDT', 'SubtleBlow')

    state.OffenseMode:options('Normal', 'Acc')
end

return WARStates
```

States are Mote-Include `M{}` collections. They auto-cycle via
`//gs c cyclestate <Name>` and surface in the UI overlay.

---

## DualBox

`<Yourname>/config/DUALBOX_CONFIG.lua`:

```lua
return {
    role = 'main',                 -- 'main' or 'alt'
    character_name = 'Tetsouo',    -- this character
    alt_character = 'Kaories',     -- partner (only set on main)
    main_character = nil,          -- partner (only set on alt)
    enabled = true,
    timeout = 30,                  -- IPC ack timeout (seconds)
    debug = false,
}
```

See [DualBox guide](dualbox.md) for the IPC handshake flow and
broadcasting commands.

---

## Refill (consumables)

`<Yourname>/config/<job>/<JOB>_REFILL.lua`:

```lua
local M = {}

M.store_bag = 'case'    -- 'case' | 'sack' | 'satchel'

M.default = {
    { name = 'Sublime Sushi +1', target = 12 },
    { name = { 'Red Curry Bun +1', 'Sublime Sushi +1' }, target = 12 },  -- alternates
    { name = 'Panacea',          target = 12 },
    { name = 'Holy Water',       target = 12 },
}

M.subjobs = {
    SAM = { { name = 'Hi-Reraiser', target = 1 } },
}

return M
```

How it works:

- The refill manager reads the active job/subjob config, compares against
  current inventory, and pulls from `store_bag` to top up.
- Surplus (more than `target`) gets pushed back to `store_bag`.
- Items in your inventory but not in the active config are also pushed to
  `store_bag` — keeps the inv lean for the active job.
- When a craft set is active (`_G.__CraftManagerState.active`), the
  manager swaps to `<Yourname>/config/craft/CRAFT_REFILL.lua` and shoves
  everything else to Case.

Trigger with `//gs c rf` or `//gs c refill`.

---

## Wardrobe layout

`<Yourname>/config/WARDROBE_CONFIG.lua`:

```lua
return {
    PRIMARY_BAGS  = { 'wardrobe', 'wardrobe 2' },                    -- W1-W2 hold the active job's gear
    OVERFLOW_BAGS = { 'wardrobe 3', 'wardrobe 4', 'wardrobe 5',
                      'wardrobe 6', 'wardrobe 8' },                  -- W3-W6, W8
    PROTECTED     = { 'wardrobe 7' },                                -- W7 reserved (e.g. craft gear)
}
```

Used by `//gs c wo`. Per-character overrides let mains use 8 wardrobes
and alts share fewer.

---

## UI overlay

`<Yourname>/config/UI_CONFIG.lua` controls behavior; `<Yourname>/config/ui_settings.lua`
holds position + toggles (auto-written by `//gs c ui save`).

See [UI feature doc](../features/ui.md) for the full settings surface.

---

## Custom states (extending a job)

In your entry-point or in `<JOB>_STATES.lua`:

```lua
function user_setup()
    state.MyCustomState = M{ 'Option1', 'Option2', 'Option3' }
end
```

Then bind it in `<JOB>_KEYBINDS.lua`:

```lua
{ key = "!9", command = "cyclestate MyCustomState", desc = "My Custom", state = "MyCustomState" },
```

The UI overlay picks it up automatically because it iterates `state.*`.

---

## Equipment sets

`<Yourname>/sets/<job>_sets.lua` — see the
[sets-editing rules](../../../.claude/rules/sets-editing.md) (private)
for naming conventions, or read [the README's sets section](../../../README.md).
Validate with `//gs c checksets`.

---

## Troubleshooting

| Symptom | Try |
| --- | --- |
| Edit doesn't apply | `//gs c reload`. If still nothing, check Windower console for Lua syntax errors and confirm the file path matches. |
| Lockstyle silently fails | Increase `delay_after_load`. Verify DressUp is loaded. Check `by_subjob` key matches FFXI subjob spelling. |
| Macrobook not changing | Verify the book/page exists in FFXI. Check subjob spelling. |
| `//gs c rf` says "Need N more free slots" | The pre-check refuses to run if there isn't room to gather slips. Free 33 slots, then retry. |
| `//gs c wo` stalls | `//gs c wo recover` re-enables every slot. |
