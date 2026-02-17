# Keybinds

All jobs use per-job keybind config files at `Tetsouo/config/[job]/[JOB]_KEYBINDS.lua`.

Keybinds bind on job load and unbind on job change. The UI overlay shows them automatically.

---

## Format

```lua
[JOB]Keybinds.binds = {
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon" },
    { key = "!2", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
}
```

| Field | Description | Example |
|-------|-------------|---------|
| `key` | Key combination | `"!1"` (Alt+1) |
| `command` | GearSwap command to run | `"cycle MainWeapon"` |
| `desc` | Label shown in UI | `"Main Weapon"` |
| `state` | State name for UI value display | `"MainWeapon"` |

---

## Key modifiers

| Symbol | Key |
|--------|-----|
| `!` | Alt |
| `^` | Ctrl |
| `@` | Windows |
| `#` | Shift |

Examples: `!1` = Alt+1, `^f9` = Ctrl+F9, `!a` = Alt+A

Valid keys: `0-9`, `a-z` (lowercase), `f1-f12`, `pageup`, `pagedown`, `home`, `end`, `insert`, `delete`

---

## Command types

| Type | Example | Effect |
|------|---------|--------|
| `cycle` | `cycle MainWeapon` | Rotate through state values |
| `set` | `set HybridMode PDT` | Force a specific value |
| `toggle` | `toggle Kiting` | On/Off toggle |

Job-specific commands (e.g., `waltz`, `ecosystem`, `afflatus`) are documented in each job's states.md and in the [commands reference](commands.md).

---

## Applying changes

After editing a keybind config file:

```
//gs c reload
```

Old keybinds unbind, new ones bind, UI refreshes.

---

## Notes

- **Avoid reserved keys**: F9-F12 (GearSwap/Mote), Ctrl+H (Windower hide)
- **Case matters**: use `"!a"` not `"!A"` for key codes; command/state names are case-sensitive (`MainWeapon` not `mainweapon`)
- **Commas required** after each entry except the last
- **state field**: must match a `state.X` defined in the job file, or the UI won't show a current value
- Per-job keybind listings are in each job's [states.md](../jobs/README.md)
