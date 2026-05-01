# Keybinds

Keybinds are defined per-job in
`<Yourname>/config/<job>/<JOB>_KEYBINDS.lua`. The framework binds on job
load and unbinds on job change. The UI overlay shows them automatically.

> **There are no universal keybinds** other than `Alt+F1` (UI toggle).
> Mote-Include's default F9-F12 binds are intentionally not registered.

---

## File format

```lua
local WARKeybinds = {}

WARKeybinds.binds = {
    { key = "!1", command = "cyclestate MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    { key = "!2", command = "cyclestate HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
}

return WARKeybinds
```

| Field | Required | Description |
| --- | --- | --- |
| `key` | yes | Windower key syntax. `!1` = Alt+1. |
| `command` | yes | The GearSwap command to send (no leading `gs c`). |
| `desc` | yes | Label shown in the UI overlay. |
| `state` | no | Mote state name. The UI uses it to show the current value next to the binding. |
| `subjob` | no | Restrict binding to a specific subjob (e.g. `subjob = "BLU"`). |

---

## Key syntax

| Prefix | Modifier |
| --- | --- |
| `!` | Alt |
| `^` | Ctrl |
| `#` | Shift |
| `@` | Win |
| (none) | bare key |

Combine prefixes freely: `^!1` = Ctrl+Alt+1, `!#a` = Alt+Shift+A.

Valid bare keys: `0-9`, `a-z` (lowercase), `f1`-`f12`, `pageup`,
`pagedown`, `home`, `end`, `insert`, `delete`, `space`, `tab`,
`backspace`, `escape`, `numpad0`-`numpad9`, `numpadadd`, `numpadsubtract`.

---

## Command types

The most common commands you'll bind:

| Command | Example | Effect |
| --- | --- | --- |
| `cyclestate <Name>` | `cyclestate MainWeapon` | Rotate through state values forward |
| `cyclebackstate <Name>` | `cyclebackstate MainWeapon` | Rotate backward |
| `set <Name> <Value>` | `set HybridMode PDT` | Force a specific value |
| `toggle <Name>` | `toggle Kiting` | On/Off toggle |
| `<job-specific>` | `aoe`, `rune`, `step`, `fbc`, `rolls`, ... | See [commands reference](commands.md) |

State names are **case-sensitive**: `cyclestate MainWeapon` works,
`cyclestate mainweapon` does not. They must match the `state.<Name>`
declared in your `<JOB>_STATES.lua`.

---

## Subjob-restricted binds

Some binds only make sense for specific subjobs. Use the `subjob` field:

```lua
{ key = "!4", command = "aoe",  desc = "AoE BLU rotation", subjob = "BLU" },
{ key = "!5", command = "rune", desc = "Rune",             subjob = "RUN" },
```

The framework binds these only when the matching subjob is active.

---

## Applying changes

```
//gs c reload
```

The reload unbinds the previous job's keybinds, loads the new
`<JOB>_KEYBINDS.lua`, and re-renders the UI overlay.

---

## Per-job examples

Real keybinds shipped in `_master/config/<job>/<JOB>_KEYBINDS.lua`. Open
yours for the full list — these are highlights only.

### WAR

| Key | Command | Notes |
| --- | --- | --- |
| Alt+1 | `cyclestate MainWeapon` | Ukonvasara, Naegling, Chango, … |
| Alt+2 | `cyclestate HybridMode` | Normal / PDT / SubtleBlow |

### DNC

| Key | Command | Notes |
| --- | --- | --- |
| Alt+1 | `cyclestate MainWeapon` | |
| Ctrl+1 | `cyclestate SubWeaponOverride` | |
| Alt+2 | `cyclestate HybridMode` | |
| Alt+3 | `cyclestate MainStep` | Main step rotation |
| Alt+4 | `cyclestate AltStep` | Alt step rotation |
| Alt+5 | `cyclestate UseAltStep` | Toggle |
| Alt+6 | `cyclestate ClimacticAuto` | |
| Alt+7 | `cyclestate JumpAuto` | |
| Alt+8 | `cyclestate Dance` | |
| Ctrl+8 | `dance` | Activate selected dance |

### PLD

| Key | Command | Notes |
| --- | --- | --- |
| Alt+1 | `cyclestate MainWeapon` | |
| Alt+2 | `cyclestate HybridMode` | |
| Alt+4 | `aoe` | BLU enmity rotation (subjob = BLU) |
| Alt+5 | `rune` | (subjob = RUN) |

### RDM

| Key | Command | Notes |
| --- | --- | --- |
| F1 | `cyclestate GainSpell` | |
| F2 | `cyclestate Barspell` | |
| F3 | `cyclestate BarAilment` | |
| F4 | `cyclestate Spike` | |
| F5 | `cyclestate Storm` | (subjob = SCH) |
| F6 | `cyclestate EnSpell` | |

### COR

| Key | Command | Notes |
| --- | --- | --- |
| Alt+3 | `rolls` | Show active rolls |
| Alt+4 | `doubleup` | Double-Up status |

> Open `_master/config/<job>/<JOB>_KEYBINDS.lua` for the canonical full
> list; copy + edit your own at
> `<Yourname>/config/<job>/<JOB>_KEYBINDS.lua`.

---

## Notes & gotchas

- **Reserved keys**: avoid F9-F12 if you also use other addons that bind
  them; Ctrl+H is reserved by Windower for chat hiding.
- **The `state` field is optional but recommended** — without it, the UI
  shows the keybind but no current value.
- **Commas required** after every entry except the last (Lua list rules).
- **Case-sensitive everywhere**: `"!a"` (lowercase), `state = "MainWeapon"`
  (CamelCase exactly as defined).
- **Subjob field is exact**: `"BLU"`, not `"blu"`.
- The whole `<JOB>_KEYBINDS.lua` file is hot-reloaded on every job change,
  so you can iterate without restarting GearSwap.
