# UI System - Interface Customization

Complete guide for customizing the Tetsouo GearSwap UI overlay system.


**Universal**: Works for all 15 jobs (WAR, PLD, DNC, DRK, SAM, THF, RDM, WHM, BLM, GEO, COR, BRD, BST)

---

## Table of Contents

- [Overview](#overview)
- [Configuration File](#configuration-file)
- [Position and Display](#position-and-display)
- [Visible Sections](#visible-sections)
- [Visual Appearance](#visual-appearance)
- [Advanced Settings](#advanced-settings)
- [Configuration Examples](#configuration-examples)
- [Applying Changes](#applying-changes)

---

## Overview

The UI system provides a visual overlay displaying:

- **Current states** (MainWeapon, HybridMode, etc.)
- **Keybind reference** (which keys do what)
- **Job-specific settings** (automatic per job)
- **Alt character job** (if DualBox enabled)

### Quick Commands

```bash
//gs c ui        # Toggle UI on/off
Alt+F1          # Quick toggle (default keybind)
//gs c ui save   # Save current position
```

---

## Configuration File

**File**: `config/UI_CONFIG.lua`

This file controls all UI appearance and behavior settings.

---

## Position and Display

### Enable/Disable UI

```lua
-- Enable/Disable UI on startup
UIConfig.enabled = true  -- Set to false to disable
```

#### In-game commands:

```bash
//gs c ui          # Toggle UI on/off
Alt+F1            # Quick toggle (if keybind set)
```

---

### Position Configuration

```lua
-- Default position (X, Y coordinates)
UIConfig.default_position = {
    x = 1862,  -- Horizontal position
    y = -11    -- Vertical position
}
```

#### Finding Your Position

1. Enable draggable mode (see [Draggable Flag](#draggable-flag))
2. Move UI to desired position with mouse
3. Type `//gs c ui save` to save
4. Position automatically saved to `ui_position.lua`

**Tip**: Negative Y values move UI upward from bottom of screen.

---

### Initialization Delay

```lua
-- Delay before UI loads after job change (seconds)
UIConfig.init_delay = 5.0
```

**Why delays?**

- Prevents UI loading before character data is ready
- Avoids errors during job transitions
- 5.0s is safe for most systems

**Recommended values**:

- **5.0s** (default) - Safe for most systems
- **3.0s** - Fast systems/SSDs
- **7.0s** - Slow systems/HDDs

---

## Visible Sections

### Header and Footer

```lua
-- Show/Hide header section (title + legend)
UIConfig.show_header = true

-- Show/Hide legend (Ctrl/Alt/Windows/Shift symbols)
UIConfig.show_legend = true

-- Show/Hide column headers (Key | Function | Current)
UIConfig.show_column_headers = true

-- Show/Hide footer (//gs c ui command)
UIConfig.show_footer = true
```

**Example: Minimal UI (keybinds only)**

```lua
UIConfig.show_header = false         -- No title
UIConfig.show_legend = false         -- No legend
UIConfig.show_column_headers = false -- No headers
UIConfig.show_footer = false         -- No footer
```

---

### Content Sections

```lua
-- Show/Hide specific content sections
UIConfig.sections = {
    spells = true,        -- Spell/ability keybinds
    enhancing = true,     -- Enhancing cycles (RDM)
    job_abilities = true, -- Job ability keybinds
    weapons = true,       -- Weapon cycling
    modes = true          -- Mode toggles (HybridMode, etc.)
}
```

**Example: Hide spell section**

```lua
UIConfig.sections = {
    spells = false,       -- Hide spells
    enhancing = true,
    job_abilities = true,
    weapons = true,
    modes = true
}
```

**Note**: Empty sections automatically hidden (no manual configuration needed).

---

## Visual Appearance

### Text Configuration

```lua
UIConfig.text = {
    size = 12,         -- Font size
    font = 'Consolas', -- Font family (Consolas, Arial, etc.)
    stroke = {
        width = 2,     -- Outline thickness
        alpha = 255,   -- Outline opacity (0-255)
        red = 0,       -- Outline color RGB
        green = 0,
        blue = 0
    }
}
```

#### Popular Fonts

- `Consolas` - Monospace (default, best for alignment)
- `Arial` - Standard sans-serif
- `Courier New` - Typewriter style
- `Verdana` - High readability

**Example: Larger text with blue outline**

```lua
UIConfig.text = {
    size = 14,         -- Bigger
    font = 'Arial',
    stroke = {
        width = 3,     -- Thicker outline
        alpha = 255,
        red = 0,       -- Blue
        green = 100,
        blue = 255
    }
}
```

---

### Background Configuration

```lua
UIConfig.background = {
    alpha = 100, -- Opacity (0-255): 0=transparent, 255=opaque
    red = 10,    -- Background color RGB
    green = 10,
    blue = 25,
    visible = true -- Show background
}
```

#### Background Examples

**Semi-transparent black:**

```lua
UIConfig.background = {
    alpha = 150,
    red = 0,
    green = 0,
    blue = 0,
    visible = true
}
```

**Dark blue:**

```lua
UIConfig.background = {
    alpha = 120,
    red = 10,
    green = 20,
    blue = 50,
    visible = true
}
```

**No background (transparent):**

```lua
UIConfig.background = {
    visible = false
}
```

---

### Formatting Options

```lua
UIConfig.flags = {
    draggable = true, -- Allow moving UI with mouse
    bold = true       -- Bold text
}
```

#### Draggable Flag

**`draggable = true`** allows you to:

1. Click and drag UI to new position in-game
2. Save position with `//gs c ui save`
3. Position persists across reloads

**Tip**: Set to `false` after positioning to prevent accidental moves.

---

## Advanced Settings

### Custom Colors (Advanced)

```lua
-- Override default colors (nil = use system defaults)
UIConfig.colors = {
    header_separator = nil, -- "\\cs(100,150,255)" format
    section_title = nil,
    key_text = nil,
    description_text = nil,
    value_text = nil
}
```

**Color format**: `\\cs(R,G,B)` where R, G, B are 0-255

**Example: Custom color scheme**

```lua
UIConfig.colors = {
    header_separator = "\\cs(100,150,255)", -- Light blue
    section_title = "\\cs(255,200,100)",    -- Orange
    key_text = "\\cs(150,255,150)",         -- Light green
    description_text = "\\cs(200,200,255)", -- Pale blue
    value_text = "\\cs(255,255,100)"        -- Yellow
}
```

**Recommendation**: Leave as `nil` to use system defaults (recommended for consistency).

---

### Auto-Save Position

```lua
-- Auto-save position on drag
UIConfig.auto_save_position = false  -- true for auto-save

-- Auto-save delay in seconds
UIConfig.auto_save_delay = 1.5
```

#### Save Modes

- `false` - Manual save with `//gs c ui save` (recommended)
- `true` - Auto-save after dragging (1.5s delay)

---

### Performance and Debug

```lua
-- Show debug messages
UIConfig.debug = false  -- true to see debug messages

-- Update frequency
-- 0 = update only on state change (recommended)
-- 1-10 = update every N frames
UIConfig.update_throttle = 0
```

**Recommendation**: Keep `update_throttle = 0` for best performance.

---

## Configuration Examples

### Minimal Configuration (Compact)

```lua
UIConfig.enabled = true
UIConfig.show_header = false
UIConfig.show_legend = false
UIConfig.show_column_headers = false
UIConfig.show_footer = false

UIConfig.text = {
    size = 10,
    font = 'Consolas'
}

UIConfig.background = {
    alpha = 80,
    visible = true
}
```

**Result**: Small, compact UI showing only keybinds and current values.

---

### Complete Configuration (Full)

```lua
UIConfig.enabled = true
UIConfig.show_header = true
UIConfig.show_legend = true
UIConfig.show_column_headers = true
UIConfig.show_footer = true

UIConfig.text = {
    size = 14,
    font = 'Arial'
}

UIConfig.background = {
    alpha = 150,
    visible = true
}

UIConfig.sections = {
    spells = true,
    enhancing = true,
    job_abilities = true,
    weapons = true,
    modes = true
}
```

**Result**: Full UI with all sections, headers, and footer visible.

---

### HUD Style (Transparent)

```lua
UIConfig.enabled = true
UIConfig.show_header = false
UIConfig.show_footer = false

UIConfig.text = {
    size = 12,
    font = 'Consolas',
    stroke = {
        width = 3,      -- Thick outline for visibility
        alpha = 255
    }
}

UIConfig.background = {
    alpha = 50,         -- Very transparent
    visible = true
}
```

**Result**: Minimal HUD-style overlay with thick text outline, semi-transparent background.

---

## Applying Changes

After modifying `config/UI_CONFIG.lua`:

```bash
//gs c reload
```

UI reloads with your new settings.

**Note**: Position changes require save:

```bash
//gs c ui save
```

---

## Troubleshooting

### Issue: "UI not displaying"

**Solutions**:

1. **Check if enabled**:

   ```lua
   UIConfig.enabled = true
   ```

2. **Toggle UI**:

   ```bash
   //gs c ui
   ```

3. **Check position**:
 - UI may be off-screen
 - Delete `ui_position.lua` to reset
 - Reload: `//gs c reload`

---

### Issue: "UI position resets every login"

**Solutions**:

1. **Save position manually**:

   ```bash
   //gs c ui save
   ```

2. **Verify file exists**:
 - Path: `[YourName]/ui_position.lua`
 - If missing, save command failed

3. **Enable auto-save** (optional):

   ```lua
   UIConfig.auto_save_position = true
   ```

---

### Issue: "Keybinds not showing in UI"

**Solutions**:

1. **Verify keybind has valid state**:

   ```lua
   {key = "!1", command = "cycle MainWeapon", desc = "Main Weapon", state = "MainWeapon"},
   --                                                                    ↑ must exist
   ```

2. **State must be defined in job file**:

   ```lua
   state.MainWeapon = M{'Ukonvasara', 'Naegling', ...}
   ```

3. **Refresh UI**:

   ```bash
   //gs c ui     # Toggle off
   //gs c ui     # Toggle on
   ```

---

### Issue: "UI appears but is blank"

**Solutions**:

1. **Check sections enabled**:

   ```lua
   UIConfig.sections = {
       weapons = true,
       modes = true
       -- At least one section must be true
   }
   ```

2. **Check keybind config loaded**:
 - Look for "[JOB] Keybinds loaded successfully" message on job load

3. **Verify states exist**:
 - UI shows states from job file
 - If no states defined, UI appears empty

---

## Best Practices

### Organization

1. **Edit config file, not core code**:
 - Modify: `config/UI_CONFIG.lua`
 - Don't modify: `shared/utils/ui/UI_MANAGER.lua`

2. **Test changes immediately**:
 - Save config >> `//gs c reload` >> check UI

3. **Save position after positioning**:
 - Drag to desired location >> `//gs c ui save`

---

### Performance

1. **Keep update throttle at 0**:

   ```lua
   UIConfig.update_throttle = 0  -- Only update on state change
   ```

2. **Disable unused sections**:

   ```lua
   UIConfig.sections = {
       spells = false,  -- If you don't use spell keybinds
   }
   ```

3. **Disable debug in production**:

   ```lua
   UIConfig.debug = false
   ```

---

## Quick Reference

| Setting | Purpose | Default |
|---------|---------|---------|
| `enabled` | Enable/disable UI | `true` |
| `init_delay` | Delay before UI loads (seconds) | `5.0` |
| `show_header` | Show title and legend | `true` |
| `show_footer` | Show command reference | `true` |
| `draggable` | Allow moving with mouse | `true` |
| `text.size` | Font size | `12` |
| `text.font` | Font family | `'Consolas'` |
| `background.alpha` | Background opacity (0-255) | `100` |
| `auto_save_position` | Auto-save position on drag | `false` |

---

## Next Steps

- **[Commands Reference](../guides/commands.md)** - All available commands
- **[Keybinds Guide](../guides/keybinds.md)** - Customize keyboard shortcuts
- **[Configuration Guide](../guides/configuration.md)** - Advanced configuration
- **[FAQ](../guides/faq.md)** - Common issues and solutions

---

