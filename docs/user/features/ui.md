# UI Overlay

Visual overlay displaying current states, keybinds, and job settings. Works for all 15 jobs.

---

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `ui` | | Toggle UI visibility |
| `ui on` | `ui enable` | Enable UI |
| `ui off` | `ui disable` | Disable UI (persists across reloads) |
| `ui header` | `ui h` | Toggle header section |
| `ui legend` | `ui l` | Toggle legend section |
| `ui columns` | `ui c` | Toggle column headers |
| `ui footer` | `ui f` | Toggle footer section |
| `ui font <name>` | | Change font (`Consolas` or `Courier New`) |
| `ui bg <preset>` | `ui theme` | Apply a background preset |
| `ui bg toggle` | `ui theme toggle` | Toggle background visibility |
| `ui bg list` | `ui theme list` | List available presets |
| `ui bg <r> <g> <b> <a>` | | Custom background RGBA (0-255) |
| `ui save` | `ui s` | Save position and settings |
| `ui help` | `ui ?` | Show help |

---

## Configuration

**File**: `config/UI_CONFIG.lua`

### Position

Drag the overlay to where you want it, then run `//gs c ui save`. Position persists across reloads. Delete `ui_position.lua` to reset.

### Settings reference

| Setting | Default | Description |
|---------|---------|-------------|
| `enabled` | `true` | Show UI on startup |
| `init_delay` | `5.0` | Seconds before UI loads after job change |
| `show_header` | `true` | Title bar |
| `show_legend` | `true` | Modifier key legend |
| `show_column_headers` | `true` | Column header row |
| `show_footer` | `true` | Command reference line |
| `flags.draggable` | `true` | Allow mouse drag |
| `text.size` | `10` | Font size |
| `text.font` | `'Consolas'` | Font family |
| `background.r/g/b` | `15/15/35` | Background color (0-255) |
| `background.a` | `180` | Background opacity (0-255) |
| `background.visible` | `true` | Show background |
| `auto_save_position` | `false` | Auto-save on drag |
| `update_throttle` | `0` | 0 = update on state change only |
| `debug` | `false` | Debug messages |

### Sections

```lua
UIConfig.sections = {
    spells = true,
    enhancing = true,
    job_abilities = true,
    weapons = true,
    modes = true
}
```

Empty sections are hidden automatically.

### Custom colors

```lua
UIConfig.colors = {
    header_separator = nil,   -- "\\cs(R,G,B)" format, nil = system default
    section_title = nil,
    key_text = nil,
    description_text = nil,
    value_text = nil
}
```

### Background presets

Switch at runtime with `//gs c ui theme <name>`. Use `//gs c ui theme list` to see all presets.

---

## Troubleshooting

**UI not visible**: Check `UIConfig.enabled = true`. Try `//gs c ui`. If off-screen, delete `ui_position.lua` and reload.

**Position resets**: Run `//gs c ui save` after positioning.

**Keybinds not showing**: The keybind entry must have a `state` field that matches a defined `state.X` in the job file. Toggle UI off/on to refresh.
